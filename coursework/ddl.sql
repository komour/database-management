CREATE DOMAIN POSINT AS INT CHECK (VALUE >= 0);
CREATE DOMAIN QDECK AS INT CHECK (VALUE BETWEEN 1 AND 2);
CREATE DOMAIN QCARD AS INT CHECK (VALUE > 0);

CREATE TABLE Player
(
    id               BIGINT       NOT NULL GENERATED ALWAYS AS IDENTITY,
    username         VARCHAR(25)  NOT NULL,
    password         CHAR(64)     NOT NULL,
    fav_card_back_id INT          NOT NULL,
    email            VARCHAR(250) NOT NULL,
    CONSTRAINT Player_K1 UNIQUE (email),
    CONSTRAINT Player_PK PRIMARY KEY (id)
);

CREATE TABLE CardBack
(
    id          INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(300) NOT NULL,
    CONSTRAINT CardBack_K1 UNIQUE (name),
    CONSTRAINT CardBack_K2 UNIQUE (description),
    CONSTRAINT CardBack_PK PRIMARY KEY (id)
);

ALTER TABLE Player
    ADD CONSTRAINT Player_FK1 FOREIGN KEY (fav_card_back_id) REFERENCES CardBack (id)
        ON UPDATE CASCADE;

CREATE TABLE PlayerCardBack
(
    player_id    BIGINT NOT NULL,
    card_back_id INT    NOT NULL,
    CONSTRAINT PlayerCardBack_FK1 FOREIGN KEY (player_id) REFERENCES Player (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT PlayerCardBack_FK2 FOREIGN KEY (card_back_id) REFERENCES CardBack (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT PlayerCardBack_PK PRIMARY KEY (player_id, card_back_id)
);

CREATE TABLE Class
(
    id      INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    name    VARCHAR(100) NOT NULL,
    hero_id INT          NOT NULL,
    CONSTRAINT Class_K1 UNIQUE (name),
    CONSTRAINT Class_K2 UNIQUE (hero_id),
    CONSTRAINT Class_PK PRIMARY KEY (id)
);

CREATE TABLE Hero
(
    id          INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    name        VARCHAR(100) NOT NULL,
    class_id    INT          NOT NULL,
    description VARCHAR(300) NOT NULL,
    CONSTRAINT Hero_K1 UNIQUE (name),
    CONSTRAINT Hero_K2 UNIQUE (description),
    CONSTRAINT Hero_FK1 FOREIGN KEY (class_id) REFERENCES Class (id)
        ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT Hero_PK PRIMARY KEY (id)
);

ALTER TABLE Class
    ADD CONSTRAINT Class_FK1 FOREIGN KEY (hero_id) REFERENCES Hero (id)
        ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE CollectionHero
(
    player_id BIGINT NOT NULL,
    hero_id   INT    NOT NULL,
    CONSTRAINT PlayerHero_FK1 FOREIGN KEY (player_id) REFERENCES Player (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT PlayerHero_FK2 FOREIGN KEY (hero_id) REFERENCES Hero (id)
        ON UPDATE CASCADE,
    CONSTRAINT CollectionHero_PK PRIMARY KEY (player_id, hero_id)
);

CREATE TABLE FavoriteHero
(
    player_id   BIGINT NOT NULL,
    class_id    INT    NOT NULL,
    fav_hero_id INT    NOT NULL,
    CONSTRAINT FavoriteHero_FK1 FOREIGN KEY (player_id) REFERENCES Player (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FavoriteHero_FK2 FOREIGN KEY (player_id, fav_hero_id) REFERENCES CollectionHero (player_id, hero_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FavoriteHero_FK3 FOREIGN KEY (class_id) REFERENCES Class (id)
        ON UPDATE CASCADE,
    CONSTRAINT FavoriteHero_PK PRIMARY KEY (player_id, class_id)
);

CREATE TABLE CardType
(
    id   INT NOT NULL GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100),
    CONSTRAINT CardType_K1 UNIQUE (id),
    CONSTRAINT CardType_PK PRIMARY KEY (id)
);

CREATE TABLE CardRarity
(
    id   INT NOT NULL GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100),
    CONSTRAINT CardRarity_K1 UNIQUE (name),
    CONSTRAINT CardRarity_PK PRIMARY KEY (id)
);

CREATE TABLE Card
(
    id          INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    name        VARCHAR(100) NOT NULL,
    neutral     BOOLEAN      NOT NULL,
    type        INT          NOT NULL,
    cost        POSINT       NOT NULL,
    rarity      INT          NOT NULL,
    elite       BOOLEAN      NOT NULL,
    attack      POSINT,
    health      POSINT,
    description VARCHAR(300),
    CONSTRAINT Card_K1 UNIQUE (name),
    CONSTRAINT Card_FK1 FOREIGN KEY (type) REFERENCES CardType (id)
        ON UPDATE CASCADE,
    CONSTRAINT Card_FK2 FOREIGN KEY (rarity) REFERENCES CardRarity (id)
        ON UPDATE CASCADE,
    CONSTRAINT Card_PK PRIMARY KEY (id)
);

CREATE TABLE CardClass
(
    card_id  INT NOT NULL,
    class_id INT NOT NULL,
    CONSTRAINT CardClass_FK1 FOREIGN KEY (card_id) REFERENCES Card (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CardClass_FK2 FOREIGN KEY (class_id) REFERENCES Class (id)
        ON UPDATE CASCADE,
    CONSTRAINT CardClass_PK PRIMARY KEY (card_id)
);

CREATE TABLE Deck
(
    number    INT         NOT NULL,
    name      VARCHAR(24) NOT NULL,
    class_id  INT         NOT NULL,
    player_id BIGINT      NOT NULL,
    CONSTRAINT Deck_FK1 FOREIGN KEY (class_id) REFERENCES Class (id)
        ON UPDATE CASCADE,
    CONSTRAINT Deck_FK2 FOREIGN KEY (player_id) REFERENCES Player (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Deck_PK PRIMARY KEY (number, player_id)
);

CREATE TABLE CollectionCard
(
    player_id BIGINT NOT NULL,
    card_id   INT    NOT NULL,
    quantity  QCARD  NOT NULL,
    CONSTRAINT CollectionCard_FK1 FOREIGN KEY (player_id) REFERENCES Player (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CollectionCard_FK2 FOREIGN KEY (card_id) REFERENCES Card (id)
        ON UPDATE CASCADE,
    CONSTRAINT CollectionCard_PK PRIMARY KEY (player_id, card_id)
);

CREATE TABLE CardInDeck
(
    deck_no   BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    card_id   INT    NOT NULL,
    amount    QDECK  NOT NULL,
    CONSTRAINT CardInDeck_FK1 FOREIGN KEY (player_id, deck_no) REFERENCES Deck (player_id, number)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CardInDeck_FK2 FOREIGN KEY (player_id, card_id) REFERENCES CollectionCard (player_id, card_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CardInDeck_PK PRIMARY KEY (deck_no, card_id, player_id)
);


-- Поиск всех колод игрока для определенного класса
CREATE INDEX ON Deck USING BTREE (player_id, class_id);

-- Поиск всех колод игрока с определенным именем
CREATE INDEX ON Deck USING BTREE (player_id, name);

-- Поиск всех героев для определенного класса
CREATE INDEX ON Hero USING HASH (class_id);

-- Поиск всех карт определенного типа
CREATE INDEX ON Card USING HASH (type);

-- Поиск всех карт определенной редкости
CREATE INDEX ON Card USING HASH (rarity);

-- Поиск всех элитных карт
CREATE INDEX ON Card USING HASH (elite);

-- Поиск всех карт с определенным значнием атаки
CREATE INDEX ON Card USING BTREE (attack);

-- Поиск всех карт с определенным значением здоровья
CREATE INDEX ON Card USING BTREE (health);

-- Поиск всех карт с определенным здоровьем и атакой
CREATE INDEX ON Card USING BTREE (attack, health);
CREATE INDEX ON Card USING BTREE (health, attack);

-- Поиск всех карт определенной стоимости
CREATE INDEX ON Card USING HASH (cost);

-- Поиск всех нейтральных карт
CREATE INDEX ON Card USING HASH (neutral);

-- Поиск всех карт для определенного класса
CREATE INDEX ON CardClass USING HASH (class_id);

-- Поиск всех карт игрока
CREATE INDEX ON CollectionCard USING HASH (player_id);

-- Поиск всех рубашек для карт игрока
CREATE INDEX ON PlayerCardBack USING HASH (player_id);

-- Поиск всех героев в коллекции игрока
CREATE INDEX ON CollectionHero USING HASH (player_id);

-- Поиск всех игроков с определенным ником
CREATE INDEX ON Player USING HASH (username);

