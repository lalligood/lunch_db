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
WHERE restaurant_name = ''
RETURNING *;

--Add recent dining experience
INSERT INTO meals (id, restaurant_id, notes) VALUES (
    current_date /* replace with date string if not today! */
    , (SELECT id FROM restaurants WHERE restaurant_name ILIKE '%' LIMIT 1)
    , null /* replace  with any pertinent notes about experience */
) RETURNING *;

--Select a restaurant at random
WITH cnt AS (
    SELECT
        count(*) AS y
        , random() AS x
    FROM restaurants
)
SELECT
    r.*
FROM restaurants r, cnt
WHERE id = floor(cnt.x * (cnt.y + 1)) + 9
LIMIT 1;

--List restaurants that you have not eaten at
SELECT restaurant_name
FROM restaurants r
LEFT OUTER JOIN meals m ON r.id = m.restaurant_id
WHERE m.id IS NULL