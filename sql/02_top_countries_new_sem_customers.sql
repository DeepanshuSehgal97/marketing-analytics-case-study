-- Task 2: Top 5 countries by new customers acquired through SEM in the last 30 days.
-- "New user" = first booking date within the period.
-- Database: Vertica

WITH customer_first_booking AS (
    SELECT
        customer_id,
        MIN(date) AS first_booking_ever_date
    FROM bookings
    WHERE booking_id IS NOT NULL
    GROUP BY customer_id
),
new_sem_customers AS (
    SELECT
        b.customer_id,
        b.departure_country AS country,
        b.date              AS first_booking_date
    FROM bookings b
    INNER JOIN customer_first_booking cfb
        ON b.customer_id = cfb.customer_id
       AND b.date        = cfb.first_booking_ever_date
    WHERE b.marketing_channel = 'SEM'
      AND b.booking_id IS NOT NULL
      AND b.date >= CURRENT_DATE - INTERVAL '30 days'
)
SELECT
    country,
    COUNT(DISTINCT customer_id)                                       AS new_customers_acquired,
    RANK() OVER (ORDER BY COUNT(DISTINCT customer_id) DESC)           AS rank
FROM new_sem_customers
GROUP BY country
ORDER BY new_customers_acquired DESC
LIMIT 5;
