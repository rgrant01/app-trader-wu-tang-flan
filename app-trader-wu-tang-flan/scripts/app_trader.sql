-- General data from both tables -- 

SELECT *
FROM app_store_apps;

SELECT *
FROM play_store_apps;

-- Overall comparison between shared apps -- 

SELECT DISTINCT(a.name), p.name, a.price, p.price, a.primary_genre,
p.genres, a.content_rating, p.content_rating, a.rating, p.rating,
a.review_count, p.review_count, p.install_count
FROM app_store_apps AS a 
FULL OUTER JOIN play_store_apps AS p
ON a.name = p.name
WHERE a.name IS NOT null AND p.name IS NOT null;

--------- Debbie: FINAL EVALUATION USING CTEs-329 rows--getting extra column of price app trader will pay for app=purchase price * 10K, ordered by importance to app trader---
WITH app AS
(SELECT
	name,avg(rating) as app_avg_rating,round(SUM(cast(review_count as int)),2) as app_total_reviews,round(avg(price),2) as app_avg_price
FROM app_store_apps
 GROUP BY name
), play as
(SELECT
	name,genres,content_rating,avg(rating) as play_avg_rating,round(SUM(cast(review_count as int)),2) as play_total_reviews,avg(CAST(REPLACE(price,'$','')AS float)) as play_avg_price
FROM play_store_apps
 GROUP BY name,genres,content_rating
)
SELECT a.name,p.genres,p.content_rating,round(a.app_avg_rating,2) as app_avg_rating ,round(p.play_avg_rating,2) as play_avg_rating,trunc(a.app_total_reviews) as app_all_reviews,trunc(p.play_total_reviews) as play_all_reviews,TRUNC((app_total_reviews+play_total_reviews)/2) as all_total_reviews,a.app_avg_price,p.play_avg_price,
	CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END AS App_trader_purchase_price
FROM app as a
INNER JOIN play as p
ON a.name = p.name
ORDER BY app_avg_rating DESC,play_avg_rating DESC,all_total_reviews DESC,app_avg_price DESC;

-- Expected profits from both app stores -------------------------------------------------------------------------------------------------------------------------------------------------------

-- app store -- 
SELECT primary_genre, COUNT(primary_genre), ROUND(AVG(
CASE WHEN price < 1 
	THEN 1500*(12*(1+2*rating)) - 10000 
ELSE 1500*(12*(1+2*rating)) - 10000 * price 
	END),2) as avg_expected_profit
FROM app_store_apps
GROUP BY primary_genre
ORDER BY avg_expected_profit DESC;

-- play store -- 
SELECT category, COUNT(category), ROUND(AVG(
CASE WHEN CAST(TRIM(REPLACE(price, '$', '')) AS numeric) < 1 
	THEN 1500*(12*(1+2*CAST(rating AS numeric))) - 10000
WHEN CAST(TRIM(REPLACE(price, '$', '')) AS numeric) >= 1 
	THEN 1500*(12*(1+2*CAST(rating AS numeric))) - 10000 * CAST(TRIM(REPLACE(price, '$', '')) AS numeric) 
	END),2) as avg_expected_profit
FROM play_store_apps
WHERE rating IS NOT NULL
GROUP BY category
ORDER BY avg_expected_profit DESC;
/* Alternatively order by count of genres */

-- Most expensive apps -- 

-- app store -- 
SELECT name, primary_genre, price
FROM app_store_apps AS a
GROUP BY a.name, a.primary_genre, a.price
ORDER BY price DESC

-- play store -- 
SELECT name, genres, (CAST(REPLACE(price,'$','') AS numeric)) As price
FROM play_store_apps AS p
GROUP BY p.name, p.genres, p.price
ORDER BY price DESC;

-----------------------------------------------------------------------------------------------------------------------------------------

-- Expected profit by content rating -- same as query for category/genre, just plug content rating -- 

-- app store -- 
SELECT content_rating, COUNT(content_rating), ROUND(AVG(
CASE WHEN price < 1 
	THEN 1500*(12*(1+2*rating)) - 10000 
ELSE 1500*(12*(1+2*rating)) - 10000 * price 
	END),2) as avg_expected_profit
FROM app_store_apps
GROUP BY content_rating
ORDER BY COUNT(content_rating) DESC;


-- play store -- 

SELECT  content_rating, COUNT(content_rating), ROUND(AVG(
CASE WHEN CAST(TRIM(REPLACE(price, '$', '')) AS numeric) < 1 
	THEN 1500*(12*(1+2*CAST(rating AS numeric))) - 10000
WHEN CAST(TRIM(REPLACE(price, '$', '')) AS numeric) >= 1 
	THEN 1500*(12*(1+2*CAST(rating AS numeric))) - 10000 * CAST(TRIM(REPLACE(price, '$', '')) AS numeric) 
	END),2) as avg_expected_profit
FROM play_store_apps AS p
WHERE rating IS NOT NULL
GROUP BY content_rating
ORDER BY avg_expected_profit DESC;



SELECT DISTINCT(a.name), p.name, a.price, p.price, a.primary_genre,
p.genres, a.content_rating, p.content_rating, a.rating, p.rating,
a.review_count, p.review_count, p.install_count, ROUND(AVG(
CASE WHEN a.price < 1 
	THEN 1500*(12*(1+2*a.rating)) - 10000 
ELSE 1500*(12*(1+2*a.rating)) - 10000 * a.price 
	END),2) as avg_expected_profit_app,
ROUND(AVG(
CASE WHEN CAST(TRIM(REPLACE(p.price, '$', '')) AS numeric) < 1 
	THEN 1500*(12*(1+2*CAST(p.rating AS numeric))) - 10000
WHEN CAST(TRIM(REPLACE(p.price, '$', '')) AS numeric) >= 1 
	THEN 1500*(12*(1+2*CAST(p.rating AS numeric))) - 10000 * CAST(TRIM(REPLACE(p.price, '$', '')) AS numeric) 
	END),2) as avg_expected_profit_play
	FROM app_store_apps AS a 
FULL OUTER JOIN play_store_apps AS p
ON a.name = p.name
WHERE a.name IS NOT null AND p.name IS NOT null
GROUP BY a.name, p.name, a.price, p.price, a.primary_genre,
p.genres, a.content_rating, p.content_rating, a.rating, p.rating,
a.review_count, p.review_count, p.install_count
ORDER BY avg_expected_profit_play DESC;

