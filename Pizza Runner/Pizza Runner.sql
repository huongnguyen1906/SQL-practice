CREATE DATABASE pizza_runner;
USE pizza_runner

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 12:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 12:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-02 13:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meat lovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


--- Data cleaning
SELECT * FROM runners
SELECT * FROM customer_orders
SELECT * FROM runner_orders
SELECT * FROM pizza_names
SELECT * FROM pizza_recipes
SELECT * FROM pizza_toppings

SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'pizza_names'
/*
Cleaning customer_orders
- Identify records with null or 'null' values
- updating null or 'null' values to ''
- blanks '' are not null because it indicates the customer asked for no extras or exclusions
*/
DROP TABLE IF EXISTS update_customer_orders
SELECT order_id,
			customer_id, 
			pizza_id,
			CASE WHEN exclusions is NULL OR exclusions LIKE 'null' THEN '' ELSE exclusions END AS exclusions,
			CASE WHEN extras IS NULL OR extras LIKE 'null' THEN '' ELSE extras END AS extras,
			CAST (order_time AS DATETIME) AS order_time
INTO update_customer_orders
FROM customer_orders 

SELECT * FROM update_customer_orders

---Cleaning runner_orders 
DROP TABLE IF EXISTS update_runner_orders
SELECT order_id,
			runner_id, 
			CASE WHEN pickup_time IS NULL OR pickup_time LIKE 'null' THEN ''
				ELSE(CAST(pickup_time AS DATETIME) END AS pickup_time,
			CASE WHEN distance IS NULL OR distance LIKE 'null' THEN '' 
				ELSE REPLACE(REPLACE(REPLACE(distance,'km',''),' ',''),'g','') END AS distance,
			CASE WHEN duration  IS NULL OR duration LIKE 'null' THEN '' 
				ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(duration,'minutes',''),'mins',''),'minute',''),' ',''),'g','') END AS duration,
			CASE WHEN cancellation IS NULL OR cancellation LIKE 'null' THEN '' ELSE cancellation END AS cancellation
INTO update_runner_orders
FROM runner_orders 

SELECT * FROM update_customer_orders
SELECT * FROM update_runner_orders

-- Q1. How many pizzas were ordered?
SELECT COUNT (pizza_id) AS pizzas_ordered
FROM update_customer_orders

--Q2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS orders_count
FROM update_customer_orders

--Q3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT (order_id) AS successful_orders
FROM update_runner_orders
WHERE cancellation IS NULL OR cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY runner_id
ORDER BY runner_id

-- Q4. How many of each type of pizza was delivered?
SELECT pn.pizza_name, COUNT(ro.order_id) AS pizza_type_count
FROM update_runner_orders AS ro
JOIN update_customer_orders AS co ON ro.order_id = co.order_id
JOIN pizza_names AS pn ON pn.pizza_id = co.pizza_id
WHERE ro.cancellation IS NULL OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation') OR ro.cancellation = ''
GROUP BY pn.pizza_name
------------------------
SELECT
  pn.pizza_name,
  COUNT(co.order_id) AS pizza_type_count
FROM update_customer_orders AS co
INNER JOIN pizza_names AS pn
   ON co.pizza_id = pn.pizza_id
INNER JOIN update_runner_orders AS ro
   ON co.order_id = ro.order_id
WHERE cancellation IS NULL
OR cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY pn.pizza_name
ORDER BY pn.pizza_name;

--- OR
SELECT
  pn.pizza_name,
  COUNT(CO.order_id) AS pizza_type_count
FROM update_customer_orders AS co
INNER JOIN pizza_names AS pn
   ON co.pizza_id = pn.pizza_id
WHERE EXISTS (
  SELECT 1 FROM update_runner_orders AS ro
   WHERE ro.order_id = co.order_id
   AND (
    ro.cancellation IS NULL
    OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
  )
)
GROUP BY pn.pizza_name
ORDER BY pn.pizza_name;

--Q5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
  customer_id,
  SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS meat_lovers,
  SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS vegetarian
FROM update_customer_orders
GROUP BY customer_id;

-- Q6. What was the maximum number of pizzas delivered in a single order?
SELECT ro.order_id, COUNT (*) AS total_pizzas
FROM update_customer_orders AS co
JOIN update_runner_orders AS ro ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL
	OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY ro.order_id
-------------------------------------------
SELECT MAX (total_pizzas) AS maximum_pizzas
FROM (SELECT ro.order_id, COUNT (*) AS total_pizzas
		FROM update_customer_orders AS co
		JOIN update_runner_orders AS ro ON ro.order_id = co.order_id
		WHERE ro.cancellation IS NULL
			OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
		GROUP BY ro.order_id) AS x

-- Q7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT * FROM update_customer_orders

SELECT co.customer_id, 
		sUM(CASE WHEN co.exclusions = '' OR co.extras = '' THEN 1 ELSE 0 END )AS no_change,
		SUM(CASE WHEN co.exclusions <> '' OR co.extras <> '' THEN 1 ELSE 0 END) AS change
FROM update_runner_orders AS ro 
JOIN update_customer_orders AS co ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL
	OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY customer_id

--Q8. How many pizzas were delivered that had both exclusions and extras?
SELECT sUM(CASE WHEN co.exclusions <> '' AND co.extras <> '' THEN 1 ELSE 0 END ) AS total_pizzas
FROM update_runner_orders AS ro 
JOIN update_customer_orders AS co ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL
	OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')

-- Q9. What was the total volume of pizzas ordered for each hour of the day?
SELECT DATEPART(HOUR,order_time) AS each_hour, COUNT(order_id) AS total_pizzas
FROM update_customer_orders
GROUP BY DATEPART(HOUR,order_time)

--Q10. What was the volume of orders for each day of the week?
SELECT FORMAT(order_time, 'dddd') AS day_of_week, COUNT(order_id) AS total_pizzas
FROM update_customer_orders
GROUP BY FORMAT(order_time, 'dddd')

-- Q11.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

WITH T1 AS 
	(SELECT
		runner_id,
		registration_date,
		DATEADD(DAY, (DATEDIFF(DAY, registration_date, '2021-01-01') % 7), registration_date) AS start_of_week
	FROM runners)
SELECT
  start_of_week,
  COUNT(runner_id) AS signups
FROM T1
GROUP BY start_of_week
ORDER BY start_of_week;

/*
SELECT
		runner_id,
		registration_date,
		DATEDIFF(DAY, '2021-01-01',registration_date) ,
		DATEDIFF(DAY, '2021-01-01',registration_date) % 7 AS start_of_week,
		DATEADD(DAY, (DATEDIFF(DAY, registration_date, '2021-01-01') % 7), registration_date)
	FROM runners
*/
-- Q12. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH runner_pickup AS 
	(SELECT runner_id, 
		   co.order_id,
		   order_time,
		   pickup_time,
		   DATEPART(MINUTE,(pickup_time - order_time)) AS time_to_pickup
	FROM update_runner_orders AS ro
	JOIN update_customer_orders AS co ON ro.order_id = co.order_id
	WHERE pickup_time <> '')

SELECT runner_id, AVG (time_to_pickup) AS avg_minutes
FROM runner_pickup
GROUP BY runner_id

-- Q13. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH pizzas_counts AS
	(SELECT order_id, COUNT (pizza_id) AS num_pizzas, order_time
	FROM update_customer_orders
	GROUP BY order_id, order_time),

repared_times AS
	(SELECT  co.order_id,
			order_time,
			pickup_time,
			DATEPART(MINUTE,(pickup_time - order_time)) AS time_to_pickup
		FROM update_runner_orders AS ro
		JOIN update_customer_orders AS co ON ro.order_id = co.order_id
		WHERE pickup_time <> '')

SELECT num_pizzas, AVG (time_to_pickup) AS repared_time
FROM pizzas_counts AS pc
JOIN repared_times AS rt ON pc.order_id = rt.order_id
GROUP BY num_pizzas

-- Q14. What was the average distance travelled for each runner?
SELECT runner_id, AVG (CAST(distance AS FLOAT)) AS avg_distance
FROM update_runner_orders
GROUP BY runner_id
ORDER BY runner_id

-- Q15. What was the difference between the longest and shortest delivery times for all orders?
SELECT
  MAX(CAST(duration AS float)) - MIN(CAST(duration AS float)) AS difference
FROM update_runner_orders;

-- Q16. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, order_id, distance, duration, ROUND(AVG(60*CAST(distance AS float)/CAST (duration AS float)),2) AS speed
FROM update_runner_orders
WHERE distance <> ''
GROUP BY runner_id, order_id, distance, duration
ORDER BY speed DESC
-- Q17. What is the successful delivery percentage for each runner?
SELECT
  runner_id,
  COUNT(pickup_time) as delivered,
  COUNT(*) AS total,
  ROUND(100 * COUNT(pickup_time) / COUNT(*),2) AS delivery_percent
FROM update_runner_orders
WHERE pickup_time <> ''
GROUP BY runner_id
ORDER BY runner_id;