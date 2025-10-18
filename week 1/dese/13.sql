SELECT 
    "districts"."name",
    "staff_evaluations"."exemplary",
    AVG("graduation_rates"."graduated") AS "average_graduated"
FROM "districts"
JOIN "staff_evaluations" ON "districts"."id" = "staff_evaluations"."district_id"
JOIN "schools" ON "districts"."id" = "schools"."district_id"
JOIN "graduation_rates" ON "schools"."id" = "graduation_rates"."school_id"
WHERE "staff_evaluations"."exemplary" IS NOT NULL
GROUP BY "districts"."id", "districts"."name", "districts"."type", "staff_evaluations"."exemplary"
ORDER BY "staff_evaluations"."exemplary" DESC
LIMIT 10;