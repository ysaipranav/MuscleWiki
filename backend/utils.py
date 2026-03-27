"""
Convert workout-data.json to CSV format.

Usage:
    python utils.py
"""

import os
import pandas as pd

DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')

src = os.path.join(DATA_DIR, 'workout-data.json')
dst = os.path.join(DATA_DIR, 'workout-data.csv')

pd.read_json(src).to_csv(dst, index=False)
print(f'Wrote {dst}')
