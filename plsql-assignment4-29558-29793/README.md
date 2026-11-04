# EMPLOYEE MANAGEMENT SYSTEM – ORACLE PL/SQL

# GROUP ASSIGNMENT IV

## Assignment and Lecture Details

| **Detail** | **Information** |
|---|---|
| Assignment Title | Employee Management System – Oracle PL/SQL |
| Assignment Number | Group Assignment IV |
| Course | Database Development with PL/SQL (INSY 8311) |
| Instructor | Eric Maniraguha |
| Class Group | C |

---

## GROUP MEMBERS

| **Full Name** | **Student ID** |
|---|---:|
| NIYIMBONERA Mahoro Anselme | 29558 |
| MUTESI Liza Phiona | 29793 |

---

# 1. APPLICATION DESCRIPTION

The Employee Management System is a small Human Resources (HR) application developed using Oracle PL/SQL. It manages company departments, jobs, employees, their managers, and salary changes.

The PL/SQL code allows HR to add, update, and delete employees, generate department and team reports, calculate bonuses, adjust salaries, and remove inactive employees in bulk.

# 2. APPLICATION REQUIREMENTS

1. Maintain departments, jobs, and employees with correct relationships.
2. Ensure that each employee's salary stays within the salary range defined for their job.
3. Record every salary change in a salary history table.
4. Allow HR to add, update, and delete individual employees with clear error messages.
5. Generate department reports, manager team reports, salary summaries, and top-earner reports.
6. Support bulk salary increases or cuts for an entire department and bulk deletion of inactive employees. Failed rows are logged without stopping the processing of other rows.
7. Calculate bonuses for active employees according to the following rules:
   - 5 or more years of service = 10%
   - 3 or more years of service = 7%
   - 1 or more years of service = 5%
   - Less than 1 year of service = 2%

# 3. DATABASE TABLES

The application uses the following database tables:

| **Table** | **Columns** |
|---|---|
| **department** | department_id, department_name, location |
| **job** | job_id, job_title, min_salary, max_salary |
| **employee** | employee_id, first_name, last_name, email, hire_date, salary, status, job_id, department_id, manager_id |
| **salary_history** | history_id, employee_id, old_salary, new_salary, change_date |
| **error_log** | log_id, error_source, error_message, logged_at |

# 4. REPOSITORY STRUCTURE

The repository is organized into the following folders and files:

```text
Employee-Management-System/
│
├── 00_schema/
│   ├── 01_create_tables.sql
│   └── 02_insert_sample_data.sql
│
├── 01_procedures/
│   └── One file per procedure (10 procedures)
│
├── 02_functions/
│   └── One file per function (6 functions)
│
├── 03_tests/
│   ├── test_success_cases.sql
│   └── test_error_cases.sql
│
├── screenshots/
│   └── Output of every test
│
└── docs/
    └── IMPLEMENTATION_NOTES.md
```

# 5. HOW TO RUN THE PROJECT

**Requirements:** Oracle Database and SQL Developer.

Run each SQL script using **F5 (Run Script)** in SQL Developer.

Follow these steps in order:

1. Run `00_schema/01_create_tables.sql` to create the database tables.
2. Run `00_schema/02_insert_sample_data.sql` to insert sample data.
3. Compile every file in `02_functions/` first, since some procedures use these functions.
4. Compile every file in `01_procedures/`.
5. Run `03_tests/test_success_cases.sql` and `03_tests/test_error_cases.sql` block by block. Start by enabling output with:

   ```sql
   SET SERVEROUTPUT ON;
   ```

6. Compare the execution results with the corresponding screenshots in the `screenshots/` folder.

# 6. WHERE EACH CONCEPT IS USED

For the full table showing where each concept is implemented, refer to:

`docs/IMPLEMENTATION_NOTES.md`

# 7. AI ASSISTANT STATEMENT

We used an AI assistant to help us plan the project, generate and debug the initial versions of the SQL and PL/SQL code, and prepare the documentation templates. We then executed every script in Oracle, checked the results, and corrected compilation errors. Both group members have reviewed the code and can explain its implementation.
