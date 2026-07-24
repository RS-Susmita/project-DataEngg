#%%
import pandas as pd
print("Hello from Python cell")
# %%
# read all data sets
customers=pd.read_csv("../data/customers.csv")
orders=pd.read_csv("../data/orders.csv")
products=pd.read_csv("../data/products.csv")
clickstream=pd.read_csv("../data/clickstream.csv")
print(customers.head)
print("Customers:", len(customers))
print("Orders:", len(orders))
print("Products:", len(products))
print("Clickstream:", len(clickstream))


# %%
# Validate Schema Consistency

print(customers.columns)
print(orders.columns)
print(products.columns)
print(clickstream.columns)
print(customers.info)
print(orders.info)
# %%
# Delete Duplicate Customers:

# %%
duplicate_customers = customers[customers.duplicated(subset="customer_id")]

duplicate_customers
print(len(duplicate_customers))
# %%
# Identify Invalid Records
# %%
invalid_orders = orders[orders["quantity"] <= 0]

print(invalid_orders)
invalid_price = orders[orders["unit_price"] <= 0]
invalid_price
# %%
