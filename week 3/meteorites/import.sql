CREATE TABLE IF NOT EXISTS "meteorites" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "class" TEXT NOT NULL,
    "mass" NUMERIC,
    "discovery" TEXT NOT NULL,
    "year" INTEGER,
    "lat" NUMERIC,
    "long" NUMERIC,
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "temp" (
    "name" TEXT NOT NULL,
    "id" INTEGER,
    "nametype" TEXT NOT NULL,
    "class" TEXT NOT NULL,
    "mass" NUMERIC,
    "discovery" TEXT NOT NULL,
    "year" INTEGER,
    "lat" NUMERIC,
    "long" NUMERIC
);

DELETE FROM "temp"
WHERE "nametype" = 'Relict';


UPDATE "temp"
SET
    "mass" = NULLIF(TRIM("mass"), ''),
    "year" = NULLIF(TRIM("year"), ''),
    "lat"  = NULLIF(TRIM("lat"), ''),
    "long" = NULLIF(TRIM("long"), '');

UPDATE "temp"
SET
    "mass" = ROUND("mass", 2),
    "lat"  = ROUND("lat", 2),
    "long" = ROUND("long", 2);

INSERT INTO "meteorites" ("name", "class", "mass", "discovery", "year", "lat", "long")
SELECT "name", "class", "mass", "discovery", "year", "lat", "long"
FROM (SELECT * FROM "temp"  
    ORDER BY "year" ASC, "name" ASC
);

DROP TABLE "temp";