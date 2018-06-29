USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.gpa_cumulative AS

SELECT 'kippcamden' AS [db_name]
      ,[cumulative_Y1_gpa]
      ,[cumulative_Y1_gpa_projected]
      ,[cumulative_Y1_gpa_projected_s1]
      ,[cumulative_Y1_gpa_unweighted]
      ,[earned_credits_cum]
      ,[earned_credits_cum_projected]
      ,[earned_credits_cum_projected_s1]
      ,[potential_credits_cum]
      ,[schoolid]
      ,[studentid]
FROM kippcamden.powerschool.gpa_cumulative
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[cumulative_Y1_gpa]
      ,[cumulative_Y1_gpa_projected]
      ,[cumulative_Y1_gpa_projected_s1]
      ,[cumulative_Y1_gpa_unweighted]
      ,[earned_credits_cum]
      ,[earned_credits_cum_projected]
      ,[earned_credits_cum_projected_s1]
      ,[potential_credits_cum]
      ,[schoolid]
      ,[studentid]
FROM kippmiami.powerschool.gpa_cumulative
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[cumulative_Y1_gpa]
      ,[cumulative_Y1_gpa_projected]
      ,[cumulative_Y1_gpa_projected_s1]
      ,[cumulative_Y1_gpa_unweighted]
      ,[earned_credits_cum]
      ,[earned_credits_cum_projected]
      ,[earned_credits_cum_projected_s1]
      ,[potential_credits_cum]
      ,[schoolid]
      ,[studentid]
FROM kippnewark.powerschool.gpa_cumulative;