\# Employee Management System - Oracle PL/SQL



Group Assignment IV: Records, Collections, Cursors, Bulk Processing, Stored Procedures, Functions and Exception Handling

Course: Database Development with PL/SQL (INSY 8311)

Instructor: Eric Maniraguha | Class group:C 



\## Group members



| Full name | Student ID |

|---|---|

| NIYIMBONERA Mahoro Anselme |29558|

| MUTESI Liza Phiona       |29793|



\## Application description



A small Human Resources system for a company. It stores departments, jobs, employees

(with their manager) and salary changes. The PL/SQL code lets HR add, update and delete

employees, report on a department or a team, calculate bonuses, and adjust salaries or

remove inactive employees for many people at once.



\## Requirements of the application



1\. Keep departments, jobs and employees with correct relationships.

2\. Each job has a salary range; an employee salary must stay inside it.

3\. Every salary change is saved in a history table.

4\. HR can add, update and delete one employee with clear error messages.

5\. HR can see a department report, a manager's team, a salary summary and the top earners.

6\. HR can raise or cut salaries for a whole department, and delete all inactive employees,

&#x20;  in bulk. Rows that fail are logged and do not stop the other rows.

7\. Bonus rule: 5+ years = 10%, 3+ years = 7%, 1+ year = 5%, less = 2% (active employees only).



\## Database tables



\- department (department\_id, department\_name, location)

\- job (job\_id, job\_title, min\_salary, max\_salary)

\- employee (employee\_id, first\_name, last\_name, email, hire\_date, salary, status, job\_id, department\_id, manager\_id)

\- salary\_history (history\_id, employee\_id, old\_salary, new\_salary, change\_date)

\- error\_log (log\_id, error\_source, error\_message, logged\_at)



\## Repository structure



\- 00\_schema: 01\_create\_tables.sql, 02\_insert\_sample\_data.sql

\- 01\_procedures: one file per procedure (10 procedures)

\- 02\_functions: one file per function (6 functions)

\- 03\_tests: test\_success\_cases.sql, test\_error\_cases.sql

\- screenshots: output of every test

\- docs: IMPLEMENTATION\_NOTES.md



\## How to run (Oracle Database, SQL Developer, run each file with F5)



1\. Run 00\_schema/01\_create\_tables.sql

2\. Run 00\_schema/02\_insert\_sample\_data.sql

3\. Compile every file in 02\_functions/ first (the procedures use some of them)

4\. Compile every file in 01\_procedures/

5\. Run 03\_tests/test\_success\_cases.sql and 03\_tests/test\_error\_cases.sql block by block (start with SET SERVEROUTPUT ON)

6\. Compare the results with the screenshots folder



\## Where each concept is used



See docs/IMPLEMENTATION\_NOTES.md for the full table.



\## AI assistant statement



We used an AI assistant to help us plan the project, generate and

debug the first versions of the SQL and PL/SQL code, and write the documentation templates.

We then ran every script in Oracle, checked the results, and fixed compile errors. Both of us

have read the code and can explain it. <Edit this paragraph so it describes exactly how you used it.>

