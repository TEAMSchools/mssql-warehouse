CREATE OR ALTER VIEW
  extracts.illuminate_users AS
SELECT
  ps_teachernumber AS [01 User ID],
  preferred_last_name AS [02 User Last Name],
  preferred_first_name AS [03 User First Name],
  NULL AS [04 User Middle Name],
  NULL AS [05 Birth Date],
  NULL AS [06 Gender],
  userprincipalname AS [07 Email Address],
  samaccountname AS [08 Username],
  NULL AS [09 Password],
  df_employee_number AS [10 State User or Employee ID],
  NULL AS [11 Name suffix],
  NULL AS [12 Former First Name],
  NULL AS [13 Former Middle Name],
  NULL AS [14 Former Last Name],
  NULL AS [15 Primary Race],
  NULL AS [16 User is Hispanic],
  NULL AS [17 Address],
  legal_entity_name AS [18 City],
  NULL AS [19 State],
  NULL AS [20 Zip],
  primary_job AS [21 Job Title],
  NULL AS [22 Education Level],
  NULL AS [23 Hire Date],
  NULL AS [24 Exit Date],
  COALESCE(is_active_ad, 0) AS [25 Active],
  NULL AS [26 Position Status],
  NULL AS [27 Total Years Edu Service],
  NULL AS [28 Total Year In District],
  NULL AS [29 Email2],
  NULL AS [30 Phone1],
  NULL AS [31 Phone2]
FROM
  people.staff_crosswalk_static
