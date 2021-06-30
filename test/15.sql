select 
	TeamName
from (
  select distinct TeamId
  from (
    select TeamId, ContestId
    from Teams natural join Sessions
    except
    select TeamId, ContestId
    from Sessions natural join Runs natural join Teams
    where Accepted = 1
  ) A
) B natural join Teams;