CREATE OR ALTER VIEW
  illuminate_public.users_validation AS
SELECT
  USER_ID
FROM
  OPENQUERY (
    ILLUMINATE,
    '
  SELECT user_id
  FROM public.users
'
  );
