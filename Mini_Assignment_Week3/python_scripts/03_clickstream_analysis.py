# %%
import pandas as pd

clickstream = pd.read_csv("../data/clickstream.csv")
print("Clickstream:", len(clickstream))
clickstream.head(10)

# %%
# 1. Find the most visited pages
clickstream["page_url"].value_counts()

# %%
# 2. Calculate session counts.  
# %%
session_counts = clickstream.groupby("customer_id").size()
session_counts
# %%
# 3. Find bounce rate.  
bounce = session_counts[session_counts == 1]
bounce_rate = len(bounce) / len(session_counts) * 100
print(bounce_rate)

# %%
# 4. Find mobile vs desktop traffic percentage.  
device = clickstream["device_type"].value_counts(normalize=True) * 100
device
# %%
