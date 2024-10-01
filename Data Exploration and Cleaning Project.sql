/*  
    Data  Exploration and  Cleaning Project 
    
    housing data in usa , nashvill

*/ 

---Data Exploration 


SELECT * 
FROM
    housing

---Overview

/*
     The sale date column is in time stamp >> clean it to date 
    The property adress must be split 
    also split the owner adress Column
*/

SELECT *
FROM
    housing 
WHERE 
    SalePrice IS NULL

/* No nulll Values in SalePrice Column*/

---------------------------------------------
SELECT 
    SoldAsVacant
From
    housing
GROUP BY 
    SoldAsVacant
  
/* The sold as vacant has N , Y , Yes , NO values  
standarize The values to Yes And No */

SELECT * 
FROM
    housing
WHERE 
    PropertyAddress IS NULL

/*
    Null Values Were found On The property Adress column
    Also null values in Total_value,land_value , and Building Value

*/


--DATA Cleaning Process 

--1  Chaneg The sale_date To date format using The convert Function.

SELECT 
    SaleDate,CONVERT(date,SaleDate)
FROM
     housing


ALTER TABLE housing
ADD SaleDate_fix DATE

UPDATE housing 
SET Saledate_fix=CONVERT(date,SaleDate)

----------------------------------------------------------------------

--2 standarize The values in sold_as_vacant using The case statment

SELECT 
    SoldAsVacant,

CASE 
    WHEN SoldAsVacant='N' THEN 'NO'
    WHEN SoldAsVacant ='Y' THEN 'Yes'
    ELSE SoldAsVacant
END

FROM
    housing
GROUP BY
     SoldAsVacant

---update The column
UPDATE housing 

SET SoldAsVacant =

CASE 
    WHEN SoldAsVacant='N' THEN 'NO'
    WHEN SoldAsVacant ='Y' THEN 'Yes'
    ELSE SoldAsVacant
END
-----------------------------------------------------------------------------------

---Null Values in Property adress column 

/*
    Poupilating the null property adress values using The parcal_id column as Referance
 an self join is the best way to do that ,when looking at the data some rows have a parcal_id but the address value is missing


*/

SELECT 
    a.ParcelID , a.PropertyAddress,b.ParcelID,b.PropertyAddress,
    ISNULL(a.PropertyAddress,b.PropertyAddress)-- The is null function to fill the null values with specific values
FROM
    housing as a
JOIN 
    housing as b 
on 
    a.ParcelID=b.ParcelID
WHERE 
    a.PropertyAddress IS NULL AND
 a.[UniqueID ]<>b.[UniqueID ]


---Update The Table
UPDATE
     a
SET 
    PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM
    housing as a
JOIN 
    housing as b 
on 
    a.ParcelID=b.ParcelID
WHERE 
    a.PropertyAddress IS NULL AND
    a.[UniqueID ]<>b.[UniqueID ]
 ----------------------------------------------------------------------------------------------------------------------


 ---split The property adress column 

SELECT 
    SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)---getting The data before the ','
    ,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))---using the len function to get The index
FROM 
    housing

ALTER TABLE portfolio.dbo.housing
ADD Street_adress NVARCHAR(225) 

ALTER TABLE portfolio.dbo.housing
ADD  City  NVARCHAR(225) 

----Update Table
UPDATE 
    housing 
set 
    Street_adress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


UPDATE 
    housing 
set 
     City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
---------------------------------------------------------------------------------------

/*  
    locating Duplicates  
    Duplicate means duplicate rows so we will use row numbr function to get the row number  Thats greater than 1
*/

WITH ROWS as
 (
SELECT 
    *,ROW_NUMBER() OVER (

PARTITION BY 
        ParcelID ,PropertyAddress,
        SaleDate, SalePrice,LegalReference
ORDER BY 
    UniqueID
)row_num

FROM 
    housing
)



SELECT *
 FROM 
    ROWS WHERE row_num >1

-----The Data ABOVE are The Duplicates 
------------------------------------------------------------------------------------------------------

---Removing Unused Columns 

ALTER TABLE portfolio.dbo.housing
drop COLUMN PropertyAddress ,SaleDate,TaxDistrict


