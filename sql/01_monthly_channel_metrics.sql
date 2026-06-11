-- Task 1: Monthly bookings, unique customers, transacted value,
-- take rate, revenue, spend, and ROI per channel, past 12 complete months.
-- Database: Vertica
-- Definitions: Take Rate = revenue / transacted_value, ROI = revenue / spend

SELECT
    DATE_TRUNC('month', b.date)::DATE      AS month,
    b.marketing_channel                    AS channel,
    COUNT(DISTINCT b.booking_id)           AS monthly_bookings,
    COUNT(DISTINCT b.customer_id)          AS unique_customers,
    SUM(b.transacted_value)                AS total_transacted_value,
    SUM(b.revenue)                         AS total_revenue,
    SUM(b.spend)                           AS total_spend,
    CASE
        WHEN SUM(b.transacted_value) > 0
        THEN (SUM(b.revenue) / SUM(b.transacted_value)) * 100
        ELSE 0
    END                                    AS take_rate_pct,
    CASE
        WHEN SUM(b.spend) > 0
        THEN SUM(b.revenue) / SUM(b.spend)
        ELSE 0
    END                                    AS roi
FROM bookings b
WHERE b.date >= CURRENT_DATE - INTERVAL '12 months'
  AND DATE_TRUNC('month', b.date) <= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 day')
GROUP BY DATE_TRUNC('month', b.date), b.marketing_channel
ORDER BY month DESC, channel;
