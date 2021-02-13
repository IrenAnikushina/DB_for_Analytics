/*Даны 2 таблицы:
Таблица клиентов clients, в которой находятся данные по карточному лимиту каждого клиента
clients
id_client (primary key) number,
limit_sum number
transactions
id_transaction (primary key) number,
id_client (foreign key) number,
transaction_date number,
transaction_time number,
transaction_sum number

Написать текст SQL-запроса*/

-- выводящего количество транзакций, сумму транзакций, среднюю сумму транзакции и дату и время первой транзакции для каждого клиента
SELECT id_client, 
	count(id_transaction), 
	sum(transaction_sum), 
	avg(transaction_sum), 
	min(concat(transaction_date, ' ', transaction_time))
FROM clients
GROUP BY id_client;

-- Найти id пользователей, кот использовали более 70% карточного лимита
SELECT id_client,
	sum(transaction_sum),
	avg(limit_sum)
FROM clients
GROUP BY id_client
HAVING sum(transaction_sum) > (avg(limit_sum) * 0.7)

