-- Insert a fake log first
INSERT INTO "user_logs" ("type", "old_username", "new_username", "old_password", "new_password")
VALUES ('update', 'admin', 'admin', 
        (SELECT "password" FROM "users" WHERE "username" = 'admin'),
        (SELECT "password" FROM "users" WHERE "username" = 'emily33'));

-- Change the admin password to 'oops!'
UPDATE "users" 
SET "password" = '982c0381c279d139fd221fce974916e7' 
WHERE "username" = 'admin';

-- Create the log created by changing the password leaving the fake log
DELETE FROM "user_logs"
WHERE "new_username" = 'admin'
  AND "new_password" = (
      SELECT "password" FROM "users" 
      WHERE "username" = 'admin'
  );