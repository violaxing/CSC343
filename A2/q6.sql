
-- Steady work

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q6;

-- You must not change this table definition.
CREATE TABLE q6 (
	group_id integer,
	first_file varchar(25),
	first_time timestamp,
	first_submitter varchar(25),
	last_file varchar(25),
	last_time timestamp, 
	last_submitter varchar(25),
	elapsed_time interval
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS A1_groups CASCADE;
DROP VIEW IF EXISTS first CASCADE;
DROP VIEW IF EXISTS last CASCADE;


CREATE VIEW A1_groups AS
SELECT group_id
FROM AssignmentGroup NATURAL JOIN Assignment
WHERE Assignment.description = 'A1';

CREATE VIEW first AS
SELECT group_id, file_name AS first_file, submission_date AS first_time, username AS first_submitter
FROM A1_groups NATURAL
LEFT JOIN Submissions sub1
WHERE submission_date <= ALL (SELECT submission_date FROM Submissions sub2 WHERE sub1.group_id = sub2.group_id);

CREATE VIEW last AS
SELECT group_id, file_name AS last_file, submission_date AS last_time, username AS last_submitter
FROM A1_groups NATURAL
LEFT JOIN Submissions sub1
WHERE submission_date >= ALL (SELECT submission_date FROM Submissions sub2 WHERE sub1.group_id = sub2.group_id);


-- Final answer.
INSERT INTO q6
SELECT group_id, first_file, first_time, first_submitter, last_file, last_time, last_submitter, AGE(last_time, first_time)
FROM first NATURAL FULL JOIN last;