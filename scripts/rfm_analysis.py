import csv
from datetime import datetime
from collections import defaultdict
import json
import os

def run_rfm_analysis():
    input_file = os.path.join(os.path.dirname(__file__), "..", "data", "ecommerce_raw_transactions.csv")
    if not os.path.exists(input_file):
        print("Data file not found. Run generate_data.py first.")
        return
    
    customers = defaultdict(lambda: {"latest_date": None, "invoices": set(), "total_spend": 0.0, "country": ""})
    max_date = datetime.min
    
    with open(input_file, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            cust_id = row["CustomerID"]
            if not cust_id:
                continue
            
            inv_date = datetime.strptime(row["InvoiceDate"], "%Y-%m-%d %H:%M:%S")
            if inv_date > max_date:
                max_date = inv_date
                
            qty = int(row["Quantity"])
            unit_price = float(row["UnitPrice"])
            inv_no = row["InvoiceNo"]
            country = row["Country"]
            
            if qty > 0 and not inv_no.startswith("C"):
                total_val = qty * unit_price
                customers[cust_id]["invoices"].add(inv_no)
                customers[cust_id]["total_spend"] += total_val
                customers[cust_id]["country"] = country
                if customers[cust_id]["latest_date"] is None or inv_date > customers[cust_id]["latest_date"]:
                    customers[cust_id]["latest_date"] = inv_date

    # Reference anchor date
    reference_date = max_date
    rfm_table = []
    
    for cust_id, data in customers.items():
        if data["total_spend"] <= 0 or data["latest_date"] is None:
            continue
        recency = (reference_date - data["latest_date"]).days
        frequency = len(data["invoices"])
        monetary = round(data["total_spend"], 2)
        rfm_table.append({
            "CustomerID": cust_id,
            "Country": data["country"],
            "Recency": recency,
            "Frequency": frequency,
            "Monetary": monetary
        })
        
    # Sort for quantile calculation
    rfm_table.sort(key=lambda x: x["Recency"], reverse=True) # lower is better, so reverse for 1-5 score
    n = len(rfm_table)
    for idx, row in enumerate(rfm_table):
        row["R_Score"] = min(5, int((idx / n) * 5) + 1)
        
    rfm_table.sort(key=lambda x: x["Frequency"])
    for idx, row in enumerate(rfm_table):
        row["F_Score"] = min(5, int((idx / n) * 5) + 1)
        
    rfm_table.sort(key=lambda x: x["Monetary"])
    for idx, row in enumerate(rfm_table):
        row["M_Score"] = min(5, int((idx / n) * 5) + 1)

    segments = defaultdict(lambda: {"count": 0, "total_revenue": 0.0, "recency_sum": 0, "orders_sum": 0})
    
    for row in rfm_table:
        r, f, m = row["R_Score"], row["F_Score"], row["M_Score"]
        if r >= 4 and f >= 4 and m >= 4:
            seg = "Champions"
        elif r >= 3 and f >= 3 and m >= 3:
            seg = "Loyal Customers"
        elif r >= 3 and f >= 1 and m >= 2:
            seg = "Potential Loyalists"
        elif r >= 4 and f == 1:
            seg = "Recent New Customers"
        elif r <= 2 and f >= 3 and m >= 3:
            seg = "At Risk (High Value)"
        elif r <= 2 and f <= 2 and m >= 3:
            seg = "Hibernating Big Spenders"
        elif r == 1 and f <= 2:
            seg = "Lost Customers"
        else:
            seg = "Promising"
            
        row["Segment"] = seg
        segments[seg]["count"] += 1
        segments[seg]["total_revenue"] += row["Monetary"]
        segments[seg]["recency_sum"] += row["Recency"]
        segments[seg]["orders_sum"] += row["Frequency"]

    summary = []
    total_rev_all = sum(s["total_revenue"] for s in segments.values())
    total_cust_all = sum(s["count"] for s in segments.values())
    
    for seg, vals in sorted(segments.items(), key=lambda x: x[1]["total_revenue"], reverse=True):
        summary.append({
            "segment": seg,
            "customers": vals["count"],
            "customer_share_pct": round(vals["count"] * 100.0 / total_cust_all, 2),
            "total_revenue": round(vals["total_revenue"], 2),
            "revenue_share_pct": round(vals["total_revenue"] * 100.0 / total_rev_all, 2),
            "avg_recency_days": round(vals["recency_sum"] / vals["count"], 1),
            "avg_orders": round(vals["orders_sum"] / vals["count"], 1)
        })
        
    out_file = os.path.join(os.path.dirname(__file__), "..", "data", "rfm_segmented_summary.json")
    with open(out_file, mode="w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
        
    print(f"RFM analysis completed across {len(rfm_table)} active customers.")
    print(f"Summary written to {out_file}")

if __name__ == "__main__":
    run_rfm_analysis()
