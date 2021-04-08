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
    number    BIGINT      NOT NULL,
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
CREATE INDEX ON Card USING HASH (type);

-- Поиск всех элитных карт
CREATE INDEX ON Card USING HASH (elite);

-- Поиск всех карт с определенным значнием атаки
CREATE INDEX ON Card USING BTREE (attack);

-- Поиск всех карт с определенным значением здоровья
CREATE INDEX ON Card USING BTREE (health);

-- Поиск всех карт с определенным здоровьем и атакой
CREATE INDEX ON Card USING BTREE (attack, health);

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


-- data.sql --

INSERT INTO CardType (name)
VALUES ('Minion'),
       ('Spell'),
       ('Weapon');

INSERT INTO CardRarity (name)
VALUES ('Common'),
       ('Free'),
       ('Rare'),
       ('Epic'),
       ('Legendary');

INSERT INTO CardBack(name, description)
VALUES ('Classic', 'The only card back you''ll ever need.'),
       ('Legend', 'Wow. Hardcore. Acquired from achieving Legend Rank in Ranked Play.'),
       ('Winter Veil Wreath',
        'A beautiful Winter Veil wreath around a snow globe full of THE FROSTY DESTRUCTION OF YOUR OPPONENTS! I Mean... good cheer. Acquired from Winter Veil 2015-2017 or when available in the shop.'),
       ('Mark of Hakkar',
        'Look out! This card back''s gone viral! Acquired by encountering another player with the Mark of Hakkar card back in any play mode.');

INSERT INTO Player(username, password, fav_card_back_id, email)
VALUES ('Chester', 'b794385f2d1ef7ab4d9273d1906381b44f2f6f2588a3efb96a49188331984753', 1, 'komaroff404@gmail.com'),
       ('Forsen', '67f544ece9af8743cecd07cba03ffeada3ae43f1f6aa277ac41abea18ec491d6', 1, 'forsen@gmail.com'),
       ('Thijs', '81285d02f41c3f0d10ffae5cbb267fef28ba14c0ec528d68983e42aae8a3b1cc', 1, 'thijs@gmail.com');

BEGIN;
INSERT INTO Class(name, hero_id)
VALUES ('Druid', 1),
       ('Hunter', 2),
       ('Mage', 3),
       ('Paladin', 4),
       ('Priest', 5),
       ('Rogue', 6),
       ('Shaman', 7),
       ('Warlock', 8),
       ('Warrior', 9);

INSERT INTO Hero(name, class_id, description)
VALUES ('Malfurion Stormage', 1,
        'The lord of the night elves is a wise and noble leader. Yes, those antlers are real.'),
       ('Rexxar', 2, 'He only feels at home in the wilderness with his beasts. Super secret: Misha is his favorite.'),
       ('Jaina Proudmoore', 3,
        'The Kirin Tor''s leader is a powerful sorceress. She used to be a lot nicer before the Theramore thing.'),
       ('Uther Lightbringer', 4,
        'Leader of the Knights of the Silver Hand. Best-selling author of The Light and How to Swing It.'),
       ('Anduin Wrynn', 5, 'The future King of Stormwind is a kind, gentle soul. Except when he''s in Shadowform.'),
       ('Valeera Sanguinar', 6,
        'Expert assassin. Deadly gladiator. Best knife skills in her cooking class, according to survivors.'),
       ('Thrall', 7, 'Thrall quit his former job as Warchief to save the world and spend more time with his family.'),
       ('Gul''dan', 8, 'Talented, persuasive and hard-working. Too bad he wants to feed your soul to demons.'),
       ('Garrosh Hellscream', 9, 'This former Warchief of the Horde isn''t bitter about being deposed. Not at all.'),
       ('Lunara', 1,
        'The first daughter of Cenarius: fierce defender of nature and natural hair-care products. Obtained during the launch of the Year of the Raven'),
       ('Alleria Windrunner', 2,
        'The high elf Ranger Captain is a peerless archer. Ask any of the orcs she used for target practice.'),
       ('Medivh', 3, 'The Guardian of Titisfal is a force for good. Demonic possession is a manageable condition'),
       ('Lady Liadrin', 4,
        'Since the resoration of the Sunwell, the Blood Lnight Matriarch''s mood seems, well, sunnier! Obtained by reaching level 20 on a new character in World of Warcraft.'),
       ('Tyrande Whisperwind', 5,
        'Unlike some people, this leader didn''t fall asleep on the job. We''re looking at you, Malfurion. Obtained from a special promotion.'),
       ('Maiev Shadowsong', 6,
        'Dedicated to rooting out demonic corruption, Maiev once jailed Illidan for ten thousand years. And that was just his first offense. Obtained during the launch of the Year of the Mammoth.'),
       ('Morgle the Oracle', 7, 'Mrrgl mrrgl mrrrrrrrrgl. Mrrrrrrgl! Mrgl? Obtained by recruiting a friend.'),
       ('Nemsy Necrofizzle', 8, 'Siphoning souls with a smile! Obtained from participating in Fireside Gatherings.'),
       ('Magni Bronzebeard', 9,
        'Lord of Ironforge. King of Khaz Modan. Grand Explorer. Moira''s Dad. Huggable Leader.');
COMMIT;

INSERT INTO CollectionHero(player_id, hero_id)
VALUES (1, 1),
       (1, 2),
       (1, 3),
       (1, 4),
       (1, 5),
       (1, 6),
       (1, 7),
       (1, 8),
       (1, 9),
       (1, 12),
       (1, 13),
       (1, 15),
       (1, 16),
       (2, 1),
       (2, 2),
       (2, 3),
       (2, 4),
       (2, 5),
       (2, 6),
       (2, 7),
       (2, 8),
       (2, 9),
       (3, 1),
       (3, 2),
       (3, 3),
       (3, 4),
       (3, 5),
       (3, 6),
       (3, 7),
       (3, 8),
       (3, 9),
       (3, 10),
       (3, 11),
       (3, 12),
       (3, 13),
       (3, 14),
       (3, 15),
       (3, 16),
       (3, 17),
       (3, 18);

INSERT INTO FavoriteHero(player_id, class_id, fav_hero_id)
VALUES (1, 1, 1),
       (1, 2, 2),
       (1, 3, 12),
       (1, 4, 13),
       (1, 5, 5),
       (1, 6, 15),
       (1, 7, 16),
       (1, 8, 8),
       (1, 9, 9),
       (2, 1, 1),
       (2, 2, 2),
       (2, 3, 3),
       (2, 4, 4),
       (2, 5, 5),
       (2, 6, 6),
       (2, 7, 7),
       (2, 8, 8),
       (2, 9, 9),
       (3, 1, 10),
       (3, 2, 11),
       (3, 3, 12),
       (3, 4, 13),
       (3, 5, 14),
       (3, 6, 15),
       (3, 7, 16),
       (3, 8, 17),
       (3, 9, 18);

INSERT INTO PlayerCardBack(player_id, card_back_id)
VALUES (1, 1),
       (1, 2),
       (2, 1),
       (3, 1),
       (3, 2),
       (3, 3),
       (3, 4);

INSERT INTO Deck(number, name, class_id, player_id)
VALUES (1, 'Face Hunter', 2, 1),
       (1, 'To Legend', 3, 2),
       (1, 'Blizzcon2013', 2, 3),
       (2, 'Control Warrior', 9, 3);

INSERT INTO Card(name, neutral, type, cost, rarity, elite, attack, health, description)
VALUES ('Timber Wolf', FALSE, 1, 1, 2, FALSE, 1, 1, 'Your other Beasts have +1 Attack.'),
       ('Houndmaster', FALSE, 1, 4, 2, FALSE, 4, 3, 'Battlecry: Give a friendly Beast +2/+2 and Taunt.'),
       ('Starving Buzzard', FALSE, 1, 5, 2, FALSE, 3, 2, 'Whenever you summon a Beast, draw a card.'),
       ('Tundra Rhino', FALSE, 1, 5, 2, FALSE, 2, 5, 'Your Beasts have Charge.'),
       ('Arcane Shot', FALSE, 2, 1, 2, FALSE, NULL, NULL, 'Deal 2 damage.'),
       ('Tracking', FALSE, 2, 1, 2, FALSE, NULL, NULL,
        'Look at the top 3 cards of your deck. Draw one and discard the others.'),
       ('Hunter''s Mark', FALSE, 2, 2, 2, FALSE, NULL, NULL, 'Change a minion''s Health to 1.'),
       ('Animal Companion', FALSE, 2, 3, 2, FALSE, NULL, NULL, 'Summon a random Beast Companion.'),
       ('Kill Command', FALSE, 2, 3, 2, FALSE, NULL, NULL,
        'Deal 3 damage. If you control a Beast, deal 5 damage instead.'),
       ('Multi-Shot', FALSE, 2, 4, 2, FALSE, NULL, NULL, 'Deal 3 damage to two random enemy minions.'),
       ('Water Elemental', FALSE, 1, 4, 2, FALSE, 3, 6, 'Freeze any character damaged by this minion.'),
       ('Arcane Missiles', FALSE, 2, 1, 2, FALSE, NULL, NULL, 'Deal 3 damage randomly split among all enemies.'),
       ('Mirror Image', FALSE, 2, 0, 2, FALSE, NULL, NULL, 'Summon two 0/2 minions with Taunt.'),
       ('Arcane Explosion', FALSE, 2, 2, 2, FALSE, NULL, NULL, 'Deal 1 damage to all enemy minions.'),
       ('Frostbolt', FALSE, 2, 2, 2, FALSE, NULL, NULL, 'Deal 3 damage to a character and Freeze it.'),
       ('Arcane Intellect', FALSE, 2, 3, 2, FALSE, NULL, NULL, 'Draw 2 cards.'),
       ('Frost Nova', FALSE, 2, 3, 2, FALSE, NULL, NULL, 'Freeze all enemy minions.'),
       ('Fireball', FALSE, 2, 4, 2, FALSE, NULL, NULL, 'Deal 6 damage.'),
       ('Polymorph', FALSE, 2, 4, 2, FALSE, NULL, NULL, 'Transform a minion into a 1/1 Sheep.'),
       ('Flamestrike', FALSE, 2, 7, 2, FALSE, NULL, NULL, 'Deal 4 damage to all enemy minions.'),
       ('Charge', FALSE, 2, 1, 2, FALSE, NULL, NULL,
        'Give a friendly minion Charge. It can''t attack heroes this turn.'),
       ('Whirlwind', FALSE, 2, 1, 2, FALSE, NULL, NULL, 'Deal 1 damage to ALL minions.'),
       ('Cleave', FALSE, 2, 2, 2, FALSE, NULL, NULL, 'Deal 2 damage to two random enemy minions.'),
       ('Execute', FALSE, 2, 1, 2, FALSE, NULL, NULL, 'Destroy a damaged enemy minion.'),
       ('Heroic Strike', FALSE, 2, 2, 2, FALSE, NULL, NULL, 'Give your hero +4 Attack this turn.'),
       ('Shield Block', FALSE, 2, 3, 2, FALSE, NULL, NULL, 'Gain 5 Armor. Draw a card.'),
       ('Warsong Commander', FALSE, 1, 3, 2, FALSE, 2, 3, 'Your Charge minions have +1 Attack.'),
       ('Kor''kron Elite', FALSE, 1, 4, 2, FALSE, 4, 3, 'Charge'),
       ('Fiery War Axe', FALSE, 3, 3, 2, FALSE, 3, 2, NULL),
       ('Arcanite Reaper', FALSE, 3, 5, 2, FALSE, 5, 2, NULL),
       ('Freezing Trap', FALSE, 2, 2, 1, FALSE, NULL, NULL,
        'Secret: When an enemy minion attacks, return it to its owner''s hand. It costs (2) more.'),
       ('Scavenging Hyena', FALSE, 1, 2, 1, FALSE, 2, 2, 'Whenever a friendly Beast dies, gain +2/+1.'),
       ('Eaglehorn Bow', FALSE, 3, 3, 3, FALSE, 3, 2, 'Whenever a friendly Secret is revealed, gain +1 Durability.'),
       ('Snake Trap', FALSE, 2, 2, 4, FALSE, NULL, NULL,
        'Secret: When one of your minions is attacked, summon three 1/1 Snakes.'),
       ('King Krush', FALSE, 1, 9, 5, TRUE, 8, 8, 'Charge'),
       ('Mana Wyrm', FALSE, 1, 1, 1, FALSE, 1, 3, 'Whenever you cast a spell, gain +1 Attack.'),
       ('Sorcerer''s Apprentice', FALSE, 1, 2, 1, FALSE, 3, 2, 'Your spells cost (1) less.'),
       ('Blizzard', FALSE, 2, 6, 3, FALSE, NULL, NULL, 'Deal 2 damage to all enemy minions and Freeze them.'),
       ('Pyroblast', FALSE, 2, 10, 4, FALSE, NULL, NULL, 'Deal 10 damage.'),
       ('Archmage Antonidas', FALSE, 1, 7, 5, TRUE, 5, 7,
        'Whenever you cast a spell, add a ''Fireball'' spell to your hand.'),
       ('Inner Rage', FALSE, 2, 0, 1, FALSE, NULL, NULL, 'Deal 1 damage to a minion and give it +2 Attack.'),
       ('Slam', FALSE, 2, 2, 1, FALSE, NULL, NULL, 'Deal 2 damage to a minion. If it survives, draw a card.'),
       ('Frothing Berserker', FALSE, 1, 3, 3, FALSE, 2, 4, 'Whenever a minion takes damage, gain +1 Attack.'),
       ('Brawl', FALSE, 2, 5, 4, FALSE, NULL, NULL, 'Destroy all minions except one. (chosen randomly)'),
       ('Grommash Hellscream', FALSE, 1, 8, 5, TRUE, 4, 9, 'Charge Has +6 Attack while damaged.'),
       ('Wisp', TRUE, 1, 0, 1, FALSE, 1, 1, NULL),
       ('Leper Gnome', TRUE, 1, 1, 1, FALSE, 1, 1, 'Deathrattle: Deal 2 damage to the enemy hero.'),
       ('Acidic Swamp Ooze', TRUE, 1, 2, 2, FALSE, 3, 2, 'Battlecry: Destroy your opponent''s weapon.'),
       ('Novice Engineer', TRUE, 1, 2, 2, FALSE, 1, 1, 'Battlecry: Draw a card.'),
       ('Bloodmage Thalnos', TRUE, 1, 2, 5, TRUE, 1, 1, 'Spell Damage +1 Deathrattle: Draw a card.'),
       ('Doomsayer', TRUE, 1, 2, 4, FALSE, 0, 7, 'At the start of your turn, destroy ALL minions.'),
       ('Knife Juggler', TRUE, 1, 2, 3, FALSE, 3, 2, 'After you summon a minion, deal 1 damage to a random enemy.'),
       ('Loot Hoarder', TRUE, 1, 2, 1, FALSE, 2, 1, 'Deathrattle: Draw a card.'),
       ('Lorewalker Cho', TRUE, 1, 2, 5, TRUE, 0, 4,
        'Whenever a player casts a spell, put a copy into the other player’s hand.'),
       ('Nat Pagle', TRUE, 1, 2, 5, TRUE, 0, 4,
        'At the start of your turn, you have a 50% chance to draw an extra card.'),
       ('Youthful Brewmaster', TRUE, 1, 2, 1, FALSE, 3, 2,
        'Battlecry: Return a friendly minion from the battlefield to your hand.'),
       ('Ironfur Grizzly', TRUE, 1, 2, 1, FALSE, 3, 2, NULL),
       ('Razorfen Hunter', TRUE, 1, 3, 2, FALSE, 2, 3, 'Battlecry: Summon a 1/1 Boar.'),
       ('Shattered Sun Cleric', TRUE, 1, 3, 2, FALSE, 3, 2, 'Battlecry: Give a friendly minion +1/+1.'),
       ('Silverback Patriarch', TRUE, 1, 3, 2, FALSE, 1, 4, 'Taunt'),
       ('Wolfrider', TRUE, 1, 3, 2, FALSE, 3, 1, 'Charge'),
       ('Ironbeak Owl', TRUE, 1, 2, 1, FALSE, 2, 1, 'Battlecry: Silence a minion.'),
       ('Tinkmaster Overspark', TRUE, 1, 3, 5, TRUE, 3, 3,
        'Battlecry: Transform another random minion into a 5/5 Devilsaur or a 1/1 Squirrel.'),
       ('Chillwind Yeti', TRUE, 1, 4, 2, FALSE, 4, 5, NULL),
       ('Sen''jin Shieldmasta', TRUE, 1, 4, 2, FALSE, 3, 5, 'Taunt'),
       ('Defender of Argus', TRUE, 1, 4, 3, FALSE, 2, 3, 'Battlecry: Give adjacent minions +1/+1 and Taunt.'),
       ('Big Game Hunter', TRUE, 1, 3, 4, FALSE, 4, 2, 'Battlecry: Destroy a minion with 7 or more Attack.'),
       ('Stranglethorn Tiger', TRUE, 1, 5, 1, FALSE, 5, 5, 'Stealth'),
       ('Boulderfist Ogre', TRUE, 1, 6, 2, FALSE, 6, 7, NULL),
       ('Cairne Bloodhoof', TRUE, 1, 6, 5, TRUE, 4, 5, 'Deathrattle: Summon a 4/5 Baine Bloodhoof.'),
       ('Hogger', TRUE, 1, 6, 5, TRUE, 4, 4, 'At the end of your turn, summon a 2/2 Gnoll with Taunt.'),
       ('The Black Knight', TRUE, 1, 6, 5, TRUE, 4, 5, 'Battlecry: Destroy an enemy minion with Taunt.'),
       ('Baron Geddon', TRUE, 1, 7, 5, TRUE, 7, 5, 'At the end of your turn, deal 2 damage to ALL other characters.'),
       ('Stormwind Champion', TRUE, 1, 7, 2, FALSE, 6, 6, 'Your other minions have +1/+1.'),
       ('War Golem', TRUE, 1, 7, 2, FALSE, 7, 7, NULL),
       ('Gruul', TRUE, 1, 8, 5, TRUE, 7, 7, 'At the end of each turn, gain +1/+1 .'),
       ('Alexstrasza', TRUE, 1, 9, 5, TRUE, 8, 8, 'Battlecry: Set a hero''s remaining Health to 15.'),
       ('Deathwing', TRUE, 1, 10, 5, TRUE, 12, 12, 'Battlecry: Destroy all other minions and discard your hand.'),
       ('Sunwalker', TRUE, 1, 6, 3, FALSE, 4, 5, 'Taunt Divine Shield'),
       ('Priestess of Elune', TRUE, 1, 6, 1, FALSE, 5, 4, 'Battlecry: Restore 4 Health to your hero.'),
       ('Violet Teacher', TRUE, 1, 4, 3, FALSE, 3, 5, 'Whenever you cast a spell, summon a 1/1 Violet Apprentice.'),
       ('Silvermoon Guardian', TRUE, 1, 4, 1, FALSE, 3, 3, 'Divine Shield'),
       ('Dark Iron Dwarf', TRUE, 1, 4, 1, FALSE, 4, 4, 'Battlecry: Give a minion +2 Attack this turn.'),
       ('Gnomish Inventor', TRUE, 1, 4, 2, FALSE, 2, 4, 'Battlecry: Draw a card.'),
       ('Thrallmar Farseer', TRUE, 1, 3, 1, FALSE, 2, 3, 'Windfury'),
       ('Tauren Warrior', TRUE, 1, 3, 1, FALSE, 2, 3, 'Taunt Has +3 Attack while damaged.'),
       ('Earthen Ring Farseer', TRUE, 1, 3, 1, FALSE, 3, 3, 'Battlecry: Restore 3 Health.'),
       ('Wild Pyromancer', TRUE, 1, 2, 3, FALSE, 3, 2, 'After you cast a spell, deal 1 damage to ALL minions.'),
       ('Young Dragonhawk', TRUE, 1, 1, 2, FALSE, 1, 1, 'Windfury'),
       ('Argent Squire', TRUE, 1, 1, 1, FALSE, 1, 1, NULL);


INSERT INTO CardClass(card_id, class_id)
VALUES (1, 2),
       (2, 2),
       (3, 2),
       (4, 2),
       (5, 2),
       (6, 2),
       (7, 2),
       (8, 2),
       (9, 2),
       (10, 2),
       (11, 3),
       (12, 3),
       (13, 3),
       (14, 3),
       (15, 3),
       (16, 3),
       (17, 3),
       (18, 3),
       (19, 3),
       (20, 3),
       (21, 9),
       (22, 9),
       (23, 9),
       (24, 9),
       (25, 9),
       (26, 9),
       (27, 9),
       (28, 9),
       (29, 9),
       (30, 9),
       (31, 2),
       (32, 2),
       (33, 2),
       (34, 2),
       (35, 2),
       (36, 3),
       (37, 3),
       (38, 3),
       (39, 3),
       (40, 3),
       (41, 9),
       (42, 9),
       (43, 9),
       (44, 9),
       (45, 9);


INSERT INTO CollectionCard(player_id, card_id, quantity)
VALUES (2, 1, 2),
       (2, 2, 2),
       (2, 3, 2),
       (2, 4, 2),
       (2, 5, 2),
       (2, 6, 2),
       (2, 7, 2),
       (2, 8, 2),
       (2, 9, 2),
       (2, 10, 2),
       (2, 11, 2),
       (2, 12, 2),
       (2, 13, 2),
       (2, 14, 2),
       (2, 15, 2),
       (2, 16, 2),
       (2, 17, 2),
       (2, 18, 2),
       (2, 19, 2),
       (2, 20, 2),
       (2, 21, 2),
       (2, 22, 2),
       (2, 23, 2),
       (2, 24, 2),
       (2, 25, 2),
       (2, 26, 2),
       (2, 27, 2),
       (2, 28, 2),
       (2, 29, 2),
       (2, 30, 2),
       (2, 31, 2),
       (2, 32, 2),
       (2, 33, 2),
       (2, 34, 2),
       (2, 35, 2),
       (2, 36, 2),
       (2, 37, 2),
       (2, 38, 2),
       (2, 39, 2),
       (2, 40, 2),
       (2, 41, 2),
       (2, 42, 2),
       (2, 43, 2),
       (2, 44, 2),
       (2, 45, 2),
       (3, 1, 2),
       (3, 2, 2),
       (3, 3, 2),
       (3, 4, 2),
       (3, 5, 2),
       (3, 6, 2),
       (3, 7, 2),
       (3, 8, 2),
       (3, 9, 2),
       (3, 10, 2),
       (3, 11, 2),
       (3, 12, 2),
       (3, 13, 2),
       (3, 14, 2),
       (3, 15, 2),
       (3, 16, 2),
       (3, 17, 2),
       (3, 18, 2),
       (3, 19, 2),
       (3, 20, 2),
       (3, 21, 2),
       (3, 22, 2),
       (3, 23, 2),
       (3, 24, 2),
       (3, 25, 2),
       (3, 26, 2),
       (3, 27, 2),
       (3, 28, 2),
       (3, 29, 2),
       (3, 30, 2),
       (3, 31, 2),
       (3, 32, 2),
       (3, 33, 2),
       (3, 34, 2),
       (3, 35, 2),
       (3, 36, 2),
       (3, 37, 2),
       (3, 38, 2),
       (3, 39, 2),
       (3, 40, 2),
       (3, 41, 2),
       (3, 42, 2),
       (3, 43, 2),
       (3, 44, 2),
       (3, 45, 2),
       (3, 46, 2),
       (3, 47, 2),
       (3, 48, 2),
       (3, 49, 2),
       (3, 50, 2),
       (3, 51, 2),
       (3, 52, 2),
       (3, 53, 2),
       (3, 54, 2),
       (3, 55, 2),
       (3, 56, 2),
       (3, 57, 2),
       (3, 58, 2),
       (3, 59, 2),
       (3, 60, 2),
       (3, 61, 2),
       (3, 62, 2),
       (3, 63, 2),
       (3, 64, 2),
       (3, 65, 2),
       (3, 66, 2),
       (3, 67, 2),
       (3, 68, 2),
       (3, 69, 2),
       (3, 70, 2),
       (3, 71, 2),
       (3, 72, 2),
       (3, 73, 2),
       (3, 74, 2),
       (3, 75, 2),
       (3, 76, 2),
       (3, 77, 2),
       (3, 78, 2),
       (3, 79, 2),
       (3, 80, 2),
       (3, 81, 2),
       (3, 82, 2),
       (3, 83, 2),
       (3, 84, 2),
       (3, 85, 2),
       (3, 86, 2),
       (3, 87, 2),
       (3, 88, 2),
       (3, 89, 2),
       (3, 90, 2),
       (1, 1, 1),
       (1, 2, 2),
       (1, 5, 2),
       (1, 6, 2),
       (1, 7, 1),
       (1, 8, 1),
       (1, 9, 2),
       (1, 10, 1),
       (1, 11, 2),
       (1, 17, 2),
       (1, 18, 1),
       (1, 19, 2),
       (1, 20, 1),
       (1, 21, 2),
       (1, 22, 2),
       (1, 25, 42),
       (1, 26, 2),
       (1, 27, 1),
       (1, 28, 2),
       (1, 29, 2),
       (1, 30, 1),
       (1, 31, 2),
       (1, 34, 322),
       (1, 35, 2),
       (1, 36, 2),
       (1, 37, 2),
       (1, 38, 1),
       (1, 39, 2),
       (1, 40, 1),
       (1, 41, 2),
       (1, 44, 2),
       (1, 45, 2),
       (1, 46, 1),
       (1, 47, 2),
       (1, 48, 2),
       (1, 49, 1),
       (1, 50, 2),
       (1, 54, 69),
       (1, 55, 1),
       (1, 56, 2),
       (1, 57, 1),
       (1, 58, 7),
       (1, 61, 1),
       (1, 62, 2),
       (1, 63, 1),
       (1, 65, 1),
       (1, 66, 1),
       (1, 67, 3),
       (1, 71, 2),
       (1, 72, 1),
       (1, 73, 1337),
       (1, 74, 11),
       (1, 80, 1),
       (1, 81, 228),
       (1, 82, 1),
       (1, 83, 2),
       (1, 84, 1),
       (1, 85, 2),
       (1, 86, 2),
       (1, 87, 1);

INSERT INTO CardInDeck(deck_no, player_id, card_id, amount)
VALUES (1, 1, 1, 1),
       (1, 1, 2, 2),
       (1, 1, 5, 2),
       (1, 1, 6, 2),
       (1, 1, 7, 1),
       (1, 1, 8, 1),
       (1, 1, 9, 2),
       (1, 1, 10, 1),
       (1, 1, 31, 2),
       (1, 1, 34, 2),
       (1, 1, 35, 2),
       (1, 1, 46, 1),
       (1, 1, 47, 2),
       (1, 1, 48, 2),
       (1, 1, 49, 1),
       (1, 1, 54, 2),
       (1, 1, 55, 1),
       (1, 1, 56, 2),
       (1, 1, 57, 1),

       (1, 2, 11, 2),
       (1, 2, 12, 2),
       (1, 2, 13, 2),
       (1, 2, 14, 2),
       (1, 2, 15, 2),
       (1, 2, 16, 2),
       (1, 2, 17, 2),
       (1, 2, 18, 2),
       (1, 2, 19, 2),
       (1, 2, 20, 2),
       (1, 2, 36, 2),
       (1, 2, 37, 2),
       (1, 2, 38, 2),
       (1, 2, 39, 2),
       (1, 2, 40, 2),

       (1, 3, 1, 2),
       (1, 3, 2, 2),
       (1, 3, 3, 2),
       (1, 3, 4, 2),
       (1, 3, 5, 2),
       (1, 3, 6, 2),
       (1, 3, 7, 2),
       (1, 3, 8, 2),
       (1, 3, 9, 2),
       (1, 3, 10, 2),
       (1, 3, 31, 2),
       (1, 3, 32, 2),
       (1, 3, 33, 2),
       (1, 3, 34, 2),
       (1, 3, 35, 2),

       (2, 3, 21, 2),
       (2, 3, 22, 2),
       (2, 3, 23, 2),
       (2, 3, 24, 2),
       (2, 3, 25, 2),
       (2, 3, 26, 2),
       (2, 3, 27, 2),
       (2, 3, 28, 2),
       (2, 3, 29, 2),
       (2, 3, 30, 2),
       (2, 3, 41, 2),
       (2, 3, 42, 2),
       (2, 3, 43, 2),
       (2, 3, 44, 2),
       (2, 3, 45, 2);


-- selects --

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


-- updates --

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


-- EXAM --

SELECT C.name AS card_name, CC.quantity
FROM CollectionCard CC
         JOIN Card C on CC.card_id = C.id
         JOIN Player P on CC.player_id = P.id
WHERE P.id = 1
ORDER BY CC.quantity DESC
LIMIT 10;

SELECT C.name AS card_name
FROM Card C
         JOIN CollectionCard CC on C.id = CC.card_id
WHERE CC.player_id = 3
  AND C.type = 3
  AND C.rarity NOT IN (SELECT CR.id from CardRarity CR WHERE CR.name != 'Free')
  AND C.id NOT IN (SELECT card_id
                   FROM CardInDeck CD
                            JOIN Player P on CD.player_id = P.id
                   WHERE CD.player_id = P.id);



SELECT C.name as card_name, count(C.name) as card_count
FROM CardInDeck CD
         JOIN Card C on CD.card_id = C.id
WHERE C.rarity IN (SELECT CR.id from CardRarity CR WHERE CR.name = 'Legendary')
GROUP BY C.name
ORDER BY card_count DESC
LIMIT 1;

--


UPDATE CollectionCard
SET quantity = quantity - 1
WHERE player_id = 1
  AND card_id IN (SELECT id from Card C WHERE C.name = 'Fireball')
  AND quantity > 1;



UPDATE CardInDeck
SET amount = amount - 1
WHERE player_id = 1
  AND card_id IN (SELECT id from Card C WHERE C.name = 'cardName')
  AND deck_no = 1
  AND amount > 1;