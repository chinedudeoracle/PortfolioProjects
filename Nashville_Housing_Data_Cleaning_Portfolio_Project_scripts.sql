/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------

--Standardize Data Format

Select SaleDate, CONVERT(date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(date, SaleDate)

Select SaleDate
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted date

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDateConverted
From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------

--Populate Property Address data

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select PropertyAddress
From PortfolioProject..NashvilleHousing
Where PropertyAddress IS NULL

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress IS NULL

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress IS NULL
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null

--------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City)
Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address2

From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

--Breaking out Address into Individual Columns (Address, City, State)

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerSplitCity
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerSplitState
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255) 

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
  END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
  END

-------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS(
Select *,
 ROW_NUMBER() OVER (
     PARTITION BY ParcelID,
	              PropertyAddress,
				  SaleDate,
				  SalePrice,
				  LegalReference
				  Order By
					  UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order By ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress


WITH RowNumCTE AS(
Select *,
 ROW_NUMBER() OVER (
     PARTITION BY ParcelID,
	              PropertyAddress,
				  SaleDate,
				  SalePrice,
				  LegalReference
				  Order By
					  UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order By ParcelID
)

DELETE 
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress


Select *
From PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------

--Delete Unused columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict