-- ============================================================
-- EdTech India SQL Analysis
-- Schema definition (PostgreSQL)
-- ============================================================
-- This schema normalises the original Excel dataset into three
-- related tables: companies, courses, and enrollments.
--
-- The original flat dataset had company names with inconsistent
-- trailing whitespace (e.g. "BYJU'S" and "BYJU'S  " were treated
-- as different companies). This was cleaned during export so
-- there are 15 distinct companies, each appearing across multiple
-- cities. City and city tier are kept at the enrollment level,
-- since they describe where the student is based, not where the
-- company is headquartered.
-- ============================================================

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS companies;

CREATE TABLE companies (
    company_id   INTEGER PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE courses (
    course_id     INTEGER PRIMARY KEY,
    course_name   VARCHAR(100) NOT NULL,
    category      VARCHAR(50)  NOT NULL,
    base_price_inr NUMERIC(10,2) NOT NULL
);

CREATE TABLE enrollments (
    enrollment_id     VARCHAR(10) PRIMARY KEY,
    enrollment_date   DATE NOT NULL,
    company_id        INTEGER NOT NULL REFERENCES companies(company_id),
    course_id         INTEGER NOT NULL REFERENCES courses(course_id),
    city              VARCHAR(50),
    state             VARCHAR(50),
    city_tier         VARCHAR(10),
    gender            VARCHAR(10),
    age_group         VARCHAR(10),
    referral_source   VARCHAR(50),
    payment_mode      VARCHAR(30),
    device_type       VARCHAR(20),
    original_price_inr NUMERIC(10,2),
    discount_pct       NUMERIC(5,2),
    discount_amount_inr NUMERIC(10,2),
    final_price_inr     NUMERIC(10,2),
    gst_amount_inr      NUMERIC(10,2),
    net_revenue_inr     NUMERIC(10,2),
    platform_cost_inr   NUMERIC(10,2),
    gross_profit_inr    NUMERIC(10,2),
    gross_margin_pct    NUMERIC(5,2),
    course_completed    VARCHAR(3),
    student_rating      NUMERIC(3,1),
    refund_issued       VARCHAR(3),
    support_tickets_raised INTEGER
);

-- Helpful indexes for the queries in queries.sql
CREATE INDEX idx_enrollments_company ON enrollments(company_id);
CREATE INDEX idx_enrollments_course  ON enrollments(course_id);
CREATE INDEX idx_enrollments_date    ON enrollments(enrollment_date);
