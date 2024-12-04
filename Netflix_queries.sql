--Netflix Project 
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix 
(
	show_id	VARCHAR(6), --defining the data types for each of these columns
	type 	VARCHAR (10),
	title	VARCHAR(150),
	director VARCHAR(208),
	casts	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),	
	release_year  INT,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(100),
	description	VARCHAR(250)
);
SELECT * FROM netflix ;

SELECT 
	COUNT(*) as total_content 
FROM netflix ;

SELECT 
	DISTINCT type 
FROM netflix;

SELECT * FROM netflix ;

--15 BUISNESS PROBLEMS -->

-- 1. Count the number of Movies vs TV shows

SELECT
	type,
	COUNT(*) as total_content 
FROM netflix
GROUP BY type

--2. Find the most common rating for the movies and the TV shows 

SELECT 
	type,
	rating
FROM
(
SELECT 
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1,2
-- ORDER BY 1,3 DESC
) as t1

WHERE
	ranking=1

--3.List all movies released in a specific year (eg.2020)

--filter 2020 
--movies 
SELECT*FROM netflix
WHERE 
	type = 'Movie'
	AND -- both conditions should be true 
	release_year = 2020

--4. Find the top 5 countries with the most content on Netflix 

SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

ORDER BY 2 DESC
LIMIT 5

--5.Identify the longest movie --->

SELECT*FROM netflix
WHERE 
	type  = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)

--6.Find content added in the last 5 years 

SELECT

	*
FROM netflix
WHERE
	TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL'5 years' -- RETURNS THE FIVE YEARS OLD DATE 

--7.Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT*FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%' --this also works when the movie or show is directed by more than one director including Rajiv Chilaka
-- ILIKE is better to use than LIKE since if a new entry is made with r lower case in Rajiv , ILIKE will still work 

--8.List all TV shows with more than 5 seasons

SELECT
	*
FROM netflix 
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration,' ',1)::numeric> 5 --we cannot compare text so we have to split the number and the word season and then compare --->

--9.Count the number of content items in each genre 

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	COUNT(show_id)
FROM netflix
GROUP by 1

--10.Find each year and the average numbers of content release by India on netflix.return top 5 with highest average content release!

SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix where country = 'India')::numeric * 100,2) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
	
--11.List all movies that are documentaries

SELECT*FROM netflix
WHERE
	listed_in ILIKE '%documentaries%'


--12.Find all the content without a director 

SELECT * FROM netflix 
WHERE
	director IS NULL 

--13.Find how many movies actor salman khan appear in the last 10 years

SELECT*FROM netflix 
WHERE 
	casts ILIKE '%SALMAN Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10

--14.Find the top 10 actors who have appeared int the highest number of movies produced in India. 
SELECT 
UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10 -- for limiting to top 10 actors 

-- 15.categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad'
-- and all other content as 'Good'.count how many items fall into each 
WITH new_table
AS
(
SELECT 
*,
	CASE
	WHEN 
		description ILIKE '%kill%' OR 
		description ILIKE '%violence%' THEN 'Bad_Content'
		ELSE 'Good_Content'
	END category
FROM netflix 
)
SELECT 
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1