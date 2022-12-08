USE [gabby] GO
SET
ANSI_NULLS ON GO
SET
QUOTED_IDENTIFIER ON GO CREATE
OR ALTER
TRIGGER deanslist.TR_behavior_AI ON deanslist.behavior AFTER
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
DELETE FROM deanslist.behavior
WHERE
    behavior.dlsaid IN (
        SELECT
            dlsaid
        FROM
            INSERTED
    );

INSERT INTO
    deanslist.behavior
SELECT
    *
FROM
    INSERTED
    --OUTPUT SELECT * FROM INSERTED;
    END;

END
