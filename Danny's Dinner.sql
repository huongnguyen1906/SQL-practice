CREATE DATABASE dannys_diner;
USE dannys_diner

DROP TABLE IF EXISTS sales
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
----------------------------------
SELECT *
FROM sales

menu, members

--------------------------------------------------------------------
-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) AS total_amount
FROM sales as s
LEFT JOIN menu AS m ON s.product_id = m.product_id
GROUP BY customer_id

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS visited_days
FROM sales
GROUP BY customer_id

-- 3. What was the first item from the menu purchased by each customer?
WITH cte AS
	(SELECT customer_id, product_id, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) as order_items
	FROM sales)

SELECT customer_id, product_name
FROM cte 
LEFT JOIN menu AS m ON cte.product_id = m.product_id
WHERE order_items = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1 s.product_id, m.product_name, COUNT(*) AS total_times
FROM sales AS s
LEFT JOIN menu AS m ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
ORDER BY total_times DESC

-- 5. Which item was the most popular for each customer?
WITH T1 AS (
	SELECT s.customer_id,s.product_id, m.product_name, COUNT(s.product_id) AS total_order
	FROM sales AS s
	LEFT JOIN menu AS m ON s.product_id = m.product_id
	GROUP BY s.customer_id, s.product_id, m.product_name),

T2 AS
	(SELECT *, RANK() OVER(PARTITION BY T1.customer_id ORDER BY T1.total_order DESC) AS rnk
	FROM T1)

SELECT customer_id,product_id, product_name, total_order
FROM T2
WHERE T2.rnk = 1

-- 6. Which item was purchased first by the customer after they became a member?
WITH T1 AS
	(SELECT s.customer_id, s.order_date, s.product_id , m.join_date , DATEDIFF(DAY, m.join_date, s.order_date) AS date_tag
	FROM sales AS s
	LEFT JOIN members AS m ON s.customer_id = m.customer_id
	WHERE s.order_date >= m.join_date),
T2 AS
	(SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY date_tag ASC) AS rnk
	 FROM T1)
SELECT T2.customer_id, m.product_name, T2.order_date
FROM T2 
LEFT JOIN menu AS m ON T2. product_id = m.product_id
WHERE rnk = 1

-- 7. Which item was purchased just before the customer became a member?---------------------------------
WITH T1 AS
	(SELECT s.customer_id, s.order_date, s.product_id , m.join_date , DATEDIFF(DAY, s.order_date, m.join_date ) AS date_tag
	FROM sales AS s
	LEFT JOIN members AS m ON s.customer_id = m.customer_id
	WHERE s.order_date < m.join_date),
T2 AS
	(SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY date_tag ASC) AS rnk
	 FROM T1)
SELECT T2.customer_id, m.product_name, T2.order_date
FROM T2 
LEFT JOIN menu AS m ON T2. product_id = m.product_id
WHERE rnk = 1

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,COUNT( s.product_id) AS total_items,SUM (me.price) AS total_spent
FROM sales AS s
LEFT JOIN menu AS me ON s.product_id = me.product_id
LEFT JOIN members AS m ON m.customer_id = s.customer_id
WHERE  s.order_date < m.join_date
GROUP BY s.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, SUM(me.price) AS total_spent,
	   SUM(CASE WHEN me.product_name = 'sushi' THEN me.price*20
		    ELSE me.price*10
	    END) as customer_points
FROM sales AS s
LEFT JOIN menu AS me ON s.product_id = me.product_id
LEFT JOIN members AS m ON m.customer_id = s.customer_id
WHERE s.customer_id IN (SELECT customer_id FROM members)
GROUP BY s.customer_id
ORDER BY customer_id
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH first_week_points AS
	(SELECT s.customer_id,
		   SUM(me.price) AS total_spent,
		   me.price*20 AS customer_points_first_week
	FROM sales AS s
	LEFT JOIN menu AS me ON s.product_id = me.product_id
	LEFT JOIN members AS m ON m.customer_id = s.customer_id
	WHERE  s.order_date BETWEEN m.join_date AND DATEADD(DAY,6, m.join_date)
	GROUP BY s.customer_id, me.price),

normal_points AS
	(SELECT s.customer_id, SUM(me.price) AS total_spent,
		   SUM(CASE WHEN me.product_name = 'sushi' THEN me.price*20
				ELSE me.price*10
			END) as customer_points
	FROM sales AS s
	LEFT JOIN menu AS me ON s.product_id = me.product_id
	LEFT JOIN members AS m ON m.customer_id = s.customer_id
	WHERE s.order_date NOT BETWEEN m.join_date AND DATEADD(DAY,6, m.join_date) AND s.order_date < '2021-02-01'
	GROUP BY s.customer_id),

combined_points AS
	(SELECT * FROM first_week_points 
	UNION ALL 
	SELECT * FROM normal_points)

SELECT customer_id, SUM(total_spent)AS total_spents, SUM (customer_points_first_week) AS customer_points
FROM combined_points
GROUP BY customer_id