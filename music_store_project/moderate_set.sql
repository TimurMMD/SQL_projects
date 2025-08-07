-- Question Set 2 - Moderate

-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT(c.email), c.first_name, c.last_name, g.name as genre
FROM customer as c
INNER JOIN invoice as i ON i.customer_id = c.customer_id
INNER JOIN invoice_line as il ON il.invoice_id = i.invoice_id
INNER JOIN track as t ON t.track_id = il.track_id
INNER JOIN genre as g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
ORDER BY c.email

-- 2. Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT a.name, COUNT(t.track_id)
FROM artist as a
JOIN album as al ON al.artist_id = a.artist_id
JOIN track as t ON t.album_id = al.album_id
JOIN genre as g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY a.name
ORDER BY count DESC
LIMIT 10;

-- 3. Return all the track names that have a song length longer than the average song length. Return the name and milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name, milliseconds/1000 as length
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds)
						FROM track)
ORDER BY milliseconds DESC
