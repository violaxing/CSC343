DROP SCHEMA IF EXISTS markus CASCADE;
CREATE SCHEMA markus;
SET search_path TO markus;

CREATE TYPE Degree AS ENUM ('certificate', 'undergraduate', 'professional', 'masters', 'doctoral');
CREATE TYPE Skills AS ENUM ('SQL', 'Scheme', 'Python', 'R', 'LaTeX');
CREATE TYPE level AS ENUM ('1', '2', '3', '4', '5');
CREATE DOMAIN importance AS smallint
    CHECK (VALUE <= 5 and VALUE >= 1);
CREATE DOMAIN grade AS smallint
   CHECK (VALUE >= 0 and VALUE <= 100);

--postings
-- the pid as well as position

CREATE TABLE position (
  pID varchar(20) PRIMARY KEY NOT NULL,
  position varchar(100) NOT NULL
);

-- the question id
CREATE TABLE questionID (
	qID varchar(20) PRIMARY KEY NOT NULL
);

-- the questions asked based on position and question id
CREATE TABLE questions(
	pID varchar(20) NOT NULL REFERENCES position,
	qID varchar(20) NOT NULL REFERENCES questionID,
	question varchar(100) NOT NULL,
	PRIMARY KEY(pID, qID)
) ;
-- required skill for the job and also the importance of the skill
CREATE TABLE reqSkills(
	pID varchar(20) NOT NULL REFERENCES position,
	what Skills NOT NULL, 
	skill_level level NOT NULL,
	skill_importance importance NOT NULL
);

--interview
-- the interview date and location along with a reference number
CREATE TABLE Interview (
	sID varchar(20) PRIMARY KEY NOT NULL,
	InterviewDate timestamp NOT NULL,
	location varchar(40) NOT NULL
) ; 
-- who is doing the interview
CREATE TABLE interviewer (
  sID varchar(20) PRIMARY KEY NOT NULL REFERENCES Interview,
  forename varchar(20) NOT NULL,
  surname varchar(20) NOT NULL,
  honorific varchar(20),
  title varchar(20)
);

-- resume of those who are gonna be interviewed with all the info
CREATE TABLE resume (
    rID varchar(20) NOT NULL PRIMARY KEY,
    forename varchar(50) NOT NULL,
    surname varchar(50) NOT NULL,
    DOB varchar(50) NOT NULL,
    citizenship varchar(50) NOT NULL,
    address varchar(50) NOT NULL,
    telephone varchar(20) NOT NULL,
    email varchar(50) NOT NULL
);

-- the assessment of the one who applied for the job
CREATE TABLE assessment (
   rID varchar(20) REFERENCES resume(rID),
   pID varchar(20) REFERENCES position(pID),
   sID varchar(20) REFERENCES Interview(sID),
   techProficiency grade NOT NULL,
   communication grade NOT NULL,
   enthusiasm grade NOT NULL,
   collegiality grade NOT NULL,
   PRIMARY KEY (rID, pID, sID)
);
-- the questions asked and the answers given
CREATE TABLE questionAnswer (
   rID varchar(20),
   pID varchar(20),
   sID varchar(20),
   qID varchar(20) REFERENCES questionID,
   answer varchar(100) NOT NULL,
   FOREIGN KEY (rID, pID, sID) REFERENCES assessment,
   PRIMARY KEY (rID, pID, sID, qID)
);

-- name of the one to be interviewed

CREATE TABLE name (
  rID varchar(20) NOT NULL REFERENCES resume(rID),
  forename varchar(20) NOT NULL,
  surname varchar(20) NOT NULL,
  honorific varchar(20),
  title varchar(50) NOT NULL,
  PRIMARY KEY (rID, forename)

);
-- summarizing how the applicant was
CREATE TABLE summaries (
	rID varchar(20) NOT NULL REFERENCES resume(rID),
  sumID varchar(20),
	summary varchar(1000),
	PRIMARY KEY (rID, sumID)
);

-- education of the applicant and where he got his degree
CREATE TABLE education (
  eID varchar(20) NOT NULL,
  rID varchar(20) NOT NULL REFERENCES resume(rID),
  degreeName varchar(50) NOT NULL,
  institution varchar(50) NOT NULL,
  honors varchar(20),
  startDate varchar(50) NOT NULL,
  endDate varchar(50) NOT NULL,
  level degree NOT NULL,
  PRIMARY KEY (eID)
);
-- experiences the applicant has and when he started as well as end
CREATE TABLE experience(
 positionTitle varchar(100) NOT NULL,
 description text,
 startDate varchar(50) NOT NULL,
 endDate varchar(50) NOT NULL
);
-- if major, which institution and what major along with degree
CREATE TABLE major (
  rID varchar(20) REFERENCES resume(rID),
  degreeName varchar(30) NOT NULL,
  institution varchar(50) NOT NULL,
  major varchar(20) NOT NULL,
  PRIMARY KEY (rID, major)
);
-- if minor, which institution and what major along with degree
CREATE TABLE minor (
  rID varchar(20) REFERENCES resume(rID),
  degreeName varchar(30) NOT NULL,
  institution varchar(50) NOT NULL,
  minor varchar(20) NOT NULL,
  PRIMARY KEY (rID, minor)
);