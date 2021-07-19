USE gabby;
GO

CREATE OR ALTER FUNCTION utilities.STRIP_CHARACTERS (
    @string NVARCHAR(MAX)
   ,@match_expression VARCHAR(255)
)
  RETURNS NVARCHAR(MAX)
  WITH SCHEMABINDING
AS

BEGIN

  SET @match_expression = '%[' + @match_expression + ']%';

  WHILE PATINDEX(@match_expression, @string) > 0
    SET @string = STUFF(@string, PATINDEX(@match_expression, @string), 1, '');

  RETURN @string;

END;
