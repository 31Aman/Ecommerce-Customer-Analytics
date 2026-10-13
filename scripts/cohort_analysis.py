import csv
from datetime import datetime
from collections import defaultdict
import json
import os

def run_cohort_analysis():
    input_file = os.path.join(os.path.dirname(__file__), "..", "data", "ecommerce_raw_transactions.csv")
    if not os.path.exists(input_file):
        print("Data file not found.")
        return
        
    first_purchase = {}
    customer_months = defaultdict(set)
    
    with open(input_file, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            cust_id = row["CustomerID"]
            qty = int(row["Quantity"])
            inv_no = row["InvoiceNo"]
            if not cust_id or qty <= 0 or inv_no.startswith("C"):
                continue
                
            inv_date = datetime.strptime(row["InvoiceDate"], "%Y-%m-%d %H:%M:%S")
            month_key = (inv_date.year, inv_date.month)
            
            customer_months[cust_id].add(month_key)
            if cust_id not in first_purchase or inv_date < first_purchase[cust_id]:
                first_purchase[cust_id] = inv_date
                
    cohort_sizes = defaultdict(int)
    customer_cohorts = {}
    
    for cust_id, date in first_purchase.items():
        c_month = (date.year, date.month)
        customer_cohorts[cust_id] = c_month
        cohort_sizes[c_month] += 1
        
    cohort_retention = defaultdict(lambda: defaultdict(int))
    
    for cust_id, active_months in customer_months.items():
        c_year, c_month = customer_cohorts[cust_id]
        for a_year, a_month in active_months:
            idx = (a_year - c_year) * 12 + (a_month - c_month)
            cohort_retention[(c_year, c_month)][idx] += 1
            
    matrix = []
    for c_month in sorted(cohort_sizes.keys()):
        total = cohort_sizes[c_month]
        row_data = {
            "cohort": f"{c_month[0]}-{c_month[1]:02d}",
            "initial_users": total,
            "retention_rates": {}
        }
        for idx in range(12):
            if idx in cohort_retention[c_month]:
                active = cohort_retention[c_month][idx]
                pct = round(active * 100.0 / total, 1)
                row_data["retention_rates"][f"M_{idx}"] = f"{pct}%"
        matrix.append(row_data)
        
    out_file = os.path.join(os.path.dirname(__file__), "..", "data", "cohort_retention_matrix.json")
    with open(out_file, mode="w", encoding="utf-8") as f:
        json.dump(matrix, f, indent=2)
        
    print(f"Cohort retention analysis completed for {len(matrix)} monthly cohorts.")
    print(f"Matrix written to {out_file}")

if __name__ == "__main__":
    run_cohort_analysis()
