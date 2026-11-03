-- =====================================================
-- 02_insert_sample_data.sql
-- Employee Management System - sample data
-- =====================================================

-- Clean old data (safe to re-run)
DELETE FROM error_log;
DELETE FROM salary_history;
DELETE FROM employee;
DELETE FROM job;
DELETE FROM department;
COMMIT;

-- 1. DEPARTMENTS
INSERT INTO department (department_name, location) VALUES ('IT', 'Kigali');
INSERT INTO department (department_name, location) VALUES ('Human Resources', 'Kigali');
INSERT INTO department (department_name, location) VALUES ('Finance', 'Kigali');
INSERT INTO department (department_name, location) VALUES ('Sales', 'Huye');
INSERT INTO department (department_name, location) VALUES ('Operations', 'Musanze');

-- 2. JOBS
INSERT INTO job (job_title, min_salary, max_salary) VALUES ('Manager', 3000, 6000);
INSERT INTO job (job_title, min_salary, max_salary) VALUES ('Developer', 1500, 3500);
INSERT INTO job (job_title, min_salary, max_salary) VALUES ('HR Officer', 1000, 2500);
INSERT INTO job (job_title, min_salary, max_salary) VALUES ('Accountant', 1200, 3000);
INSERT INTO job (job_title, min_salary, max_salary) VALUES ('Sales Representative', 800, 2000);
INSERT INTO job (job_title, min_salary, max_salary) VALUES ('Clerk', 500, 1200);

-- 3. EMPLOYEES - managers first (no manager_id)
INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Alice', 'Uwase', 'alice.uwase@company.rw', DATE '2018-01-15', 5000,
        (SELECT job_id FROM job WHERE job_title = 'Manager'),
        (SELECT department_id FROM department WHERE department_name = 'IT'), NULL);

INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Eric', 'Mugisha', 'eric.mugisha@company.rw', DATE '2018-03-01', 4500,
        (SELECT job_id FROM job WHERE job_title = 'Manager'),
        (SELECT department_id FROM department WHERE department_name = 'Human Resources'), NULL);

INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Grace', 'Ingabire', 'grace.ingabire@company.rw', DATE '2017-06-10', 5200,
        (SELECT job_id FROM job WHERE job_title = 'Manager'),
        (SELECT department_id FROM department WHERE department_name = 'Finance'), NULL);

INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('David', 'Niyonzima', 'david.niyonzima@company.rw', DATE '2019-02-20', 4800,
        (SELECT job_id FROM job WHERE job_title = 'Manager'),
        (SELECT department_id FROM department WHERE department_name = 'Sales'), NULL);

INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Sarah', 'Mukamana', 'sarah.mukamana@company.rw', DATE '2019-05-05', 4600,
        (SELECT job_id FROM job WHERE job_title = 'Manager'),
        (SELECT department_id FROM department WHERE department_name = 'Operations'), NULL);

-- 4. EMPLOYEES - IT staff (manager: Alice)
INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('John', 'Habimana', 'john.habimana@company.rw', DATE '2020-03-01', 2800,
        (SELECT job_id FROM job WHERE job_title = 'Developer'),
        (SELECT department_id FROM department WHERE department_name = 'IT'),
        (SELECT employee_id FROM employee WHERE email = 'alice.uwase@company.rw'));

INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Diane', 'Uwimana', 'diane.uwimana@company.rw', DATE '2021-07-12', 2500,
        (SELECT job_id FROM job WHERE job_title = 'Developer'),
        (SELECT department_id FROM department WHERE department_name = 'IT'),
        (SELECT employee_id FROM employee WHERE email = 'alice.uwase@company.rw'));

INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Patrick', 'Nshimiyimana', 'patrick.nshimiyimana@company.rw', DATE '2022-09-01', 2000,
        (SELECT job_id FROM job WHERE job_title = 'Developer'),
        (SELECT department_id FROM department WHERE department_name = 'IT'),
        (SELECT employee_id FROM employee WHERE email = 'alice.uwase@company.rw'));

-- 5. EMPLOYEES - HR staff (manager: Eric)
INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Claire', 'Mukeshimana', 'claire.mukeshimana@company.rw', DATE '2020-11-15', 1800,
        (SELECT job_id FROM job WHERE job_title = 'HR Officer'),
        (SELECT department_id FROM department WHERE department_name = 'Human Resources'),
        (SELECT employee_id FROM employee WHERE email = 'eric.mugisha@company.rw'));

INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Jean', 'Kamanzi', 'jean.kamanzi@company.rw', DATE '2022-01-10', 1500,
        (SELECT job_id FROM job WHERE job_title = 'HR Officer'),
        (SELECT department_id FROM department WHERE department_name = 'Human Resources'),
        (SELECT employee_id FROM employee WHERE email = 'eric.mugisha@company.rw'));

-- 6. EMPLOYEES - Finance staff (manager: Grace)
INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Olivier', 'Hakizimana', 'olivier.hakizimana@company.rw', DATE '2019-08-19', 2400,
        (SELECT job_id FROM job WHERE job_title = 'Accountant'),
        (SELECT department_id FROM department WHERE department_name = 'Finance'),
        (SELECT employee_id FROM employee WHERE email = 'grace.ingabire@company.rw'));

INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Beatrice', 'Umutoni', 'beatrice.umutoni@company.rw', DATE '2021-04-26', 2100,
        (SELECT job_id FROM job WHERE job_title = 'Accountant'),
        (SELECT department_id FROM department WHERE department_name = 'Finance'),
        (SELECT employee_id FROM employee WHERE email = 'grace.ingabire@company.rw'));

-- 7. EMPLOYEES - Sales staff (manager: David)
INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Samuel', 'Ndayisaba', 'samuel.ndayisaba@company.rw', DATE '2020-06-01', 1400,
        (SELECT job_id FROM job WHERE job_title = 'Sales Representative'),
        (SELECT department_id FROM department WHERE department_name = 'Sales'),
        (SELECT employee_id FROM employee WHERE email = 'david.niyonzima@company.rw'));

INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Esther', 'Uwera', 'esther.uwera@company.rw', DATE '2021-10-04', 1200,
        (SELECT job_id FROM job WHERE job_title = 'Sales Representative'),
        (SELECT department_id FROM department WHERE department_name = 'Sales'),
        (SELECT employee_id FROM employee WHERE email = 'david.niyonzima@company.rw'));

INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Moses', 'Bizimana', 'moses.bizimana@company.rw', DATE '2023-02-13', 1000,
        (SELECT job_id FROM job WHERE job_title = 'Sales Representative'),
        (SELECT department_id FROM department WHERE department_name = 'Sales'),
        (SELECT employee_id FROM employee WHERE email = 'david.niyonzima@company.rw'));

-- 8. EMPLOYEES - Operations staff (manager: Sarah)
INSERT INTO employee (first_name, last_name, email, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Peter', 'Habiyaremye', 'peter.habiyaremye@company.rw', DATE '2022-05-23', 800,
        (SELECT job_id FROM job WHERE job_title = 'Clerk'),
        (SELECT department_id FROM department WHERE department_name = 'Operations'),
        (SELECT employee_id FROM employee WHERE email = 'sarah.mukamana@company.rw'));

INSERT INTO employee (first_name, last_name, email, hire_date, salary, status, job_id, department_id, manager_id)
VALUES ('Linda', 'Kayitesi', 'linda.kayitesi@company.rw', DATE '2021-12-01', 700, 'INACTIVE',
        (SELECT job_id FROM job WHERE job_title = 'Clerk'),
        (SELECT department_id FROM department WHERE department_name = 'Operations'),
        (SELECT employee_id FROM employee WHERE email = 'sarah.mukamana@company.rw'));

-- 9. SALARY HISTORY (a few past raises)
INSERT INTO salary_history (employee_id, old_salary, new_salary, change_date)
VALUES ((SELECT employee_id FROM employee WHERE email = 'john.habimana@company.rw'), 2500, 2800, DATE '2023-01-01');

INSERT INTO salary_history (employee_id, old_salary, new_salary, change_date)
VALUES ((SELECT employee_id FROM employee WHERE email = 'olivier.hakizimana@company.rw'), 2200, 2400, DATE '2023-01-01');

INSERT INTO salary_history (employee_id, old_salary, new_salary, change_date)
VALUES ((SELECT employee_id FROM employee WHERE email = 'samuel.ndayisaba@company.rw'), 1300, 1400, DATE '2023-06-01');

COMMIT;

-- Check 1: row counts
SELECT 'DEPARTMENT' AS table_name, COUNT(*) AS total_rows FROM department
UNION ALL SELECT 'JOB', COUNT(*) FROM job
UNION ALL SELECT 'EMPLOYEE', COUNT(*) FROM employee
UNION ALL SELECT 'SALARY_HISTORY', COUNT(*) FROM salary_history;

-- Check 2: employees with department, job and manager
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS employee_name,
       d.department_name,
       j.job_title,
       e.salary,
       e.status,
       m.first_name || ' ' || m.last_name AS manager_name
FROM employee e
JOIN department d ON e.department_id = d.department_id
JOIN job j ON e.job_id = j.job_id
LEFT JOIN employee m ON e.manager_id = m.employee_id
ORDER BY e.employee_id;