select SessionId from 
	Sessions
except select 
	SessionId
from (select 
	SessionId, Letter
from Problems natural join Sessions
except select 
	SessionId, Letter
from Runs
where Accepted = 1) subQuery;