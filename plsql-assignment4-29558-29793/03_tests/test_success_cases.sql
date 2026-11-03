-- =====================================================
-- test_success_cases.sql
-- Run the tests IN ORDER (S1 to S13), one block at a time.
-- =====================================================
SET SERVEROUTPUT ON

-- ===== PREPARE (run once at the start) =====
DELETE FROM salary_history WHERE employee_id IN
  (SELECT employee_id FROM employee
   WHERE email IN ('temp.employee@company.rw', 'test.user@company.rw'));
DELETE FROM employee WHERE email IN ('temp.employee@company.rw', 'test.user@company.rw');
COMMIT;

-- ===== TEST S1: functions called from a SELECT (screenshot: Query Result) =====
SELECT e.employee_id,
       get_employee_name(e.employee_id)     AS full_name,
       calculate_bonus(e.employee_id)       AS bonus,
       get_manager_team_size(e.employee_id) AS team_size,
       is_salary_valid(e.job_id, e.salary)  AS salary_ok
FROM   employee e
WHERE  e.employee_id IN (1000, 1005, 1007);

-- ===== TEST S2: department totals from a SELECT (screenshot: Query Result) =====
SELECT department_name, get_department_total_salary(department_name) AS total_salary
FROM   department
ORDER  BY department_name;

-- ===== TEST S3: functions called from an anonymous block =====
DECLARE
  v_job_id job.job_id%TYPE;
BEGIN
  SELECT job_id INTO v_job_id FROM job WHERE job_title = 'Developer';
  DBMS_OUTPUT.PUT_LINE('get_employee_name(1000)                 : ' || get_employee_name(1000));
  DBMS_OUTPUT.PUT_LINE('get_employee_id_by_dept_job(IT,Manager) : ' || get_employee_id_by_dept_job('IT', 'Manager'));
  DBMS_OUTPUT.PUT_LINE('calculate_bonus(1005)                   : ' || calculate_bonus(1005));
  DBMS_OUTPUT.PUT_LINE('get_department_total_salary(Finance)    : ' || get_department_total_salary('Finance'));
  DBMS_OUTPUT.PUT_LINE('get_manager_team_size(1004)             : ' || get_manager_team_size(1004));
  DBMS_OUTPUT.PUT_LINE('is_salary_valid(Developer, 2000)        : ' || is_salary_valid(v_job_id, 2000));
  DBMS_OUTPUT.PUT_LINE('is_salary_valid(Developer, 9000)        : ' || is_salary_valid(v_job_id, 9000));
END;
/

-- ===== TEST S4: add_employee (INSERT, implicit cursor) =====
DECLARE
  v_job_id   job.job_id%TYPE;
  v_dept_id  department.department_id%TYPE;
  v_new_id   NUMBER;
BEGIN
  SELECT job_id INTO v_job_id FROM job WHERE job_title = 'Developer';
  SELECT department_id INTO v_dept_id FROM department WHERE department_name = 'IT';
  add_employee('Temp', 'Employee', 'temp.employee@company.rw', 1500, v_job_id, v_dept_id, 1000, v_new_id);
  DBMS_OUTPUT.PUT_LINE('OUT parameter, new employee ID: ' || v_new_id);
END;
/

-- ===== TEST S5: update_employee_salary (UPDATE, implicit cursor) =====
DECLARE
  v_id   NUMBER;
  v_old  NUMBER;
BEGIN
  SELECT employee_id INTO v_id FROM employee WHERE email = 'temp.employee@company.rw';
  update_employee_salary(v_id, 1800, v_old);
  DBMS_OUTPUT.PUT_LINE('OUT parameter, old salary: ' || v_old);
END;
/

-- ===== TEST S6: delete_employee (DELETE, implicit cursor) =====
DECLARE
  v_id       NUMBER;
  v_deleted  NUMBER;
BEGIN
  SELECT employee_id INTO v_id FROM employee WHERE email = 'temp.employee@company.rw';
  DELETE FROM salary_history WHERE employee_id = v_id;   -- remove child rows first
  COMMIT;
  delete_employee(v_id, v_deleted);
  DBMS_OUTPUT.PUT_LINE('OUT parameter, rows deleted: ' || v_deleted);
END;
/

-- ===== TEST S7: department_report (explicit cursor + user-defined record) =====
DECLARE
  v_total  NUMBER;
  v_avg    NUMBER;
BEGIN
  department_report('IT', v_total, v_avg);
  DBMS_OUTPUT.PUT_LINE('OUT parameters -> employees: ' || v_total || ', average salary: ' || v_avg);
END;
/

-- ===== TEST S8: show_team_members (nested table of %ROWTYPE records) =====
DECLARE
  v_count NUMBER;
BEGIN
  show_team_members(1000, v_count);
  DBMS_OUTPUT.PUT_LINE('OUT parameter, team count: ' || v_count);
END;
/

-- ===== TEST S9: show_salary_summary (associative array) =====
DECLARE
  v_grand NUMBER;
BEGIN
  show_salary_summary(v_grand);
  DBMS_OUTPUT.PUT_LINE('OUT parameter, grand total: ' || v_grand);
END;
/

-- ===== TEST S10: show_top_earners (VARRAY) =====
BEGIN
  show_top_earners(3);
END;
/

-- ===== TEST S11: bulk_adjust_salaries (BULK COLLECT + FORALL) =====
DECLARE
  v_updated      NUMBER;
  v_failed       NUMBER;
  v_hist_before  NUMBER;
  v_hist_after   NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_hist_before FROM salary_history;
  DBMS_OUTPUT.PUT_LINE('IT total salary BEFORE: ' || get_department_total_salary('IT'));
  bulk_adjust_salaries('IT', 100, v_updated, v_failed, 'N');
  SELECT COUNT(*) INTO v_hist_after FROM salary_history;
  DBMS_OUTPUT.PUT_LINE('IT total salary AFTER : ' || get_department_total_salary('IT'));
  DBMS_OUTPUT.PUT_LINE('salary_history rows   : ' || v_hist_before || ' -> ' || v_hist_after);
  DBMS_OUTPUT.PUT_LINE('OUT parameters -> updated: ' || v_updated || ', failed: ' || v_failed);
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('IT total salary after ROLLBACK: ' || get_department_total_salary('IT'));
END;
/

-- ===== TEST S12: bulk_delete_inactive_employees (FORALL DELETE) =====
DECLARE
  v_deleted  NUMBER;
  v_failed   NUMBER;
  v_before   NUMBER;
  v_after    NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_before FROM employee;
  bulk_delete_inactive_employees(v_deleted, v_failed, 'N');
  SELECT COUNT(*) INTO v_after FROM employee;
  DBMS_OUTPUT.PUT_LINE('Employees: ' || v_before || ' -> ' || v_after);
  DBMS_OUTPUT.PUT_LINE('OUT parameters -> deleted: ' || v_deleted || ', failed: ' || v_failed);
  ROLLBACK;
  SELECT COUNT(*) INTO v_after FROM employee;
  DBMS_OUTPUT.PUT_LINE('Employees after ROLLBACK: ' || v_after);
END;
/

-- ===== TEST S13: compare_bulk_performance (row-by-row vs FORALL) =====
BEGIN
  compare_bulk_performance(10000);
END;
/

-- ===== FINAL CHECK: data must be back to normal (screenshot: Query Result) =====
SELECT (SELECT COUNT(*) FROM department)     AS departments,
       (SELECT COUNT(*) FROM job)            AS jobs,
       (SELECT COUNT(*) FROM employee)       AS employees,
       (SELECT COUNT(*) FROM salary_history) AS salary_history
FROM   dual;