-- =====================================================
-- Procedure 10: compare_bulk_performance
-- File: 01_procedures/compare_bulk_performance.sql
-- Compares row-by-row INSERT (loop) with FORALL INSERT.
-- Everything is rolled back, so no data is kept.
-- =====================================================
CREATE OR REPLACE PROCEDURE compare_bulk_performance (
  p_rows IN NUMBER DEFAULT 10000
)
IS
  TYPE t_email_tab IS TABLE OF VARCHAR2(100);
  v_emails     t_email_tab := t_email_tab();
  v_job_id     job.job_id%TYPE;
  v_dept_id    department.department_id%TYPE;
  v_start      NUMBER;
  v_row_ms     NUMBER;
  v_bulk_ms    NUMBER;

  e_invalid_rows EXCEPTION;
BEGIN
  IF p_rows IS NULL OR p_rows < 1 OR p_rows > 100000 THEN
    RAISE e_invalid_rows;
  END IF;

  SELECT job_id        INTO v_job_id  FROM job        WHERE job_title = 'Clerk';
  SELECT department_id INTO v_dept_id FROM department WHERE department_name = 'Operations';

  -- A. Row-by-row: one INSERT sent to the SQL engine for each row
  v_start := DBMS_UTILITY.GET_TIME;
  FOR i IN 1 .. p_rows LOOP
    INSERT INTO employee (first_name, last_name, email, salary, job_id, department_id)
    VALUES ('Perf', 'Test', 'perf.row' || i || '@test.rw', 600, v_job_id, v_dept_id);
  END LOOP;
  v_row_ms := (DBMS_UTILITY.GET_TIME - v_start) * 10;
  ROLLBACK;

  -- B. Bulk: fill a collection, then send all rows with ONE FORALL
  v_start := DBMS_UTILITY.GET_TIME;
  FOR i IN 1 .. p_rows LOOP
    v_emails.EXTEND;
    v_emails(i) := 'perf.bulk' || i || '@test.rw';
  END LOOP;

  FORALL i IN 1 .. v_emails.COUNT
    INSERT INTO employee (first_name, last_name, email, salary, job_id, department_id)
    VALUES ('Perf', 'Test', v_emails(i), 600, v_job_id, v_dept_id);
  v_bulk_ms := (DBMS_UTILITY.GET_TIME - v_start) * 10;
  ROLLBACK;

  DBMS_OUTPUT.PUT_LINE('=== Performance test: ' || p_rows || ' rows ===');
  DBMS_OUTPUT.PUT_LINE('Row-by-row loop : ' || v_row_ms  || ' ms');
  DBMS_OUTPUT.PUT_LINE('FORALL (bulk)   : ' || v_bulk_ms || ' ms');
  IF v_bulk_ms > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Bulk was about ' || ROUND(v_row_ms / v_bulk_ms, 1) || ' times faster.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Bulk was too fast to measure (under 10 ms).');
  END IF;
  DBMS_OUTPUT.PUT_LINE('All test rows were rolled back.');

EXCEPTION
  WHEN e_invalid_rows THEN
    RAISE_APPLICATION_ERROR(-20020, 'Number of rows must be between 1 and 100000.');
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20021, 'Job Clerk or department Operations not found.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END compare_bulk_performance;
/

-- Check: all 10 procedures must be VALID
SELECT object_name, object_type, status
FROM   user_objects
WHERE  object_type = 'PROCEDURE'
AND    object_name IN ('ADD_EMPLOYEE','UPDATE_EMPLOYEE_SALARY','DELETE_EMPLOYEE',
                       'DEPARTMENT_REPORT','SHOW_TEAM_MEMBERS','SHOW_SALARY_SUMMARY','SHOW_TOP_EARNERS',
                       'BULK_ADJUST_SALARIES','BULK_DELETE_INACTIVE_EMPLOYEES','COMPARE_BULK_PERFORMANCE')
ORDER  BY object_name;