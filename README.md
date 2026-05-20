# Workforce Aligner: Dynamic Capacity Modeling & Staffing Optimization

## Project Overview
Workforce Aligner is an end-to-end data analytics project designed to transform raw customer support ticket volumes into precise, human-centric staffing requirements. By pairing historical data engineering with dynamic visualization, this project exposes major operational mismatches caused by static scheduling. The repository contains the core SQL data transformation pipeline, mathematical formulas for staffing demand, and data models optimized for interactive Tableau dashboards.

## Business Problem
The organization operates on a rigid, flat staffing model (averaging 4 agents per hour) that assumes static customer demand throughout the day. This operational disconnect causes severe business friction:
* **Morning Resource Crises:** Dynamic customer demand drastically outpaces flat staffing levels during peak morning windows.
* **Capital Waste:** Overnight shifts are systematically overstaffed during prolonged low-volume hours.
* **Operational Blind Spots:** Leadership lacked a direct mathematical link between incoming ticket volume and the actual number of human beings needed to handle the workload.

## Objectives
* **Engineer Feature Context:** Build a robust data pipeline that eliminates null metrics and structures full rolling historical contexts for modeling.
* **Quantify Human Demand:** Translate raw inbound ticket volumes into Required Full-Time Equivalents (FTEs) to maintain a healthy 85% agent occupancy target.
* **Identify Operational Risk:** Isolate exact windows of high volatility, customer SLA failure risks, and agent burnout triggers.
* **Provide Actionable Scheduling Solutions:** Deliver mathematical proof to justify moving from fixed schedules to flexible, demand-driven shifts.

## Tools Used
* **SQL (Data Engineering):** Window functions (`LAG`, `OVER`, `ROWS BETWEEN`) used for data cleansing, lag feature creation, and rolling 3-hour average metrics.
* **Tableau (Data Visualization):** Advanced scatter plots and distribution dashboards engineered with custom shelf labels and reference lines to display capacity breakpoints.
* **Mathematical Modeling:** Capacity ratio calculations mapping ticket volume directly to workforce staffing needs.

## Analysis Approach
1. **Data Cleansing & Warm-up Filtering:** Filtered out the first 24 hours of data to ensure the model only learned from complete features with full historical context, cleanly removing null values from lag features.
2. **Feature Engineering:** Extracted previous-day volume comparisons and built rolling 3-hour short-term volume trends to act as early-warning indicators.
3. **Correlation Analysis:** Evaluated the mathematical relationship between actual ticket volumes and workforce scaling to identify operational efficiencies and scaling limitations.
4. **Temporal Volatility Mapping:** Plotted day-to-day resource needs grouped by hour to isolate predictable trends from chaotic demand spikes.

## Charts
The Tableau workbook is structured around three foundational visual proofs:

### 1. The Demand vs. Timeline Scatter Plot
* **X-Axis:** Time of Day (Hours 0–23)
* **Y-Axis:** Actual Ticket Volume
* **Visual Mechanics:** Individual data points represent unique hours across different days, with `Required Staff` calculations placed directly on the Label shelf.
* **Function:** Serves as the "smoking gun" visual that maps the sudden explosion of volume variance against a flat operational timeline.

### 2. The Labor Efficiency & Scalability Curve
* **X-Axis:** Actual Ticket Volume
* **Y-Axis:** Required Staff (FTE)
* **Visual Mechanics:** Direct linear correlation plots exposing the tight relationship between effort and headcount.
* **Function:** Acts as a budgeting and forecasting tool showing how the operation breaks down as volume approaches a "burnout ceiling."

### 3. The Scheduling Blueprint (Staffing Towers)
* **X-Axis:** Hour of Day
* **Y-Axis:** Required Staff (FTE)
* **Visual Mechanics:** Vertical columns showing the exact spread of human resources required for every hour across all analyzed history.
* **Function:** Highlights the severe operational penalty of scheduling for a flat average.

## Insights and Recommendations

### Insights
* **The Morning Staffing Crisis:** Data points are tight and predictable overnight until **Hour 8**. Between Hour 8 and Hour 11, volume drastically spikes from a baseline of ~5 tickets up to a peak of 27.
* **The 8-Agent Peak:** While average staffing is kept at 4 agents, peak morning spikes mathematically require **8.1 FTEs** to maintain basic service level agreements.
* **The Nightly Lull:** Hours 0 to 5 show flat, bottomed-out volume. Keeping a standard headcount here results in idle staff and direct capital waste.
* **Linear Scaling Constraints:** The business lacks economies of scale. For every **~3 additional tickets per hour**, the operation must add exactly **1 additional agent** to prevent operational failure.

### Recommendations
* **Deploy Split Shifts & Staggered Starts:** Transition early-morning and night staff to targeted 8:00 AM or 9:00 AM start times to realign existing headcount without increasing total labor costs.
* **Introduce a "Flex" Layer:** Recruit part-time or surge agents dedicated exclusively to a 4-hour window (8:00 AM – 12:00 PM) to absorb the vertical morning spikes.
* **Automate Low-Value Volume:** Implement conversational AI or automated self-service tools. Deflecting just 5 tickets per hour via automation structurally breaks the linear scaling model and saves 1.5 FTEs.
* **Establish an Operational Red-Line:** Create an automated "Peak Protocol" policy triggered whenever the rolling 3-hour volume field indicates a requirement of **6.0+ staff**, immediately pausing non-essential meetings and routing back-office staff into the queue.

## Business Implications
* **Burnout & Attrition Risk:** During peak morning hours, agent occupancy exceeds 100%. Unpredictable morning shifts drive high workplace stress, errors, and quiet quitting.
* **SLA Failures:** Customers contacting support between 8:00 AM and 11:00 AM face extreme wait times, damaging brand reputation and triggering contract penalties.
* **Financial Inefficiency:** The organization is paying for identical headcount at 3:00 AM as it does at 9:00 AM, heavily overpaying for low-value hours while under-investing in critical high-value revenue hours.

***

## Data Engineering Pipeline (SQL)
The following SQL view prepares the clean analytics dataset by removing historical initialization gaps:

```sql
SELECT * FROM (
    SELECT 
        date, 
        hour, 
        actual_ticket_volume, 
        avg_handle_time,
        -- Generates historical baseline for day-over-day tracking
        LAG(actual_ticket_volume, 24) OVER (ORDER BY date, hour) as prev_day_vol,
        -- Generates short-term rolling momentum metrics
        ROUND(AVG(actual_ticket_volume) OVER (ORDER BY date, hour ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING), 2) as rolling_vol_3h
    FROM staff_optization.hourly_staffing_needs
) AS final_view
-- Filters out the first 24 hours of data to ensure the model only learned from complete features
WHERE prev_day_vol IS NOT NULL;
```
