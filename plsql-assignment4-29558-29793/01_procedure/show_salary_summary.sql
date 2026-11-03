-- =====================================================
-- Procedure 6: show_salary_summary
-- File: 01_procedures/show_salary_summary.sql
-- Uses: ASSOCIATIVE ARRAY (indexed by VARCHAR2), FIRST, NEXT, COUNT,
--       cursor FOR loop, function call from a procedure
-- =====================================================
CREATE OR REPLACE PROCEDURE show_salary_summary (
  p_grand_total OUT NUMBER
)
IS
  -- associative array: key = department name, value = total salary
  TYPE t_dept_totals IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
  v_totals  t_dept_totals;
  v_name    VARCHAR2(50);
BEGIN
  p_grand_total := 0;

  -- fill the array
  FOR d IN (SELECT department_name FROM department ORDER BY department_name) LOOP
    v_totals(d.department_name) := get_department_total_salary(d.department_name);
  END LOOP;

  -- read the array
  DBMS_OUTPUT.PUT_LINE('=== Salary summary by department ===');
  v_name := v_totals.FIRST;
  WHILE v_name IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(v_name, 20) || v_totals(v_name));
    p_grand_total := p_grand_total + v_totals(v_name);
    v_name := v_totals.NEXT(v_name);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Departments: ' || v_totals.COUNT);
  DBMS_OUTPUT.PUT_LINE('Grand total: ' || p_grand_total);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Unexpected error in show_salary_summary: ' || SQLERRM);
    RAISE;
END show_salary_summary;
/
