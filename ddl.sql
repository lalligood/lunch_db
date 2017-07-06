--DROP TABLE IF EXISTS meals CASCADE;

CREATE TABLE meals
(
    id date PRIMARY KEY
    , restaurant_id uuid NOT NULL
    , times_eaten integer NOT NULL DEFAULT 1
    , notes text
);

CREATE INDEX meals_restaurants_id ON meals USING (restaurant_id);

--DROP TABLE restaurants CASCADE;

CREATE TABLE restaurants
(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4()
    , restaurant_name text UNIQUE NOT NULL
    , cuisine text NOT NULL
    , cost text NOT NULL
    , website text
    , notes text
);

CREATE INDEX restaurants_name ON restaurants USING (restaurant_name);
