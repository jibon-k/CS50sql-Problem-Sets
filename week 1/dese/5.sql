SELECT "city", count("id") AS "number_of_schools"
FROM "schools"
WHERE "type" = 'Public School'
GROUP BY "city"
HAVING count("id") <= 3
ORDER BY "number_of_schools" DESC, "city" ASC;