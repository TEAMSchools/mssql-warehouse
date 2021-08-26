USE gabby
GO

CREATE OR ALTER VIEW extracts.whetstone_observation_groups AS

SELECT school_id
      ,'{"observationGroups": [' + gabby.dbo.GROUP_CONCAT(group_dict) + ']}' AS observation_groups_dict
FROM
    (
     SELECT school_id
           ,'{' + '"_id": "' + observation_group_id + '",'
                + '"name": "' + observation_group_name + '",' 
                + gabby.dbo.GROUP_CONCAT(role_user_ids) 
             + '}' AS group_dict
     FROM
         (
          SELECT school_id
                ,observation_group_id
                ,observation_group_name
                ,'"' + role_name + '": [' + gabby.dbo.GROUP_CONCAT('"' + [user_id] + '"') + ']' AS role_user_ids
          FROM gabby.whetstone.schools_observation_groups_membership sogm
          GROUP BY school_id
                  ,observation_group_id
                  ,observation_group_name
                  ,role_name
         ) sub
     GROUP BY school_id
             ,observation_group_id
             ,observation_group_name
    ) sub
GROUP BY school_id
