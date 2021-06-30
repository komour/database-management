select distinct
	TeamName
from Sessions s, Runs r, Teams t
where r.SessionId = s.SessionId
and r.Letter = :Letter
and r.Accepted = 1
and s.ContestId = :ContestId
and t.TeamId = s.TeamId;
