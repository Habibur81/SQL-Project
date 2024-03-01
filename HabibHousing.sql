--------------------------------------SQL Query--------------------------------------------
SELECT * FROM PortfolioProject..HabibHousing

------------------------------------Data Formating-----------------------------------------

SELECT SaleDate, CONVERT(Date, SaleDate) AS DateFormat FROM PortfolioProject..HabibHousing

SELECT SaleDate FROM PortfolioProject..HabibHousing

UPDATE HabibHousing SET SaleDate =  CONVERT(Date, SaleDate)

ALTER TABLE HabibHousing ADD New_SaleDate DATE;

UPDATE HabibHousing SET New_SaleDate =  CONVERT(Date, SaleDate)

SELECT New_SaleDate FROM PortfolioProject..HabibHousing

---Populate Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..HabibHousing a
JOIN PortfolioProject..HabibHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..HabibHousing a
JOIN PortfolioProject..HabibHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

---Breaking out Address into Individual columns (Address, City, State)

SELECT PropertyAddress FROM PortfolioProject..HabibHousing

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..HabibHousing

ALTER TABLE PortfolioProject..HabibHousing ADD SplitAdress nvarchar(255);

UPDATE PortfolioProject..HabibHousing SET SplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

SELECT SplitAdress FROM PortfolioProject..HabibHousing

ALTER TABLE PortfolioProject..HabibHousing ADD SplitCity nvarchar(255)

UPDATE PortfolioProject..HabibHousing SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT SplitCity FROM PortfolioProject..HabibHousing

---Use Parsename function  

SELECT OwnerAddress FROM PortfolioProject..HabibHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS AddressLastPart, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS AddressMidPart,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS AddressFirstPart
FROM PortfolioProject..HabibHousing

ALTER TABLE PortfolioProject..HabibHousing ADD OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject..HabibHousing SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..HabibHousing ADD OwnerCityAddress nvarchar(255)

UPDATE PortfolioProject..HabibHousing SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

ALTER TABLE PortfolioProject..HabibHousing ADD OwnerStateAddress nvarchar(255)

UPDATE PortfolioProject..HabibHousing SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 

SELECT * FROM PortfolioProject..HabibHousing

--Change Y and No to Yes to no in "Sold as vacant" field

SELECT SoldAsVacant, COUNT(SoldAsVacant) FROM PortfolioProject..HabibHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM PortfolioProject..HabibHousing

UPDATE PortfolioProject..HabibHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END

--Idenfity duplicates rows
SELECT * FROM PortfolioProject..HabibHousing

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY 
	parcelID, 
	PropertyAddress,
	SaleDate,
	LegalReference
ORDER BY 
	UniqueID
) row_num
FROM PortfolioProject..HabibHousing
--ORDER BY parcelID
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--Remove Duplicate rows

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY 
	parcelID, 
	PropertyAddress,
	SaleDate,
	LegalReference
ORDER BY 
	UniqueID
) row_num
FROM PortfolioProject..HabibHousing
--ORDER BY parcelID
)
DELETE FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--Delete Unused columns

SELECT * FROM PortfolioProject..HabibHousing;

ALTER TABLE PortfolioProject..HabibHousing
DROP COLUMN PropertyAddress;

ALTER TABLE PortfolioProject..HabibHousing
DROP COLUMN OwnerAddress;

ALTER TABLE PortfolioProject..HabibHousing
DROP COLUMN SaleDate;

ALTER TABLE PortfolioProject..HabibHousing
DROP COLUMN TaxDistrict;


SELECT * FROM PortfolioProject..HabibHousing


SELECT ParcelID, AVG(SalePrice) FROM PortfolioProject..HabibHousing
GROUP BY ParcelID  ----------------------Query is not run

SELECT ParcelID, OwnerName, AVG(SalePrice) OVER(PARTITION BY ParcelID) AS Avg_SalePrice FROM PortfolioProject..HabibHousing
WHERE OwnerName IS NOT NULL


