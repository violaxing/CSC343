-- Distributions

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q1;

-- You must not change this table definition.
CREATE TABLE q1 (
	assignment_id integer,
	average_mark_percent real, 
	num_80_100 integer, 
	num_60_79 integer, 
	num_50_59 integer, 
	num_0_49 integer
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS total CASCADE;
DROP VIEW IF EXISTS grade1 CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW total AS
SELECT rubricitem.assignment_id, SUM(out_of*weight) AS total
FROM rubricitem
GROUP BY rubricitem.assignment_id;

CREATE VIEW grade1 AS
SELECT Total.assignment_id, (mark/total * 100) AS score
FROM Result, total, AssignmentGroup
WHERE Result.group_id = AssignmentGroup.group_id 
AND AssignmentGroup.assignment_id = Total.assignment_id;

-- Final answer.
INSERT INTO q1 
SELECT assignment_id, AVG(score) AS average_mark_percent,
       SUM(CASE WHEN score <= 100 AND score >= 80 THEN 1 ELSE 0 END) as num_80_100,
	   SUM(CASE WHEN score < 80 AND score >= 60 THEN 1 ELSE 0 END) as num_60_79,
	   SUM(CASE WHEN score < 60 AND score >= 50 THEN 1 ELSE 0 END) as num_50_59,
	   SUM(CASE WHEN score < 50 THEN 1 ELSE 0 END) as num_0_49
FROM grade1
GROUP BY assignment_id;
