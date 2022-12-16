CREATE
OR ALTER
FUNCTION utilities.STRIP_HTML (@HTMLText VARCHAR(MAX)) RETURNS VARCHAR(MAX) AS BEGIN DECLARE @Start INT;

DECLARE @End INT;

DECLARE @Length INT;

-- Replace the HTML entity &amp; with the '&' character (this needs to be done first, AS
-- '&' might be double encoded AS '&amp;amp;')
SET
  @Start = CHARINDEX('&amp;', @HTMLText);

SET
  @End = @Start + 4;

SET
  @Length = (@End - @Start) + 1;

WHILE (
  @Start > 0
  AND @End > 0
  AND @Length > 0
) BEGIN
SET
  @HTMLText = STUFF(@HTMLText, @Start, @Length, '&');

SET
  @Start = CHARINDEX('&amp;', @HTMLText);

SET
  @End = @Start + 4;

SET
  @Length = (@End - @Start) + 1;

END;

-- Replace the HTML entity &lt; with the '<' character
SET
  @Start = CHARINDEX('&lt;', @HTMLText);

SET
  @End = @Start + 3;

SET
  @Length = (@End - @Start) + 1;

WHILE (
  @Start > 0
  AND @End > 0
  AND @Length > 0
) BEGIN
SET
  @HTMLText = STUFF(@HTMLText, @Start, @Length, '<');

SET
  @Start = CHARINDEX('&lt;', @HTMLText);

SET
  @End = @Start + 3;

SET
  @Length = (@End - @Start) + 1;

END;

-- Replace the HTML entity &gt; with the '>' character
SET
  @Start = CHARINDEX('&gt;', @HTMLText);

SET
  @End = @Start + 3;

SET
  @Length = (@End - @Start) + 1;

WHILE (
  @Start > 0
  AND @End > 0
  AND @Length > 0
) BEGIN
SET
  @HTMLText = STUFF(@HTMLText, @Start, @Length, '>');

SET
  @Start = CHARINDEX('&gt;', @HTMLText);

SET
  @End = @Start + 3;

SET
  @Length = (@End - @Start) + 1;

END;

-- Replace the HTML entity &amp; with the '&' character
SET
  @Start = CHARINDEX('&amp;amp;', @HTMLText);

SET
  @End = @Start + 4;

SET
  @Length = (@End - @Start) + 1;

WHILE (
  @Start > 0
  AND @End > 0
  AND @Length > 0
) BEGIN
SET
  @HTMLText = STUFF(@HTMLText, @Start, @Length, '&');

SET
  @Start = CHARINDEX('&amp;amp;', @HTMLText);

SET
  @End = @Start + 4;

SET
  @Length = (@End - @Start) + 1;

END;

-- Replace the HTML entity &nbsp; with the ' ' character
SET
  @Start = CHARINDEX('&nbsp;', @HTMLText);

SET
  @End = @Start + 5;

SET
  @Length = (@End - @Start) + 1;

WHILE (
  @Start > 0
  AND @End > 0
  AND @Length > 0
) BEGIN
SET
  @HTMLText = STUFF(@HTMLText, @Start, @Length, ' ');

SET
  @Start = CHARINDEX('&nbsp;', @HTMLText);

SET
  @End = @Start + 5;

SET
  @Length = (@End - @Start) + 1;

END;

-- Replace any <br> tags with a newline
SET
  @Start = CHARINDEX('<br>', @HTMLText);

SET
  @End = @Start + 3;

SET
  @Length = (@End - @Start) + 1;

WHILE (
  @Start > 0
  AND @End > 0
  AND @Length > 0
) BEGIN
--SET @HTMLText = STUFF(@HTMLText, @Start, @Length, CHAR(13) + CHAR(10));
SET
  @HTMLText = STUFF(@HTMLText, @Start, @Length, '');

SET
  @Start = CHARINDEX('<br>', @HTMLText);

SET
  @End = @Start + 3;

SET
  @Length = (@End - @Start) + 1;

END;

-- Replace any <br/> tags with a newline
SET
  @Start = CHARINDEX('<br/>', @HTMLText);

SET
  @End = @Start + 4;

SET
  @Length = (@End - @Start) + 1;

WHILE (
  @Start > 0
  AND @End > 0
  AND @Length > 0
) BEGIN
--SET @HTMLText = STUFF(@HTMLText, @Start, @Length, CHAR(13) + CHAR(10));
SET
  @HTMLText = STUFF(@HTMLText, @Start, @Length, '');

SET
  @Start = CHARINDEX('<br/>', @HTMLText);

SET
  @End = @Start + 4;

SET
  @Length = (@End - @Start) + 1;

END;

-- Replace any <br /> tags with a newline
SET
  @Start = CHARINDEX('<br />', @HTMLText);

SET
  @End = @Start + 5;

SET
  @Length = (@End - @Start) + 1;

WHILE (
  @Start > 0
  AND @End > 0
  AND @Length > 0
) BEGIN
--SET @HTMLText = STUFF(@HTMLText, @Start, @Length, CHAR(13) + CHAR(10));
SET
  @HTMLText = STUFF(@HTMLText, @Start, @Length, '');

SET
  @Start = CHARINDEX('<br />', @HTMLText);

SET
  @End = @Start + 5;

SET
  @Length = (@End - @Start) + 1;

END;

-- Remove anything BETWEEN <whatever> tags
SET
  @Start = CHARINDEX('<', @HTMLText);

SET
  @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText));

SET
  @Length = (@End - @Start) + 1;

WHILE (
  @Start > 0
  AND @End > 0
  AND @Length > 0
) BEGIN
SET
  @HTMLText = STUFF(@HTMLText, @Start, @Length, '');

SET
  @Start = CHARINDEX('<', @HTMLText);

SET
  @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText));

SET
  @Length = (@End - @Start) + 1;

END;

RETURN LTRIM(RTRIM(@HTMLText));

END;
