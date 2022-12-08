USE [gabby] GO
SET
ANSI_NULLS ON GO
SET
QUOTED_IDENTIFIER ON GO CREATE
OR ALTER
TRIGGER njdoe.TR_background_check_AI ON njdoe.background_check AFTER
INSERT
    AS BEGIN
SET
NOCOUNT ON;

IF (
    EXISTS (
        SELECT
            1
        FROM
            INSERTED
    )
) BEGIN
DELETE FROM njdoe.background_check
WHERE
    background_check.df_employee_number IN (
        SELECT
            df_employee_number
        FROM
            INSERTED
    );

INSERT INTO
    njdoe.background_check
SELECT
    *
FROM
    INSERTED END;

END
