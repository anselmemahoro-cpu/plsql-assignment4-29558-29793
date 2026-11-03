-- =====================================================
-- Procedure 5: show_team_members
-- File: 01_procedures/show_team_members.sql
-- Uses: NESTED TABLE of %ROWTYPE records, EXTEND, COUNT, LAST,
--       explicit cursor, %ROWTYPE, user-defined exception
-- =====================================================
CREATE OR REPLACE PROCEDURE show_team_members (
  p_manager_id  IN  NUMBER,
  p_team_count  OUT NUMBER
)
IS
  -- nested table where each element is a full employee record
  TYPE t_team IS TABLE OF employee%ROWTYPE;
  v_team          t_team := t_team();
  v_row           employee%ROWTYPE;
  v_manager_name  VARCHAR2(101);

  CURSOR c_team IS
    SELECT *
    FROM   employee
    WHERE  manager_id = p_manager_id
    ORDER  BY employee_id;

  e_no_team EXCEPTION;
BEGIN
  -- raises ORA-20001 if the manager does not exist
  v_manager_name := get_employee_name(p_manager_id);

  OPEN c_team;
  LOOP
    FETCH c_team INTO v_row;
    EXIT WHEN c_team%NOTFOUND;
    v_team.EXTEND;                  -- make room for one more element
    v_team(v_team.LAST) := v_row;   -- store the record in the collection
  END LOOP;
  CLOSE c_team;

  p_team_count := v_team.COUNT;

  IF p_team_count = 0 THEN
    RAISE e_no_team;
  END IF;

  DBMS_OUTPUT.PUT_LINE('=== Team of ' || v_manager_name || ' ===');
  FOR i IN 1 .. v_team.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(i || '. ' ||
                         v_team(i).first_name || ' ' || v_team(i).last_name ||
                         ' | salary ' || v_team(i).salary ||
                         ' | ' || v_team(i).status);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Team size: ' || p_team_count);

EXCEPTION
  WHEN e_no_team THEN
    RAISE_APPLICATION_ERROR(-20015, v_manager_name || ' has no employees reporting to them.');
  WHEN OTHERS THEN
    IF c_team%ISOPEN THEN
      CLOSE c_team;
    END IF;
    RAISE;
END show_team_members;
/
