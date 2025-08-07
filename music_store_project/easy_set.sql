-- Question Set 1 - Easy

-- 1. Who is the senior most employee based on job title

SELECT last_name, first_name, title 
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- 2. Which countries have the most invoices?

SELECT billing_country, COUNT(*)
FROM invoice
GROUP BY billing_country
ORDER BY count DESC

-- 3. What are top 3 values of total invoice?

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- 4. Which city has the best customers? Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.

SELECT billing_city, SUM(total)
FROM invoice
GROUP BY billing_city
ORDER BY sum DESC
LIMIT 1;

-- 5. Who is the best customer? (The customer who has spent the most money is the best)

SELECT c.first_name, c.last_name, SUM(i.total) 
FROM customer AS c
INNER JOIN invoice AS i ON i.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY sum DESC
LIMIT 1;
