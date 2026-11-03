-- =====================================================
-- Function 4: get_department_total_salary
-- File: 02_functions/get_department_total_salary.sql
-- Uses: explicit cursor (OPEN / FETCH / CLOSE) with a parameter
-- Counts only ACTIVE employees
-- =====================================================
CREATE OR REPLACE FUNCTION get_department_total_salary (
  p_department_name IN VARCHAR2
) RETURN NUMBER
IS
  v_department_id  department.department_id%TYPE;
  v_salary         employee.salary%TYPE;
  v_total          NUMBER := 0;

  -- explicit cursor with a parameter
  CURSOR c_salaries (p_dept_id NUMBER) IS
    SELECT salary
    FROM   employee
    WHERE  department_id = p_dept_id
    AND    status = 'ACTIVE';
BEGIN
  -- find the department (NO_DATA_FOUND if it does not exist)
  SELECT department_id
  INTO   v_department_id
  FROM   department
  WHERE  department_name = p_department_name;

  OPEN c_salaries(v_department_id);
  LOOP
    FETCH c_salaries INTO v_salary;
    EXIT WHEN c_salaries%NOTFOUND;
    v_total := v_total + v_salary;
  END LOOP;
  CLOSE c_salaries;

  RETURN v_total;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20005, 'Department ' || p_department_name || ' does not exist.');
  WHEN OTHERS THEN
    IF c_salaries%ISOPEN THEN
      CLOSE c_salaries;
    END IF;
    RAISE;   -- do not hide unexpected errors
END get_department_total_salary;
/