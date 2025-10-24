CREATE TABLE IF NOT EXISTS "collections" (
    "id" INTEGER PRIMARY KEY,
    "title" TEXT NOT NULL,
    "accession_number" TEXT NOT NULL UNIQUE,
    "acquired" NUMERIC
);

CREATE TABLE IF NOT EXISTS "artists" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "created" (
    "artist_id" INTEGER,
    "collection_id" INTEGER,
    PRIMARY KEY ("artist_id", "collection_id"),
    FOREIGN KEY ("artist_id") REFERENCES "artists"("id") ON DELETE CASCADE,
    FOREIGN KEY ("collection_id") REFERENCES "collections"("id") ON DELETE CASCADE
);
