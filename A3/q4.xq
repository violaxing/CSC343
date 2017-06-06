declare variable $dataset0 external;
declare variable $dataset1 external;
<bestskills>{
let $d1 := $dataset0
let $d2 := $dataset1
for $i in $d1//interview
let $rID := $i/@rID
let $maxScore := max(
                 let $a := $i/assessment
                 return (string($a/communication),string($a/enthusiasm),string($a/collegiality))   
                ) 
let $forename := (
                 for $r in $d2//resume
                 where $r/@rID = $rID
                 return $r/identification/name/forename 
                )
let $best := ((let $a := $i/assessment
              where string($a/communication) =$maxScore
              return <best resume = "{string($forename)}" position = "{$i/@sID}">{$a/communication}</best>),
              (let $a := $i/assessment
              where string($a/enthusiasm) =$maxScore
              return <best resume = "{string($forename)}" position = "{$i/@sID}" >{$a/enthusiasm}</best>),
              (let $a := $i/assessment
              where string($a/collegiality) =$maxScore
              return <best resume = "{string($forename)}" position = "{$i/@sID}" >{$a/collegiality}</best>))  
return $best
}</bestskills> 
	