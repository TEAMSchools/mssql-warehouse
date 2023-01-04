CREATE OR ALTER VIEW
  deanslist.incidents_custom_fields_wide AS
SELECT
  incident_id,
  [Approver Name],
  [Behavior Category],
  [Board Approval Date],
  [Discipline Fields],
  [Doctor Approval],
  [Entered into SSDS (suspensions only)],
  [Final Approval],
  [HI end date],
  [HI start date],
  [Home Instruction Fields],
  [Hourly Rate],
  [Hours per Week],
  [Initial Trigger (antecedent)],
  [Instructor Name],
  [Instructor Source],
  [NJ State Reporting],
  [Others Involved],
  [Parent Contacted?],
  [Perceived Motivation],
  [Restraint Used],
  [SSDS Incident ID]
FROM
  (
    SELECT
      incident_id,
      field_name,
      [Value]
    FROM
      deanslist.incidents_custom_fields
  ) AS sub PIVOT (
    MAX([Value]) FOR field_name IN (
      [Approver Name],
      [Behavior Category],
      [Board Approval Date],
      [Discipline Fields],
      [Doctor Approval],
      [Entered into SSDS (suspensions only)],
      [Final Approval],
      [HI end date],
      [HI start date],
      [Home Instruction Fields],
      [Hourly Rate],
      [Hours per Week],
      [Initial Trigger (antecedent)],
      [Instructor Name],
      [Instructor Source],
      [NJ State Reporting],
      [Others Involved],
      [Parent Contacted?],
      [Perceived Motivation],
      [Restraint Used],
      [SSDS Incident ID]
    )
  ) AS p
