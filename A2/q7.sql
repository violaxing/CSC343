
-- High coverage

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q7;

-- You must not change this table definition.
CREATE TABLE q7 (
	ta varchar(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS Student_grader CASCADE;
DROP VIEW IF EXISTS assignments CASCADE;
DROP VIEW IF EXISTS students CASCADE;

-- Student and grader pairs
CREATE VIEW Student_grader AS
SELECT AssignmentGroup.assignment_id, Grader.group_id, Grader.username AS ta, Membership.username AS stu
FROM Grader, Membership, AssignmentGroup
WHERE Grader.group_id = Membership.group_id AND Membership.group_id = AssignmentGroup.group_id;

-- Graded on all assignments
CREATE VIEW assignments AS
SELECT DISTINCT ta
FROM Student_Grader AS sg1
WHERE NOT EXISTS 
((SELECT assignment_id FROM Assignment)
EXCEPT
(SELECT assignment_id FROM Student_Grader AS sg2 WHERE sg1.ta = sg2.ta));

-- Graded every student on some assignment
CREATE VIEW students AS
SELECT DISTINCT ta
FROM Student_Grader AS sg1
WHERE NOT EXISTS 
(SELECT username AS stu FROM Membership
EXCEPT
SELECT stu FROM Student_Grader AS sg2 WHERE sg1.ta = sg2.ta);

-- Final answer.
INSERT INTO q7
SELECT assignments.ta AS ta
FROM assignments INNER JOIN students ON assignments.ta = students.ta;
	-- put a final query here so that its results will go into the table.
