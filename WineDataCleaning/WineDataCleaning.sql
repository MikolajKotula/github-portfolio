-- DATA CLEANING --

-- Price --
/*
Removal of the currency symbol as each price has the same one, 
and removal of information about whether the price is per bottle, as this information is already included in a separate column.
*/
SELECT CAST( 
	SUBSTRING(
		Price, 
		PATINDEX('%[0-9]%', Price),
		LEN(Price) - PATINDEX('%[0-9]%', REVERSE(Price))
	)AS DECIMAL(5,2)) AS Price
FROM [Projects].[dbo].[WineData];

UPDATE [Projects].[dbo].[WineData]
SET Price= CAST( 
	SUBSTRING( 
		Price,
		PATINDEX('%[0-9]%', Price),
		LEN(Price) - PATINDEX('%[0-9]%', REVERSE(Price))
	) AS DECIMAL(5,2));

ALTER TABLE [Projects].[dbo].[WineData]
ALTER COLUMN Price DECIMAL (5,2);

-- Capacity --
/*
Conversion of capacity to liters and removal of capacity units
*/
SELECT DISTINCT
	SUBSTRING(
		Capacity,
		PATINDEX('%[A-Za-z]%',[Capacity]),
		LEN(Capacity)
	) AS Unit
FROM [Projects].[dbo].[WineData];
/* 
Capacity Units:
	CL
	LTR
	LITRE
	L
	Our
	ML
*/
UPDATE [Projects].[dbo].[WineData]
SET Capacity = 
    CASE 
        WHEN t.Unit = 'CL' THEN CAST(t.CapacityNum AS FLOAT) / 100
        WHEN t.Unit = 'ML' THEN CAST(t.CapacityNum AS FLOAT) / 1000
        WHEN t.Unit IN ('L', 'LTR', 'LITRE') THEN CAST(t.CapacityNum AS FLOAT)
    END
FROM (
    SELECT Capacity,
        SUBSTRING(Capacity, 1, PATINDEX('%[A-Za-z]%', [Capacity]) - 1) AS CapacityNum,
        SUBSTRING(Capacity, PATINDEX('%[A-Za-z]%', [Capacity]), LEN(Capacity)) AS Unit
    FROM [Projects].[dbo].[WineData]
) AS t
WHERE [Projects].[dbo].[WineData].Capacity = t.Capacity;

-- ABV --
/* Removal of additional text */
SELECT CASE
 WHEN ABV <> '' THEN
	CAST( SUBSTRING(
			ABV, 
			PATINDEX('%[0-9]%', ABV),
			LEN(ABV)-5)
	AS DECIMAL(4,2))
  ELSE NULL
 END AS ABV2, ABV
FROM[Projects].[dbo].[WineData];

UPDATE [Projects].[dbo].[WineData]
SET ABV= CASE
	WHEN ABV <> '' THEN
		CAST( SUBSTRING(
			ABV, 
			PATINDEX('%[0-9]%', ABV),
			LEN(ABV)-5)
		AS DECIMAL(4,2))
	 ELSE NULL
	END;

-- Vintage --
/* Correction of wine vintages. */
SELECT DISTINCT Vintage
from [Projects].[dbo].[WineData]

UPDATE [Projects].[dbo].[WineData]
SET Vintage = CASE 
		WHEN Vintage = '2012/2015' THEN '2015'
		WHEN Vintage = '2016/7' THEN '2017'
		WHEN Vintage = '2019/20' THEN '2020'
		WHEN Vintage = '2020/21' THEN '2021'
		WHEN Vintage = '2021/22' THEN '2022'
		WHEN Vintage = '2020/2021' THEN '2021'
		WHEN Vintage = '2020/2022' THEN '2022'
		WHEN Vintage = '2021/2022' THEN '2022'
		ELSE Vintage
	END;

-- Appelation
/* We can replace some empty values in 'Appelation' from information in 'Title' */

select * from (
SELECT Title, SUBSTRING(Title, CHARINDEX(',', Title) + 2, LEN(Title)) AS Appellation2, Country, Region, Appellation
    FROM [Projects].[dbo].[WineData]
    WHERE  Title LIKE '%,%' 
	AND Appellation = ''
) t
WHERE Appellation2 <> Country 
AND Appellation2 <> Region
AND Appellation2 NOT LIKE '%[0-9]%'

UPDATE [Projects].[dbo].[WineData]
SET Appellation = Appellation2
FROM (
    SELECT Title, SUBSTRING(Title, CHARINDEX(',', Title) + 2, LEN(Title)) AS Appellation2, Country, Region, Appellation
    FROM [Projects].[dbo].[WineData]
    WHERE Title LIKE '%,%' AND Appellation = ''
) t
WHERE [Projects].[dbo].[WineData].Title = t.Title
  AND t.Appellation2 <> [Projects].[dbo].[WineData].Country
  AND t.Appellation2 <> [Projects].[dbo].[WineData].Region
  AND t.Appellation2 NOT LIKE '%[0-9]%';


-- Replacing missing and empty values --

-- Description --
UPDATE [Projects].[dbo].[WineData]
SET Description='None' 
WHERE Description='' ;

-- Capacity --
UPDATE [Projects].[dbo].[WineData]
SET Capacity=CASE 
	WHEN Capacity IS NULL THEN 0
	ELSE CAST(Capacity AS DECIMAL(5,2))
 END;

-- Grape --
UPDATE [Projects].[dbo].[WineData]
SET Grape='Unknown' 
WHERE Grape='' ;

-- Secondary Grape --
UPDATE [Projects].[dbo].[WineData]
SET [Secondary Grape Varieties]='Unknown' 
WHERE [Secondary Grape Varieties]='' ;

-- Closure --
UPDATE [Projects].[dbo].[WineData]
SET Closure='Unknown' 
WHERE Closure='';

-- Country --
UPDATE [Projects].[dbo].[WineData]
SET Country='Unknown' 
WHERE Country='';

-- Unit --
/* There are some wines with 0 units, so empty values are replaced with '-1' */
UPDATE [Projects].[dbo].[WineData]
SET Unit='-1'
WHERE Unit='';

-- Characteristics --
UPDATE [Projects].[dbo].[WineData]
SET Characteristics='Unknown'
WHERE Characteristics='';

-- Type --
UPDATE [Projects].[dbo].[WineData]
SET Type='Unknown'
WHERE Type='';

-- ABV --
-- There are some wines with 0 ABV, so NULL values are replaced with '-1'
UPDATE [Projects].[dbo].[WineData]
SET ABV='-1'
WHERE ABV IS NULL;

-- Region --
UPDATE [Projects].[dbo].[WineData]
SET Region='Unknown'
WHERE Region='';

-- Style --
UPDATE [Projects].[dbo].[WineData]
SET Style='Unknown'
WHERE Style='';

-- Vintage --
UPDATE [Projects].[dbo].[WineData]
SET Vintage=0
WHERE Vintage='' or Vintage='NV';

-- Appellation --
UPDATE [Projects].[dbo].[WineData]
SET Appellation='Unknown'
WHERE Appellation=''; 

-- Correcting encoding errors --

-- Title --
SELECT Title, 
  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(REPLACE(REPLACE( REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(
  Title, 'Ă©','é'), 'Ă«','ë'), 'Ă˘','â'), 'Ă´','ô'), 'â€',''''), 'â€™',''''), 'Ă¨','è'), 'Ăˇ','á'), 'ĂĽ','ü'), 'Ă¤','ä'), 'Ă®','î'), 'ĂŞ','ê'), 
  'Ă±','ñ'), 'Ă','í'), 'Â°','°'),'í‰','É'),'Ăł','ó')
FROM [Projects].[dbo].[WineData];

UPDATE [Projects].[dbo].[WineData]
SET Title= 
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  Title, 'Ă©','é'),
  'Ă«','ë'),
  'Ă˘','â'),
  'Ă´','ô'),
  'â€',''''),
  'â€™',''''),
  'Ă¨','è'),
  'Ăˇ','á'),
  'ĂĽ','ü'),
  'Ă¤','ä'),
  'Ă®','î'),
  'ĂŞ','ê'),
  'Ă±','ñ'),
  'Ă','í'),
  'Â°','°'),
  'í‰','É'),
  'Ăł','ó');

  -- Description --
select Description,replace(replace(replace( replace( replace( Replace( replace( Replace( Replace( replace( replace( replace( replace( replace( Replace( REPLACE( REPLACE( REPLACE( REPLACE(
	Description, 'Ă©','é'),'Ă«','ë'),'Ă˘','â'),'Ă´','ô'),'â€',''''),'â€™',''''),'Ă¨','è'),'Ăˇ','á'),'ĂĽ','ü'),'Ă¤','ä'),'Ă®','î'),'ĂŞ','ê'),'Ă±','ñ'),'Ă','í'),'Â°','°'),'í‰','É'),'Ăł','ó'),'â€“','-'),'â€¦','...')
from [Projects].[dbo].[WineData];

  UPDATE [Projects].[dbo].[WineData]
SET Description=
REPLACE(
REPLACE(
 REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  Description, 'Ă©','é'),
  'Ă«','ë'),
  'Ă˘','â'),
  'Ă´','ô'),
  'â€',''''),
  'â€™',''''),
  'Ă¨','è'),
  'Ăˇ','á'),
  'ĂĽ','ü'),
  'Ă¤','ä'),
  'Ă®','î'),
  'ĂŞ','ê'),
  'Ă±','ñ'),
  'Ă','í'),
  'Â°','°'),
  'í‰','É'),
  'Ăł','ó'),
  'â€“','-'),
  'â€¦','...');

-- Type --
UPDATE [Projects].[dbo].[WineData]
SET Type=REPLACE( Type, 'Ă©','é');

-- Appellation --
update [Projects].[dbo].[WineData]
set Appellation=
REPLACE(
REPLACE(
 REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  Appellation, 'Ă©','é'),
  'Ă«','ë'),
  'Ă˘','â'),
  'Ă´','ô'),
  'â€',''''),
  'â€™',''''),
  'Ă¨','è'),
  'Ăˇ','á'),
  'ĂĽ','ü'),
  'Ă¤','ä'),
  'Ă®','î'),
  'ĂŞ','ê'),
  'Ă±','ñ'),
  'Ă','í'),
  'Â°','°'),
  'í‰','É'),
  'Ăł','ó'),
  'â€“','-'),
  'â€¦','...');

  -- Grape --
UPDATE [Projects].[dbo].[WineData]
SET Grape=
REPLACE(
REPLACE(
 REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  REPLACE(
  Grape, 'Ă©','é'),
  'Ă«','ë'),
  'Ă˘','â'),
  'Ă´','ô'),
  'â€',''''),
  'â€™',''''),
  'Ă¨','è'),
  'Ăˇ','á'),
  'ĂĽ','ü'),
  'Ă¤','ä'),
  'Ă®','î'),
  'ĂŞ','ê'),
  'Ă±','ñ'),
  'Ă','í'),
  'Â°','°'),
  'í‰','É'),
  'Ăł','ó'),
  'â€“','-'),
  'â€¦','...');
