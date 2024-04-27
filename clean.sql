BEGIN;

INSERT INTO sun_table_final
SELECT DISTINCT ON (DATE(to_timestamp((raw_json ->> 'dt')::BIGINT) AT TIME ZONE 'PDT'))
    to_timestamp((raw_json -> 'sys' ->> 'sunset')::BIGINT) AT TIME ZONE 'PDT',
    to_timestamp((raw_json -> 'sys' ->> 'sunrise')::BIGINT) AT TIME ZONE 'PDT',
    to_timestamp((raw_json ->> 'dt')::BIGINT) AT TIME ZONE 'PDT',
    (raw_json -> 'sys' ->> 'id')::BIGINT,
    (raw_json -> 'sys' ->> 'type')::BIGINT,
    (to_timestamp((raw_json ->> 'dt')::BIGINT) AT TIME ZONE 'PDT')::DATE
FROM my_scraper;


INSERT INTO weather_desc_table (weather_id, weather_icon, weather_main, weather_description)
SELECT DISTINCT ON ((raw_json -> 'weather' -> 0 ->> 'id')::BIGINT)
    (raw_json -> 'weather' -> 0 ->> 'id')::BIGINT,
    (raw_json -> 'weather' -> 0 ->> 'icon')::VARCHAR(255),
    (raw_json -> 'weather' -> 0 ->> 'main')::VARCHAR(255),
    (raw_json -> 'weather' -> 0 ->> 'description')::VARCHAR(255)
FROM my_scraper;


INSERT INTO location_table (city_id, city_name, cod, lat, long, timezone, country)
SELECT DISTINCT ON (raw_json -> 'id')
    (raw_json -> 'id')::BIGINT AS city_id,
    (raw_json -> 'name')::TEXT AS city_name,
    (raw_json -> 'cod')::BIGINT AS cod,
    (raw_json -> 'coord' ->> 'lat')::DOUBLE PRECISION AS lat,
    (raw_json -> 'coord' ->> 'lon')::DOUBLE PRECISION AS long,
    (raw_json -> 'timezone')::BIGINT AS timezone,
    (raw_json -> 'sys' -> 'country')::TEXT AS country
FROM my_scraper;


INSERT INTO weather_table (wind_deg, wind_gust, wind_speed, main_temp, main_humidity, 
                           main_pressure, main_temp_max, main_temp_min, main_feels_like, 
                           clouds_all, visibility, city_id, date_time, date_, weather_id, time_)
SELECT DISTINCT ON (to_timestamp((raw_json ->> 'dt')::BIGINT) AT TIME ZONE 'PDT')
    (raw_json -> 'wind' ->> 'deg')::BIGINT AS wind_deg,
    (raw_json -> 'wind' ->> 'gust')::DOUBLE PRECISION AS wind_gust,
    (raw_json -> 'wind' ->> 'speed')::DOUBLE PRECISION AS wind_speed,
    (raw_json -> 'main' ->> 'temp')::DOUBLE PRECISION AS main_temp,
    (raw_json -> 'main' ->> 'humidity')::BIGINT AS main_humidity,
    (raw_json -> 'main' ->> 'pressure')::BIGINT AS main_pressure,
    (raw_json -> 'main' ->> 'temp_max')::DOUBLE PRECISION AS main_temp_max,
    (raw_json -> 'main' ->> 'temp_min')::DOUBLE PRECISION AS main_temp_min,
    (raw_json -> 'main' ->> 'feels_like')::DOUBLE PRECISION AS main_feels_like,
    (raw_json -> 'clouds' ->> 'all')::BIGINT AS clouds_all,
    (raw_json ->> 'visibility')::BIGINT AS visibility,
    (raw_json ->> 'id')::BIGINT AS city_id,
    to_timestamp((raw_json ->> 'dt')::BIGINT) AT TIME ZONE 'PDT' AS date_time,
    (to_timestamp((raw_json ->> 'dt')::BIGINT) AT TIME ZONE 'PDT')::DATE AS date_,
    (raw_json -> 'weather' -> 0 ->> 'id')::BIGINT AS weather_id,
    (to_timestamp((raw_json ->> 'dt')::BIGINT) AT TIME ZONE 'PDT')::TIME AS time_
FROM my_scraper;


DELETE FROM my_scraper;


COMMIT;
