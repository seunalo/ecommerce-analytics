-- ============================================================
-- E-COMMERCE ANALYTICS SQL QUERIES
-- Author: Oluwaseun Alo
-- Description: SQL queries for e-commerce data analysis
-- ============================================================

-- NOTE: These queries are designed for a hypothetical SQL database
-- containing the same data as the UCI Online Retail dataset.
-- Table structure: transactions(invoice_no, stock_code, description, 
--                              quantity, invoice_date, unit_price, 
--                              customer_id, country)

-- ============================================================
-- 1. BASIC BUSINESS METRICS
-- ============================================================

-- Total Revenue, Transactions, and Customers
SELECT 
    ROUND(SUM(quantity * unit_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice_no) AS total_transactions,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT stock_code) AS total_products,
    ROUND(SUM(quantity * unit_price) / COUNT(DISTINCT invoice_no), 2) AS avg_order_value
FROM transactions
WHERE quantity > 0 
  AND unit_price > 0
  AND customer_id IS NOT NULL;

-- ============================================================
-- 2. TIME-BASED ANALYSIS
-- ============================================================

-- Monthly Revenue Trend
SELECT 
    DATE_TRUNC('month', invoice_date) AS month,
    ROUND(SUM(quantity * unit_price), 2) AS revenue,
    COUNT(DISTINCT invoice_no) AS num_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM transactions
WHERE quantity > 0 AND unit_price > 0
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY month;

-- Revenue by Day of Week
SELECT 
    EXTRACT(DOW FROM invoice_date) AS day_of_week,
    CASE EXTRACT(DOW FROM invoice_date)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    ROUND(SUM(quantity * unit_price), 2) AS revenue,
    COUNT(DISTINCT invoice_no) AS num_orders
FROM transactions
WHERE quantity > 0 AND unit_price > 0
GROUP BY EXTRACT(DOW FROM invoice_date)
ORDER BY day_of_week;

-- Revenue by Hour of Day
SELECT 
    EXTRACT(HOUR FROM invoice_date) AS hour_of_day,
    ROUND(SUM(quantity * unit_price), 2) AS revenue,
    COUNT(DISTINCT invoice_no) AS num_orders
FROM transactions
WHERE quantity > 0 AND unit_price > 0
GROUP BY EXTRACT(HOUR FROM invoice_date)
ORDER BY hour_of_day;

-- Month-over-Month Growth Rate
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', invoice_date) AS month,
        SUM(quantity * unit_price) AS revenue
    FROM transactions
    WHERE quantity > 0 AND unit_price > 0
    GROUP BY DATE_TRUNC('month', invoice_date)
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) / 
        NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 
        2
    ) AS growth_rate_pct
FROM monthly_revenue
ORDER BY month;

-- ============================================================
-- 3. PRODUCT ANALYSIS
-- ============================================================

-- Top 10 Products by Revenue
SELECT 
    stock_code,
    description,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(quantity * unit_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice_no) AS num_orders
FROM transactions
WHERE quantity > 0 AND unit_price > 0
GROUP BY stock_code, description
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 Products by Quantity Sold
SELECT 
    stock_code,
    description,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(quantity * unit_price), 2) AS total_revenue
FROM transactions
WHERE quantity > 0 AND unit_price > 0
GROUP BY stock_code, description
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- Product Category Performance (using description keywords)
SELECT 
    CASE 
        WHEN LOWER(description) LIKE '%bag%' THEN 'Bags'
        WHEN LOWER(description) LIKE '%box%' THEN 'Boxes'
        WHEN LOWER(description) LIKE '%candle%' THEN 'Candles'
        WHEN LOWER(description) LIKE '%christmas%' THEN 'Christmas'
        WHEN LOWER(description) LIKE '%clock%' THEN 'Clocks'
        WHEN LOWER(description) LIKE '%frame%' THEN 'Frames'
        WHEN LOWER(description) LIKE '%heart%' THEN 'Heart Items'
        WHEN LOWER(description) LIKE '%light%' THEN 'Lights'
        ELSE 'Other'
    END AS category,
    COUNT(DISTINCT stock_code) AS num_products,
    ROUND(SUM(quantity * unit_price), 2) AS total_revenue
FROM transactions
WHERE quantity > 0 AND unit_price > 0
GROUP BY category
ORDER BY total_revenue DESC;

-- ============================================================
-- 4. CUSTOMER ANALYSIS (RFM)
-- ============================================================

-- RFM Metrics Calculation
WITH customer_rfm AS (
    SELECT 
        customer_id,
        -- Recency: days since last purchase
        EXTRACT(DAY FROM (
            (SELECT MAX(invoice_date) FROM transactions) - MAX(invoice_date)
        )) AS recency,
        -- Frequency: number of orders
        COUNT(DISTINCT invoice_no) AS frequency,
        -- Monetary: total spend
        ROUND(SUM(quantity * unit_price), 2) AS monetary
    FROM transactions
    WHERE quantity > 0 
      AND unit_price > 0 
      AND customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    -- RFM Scores (1-5 scale using NTILE)
    NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency) AS f_score,
    NTILE(5) OVER (ORDER BY monetary) AS m_score
FROM customer_rfm
ORDER BY monetary DESC;

-- Customer Segmentation based on RFM Scores
WITH customer_rfm AS (
    SELECT 
        customer_id,
        EXTRACT(DAY FROM (
            (SELECT MAX(invoice_date) FROM transactions) - MAX(invoice_date)
        )) AS recency,
        COUNT(DISTINCT invoice_no) AS frequency,
        ROUND(SUM(quantity * unit_price), 2) AS monetary
    FROM transactions
    WHERE quantity > 0 AND unit_price > 0 AND customer_id IS NOT NULL
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM customer_rfm
)
SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost'
        ELSE 'Others'
    END AS customer_segment
FROM rfm_scores;

-- Customer Segment Summary
WITH customer_segments AS (
    -- (Using the same CTE structure as above, abbreviated here)
    SELECT 
        customer_id,
        monetary,
        CASE 
            WHEN NTILE(5) OVER (ORDER BY recency DESC) >= 4 
                AND NTILE(5) OVER (ORDER BY frequency) >= 4 
                AND NTILE(5) OVER (ORDER BY monetary) >= 4 THEN 'Champions'
            WHEN NTILE(5) OVER (ORDER BY recency DESC) <= 2 
                AND NTILE(5) OVER (ORDER BY frequency) <= 2 THEN 'Lost'
            ELSE 'Others'
        END AS segment
    FROM (
        SELECT 
            customer_id,
            EXTRACT(DAY FROM (
                (SELECT MAX(invoice_date) FROM transactions) - MAX(invoice_date)
            )) AS recency,
            COUNT(DISTINCT invoice_no) AS frequency,
            SUM(quantity * unit_price) AS monetary
        FROM transactions
        WHERE quantity > 0 AND unit_price > 0 AND customer_id IS NOT NULL
        GROUP BY customer_id
    ) rfm
)
SELECT 
    segment,
    COUNT(*) AS num_customers,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_customers
FROM customer_segments
GROUP BY segment
ORDER BY total_revenue DESC;

-- ============================================================
-- 5. GEOGRAPHIC ANALYSIS
-- ============================================================

-- Revenue by Country
SELECT 
    country,
    COUNT(DISTINCT customer_id) AS num_customers,
    COUNT(DISTINCT invoice_no) AS num_orders,
    ROUND(SUM(quantity * unit_price), 2) AS total_revenue,
    ROUND(AVG(quantity * unit_price), 2) AS avg_order_value
FROM transactions
WHERE quantity > 0 AND unit_price > 0
GROUP BY country
ORDER BY total_revenue DESC
LIMIT 15;

-- Revenue Percentage by Country
WITH country_revenue AS (
    SELECT 
        country,
        SUM(quantity * unit_price) AS revenue
    FROM transactions
    WHERE quantity > 0 AND unit_price > 0
    GROUP BY country
)
SELECT 
    country,
    ROUND(revenue, 2) AS revenue,
    ROUND(revenue * 100.0 / SUM(revenue) OVER (), 2) AS pct_of_total
FROM country_revenue
ORDER BY revenue DESC
LIMIT 10;

-- ============================================================
-- 6. COHORT ANALYSIS
-- ============================================================

-- Customer Cohort by First Purchase Month
WITH customer_first_purchase AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month
    FROM transactions
    WHERE customer_id IS NOT NULL AND quantity > 0
    GROUP BY customer_id
),
customer_activity AS (
    SELECT 
        t.customer_id,
        cfp.cohort_month,
        DATE_TRUNC('month', t.invoice_date) AS activity_month,
        EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', t.invoice_date), cfp.cohort_month)) AS month_number
    FROM transactions t
    JOIN customer_first_purchase cfp ON t.customer_id = cfp.customer_id
    WHERE t.quantity > 0
)
SELECT 
    cohort_month,
    month_number,
    COUNT(DISTINCT customer_id) AS num_customers
FROM customer_activity
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;

-- ============================================================
-- 7. ADVANCED ANALYTICS
-- ============================================================

-- Customer Lifetime Value (CLV) Estimation
WITH customer_stats AS (
    SELECT 
        customer_id,
        MIN(invoice_date) AS first_purchase,
        MAX(invoice_date) AS last_purchase,
        COUNT(DISTINCT invoice_no) AS num_orders,
        SUM(quantity * unit_price) AS total_revenue,
        EXTRACT(DAY FROM (MAX(invoice_date) - MIN(invoice_date))) AS customer_lifespan_days
    FROM transactions
    WHERE quantity > 0 AND unit_price > 0 AND customer_id IS NOT NULL
    GROUP BY customer_id
    HAVING COUNT(DISTINCT invoice_no) > 1  -- Repeat customers only
)
SELECT 
    customer_id,
    num_orders,
    ROUND(total_revenue, 2) AS total_revenue,
    customer_lifespan_days,
    ROUND(total_revenue / NULLIF(customer_lifespan_days, 0) * 365, 2) AS annualized_value,
    ROUND(total_revenue / num_orders, 2) AS avg_order_value
FROM customer_stats
ORDER BY total_revenue DESC
LIMIT 20;

-- Market Basket Analysis: Frequently Bought Together
WITH order_products AS (
    SELECT DISTINCT 
        invoice_no,
        stock_code,
        description
    FROM transactions
    WHERE quantity > 0 AND unit_price > 0
)
SELECT 
    a.description AS product_a,
    b.description AS product_b,
    COUNT(*) AS times_bought_together
FROM order_products a
JOIN order_products b 
    ON a.invoice_no = b.invoice_no 
    AND a.stock_code < b.stock_code
GROUP BY a.description, b.description
HAVING COUNT(*) > 50
ORDER BY times_bought_together DESC
LIMIT 20;

-- ============================================================
-- 8. KPI DASHBOARD QUERIES
-- ============================================================

-- Daily KPIs for Dashboard
SELECT 
    DATE(invoice_date) AS date,
    ROUND(SUM(quantity * unit_price), 2) AS daily_revenue,
    COUNT(DISTINCT invoice_no) AS daily_orders,
    COUNT(DISTINCT customer_id) AS daily_customers,
    ROUND(SUM(quantity * unit_price) / COUNT(DISTINCT invoice_no), 2) AS daily_aov
FROM transactions
WHERE quantity > 0 AND unit_price > 0
GROUP BY DATE(invoice_date)
ORDER BY date;

-- Rolling 7-Day Metrics
WITH daily_metrics AS (
    SELECT 
        DATE(invoice_date) AS date,
        SUM(quantity * unit_price) AS revenue,
        COUNT(DISTINCT invoice_no) AS orders
    FROM transactions
    WHERE quantity > 0 AND unit_price > 0
    GROUP BY DATE(invoice_date)
)
SELECT 
    date,
    revenue,
    orders,
    ROUND(AVG(revenue) OVER (
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_7day_avg_revenue,
    ROUND(AVG(orders) OVER (
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_7day_avg_orders
FROM daily_metrics
ORDER BY date;

-- ============================================================
-- END OF QUERIES
-- ============================================================
