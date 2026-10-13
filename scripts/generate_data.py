import csv
import random
from datetime import datetime, timedelta
import os

def generate_ecommerce_data(num_records=15000, random_seed=42):
    random.seed(random_seed)
    
    num_customers = 1200
    customer_ids = [f"CUST-{1000 + i}" for i in range(num_customers)]
    
    products = [
        {"StockCode": "PRD-001", "Description": "Wireless Bluetooth Earbuds", "UnitPrice": 49.99, "Category": "Electronics"},
        {"StockCode": "PRD-002", "Description": "Noise-Cancelling Headphones", "UnitPrice": 149.99, "Category": "Electronics"},
        {"StockCode": "PRD-003", "Description": "Mechanical Gaming Keyboard", "UnitPrice": 89.50, "Category": "Electronics"},
        {"StockCode": "PRD-004", "Description": "Ergonomic Office Chair Cushion", "UnitPrice": 34.00, "Category": "Home & Office"},
        {"StockCode": "PRD-005", "Description": "Stainless Steel Thermal Flask", "UnitPrice": 22.50, "Category": "Home & Kitchen"},
        {"StockCode": "PRD-006", "Description": "Smart Fitness Tracker Band", "UnitPrice": 59.90, "Category": "Wearables"},
        {"StockCode": "PRD-007", "Description": "Ultra-Wide Gaming Mouse Pad", "UnitPrice": 18.00, "Category": "Accessories"},
        {"StockCode": "PRD-008", "Description": "4K USB-C Multiport Hub", "UnitPrice": 45.00, "Category": "Accessories"},
        {"StockCode": "PRD-009", "Description": "LED Desk Lamp with Wireless Charger", "UnitPrice": 39.99, "Category": "Home & Office"},
        {"StockCode": "PRD-010", "Description": "Compact Espresso Coffee Machine", "UnitPrice": 119.00, "Category": "Home & Kitchen"},
        {"StockCode": "PRD-011", "Description": "Portable External SSD 1TB", "UnitPrice": 95.00, "Category": "Electronics"},
        {"StockCode": "PRD-012", "Description": "Organic Cotton Bed Sheet Set", "UnitPrice": 54.00, "Category": "Home & Living"},
    ]
    
    countries = ["United Kingdom", "Germany", "France", "United States", "Australia", "Canada", "India"]
    country_weights = [0.65, 0.10, 0.08, 0.07, 0.04, 0.03, 0.03]
    
    start_date = datetime(2024, 1, 1)
    end_date = datetime(2024, 12, 31)
    date_range_days = (end_date - start_date).days
    
    invoice_counter = 100000
    current_invoice = f"INV-{invoice_counter}"
    current_customer = random.choice(customer_ids)
    current_country = random.choices(countries, weights=country_weights, k=1)[0]
    current_date = start_date + timedelta(days=random.randint(0, date_range_days), hours=random.randint(8, 20), minutes=random.randint(0, 59))
    
    output_dir = os.path.join(os.path.dirname(__file__), "..", "data")
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, "ecommerce_raw_transactions.csv")
    
    with open(output_path, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["InvoiceNo", "StockCode", "Description", "Quantity", "InvoiceDate", "UnitPrice", "CustomerID", "Country", "Category"])
        
        for i in range(num_records):
            if i % random.randint(1, 4) == 0:
                invoice_counter += 1
                current_invoice = f"INV-{invoice_counter}"
                if random.random() < 0.35:
                    current_customer = customer_ids[random.randint(0, 150)] # Loyal segment
                else:
                    current_customer = random.choice(customer_ids)
                current_country = random.choices(countries, weights=country_weights, k=1)[0]
                current_date = start_date + timedelta(days=random.randint(0, date_range_days), hours=random.randint(8, 20), minutes=random.randint(0, 59))
                
            prod = random.choice(products)
            qty = random.choices([1, 2, 3, 4, 5, 8, 10, -1], weights=[0.50, 0.25, 0.10, 0.05, 0.04, 0.03, 0.02, 0.01], k=1)[0]
            inv_no = f"C{current_invoice}" if qty < 0 else current_invoice
            cust_id = "" if random.random() < 0.02 else current_customer
            
            writer.writerow([
                inv_no,
                prod["StockCode"],
                prod["Description"],
                qty,
                current_date.strftime("%Y-%m-%d %H:%M:%S"),
                prod["UnitPrice"],
                cust_id,
                current_country,
                prod["Category"]
            ])
            
    print(f"Generated {num_records} transactions and saved to {output_path}")

if __name__ == "__main__":
    generate_ecommerce_data()
