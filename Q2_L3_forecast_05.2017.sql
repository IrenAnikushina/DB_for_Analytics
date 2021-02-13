/* В качестве ДЗ делам прогноз ТО на 05.2017. В качестве метода прогноза - считаем сколько денег тратят группы клиентов в день:
1. Группа часто покупающих (3 и более покупок) и которые последний раз покупали не так давно. Считаем сколько денег оформленного заказа приходится на 1 день. 
Умножаем на 30.
2. Группа часто покупающих, но которые не покупали уже значительное время. Так же можем сделать вывод, из такой группы за след месяц сколько купят и на какую сумму. 
(постараться продумать логику)
3. Отдельно разобрать пользователей с 1 и 2 покупками за все время, прогнозируем их.
4. В итоге у вас будет прогноз ТО и вы сможете его сравнить с фактом и оценить грубо разлет по данным.
Как источник данных используем данные по продажам за 2 года.*/

-- 1. Группа часто покупающих (3 и более покупок) и которые последний раз покупали не так давно. 
-- Считаем сколько денег оформленного заказа приходится на 1 день. Умножаем на 30.
-- -- выборка id и стоимость за день по пользователям, которые соответствуют условию
CREATE TEMPORARY TABLE IF NOT EXISTS forecast_2017_05 AS 
(
	SELECT user_id, sum(price)/(timestampdiff(DAY, min(new_o_date), date('2017-05-01'))) * 31 AS forecast
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2017-05-01')
	GROUP BY user_id
	HAVING count(id_o) > 2 -- пользователи, у которых 3+ покупок, 
	AND (timestampdiff(DAY, max(new_o_date), date('2017-05-01'))) <= 60 -- последний заказ не более 60 дней назад
)
-- ---------------------
-- эта выборка показывает факт оборот за май 2017 по тем пользователям, которые попали в прогнозную выборку по условиям задания
-- -- итог 50641804.4999995
SELECT sum(price) AS fact_05_2017
FROM orders_20190822 o 
JOIN (SELECT user_id FROM forecast_2017_05) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 5 
AND year(new_o_date) = 2017 -- т.к. в таблице два года


-- эта выборка - наш прогноз на май 2017 
-- итог 111453993.3725687
SELECT sum(forecast) AS forecast
FROM forecast_2017_05

-- найти соотношение между маем и апрелем 2016 года для данной группы пользователей и применить данный кэф для 2017 года
-- -- выборка id пользователей категории 3+ за апрель 2016
CREATE TEMPORARY TABLE IF NOT EXISTS users_2016_04 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2016-05-01')
	GROUP BY user_id
	HAVING count(id_o) > 2 -- пользователи, у которых 3+ покупок, 
	AND (timestampdiff(DAY, max(new_o_date), date('2016-05-01'))) <= 60 -- последний заказ не более 60 дней назад
);
-- -- выборка факт суммы по пользователям категории 3+ за май 2016
-- май 2016 24409660.80000082
SELECT sum(price) AS fact_05_2016
FROM orders_20190822 o  
JOIN (SELECT user_id FROM users_2016_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 5 
AND year(new_o_date) = 2016
-- -- выборка факт суммы по пользователям категории 3+ за апрель 2016
-- апрель 2016 50427776.69999895
SELECT sum(price) AS fact_04_2016
FROM orders_20190822 o  
JOIN (SELECT user_id FROM users_2016_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 4 
AND year(new_o_date) = 2016

-- -- кэф 0,5

-- -- выборка факт суммы по пользователям категории 3+ за апрель 2017
-- апрель 2017 87836087.49999124
SELECT sum(price) AS fact_04_2017
FROM orders_20190822 o 
JOIN (SELECT user_id FROM users_2017_04_2) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 4 
AND year(new_o_date) = 2017 -- т.к. в таблице два года



-- ------------------------------------------------------------------------------------------------------------------------------------------
-- 2. Группа часто покупающих, но которые не покупали уже значительное время. Так же можем сделать вывод, из такой группы за след месяц сколько купят и на какую сумму. 
-- (постараться продумать логику)

-- -- выборка id по пользователям, которые соответствуют условию на конец февраля 2017
DROP TABLE IF EXISTS users_2017_02;
CREATE TEMPORARY TABLE IF NOT EXISTS users_2017_02 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2017-03-01')
	GROUP BY user_id
	HAVING count(id_o) > 2 -- пользователи, у которых 3+ покупок, 
	AND (timestampdiff(DAY, max(new_o_date), date('2017-03-01'))) > 60 -- последний заказ более 60 дней назад
)
-- -- на какую сумму они сделали заказы в марте 2017
-- факт март 2017 - 14258064.100000124
SELECT sum(price) AS fact_03_2017
FROM orders_20190822 o 
JOIN (SELECT user_id FROM users_2017_02) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 3 
AND year(new_o_date) = 2017 -- т.к. в таблице два года


-- -- выборка id по пользователям, которые соответствуют условию на конец марта 2017
DROP TABLE IF EXISTS users_2017_03;
CREATE TEMPORARY TABLE IF NOT EXISTS users_2017_03 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2017-04-01')
	GROUP BY user_id
	HAVING count(id_o) > 2 -- пользователи, у которых 3+ покупок, 
	AND (timestampdiff(DAY, max(new_o_date), date('2017-04-01'))) > 60 -- последний заказ более 60 дней назад
)
-- -- на какую сумму они сделали заказы в апрель 2017
-- факт апрель 2017 - 12726209.30000003
SELECT sum(price) AS fact_04_2017
FROM orders_20190822 o 
JOIN (SELECT user_id FROM users_2017_03) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 4 
AND year(new_o_date) = 2017 -- т.к. в таблице два года


-- -- выборка id по пользователям, которые соответствуют условию на конец апреля 2017
DROP TABLE IF EXISTS users_2017_04;
CREATE TEMPORARY TABLE IF NOT EXISTS users_2017_04 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2017-05-01')
	GROUP BY user_id
	HAVING count(id_o) > 2 -- пользователи, у которых 3+ покупок, 
	AND (timestampdiff(DAY, max(new_o_date), date('2017-05-01'))) > 60 -- последний заказ более 60 дней назад
)
-- -- на какую сумму они сделали заказы в мае 2017
-- факт май 2017 - 12726209.30000003
SELECT sum(price) AS fact_05_2017
FROM orders_20190822 o 
JOIN (SELECT user_id FROM users_2017_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 5 
AND year(new_o_date) = 2017 -- т.к. в таблице два года




-- ------------------------------------------------------------------------------------------------------------------------------------------
-- 3. Отдельно разобрать пользователей с 1 и 2 покупками за все время, прогнозируем их.

/* попытка сделать прогноз высчитав сколько денег приносит пользователь за день, провалилась
-- 2 покупки
DROP TEMPORARY TABLE IF EXISTS forecast_2017_05;  
CREATE TEMPORARY TABLE IF NOT EXISTS forecast_2017_05 AS 
(
	SELECT user_id, sum(price)/(timestampdiff(DAY, min(new_o_date), date('2017-05-01'))) * 31 AS forecast
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2017-05-01')
	GROUP BY user_id
	HAVING count(id_o) <= 2 -- пользователи, у которых 2 и меньше покупок, 
	AND (timestampdiff(DAY, max(new_o_date), date('2017-05-01'))) <= 60 -- последний заказ не более 60 дней назад
)
-- ---------------------
-- эта выборка показывает факт оборот за май 2017 по тем пользователям, которые попали в прогнозную выборку по условиям задания
-- -- итог 15 292 431.000000164
SELECT sum(price) AS fact_05_2017
FROM orders_20190822 o 
JOIN (SELECT user_id FROM forecast_2017_05) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 5 
AND year(new_o_date) = 2017 -- т.к. в таблице два года


-- эта выборка - наш прогноз на май 2017 
-- итог 458 498 719.29534215
SELECT sum(forecast) AS forecast_05_2017
FROM forecast_2017_05
*/

-- найти соотношение между маем и апрелем 2016 года для данной группы пользователей и применить данный кэф для 2017 года
-- -- выборка id пользователей категории 2 и менее заказов на конец апреля 2016
DROP TEMPORARY TABLE IF EXISTS users_2016_04;
CREATE TEMPORARY TABLE IF NOT EXISTS users_2016_04 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2016-05-01')
	GROUP BY user_id
	HAVING count(id_o) <= 2 -- пользователи, у которых 2 и менее заказов покупок, 
	AND (timestampdiff(DAY, max(new_o_date), date('2016-05-01'))) <= 60 -- последний заказ не более 60 дней назад
);
-- -- выборка факт суммы по пользователям категории 2 и менее заказов за май 2016
-- май 2016 - 13580379.400000185
SELECT sum(price) AS fact_05_2016
FROM orders_20190822 o  
JOIN (SELECT user_id FROM users_2016_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 5 
AND year(new_o_date) = 2016
-- -- выборка факт суммы по пользователям категории 2 и менее заказов за апрель 2016
-- апрель 2016 - 88823746.19999178
SELECT sum(price) AS fact_04_2016
FROM orders_20190822 o  
JOIN (SELECT user_id FROM users_2016_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 4 
AND year(new_o_date) = 2016

-- -- кэф 0,15

-- -- выборка id пользователей категории 2 и менее заказов на конец апреля 2017
DROP TEMPORARY TABLE IF EXISTS users_2017_04;
CREATE TEMPORARY TABLE IF NOT EXISTS users_2017_04 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2017-05-01')
	GROUP BY user_id
	HAVING count(id_o) <= 2 -- пользователи, у которых 2 и менее заказов покупок, 
	AND (timestampdiff(DAY, max(new_o_date), date('2017-05-01'))) <= 60 -- последний заказ не более 60 дней назад
);

-- -- выборка факт суммы по пользователям категории 2 и менее заказов за апрель 2017
-- апрель 2017 87836087.49999124
SELECT sum(price) AS fact_04_2017
FROM orders_20190822 o 
JOIN (SELECT user_id FROM users_2017_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 4 
AND year(new_o_date) = 2017 -- т.к. в таблице два года

-- ---------------------------------------------------
-- 3. Группа пользователям категории 2 и менее заказов, но которые не покупали уже значительное время

-- -- выборка id по пользователям, которые соответствуют условию на конец февраля 2017
DROP TABLE IF EXISTS users_2017_02;
CREATE TEMPORARY TABLE IF NOT EXISTS users_2017_02 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2017-03-01')
	GROUP BY user_id
	HAVING count(id_o) <= 2 -- пользователи, у которых 2 и менее заказов покупок, 
	AND (timestampdiff(DAY, max(new_o_date), date('2017-03-01'))) > 60 -- последний заказ более 60 дней назад
)
-- -- на какую сумму они сделали заказы в марте 2017
-- факт март 2017 - 16987223.400000293
SELECT sum(price) AS fact_03_2017
FROM orders_20190822 o 
JOIN (SELECT user_id FROM users_2017_02) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 3 
AND year(new_o_date) = 2017 -- т.к. в таблице два года


-- -- выборка id по пользователям, которые соответствуют условию на конец марта 2017
DROP TABLE IF EXISTS users_2017_03;
CREATE TEMPORARY TABLE IF NOT EXISTS users_2017_03 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2017-04-01')
	GROUP BY user_id
	HAVING count(id_o)  <= 2 -- пользователи, у которых 2 и менее заказов покупок,
	AND (timestampdiff(DAY, max(new_o_date), date('2017-04-01'))) > 60 -- последний заказ более 60 дней назад
)
-- -- на какую сумму они сделали заказы в апрель 2017
-- факт апрель 2017 - 14589856.40000018
SELECT sum(price) AS fact_04_2017
FROM orders_20190822 o 
JOIN (SELECT user_id FROM users_2017_03) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 4 
AND year(new_o_date) = 2017 -- т.к. в таблице два года


-- -- выборка id по пользователям, которые соответствуют условию на конец апреля 2017
DROP TABLE IF EXISTS users_2017_04;
CREATE TEMPORARY TABLE IF NOT EXISTS users_2017_04 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2017-05-01')
	GROUP BY user_id
	HAVING count(id_o)  <= 2 -- пользователи, у которых 2 и менее заказов покупок,
	AND (timestampdiff(DAY, max(new_o_date), date('2017-05-01'))) > 60 -- последний заказ более 60 дней назад
)
-- -- на какую сумму они сделали заказы в мае 2017
-- факт май 2017 - 12726209.30000003
SELECT sum(price) AS fact_05_2017
FROM orders_20190822 o 
JOIN (SELECT user_id FROM users_2017_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 5 
AND year(new_o_date) = 2017 -- т.к. в таблице два года

-- ---------------------------------------------------
-- 3. Группа пользователей с 1 заказом
-- -- Находим id пользователей с 1 заказом в апреле 2016 года
DROP TEMPORARY TABLE IF EXISTS users_2016_04;
CREATE TEMPORARY TABLE IF NOT EXISTS users_2016_04 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2016-05-01')
	GROUP BY user_id
	HAVING count(id_o) = 1 -- пользователи, у которых 1 заказ
);

-- -- выборка факт суммы по пользователям с 1 заказом за апрель 2016
-- апрель 2016 65885910.29999638
SELECT sum(price) AS fact_04_2016
FROM orders_20190822 o  
JOIN (SELECT user_id FROM users_2016_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 4 
AND year(new_o_date) = 2016

-- -- выборка факт суммы по пользователям с 1 заказом за май 2016
-- май 2016 11173024.800000062
SELECT sum(price) AS fact_05_2016
FROM orders_20190822 o  
JOIN (SELECT user_id FROM users_2016_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 5 
AND year(new_o_date) = 2016

-- -- Находим id пользователей с 1 заказом в апреле 2017 года
DROP TEMPORARY TABLE IF EXISTS users_2017_04;
CREATE TEMPORARY TABLE IF NOT EXISTS users_2017_04 AS 
(
	SELECT user_id
	FROM orders_20190822  
	WHERE date(new_o_date) < date('2017-05-01')
	GROUP BY user_id
	HAVING count(id_o) = 1 -- пользователи, у которых 1 заказ
);

-- -- выборка факт суммы по пользователям с 1 заказом за апрель 2017
-- апрель 2017 84343884.79998784
SELECT sum(price) AS fact_04_2017
FROM orders_20190822 o  
JOIN (SELECT user_id FROM users_2017_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 4 
AND year(new_o_date) = 2017

-- -- выборка факт суммы по пользователям с 1 заказом за май 2017
-- май 2017 84343884.79998784
SELECT sum(price) AS fact_05_2017
FROM orders_20190822 o  
JOIN (SELECT user_id FROM users_2017_04) AS t
ON o.user_id = t.user_id
WHERE month(new_o_date) = 5 
AND year(new_o_date) = 2017


-- ---------------------------------------------------------------------------------------------------------
-- прогноз для пользователей, которые зарегистрируются и сделают первый заказ в мае
-- -- пользователи, которые новые в мае - сравнить долю таких заказов к общей сумме в 2016 и применить коэф
-- -- -- это общий товарооборот по месяцам 
SELECT (concat(month(new_o_date), '-', year(new_o_date))), sum(price)
FROM orders_20190822 
GROUP BY (concat(month(new_o_date), '-', year(new_o_date)));

-- -- -- это ТО по месяцам только по первым заказам 
SELECT (concat(month(new_o_date), '-', year(new_o_date))), sum(price)
FROM orders_20190822 o2  
WHERE id_o IN 
	(SELECT min(id_o) 
	FROM orders_20190822 o3  
	GROUP BY user_id
	)
GROUP BY (concat(month(new_o_date), '-', year(new_o_date)));


	

-- ------------------------------------------------------------------------------------------------------------------------------------------
-- 4. В итоге у вас будет прогноз ТО и вы сможете его сравнить с фактом и оценить грубо разлет по данным.



















