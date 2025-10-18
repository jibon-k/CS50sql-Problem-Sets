SELECT "name" FROM "schools"
WHERE "id" IN (
    SELECT "id" FROM "graduation_rates"
    WHERE "graduated" = 100
);