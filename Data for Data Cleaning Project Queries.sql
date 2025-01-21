/*

Cleaning Data In SQL Queris

*/

Select *
From PortfolioProjects..NashvilleHousing

-----------------------------------------------------------------------------

--Standardize Data Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProjects..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

AlTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select *
From PortfolioProjects..NashvilleHousing

-----------------------------------------------------------------------------------

--Populate Property Address Data 

Select *
From PortfolioProjects..NashvilleHousing
--where PropertyAddress is null
Order By ParcelID


-- we found here the propertyaddress for Null value and update it
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------

-- Breaking Out Address Into Individual Column (Address, City, State)

Select PropertyAddress
From PortfolioProjects..NashvilleHousing


-- Here We are going to use SUBSTRING

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

From PortfolioProjects..NashvilleHousing


AlTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

AlTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProjects..NashvilleHousing


Select OwnerAddress
From PortfolioProjects..NashvilleHousing


--Now We are going to use PARSENAME

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProjects..NashvilleHousing


AlTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

AlTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


AlTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


Select *
From PortfolioProjects..NashvilleHousing



--------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjects..NashvilleHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant
,CASE when SoldAsVacant = 'Y' THEN 'Yes'
	  when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From PortfolioProjects..NashvilleHousing


update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	  when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END




----------------------------------------------------------------------------------------------

-- Remove Duplicates


-- Here we Find Duplicates Using CTE and PARTITION Then DELETE 

WITH RowNumCTE AS(
	Select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY 
									UniqueID
									) row_num

	From PortfolioProjects..NashvilleHousing
--	ORDER BY ParcelID
)
Delete
From RowNumCTE
Where row_num >  1
--Order by PropertyAddress



Select *
From PortfolioProjects..NashvilleHousing



---------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


Select *
From PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





