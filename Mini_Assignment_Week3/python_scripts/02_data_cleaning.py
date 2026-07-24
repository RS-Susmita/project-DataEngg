# %%
import pandas as pd
print("Hello from Python cell")

customers = pd.read_csv("../data/customers.csv")
orders = pd.read_csv("../data/orders.csv")
products = pd.read_csv("../data/products.csv")
clickstream = pd.read_csv("../data/clickstream.csv")
# %%
# standerdize city names

# %%
customers["city"] = customers["city"].str.title()

customers.head()
# %%
# Convert timestamps correctly.  (if any)
# %%
clickstream["event_timestamp"] = pd.to_datetime(clickstream["event_timestamp"])

clickstream.info()

# %%
# %%
# Handle missing values.  (if any)
customers.isnull().sum()

orders.isnull().sum()

products.isnull().sum()

clickstream.isnull().sum()
# %%
# Remove corrupted rows.  
orders = orders[
    (orders["quantity"] > 0)
    &
    (orders["unit_price"] > 0)
]
# %%
