-- =====================================================
-- Function 2: get_employee_id_by_dept_job
-- File: 02_functions/get_employee_id_by_dept_job.sql
-- Uses: NO_DATA_FOUND, TOO_MANY_ROWS
-- =====================================================
CREATE OR REPLACE FUNCTION get_employee_id_by_dept_job (
  p_department_name IN VARCHAR2,
  p_job_title       IN VARCHAR2
) RETURN NUMBER
IS
  v_employee_id employee.employee_id%TYPE;
BEGIN
  SELECT e.employee_id
  INTO   v_employee_id
  FROM   employee e
         JOIN department d ON e.department_id = d.department_id
         JOIN job j        ON e.job_id = j.job_id
  WHERE  d.department_name = p_department_name
  AND    j.job_title = p_job_title;

  RETURN v_employee_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20002, 'No employee found in ' || p_department_name || ' with job ' || p_job_title || '.');
  WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20003, 'More than one employee found in ' || p_department_name || ' with job ' || p_job_title || '.');
END get_employee_id_by_dept_job;
/