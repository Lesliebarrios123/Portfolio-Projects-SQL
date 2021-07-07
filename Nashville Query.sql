/*
Cleaning SQL data
*/


Select *
From Portfolio.dbo.Nashville




--Changing Data Format----------------------------------------------------------------------------------------------


Select SaleDateConverted, CONVERT(Date,SaleDate)
From Portfolio.dbo.Nashville

/*
Update Nashville
Set SaleDate = CONVERT(Date,SaleDate)
*/

ALTER TABLE Nashville
Add SaleDateConverted Date;

Update Nashville
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.Nashville a 
Join Portfolio.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.Nashville a
Join Portfolio.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 
--We know this has done its job because once you execute the query before it should return no results because there is no longer a property address that is NULL




--Breaking down Address, City, State--------------------------------------------------------------------------------



Select PropertyAddress
From Portfolio.dbo.Nashville 

--The -1 is to get rid of the comma since we are obtaining the index
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Portfolio.dbo.Nashville

ALTER TABLE Nashville
Add PropSplitAddress Nvarchar(255);

Update Nashville
SET PropSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville
Add PropSplitCity Nvarchar(255);

Update Nashville
SET PropSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select
PARSENAME(Replace(OwnerAddress,',', '.'), 3)
, PARSENAME(Replace(OwnerAddress,',', '.'), 2)
, PARSENAME(Replace(OwnerAddress,',', '.'), 1)
From Portfolio.dbo.Nashville

ALTER TABLE Nashville
Add OwnerSplitAddress Nvarchar(255);

Update Nashville
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'), 3)

ALTER TABLE Nashville
Add OwnerSplitCity Nvarchar(255);

Update Nashville
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'), 2)

ALTER TABLE Nashville
Add OwnerSplitState Nvarchar(255);

Update Nashville
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'), 1)

Select *
From Portfolio.dbo.Nashville



-- Change Y and N to Yes and No in "Sold as Vacant" field----------------------------------------------------------



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' Then 'NO'
	   Else SoldAsVacant
	   End
From Portfolio.dbo.Nashville

Update Nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



--Remove Duplicates-----------------------------------------------------------------------------------------------


With RowNUmCTE AS(
Select *,
	Row_Number() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				    UniqueID
					) row_num

From Portfolio.dbo.Nashville
)
--Delete
Select *
From RowNUmCTE
where row_num > 1
Order by PropertyAddress




--Delete Unused Columns---------------------------------------------------------------------------------------------


Select *
From Portfolio.dbo.Nashville

Alter Table Portfolio.dbo.Nashville
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Portfolio.dbo.Nashville
Drop Column SaleDate