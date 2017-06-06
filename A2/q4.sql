-- Grader report

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q4;

-- You must not change this table definition.
CREATE TABLE q4 (
	assignment_id integer,
	username varchar(25), 
	num_marked integer, 
	num_not_marked integer,
	min_mark real,
	max_mark real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS total CASCADE;
DROP VIEW IF EXISTS grader_assignment CASCADE;

CREATE VIEW total AS
SELECT RubricItem.assignment_id, SUM(out_of*weight) AS total
FROM RubricItem
GROUP BY RubricItem.assignment_id;

CREATE VIEW grader_assignment AS
SELECT Grader.username, AssignmentGroup.assignment_id, (mark/total * 100) AS score
FROM AssignmentGroup, Total, Grader LEFT JOIN Result ON Grader.group_id = Result.group_id
WHERE Grader.group_id = AssignmentGroup.group_id
AND AssignmentGroup.assignment_id = total.assignment_id;

-- Final answer.
INSERT INTO q4
SELECT assignment_id, username,
	SUM(CASE WHEN score IS NOT NULL THEN 1 ELSE 0 END) AS num_marked,
	SUM(CASE WHEN score IS NULL THEN 1 ELSE 0 END) AS num_not_marked,
	MIN(score) AS min_mark,
	MAX(score) AS max_mark
FROM grader_assignment
GROUP BY assignment_id, username;