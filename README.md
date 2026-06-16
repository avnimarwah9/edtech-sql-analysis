# EdTech India — SQL Analysis

A SQL project that builds on my earlier Excel project using the same EdTech enrolment dataset, this time working with a relational database in PostgreSQL. The goal was to move from a single spreadsheet to a proper database with multiple related tables, and to practice the kind of queries used in real data analysis: joins, aggregations, window functions, and common table expressions (CTEs).

## About this project

This is a practice project built on a synthetic dataset of around 2,500 student enrolments across 15 Indian EdTech companies (the same dataset used in my [Excel KPI analysis project](https://github.com/avnimarwah9/edtech-excel-kpi-analysis)).

While working with this dataset in SQL, I found a data quality issue that wasn’t obvious in the spreadsheet: several company names had trailing spaces (for example, `BYJU'S` and `BYJU'S  ` were being treated as two different companies). I cleaned this during the export so the database now has the correct 15 distinct companies. I also found and removed 8 exact duplicate enrolment records.

## Database design

The original flat spreadsheet was split into three related tables:

|Table        |Description                                                                                                       |
|-------------|------------------------------------------------------------------------------------------------------------------|
|`companies`  |15 distinct EdTech companies                                                                                      |
|`courses`    |29 distinct courses, with category and base price                                                                 |
|`enrollments`|around 2,500 enrolment records, linked to companies and courses, with pricing, completion, rating, and refund data|

City and city tier are kept at the enrolment level, since they describe where the student is based rather than where the company operates.

## Files

- `schema.sql` — table definitions and indexes
- `load_data.sql` — commands to load the CSV data into the tables
- `queries.sql` — 8 queries answering business questions, from simple aggregations to window functions
- `data/` — the cleaned CSV files (companies, courses, enrollments)

## How to run this

1. Create a database in PostgreSQL.
1. Run `schema.sql` to create the tables.
1. Run `load_data.sql` from the project folder to load the CSV files (uses `\copy`, so run it from `psql`).
1. Run any query from `queries.sql`.

## Queries included

1. Revenue and completion rate by course category
1. Monthly revenue trend per company
1. Rank courses by completion rate within each city tier (window function)
1. Running total of refunds over time (window function)
1. Companies with above-average student ratings (CTE and subquery)
1. Year-over-year revenue growth by category (window function with LAG)
1. Discount level vs refund rate
1. Top 5 courses by net revenue, with company and category

## Key findings

- Coding & Tech has the highest total revenue and the highest completion rate among course categories.
- Enrolments with discounts above 30% have a noticeably higher refund rate (around 10.6%) than enrolments with no discount (around 8.7%), suggesting heavy discounting may attract less committed students.
- Completion rates for the same course can vary a lot by city tier, with Tier 1 cities generally showing higher completion for technical courses like Data Science and Data Analytics.

## Tools used

PostgreSQL (joins, GROUP BY, CASE expressions, CTEs, window functions: RANK, LAG, running totals with SUM OVER)
