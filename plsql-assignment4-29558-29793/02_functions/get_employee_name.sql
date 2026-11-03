-- =====================================================
-- Function 1: get_employee_name
-- File: 02_functions/get_employee_name.sql
-- Uses: %ROWTYPE record, NO_DATA_FOUND, RAISE_APPLICATION_ERROR
-- =====================================================
CREATE OR REPLACE FUNCTION get_employee_name (
  p_employee_id IN NUMBER
) RETURN VARCHAR2
IS
  v_emp employee%ROWTYPE;   -- record with the same columns as the employee table
BEGIN
  SELECT *
  INTO   v_emp
  FROM   employee
  WHERE  employee_id = p_employee_id;

  RETURN v_emp.first_name || ' ' || v_emp.last_name;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Employee ID ' || p_employee_id || ' does not exist.');
END get_employee_name;
/