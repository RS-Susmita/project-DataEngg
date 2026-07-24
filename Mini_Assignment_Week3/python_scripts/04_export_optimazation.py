#%%
import pandas as pd
orders = pd.read_csv("../data/orders.csv")

# %%
# 1. Export analytical dataset into:  
#o CSV  
# o Parquet 
orders_csv = orders.head(20)
print(orders_csv)
                         
# %%
orders.to_parquet("../data/orders_export.parquet", index=False)


# %%
# %%
# Compare storage size
import os

csv_size = os.path.getsize("../data/orders_export.csv")
parquet_size = os.path.getsize("../data/orders_export.parquet")

print("CSV:", csv_size)

print("Parquet:", parquet_size)
# %%
# Compare read performance
# %%
import time

start = time.time()
pd.read_csv("../data/orders_export.csv")
csv_time = time.time() - start

start = time.time()
pd.read_parquet("../data/orders_export.parquet")
parquet_time = time.time() - start

print("CSV Read Time:", csv_time)

print("Parquet Read Time:", parquet_time)

# %%
