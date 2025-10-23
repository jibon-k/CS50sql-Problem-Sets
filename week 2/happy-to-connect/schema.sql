CREATE TABLE "users" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "username" TEXT UNIQUE NOT NULL,
    "password" TEXT NOT NULL,
    PRIMARY KEY("id")
);


CREATE TABLE "education" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "year_founded" INTEGER NOT NULL,
    PRIMARY KEY("id")
);


CREATE TABLE "companies" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "industry" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    PRIMARY KEY("id")
);


CREATE TABLE "connections" (
    "id" INTEGER,
    "user_id1" INTEGER NOT NULL,
    "user_id2" INTEGER NOT NULL,
    "connected_at" DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY ("user_id1") REFERENCES "users"("id"),
    FOREIGN KEY ("user_id2") REFERENCES "users"("id"),
    UNIQUE(user_id1, user_id2),
    CHECK (user_id1 != user_id2)
);


CREATE TABLE "user_education" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "education_id" INTEGER NOT NULL,
    "start_date" NUMERIC NOT NULL,
    "end_date" NUMERIC,
    "degree_type" TEXT,
    PRIMARY KEY("id"),
    FOREIGN KEY ("user_id") REFERENCES "users"("id"),
    FOREIGN KEY ("education_id") REFERENCES "education"("id")
);


CREATE TABLE "user_companies" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "company_id" INTEGER NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" NUMERIC,
    "title" TEXT NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY ("user_id") REFERENCES "users"("id"),
    FOREIGN KEY ("company_id") REFERENCES "companies"("id")
);
