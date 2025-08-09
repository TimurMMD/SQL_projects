-- Easy Set of Questions

-- 1. What was the bigest count for one name? What was the year and a state?
SELECT name, year, gender, state, count
FROM StateBabyNames
ORDER BY count DESC

-- 2. – Most popular male & female name in history (EASY)

-- Male -- 
SELECT name, gender, SUM(count)
FROM StateBabyNames
WHERE gender LIKE 'M'
GROUP BY name, gender
ORDER BY sum DESC
LIMIT 10;

-- Female -- 
SELECT name, gender, SUM(count)
FROM StateBabyNames
WHERE gender LIKE 'F'
GROUP BY name, gender
ORDER BY sum DESC
LIMIT 10;

-- 3. – Most popular name in each state (EASY)

-- Male -- 
WITH RankedBabyNames AS (
	SELECT name, gender, state, SUM(count) AS total_count,
			ROW_NUMBER() OVER(PARTITION BY state ORDER BY SUM(count) DESC) AS rank_num
	FROM StateBabyNames
	WHERE gender = 'M'
	GROUP BY name, gender, state
)

SELECT name, gender, state, total_count
FROM RankedBabyNames 
WHERE rank_num = 1
ORDER BY total_count DESC

-- Female -- 
WITH RankedBabyNames AS (
	SELECT name, gender, state, SUM(count) AS total_count,
			ROW_NUMBER() OVER(PARTITION BY state ORDER BY SUM(count) DESC) AS rank_num
	FROM StateBabyNames
	WHERE gender = 'F'
	GROUP BY name, gender, state
)

SELECT name, gender, state, total_count
FROM RankedBabyNames 
WHERE rank_num = 1
ORDER BY total_count DESC


-- 4. – Proportion of babies with top-10 names each year (EASY)

WITH YearlyNameRanks AS (
	SELECT name, year, gender, count,
			RANK() OVER(PARTITION BY year, gender ORDER BY count DESC) AS rank
	FROM StateBabyNames
),
Top10Names AS (
	SELECT name, year, gender, count
	FROM YearlyNameRanks
	WHERE rank <= 10
)

SELECT name, year, gender, count, CAST(count as FLOAT) / SUM(count) OVER(PARTITION BY year, gender) AS proportion
FROM Top10Names
ORDER BY proportion DESC

-- 5. – Unique names with at least 10 babies each year (EASY)

WITH FirstAppearance AS (

SELECT name, MIN(year) AS first_year
FROM StateBabyNames
GROUP BY name
),
YearlyCount AS (

SELECT name, year, SUM(count) AS total_babies
FROM StateBabyNames 
GROUP BY name, year
HAVING SUM(count) >= 10
)

SELECT yc.name, yc.year, yc.total_babies
FROM YearlyCount yc
JOIN FirstAppearance fa ON yc.name = fa.name
WHERE yc.year = fa.first_year
ORDER BY yc.year, yc.name

