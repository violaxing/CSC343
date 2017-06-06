-- A1 report

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q10;

-- You must not change this table definition.
CREATE TABLE q10 (
	group_id integer,
	mark real,
	compared_to_average real,
	status varchar(5)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS assignment_mark CASCADE;
DROP VIEW IF EXISTS group_marks CASCADE;
DROP VIEW IF EXISTS average_marks CASCADE;
DROP VIEW IF EXISTS percent CASCADE;


CREATE VIEW assignment_mark AS (
SELECT DISTINCT assignment_id, SUM(out_of*weight) AS total
FROM RubricItem NATURAL JOIN Assignment
GROUP BY assignment_id, description
HAVING Assignment.description = 'A1'
);

CREATE VIEW group_marks AS (
SELECT t1.group_id, t2.mark 
FROM AssignmentGroup AS t1 NATURAL LEFT JOIN Result AS t2
);

CREATE VIEW average_marks AS (
SELECT AVG(mark) AS average
FROM  (SELECT DISTINCT group_id, total
	   FROM (AssignmentGroup 
	   NATURAL JOIN assignment_mark)) as a
 NATURAL JOIN group_marks
);

CREATE VIEW percent AS (
SELECT t3.group_id, 100*t3.mark/t3.total AS mark, 100*(t3.mark - t3.average)*t3.mark/(t3.mark*t3.total) AS compared_to_average 
FROM (((SELECT DISTINCT group_id, total
	   FROM (AssignmentGroup 
	   NATURAL JOIN assignment_mark)) as a
 NATURAL LEFT JOIN average_marks) AS t1
		NATURAL JOIN ((SELECT DISTINCT group_id, total
	   FROM (AssignmentGroup 
	   NATURAL JOIN assignment_mark)) as b
 NATURAL LEFT JOIN group_marks) AS t2) AS t3
);

-- Final answer.
INSERT INTO q10(
	SELECT group_id, mark, compared_to_average,
		CASE WHEN compared_to_average = null THEN null 
			 WHEN compared_to_average < 0 THEN 'below'
			 WHEN compared_to_average > 0 THEN 'above'
			 WHEN compared_to_average = 0 THEN 'at'
		END AS status
	FROM percent
);