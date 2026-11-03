-- =====================================================
-- Procedure 3: delete_employee
-- File: 01_procedures/delete_employee.sql
-- Uses: implicit cursor (DELETE), SQL%ROWCOUNT, SQL%NOTFOUND,
--       OUT parameter, ORA-02292 (child records found)
-- =====================================================
CREATE OR REPLACE PROCEDURE delete_employee (
  p_employee_id   IN  NUMBER,
  p_rows_deleted  OUT NUMBER
)
IS
  e_child_found  EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_child_found, -2292);   -- ORA-02292: child record found
BEGIN
  DELETE FROM employee
  WHERE  employee_id = p_employee_id;

  p_rows_deleted := SQL%ROWCOUNT;

  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Employee ID ' || p_employee_id || ' does not exist. Nothing deleted.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Rows deleted: ' || p_rows_deleted);
  COMMIT;

EXCEPTION
  WHEN e_child_found THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20013, 'Cannot delete employee ' || p_employee_id || ': it has salary history or manages other employees.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END delete_employee;
/