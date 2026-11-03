\# Implementation Notes



\## 1. Design overview



Scenario: Employee Management. Functions do calculations and checks and return a value.

Procedures change data, print reports and use OUT parameters. All errors use

RAISE\_APPLICATION\_ERROR with codes between -20001 and -20021, and unexpected errors are

re-raised with RAISE so they are never hidden. Procedures that change data have a COMMIT

(the bulk ones have a p\_commit parameter so they can be tested and rolled back).



\## 2. Where each requirement is implemented



| Requirement | Where |

|---|---|

| %ROWTYPE record | get\_employee\_name, update\_employee\_salary, show\_team\_members |

| User-defined record | calculate\_bonus, department\_report |

| Nested table | show\_team\_members, bulk\_adjust\_salaries, bulk\_delete\_inactive\_employees |

| Associative array | show\_salary\_summary (indexed by department name), bulk\_adjust\_salaries (flags) |

| VARRAY | show\_top\_earners (maximum 5 elements) |

| Implicit cursor (SQL%ROWCOUNT, SQL%FOUND, SQL%NOTFOUND) | add\_employee, update\_employee\_salary, delete\_employee |

| Explicit cursor (OPEN/FETCH/CLOSE) | get\_department\_total\_salary, department\_report, show\_team\_members, show\_top\_earners |

| Cursor FOR loop | get\_manager\_team\_size, show\_salary\_summary |

| BULK COLLECT | bulk\_adjust\_salaries, bulk\_delete\_inactive\_employees |

| FORALL (UPDATE, INSERT, DELETE) | bulk\_adjust\_salaries, bulk\_delete\_inactive\_employees, compare\_bulk\_performance |

| Bulk DML errors (SAVE EXCEPTIONS, SQL%BULK\_EXCEPTIONS, ORA-24381) | bulk\_adjust\_salaries, bulk\_delete\_inactive\_employees |

| Predefined exceptions | NO\_DATA\_FOUND, TOO\_MANY\_ROWS (get\_employee\_id\_by\_dept\_job), DUP\_VAL\_ON\_INDEX (add\_employee) |

| User-defined exceptions | e\_inactive\_employee, e\_invalid\_salary, e\_no\_employees, e\_no\_team, e\_invalid\_limit and others |

| RAISE\_APPLICATION\_ERROR | all procedures and functions |

| Functions called from SQL and from a block | tests S1, S2, S3 |



\## 3. Error codes



| Code | Meaning |

|---|---|

| -20001 | Employee does not exist |

| -20002 | No employee found for department and job |

| -20003 | More than one employee found |

| -20004 | Employee is INACTIVE |

| -20005 | Department does not exist |

| -20006 | Job does not exist |

| -20007 | Salary is empty |

| -20008 | Salary outside the job range |

| -20009 | Duplicate email |

| -20010 | Department or manager does not exist |

| -20012 | New salary equals current salary |

| -20013 | Cannot delete: child records exist |

| -20014 | Department has no active employees |

| -20015 | Manager has no team |

| -20016 | Invalid limit for top earners |

| -20017 | Bulk amount is zero or empty |

| -20018 | No active employees to update |

| -20019 | No inactive employees to delete |

| -20020 | Invalid number of rows for the performance test |

| -20021 | Job or department for the performance test not found |



\## 4. Bulk processing and performance



Row-by-row processing (a normal FOR loop with an INSERT or UPDATE inside) makes the PL/SQL

engine send one SQL statement to the SQL engine for every row. Each trip is a context switch,

so 10,000 rows mean 10,000 switches.



BULK COLLECT fetches all the rows into a collection with one switch. FORALL sends the whole

collection to the SQL engine in one switch and the SQL engine runs the statement for every

element. Fewer switches means less overhead and faster execution.



SAVE EXCEPTIONS lets FORALL continue after a row fails. The failed rows are available in

SQL%BULK\_EXCEPTIONS (ERROR\_INDEX and ERROR\_CODE), and we save them in the error\_log table.

Without it, the first error would stop the statement.



Measured with compare\_bulk\_performance (test S13), inserting 10,000 rows:



| Method | Time (ms) |

|---|---|

| Row-by-row loop | <number from your screenshot> |

| FORALL | <number from your screenshot> |



Bulk was about <x> times faster on our computer. The exact times change from run to run, but

FORALL is consistently faster. The test rolls everything back.



Considerations: a collection is stored in memory, so for millions of rows BULK COLLECT should

be used with the LIMIT clause to process the rows in batches. In our small data set the

difference is small for real tables, but the performance test shows the principle.



\## 5. Transaction design



add\_employee, update\_employee\_salary and delete\_employee commit on success and roll back on

unexpected errors. The bulk procedures accept p\_commit ('Y' by default) so that the tests can

show the result and then ROLLBACK to keep the sample data unchanged.



\## 6. Limitations



\- The bonus function depends on the current date, so results change over time.

\- Passwords, security and user roles are not part of this assignment.

