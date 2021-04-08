-- Распылить все экземпляры карты у игрока
-- Необходимый уровень изоляции - Repeatable Read
CREATE OR REPLACE FUNCTION deleteCardFromCollection(playerId BIGINT, cardName VARCHAR(100))
    RETURNS BOOLEAN
AS
$$
DECLARE
    oldQuantity INT;
BEGIN
    SELECT quantity
    INTO oldQuantity
    FROM CollectionCard CC
    WHERE CC.card_id IN (SELECT C.id from Card C WHERE C.name = cardName)
      AND CC.player_id = playerId;
    IF oldQuantity IS NULL THEN
        RETURN FALSE;
    END IF;
    DELETE
    FROM CollectionCard CC
    WHERE CC.card_id IN (SELECT C.id from Card C WHERE C.name = cardName)
      AND CC.player_id = playerId;
    RETURN TRUE;
END;
$$
    LANGUAGE plpgsql;


-- Распылить только один экземпляр карты у игрока
-- Необходимый уровень изоляции - Repeatable Read
CREATE OR REPLACE FUNCTION deleteOneCardFromCollection(playerId BIGINT, cardName VARCHAR(100))
    RETURNS BOOLEAN
AS
$$
DECLARE
    oldQuantity INT;
BEGIN
    SELECT quantity
    INTO oldQuantity
    FROM CollectionCard CC
    WHERE CC.card_id IN (SELECT C.id from Card C WHERE C.name = cardName)
      AND CC.player_id = playerId;
    IF oldQuantity IS NULL THEN
        RETURN FALSE;
    END IF;
    IF oldQuantity < 2 THEN
        DELETE
        FROM CollectionCard CC
        WHERE CC.card_id IN (SELECT C.id from Card C WHERE C.name = cardName)
          AND CC.player_id = playerId;
        RETURN TRUE;
    ELSE
        UPDATE CollectionCard
        SET quantity = quantity - 1
        WHERE player_id = playerId
          AND card_id IN (SELECT id from Card C WHERE C.name = cardName);
        RETURN TRUE;
    END IF;
END;
$$
    LANGUAGE plpgsql;


-- Изменить имя колоды
-- Необходимый уровень изоляции - Read Committed
CREATE OR REPLACE FUNCTION renameDeck(playerId BIGINT, deckNumber INT, deckName VARCHAR(100))
    RETURNS BOOLEAN
AS
$$
DECLARE
    oldName VARCHAR(100);
BEGIN
    SELECT name
    INTO oldName
    FROM Deck
    WHERE number = deckNumber
      AND player_id = playerId;
    IF oldName IS NULL THEN
        RETURN FALSE;
    END IF;
    UPDATE Deck
    SET name = deckName
    WHERE number = deckNumber
      AND player_id = playerId;
    RETURN TRUE;
END;
$$
    LANGUAGE plpgsql;

-- Проверить, лежит ли любимая рубашка для карт игрока в коллекции игрока
-- Необходимый уровень изоляции - Read Committed
CREATE OR REPLACE FUNCTION checkFavCardBack(playerId BIGINT)
    RETURNS BOOLEAN
AS
$$
DECLARE
    cardBackId INT;
BEGIN
    SELECT fav_card_back_id
    INTO cardBackId
    FROM Player
    WHERE id = playerId;
    IF cardBackId IN (SELECT card_back_id FROM PlayerCardBack WHERE player_id = playerId) THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$
    LANGUAGE plpgsql;

-- Соответствующий триггер
CREATE OR REPLACE FUNCTION checkFavCardBackTrigger()
    RETURNS TRIGGER
AS
$$
DECLARE
    cardBackId INT;
BEGIN
    SELECT fav_card_back_id
    INTO cardBackId
    FROM Player
    WHERE id = NEW.player_id;
    IF cardBackId IN (SELECT card_back_id FROM PlayerCardBack WHERE player_id = NEW.player_id) THEN
        RETURN NEW;
    END IF;
    RETURN OLD;
END;
$$
    LANGUAGE plpgsql;

-- Изменить любимую рубашку
-- Необходимый уровень изоляции - Read Committed
CREATE OR REPLACE FUNCTION editCardBack(playerId BIGINT, newCardBack INT)
    RETURNS BOOLEAN
AS
$$
BEGIN
    IF newCardBack NOT IN (SELECT card_back_id FROM PlayerCardBack WHERE player_id = playerId) THEN
        RETURN FALSE;
    END IF;
    UPDATE Player
    SET fav_card_back_id = newCardBack
    WHERE id = playerId;
    RETURN TRUE;
END;
$$
    LANGUAGE plpgsql;

-- Изменить основного героя для класса.
-- Если нового героя нет в коллекции игрока или он не соответствует классу, то возвращаем FALSE
-- Необходимый уровень изоляции - Read Committed
CREATE OR REPLACE FUNCTION editFavHero(playerId BIGINT, classId INT, newHeroId INT)
    RETURNS BOOLEAN
AS
$$
DECLARE
    heroClass INT;
BEGIN
    IF newHeroId NOT IN (SELECT hero_id FROM CollectionHero WHERE player_id = playerId) THEN
        RETURN FALSE;
    END IF;
    SELECT class_id INTO heroClass FROM Hero WHERE id = newHeroId;
    IF heroClass <> classId THEN
        RETURN FALSE;
    END IF;
    UPDATE FavoriteHero
    SET fav_hero_id = newHeroId
    WHERE player_id = playerId
      AND class_id = classId;
    RETURN TRUE;
END;
$$
    LANGUAGE plpgsql;

-- Удалить один экземпляр карты из колоды
-- Необходимый уровень изоляции - Repeatable Read
-- Можно удалить, например, карту из первой колоды первого игрока: `deleteOneCardFromDeck(1, 1, 'Houndmaster')`
-- И проверить, что их осталось 29: `getDeckSize(1, 1)`
CREATE OR REPLACE FUNCTION deleteOneCardFromCollection(playerId BIGINT, deckNo INT, cardName VARCHAR(100))
    RETURNS BOOLEAN
AS
$$
DECLARE
    oldAmount INT;
BEGIN
    SELECT amount
    INTO oldAmount
    FROM CardInDeck CD
    WHERE CD.card_id IN (SELECT C.id from Card C WHERE C.name = cardName)
      AND CD.player_id = playerId
      AND CD.deck_no = deckNo;
    IF oldAmount IS NULL THEN
        RETURN FALSE;
    END IF;
    IF oldAmount < 2 THEN
        DELETE
        FROM CardInDeck CD
        WHERE CD.card_id IN (SELECT C.id from Card C WHERE C.name = cardName)
          AND CD.player_id = playerId
          AND CD.deck_no = deckNo;
        RETURN TRUE;
    ELSE
        UPDATE CardInDeck
        SET amount = amount - 1
        WHERE player_id = playerId
          AND card_id IN (SELECT id from Card C WHERE C.name = cardName)
          AND deck_no = deckNo;
        RETURN TRUE;
    END IF;
END;
$$
    LANGUAGE plpgsql;

-- Проверить, соответствует ли карта в колоде классу колоды
-- Необходимый уровень изоляции - Read Committed
CREATE OR REPLACE FUNCTION checkCardClassInDeck(deckNo INT, cardId INT, playerId BIGINT)
    RETURNS BOOLEAN
AS
$$
DECLARE
    cardClazz INT;
BEGIN
    SELECT class_id INTO cardClazz FROM CardClass WHERE card_id = cardId;
    IF cardClazz IN (SELECT class_id FROM Deck WHERE number = deckNo AND player_id = playerId) THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$
    LANGUAGE plpgsql;

-- Соответствующий триггер
CREATE OR REPLACE FUNCTION checkCardClassInDeckTrigger()
    RETURNS TRIGGER
AS
$$
DECLARE
    cardClazz INT;
BEGIN
    SELECT class_id INTO cardClazz FROM CardClass WHERE card_id = NEW.deck_no;
    IF cardClazz IN (SELECT class_id FROM Deck WHERE number = NEW.deck_no AND player_id = NEW.player_id) THEN
        RETURN NEW;
    END IF;
    RETURN OLD;
END;
$$
    LANGUAGE plpgsql;

-- Проверить, есть ли новый герой коллекции игрока и соответствует ли он своему классу
-- Необходимый уровень изоляции - Read Committed
CREATE OR REPLACE FUNCTION checkFavHeroClass(playerId BIGINT, classId INT, newHeroId INT)
    RETURNS BOOLEAN
AS
$$
DECLARE
    heroClass INT;
BEGIN
    IF newHeroId NOT IN (SELECT hero_id FROM CollectionHero WHERE player_id = playerId) THEN
        RETURN FALSE;
    END IF;
    SELECT class_id INTO heroClass FROM Hero WHERE id = newHeroId;
    IF heroClass <> classId THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
$$
    LANGUAGE plpgsql;

-- Соответствующий триггер
CREATE OR REPLACE FUNCTION checkFavHeroClassTrigger()
    RETURNS TRIGGER
AS
$$
DECLARE
    heroClass INT;
BEGIN
    IF NEW.fav_hero_id NOT IN (SELECT hero_id FROM CollectionHero WHERE player_id = NEW.player_id) THEN
        RETURN OLD;
    END IF;
    SELECT class_id INTO heroClass FROM Hero WHERE id = NEW.fav_hero_id;
    IF heroClass <> NEW.class_id THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;
