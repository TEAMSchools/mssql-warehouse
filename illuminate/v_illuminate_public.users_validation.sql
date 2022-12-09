USE gabby;

GO
CREATE OR ALTER VIEW
  illuminate_public.users_validation AS
SELECT
  user_id
FROM
  OPENQUERY (ILLUMINATE, '
  SELECT user_id
  FROM public.users
');
