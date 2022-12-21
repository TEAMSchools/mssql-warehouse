CREATE OR ALTER VIEW
  asset_details AS
WITH
  current_trans AS (
    SELECT
      asset.asset_id,
      ats.employee_id,
      ats.trans_type,
      ats.entry_date,
      transaction_types.[trans_description] AS [Last Transaction],
      employees.[employee_number] AS [Assignee Employee ID],
      employees.[first_name] AS [Assignee First Name],
      employees.[last_name] AS [Assignee Last Name],
      ROW_NUMBER() OVER (
        PARTITION BY
          asset.asset_id
        ORDER BY
          ats.entry_date DESC
      ) AS rn_entrydate
    FROM
      [WaspTrackAsset].[dbo].[asset]
      INNER JOIN [WaspTrackAsset].[dbo].[asset_transactions] ats ON asset.asset_id = ats.asset_id
      AND ats.trans_type IN (300, 350) /* Check In & Check Out */
      INNER JOIN [WaspTrackAsset].[dbo].[transaction_types] ON ats.trans_type = transaction_types.trans_type_no
      INNER JOIN [WaspTrackAsset].[dbo].[employees] ON ats.employee_id = employees.employee_id
  )
SELECT
  asset.[asset_id] AS [Asset ID],
  asset.[asset_tag] AS [Asset Tag],
  asset.[serial_number] AS [Serial Number],
  asset.[po] AS PO,
  asset.[warranty_begin_date] AS [Warranty Start],
  asset.[warranty_end_date] AS [Warranty End],
  asset.[warranty_provider] AS [Warranty Provider],
  asset.[is_disposed] AS [Disposed],
  asset.[is_checked_out] AS [Checked out],
  asset.[date_updated] AS [Updated],
  asset.[asset_description] AS [Description],
  asset.[manufacturer_id] AS [Manufacturer],
  asset.[model] AS [Model],
  asset.[supplier_id] AS [Supplier],
  item.item_number AS [Item Number],
  item.description AS [Item Description],
  category.description AS Category,
  departments.name AS Department,
  location.code AS Location,
  condition.[description] AS [Condition],
  sites.[site_name] AS [Site],
  ct.[Last Transaction],
  ct.[Assignee Employee ID],
  ct.[Assignee First Name],
  ct.[Assignee Last Name],
  ct.[entry_date] AS [Last Transaction Time]
FROM
  [WaspTrackAsset].[dbo].[asset]
  INNER JOIN [WaspTrackAsset].[dbo].[item] ON asset.item_id = item.item_id
  INNER JOIN [WaspTrackAsset].[dbo].[departments] ON asset.department_id = departments.department_id
  INNER JOIN [WaspTrackAsset].[dbo].[location] ON asset.location_id = location.location_id
  INNER JOIN [WaspTrackAsset].[dbo].[category] ON item.category_id = category.category_id
  INNER JOIN [WaspTrackAsset].[dbo].[condition] ON asset.condition_id = condition.condition_id
  INNER JOIN [WaspTrackAsset].[dbo].[sites] ON location.site_id = sites.site_id
  LEFT JOIN current_trans AS ct ON asset.asset_id = ct.asset_id
  AND ct.rn_entrydate = 1;
