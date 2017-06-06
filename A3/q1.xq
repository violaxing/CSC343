declare variable $dataset0 external;
<dbjobs>{
  for $posting in $dataset0//posting
  where $posting//reqSkill[@what = "SQL"]
  and $posting//reqSkill[@level = "5"]
  return $posting	
}</dbjobs>