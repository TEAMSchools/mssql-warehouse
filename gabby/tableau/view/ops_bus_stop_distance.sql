CREATE OR ALTER VIEW
  tableau.ops_bus_stop_distance AS
SELECT
  student_number AS student_id,
  location_type,
  location_name AS bus_stop_name,
  distance AS distance_to_bus_stop,
  RANK() OVER (
    PARTITION BY
      student_number
    ORDER BY
      distance ASC
  ) AS distance_rank,
  ROW_NUMBER() OVER (
    PARTITION BY
      student_number
    ORDER BY
      distance ASC
  ) AS distance_rank_unique
FROM
  ops.bus_stop_distance
