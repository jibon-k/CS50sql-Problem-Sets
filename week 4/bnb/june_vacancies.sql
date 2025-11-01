CREATE VIEW "june_vacancies" AS
SELECT "listings"."id",
    "listings"."property_type",
    "listings"."host_name",
    "vacant_count"."days_vacant"
FROM "listings"
JOIN(
    SELECT "listing_id", count("id") AS "days_vacant" 
    FROM "availabilities"
    WHERE "date" BETWEEN '2023-06-01' AND '2023-06-30'
    GROUP BY "listing_id") AS "vacant_count"
ON "listings"."id" = "vacant_count"."listing_id";