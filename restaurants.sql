--Where I have not eaten recently
SELECT * FROM not_recent;

--...and where I have
SELECT * FROM recent_meals;

--Add recent dining experience
INSERT INTO meals (id, restaurant_id, notes) VALUES (
    to_char(current_date, 'YYYYMMDD')::int /* replace with date string if not today! */
    , (SELECT id FROM restaurants WHERE restaurant_name ILIKE '%%' LIMIT 1)
    , null /* replace  with any pertinent notes about experience */
) RETURNING *;

--Add new restaurants
INSERT INTO restaurants
    (restaurant_name, cuisine, cost, website, notes) VALUES (
    ''    /* restaurant_name */
    , ''  /* cuisine */
    , 'cheap/moderate/expensive' /* cost */
    , ''  /* website */
    , null  /* notes */
) RETURNING *;

--Updating notes for existing restaurants
UPDATE restaurants
    SET notes = ''
        --, cuisine = ''
        --, website = ''
        --, active = True/False
WHERE restaurant_name ILIKE '%%'
RETURNING *;

--Select a restaurant at random
SELECT
    restaurant_name
    , cuisine
FROM restaurants
OFFSET floor(random() * (SELECT count(*) FROM restaurants))
LIMIT 1;

--List restaurants that you have not eaten at
SELECT restaurant_name
FROM restaurants r
LEFT OUTER JOIN meals m ON r.id = m.restaurant_id
WHERE m.id IS NULL;

--Simple analytics about places most eaten at
SELECT
    r.restaurant_name AS restaurant
    , count(m.restaurant_id) AS times_eaten
    , to_date(max(m.id)::TEXT, 'YYYYMMDD') AS last_eaten
FROM meals m
INNER JOIN restaurants r ON r.id = m.restaurant_id
GROUP BY 1
HAVING count(m.restaurant_id) >= 5
ORDER BY 2 DESC, 3 DESC;