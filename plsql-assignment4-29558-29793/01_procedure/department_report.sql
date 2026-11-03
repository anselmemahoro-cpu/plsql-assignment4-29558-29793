-- =====================================================
-- Procedure 4: department_report
-- File: 01_procedures/department_report.sql
-- Uses: explicit cursor with parameter, OPEN/FETCH/CLOSE,
--       user-defined RECORD, OUT parameters, user-defined exception
-- =====================================================
CREATE OR REPLACE PROCEDURE department_report (
  p_department_name  IN  VARCHAR2,
  p_total_employees  OUT NUMBER,
  p_average_salary   OUT NUMBER
)
IS
  v_department_id  department.department_id%TYPE;
  v_total_salary   NUMBER := 0;

  -- user-defined record type
  TYPE t_emp_rec IS RECORD (
    employee_id  employee.employee_id%TYPE,
    full_name    VARCHAR2(101),
    job_title    job.job_title%TYPE,
    salary       employee.salary%TYPE
  );
  v_emp t_emp_rec;

  -- explicit cursor with a parameter
  CURSOR c_dept_employees (p_dept_id NUMBER) IS
    SELECT e.employee_id,
           e.first_name || ' ' || e.last_name,
           j.job_title,
           e.salary
    FROM   employee e
           JOIN job j ON e.job_id = j.job_id
    WHERE  e.department_id = p_dept_id
    AND    e.status = 'ACTIVE'
    ORDER  BY e.salary DESC;

  e_no_employees EXCEPTION;   -- user-defined exception
BEGIN
  SELECT department_id
  INTO   v_department_id
  FROM   department
  WHERE  department_name = p_department_name;

  p_total_employees := 0;
  DBMS_OUTPUT.PUT_LINE('=== Department report: ' || p_department_name || ' ===');

  OPEN c_dept_employees(v_department_id);
  LOOP
    FETCH c_dept_employees INTO v_emp;
    EXIT WHEN c_dept_employees%NOTFOUND;

    p_total_employees := p_total_employees + 1;
    v_total_salary    := v_total_salary + v_emp.salary;

    DBMS_OUTPUT.PUT_LINE(v_emp.employee_id || ' | ' ||
                         RPAD(v_emp.full_name, 22) || ' | ' ||
                         RPAD(v_emp.job_title, 20) || ' | ' ||
                         v_emp.salary);
  END LOOP;
  CLOSE c_dept_employees;

  IF p_total_employees = 0 THEN
    RAISE e_no_employees;
  END IF;

  p_average_salary := ROUND(v_total_salary / p_total_employees, 2);

  DBMS_OUTPUT.PUT_LINE('Active employees: ' || p_total_employees);
  DBMS_OUTPUT.PUT_LINE('Average salary: ' || p_average_salary);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20005, 'Department ' || p_department_name || ' does not exist.');
  WHEN e_no_employees THEN
    RAISE_APPLICATION_ERROR(-20014, 'Department ' || p_department_name || ' has no active employees.');
  WHEN OTHERS THEN
    IF c_dept_employees%ISOPEN THEN
      CLOSE c_dept_employees;
    END IF;
    RAISE;
END department_report;
/
