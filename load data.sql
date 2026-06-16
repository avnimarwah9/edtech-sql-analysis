-- ============================================================
-- EdTech India SQL Analysis
-- Data loading (PostgreSQL)
-- ============================================================
-- Run this after schema.sql, from the project folder, so the
-- relative paths to the data/ folder resolve correctly.
--
-- If \copy does not work in your client, use a full absolute
-- path to the CSV files instead, or use pgAdmin's import tool.
-- ============================================================

\copy companies   FROM 'data/companies.csv'   WITH (FORMAT csv, HEADER true);
\copy courses     FROM 'data/courses.csv'     WITH (FORMAT csv, HEADER true);
\copy enrollments FROM 'data/enrollments.csv' WITH (FORMAT csv, HEADER true);

-- Quick sanity checks after loading
SELECT 'companies' AS table_name, COUNT(*) AS row_count FROM companies
UNION ALL
SELECT 'courses', COUNT(*) FROM courses
UNION ALL
SELECT 'enrollments', COUNT(*) FROM enrollments;
