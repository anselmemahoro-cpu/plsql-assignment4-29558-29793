-- =====================================================
-- Procedure 8 (fixed): bulk_adjust_salaries
-- File: 01_procedures/bulk_adjust_salaries.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE bulk_adjust_salaries (
  p_department_name  IN  VARCHAR2,
  p_amount           IN  NUMBER,
  p_rows_updated     OUT NUMBER,
  p_rows_failed      OUT NUMBER,
  p_commit           IN  VARCHAR2 DEFAULT 'Y'
)
IS
  TYPE t_num_tab  IS TABLE OF NUMBER;
  TYPE t_flag_tab IS TABLE OF BOOLEAN INDEX BY PLS_INTEGER;

  v_ids        t_num_tab;
  v_old_sal    t_num_tab;
  v_err_idx    t_num_tab := t_num_tab();
  v_err_code   t_num_tab := t_num_tab();
  v_hist_ids   t_num_tab := t_num_tab();
  v_hist_old   t_num_tab := t_num_tab();
  v_hist_new   t_num_tab := t_num_tab();
  v_failed     t_flag_tab;

  v_department_id  department.department_id%TYPE;
  v_msg            VARCHAR2(500);

  e_bulk_errors     EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);
  e_invalid_amount  EXCEPTION;
  e_no_employees    EXCEPTION;
BEGIN
  p_rows_updated := 0;
  p_rows_failed  := 0;

  IF p_amount IS NULL OR p_amount = 0 THEN
    RAISE e_invalid_amount;
  END IF;

  IF p_department_name IS NOT NULL THEN
    SELECT department_id
    INTO   v_department_id
    FROM   department
    WHERE  department_name = p_department_name;
  END IF;

  -- 1. BULK COLLECT
  SELECT employee_id, salary
  BULK COLLECT INTO v_ids, v_old_sal
  FROM   employee
  WHERE  status = 'ACTIVE'
  AND    (v_department_id IS NULL OR department_id = v_department_id);

  IF v_ids.COUNT = 0 THEN
    RAISE e_no_employees;
  END IF;

  -- 2. FORALL UPDATE with SAVE EXCEPTIONS
  BEGIN
    FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
      UPDATE employee
      SET    salary = salary + p_amount
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

  -- 3. Save the failed rows in error_log
  p_rows_failed := v_err_idx.COUNT;
  FOR j IN 1 .. v_err_idx.COUNT LOOP
    v_failed(v_err_idx(j)) := TRUE;
    v_msg := SUBSTR('Employee ID ' || v_ids(v_err_idx(j)) || ': ' || SQLERRM(-v_err_code(j)), 1, 500);
    INSERT INTO error_log (error_source, error_message)
    VALUES ('bulk_adjust_salaries', v_msg);
  END LOOP;

  -- 4. Collect only the rows updated successfully
  FOR i IN 1 .. v_ids.COUNT LOOP
    IF NOT v_failed.EXISTS(i) THEN
      v_hist_ids.EXTEND;
      v_hist_old.EXTEND;
      v_hist_new.EXTEND;
      v_hist_ids(v_hist_ids.LAST) := v_ids(i);
      v_hist_old(v_hist_old.LAST) := v_old_sal(i);
      v_hist_new(v_hist_new.LAST) := v_old_sal(i) + p_amount;
    END IF;
  END LOOP;

  p_rows_updated := v_hist_ids.COUNT;

  -- 5. FORALL INSERT into salary_history
  IF v_hist_ids.COUNT > 0 THEN
    FORALL i IN 1 .. v_hist_ids.COUNT
      INSERT INTO salary_history (employee_id, old_salary, new_salary)
      VALUES (v_hist_ids(i), v_hist_old(i), v_hist_new(i));
  END IF;

  DBMS_OUTPUT.PUT_LINE('Employees found: ' || v_ids.COUNT ||
                       ' | updated: ' || p_rows_updated ||
                       ' | failed: ' || p_rows_failed);

  IF p_commit = 'Y' THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN e_invalid_amount THEN
    RAISE_APPLICATION_ERROR(-20017, 'Amount must be a number different from zero.');
  WHEN e_no_employees THEN
    RAISE_APPLICATION_ERROR(-20018, 'No active employees found to update.');
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20005, 'Department ' || p_department_name || ' does not exist.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END bulk_adjust_salaries;
/