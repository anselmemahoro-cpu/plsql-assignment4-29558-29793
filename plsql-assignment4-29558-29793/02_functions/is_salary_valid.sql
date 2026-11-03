-- =====================================================
-- Function 6: is_salary_valid
-- File: 02_functions/is_salary_valid.sql
-- Returns 'Y' if the salary is inside the job min/max range, else 'N'
-- =====================================================
CREATE OR REPLACE FUNCTION is_salary_valid (
  p_job_id  IN NUMBER,
  p_salary  IN NUMBER
) RETURN VARCHAR2
IS
  v_min_salary  job.min_salary%TYPE;
  v_max_salary  job.max_salary%TYPE;
BEGIN
  IF p_salary IS NULL THEN
    RAISE_APPLICATION_ERROR(-20007, 'Salary cannot be empty.');
  END IF;

  SELECT min_salary, max_salary
  INTO   v_min_salary, v_max_salary
  FROM   job
  WHERE  job_id = p_job_id;

  IF p_salary BETWEEN v_min_salary AND v_max_salary THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20006, 'Job ID ' || p_job_id || ' does not exist.');
END is_salary_valid;
/

-- Check: all 6 functions must be VALID
SELECT object_name, object_type, status
FROM   user_objects
WHERE  object_type = 'FUNCTION'
AND    object_name IN ('GET_EMPLOYEE_NAME','GET_EMPLOYEE_ID_BY_DEPT_JOB','CALCULATE_BONUS',
                       'GET_DEPARTMENT_TOTAL_SALARY','GET_MANAGER_TEAM_SIZE','IS_SALARY_VALID')
ORDER  BY object_name;