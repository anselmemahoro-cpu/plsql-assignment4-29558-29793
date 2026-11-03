-- =====================================================
-- test_error_cases.sql
-- Every block catches the error and prints it.
-- Run one block at a time (select it, press F5).
-- =====================================================
SET SERVEROUTPUT ON

-- ===== TEST E1: function errors, part 1 =====
BEGIN
  BEGIN
    DBMS_OUTPUT.PUT_LINE(get_employee_name(9999));
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND (employee)      -> ' || SQLERRM);
  END;
  BEGIN
    DBMS_OUTPUT.PUT_LINE(get_employee_id_by_dept_job('IT', 'Developer'));
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('TOO_MANY_ROWS                  -> ' || SQLERRM);
  END;
  BEGIN
    DBMS_OUTPUT.PUT_LINE(get_employee_id_by_dept_job('IT', 'Clerk'));
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND (dept + job)     -> ' || SQLERRM);
  END;
  BEGIN
    DBMS_OUTPUT.PUT_LINE(calculate_bonus(1016));
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('User-defined (inactive)        -> ' || SQLERRM);
  END;
  BEGIN
    DBMS_OUTPUT.PUT_LINE(calculate_bonus(9999));
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND (bonus)          -> ' || SQLERRM);
  END;
END;
/

-- ===== TEST E2: function errors, part 2 =====
DECLARE
  v_job_id job.job_id%TYPE;
BEGIN
  SELECT job_id INTO v_job_id FROM job WHERE job_title = 'Developer';
  BEGIN
    DBMS_OUTPUT.PUT_LINE(get_department_total_salary('Marketing'));
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Unknown department            -> ' || SQLERRM);
  END;
  BEGIN
    DBMS_OUTPUT.PUT_LINE(get_manager_team_size(9999));
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Unknown manager               -> ' || SQLERRM);
  END;
  BEGIN
    DBMS_OUTPUT.PUT_LINE(is_salary_valid(9999, 1000));
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Unknown job                   -> ' || SQLERRM);
  END;
  BEGIN
    DBMS_OUTPUT.PUT_LINE(is_salary_valid(v_job_id, NULL));
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Empty salary                  -> ' || SQLERRM);
  END;
END;
/

-- ===== TEST E3: add_employee errors =====
DECLARE
  v_job_id   job.job_id%TYPE;
  v_dept_id  department.department_id%TYPE;
  v_new_id   NUMBER;
BEGIN
  SELECT job_id INTO v_job_id FROM job WHERE job_title = 'Developer';
  SELECT department_id INTO v_dept_id FROM department WHERE department_name = 'IT';
  BEGIN
    add_employee('Temp', 'Rich', 'temp.rich@company.rw', 9000, v_job_id, v_dept_id, 1000, v_new_id);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Salary out of range           -> ' || SQLERRM);
  END;
  BEGIN
    add_employee('Alice', 'Copy', 'alice.uwase@company.rw', 1500, v_job_id, v_dept_id, 1000, v_new_id);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('DUP_VAL_ON_INDEX (email)       -> ' || SQLERRM);
  END;
  BEGIN
    add_employee('Temp', 'NoDept', 'temp.nodept@company.rw', 1500, v_job_id, 9999, 1000, v_new_id);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Department does not exist      -> ' || SQLERRM);
  END;
END;
/

-- ===== TEST E4: update_employee_salary errors =====
DECLARE
  v_old NUMBER;
BEGIN
  BEGIN
    update_employee_salary(9999, 1800, v_old);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND (employee)       -> ' || SQLERRM);
  END;
  BEGIN
    update_employee_salary(1016, 800, v_old);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Inactive employee             -> ' || SQLERRM);
  END;
  BEGIN
    update_employee_salary(1005, 9000, v_old);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Salary out of range           -> ' || SQLERRM);
  END;
  BEGIN
    update_employee_salary(1005, 2800, v_old);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Same salary                   -> ' || SQLERRM);
  END;
END;
/

-- ===== TEST E5: delete_employee errors =====
DECLARE
  v_deleted NUMBER;
BEGIN
  BEGIN
    delete_employee(9999, v_deleted);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('SQL%NOTFOUND (no such employee) -> ' || SQLERRM);
  END;
  BEGIN
    delete_employee(1005, v_deleted);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Child record found (ORA-02292)  -> ' || SQLERRM);
  END;
END;
/

-- ===== TEST E6: department_report errors =====
DECLARE
  v_total  NUMBER;
  v_avg    NUMBER;
BEGIN
  BEGIN
    department_report('Marketing', v_total, v_avg);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Unknown department            -> ' || SQLERRM);
  END;

  INSERT INTO department (department_name, location) VALUES ('Legal', 'Kigali');
  COMMIT;
  BEGIN
    department_report('Legal', v_total, v_avg);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Department with no employees  -> ' || SQLERRM);
  END;
  DELETE FROM department WHERE department_name = 'Legal';
  COMMIT;
END;
/

-- ===== TEST E7: show_team_members and show_top_earners errors =====
DECLARE
  v_count NUMBER;
BEGIN
  BEGIN
    show_team_members(9999, v_count);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Unknown manager               -> ' || SQLERRM);
  END;
  BEGIN
    show_team_members(1005, v_count);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Manager with no team          -> ' || SQLERRM);
  END;
  BEGIN
    show_top_earners(8);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Limit too big (VARRAY max 5)  -> ' || SQLERRM);
  END;
  BEGIN
    show_top_earners(0);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Limit too small               -> ' || SQLERRM);
  END;
END;
/

-- ===== TEST E8: bulk_adjust_salaries errors (bulk DML errors with SAVE EXCEPTIONS) =====
DECLARE
  v_updated  NUMBER;
  v_failed   NUMBER;
BEGIN
  DELETE FROM error_log;
  COMMIT;

  -- a cut of 1000: two employees would get a salary of 0 or less, so they fail
  bulk_adjust_salaries(NULL, -1000, v_updated, v_failed, 'N');
  DBMS_OUTPUT.PUT_LINE('OUT parameters -> updated: ' || v_updated || ', failed: ' || v_failed);
  FOR r IN (SELECT error_message FROM error_log ORDER BY log_id) LOOP
    DBMS_OUTPUT.PUT_LINE('error_log: ' || r.error_message);
  END LOOP;
  ROLLBACK;

  BEGIN
    bulk_adjust_salaries('Marketing', 100, v_updated, v_failed, 'N');
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Unknown department            -> ' || SQLERRM);
  END;
  BEGIN
    bulk_adjust_salaries('IT', 0, v_updated, v_failed, 'N');
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Amount is zero                 -> ' || SQLERRM);
  END;
END;
/

-- ===== TEST E9: bulk_delete_inactive_employees errors =====
DECLARE
  v_deleted  NUMBER;
  v_failed   NUMBER;
BEGIN
  DELETE FROM error_log;
  COMMIT;

  -- Samuel becomes INACTIVE but has salary history, so his delete fails; Linda is deleted
  UPDATE employee SET status = 'INACTIVE' WHERE email = 'samuel.ndayisaba@company.rw';
  bulk_delete_inactive_employees(v_deleted, v_failed, 'N');
  DBMS_OUTPUT.PUT_LINE('OUT parameters -> deleted: ' || v_deleted || ', failed: ' || v_failed);
  FOR r IN (SELECT error_message FROM error_log ORDER BY log_id) LOOP
    DBMS_OUTPUT.PUT_LINE('error_log: ' || r.error_message);
  END LOOP;
  ROLLBACK;

  -- nothing to delete
  UPDATE employee SET status = 'ACTIVE' WHERE status = 'INACTIVE';
  BEGIN
    bulk_delete_inactive_employees(v_deleted, v_failed, 'N');
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('No inactive employees         -> ' || SQLERRM);
  END;
  ROLLBACK;
END;
/

-- ===== TEST E10: compare_bulk_performance errors =====
BEGIN
  BEGIN
    compare_bulk_performance(0);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rows = 0                      -> ' || SQLERRM);
  END;
  BEGIN
    compare_bulk_performance(500000);
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rows too many                 -> ' || SQLERRM);
  END;
END;
/

-- ===== FINAL CHECK: data must be back to normal (screenshot: Query Result) =====
SELECT (SELECT COUNT(*) FROM department)     AS departments,
       (SELECT COUNT(*) FROM job)            AS jobs,
       (SELECT COUNT(*) FROM employee)       AS employees,
       (SELECT COUNT(*) FROM salary_history) AS salary_history
FROM   dual;