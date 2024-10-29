
select * 
from Portfolio..HousingData

-- correct SaleDate
select SaleDate, CONVERT(Date, SaleDate)
from Portfolio..HousingData


ALTER TABLE HousingData
ADD SaleDateConverted DATE;

update HousingData
set SaleDateConverted = CONVERT(Date, SaleDate)


select SaleDate, SaleDateConverted
from Portfolio..HousingData

-- PropertyAddress
-- Replaceing null values

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio..HousingData a
join Portfolio..HousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio..HousingData a
join Portfolio..HousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Spliting Adress into Multiple columns (Adress, City)

select PropertyAddress
from Portfolio..HousingData

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) as City
from Portfolio..HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE HousingData
ADD PropertySplitCity NVARCHAR(255);

update HousingData
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

update HousingData
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))

select *
from Portfolio..HousingData

-- OwnerAddress
-- Spliting Adress into Multiple columns (Adress, City, State)
select OwnerAddress
from Portfolio..HousingData


select PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
		PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
		PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
from Portfolio..HousingData


ALTER TABLE HousingData
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE HousingData
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE HousingData
ADD OwnerSplitState NVARCHAR(255);

update HousingData
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

update HousingData
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

update HousingData
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

--SoldAsVacant
-- Correct Values, Change N and Y to 'Yes' and 'No'

select distinct(SoldAsVacant)
from Portfolio..HousingData


select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from Portfolio..HousingData

update HousingData
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--  Duplicates

WITH Row_num_CTE AS (
select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
		PropertyAddress,
		SaleDate,
		LegalReference
		ORDER BY 
			UniqueID
			) row_num
from Portfolio..HousingData
)
--DELETE
Select * 
from Row_num_CTE
where row_num > 1