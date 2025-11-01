CREATE VIEW "frequently_reviewed" AS
SELECT "listings"."id",
       "listings"."property_type", 
       "listings"."host_name",
       "review_counts"."reviews"
FROM "listings"
JOIN (
    SELECT "listing_id", COUNT(*) as "reviews"
    FROM "reviews" 
    GROUP BY "listing_id"
) AS "review_counts" ON 
    "review_counts"."listing_id" = "listings"."id"
ORDER BY "review_counts"."reviews" DESC
LIMIT 100;