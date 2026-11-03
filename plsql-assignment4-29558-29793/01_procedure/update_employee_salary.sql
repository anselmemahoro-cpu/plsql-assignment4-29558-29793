-- =====================================================
-- Procedure 2: update_employee_salary
-- File: 01_procedures/update_employee_salary.sql
-- Uses: implicit cursor (UPDATE), SQL%FOUND, SQL%NOTFOUND, SQL%ROWCOUNT,
--       %ROWTYPE record, OUT parameter, NO_DATA_FOUND
-- Saves the change in salary_history
-- =====================================================
CREATE OR REPLACE PROCEDURE update_employee_salary (
  p_employee_id  IN  NUMBER,
  p_new_salary   IN  NUMBER,
  p_old_salary   OUT NUMBER
)
IS
  v_emp   employee%ROWTYPE;   -- record with all employee columns
  v_rows  NUMBER;
BEGIN
  SELECT *
  INTO   v_emp
  FROM   employee
  WHERE  employee_id = p_employee_id;

  IF v_emp.status = 'INACTIVE' THEN
    RAISE_APPLICATION_ERROR(-20004, 'Employee ID ' || p_employee_id || ' is INACTIVE. Salary not changed.');
  END IF;

  IF p_new_salary = v_emp.salary THEN
    RAISE_APPLICATION_ERROR(-20012, 'New salary is the same as the current salary.');
  END IF;

  IF is_salary_valid(v_emp.job_id, p_new_salary) = 'N' THEN
    RAISE_APPLICATION_ERROR(-20008, 'Salary ' || p_new_salary || ' is outside the allowed range for this job.');
  END IF;

  p_old_salary := v_emp.salary;

  UPDATE employee
  SET    salary = p_new_salary
  WHERE  employee_id = p_employee_id;

  v_rows := SQL%ROWCOUNT;   -- save it now, the next INSERT will reset SQL%

  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Employee ID ' || p_employee_id || ' was not updated.');
  ELSIF SQL%FOUND THEN
    INSERT INTO salary_history (employee_id, old_salary, new_salary)
    VALUES (p_employee_id, v_emp.salary, p_new_salary);
    DBMS_OUTPUT.PUT_LINE('Rows updated: ' || v_rows);
    DBMS_OUTPUT.PUT_LINE('Salary changed from ' || v_emp.salary || ' to ' || p_new_salary);
  END IF;

  COMMIT;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Employee ID ' || p_employee_id || ' does not exist.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END update_employee_salary;
/