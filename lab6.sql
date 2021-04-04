-- 1. Добавить внешние ключи.
ALTER TABLE dealer ADD FOREIGN KEY (id_company) REFERENCES company(id_company);

ALTER TABLE "order" ADD FOREIGN KEY (id_production) REFERENCES production(id_production);
ALTER TABLE "order" ADD FOREIGN KEY (id_dealer) REFERENCES dealer(id_dealer);
ALTER TABLE "order" ADD FOREIGN KEY (id_pharmacy) REFERENCES pharmacy(id_pharmacy);

ALTER TABLE production ADD FOREIGN KEY (id_company) REFERENCES company(id_company);
ALTER TABLE production ADD FOREIGN KEY (id_medicine) REFERENCES medicine(id_medicine);



-- 2. Выдать информацию по всем заказам лекарства “Кордеон” компании “Аргус” с
-- указанием названий аптек, дат, объема заказов
SELECT
    o.date, o.quantity, m.name, ph.name, c.name
FROM
    "order" o
INNER JOIN dealer d on d.id_dealer = o.id_dealer
INNER JOIN pharmacy ph on ph.id_pharmacy = o.id_pharmacy
INNER JOIN production p on p.id_production = o.id_production
INNER JOIN medicine m on m.id_medicine = p.id_medicine
INNER JOIN company c on c.id_company = d.id_company
WHERE m.name = 'Кордеон' AND d.id_company = 7;



-- 3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы
-- до 25 января.
SELECT
    *
FROM
    medicine m
WHERE m.id_medicine NOT IN
(
    SELECT DISTINCT
        p.id_medicine
    FROM
        "order" o
    INNER JOIN production p on p.id_production = o.id_production
    INNER JOIN company c on c.id_company = p.id_company
    WHERE c.name = 'Фарма' AND o.date < '2019-01-25'
);


-- 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая
-- оформила не менее 120 заказов
SELECT
    c.name, COUNT(c.id_company) as count_of_orders, max(p.rating), min(p.rating)
FROM
    "order" o
INNER JOIN production p on p.id_production = o.id_production
INNER JOIN company c on c.id_company = p.id_company
INNER JOIN medicine m on m.id_medicine = p.id_medicine
GROUP BY c.name
HAVING COUNT(c.id_company) >= 120;



-- 5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”.
-- Если у дилера нет заказов, в названии аптеки проставить NULL
SELECT DISTINCT
    p.name, d.name
FROM "order" o
INNER JOIN pharmacy p on p.id_pharmacy = o.id_pharmacy
INNER JOIN production pr on pr.id_production = o.id_production
RIGHT JOIN dealer d on d.id_dealer = o.id_dealer
WHERE d.id_company = 4;


-- 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а
-- длительность лечения не более 7 дней.
UPDATE
    production  p
SET
    price = 0.8 * price
FROM
    medicine m
WHERE m.cure_duration <= 7 AND p.price <= '3000';


-- 7. Добавить индексы
CREATE UNIQUE INDEX IX_company_name ON company(name);
CREATE UNIQUE INDEX IX_medicine_name ON medicine(name);

CREATE INDEX IX_order_date ON "order"(date);
CREATE INDEX IX_production_price ON production(price);
CREATE INDEX IX_production_rating ON production(rating);

CREATE UNIQUE INDEX IX_pharmacy_name ON pharmacy(name);
CREATE INDEX IX_pharmacy_rating ON pharmacy(rating);
