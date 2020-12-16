WITH remove_footnotes AS (
  SELECT field, STUFF(field, LEN(field), 1, '') AS new_field
  FROM gabby.tntp.teacher_survey_school_sorter
  WHERE ISNUMERIC(RIGHT(field,1)) = 1
    AND RIGHT(field,1) <> '.'
    AND field NOT IN ('Offer by Aug 1','Offer by July 1','Offer by June 1','Offer by May 1')
 )

,remove_ending_period AS (
  SELECT field, STUFF(field, LEN(field), 1, '') AS new_field
  FROM gabby.tntp.teacher_survey_school_sorter
  WHERE RIGHT(field,1) = '.'    
 )

--UPDATE remove_footnotes
--SET field = new_field

--UPDATE remove_ending_period
--SET field = new_field