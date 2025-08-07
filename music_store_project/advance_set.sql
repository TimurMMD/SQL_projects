-- Question Set 3 - Advance

--  1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT CONCAT(c.first_name, ' ', c.last_name) as customer_name, a.name, SUM(il.unit_price*il.quantity)
FROM customer as c
JOIN invoice as i ON i.customer_id = c.customer_id
JOIN invoice_line as il ON il.invoice_id = i.invoice_id
JOIN track as t ON t.track_id = il.track_id
JOIN album as al ON al.album_id = t.album_id
JOIN artist as a ON a.artist_id = al.artist_id
GROUP BY c.first_name, c.last_name, a.name
ORDER BY sum DESC

--  2. Find out the most popular music Genre for each country. The most popular genre as the genre with the highest amount of purchases. 

WITH GenreSales AS (
		SELECT i.billing_country as country, g.name as genre, SUM(i.total) AS total_sales
		FROM invoice i
		JOIN invoice_line il ON il.invoice_id = i.invoice_id
		JOIN track t ON t.track_id = il.track_id
		JOIN genre g ON g.genre_id = t.genre_id
		GROUP BY i.billing_country, g.name
),
RankedGenreSales AS (
		SELECT country, genre, total_sales,
				ROW_NUMBER() OVER(PARTITION BY country ORDER BY total_sales DESC) AS rank_num
		FROM GenreSales		
)
SELECT country, genre, total_sales
FROM RankedGenreSales
WHERE rank_num = 1
ORDER BY total_sales DESC

--  3. Find the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent.

WITH countrysales AS(
	SELECT CONCAT(c.first_name, ' ', c.last_name) as customer_name,
		i.billing_country as country,
		SUM(i.total) as total_sales
	FROM customer c
	JOIN invoice i ON i.customer_id = c.customer_id
	GROUP BY c.first_name, c.last_name, i.billing_country
),
Rankedcountrysales AS (
		SELECT customer_name, country, total_sales,
				ROW_NUMBER() OVER(PARTITION BY country ORDER BY total_sales DESC) as rank_num
		FROM countrysales 
)
SELECT customer_name, country, total_sales
FROM Rankedcountrysales
WHERE rank_num = 1
ORDER BY total_sales DESC
