# E-commerce Sales Analytics & Customer Segmentation

![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)
![Pandas](https://img.shields.io/badge/Pandas-1.3+-green.svg)
![Scikit-learn](https://img.shields.io/badge/Scikit--learn-0.24+-orange.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

A comprehensive data analytics project analyzing e-commerce transaction data to uncover sales patterns, segment customers, and provide actionable business insights.

## Project Overview

This project analyzes transactional data from a UK-based online retail company to answer critical business questions:

- **What are our peak sales periods and best-selling products?**
- **Who are our most valuable customers?**
- **Which customer segments should marketing prioritize?**
- **How can we predict future demand for inventory planning?**

## Key Results

| Metric | Value |
|--------|-------|
| Total Revenue Analyzed | $8.9M+ |
| Customers Segmented | 4,300+ |
| Actionable Insights | 6 key recommendations |
| Customer Segments | 8 distinct groups |

### Business Impact

- Identified **Champions segment** (top customers) representing 12% of customers but 35% of revenue
- Discovered **Tuesday-Thursday** as peak sales days with opportunity for weekend promotions
- Found **November peak** for seasonal inventory planning
- Flagged **"At Risk" customers** for re-engagement campaigns

## 🛠️ Technical Skills Demonstrated

- **Data Cleaning & Preprocessing**: Handling missing values, outliers, data type conversions
- **Exploratory Data Analysis**: Sales trends, product analysis, geographic distribution
- **Customer Segmentation**: RFM (Recency, Frequency, Monetary) analysis
- **Machine Learning**: K-Means clustering for customer grouping
- **Time Series Analysis**: Revenue forecasting with moving averages
- **Data Visualization**: Matplotlib, Seaborn for insights communication
- **SQL**: Complex queries including CTEs, window functions, aggregations

## Project Structure

```
ecommerce-analytics-project/
│
├── ecommerce_analytics.ipynb    # Main Jupyter notebook with full analysis
├── sql_queries.sql              # SQL queries for database analysis
├── requirements.txt             # Python dependencies
├── README.md                    # Project documentation
│
├── outputs/                     # Generated outputs
│   ├── customer_segments.csv    # Customer segmentation results
│   ├── monthly_revenue.csv      # Monthly revenue data
│   └── visualizations/          # Generated charts
│
└── data/                        # Data directory (not included)
    └── online_retail.xlsx       # UCI Online Retail Dataset
```

## Quick Start

### Prerequisites

- Python 3.9+
- Jupyter Notebook or JupyterLab

### Installation

1. Clone the repository:
```bash
git clone https://github.com/seunalo/ecommerce-analytics.git
cd ecommerce-analytics
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Launch Jupyter Notebook:
```bash
jupyter notebook ecommerce_analytics.ipynb
```

The notebook will automatically download the dataset from UCI Machine Learning Repository.

## Analysis Highlights

### 1. Revenue Trends
![Monthly Revenue](outputs/monthly_revenue_trend.png)

- Strong seasonal pattern with **November peak** (holiday shopping)
- Average monthly revenue: **$685K**
- Month-over-month growth varies from -15% to +45%

### 2. Customer Segmentation (RFM Analysis)

| Segment | % Customers | % Revenue | Action |
|---------|-------------|-----------|--------|
| Champions | 12% | 35% | VIP rewards program |
| Loyal Customers | 18% | 28% | Early access to sales |
| At Risk | 15% | 12% | Re-engagement campaign |
| Lost | 22% | 5% | Win-back offers |

### 3. K-Means Clustering
![Customer Clusters](outputs/kmeans_clusters.png)

Applied unsupervised learning to validate RFM segments and discover natural customer groupings.

### 4. Key Recommendations

1. **Launch VIP Program** for Champions segment (35% of revenue)
2. **Re-engagement Campaign** for "At Risk" customers before they churn
3. **Inventory Planning** - increase stock 30% for November peak
4. **Marketing Timing** - schedule campaigns for 10 AM - 12 PM (peak hours)
5. **Weekend Promotions** - currently underperforming vs weekdays
6. **International Expansion** - Germany & France show growth potential

## 🔧 Technologies Used

| Category | Tools |
|----------|-------|
| Programming | Python 3.9 |
| Data Manipulation | Pandas, NumPy |
| Visualization | Matplotlib, Seaborn |
| Machine Learning | Scikit-learn |
| Database | SQL (PostgreSQL syntax) |
| Development | Jupyter Notebook, Git |

## SQL Skills Demonstrated

The `sql_queries.sql` file includes:

- **Basic Aggregations**: Revenue, customer counts, averages
- **Window Functions**: Running totals, month-over-month growth, rolling averages
- **CTEs**: Complex multi-step queries for RFM analysis
- **Cohort Analysis**: Customer retention by acquisition month
- **Market Basket Analysis**: Frequently bought together products

Example query (Month-over-Month Growth):
```sql
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', invoice_date) AS month,
        SUM(quantity * unit_price) AS revenue
    FROM transactions
    GROUP BY DATE_TRUNC('month', invoice_date)
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / 
          LAG(revenue) OVER (ORDER BY month) * 100, 2) AS growth_pct
FROM monthly_revenue;
```

## 📚 Data Source

**UCI Online Retail Dataset**
- Source: [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/datasets/online+retail)
- Records: 541,909 transactions
- Period: December 2010 - December 2011
- Region: UK-based online retailer with international customers

## Connect With Me

- **LinkedIn**: [linkedin.com/in/seunalo](https://linkedin.com/in/seunalo)


---

*If you found this project useful, please consider giving it a ⭐!*
