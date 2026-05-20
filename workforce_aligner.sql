SELECT * FROM staff_optization.agent_roster;
SELECT * FROM staff_optization.hourly_staffing_needs;
SELECT * FROM staff_optization.ticket_logs;

SELECT 
    date,
    hour,
    actual_ticket_volume,
    avg_handle_time,
    -- Lag Features: What happened this same hour yesterday?
    LAG(actual_ticket_volume, 24) OVER (ORDER BY date, hour) as prev_day_vol,
    -- Rolling Average: Last 3 hours trend
    ROUND(AVG(actual_ticket_volume) OVER (ORDER BY date, hour ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING), 2) as rolling_vol_3h
FROM staff_optization.hourly_staffing_needs;
#They are simply "warm-up" rows.
#prev_day_vol: Since you’re looking back 24 hours (LAG 24), the first 24 rows of your dataset have no "yesterday" to look at yet.
#rolling_vol_3h: The first row has no "previous 3 hours" to average.



#I filtered out the first 24 hours of data to ensure the model only learned from complete features with full historical context.
#this got rid of the nulls
SELECT * FROM (
    SELECT 
        date, 
        hour, 
        actual_ticket_volume, 
        avg_handle_time,
        LAG(actual_ticket_volume, 24) OVER (ORDER BY date, hour) as prev_day_vol,
        ROUND(AVG(actual_ticket_volume) OVER (ORDER BY date, hour ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING), 2) as rolling_vol_3h
    FROM staff_optization.hourly_staffing_needs
) AS final_view
WHERE prev_day_vol IS NOT NULL; -- This removes the first 24 "broken" rows

