-- ============================================================
-- EdTech India SQL Analysis
-- Queries (PostgreSQL)
-- ============================================================
-- Each query answers a business question and is labelled with
-- the main SQL concept it demonstrates. Queries are arranged
-- roughly from simple to more advanced.
-- ============================================================


-- ------------------------------------------------------------
-- 1. Revenue and completion rate by course category
-- Concept: JOIN, GROUP BY, aggregate functions
-- Business question: which course categories bring in the most
-- revenue, and how do they compare on completion rate?
-- ------------------------------------------------------------
SELECT
    c.category,
    COUNT(*) AS total_enrollments,
    ROUND(SUM(e.net_revenue_inr), 2) AS total_revenue,
    ROUND(AVG(e.gross_margin_pct), 2) AS avg_margin_pct,
    ROUND(
        100.0 * SUM(CASE WHEN e.course_completed = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS completion_rate_pct
FROM enrollments e
JOIN courses c ON c.course_id = e.course_id
GROUP BY c.category
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 2. Monthly revenue trend per company
-- Concept: date functions, GROUP BY with multiple columns
-- Business question: how does each company's revenue change
-- month to month?
-- ------------------------------------------------------------
SELECT
    comp.company_name,
    DATE_TRUNC('month', e.enrollment_date)::date AS month,
    ROUND(SUM(e.net_revenue_inr), 2) AS monthly_revenue
FROM enrollments e
JOIN companies comp ON comp.company_id = e.company_id
GROUP BY comp.company_name, DATE_TRUNC('month', e.enrollment_date)
ORDER BY comp.company_name, month;


-- ------------------------------------------------------------
-- 3. Rank courses by completion rate within each city tier
-- Concept: window function (RANK with PARTITION BY)
-- Business question: within each city tier, which courses have
-- the highest completion rates?
-- ------------------------------------------------------------
WITH course_tier_stats AS (
    SELECT
        e.city_tier,
        c.course_name,
        COUNT(*) AS total_enrollments,
        ROUND(
            100.0 * SUM(CASE WHEN e.course_completed = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
            2
        ) AS completion_rate_pct
    FROM enrollments e
    JOIN courses c ON c.course_id = e.course_id
    GROUP BY e.city_tier, c.course_name
)
SELECT
    city_tier,
    course_name,
    total_enrollments,
    completion_rate_pct,
    RANK() OVER (
        PARTITION BY city_tier
        ORDER BY completion_rate_pct DESC
    ) AS rank_in_tier
FROM course_tier_stats
ORDER BY city_tier, rank_in_tier;


-- ------------------------------------------------------------
-- 4. Running total of refunds over time
-- Concept: window function (SUM with ORDER BY for running total)
-- Business question: how is the cumulative number of refunds
-- growing month by month?
-- ------------------------------------------------------------
WITH monthly_refunds AS (
    SELECT
        DATE_TRUNC('month', enrollment_date)::date AS month,
        SUM(CASE WHEN refund_issued = 'Yes' THEN 1 ELSE 0 END) AS refunds_this_month
    FROM enrollments
    GROUP BY DATE_TRUNC('month', enrollment_date)
)
SELECT
    month,
    refunds_this_month,
    SUM(refunds_this_month) OVER (ORDER BY month) AS running_total_refunds
FROM monthly_refunds
ORDER BY month;


-- ------------------------------------------------------------
-- 5. Companies with above-average student ratings
-- Concept: CTE, subquery, HAVING
-- Business question: which companies have an average rating
-- higher than the overall platform average?
-- ------------------------------------------------------------
WITH company_ratings AS (
    SELECT
        comp.company_name,
        ROUND(AVG(e.student_rating), 2) AS avg_rating,
        COUNT(*) AS total_enrollments
    FROM enrollments e
    JOIN companies comp ON comp.company_id = e.company_id
    GROUP BY comp.company_name
)
SELECT
    company_name,
    avg_rating,
    total_enrollments
FROM company_ratings
WHERE avg_rating > (SELECT AVG(student_rating) FROM enrollments)
ORDER BY avg_rating DESC;


-- ------------------------------------------------------------
-- 6. Year-over-year revenue growth by category
-- Concept: window function (LAG) for period-over-period comparison
-- Business question: how has each category's revenue changed
-- from one year to the next?
-- ------------------------------------------------------------
WITH yearly_revenue AS (
    SELECT
        c.category,
        EXTRACT(YEAR FROM e.enrollment_date)::int AS year,
        ROUND(SUM(e.net_revenue_inr), 2) AS total_revenue
    FROM enrollments e
    JOIN courses c ON c.course_id = e.course_id
    GROUP BY c.category, EXTRACT(YEAR FROM e.enrollment_date)
)
SELECT
    category,
    year,
    total_revenue,
    LAG(total_revenue) OVER (PARTITION BY category ORDER BY year) AS previous_year_revenue,
    ROUND(
        100.0 * (total_revenue - LAG(total_revenue) OVER (PARTITION BY category ORDER BY year))
        / LAG(total_revenue) OVER (PARTITION BY category ORDER BY year),
        2
    ) AS yoy_growth_pct
FROM yearly_revenue
ORDER BY category, year;


-- ------------------------------------------------------------
-- 7. Discount level vs refund rate
-- Concept: CASE expression, GROUP BY on a derived column
-- Business question: are bigger discounts associated with
-- higher refund rates?
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN discount_pct = 0 THEN 'No Discount'
        WHEN discount_pct <= 15 THEN 'Low (1-15%)'
        WHEN discount_pct <= 30 THEN 'Medium (16-30%)'
        ELSE 'High (>30%)'
    END AS discount_band,
    COUNT(*) AS total_enrollments,
    ROUND(
        100.0 * SUM(CASE WHEN refund_issued = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS refund_rate_pct
FROM enrollments
GROUP BY discount_band
ORDER BY refund_rate_pct DESC;


-- ------------------------------------------------------------
-- 8. Top 5 courses by net revenue, with company and category
-- Concept: JOIN across three tables, LIMIT
-- Business question: which individual courses generate the
-- most revenue, and who runs them?
-- ------------------------------------------------------------
SELECT
    c.course_name,
    c.category,
    comp.company_name,
    COUNT(*) AS total_enrollments,
    ROUND(SUM(e.net_revenue_inr), 2) AS total_revenue
FROM enrollments e
JOIN courses c ON c.course_id = e.course_id
JOIN companies comp ON comp.company_id = e.company_id
GROUP BY c.course_name, c.category, comp.company_name
ORDER BY total_revenue DESC
LIMIT 5;
