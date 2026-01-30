# 🛒 Shopverse – Advanced E-Commerce Sales Analytics (SQL + Power BI)
https://app.powerbi.com/view?r=eyJrIjoiMTNkOTM4OWYtNTM3NC00MTcyLTk5MDQtYzRhNzk3NWYxYTg4IiwidCI6ImU4MGY3YzcwLThhNTMtNGFjYS1hNTFiLTg0NzVmNjNkMDUxZSJ9
## 📌 Project Overview
**Shopverse** is an end-to-end **advanced e-commerce analytics project** built using **MySQL and Power BI**.  
The project focuses on analyzing **sales performance, profitability, customer behavior, payment patterns, and target achievement** using a **view-driven SQL architecture** and interactive Power BI dashboards.
<img width="1025" height="586" alt="image" src="https://github.com/user-attachments/assets/9b7ef622-9cee-4458-850a-07ec77963c78" />
<img width="1025" height="586" alt="image" src="https://github.com/user-attachments/assets/a2bdb23f-db24-4c62-ae4c-28b6a3ecd24e" />
<img width="1025" height="586" alt="image" src="https://github.com/user-attachments/assets/cbb1feb7-e11a-4ca7-b58e-10cf6c36e37f" />


This project is designed to demonstrate **real-world business analytics skills** suitable for **Data Analyst / Business Analyst roles**.


---

## 🛠 Tools & Technologies
- **Database:** MySQL  
- **Visualization:** Power BI  
- **Data Modeling:** SQL Views  
- **Analytics:** KPIs, YoY Growth, Target vs Actual, Profit Margins  
- **Design:** Dark-theme dashboard with KPI indicators & donut charts  

---

## 📂 Dataset Structure
- `orders` – transactional sales data (revenue, profit, targets, dates)
- `products` – product, category, sub-category details
- `customers` – customer demographics and geography
- `campaigns` – campaign metadata
- `calendar` – date intelligence

All datasets are **relationally consistent** and optimized for analytical queries.

---

## 🧠 Business Problems Solved
- Monthly & yearly sales and profit analysis
- Revenue and profit **target achievement tracking**
- Category & sub-category performance comparison
- Customer Lifetime Value (LTV) analysis
- New vs repeat customer identification
- Payment mode contribution and usage trends
- Regional and country-level performance analysis
- YoY growth and cumulative performance tracking

---

## 🗄 SQL Design Approach
✔ **View-based architecture**  
✔ Each business question mapped to **one reusable SQL view**  
✔ Optimized for **direct Power BI consumption (no transformations needed)**  

### Key SQL Views Created
- `shopverse_sales_overview`
- `shopverse_cumulative_revenue_profit`
- `shopverse_yoy_summary`
- `shopverse_aov_category`
- `shopverse_cat_subcat_performance`
- `shopverse_customer_ltv`
- `shopverse_repeat_purchases`
- `shopverse_payment_mode_analysis`
- `shopverse_revenue_target_analysis`
- `shopverse_profit_target_analysis`
- `shopverse_monthly_achievement_rate`
- `shopverse_target_status`
- `shopverse_profitability_dashboard`
*(40+ analytical views in total)*

---

## 📊 Power BI Dashboard Structure

### 🔵 Page 1: Executive Overview
**Goal:** Overall business health

**KPIs**
- Total Revenue
- Total Profit
- Total Orders
- Revenue Target Status (▲ / ▼)
- Profit Target Status (▲ / ▼)

**Charts**
- Revenue & Profit Trend (Dual Line)
- Revenue vs Target (Donut)
- Profit vs Target (Donut)
- Monthly Orders Trend

---

### 🟢 Page 2: Product & Customer Insights
**Goal:** Identify key business drivers

**KPIs**
- Average Order Value (AOV)
- Top Category Revenue
- Top Product Profit
- New Customers
- Repeat Customers

**Charts**
- Category Revenue (Bar)
- Best vs Worst Sub-Category Margin
- Customer Lifetime Value (Table)
- Gender-wise Revenue (Donut)
- AOV Trend (Line)

---

### 🟣 Page 3: Targets & Achievement Analysis
**Goal:** Strategic performance tracking

**KPIs**
- Actual Revenue
- Target Revenue
- Revenue Achievement %
- Actual Profit
- Profit Achievement %

**Charts**
- Achievement Trend (Revenue & Profit – Dual Line)
- Revenue Achievement (Donut)
- Profit Achievement (Donut)
- Region-wise Achievement (Bar)
- Category Achievement Rate (Bar)
- Target Status Summary (Table)

---

## 📈 Key Analytics Techniques Used
- Window functions (`RANK()`, `LAG()`)
- Cumulative calculations
- YoY growth analysis
- Profit margin & achievement ratios
- Conditional logic for KPI status
- Aggregation-level optimization for dashboards

---

## 🎯 Project Highlights
✔ Realistic business-driven dataset  
✔ Advanced SQL (CTEs, window functions, analytics)  
✔ Clean Power BI model using **SQL views only**  
✔ KPI indicators with positive/negative logic  
✔ Dashboard optimized for executive storytelling  

---

## 📁 Repository Contents
📦 Shopverse
┣ 📄 shopverse.sql # Complete SQL views & business logic
┣ 📄 shopverse.pdf # Power BI dashboard export
┣ 📄 README.md # Project documentation

---

## 🚀 Use Case
This project can be used as:
- A **portfolio project** for Data Analyst roles
- A **Power BI + SQL case study**
- A **real-world e-commerce analytics reference**

---

## 👤 Author
**Akhil Madanu**  
Data Analytics | SQL | Power BI | Business Intelligence

🔗 GitHub: https://github.com/AkhilMadanu21

