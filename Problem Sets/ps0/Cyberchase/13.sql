/* Write a SQL query to retrieve the titles and topics of episodes published
between 2002 and 2010 (inclusive) that are on the topic 'data'. */
SELECT "title"
FROM "episodes"
WHERE "air_date"
BETWEEN '2002-01-01' AND '2010-12-31'
AND "topic" LIKE '%data%';
