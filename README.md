# 2022 Layoffs Data Cleaning Project

This repository contains SQL scripts for cleaning and standardizing the 2022 tech industry layoffs dataset from Kaggle.

## Dataset

**Source**: [Layoffs 2022 Dataset on Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022)

The dataset tracks tech industry layoffs in 2022, including information about:
- Companies
- Industries
- Number of employees laid off
- Percentage of workforce affected
- Dates of layoff announcements
- Company stages (startup, public, etc.)
- Countries
- Total funds raised by companies

## Data Cleaning Process

The cleaning process follows four key steps:

### 1. Removing Duplicates

- Created staging tables to protect raw data
- Identified duplicates using ROW_NUMBER() with business keys
- Removed duplicate records while keeping one copy

### 2. Standardizing Data

- Trimmed leading and trailing spaces from company names
- Standardized industry classifications (e.g., normalized "crypto", "Crypto", "Cryptocurrency" to "Crypto")
- Removed trailing periods from country names
- Converted string dates to standard SQL DATE format

### 3. Handling NULL or Blank Values

- Converted empty strings to proper NULL values
- Identified records with missing critical data
- Filled in missing industry values based on other records of the same company

### 4. Removing Unnecessary Data

- Removed rows with no meaningful layoff information (both total and percentage NULL)
- Dropped temporary columns used in the cleaning process

## Usage

1. Import the raw dataset into your MySQL database
2. Execute the SQL scripts in order
3. The final clean dataset will be available in the `layoffs_staging2` table

## Schema of Cleaned Dataset

| Column                | Data Type | Description                               |
|-----------------------|-----------|-------------------------------------------|
| company               | text      | Company name                              |
| location              | text      | Company location                          |
| industry              | text      | Industry sector                           |
| total_laid_off        | int       | Number of employees laid off              |
| percentage_laid_off   | text      | Percentage of workforce laid off          |
| date                  | date      | Date of layoff announcement               |
| stage                 | text      | Company stage (startup, public, etc.)     |
| country               | text      | Country where layoffs occurred            |
| funds_raised_millions | int       | Total funding raised in millions of USD   |

## Potential Analysis Questions

With this cleaned dataset, you can explore:

1. Which industries experienced the most layoffs?
2. How do layoffs correlate with company funding levels?
3. What trends appear over time throughout 2022?
4. How do public companies compare to startups in layoff patterns?
5. Geographic distribution of tech layoffs globally

## Requirements

- MySQL 8.0 or higher
- Basic understanding of SQL

