-- Advance Set of Questions --

-- 1. – Disproportionately popular names by state (ADVANCED)

WITH NationalProportion AS (
SELECT SUM(count) AS total_national
FROM StateBabyNames
),
StateProportion AS(
SELECT state, SUM(count) AS total_state
FROM StateBabyNames
GROUP BY state
),
NameProportions AS(
SELECT s.state, s.name, s.gender,
		s.count::FLOAT / sp.total_state AS state_proportion,
		s.count::FLOAT / np.total_national AS national_proportion
FROM StateBabyNames s
JOIN StateProportion sp ON s.state = sp.state
CROSS JOIN NationalProportion np
),
StateSTD AS(
SELECT state, name, gender, state_proportion, national_proportion,
		STDDEV(state_proportion) OVER(PARTITION BY name, gender) AS name_std_dev
FROM NameProportions
),
FinalResults AS(
SELECT state, name, gender, state_proportion, national_proportion,
		(state_proportion - national_proportion)/NULLIF(name_std_dev, 0) AS z_score
FROM StateSTD
)
SELECT * FROM FinalResults
WHERE z_score > 2.0
ORDER BY z_score DESC


-- 2. – Top 10 in 1980s but out of top 100 in 2000s (ADVANCED)

WITH Top80 AS (
SELECT name, gender, SUM(count) as total_count_80s,
		ROW_NUMBER() OVER(ORDER BY SUM(count) DESC) AS rank80
FROM StateBabyNames
WHERE year >= 1980 AND year < 1989
GROUP BY name, gender
),
Top2000 AS (
SELECT name, gender, SUM(count) as total_count_2000s,
		ROW_NUMBER() OVER(ORDER BY SUM(count) DESC) AS rank2000
FROM StateBabyNames
WHERE year >= 2000 AND year < 2009
GROUP BY name, gender
)
SELECT t8.name, t8.gender, rank80, rank2000
FROM Top80 t8
JOIN Top2000 t2 ON t8.name = t2.name AND t8.gender = t2.gender
WHERE rank80 <= 10 AND rank2000 > 100
ORDER BY rank80

-- 3. – Names in top 50 for over 50 years (ADVANCED)

WITH RankingNames AS(
SELECT name, gender, year, SUM(count) as total_count,
		ROW_NUMBER() OVER(PARTITION BY year ORDER BY SUM(count) DESC) as rank_num
FROM StateBabyNames
GROUP BY name, gender, year
),
Top50Names AS (
SELECT name, gender, year, rank_num
FROM RankingNames
WHERE rank_num <= 50
)
SELECT name, gender, COUNT(year) 
FROM Top50Names
GROUP BY name, gender
HAVING COUNT(year) >= 50
ORDER BY count DESC

-- 4. – New top 10 names by decade (ADVANCED)

WITH RankingDecade AS (
SELECT name, gender, (year/10)*10 as decade,
		ROW_NUMBER() OVER(PARTITION BY (year/10)*10 ORDER BY SUM(count)) AS rank_num
FROM StateBabyNames
GROUP BY name, gender, year
),
Top10 AS(
SELECT name, gender, decade, rank_num
FROM RankingDecade
WHERE rank_num <= 10
), 
CheckingNames AS (
SELECT current_decade_names.name, current_decade_names.decade
FROM Top10 as current_decade_names
WHERE NOT EXISTS (SELECT 1
					FROM Top10 AS previous_decade_names
					WHERE previous_decade_names.name = current_decade_names.name
					AND previous_decade_names.decade = current_decade_names.decade - 10)
)
SELECT name, decade
FROM CheckingNames
ORDER BY decade

-- 5. – Popular 100 years ago, faded, now rising (ADVANCED)

WITH HistoricalPopularity AS (
SELECT name, gender, SUM(count),
	RANK() OVER(ORDER BY SUM(count)) as rank
FROM StateBabyNames
WHERE year >= 1910 AND year < 1919
GROUP BY name, gender
),
OutofStyle AS (
SELECT name, gender, SUM(count),
	RANK() OVER(ORDER BY SUM(count)) as rank
FROM StateBabyNames
WHERE year >= 1950 AND year < 1979
GROUP BY name, gender
),
RisingAgain AS (
SELECT name, gender, SUM(count),
	RANK() OVER(ORDER BY SUM(count)) as rank
FROM StateBabyNames
WHERE year >= 2000
GROUP BY name, gender
)
SELECT hp.name, hp.gender
FROM HistoricalPopularity hp
INNER JOIN OutofStyle os ON os.name = hp.name AND os.gender = hp.gender
INNER JOIN RisingAgain ra ON ra.name = os.name AND ra.gender = os.gender
WHERE hp.rank <= 5
		AND os.rank > 5
		AND ra.rank <= 1000