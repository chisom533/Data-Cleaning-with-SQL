/*
DATA Cleaning
*/

SELECT *
FROM [PORTFOLIO PROJECT]..NashvilleHousing
--------------------------------------------------------------------------------------------------------
--DATE FORMAT
SELECT SaleDateConverted,CONVERT(Date,SaleDate)
FROM [PORTFOLIO PROJECT]..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------
--Populate Property Adderss Data

SELECT*
FROM [PORTFOLIO PROJECT]..NashvilleHousing
--where propertyAdress is null
order by ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL( a.PropertyAddress,b.PropertyAddress)
FROM [PORTFOLIO PROJECT]..NashvilleHousing a
Join [PORTFOLIO PROJECT]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL( a.PropertyAddress,b.PropertyAddress)
FROM [PORTFOLIO PROJECT]..NashvilleHousing a
Join [PORTFOLIO PROJECT]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------
--Breaking Out Address into Individual Columns (Address,City, State)

SELECT PropertyAddress
FROM [PORTFOLIO PROJECT]..NashvilleHousing
--where propertyAdress is null
--order by ParcelID

SELECT 
SUBSTRING (PropertyAddress,1,CHARINDEX (',', PropertyAddress) -1) as Address
,SUBSTRING (PropertyAddress,CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress))as Address
FROM [PORTFOLIO PROJECT]..NashvilleHousing

ALTER TABLE [PORTFOLIO PROJECT]..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE [PORTFOLIO PROJECT]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX (',', PropertyAddress) -1)

ALTER TABLE [PORTFOLIO PROJECT]..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE [PORTFOLIO PROJECT]..NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT*
FROM [PORTFOLIO PROJECT]..NashvilleHousing

SELECT OwnerAddress
FROM [PORTFOLIO PROJECT]..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)
FROM [PORTFOLIO PROJECT]..NashvilleHousing

ALTER TABLE [PORTFOLIO PROJECT]..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [PORTFOLIO PROJECT]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3)

ALTER TABLE [PORTFOLIO PROJECT]..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE [PORTFOLIO PROJECT]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2)

ALTER TABLE [PORTFOLIO PROJECT]..NashvilleHousing 
ADD OwnerSplitState Nvarchar(255);

UPDATE [PORTFOLIO PROJECT]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)


SELECT*
FROM [PORTFOLIO PROJECT]..NashvilleHousing
--------------------------------------------------------------------------------------------------------

--Change Y AND N to YES AND NO in 'Sold As Vacant' Field

SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM [PORTFOLIO PROJECT]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 Desc

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant ='y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  Else SoldAsVacant
	  End
FROM [PORTFOLIO PROJECT]..NashvilleHousing

UPDATE [PORTFOLIO PROJECT]..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  Else SoldAsVacant
	  End

--------------------------------------------------------------------------------------------------------
-- Remove Duplicate
WITH RowNumCTE AS(
SELECT *,
     ROW_NUMBER() OVER 
	 (PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   LegalReference
				   ORDER BY
				    UNIQUEID
					) row_num

FROM [PORTFOLIO PROJECT]..NashvilleHousing
)
--DELETE 
SELECT*
FROM RowNumCTE
WHERE row_num >1

--------------------------------------------------------------------------------------------------------
--DELETE UNUSED COLUNMS
SELECT*
FROM [PORTFOLIO PROJECT]..NashvilleHousing

 ALTER TABLE [PORTFOLIO PROJECT]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate