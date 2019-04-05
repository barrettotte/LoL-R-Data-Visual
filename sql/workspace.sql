-- Workspace Snippets --

-- NOTE: All data is wrapped in double quotes, I could fix this up here, but I'll just do it in R --

SELECT DISTINCT __summoner__,__accountId__ FROM [RIOT_API].[dbo].[Matches];

SELECT COUNT(__gameId__) FROM [RIOT_API].[dbo].[Matches];

SELECT COUNT(DISTINCT __summoner__) FROM [RIOT_API].[dbo].[Matches];

SELECT * FROM [RIOT_API].[dbo].[Matches] WHERE __summoner__='"Our Struggle"';

-- I made a mistake writing > 9000 records, so let's swap the columns to correct it --
UPDATE [RIOT_API].[dbo].[Matches] 
	SET [__gameMode__] = [__duration__], 
		[__duration__] = [__gameMode__]


-- One of the usernames has an accented i and i really don't feel like dealing with it the right way --
UPDATE [RIOT_API].[dbo].[Matches]
	SET [__summoner__] = '"Digital"'
		WHERE [__accountId__] = '"1Wo5aAh0AQb73DOQ-tiDPdObyDDqrcrpWECEqetD9yBkBNY"';


SELECT DISTINCT 
	__gameId__, 
	__champion__,
	__season__, 
	__timestamp__, 
	__role__, 
	__lane__, 
	__summoner__, 
	__accountId__, 
	__gameMode__, 
	__duration__,
	__stats__
FROM [RIOT_API].[dbo].[Matches] WHERE __summoner__='"Mivaro"' AND __gameMode__ = '"CLASSIC"';


-- Convert an epoch/unix timestamp to date time --
-- Going to do this on the R side though, because why not --
DECLARE @TS VARCHAR(20) = '"1554242817459"';
SELECT DATEADD(SECOND, CAST(REPLACE(@TS, '"', '') AS BIGINT) / 1000, '19700101 00:00');


SELECT COUNT(*) FROM [RIOT_API].[dbo].[Matches] WHERE __summoner__='"Mivaro"' AND __gameMode__='"CLASSIC"';
SELECT COUNT(*) FROM [RIOT_API].[dbo].[Matches] 
	WHERE __accountId__='"1Wo5aAh0AQb73DOQ-tiDPdObyDDqrcrpWECEqetD9yBkBNY"' AND __gameMode__<>'"CLASSIC"';

SELECT * FROM [RIOT_API].[dbo].[Matches] WHERE __accountId__='"1Wo5aAh0AQb73DOQ-tiDPdObyDDqrcrpWECEqetD9yBkBNY"';
SELECT * FROM [RIOT_API].[dbo].[Matches] WHERE __summoner__='"Mivaro"';

-- Count distinct champ ids occurrences --
SELECT __champion__, COUNT(*) 
	FROM [RIOT_API].[dbo].[Matches] 
		WHERE __summoner__='"Mivaro"'
			AND __gameMode__='"CLASSIC"'
	GROUP BY __champion__ 
	ORDER BY 2 ASC;