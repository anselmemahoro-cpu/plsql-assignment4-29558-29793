-- =====================================================
-- Procedure 7: show_top_earners
-- File: 01_procedures/show_top_earners.sql
-- Uses: VARRAY (maximum 5 elements), EXTEND, explicit cursor,
--       user-defined exception
-- =====================================================
CREATE OR REPLACE PROCEDURE show_top_earners (
  p_limit IN NUMBER
)
IS
  -- VARRAY with a fixed maximum size of 5
  TYPE t_top_list IS VARRAY(5) OF VARCHAR2(120);
  v_top   t_top_list := t_top_list();
  v_line  VARCHAR2(120);

  CURSOR c_top IS
    SELECT first_name || ' ' || last_name || ' - ' || salary
    FROM   employee
    WHERE  status = 'ACTIVE'
    ORDER  BY salary DESC;

  e_invalid_limit EXCEPTION;
BEGIN
  IF p_limit IS NULL OR p_limit < 1 OR p_limit > 5 THEN
    RAISE e_invalid_limit;
  END IF;

  OPEN c_top;
  LOOP
    FETCH c_top INTO v_line;
    EXIT WHEN c_top%NOTFOUND OR v_top.COUNT >= p_limit;
    v_top.EXTEND;
    v_top(v_top.COUNT) := v_line;
  END LOOP;
  CLOSE c_top;

  DBMS_OUTPUT.PUT_LINE('=== Top ' || p_limit || ' earners ===');
  FOR i IN 1 .. v_top.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(i || '. ' || v_top(i));
  END LOOP;

EXCEPTION
  WHEN e_invalid_limit THEN
    RAISE_APPLICATION_ERROR(-20016, 'Limit must be a number between 1 and 5.');
  WHEN OTHERS THEN
    IF c_top%ISOPEN THEN
      CLOSE c_top;
    END IF;
    RAISE;
END show_top_earners;
/

-- Check: all 7 procedures must be VALID
SELECT object_name, object_type, status
FROM   user_objects
WHERE  object_type = 'PROCEDURE'
AND    object_name IN ('ADD_EMPLOYEE','UPDATE_EMPLOYEE_SALARY','DELETE_EMPLOYEE',
                       'DEPARTMENT_REPORT','SHOW_TEAM_MEMBERS','SHOW_SALARY_SUMMARY','SHOW_TOP_EARNERS')
ORDER  BY object_name;