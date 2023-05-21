SELECT * 
FROM Portfolio..NashvilleHousing

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Portfolio..NashvilleHousing


-- If it doesn't Update properly

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)
-- Populate Property Address data

SELECT * 
FROM Portfolio..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio..NashvilleHousing
--ORDER BY ParcelID

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress varchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity varchar(255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

SELECT OwnerAddress
FROM Portfolio..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM Portfolio..NashvilleHousing

-- Changing Y and N to Yes and No in "Sold as vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Portfolio..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			LegalReference
			ORDER BY
			UniqueID) row_num
FROM Portfolio..NashvilleHousing
--ORDER BY ParcelID
--WHERE row_num > 1)
)
SELECT *
FROM RowNumCTE
WHERE row_num>1

SELECT * 
FROM Portfolio..NashvilleHousing



-- Delete Unused Columns

SELECT * 
FROM Portfolio..NashvilleHousing


ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN SaleDate