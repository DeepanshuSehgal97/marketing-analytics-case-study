-- Task 3: Lifetime value and average bookings for Spanish customers acquired in the past year.
-- "LTV" defined as average profit and bookings per customer during the first 365 days post-acquisition.
-- Database: Vertica

WITH customer_first_booking_ever AS (
    SELECT
        customer_id,
        MIN(date) AS first_booking_ever_date
    FROM bookings
    WHERE booking_id IS NOT NULL
    GROUP BY customer_id
),
spanish_new_customers AS (
    SELECT
        c.customer_id,
        b.date AS acquisition_date
    FROM customers c
    INNER JOIN bookings b
        ON c.customer_id = b.customer_id
    INNER JOIN customer_first_booking_ever cfbe
        ON b.customer_id = cfbe.customer_id
       AND b.date        = cfbe.first_booking_ever_date
    WHERE b.departure_country = 'ES'
      AND b.booking_id IS NOT NULL
      AND b.date >= CURRENT_DATE - INTERVAL '365 days'
),
customer_365_day_activity AS (
    SELECT
        snc.customer_id,
        snc.acquisition_date,
        COUNT(DISTINCT b.booking_id) AS total_bookings,
        SUM(b.profit)                AS total_profit,
        SUM(b.revenue)               AS total_revenue
    FROM spanish_new_customers snc
    INNER JOIN bookings b
        ON snc.customer_id = b.customer_id
    WHERE b.booking_id IS NOT NULL
      AND b.date >= snc.acquisition_date
      AND b.date <= snc.acquisition_date + INTERVAL '365 days'
    GROUP BY snc.customer_id, snc.acquisition_date
)
SELECT
    COUNT(DISTINCT customer_id)        AS total_spanish_customers_acquired,
    ROUND(AVG(total_profit), 2)        AS avg_lifetime_profit_365_days,
    ROUND(AVG(total_bookings), 2)      AS avg_bookings_per_customer_365_days,
    ROUND(AVG(total_revenue), 2)       AS avg_revenue_per_customer_365_days,
    SUM(total_profit)                  AS total_cohort_profit,
    SUM(total_bookings)                AS total_cohort_bookings
FROM customer_365_day_activity;
