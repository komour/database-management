### Домашнее задание 7. Изменение данных

Будем считать, что у студента долг по предмету, если он изучает этот предмет и имеет по нему менее 60 баллов.

1. Напишите запросы, удаляющие:
   1. Студентов, не имеющих долгов;
   2. Студентов, имеющих 3 и более долгов;
   3. Группы, в которых нет студентов.
2. Работа с должниками
   1. Создайте представление `Losers` в котором для каждого студента, имеющего долги указано их количество;
   2. Создайте таблицу `LoserT`, в которой содержится та же информация, что в представлении `Losers`. Эта таблица должна автоматически обновляться при изменении таблицы с баллами;
   3. Отключите автоматическое обновление `LoserT`;
   4. Напишите запрос (один), которой обновляет таблицу `LoserT`, используя данные из таблицы `NewPoints`, в которой содержится информация о баллах, проставленных за последний день.
3. Целостность данных
   1. Добавьте проверку того, что все студенты одной группы изучают один и тот же набор курсов;
   2. Создайте триггер, не позволяющий уменьшить баллы студента по предмету. При попытке такого изменения баллы изменяться не должны.