-- Moderate Set of Questions

-- 1. – Name most often #1 in history (MODERATE)

WITH RankedNames AS (

SELECT name, gender, year, COUNT(*) as total_count, 
		ROW_NUMBER() OVER(PARTITION BY year, gender ORDER BY COUNT(*) DESC) AS rank_num
FROM StateBabyNames
GROUP BY name, gender, year
),
TopRankedNames AS (

SELECT name, gender 
FROM RankedNames
WHERE rank_num = 1
)

SELECT name, gender, COUNT(name) AS years_at_top
FROM TopRankedNames
GROUP BY name, gender
ORDER BY years_at_top DESC

-- 2. – Name most often #1 in each state (MODERATE)

WITH RankedNames AS (

SELECT name, gender, state, year, COUNT(*) as total_count, 
		ROW_NUMBER() OVER(PARTITION BY year, state, gender ORDER BY COUNT(*) DESC) AS rank_num
FROM StateBabyNames
GROUP BY name, gender, year, state
),
TopRankedNames AS (

SELECT name, state, gender 
FROM RankedNames
WHERE rank_num = 1
)

SELECT name, gender, state, COUNT(name) AS years_at_top
FROM TopRankedNames
GROUP BY name, gender, state
ORDER BY years_at_top DESC

-- 3. – Largest one-year increase in count (MODERATE)

WITH YearlyTotals AS (
SELECT name, gender, year, SUM(count) AS total_count
FROM StateBabyNames
GROUP BY name, gender, year
),
PreviousCount AS (

SELECT name, gender, year, total_count as current_count, LAG(total_count, 1) OVER (PARTITION BY name, gender ORDER BY year) AS previous_count
FROM YearlyTotals
)
SELECT name, gender, year, (current_count - previous_count) AS increase
FROM PreviousCount
WHERE previous_count IS NOT NULL
ORDER BY increase DESC




-- 4. – State top 3 but not in top 20 nationwide (MODERATE)

WITH StateTopNames AS (
SELECT name, year, gender, state, count,
		ROW_NUMBER() OVER(PARTITION BY year, state, gender ORDER BY count DESC) AS state_rank
FROM StateBabyNames
GROUP BY name, year, gender, state, count
),
TopNames AS (
SELECT name, year, gender, SUM(count) as total_count,
		ROW_NUMBER() OVER(PARTITION BY year, gender ORDER BY SUM(count) DESC) AS top_rank
FROM StateBabyNames
GROUP BY name, year, gender
)
SELECT name, year, state, count
FROM StateTopNames
WHERE state_rank <= 3 AND (name, year) IN (SELECT name, year
										FROM TopNames
										WHERE top_rank > 20)
ORDER BY count DESC;


-- 5. – Top 5 names by YoY growth rate (MODERATE)

WITH YearlyTotals AS (
SELECT name, gender, year, SUM(count) AS total_count
FROM StateBabyNames
GROUP BY name, gender, year
),
PreviousCount AS (
SELECT name, gender, year, total_count as current_count,
		LAG(total_count, 1) OVER (PARTITION BY name, gender ORDER BY year) AS previous_count
FROM YearlyTotals
),
CalcGrowthRate AS (
SELECT name, year, gender,
CASE 
	WHEN previous_count IS NOT NULL AND previous_count > 0 THEN (current_count::FLOAT - previous_count)/previous_count
	ELSE NULL
END AS growth_rate
FROM PreviousCount
),
RankGrowthRate AS (
SELECT name, gender, year, growth_rate,
	ROW_NUMBER() OVER(PARTITION BY year ORDER BY growth_rate DESC) AS growth_rank
FROM CalcGrowthRate
WHERE growth_rate IS NOT NULL
)
SELECT name, gender, year, growth_rate, growth_rank
FROM RankGrowthRate
WHERE growth_rank <= 10
ORDER BY growth_rate DESC

