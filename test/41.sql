select TeamId, sum(Accepted) as Solved
from (select distinct 
	SessionId, Letter, Accepted
from Runs
where Accepted = 1) subQuery
group by SessionId;