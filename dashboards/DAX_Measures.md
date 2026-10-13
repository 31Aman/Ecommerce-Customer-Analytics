# Power BI DAX Formulas Reference

This document lists the core Data Analysis Expressions (DAX) created in Power BI for the executive retail analytics dashboard.

---

### 1. Revenue & Sales Metrics

#### **Total Gross Revenue**
```dax
Total Revenue = 
SUMX(
    FILTER(fact_transactions, fact_transactions[is_cancelled] = FALSE),
    fact_transactions[quantity] * fact_transactions[unit_price]
)
```

#### **Total Orders**
```dax
Total Orders = 
DISTINCTCOUNT(fact_transactions[invoice_no])
```

#### **Average Order Value (AOV)**
```dax
Average Order Value = 
DIVIDE([Total Revenue], [Total Orders], 0)
```

---

### 2. Time Intelligence (MoM & YoY Performance)

#### **Prior Month Revenue**
```dax
Revenue PM = 
CALCULATE(
    [Total Revenue],
    DATEADD(dim_date[full_date], -1, MONTH)
)
```

#### **Month-over-Month (MoM) Growth %**
```dax
Revenue MoM Growth % = 
DIVIDE([Total Revenue] - [Revenue PM], [Revenue PM], 0)
```

---

### 3. Customer & Retention Metrics

#### **Total Active Customers**
```dax
Active Customers = 
DISTINCTCOUNT(fact_transactions[customer_id])
```

#### **Repeat Purchase Rate %**
```dax
Repeat Customer Rate = 
VAR CustomersWithMultipleOrders = 
    COUNTROWS(
        FILTER(
            VALUES(dim_customers[customer_id]),
            CALCULATE(DISTINCTCOUNT(fact_transactions[invoice_no])) > 1
        )
    )
VAR TotalCustomers = [Active Customers]
RETURN
    DIVIDE(CustomersWithMultipleOrders, TotalCustomers, 0)
```

#### **Cancellation Rate %**
```dax
Cancellation Rate % = 
VAR CancelledOrders = 
    CALCULATE(
        DISTINCTCOUNT(fact_transactions[invoice_no]),
        fact_transactions[is_cancelled] = TRUE
    )
RETURN
    DIVIDE(CancelledOrders, [Total Orders], 0)
```
