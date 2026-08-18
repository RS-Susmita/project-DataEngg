import duckdb
from datetime import date

# Connect to your local duckdb file
con = duckdb.connect('dev.duckdb')

# Query to count rows for today
today = date.today().isoformat()
result = con.execute(f"SELECT COUNT(*) FROM dev.daily_revenue WHERE date = '{today}'").fetchone()

if result[0] == 0:
    print("❌ Validation Failed: No data found for today!")
    exit(1) # Exits with error status
else:
    print("✅ Validation Passed: Today's data is present.")
