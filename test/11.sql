select 
    RunId, SessionId, Letter, SubmitTime, Accepted
from Sessions natural join Runs natural join Problems
where ContestId = :ContestId
and TeamId = :TeamId;