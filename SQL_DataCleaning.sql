Select *
From PortfolioProject.dbo.NashvilleHousing
/*
Convert Date Colum
*/
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


/*
Populate Property Address Data
*/
SELECT *
FROM NashvilleHousing 
WHERE PropertyAddress is null
ORDER BY ParcelID

--SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) 
--FROM NashvilleHousing A
--JOIN NashvilleHousing B
--	ON A.ParcelID = B.ParcelID
--	AND A.[UniqueID ] <> B.[UniqueID ]
--WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

/*
Breaking out Address into Individual Columns (Address, City, State)
*/

SELECT PropertyAddress
FROM NashvilleHousing 

--SELECT 
--SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) AS Address
--, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
--FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Splitting OwnerAddress Column into Address, City & State

--SELECT *
--FROM NashvilleHousing 

--SELECT OwnerAddress
--FROM NashvilleHousing 

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--SELECT *
--FROM NashvilleHousing 


/*
Change Y and N to Yes and No in "Sold as Vacant" Field
*/

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROm NashvilleHousing
Group by SoldAsVacant
Order BY 2

--SELECT SoldAsVacant
--, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
--       WHEN SoldAsVacant = 'N' THEN 'No'
--	   ELSE SoldAsVacant
--	   END
--FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing


/*
Remove Duplicates - not deleting the data, just adding them to temp table
*/
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueId) Row_Num
FROM NashvilleHousing
--ORDER BY ParcelID
)

--DELETE 
SELECT *
FROM RowNumCTE
WHERE Row_Num >1
--ORDER BY PropertyAddress


--SELECT *
--FROM NashvilleHousing 



/*
Delete Unused Columns
*/
SELECT *
FROM NashvilleHousing 


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate