/*

Cleaning Data in SQL Queries

*/

--Look at all the data we'll be cleaning
select*
from PortfolioProject..NashvilleHousing


--Standaedize Date to Date format and not Datetime
select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Get the new column into the Table
Alter table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Populate Property Address Data

--First look at the data in the column
select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select*
from PortfolioProject..NashvilleHousing
order by ParcelID

--Looks like the same ParcelID has the same address
--Join the table to itself based on ParcelID to start the process of populating nulls
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--If Property address a is null, populate it will Property address b
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Populate the Propert Address on the table to get rid of the nulls
update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Check if the query worked
--Result should be blank
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
-- First look at the data in the column
select PropertyAddress
from PortfolioProject..NashvilleHousing


select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing


--The property Address in the above ends with a comma
--Remove the comma at the end of the address
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
from PortfolioProject..NashvilleHousing

--Separate the columns for address and city
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


--Add the split data in the raw table
--Start with a columns for split address
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

--Add the city onto the table
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--Check the table to see if the update was made
select*
from PortfolioProject..NashvilleHousing


--Split out the Owner Address (Address, City and State)

--first look at the data
select OwnerAddress
from PortfolioProject..NashvilleHousing


select
PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing
--This only gives the state as it works backwards

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject..NashvilleHousing
--The above separates fiels out as needed

--Add onto the table
--Start with the Address
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

--Add the Owner Split City column
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


--Add the Split State
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Check table to see if update was made
select* 
from PortfolioProject..NashvilleHousing


--Change Y to Yes and N to No in the 'SoldAsVacant' field
--first check the data
select distinct(SoldAsVacant)
from PortfolioProject..NashvilleHousing

--Check how many values there are for each grouping
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

--Perform the changes
select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END
from PortfolioProject..NashvilleHousing

--Make the Update on the table
Update NashvilleHousing
set SoldAsVacant =CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END


--Check if it worked
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


--Remove Duplicates
--First identify where the duplicates are
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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--To delete the duplicates
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


--Check if the Duplicates were successfully deleted


From PortfolioProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1


--Check if duplicates were successfully removed
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

From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Delete Unused Columns
--First Check the data to see which columns are unused
select*
from PortfolioProject..NashvilleHousing

--We will remove the following Columns: OwnerAddress, TaxDistrict,PropertyAddress,SaleDate
ALTER TABLE PortfolioProject..NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--Check if it worked
select*
from PortfolioProject..NashvilleHousing