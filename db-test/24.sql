select distinct
	ContestId, Letter
from Problems p
where not exists (select
	ContestId, Letter
from Sessions s, Runs r
where r.SessionId = s.SessionId
and r.Accepted = 1
and r.Letter = p.Letter
and s.ContestId = p.ContestId);
