USE DATABASE TEST_DATABASE;
USE SCHEMA TEST_SCHEMA;

ALTER WAREHOUSE COMPUTE_WH SET WAREHOUSE_SIZE = 'XLARGE';
SHOW TABLES;

-- yelp_reviews table
CREATE OR REPLACE TABLE yelp_reviews (review_text variant);
DROP TABLE yelp_reviews;


-- Load the Yelp reviews data from S3 into the yelp_reviews table
COPY INTO yelp_reviews
    FROM 's3://yelp-dataset-test/'
    CREDENTIALS = (
    AWS_KEY_ID = 'AWS_ACCESS_KEY_ID'
    AWS_SECRET_KEY = 'AWS_SECRET_ACCESS'
    )
    FILE_FORMAT = (TYPE = JSON);


--Convert the JSON data into a structured table
CREATE OR REPLACE TABLE tbl_yelp_reviews AS
SELECT review_text:business_id::STRING AS business_id
,review_text:date::DATE AS review_date
,review_text:user_id::STRING AS user_id
,review_text:stars::NUMBER AS star_rating
,review_text:text::STRING AS review_text
,analyze_sentiment(review_text) AS sentiment -- Call the UDF to analyze sentiment and store the result in the sentiment column
FROM yelp_reviews;



-- yelp_businesses table
CREATE OR REPLACE TABLE yelp_businesses (business_text VARIANT);


COPY INTO yelp_businesses
    FROM 's3://yelp-dataset-test/yelp_academic_dataset_business.json'
    CREDENTIALS = (
    AWS_KEY_ID = 'AWS_ACCESS_KEY_ID'
    AWS_SECRET_KEY = 'AWS_SECRET_ACCESS'
    )
    FILE_FORMAT = (TYPE = JSON);


--Convert the JSON data into a structured table
CREATE OR REPLACE TABLE tbl_yelp_businesses AS
select business_text:business_id::STRING AS business_id
,business_text:name::STRING AS name
,business_text:city::STRING AS city
,business_text:state::STRING AS state
,business_text:review_count::STRING AS review_count
,business_text:stars::NUMBER AS stars
,business_text:categories::STRING AS categories
FROM yelp_businesses;


