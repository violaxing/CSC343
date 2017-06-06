-- Uneven workloads

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q5;

-- You must not change this table definition.
CREATE TABLE q5 (
	assignment_id integer,
	username varchar(25), 
	num_assigned integer
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS grader_assignment CASCADE;
DROP VIEW IF EXISTS enough_range CASCADE;


CREATE VIEW grader_assignment as
SELECT assignmentGroup.assignment_id, grader.username, COUNT(grader.group_id) as num
FROM grader, assignmentGroup
WHERE grader.group_id = assignmentGroup.group_id
GROUP BY assignmentGroup.assignment_id, grader.username;


CREATE VIEW enough_range as
SELECT DISTINCT first.assignment_id
FROM grader_assignment as first, grader_assignment as second
WHERE (first.num - second.num) >= 10; 

-- Final answer.
INSERT INTO q5 
SELECT grader_assignment.assignment_id, username, num as num_assigned
FROM grader_assignment, enough_range
WHERE grader_assignment.assignment_id = enough_range.assignment_id;
