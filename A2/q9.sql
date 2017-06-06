
-- Inseparable

SET SEARCH_PATH TO markus;
DROP TABLE IF EXISTS q9;

-- You must not change this table definition.
CREATE TABLE q9 (
	student1 varchar(25),
	student2 varchar(25)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS Pair CASCADE;
DROP VIEW IF EXISTS all_pair CASCADE;
DROP VIEW IF EXISTS not_together CASCADE;
DROP VIEW IF EXISTS together CASCADE;

CREATE VIEW pair as
SELECT AssignmentGroup.assignment_id, t1.username AS student1, t2.username AS student2
FROM AssignmentGroup, Membership AS t1, Membership AS t2
WHERE AssignmentGroup.group_id = t1.group_id
  AND t1.group_id = t2.group_id
  AND t1.username != t2.username;

CREATE VIEW all_pair as
SELECT Assignment.assignment_id, t1.username AS student1, t2.username AS student2
FROM Assignment, MarkusUser AS t1, MarkusUser AS t2
WHERE t1.type = 'student'
  AND t2.type = 'student'
  AND t1.username != t2.username
  AND group_max > 1;

CREATE VIEW not_together as
SELECT * FROM all_pair EXCEPT SELECT * FROM pair;


CREATE VIEW together as
(SELECT student1, student2
	FROM pair
	GROUP BY student1, student2)
EXCEPT
(SELECT student1, student2
	FROM not_together
	GROUP BY student1, student2);

-- Final answer.
INSERT INTO q9 
SELECT a.student1, a.student2
FROM together as a, together as b
WHERE a.student1 < a.student2
	AND a.student1 != b.student2 
	AND a.student2 != b.student1
GROUP BY a.student1, a.student2;