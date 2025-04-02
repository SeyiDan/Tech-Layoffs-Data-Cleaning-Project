-- SQL Project - Data Cleaning for 2022 Layoffs Dataset
-- Dataset source: https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- First, examine the raw data to understand its structure
select * 
from layoffs;

-- -----------------------------------------------------
-- 1. REMOVE DUPLICATES
-- -----------------------------------------------------

-- Create a staging table to protect the raw data from direct modifications
-- This is a best practice to avoid corrupting original data
Create table layoffs_staging like layoffs;

-- Verify the staging table structure matches the original
Select*
from layoffs_staging;

-- Populate the staging table with data from the original table
insert layoffs_staging 
select * from layoffs;

-- Identify duplicate rows by assigning row numbers
-- Rows with row_num > 1 are duplicates based on our partition keys
select *, row_number() over(partition by industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

-- More comprehensive duplicate check that includes all relevant business keys
-- We use a CTE (Common Table Expression) to identify duplicates
with duplicate_cte as
(
select *, row_number() over(partition by company, industry, total_laid_off,percentage_laid_off, `date`, stage,country, funds_raised_millions) as row_num
from layoffs_staging)
delete from duplicate_cte where row_num > 1;
-- Note: This DELETE statement would typically work in some databases but might not in MySQL directly with CTEs

-- Create another staging table to handle duplicates more effectively in MySQL
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Verify the new staging table is empty
Select*
from layoffs_staging2 where row_num >1;

-- Insert data from first staging table into the second staging table with row numbers
-- to identify duplicates
insert layoffs_staging2
select *, row_number() over(partition by company, industry, total_laid_off,percentage_laid_off, `date`, stage,country, funds_raised_millions) as row_num
from layoffs_staging;

-- Check to see duplicates (rows where row_num > 1)
Select*
from layoffs_staging2 where row_num >1;

-- Remove the duplicate rows
delete from layoffs_staging2 where row_num >1;

-- Verify duplicates have been removed
Select*
from layoffs_staging2;

-- -----------------------------------------------------
-- 2. STANDARDIZE THE DATA
-- -----------------------------------------------------

-- Remove leading and trailing spaces from company names
select company, trim(company) from layoffs_staging2;
update layoffs_staging2 set company = TRIM(company);

-- Check for inconsistencies in country field
select distinct country from layoffs_staging2 order by 1;

-- Standardize industry names - make all cryptocurrency-related entries consistent
select * from layoffs_staging2 where industry like 'crypto%';
update layoffs_staging2 set industry = 'Crypto' where industry like 'crypto%';

-- Remove trailing periods from country names
select distinct country, trim(trailing '.' from country) from layoffs_staging2 order by 1;
update layoffs_staging2 set country = trim(trailing '.' from country) where country like 'United States%';

-- Convert date strings to standard date format
select `date`, str_to_date(`date`, '%m/%d/%Y') from layoffs_staging2;
update layoffs_staging2 set `date` = str_to_date(`date`, '%m/%d/%Y');

-- Update column data type to match the standardized format
alter table layoffs_staging2 modify column `date` DATE;

-- -----------------------------------------------------
-- 3. HANDLE NULL OR BLANK VALUES
-- -----------------------------------------------------

-- Identify rows with missing critical data
select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

-- Convert empty strings to NULL for better data consistency
update layoffs_staging2 set industry = null where industry = '';

-- Verify NULL and empty values in industry field
select * from layoffs_staging2 where industry is null or industry = '';

-- Look at specific company data to understand patterns
select * from layoffs_staging2 where company = 'Airbnb';

-- Find cases where we can fill missing industries based on other records for the same company
select * from layoffs_staging2 t1 
join layoffs_staging2 t2 
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

-- Fill in missing industry values where possible based on other records of the same company
update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

-- -----------------------------------------------------
-- 4. REMOVE UNNECESSARY ROWS AND COLUMNS
-- -----------------------------------------------------

-- Find rows with no meaningful layoff data (both total and percentage are NULL)
select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

-- Remove rows that don't provide layoff information
delete from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

-- Remove the temporary row_num column as it's no longer needed
alter table layoffs_staging2 drop column row_num;

-- At this point, layoffs_staging2 contains our cleaned dataset ready for analysis
