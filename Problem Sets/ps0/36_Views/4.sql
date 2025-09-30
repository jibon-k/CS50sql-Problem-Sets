SELECT COUNT("english_title") AS "count_of_edo"
FROM "views"
WHERE "artist" IS 'Hiroshige'
AND "english_title" LIKE '%Eastern Capital%';
