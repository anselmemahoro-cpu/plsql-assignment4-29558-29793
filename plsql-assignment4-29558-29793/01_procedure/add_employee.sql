-- =====================================================
-- Procedure 1: add_employee
-- File: 01_procedures/add_employee.sql
-- Uses: implicit cursor (INSERT), SQL%ROWCOUNT, OUT parameter,
--       user-defined exception, DUP_VAL_ON_INDEX
-- =====================================================
CREATE OR REPLACE PROCEDURE add_employee (
  p_first_name       IN  VARCHAR2,
  p_last_name        IN  VARCHAR2,
  p_email            IN  VARCHAR2,
  p_salary           IN  NUMBER,
  p_job_id           IN  NUMBER,
  p_department_id    IN  NUMBER,
  p_manager_id       IN  NUMBER,
  p_new_employee_id  OUT NUMBER
)
IS
  e_invalid_salary    EXCEPTION;   -- user-defined exception
  e_parent_not_found  EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_parent_not_found, -2291);   -- ORA-02291: parent key not found
BEGIN
  -- salary must be inside the job range
  IF is_salary_valid(p_job_id, p_salary) = 'N' THEN
    RAISE e_invalid_salary;
  END IF;

  INSERT INTO employee (first_name, last_name, email, salary, job_id, department_id, manager_id)
  VALUES (p_first_name, p_last_name, p_email, p_salary, p_job_id, p_department_id, p_manager_id)
  RETURNING employee_id INTO p_new_employee_id;

  -- implicit cursor attribute
  DBMS_OUTPUT.PUT_LINE('Rows inserted: ' || SQL%ROWCOUNT);
  DBMS_OUTPUT.PUT_LINE('New employee ID: ' || p_new_employee_id);

  COMMIT;

EXCEPTION
  WHEN e_invalid_salary THEN
    RAISE_APPLICATION_ERROR(-20008, 'Salary ' || p_salary || ' is outside the allowed range for this job.');
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20009, 'Email ' || p_email || ' already exists.');
  WHEN e_parent_not_found THEN
    RAISE_APPLICATION_ERROR(-20010, 'Department or manager does not exist.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;   -- do not hide unexpected errors
END add_employee;
/