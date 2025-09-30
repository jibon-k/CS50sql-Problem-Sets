SELECT COUNT("english_title") AS "count_of_fuji"
FROM "views"
WHERE "artist" IS 'Hokusai'
AND "english_title" LIKE '%Fuji%';
