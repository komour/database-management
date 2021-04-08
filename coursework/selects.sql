-- Для некоторых запросов сначала определен простой запрос, затем функция, обобщающая этот запрос.
-- Для каких-то запросов удобнее было сделать view.

-- Получить все колоды игрока для определенного класса (номер, название)
SELECT D.number,
       D.name
FROM Deck D
WHERE player_id = 3
  AND class_id = 9;

CREATE OR REPLACE FUNCTION getDecksByPlayerIddAndClassId(playerId BIGINT, classId INT)
    RETURNS TABLE
            (
                number INT,
                name   VARCHAR(100)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT D.number,
               D.name
        FROM Deck D
        WHERE player_id = playerId
          AND class_id = classId;
END;
$$
    LANGUAGE plpgsql;


-- Получить все колоды игрока с определенным именем (все атрибуты колод)
SELECT number, name, class_id, player_id
FROM Deck
WHERE player_id = 3
  AND name = 'Control Warrior';

CREATE OR REPLACE FUNCTION getDecksByPlayerIdAndDeckName(playerId BIGINT, deckName VARCHAR(100))
    RETURNS TABLE
            (
                number    INT,
                name      VARCHAR(100),
                class_id  INT,
                player_id BIGINT
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT D.number, D.name, D.class_id, D.player_id
        FROM Deck D
        WHERE D.player_id = playerId
          AND D.name = deckName;
END;
$$
    LANGUAGE plpgsql;

-- Получить имена и описания всех героев для определенного класса
SELECT name AS hunters, description
FROM Hero
WHERE class_id = 2;

CREATE OR REPLACE FUNCTION getHeroesByClassId(classId INT)
    RETURNS TABLE
            (
                name        VARCHAR(100),
                description VARCHAR(300)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT H.name, H.description
        FROM Hero H
        WHERE class_id = classId;
END;
$$
    LANGUAGE plpgsql;


-- Получить имена и описания всех карт определенного типа
SELECT C.name AS weapons, description
FROM Card C
         JOIN CardType CT ON CT.id = C.type
WHERE CT.name = 'Weapon';

CREATE OR REPLACE FUNCTION getCardsByType(typeName VARCHAR(100))
    RETURNS TABLE
            (
                name        VARCHAR(100),
                description VARCHAR(300)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT C.name, C.description
        FROM Card C
                 JOIN CardType CT ON CT.id = C.type
        WHERE CT.name = typeName;
END;
$$
    LANGUAGE plpgsql;


-- Получить имена и описания всех карт определенной редкости
SELECT C.name AS epic_cards, C.description
FROM Card C
         JOIN CardRarity CR ON CR.id = C.rarity
WHERE CR.name = 'Epic';

CREATE OR REPLACE FUNCTION getCardsByRarity(rarityName VARCHAR(100))
    RETURNS TABLE
            (
                name        VARCHAR(100),
                description VARCHAR(300)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT C.name, C.description
        FROM Card C
                 JOIN CardRarity CR ON CR.id = C.rarity
        WHERE CR.name = rarityName;
END ;
$$
    LANGUAGE plpgsql;

-- Получить имена и описания всех элитных карт
CREATE OR REPLACE VIEW EliteCards AS
SELECT name AS elite_cards, description
FROM Card
WHERE elite = TRUE;

-- Получить имена и описания всех карт с определенным значением атаки
-- getCardsByAttack
SELECT name, description
FROM Card
WHERE attack <= 1;

-- Получить имена и описания всех карт с определенным значением здоровья
-- getCardsByHealth
SELECT name, description
FROM Card
WHERE health > 4;

-- Получить имена и описания всех карт с определенными здоровьем и атакой
-- getCardsByHealthAndAttack
SELECT name, description
FROM Card
WHERE health > 3
  AND attack > 3;

-- Получить имена и описания всех карт определенной стоимости
SELECT name, description
FROM Card
WHERE cost = 0;

CREATE OR REPLACE FUNCTION getCardsByCost(cardCost INT)
    RETURNS TABLE
            (
                name        VARCHAR(100),
                description VARCHAR(300)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT C.name, C.description
        FROM Card C
        WHERE C.cost = cardCost;
END;
$$
    LANGUAGE plpgsql;

-- Получить имена и описания всех нейтральных карт
CREATE OR REPLACE VIEW NeutralCards AS
SELECT name, description
FROM Card
WHERE neutral = TRUE;

-- Получить имена и описания всех карт для определенного класса
SELECT Card.name AS hunter_cards, Card.description
FROM Card
         JOIN CardClass CC ON Card.id = CC.card_id
         JOIN Class C ON CC.class_id = C.id
WHERE C.name = 'Hunter';

CREATE OR REPLACE FUNCTION getCardsByClass(class VARCHAR(100))
    RETURNS TABLE
            (
                name        VARCHAR(100),
                description VARCHAR(300)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT Card.name AS hunter_cards, Card.description
        FROM Card
                 JOIN CardClass CC ON Card.id = CC.card_id
                 JOIN Class C ON CC.class_id = C.id
        WHERE C.name = class;
END;
$$
    LANGUAGE plpgsql;

-- Получить имена и описания всех карт игрока
SELECT name, description
FROM Card
         JOIN CollectionCard CC ON Card.id = CC.card_id
WHERE player_id = 2;

CREATE OR REPLACE FUNCTION getCardsByPlayerId(playerId BIGINT)
    RETURNS TABLE
            (
                name        VARCHAR(100),
                description VARCHAR(300)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT Card.name, Card.description
        FROM Card
                 JOIN CollectionCard CC ON Card.id = CC.card_id
        WHERE player_id = playerId;
END;
$$
    LANGUAGE plpgsql;

-- Получить названия всех рубашек для карт игрока
SELECT name
FROM CardBack
         JOIN PlayerCardBack PCB ON CardBack.id = PCB.card_back_id
WHERE player_id = 3;

CREATE OR REPLACE FUNCTION getCardBacksByPlayerId(playerId BIGINT)
    RETURNS TABLE
            (
                name        VARCHAR(100),
                description VARCHAR(300)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT CardBack.name
        FROM CardBack
                 JOIN PlayerCardBack PCB ON CardBack.id = PCB.card_back_id
        WHERE player_id = playerId;
END;
$$
    LANGUAGE plpgsql;

-- Получить имена всех героев в коллекции игрока
SELECT Hero.name, C.name
FROM Hero
         JOIN CollectionHero CH ON Hero.id = CH.hero_id
         JOIN Class C ON Hero.class_id = C.id
WHERE player_id = 3;

CREATE OR REPLACE FUNCTION getHeroesByPlayerId(playerId BIGINT)
    RETURNS TABLE
            (
                name        VARCHAR(100),
                description VARCHAR(300)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT Hero.name, C.name
        FROM Hero
                 JOIN CollectionHero CH ON Hero.id = CH.hero_id
                 JOIN Class C ON Hero.class_id = C.id
        WHERE player_id = playerId;
END;
$$
    LANGUAGE plpgsql;

-- Получить всех игроков с определенным ником (все атрибуты игрока)
SELECT id, username, email
FROM Player
WHERE username = 'Forsen';

CREATE OR REPLACE FUNCTION getUsersByUsername(playerName VARCHAR(25))
    RETURNS TABLE
            (
                id       BIGINT,
                username VARCHAR(25),
                email    VARCHAR(250)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT P.id, P.username, P.email
        FROM Player P
        WHERE P.username = playerName;
END;
$$
    LANGUAGE plpgsql;


-- Получить список героев, выбранных у игрока в качестве основных для всех классов (ник игрока, имя класса, имя героя)
SELECT P.username, C.name, H.name
FROM FavoriteHero FH
         JOIN Class C ON C.id = FH.class_id
         JOIN CollectionHero CH ON FH.player_id = CH.player_id AND FH.fav_hero_id = CH.hero_id
         JOIN Hero H ON C.id = H.class_id AND CH.hero_id = H.id
         JOIN Player P ON FH.player_id = P.id
WHERE FH.player_id = 3;

CREATE OR REPLACE FUNCTION getUsersFavHeroes(userId VARCHAR(25))
    RETURNS TABLE
            (
                username   VARCHAR(25),
                class_name VARCHAR(100),
                hero_name  VARCHAR(100)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT P.username, C.name, H.name
        FROM FavoriteHero FH
                 JOIN Class C ON C.id = FH.class_id
                 JOIN CollectionHero CH ON FH.player_id = CH.player_id AND FH.fav_hero_id = CH.hero_id
                 JOIN Hero H ON C.id = H.class_id AND CH.hero_id = H.id
                 JOIN Player P ON FH.player_id = P.id
        WHERE FH.player_id = userId;
END;
$$
    LANGUAGE plpgsql;

-- Получить все карты из колоды игрока (имя колоды, имя карты, количество карты в колоде)
SELECT D.name, C.name, CD.amount
FROM CardInDeck CD
         JOIN Deck D ON D.player_id = CD.player_id AND D.number = CD.deck_no
         JOIN Card C ON CD.card_id = C.id
WHERE CD.player_id = 1
  AND CD.deck_no = 1;

CREATE OR REPLACE FUNCTION getDeckCards(playerId BIGINT, deckNo INT)
    RETURNS TABLE
            (
                deck_name VARCHAR(100),
                card_name VARCHAR(100),
                amount    QDECK
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT D.name, C.name, CD.amount
        FROM CardInDeck CD
                 JOIN Deck D ON D.player_id = CD.player_id AND D.number = CD.deck_no
                 JOIN Card C ON CD.card_id = C.id
        WHERE CD.player_id = playerId
          AND CD.deck_no = deckNo;
END;
$$
    LANGUAGE plpgsql;


-- Посчитать количество карт в колоде
SELECT sum(CD.amount)
FROM CardInDeck CD
WHERE CD.player_id = 1
  AND CD.deck_no = 1;

CREATE OR REPLACE FUNCTION getDeckSize(playerId BIGINT, deckNo INT)
    RETURNS TABLE
            (
                size BIGINT
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT sum(CD.amount)
        FROM CardInDeck CD
        WHERE CD.player_id = playerId
          AND CD.deck_no = deckNo;
END;
$$
    LANGUAGE plpgsql;