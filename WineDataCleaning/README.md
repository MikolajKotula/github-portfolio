# Wine Data Cleaning Project

## Introduction
The Wine Data Cleaning Project carefully examines and improves a dataset focused on wines. The goal is to enhance the dataset's quality by fixing inconsistencies, inaccuracies, and missing information. Advanced SQL queries are used to create a standardized and dependable dataset, paving the way for insightful analysis and exploration of the diverse world of wines.
Data soures:
https://www.kaggle.com/datasets/elvinrustam/wine-dataset
### Features:
- Title: The name or title of the wine.
- Description: A brief textual description providing additional details about the wine.
- Price: The cost of the wine.
- Capacity: The volume or size of the wine bottle.
- Grape: The primary grape variety used in making the wine.
- Secondary Grape Varieties: Additional grape varieties used in the wine blend.
- Closure: The type of closure used for the bottle.
- Country: The country where the wine is produced.
- Unit: units of alcohol in wine
- Characteristics: The "Characteristics" feature encapsulates the unique and discernible flavors and aromas present in a particular wine.
- Per bottle / case / each: The quantity of wine included per unit (bottle, case, or each) sold.
- Type: The general category of the wine.
- ABV: The percentage of alcohol content in the wine.
- Region: The geographic region where the grapes used to make the wine are grown.
- Style: This feature describes the overall sensory experience and characteristics of the wine.
- Vintage: The year the grapes used to make the wine were harvested.
- Appellation: A legally defined and protected geographical indication used to identify where the grapes for a wine were grown.

## Summary
The Wine Data Cleaning Project includes:
- Removal of characters from numeric columns.
- Conversion of values in the "Capacity" column to a standardized unit (liters).
- Correcting vintage years.
- Replacement of some missing values in "Appellation" with information from the "Title."
- Replacement of missing and empty values with NULL.
- Removal of duplicates.
- Removal of wines in cases and boxes. There are only 6 wines per case and 5 per each (boxed wine). For every case and box, there is a traditional 0.75 bottle).
- Correcting encoding errors

List of finctions used for the project:
- SUBSTRING
- PATINDEX
- CASE, WHEN
- CHARINDEX
- REPLACE
- CAST
- JOIN


