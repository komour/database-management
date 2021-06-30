select distinct
	TeamId
from Sessions s, Runs r
where r.SessionId = s.SessionId
and r.Letter = :Letter
and r.Accepted = 1
and s.ContestId = :ContestId;

