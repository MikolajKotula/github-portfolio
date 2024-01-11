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

ALTER TABLE [Projects].[dbo].[WineData]
ALTER COLUMN Capacity DECIMAL (5,2);
-- ABV --
/* 
Removal of additional text
*/
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
/*
Correction of wine vintages 
*/
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
SET Description=NULL
WHERE Description='' ;

-- Grape --
UPDATE [Projects].[dbo].[WineData]
SET Grape=NULL 
WHERE Grape='' ;

-- Secondary Grape --
UPDATE [Projects].[dbo].[WineData]
SET [Secondary Grape Varieties]=NULL
WHERE [Secondary Grape Varieties]='' ;

-- Closure --
UPDATE [Projects].[dbo].[WineData]
SET Closure=NULL
WHERE Closure='';

-- Country --
UPDATE [Projects].[dbo].[WineData]
SET Country=NULL
WHERE Country='';

-- Unit --
UPDATE [Projects].[dbo].[WineData]
SET Unit=NULL
WHERE Unit='';

-- Characteristics --
UPDATE [Projects].[dbo].[WineData]
SET Characteristics=NULL
WHERE Characteristics='';

-- Type --
UPDATE [Projects].[dbo].[WineData]
SET Type=NULL
WHERE Type='';

-- ABV --
UPDATE [Projects].[dbo].[WineData]
SET ABV=NULL
WHERE ABV IS NULL;

-- Region --
UPDATE [Projects].[dbo].[WineData]
SET Region=NULL
WHERE Region='';

-- Style --
UPDATE [Projects].[dbo].[WineData]
SET Style=NULL
WHERE Style='';

-- Vintage --
UPDATE [Projects].[dbo].[WineData]
SET Vintage=NULL
WHERE Vintage='' or Vintage='NV';

-- Appellation --
UPDATE [Projects].[dbo].[WineData]
SET Appellation=NULL
WHERE Appellation=''; 

-- Looking for duplicates --

SELECT title, COUNT(*)
FROM Projects.dbo.WineData
GROUP BY title
HAVING COUNT(*) > 1;

select *
from Projects.dbo.WineData
where title='Aqualta Prosecco DOC'
--The wines are almost the same except for 'Characteristics' and 'Description', but they are similar, so let's remove one of the wines

select *
from Projects.dbo.WineData as w
inner join (
SELECT Description, COUNT(*) as num
FROM Projects.dbo.WineData
GROUP BY Description
HAVING COUNT(*) > 1
) d
on d.Description=w.Description
order by Title
/* There are wines in various capacities called 'half bottle' or 'Magnum', 
but there are often some differences between 0.75 litre bottles from same company
*/

select * 
from Projects.dbo.WineData
where Title like '%Half bottle%' or Title like '%Magnum%'

select * 
from Projects.dbo.WineData
order by   Title


select * from Projects.dbo.WineData
where [Per bottle   case   each]='each' or [Per bottle   case   each]='Per case'
order by [Per bottle   case   each]


-- There is only 6 wines per case and 5 per each (Boxed Wine), for every case and box there is tradictional 0.75 bottle so we can remove them

-- removing duplicates --
DELETE FROM Projects.dbo.WineData 
WHERE Title = 'Aqualta Prosecco DOC' AND
Description LIKE 'This fresh and fragrant Prosecco is made exclusively for Majestic%'

DELETE FROM Projects.dbo.WineData 
WHERE [Per bottle   case   each]='each' or [Per bottle   case   each]='Per case'

ALTER TABLE Projects.dbo.WineData 
DROP COLUMN [Per bottle   case   each];


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
