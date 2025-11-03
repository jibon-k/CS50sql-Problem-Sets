SELECT "from_user_id" FROM "messages"
GROUP BY "to_user_id"
ORDER BY count(*) DESC
LIMIT 1;