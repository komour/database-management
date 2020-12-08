CREATE TABLE LosersT AS (
  SELECT Losers.StudentId, Losers.Debts
  FROM Losers);


CREATE FUNCTION update_losers_with_marks()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
	IF TG_OP = 'TRUNCATE' THEN
		TRUNCATE LosersT;
		INSERT INTO LosersT (StudentId, Debts)
		SELECT * FROM Losers;
		RETURN NULL;
	ELSEIF TG_OP = 'DELETE' THEN
		DELETE FROM LosersT
			WHERE StudentId = OLD.StudentId;
		INSERT INTO LosertT (SELECT StudentId, DebtsCount FROM Losers 
			WHERE Losers.StudentId = OLD.StudentId);
		RETURN NULL;
	ELSE
		DELETE FROM LoserT
		WHERE StudentId = NEW.StudentId;
		INSERT INTO LosertT (SELECT StudentId, DebtsCount FROM Losers 
			WHERE Losers.StudentId = NEW.StudentId);
		RETURN NEW;
	END IF;
END;
$$


CREATE TRIGGER update_losers
	AFTER INSERT OR DELETE OR UPDATE OR TRUNCATE 
	ON Marks
	FOR EACH ROW 
	EXECUTE PROCEDURE update_losers_with_marks();
