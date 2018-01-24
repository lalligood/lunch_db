--DROP TABLE IF EXISTS meals CASCADE;

CREATE TABLE meals
(
    id text PRIMARY KEY DEFAULT TO_CHAR(current_date, 'YYYYMMDD')::int
    , restaurant_id uuid NOT NULL
    , times_eaten integer NOT NULL DEFAULT 1
    , notes text
);

CREATE INDEX meals_restaurants_id ON meals (restaurant_id);

--DROP TABLE restaurants CASCADE;

CREATE TABLE restaurants
(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4()
    , restaurant_name text UNIQUE NOT NULL
    , cuisine text NOT NULL
    , cost text NOT NULL
    , website text
    , notes text
    , active boolean DEFAULT true
);

CREATE INDEX restaurants_name ON restaurants (restaurant_name);

DROP TABLE IF EXISTS dates;

CREATE TABLE dates (
    id int primary key
    , "date" date
    , date_text text
    , "year" int
    , quarter text
    , "month" int
    , month_text text
    , isoweek int
    , week_of_month int
    , day_of_month int
    , day_of_year int
    , day_text text
    , end_of_month date
);

CREATE INDEX IF NOT EXISTS dates_date ON dates
    (date);
CREATE INDEX IF NOT EXISTS dates_year_month_dom ON dates
    (year, month, day_of_month);
CREATE INDEX IF NOT EXISTS dates_year_quarter ON dates
    (year, quarter);
CREATE INDEX IF NOT EXISTS dates_year_isoweek ON dates
    (year, isoweek);

INSERT INTO dates
    (id, date, date_text, year, quarter, month, month_text, isoweek
    , week_of_month, day_of_month, day_of_year, day_text, end_of_month)
SELECT
    TO_CHAR(daterow::date, 'YYYYMMDD')::int AS id
    , daterow::date AS date
    , TO_CHAR(daterow::date, 'FMDay, FMMonth FMDDth, YYYY') AS date_text
    , TO_CHAR(daterow::date, 'YYYY')::int AS year
    , 'Q' || TO_CHAR(daterow::date, 'Q') AS quarter
    , TO_CHAR(daterow::date, 'MM')::int AS month
    , TO_CHAR(daterow::date, 'Month') AS month_text
    , TO_CHAR(daterow::date, 'IW')::int AS isoweek
    , TO_CHAR(daterow::date, 'W')::int AS week_of_month
    , TO_CHAR(daterow::date, 'DD')::int AS day_of_month
    , TO_CHAR(daterow::date, 'DDD')::int AS day_of_year
    , TO_CHAR(daterow::date, 'Day') AS day_text
    , (DATE_TRUNC('month', (daterow::date + INTERVAL '1 months')) - INTERVAL '1 days')::date AS end_of_month
FROM GENERATE_SERIES(DATE '2000-01-01', '2029-12-31', '1 day') AS daterow
;

--DROP VIEW recent_meals;

CREATE OR REPLACE VIEW public.recent_meals AS (
    SELECT
        d.date
        , r.restaurant_name AS restaurant
        , COALESCE(m.notes, r.notes) AS notes
    FROM meals m
    JOIN restaurants r ON r.id = m.restaurant_id
    JOIN dates d ON d.id = m.id
    WHERE d.date >= (current_date - 45)
    ORDER BY m.id DESC
);

-- DROP VIEW not_recent;

CREATE OR REPLACE VIEW public.not_recent AS
WITH rm AS (
    SELECT
        MAX(d.date) AS date
        , m.restaurant_id
    FROM meals m
    JOIN dates d ON d.id = m.id
    GROUP BY m.restaurant_id
)
SELECT r.restaurant_name
    , r.cuisine
    , r.website
    , r.notes
    , COALESCE((current_date - rm.date), 0) AS days_since_last_visit
FROM restaurants r
LEFT OUTER JOIN rm ON rm.restaurant_id = r.id
WHERE COALESCE((current_date - rm.date), -1) NOT BETWEEN 0 AND 44
    AND r.active = true
ORDER BY 5 DESC;
