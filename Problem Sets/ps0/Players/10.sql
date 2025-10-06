SELECT
    first_name || ' ' || last_name AS "player_name",
    height AS "height_inches",
    ROUND(height * 2.54, 1) AS "height_cm",
    weight AS "weight_lbs",
    ROUND(weight * 0.453592, 1) AS "weight_kg",
    birth_country AS "origin_country",
    debut AS "first_mlb_game",
    final_game AS "last_mlb_game"
FROM "players"
WHERE ("bats" = 'L' OR "bats" = 'R')
    AND "birth_country" != 'USA'
    AND "height" IS NOT NULL
    AND "weight" IS NOT NULL
ORDER BY "height" DESC, "weight" DESC, "last_name" ASC;
