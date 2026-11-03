-- =====================================================
-- Procedure 9 (fixed): bulk_delete_inactive_employees
-- File: 01_procedures/bulk_delete_inactive_employees.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE bulk_delete_inactive_employees (
  p_rows_deleted  OUT NUMBER,
  p_rows_failed   OUT NUMBER,
  p_commit        IN  VARCHAR2 DEFAULT 'Y'
)
IS
  TYPE t_num_tab IS TABLE OF NUMBER;
  v_ids       t_num_tab;
  v_err_idx   t_num_tab := t_num_tab();
  v_err_code  t_num_tab := t_num_tab();
  v_msg       VARCHAR2(500);

  e_bulk_errors       EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);
  e_nothing_to_delete EXCEPTION;
BEGIN
  p_rows_deleted := 0;
  p_rows_failed  := 0;

  SELECT employee_id
  BULK COLLECT INTO v_ids
  FROM   employee
  WHERE  status = 'INACTIVE';

  IF v_ids.COUNT = 0 THEN
    RAISE e_nothing_to_delete;
  END IF;

  BEGIN
    FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
      DELETE FROM employee
      WHERE  employee_id = v_ids(i);
  EXCEPTION
    WHEN e_bulk_errors THEN
      FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
        v_err_idx.EXTEND;
        v_err_code.EXTEND;
        v_err_idx(v_err_idx.LAST)   := SQL%BULK_EXCEPTIONS(j).ERROR_INDEX;
        v_err_code(v_err_code.LAST) := SQL%BULK_EXCEPTIONS(j).ERROR_CODE;
      END LOOP;
  END;

  p_rows_failed  := v_err_idx.COUNT;
  p_rows_deleted := v_ids.COUNT - p_rows_failed;

  FOR j IN 1 .. v_err_idx.COUNT LOOP
    v_msg := SUBSTR('Employee ID ' || v_ids(v_err_idx(j)) || ': ' || SQLERRM(-v_err_code(j)), 1, 500);
    INSERT INTO error_log (error_source, error_message)
    VALUES ('bulk_delete_inactive_employees', v_msg);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Inactive employees found: ' || v_ids.COUNT ||
                       ' | deleted: ' || p_rows_deleted ||
                       ' | failed: ' || p_rows_failed);

  IF p_commit = 'Y' THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN e_nothing_to_delete THEN
    RAISE_APPLICATION_ERROR(-20019, 'There are no INACTIVE employees to delete.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END bulk_delete_inactive_employees;
/
SHOW ERRORS PROCEDURE bulk_delete_inactive_employees