-- Data analysis questions for the dataset
USE DATABASE TEST_DATABASE;
USE SCHEMA TEST_SCHEMA;

SELECT * FROM tbl_yelp_reviews LIMIT 10;
SELECT * FROM tbl_yelp_businesses LIMIT 10;

--1) Find number of businesses in each category

SELECT TRIM(C.value)::STRING AS category, COUNT(1)
FROM tbl_yelp_businesses,
     LATERAL SPLIT_TO_TABLE(categories, ',') C
GROUP BY 1
ORDER BY 2 DESC;


--2) Find top 10 users who have reviewed the most businesses in the "Restaurants" category

SELECT r.user_id, COUNT(DISTINCT b.business_id)
FROM tbl_yelp_reviews r
    JOIN tbl_yelp_businesses b ON r.business_id = b.business_id
WHERE b.categories ILIKE '%restaurant%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


--3) Find the most popular categories of businesses (based on the number of reviews)

SELECT TRIM(C.value)::STRING AS category, COUNT(*) AS review_count
FROM tbl_yelp_businesses b
    CROSS JOIN LATERAL SPLIT_TO_TABLE(b.categories, ',') C
    JOIN tbl_yelp_reviews r ON b.business_id = r.business_id
GROUP BY category
ORDER BY review_count DESC;



--4) Find the top 3 most recent reviews for each business

SELECT r.*, b.name,
       row_number() OVER (PARTITION BY r.business_id ORDER BY r.review_date DESC) AS rn
FROM tbl_yelp_reviews r
    JOIN tbl_yelp_businesses b ON r.business_id = b.business_id
QUALIFY rn IN (1, 2, 3);


--5) Find the month with the highest number of reviews

SELECT MONTH(review_date) AS month, COUNT(1)
FROM tbl_yelp_reviews
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


--6) Find the percentage of 5-star reviews for each business

SELECT b.business_id, b.name,
       COUNT(*) AS total_reviews,
       COUNT(CASE WHEN r.star_rating = 5 THEN 1 END) AS five_star_reviews,
       ROUND(five_star_reviews / total_reviews::FLOAT * 100, 2) || '%' AS perc_5_star
FROM tbl_yelp_reviews r
    JOIN tbl_yelp_businesses b ON r.business_id = b.business_id
GROUP BY 1, 2
HAVING five_star_reviews > 0;


--7) Find the top 5 most reviewed businesses in each city
SELECT b.city, b.business_id, b.name,
       COUNT(*) AS review_count,
       ROW_NUMBER() OVER(PARTITION BY b.city ORDER BY COUNT(*)DESC) AS top_business_by_city
FROM tbl_yelp_businesses b
    JOIN tbl_yelp_reviews r ON b.business_id = r.business_id
GROUP BY ALL
QUALIFY top_business_by_city <= 5;


--8) Find the average rating of businesses that have at least 100 reviews

SELECT b.business_id, b.name,
       COUNT(*) AS total_reviews,
       ROUND(AVG(star_rating),2) AS avg_rating
FROM tbl_yelp_reviews r
    JOIN tbl_yelp_businesses b ON r.business_id=b.business_id
GROUP BY 1, 2
HAVING total_reviews >=100;


--9) List the top 10 users who have written the most reviews, along with the businesses they reviewed

SELECT r.user_id,
       COUNT(*) AS review_count,
       LISTAGG(b.name, ', ') AS reviewed_businesses
FROM tbl_yelp_reviews r
    JOIN tbl_yelp_businesses b ON r.business_id = b.business_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


--10) Find top 10 businesses with the highest positive sentiment reviews

SELECT r.business_id, b.name,
       count(*) AS review_count
FROM tbl_yelp_reviews r
    JOIN tbl_yelp_businesses b on r.business_id=b.business_id
WHERE sentiment= 'Positive'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;

