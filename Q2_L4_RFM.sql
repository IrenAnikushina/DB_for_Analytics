/*Главная задача: сделать RFM-анализ на основе данных по продажам за 2 года (из предыдущего дз).
​Что делаем:
1. Определяем критерии для каждой буквы R, F, M (т.е. к примеру, R – 3 для клиентов, которые покупали <= 30 дней от последней даты в базе, 
R – 2 для клиентов, которые покупали > 30 и менее 60 дней от последней даты в базе и т.д.)
2. Для каждого пользователя получаем набор из 3 цифр (от 111 до 333, где 333 – самые классные пользователи)
3. Вводим группировку, к примеру, 333 и 233 – это Vip, 1XX – это Lost, остальные Regular ( можете ввести боле глубокую сегментацию)
4. Для каждой группы из п. 3 находим кол-во пользователей, кот. попали в них и % товарооборота, которое они сделали на эти 2 года.
5. Проверяем, что общее кол-во пользователей бьется с суммой кол-во пользователей по группам из п. 3 (если у вас есть логические ошибки в создании групп, у вас не собьются цифры). То же самое делаем и по деньгам.
6. Результаты присылаем.*/

-- R – время с последнего действия
-- -- 3. 0-30 дней с даты покупки – высокий шанс покупки
-- -- 2. 30-60 – высокий риск ухода 
-- -- 1. больше 60 - Чем больше промежуток, тем меньше шанс повторного заказа
-- F – количество действий за все время
-- -- 3. 3+ - отлично
-- -- 2. 2-3 – норм
-- -- 1. Меньше 2 - такое
-- M – сколько всего выручки с пользователя
-- -- 3. 15 тыс + - хорошо
-- -- 2. 7-15 тыс + - норм
-- -- 1. Меньше 7 тыс - такое
SELECT user_id, 
	-- timestampdiff(DAY, max(new_o_date), date('2018-01-01')),
	CASE 
		WHEN timestampdiff(DAY, max(new_o_date), date('2018-01-01')) > 0
		AND timestampdiff(DAY, max(new_o_date), date('2018-01-01')) <= 30
		THEN '3'
		WHEN timestampdiff(DAY, max(new_o_date), date('2018-01-01')) > 30
		AND timestampdiff(DAY, max(new_o_date), date('2018-01-01')) <= 60
		THEN '2'
		ELSE '1'
	END AS recency,
	-- count(id_o),
	CASE 
		WHEN count(id_o) > 3
		THEN '3'
		WHEN count(id_o) > 1
		AND count(id_o) <= 3
		THEN '2'
		ELSE '1'
	END AS frequency, 
	-- sum(price),
	CASE 
		WHEN sum(price) >= 15000
		THEN '3'
		WHEN sum(price) > 7000 
		AND sum(price) < 15000 
		THEN '2'
		ELSE '1'
	END AS monetary
FROM `business.orders_2017`
GROUP BY user_id 

-- тоже самое с конкатенацией и за два года
DROP TEMPORARY TABLE IF EXISTS rfm_users;
CREATE TEMPORARY TABLE IF NOT EXISTS rfm_users AS 
SELECT user_id, 
	concat(
	(CASE 
		WHEN timestampdiff(DAY, max(new_o_date), date('2018-01-01')) > 0
		AND timestampdiff(DAY, max(new_o_date), date('2018-01-01')) <= 30
		THEN '3'
		WHEN timestampdiff(DAY, max(new_o_date), date('2018-01-01')) > 30
		AND timestampdiff(DAY, max(new_o_date), date('2018-01-01')) <= 60
		THEN '2'
		ELSE '1'
	END), -- recency
	'',
	(CASE 
		WHEN count(id_o) > 3
		THEN '3'
		WHEN count(id_o) > 1
		AND count(id_o) <= 3
		THEN '2'
		ELSE '1'
	END), -- frequency
	'',
	(CASE 
		WHEN sum(price) >= 15000
		THEN '3'
		WHEN sum(price) > 7000 
		AND sum(price) < 15000 
		THEN '2'
		ELSE '1'
	END) -- monetary
	) AS RFM,
	sum(price) AS total_amount
FROM orders_20190822 
GROUP BY user_id 

/*SELECT user_id, RFM, total_amount
FROM rfm_users;*/

-- сводная по RFM
DROP TEMPORARY TABLE IF EXISTS RFM_cross;
CREATE TEMPORARY TABLE IF NOT EXISTS RFM_cross AS 
SELECT RFM, count(user_id) AS qty_users, sum(total_amount) AS total_volume
FROM rfm_users
GROUP BY RFM;

/*
R	F	M	status
1	1	*	lost_new
1	2	*	lost_reg
1	3	1	lost_reg
1	3	2	lost_reg
1	3	3	lost_vip
2	1	*	new
3	1	*	new
3	3	3	vip
2	3	3	vip
2	2	*	regular
2	3	1	regular
2	3	2	regular
3	2	*	regular
3	3	1	regular
3	3	2	regular
*/

-- DROP TEMPORARY TABLE IF EXISTS rfm_status;
-- CREATE TEMPORARY TABLE IF NOT EXISTS rfm_status AS 
SELECT 
	CASE 
		WHEN RFM = 111 OR RFM = 112 OR RFM = 113   
		THEN 'lost_new'
		WHEN RFM = 121 OR RFM = 122 OR RFM = 123 OR RFM = 131 OR RFM = 132
		THEN 'lost_regular'
		WHEN RFM = 133 
		THEN 'lost_vip'
		WHEN RFM = 211 OR RFM = 212 OR RFM = 213 OR RFM = 311 OR RFM = 312 OR RFM = 313
		THEN 'new'
		WHEN RFM = 233 OR RFM = 333
		THEN 'vip'
		ELSE 'regular'
	END AS status,
	sum(qty_users), 
	sum(total_volume)
FROM RFM_cross
GROUP BY status;