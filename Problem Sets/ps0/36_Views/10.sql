SELECT
    english_title AS title,
    brightness AS light_level,
    contrast AS contrast_level
FROM views
WHERE artist = 'Hiroshige'
AND brightness > (
    SELECT AVG(brightness) FROM views
)
ORDER BY contrast DESC;
