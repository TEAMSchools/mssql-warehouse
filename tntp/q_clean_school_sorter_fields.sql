with
  remove_footnotes as (
    select
      field,
      stuff(field, len(field), 1, '') as new_field
    from
      gabby.tntp.teacher_survey_school_sorter
    where
      isnumeric(right(field, 1)) = 1
      and right(field, 1) <> '.'
      and field not in ('Offer by Aug 1', 'Offer by July 1', 'Offer by June 1', 'Offer by May 1')
  ),
  remove_ending_period as (
    select
      field,
      stuff(field, len(field), 1, '') as new_field
    from
      gabby.tntp.teacher_survey_school_sorter
    where
      right(field, 1) = '.'
  )
  -- UPDATE remove_footnotes
  -- SET field = new_field
  -- UPDATE remove_ending_period
  -- SET field = new_field
