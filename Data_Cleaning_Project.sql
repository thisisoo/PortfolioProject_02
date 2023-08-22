USE master;
GO

IF NOT EXISTS (
    SELECT name 
    FROM sys.databases
    WHERE name = N'Data_Cleaning'
    )
  CREATE DATABASE [Data_Cleaning];
GO


--Cleaning Data in SQL Queries


SELECT *
FROM Data_Cleaning.dbo.NashvilleHousing


--Standardize Date Format

SELECT SaleDate, CONVERT(varchar(10), CAST('SaleDate' AS date), 120)
FROM Data_Cleaning.dbo.NashvilleHousing


UPDATE Data_Cleaning.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE Data_Cleaning.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Data_Cleaning.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--Population Property Address Date
SELECT *
FROM Data_Cleaning.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL 
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Data_Cleaning.dbo.NashvilleHousing a
JOIN Data_Cleaning.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Data_Cleaning.dbo.NashvilleHousing a
JOIN Data_Cleaning.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Data_Cleaning.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL 
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address

FROM Data_Cleaning.dbo.NashvilleHousing

AFTER TABLE Data_Cleaning.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Data_Cleaning.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

AFTER TABLE Data_Cleaning.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Data_Cleaning.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT *
FROM Data_Cleaning.dbo.NashvilleHousing





SELECT OwnerAddress
FROM Data_Cleaning.dbo.NashvilleHousing


SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
FROM Data_Cleaning.dbo.NashvilleHousing



AFTER TABLE Data_Cleaning.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Data_Cleaning.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3 )

AFTER TABLE Data_Cleaning.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Data_Cleaning.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

AFTER TABLE Data_Cleaning.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Data_Cleaning.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM Data_Cleaning.dbo.NashvilleHousing


--Change Y and N to Yes and No in 'Sold as Vacant' field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Data_Cleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SOldAsVacant = 'N' THEN 'No'
           ELSE SoldAsVacant
           END
FROM Data_Cleaning.dbo.NashvilleHousing


UPDATE Data_Cleaning.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YEs'
          WHEN SoldAsVacant = 'N' THEN 'No'
          ELSE SoldAsVacant
          END





-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
        ROW_NUMBER() OVER (
        PARTITION BY ParcelID, 
                                 PropertyAddress,
                                 SalePrice,
                                 SaleDate,
                                 LegalReference
                                 ORDER BY 
                                        UniqueID
                                        ) row_num

FROM Data_Cleaning.dbo.NashvilleHousing
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



SELECT *
FROM Data_Cleaning.dbo.NashvilleHousing




-- Delete Unused Columns


SELECT *
FROM Data_Cleaning.dbo.NashvilleHousing


AFTER TABLE Data_Cleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TasDistrict, PropertyAddress, SaleDate





-- Importing Data Using OPENROWSET and BULK INSERT

-- More Advanced and looks cooler, but have to configure server appropriately to do correctly
-- Wanted to provide this in case you wanted to try it


-- sp_configure 'show advanced options', 1;
-- RECONFIGURE
-- GO
-- sp_configure 'Ad Hoc Distributed Queries', 1;
-- GO


-- USE Data_Cleaning.dbo.NashvilleHousing

-- GO

-- EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACEOLEDB.12.0', N' AllowInProcess', 1

-- GO

-- EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1

-- GO



---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
