-- 1. Добавить внешние ключи.
ALTER TABLE room_in_booking ADD FOREIGN KEY (id_booking) REFERENCES booking(id_booking);
ALTER TABLE room_in_booking ADD FOREIGN KEY (id_room) REFERENCES room(id_room);

ALTER TABLE room ADD FOREIGN KEY (id_hotel) REFERENCES hotel(id_hotel);
ALTER TABLE room ADD FOREIGN KEY (id_room_category) REFERENCES room_category(id_room_category);

ALTER TABLE booking ADD FOREIGN KEY (id_client) REFERENCES client(id_client);


-- 2. Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах категории “Люкс” на 1 апреля 2019г
SELECT
    c.*
FROM
    client c
INNER JOIN booking b ON c.id_client = b.id_client
INNER JOIN room_in_booking rib ON b.id_booking = rib.id_booking
INNER JOIN room r ON r.id_room = rib.id_room
WHERE id_hotel = 1 AND id_room_category = 5 AND checkin_date < '2019-04-01' AND checkout_date > '2019-04-01';


-- 3.Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT
    r.*
FROM
    room r
WHERE r.id_room NOT IN
(
    SELECT
        room_in_booking.id_room
    FROM
        room_in_booking
    WHERE checkin_date <= '2019-04-22' AND checkout_date > '2019-04-22'
);


-- 4. Дать количество проживающих в гостинице “Космос” на 23 марта по каждой категории номеров
SELECT
    id_room_category, COUNT(rib.id_room)
FROM
    room
INNER JOIN room_in_booking rib ON room.id_room = rib.id_room
INNER JOIN hotel h ON h.id_hotel = room.id_hotel
WHERE
    h.id_hotel = 1 AND checkin_date <= '2019-03-23' AND checkout_date > '2019-03-23'
GROUP BY
    id_room_category
ORDER BY
    id_room_category;



-- 5. Дать список последних проживавших клиентов по всем комнатам гостиницы
-- “Космос”, выехавшим в апреле с указанием даты выезда.
SELECT
    c.*, checkout_date
FROM
    room
INNER JOIN room_in_booking rib ON room.id_room = rib.id_room
INNER JOIN hotel h ON h.id_hotel = room.id_hotel
INNER JOIN booking b on b.id_booking = rib.id_booking
INNER JOIN client c on c.id_client = b.id_client
WHERE
    h.id_hotel = 1 AND '2019-04-1' < checkout_date AND checkout_date < '2019-04-30'
ORDER BY
    checkout_date DESC;
-- TODO по каждому номеру в отеле сгрупировать и вывести последенего кто выехал в опр дату



-- 6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам
-- комнат категории “Бизнес”, которые заселились 10 мая.
UPDATE
    room_in_booking
SET
    checkout_date = (checkout_date + integer '2')
WHERE id_room IN (
    SELECT
        r.id_room
    FROM
        room r
    INNER JOIN hotel h on h.id_hotel = r.id_hotel
    INNER JOIN room_category rc on rc.id_room_category = r.id_room_category
    WHERE
        h.id_hotel = 1 AND rc.id_room_category = 3
) AND checkin_date = '2019-05-10';

SELECT rib.*
FROM room_in_booking rib
INNER JOIN room r on r.id_room = rib.id_room
INNER JOIN hotel h on h.id_hotel = r.id_hotel
INNER JOIN room_category rc on rc.id_room_category = r.id_room_category
WHERE
    h.id_hotel = 1 AND rc.id_room_category = 3 AND checkin_date = '2019-05-10';



-- 7. Найти все "пересекающиеся" варианты проживания. Правильное состояние: не
-- может быть забронирован один номер на одну дату несколько раз, т.к. нельзя
-- заселиться нескольким клиентам в один номер. Записи в таблице
-- room_in_booking с id_room_in_booking = 5 и 2154 являются примером
-- неправильного состояния, которые необходимо найти. Результирующий кортеж
-- выборки должен содержать информацию о двух конфликтующих номерах.
SELECT
    *
FROM
    room_in_booking rib1
INNER JOIN
    room_in_booking rib2
ON
    rib1.id_room = rib2.id_room AND rib1.id_booking != rib2.id_booking AND
    NOT (rib1.checkin_date >= rib2.checkout_date OR rib1.checkout_date < rib2.checkout_date)
;

-- 8. Создать транзакцию.

-- Get Max ID from table
SELECT setval('booking_id_booking_seq', (SELECT MAX(id_booking) FROM room_in_booking));
SELECT setval('room_in_booking_id_room_in_booking_seq', (SELECT MAX(id_room_in_booking) FROM room_in_booking));

BEGIN;
    INSERT INTO
        booking AS b (id_client, booking_date)
    VALUES (1, '2020-07-10');

    INSERT INTO
        room_in_booking (ID_BOOKING, ID_ROOM, CHECKIN_DATE, CHECKOUT_DATE)
    VALUES (currval('booking_id_booking_seq'::regclass), 100, '2020-07-10', '2021-07-20');
COMMIT;



-- 9. Добавить необходимые индексы для всех таблиц.
-- перепроверить индексы
CREATE UNIQUE INDEX IX_hotel_name ON hotel (name);
CREATE UNIQUE INDEX IX_room_category_name ON room_category (name);
CREATE INDEX IX_room_in_booking_checkin_date_checkout_date ON room_in_booking (checkin_date, checkout_date);
CREATE INDEX IX_room_price ON room (price);
CREATE INDEX IX_booking_booking_date ON booking (booking_date);

