-- =====================================================
-- Function 5: get_manager_team_size
-- File: 02_functions/get_manager_team_size.sql
-- Uses: cursor FOR loop
-- Counts ACTIVE employees that report to the manager
-- =====================================================
CREATE OR REPLACE FUNCTION get_manager_team_size (
  p_manager_id IN NUMBER
) RETURN NUMBER
IS
  v_manager_id  employee.employee_id%TYPE;
  v_count       NUMBER := 0;
BEGIN
  -- check the manager exists
  SELECT employee_id
  INTO   v_manager_id
  FROM   employee
  WHERE  employee_id = p_manager_id;

  -- cursor FOR loop: no OPEN / FETCH / CLOSE needed
  FOR r IN (SELECT employee_id
            FROM   employee
            WHERE  manager_id = p_manager_id
            AND    status = 'ACTIVE')
  LOOP
    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Employee ID ' || p_manager_id || ' does not exist.');
END get_manager_team_size;
/