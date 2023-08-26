/*
Nashville Housing Data Cleaning
*/

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Standardize Date Format

Select SaleDate, Convert(Date, SaleDate)
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID

Select one.ParcelID, one.PropertyAddress, two.ParcelID, two.PropertyAddress, ISNULL(one.PropertyAddress, two.PropertyAddress)
From PortfolioProject..NashvilleHousing one
Join PortfolioProject..NashvilleHousing two
	on one.ParcelID = two.ParcelID
	and one.[UniqueID ] <> two.[UniqueID ]
Where one.PropertyAddress is NULL

Update one
Set PropertyAddress = ISNULL(one.PropertyAddress, two.PropertyAddress)
From PortfolioProject..NashvilleHousing one
Join PortfolioProject..NashvilleHousing two
	on one.ParcelID = two.ParcelID
	and one.[UniqueID ] <> two.[UniqueID ]
Where one.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City, State)

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is NULL
--Order by ParcelID

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
	   PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
	   PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
	End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
					When SoldAsVacant = 'N' then 'No'
					Else SoldAsVacant
				   End

-- Remove Duplicates

WITH RowNumCTE as (
SELECT *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
--Order by ParcelID
)

/*
DELETE
FROM RowNumCTE
Where row_num > 1
*/

Select *
FROM RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Delete Unused Columns

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

-- Final Result

Select *
From PortfolioProject..NashvilleHousing