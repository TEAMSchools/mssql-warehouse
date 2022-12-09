with
  scaffold as (
    select
      t.df_employee_number,
      t.preferred_lastfirst,
      t.legal_entity_name,
      t.location,
      t.job_title,
      t.email_address,
      t.academic_year,
      year(t.date_value) as calendar_year,
      datename(month, t.date_value) as month_text,
      month(t.date_value) as month_num,
      sum(hours_worked) as month_hours_worked,
      count(t.date_value) * 9.5 as month_possible_hours
    from
      gabby.tableau.staff_tracker t
    group by
      t.df_employee_number,
      t.preferred_lastfirst,
      t.legal_entity_name,
      t.location,
      t.job_title,
      t.email_address,
      t.academic_year,
      year(t.date_value),
      month(t.date_value),
      datename(month, t.date_value)
  ),
  days_table as (
    select
      p.df_employee_number,
      p.academic_year,
      p.month_num,
      p.month_max_days,
      coalesce([1], 0) as day_1,
      coalesce([2], 0) as day_2,
      coalesce([3], 0) as day_3,
      coalesce([4], 0) as day_4,
      coalesce([5], 0) as day_5,
      coalesce([6], 0) as day_6,
      coalesce([7], 0) as day_7,
      coalesce([8], 0) as day_8,
      coalesce([9], 0) as day_9,
      coalesce([10], 0) as day_10,
      coalesce([11], 0) as day_11,
      coalesce([12], 0) as day_12,
      coalesce([13], 0) as day_13,
      coalesce([14], 0) as day_14,
      coalesce([15], 0) as day_15,
      coalesce([16], 0) as day_16,
      coalesce([17], 0) as day_17,
      coalesce([18], 0) as day_18,
      coalesce([19], 0) as day_19,
      coalesce([20], 0) as day_20,
      coalesce([21], 0) as day_21,
      coalesce([22], 0) as day_22,
      coalesce([23], 0) as day_23,
      coalesce([24], 0) as day_24,
      coalesce([25], 0) as day_25,
      coalesce([26], 0) as day_26,
      coalesce([27], 0) as day_27,
      coalesce([28], 0) as day_28,
      case
        when month_max_days >= 29 then coalesce([29], 0)
      end as day_29,
      case
        when month_max_days >= 30 then coalesce([30], 0)
      end as day_30,
      case
        when month_max_days = 31 then coalesce([31], 0)
      end as day_31
    from
      (
        select
          df_employee_number,
          academic_year,
          hours_worked,
          month(date_value) as month_num,
          day(date_value) as day_num,
          day(eomonth(date_value)) as month_max_days
        from
          gabby.tableau.staff_tracker
      ) sub pivot (
        sum(hours_worked) for day_num in (
          [1],
          [2],
          [3],
          [4],
          [5],
          [6],
          [7],
          [8],
          [9],
          [10],
          [11],
          [12],
          [13],
          [14],
          [15],
          [16],
          [17],
          [18],
          [19],
          [20],
          [21],
          [22],
          [23],
          [24],
          [25],
          [26],
          [27],
          [28],
          [29],
          [30],
          [31]
        )
      ) p
  )
select
  s.df_employee_number,
  s.preferred_lastfirst,
  s.legal_entity_name,
  s.location,
  s.job_title,
  s.email_address,
  s.academic_year,
  s.month_num,
  s.month_text,
  s.calendar_year,
  s.month_hours_worked,
  s.month_possible_hours,
  s.month_possible_hours - s.month_hours_worked as month_hours_not_worked,
  cast(round((s.month_hours_worked / s.month_possible_hours) * 100, 0) as int) as month_percent_worked,
  cast(
    round(((s.month_possible_hours - s.month_hours_worked) / s.month_possible_hours) * 100, 0) as int
  ) as month_percent_not_worked,
  d.month_max_days,
  d.day_1,
  d.day_2,
  d.day_3,
  d.day_4,
  d.day_5,
  d.day_6,
  d.day_7,
  d.day_8,
  d.day_9,
  d.day_10,
  d.day_11,
  d.day_12,
  d.day_13,
  d.day_14,
  d.day_15,
  d.day_16,
  d.day_17,
  d.day_18,
  d.day_19,
  d.day_20,
  d.day_21,
  d.day_22,
  d.day_23,
  d.day_24,
  d.day_25,
  d.day_26,
  d.day_27,
  d.day_28,
  d.day_29,
  d.day_30,
  d.day_31
from
  scaffold s
  left join days_table d on s.df_employee_number = d.df_employee_number
  and s.academic_year = d.academic_year
  and s.month_num = d.month_num
