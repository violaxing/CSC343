declare variable $dataset0 external;
let $resumes := $dataset0/resumes
return
<qualified>{
for $r in $resumes/resume
let $num_skills := count($r/skills/skill)
where $num_skills > 3
  return
  <candidate
    rid = '{ $r/@rID }'
    numskills = '{ $num_skills }'
    citizenzhip = '{ $r/identification/citizenship/text() }'>
      <name>
        { $r/identification/name/forename/text() }
      </name>
    </candidate>
}</qualified>
    