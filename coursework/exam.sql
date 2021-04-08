-- топ 10 карт по количеству в колоде первого чувака
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
  AND C.type = 3;

-- все не базовые или базовые оружия война
SELECT C.name AS card_name
FROM Card C
         JOIN CollectionCard CC on C.id = CC.card_id
WHERE CC.player_id = 3
  AND C.type = 3
  AND C.rarity IN (SELECT CR.id from CardRarity CR WHERE CR.name != 'Free');

-- все не базовые или базовые оружия война в колоде 3 чувака
SELECT C.name AS card_name
FROM Card C
         JOIN CollectionCard CC on C.id = CC.card_id
WHERE CC.player_id = 3
  AND C.type = 3
  AND C.rarity NOT IN (SELECT CR.id from CardRarity CR WHERE CR.name != 'Free')
  AND C.id IN (SELECT card_id
                   FROM CardInDeck CD
                            JOIN Player P on CD.player_id = P.id
                   WHERE CD.player_id = P.id);


-- легендарная карта которая встречается чаще всего в колодах
SELECT C.name as card_name, count(C.name) as card_count
FROM CardInDeck CD
         JOIN Card C on CD.card_id = C.id
WHERE C.rarity IN (SELECT CR.id from CardRarity CR WHERE CR.name = 'Legendary')
GROUP BY C.name
ORDER BY card_count DESC
LIMIT 1;