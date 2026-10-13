# Executive Dashboard Design & Architecture Guide

### Multi-Page Dashboard Blueprint

#### **Page 1: Executive Overview & Revenue Performance**
* **Top KPI Ribbon Cards:**
  * Total Gross Revenue ($) with MoM delta indicator
  * Total Orders & Average Order Value (AOV)
  * Active Customer Count & Repeat Purchase Rate %
* **Visual 1 (Area Chart):** Monthly Revenue Trajectory vs Target Benchmark.
* **Visual 2 (Clustered Bar Chart):** Revenue Contribution by Product Category.
* **Visual 3 (Choropleth Map):** Global Sales Distribution by Country.

#### **Page 2: RFM Customer Segmentation**
* **Visual 1 (Treemap):** Customer distribution by RFM Segment (Champions, Loyalists, Potential Loyalists, At-Risk, Lost).
* **Visual 2 (Scatter Plot):** Monetary Value vs Recency Days, sized by Order Frequency.
* **Visual 3 (Matrix Table):** Cohort Average Order Value and Churn Probability by Segment.

#### **Page 3: Cohort Retention & Churn Analysis**
* **Visual 1 (Heatmap Matrix):** Inception Month (Cohort) vs Month Index (0–11) showing retention % decay.
* **Visual 2 (Line Chart):** Retention decay curves by customer acquisition channel.
