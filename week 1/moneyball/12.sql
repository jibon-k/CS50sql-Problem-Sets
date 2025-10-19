SELECT
    "players"."first_name",
    "players"."last_name"
FROM "players"
JOIN (
    SELECT "players"."id"
    FROM "players"
    JOIN "salaries" ON "players"."id" = "salaries"."player_id"
    JOIN "performances" ON "players"."id" = "performances"."player_id"
                       AND "salaries"."year" = "performances"."year"
                       AND "salaries"."team_id" = "performances"."team_id"
    WHERE "salaries"."year" = 2001
      AND "performances"."H" > 0
    ORDER BY "salaries"."salary" / "performances"."H" ASC
    LIMIT 10
) AS "hit_players" ON "players"."id" = "hit_players"."id"
JOIN (
    SELECT "players"."id"
    FROM "players"
    JOIN "salaries" ON "players"."id" = "salaries"."player_id"
    JOIN "performances" ON "players"."id" = "performances"."player_id"
                       AND "salaries"."year" = "performances"."year"
                       AND "salaries"."team_id" = "performances"."team_id"
    WHERE "salaries"."year" = 2001
      AND "performances"."RBI" > 0
    ORDER BY "salaries"."salary" / "performances"."RBI" ASC
    LIMIT 10
) AS "rbi_players" ON "players"."id" = "rbi_players"."id"
ORDER BY "players"."id" ASC;
