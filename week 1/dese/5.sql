SELECT "city", count("id") AS "number_of_schools"
FROM "schools"
GROUP BY "city"
HAVING count("id") <= 3
ORDER BY "number_of_schools" DESC, "city" ASC;