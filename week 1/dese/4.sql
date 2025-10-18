SELECT "city", count("id") AS "number_of_schools"
FROM "schools"
GROUP BY "city"
ORDER BY "number_of_schools" DESC, "city" ASC
LIMIT 10;