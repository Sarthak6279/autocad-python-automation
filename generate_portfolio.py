"""
AutoCAD Portfolio Generator (100 Distinct Floor Plans)

This script procedurally generates a portfolio of 100 distinct architectural
and structural floor plans in AutoCAD using pyautocad. It dynamically handles
different plot sizes (30x40, 40x50, 50x60, 20x60), facing orientations (E, W, N, S),
BHK configurations (1BHK to 6BHK, Single & Duplex), and custom details.

Usage:
  python generate_portfolio.py --list
  python generate_portfolio.py --plan CP-3040-E-1BHK-S
  python generate_portfolio.py --range 1-10
  python generate_portfolio.py --all
"""

import sys
import os
import math
import argparse
from datetime import datetime
from pathlib import Path

# Add local path and site-packages for imports
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir))

# Add main Lib/site-packages and its win32 dependencies
lib_site = script_dir / "Lib" / "site-packages"
sys.path.insert(0, str(lib_site))
sys.path.insert(0, str(lib_site / "win32"))
sys.path.insert(0, str(lib_site / "win32" / "lib"))
sys.path.insert(0, str(lib_site / "Pythonwin"))

# Add .venv/Lib/site-packages and its win32 dependencies
venv_site = script_dir / ".venv" / "Lib" / "site-packages"
sys.path.insert(0, str(venv_site))
sys.path.insert(0, str(venv_site / "win32"))
sys.path.insert(0, str(venv_site / "win32" / "lib"))
sys.path.insert(0, str(venv_site / "Pythonwin"))

try:
    from pyautocad import Autocad, APoint
    import win32com.client
except ImportError:
    print("Error: pyautocad or pywin32 not installed. Install with: pip install pyautocad pywin32")
    sys.exit(1)


# ==========================================
# 1. 100 PLAN CONFIGURATIONS DATABASE
# ==========================================
def get_plan_database():
    """Generates the list of 100 distinct plan specifications."""
    plans = []
    
    # ------------------------------------------
    # Chapter 1: Compact Series (30' x 40') - Index 1 to 25
    # ------------------------------------------
    # East-Facing (1-7)
    plans.append({'index': 1, 'id': 'CP-3040-E-1BHK-S', 'width': 30, 'depth': 40, 'facing': 'E', 'bhk': 1, 'type': 'S', 'title': '1BHK Single Floor with large front lawn', 'special_features': ['lawn']})
    plans.append({'index': 2, 'id': 'CP-3040-E-2BHK-S', 'width': 30, 'depth': 40, 'facing': 'E', 'bhk': 2, 'type': 'S', 'title': '2BHK Single Floor (Standard Layout)', 'special_features': []})
    plans.append({'index': 3, 'id': 'CP-3040-E-2BHK-SH', 'width': 30, 'depth': 40, 'facing': 'E', 'bhk': 2, 'type': 'S', 'title': '2BHK Single Floor with attached shops', 'special_features': ['shops']})
    plans.append({'index': 4, 'id': 'CP-3040-E-3BHK-S', 'width': 30, 'depth': 40, 'facing': 'E', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor (Compact room sizing)', 'special_features': []})
    plans.append({'index': 5, 'id': 'CP-3040-E-3BHK-D', 'width': 30, 'depth': 40, 'facing': 'E', 'bhk': 3, 'type': 'D', 'title': '3BHK Duplex (GF: Living, Kitchen, 1 Bed; FF: 2 Beds)', 'special_features': ['staircase']})
    plans.append({'index': 6, 'id': 'CP-3040-E-3BHK-DO', 'width': 30, 'depth': 40, 'facing': 'E', 'bhk': 3, 'type': 'D', 'title': '3BHK Duplex with a dedicated study/home office', 'special_features': ['staircase', 'study']})
    plans.append({'index': 7, 'id': 'CP-3040-E-4BHK-D', 'width': 30, 'depth': 40, 'facing': 'E', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex (Maximized space optimization)', 'special_features': ['staircase']})
    
    # North-Facing (8-14)
    plans.append({'index': 8, 'id': 'CP-3040-N-1BHK-S', 'width': 30, 'depth': 40, 'facing': 'N', 'bhk': 1, 'type': 'S', 'title': '1BHK Single Floor with a deep veranda', 'special_features': ['veranda']})
    plans.append({'index': 9, 'id': 'CP-3040-N-2BHK-S', 'width': 30, 'depth': 40, 'facing': 'N', 'bhk': 2, 'type': 'S', 'title': '2BHK Single Floor (Vastu optimized for North entrance)', 'special_features': []})
    plans.append({'index': 10, 'id': 'CP-3040-N-2BHK-SP', 'width': 30, 'depth': 40, 'facing': 'N', 'bhk': 2, 'type': 'S', 'title': '2BHK Single Floor with a dedicated pooja room', 'special_features': ['pooja']})
    plans.append({'index': 11, 'id': 'CP-3040-N-3BHK-S', 'width': 30, 'depth': 40, 'facing': 'N', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor with open-concept American kitchen', 'special_features': ['american_kitchen']})
    plans.append({'index': 12, 'id': 'CP-3040-N-3BHK-DC', 'width': 30, 'depth': 40, 'facing': 'N', 'bhk': 3, 'type': 'D', 'title': '3BHK Duplex with a central open-sky courtyard', 'special_features': ['staircase', 'courtyard']})
    plans.append({'index': 13, 'id': 'CP-3040-N-3BHK-DH', 'width': 30, 'depth': 40, 'facing': 'N', 'bhk': 3, 'type': 'D', 'title': '3BHK Duplex with a double-height living room', 'special_features': ['staircase', 'double_height']})
    plans.append({'index': 14, 'id': 'CP-3040-N-4BHK-D', 'width': 30, 'depth': 40, 'facing': 'N', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with a family lounge on first floor', 'special_features': ['staircase', 'lounge']})
    
    # West-Facing (15-20)
    plans.append({'index': 15, 'id': 'CP-3040-W-2BHK-S', 'width': 30, 'depth': 40, 'facing': 'W', 'bhk': 2, 'type': 'S', 'title': '2BHK Single Floor (Kitchen in Agni Southeast corner)', 'special_features': []})
    plans.append({'index': 16, 'id': 'CP-3040-W-2BHK-SG', 'width': 30, 'depth': 40, 'facing': 'W', 'bhk': 2, 'type': 'S', 'title': '2BHK Single Floor with rear setback garden', 'special_features': ['rear_garden']})
    plans.append({'index': 17, 'id': 'CP-3040-W-3BHK-S', 'width': 30, 'depth': 40, 'facing': 'W', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor with parallel service alleys', 'special_features': ['service_alley']})
    plans.append({'index': 18, 'id': 'CP-3040-W-3BHK-DB', 'width': 30, 'depth': 40, 'facing': 'W', 'bhk': 3, 'type': 'D', 'title': '3BHK Duplex with attached balcony for every bedroom', 'special_features': ['staircase', 'balcony']})
    plans.append({'index': 19, 'id': 'CP-3040-W-3BHK-DP', 'width': 30, 'depth': 40, 'facing': 'W', 'bhk': 3, 'type': 'D', 'title': '3BHK Duplex with an integrated car porch', 'special_features': ['staircase', 'porch']})
    plans.append({'index': 20, 'id': 'CP-3040-W-4BHK-DT', 'width': 30, 'depth': 40, 'facing': 'W', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with home theater room on first floor', 'special_features': ['staircase', 'theater']})
    
    # South-Facing (21-25)
    plans.append({'index': 21, 'id': 'CP-3040-S-2BHK-S', 'width': 30, 'depth': 40, 'facing': 'S', 'bhk': 2, 'type': 'S', 'title': '2BHK Single Floor (Main entrance on 4th Vastu pada)', 'special_features': []})
    plans.append({'index': 22, 'id': 'CP-3040-S-2BHK-SW', 'width': 30, 'depth': 40, 'facing': 'S', 'bhk': 2, 'type': 'S', 'title': '2BHK Single Floor with heavy structural walls on South', 'special_features': ['heavy_south_wall']})
    plans.append({'index': 23, 'id': 'CP-3040-S-3BHK-S', 'width': 30, 'depth': 40, 'facing': 'S', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor with a massive master suite', 'special_features': ['massive_master']})
    plans.append({'index': 24, 'id': 'CP-3040-S-3BHK-DB', 'width': 30, 'depth': 40, 'facing': 'S', 'bhk': 3, 'type': 'D', 'title': '3BHK Duplex with an overhanging front balcony', 'special_features': ['staircase', 'front_balcony']})
    plans.append({'index': 25, 'id': 'CP-3040-S-4BHK-DS', 'width': 30, 'depth': 40, 'facing': 'S', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with a servant quarter near entrance', 'special_features': ['staircase', 'servant_room']})

    # ------------------------------------------
    # Chapter 2: Executive Series (40' x 50') - Index 26 to 50
    # ------------------------------------------
    # East-Facing (26-32)
    plans.append({'index': 26, 'id': 'EX-4050-E-2BHK-S', 'width': 40, 'depth': 50, 'facing': 'E', 'bhk': 2, 'type': 'S', 'title': '2BHK Single Floor with massive living and dining hall', 'special_features': ['massive_hall']})
    plans.append({'index': 27, 'id': 'EX-4050-E-3BHK-S', 'width': 40, 'depth': 50, 'facing': 'E', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor (Standard executive layout)', 'special_features': []})
    plans.append({'index': 28, 'id': 'EX-4050-E-3BHK-SW', 'width': 40, 'depth': 50, 'facing': 'E', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor with walk-in wardrobe for master Bed', 'special_features': ['wardrobe']})
    plans.append({'index': 29, 'id': 'EX-4050-E-4BHK-S', 'width': 40, 'depth': 50, 'facing': 'E', 'bhk': 4, 'type': 'S', 'title': '4BHK Single Floor (Sprawling single-level flat layout)', 'special_features': []})
    plans.append({'index': 30, 'id': 'EX-4050-E-4BHK-DU', 'width': 40, 'depth': 50, 'facing': 'E', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with a grand U-shaped staircase core', 'special_features': ['staircase', 'u_stair']})
    plans.append({'index': 31, 'id': 'EX-4050-E-4BHK-DG', 'width': 40, 'depth': 50, 'facing': 'E', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with a dedicated home gym room', 'special_features': ['staircase', 'gym']})
    plans.append({'index': 32, 'id': 'EX-4050-E-5BHK-D', 'width': 40, 'depth': 50, 'facing': 'E', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex (Maximum room capacity for joint families)', 'special_features': ['staircase']})
    
    # North-Facing (33-39)
    plans.append({'index': 33, 'id': 'EX-4050-N-2BHK-SP', 'width': 40, 'depth': 50, 'facing': 'N', 'bhk': 2, 'type': 'S', 'title': '2BHK Single Floor with wrap-around front porch', 'special_features': ['porch', 'wrap_porch']})
    plans.append({'index': 34, 'id': 'EX-4050-N-3BHK-SK', 'width': 40, 'depth': 50, 'facing': 'N', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor with wet kitchen and dry kitchen split', 'special_features': ['wet_dry_kitchen']})
    plans.append({'index': 35, 'id': 'EX-4050-N-3BHK-SD', 'width': 40, 'depth': 50, 'facing': 'N', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor with a formal drawing room near entry', 'special_features': ['drawing_room']})
    plans.append({'index': 36, 'id': 'EX-4050-N-4BHK-S', 'width': 40, 'depth': 50, 'facing': 'N', 'bhk': 4, 'type': 'S', 'title': '4BHK Single Floor with attached bathroom for all 4 beds', 'special_features': ['all_attached']})
    plans.append({'index': 37, 'id': 'EX-4050-N-4BHK-DS', 'width': 40, 'depth': 50, 'facing': 'N', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex featuring a central spiral staircase', 'special_features': ['staircase', 'spiral_stair']})
    plans.append({'index': 38, 'id': 'EX-4050-N-4BHK-DT', 'width': 40, 'depth': 50, 'facing': 'N', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with a massive open-to-sky terrace', 'special_features': ['staircase', 'roof_terrace']})
    plans.append({'index': 39, 'id': 'EX-4050-N-5BHK-DG', 'width': 40, 'depth': 50, 'facing': 'N', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with a guest bedroom on ground floor', 'special_features': ['staircase', 'guest_room']})

    # West-Facing (40-45)
    plans.append({'index': 40, 'id': 'EX-4050-W-3BHK-SG', 'width': 40, 'depth': 50, 'facing': 'W', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor with an integrated garage space', 'special_features': ['garage']})
    plans.append({'index': 41, 'id': 'EX-4050-W-3BHK-SV', 'width': 40, 'depth': 50, 'facing': 'W', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor optimized for cross-ventilation', 'special_features': ['cross_vent']})
    plans.append({'index': 42, 'id': 'EX-4050-W-4BHK-SD', 'width': 40, 'depth': 50, 'facing': 'W', 'bhk': 4, 'type': 'S', 'title': '4BHK Single Floor with a central dining lobby', 'special_features': ['central_lobby']})
    plans.append({'index': 43, 'id': 'EX-4050-W-4BHK-DL', 'width': 40, 'depth': 50, 'facing': 'W', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with L-shaped stairs & under-stair storage', 'special_features': ['staircase', 'l_stair']})
    plans.append({'index': 44, 'id': 'EX-4050-W-4BHK-DB', 'width': 40, 'depth': 50, 'facing': 'W', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with large covered balcony lounge', 'special_features': ['staircase', 'balcony_lounge']})
    plans.append({'index': 45, 'id': 'EX-4050-W-5BHK-DM', 'width': 40, 'depth': 50, 'facing': 'W', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with 2 master bedrooms (one on each level)', 'special_features': ['staircase', 'dual_master']})

    # South-Facing (46-50)
    plans.append({'index': 46, 'id': 'EX-4050-S-3BHK-ST', 'width': 40, 'depth': 50, 'facing': 'S', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor with underground water tank shown', 'special_features': ['water_tank']})
    plans.append({'index': 47, 'id': 'EX-4050-S-3BHK-SS', 'width': 40, 'depth': 50, 'facing': 'S', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor with private rear sit-out', 'special_features': ['sitout']})
    plans.append({'index': 48, 'id': 'EX-4050-S-4BHK-SU', 'width': 40, 'depth': 50, 'facing': 'S', 'bhk': 4, 'type': 'S', 'title': '4BHK Single Floor with massive kitchen-utility zone', 'special_features': ['utility_zone']})
    plans.append({'index': 49, 'id': 'EX-4050-S-4BHK-DP', 'width': 40, 'depth': 50, 'facing': 'S', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with protective canopy over parking porch', 'special_features': ['staircase', 'parking_canopy']})
    plans.append({'index': 50, 'id': 'EX-4050-S-5BHK-DB', 'width': 40, 'depth': 50, 'facing': 'S', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with modular home bar & lounge', 'special_features': ['staircase', 'home_bar']})

    # ------------------------------------------
    # Chapter 3: Luxury Villa Series (50' x 60') - Index 51 to 75
    # ------------------------------------------
    # East-Facing (51-57)
    plans.append({'index': 51, 'id': 'LV-5060-E-3BHK-SB', 'width': 50, 'depth': 60, 'facing': 'E', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor "Bungalow Style" with 3-sided lawns', 'special_features': ['three_sided_lawn']})
    plans.append({'index': 52, 'id': 'LV-5060-E-4BHK-SF', 'width': 50, 'depth': 60, 'facing': 'E', 'bhk': 4, 'type': 'S', 'title': '4BHK Single Floor with a massive central formal hall', 'special_features': ['formal_hall']})
    plans.append({'index': 53, 'id': 'LV-5060-E-4BHK-DG', 'width': 50, 'depth': 60, 'facing': 'E', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with 2-car automatic garage integration', 'special_features': ['staircase', 'double_garage']})
    plans.append({'index': 54, 'id': 'LV-5060-E-4BHK-DO', 'width': 50, 'depth': 60, 'facing': 'E', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with private home office & library wing', 'special_features': ['staircase', 'office_library']})
    plans.append({'index': 55, 'id': 'LV-5060-E-5BHK-DL', 'width': 50, 'depth': 60, 'facing': 'E', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with massive double-height grand lobby', 'special_features': ['staircase', 'grand_lobby']})
    plans.append({'index': 56, 'id': 'LV-5060-E-5BHK-DP', 'width': 50, 'depth': 60, 'facing': 'E', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with attached pool and deck layout', 'special_features': ['staircase', 'pool']})
    plans.append({'index': 57, 'id': 'LV-5060-E-6BHK-D', 'width': 50, 'depth': 60, 'facing': 'E', 'bhk': 6, 'type': 'D', 'title': '6BHK Duplex (Elite joint family luxury layout)', 'special_features': ['staircase']})
    
    # North-Facing (58-64)
    plans.append({'index': 58, 'id': 'LV-5060-N-3BHK-SC', 'width': 50, 'depth': 60, 'facing': 'N', 'bhk': 3, 'type': 'S', 'title': '3BHK Single Floor with traditional inner courtyard', 'special_features': ['courtyard']})
    plans.append({'index': 59, 'id': 'LV-5060-N-4BHK-SU', 'width': 50, 'depth': 60, 'facing': 'N', 'bhk': 4, 'type': 'S', 'title': '4BHK Single Floor with massive store-room and outhouse', 'special_features': ['outhouse']})
    plans.append({'index': 60, 'id': 'LV-5060-N-4BHK-DF', 'width': 50, 'depth': 60, 'facing': 'N', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with modern glass-facade front elevation', 'special_features': ['staircase', 'glass_facade']})
    plans.append({'index': 61, 'id': 'LV-5060-N-4BHK-DP', 'width': 50, 'depth': 60, 'facing': 'N', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex featuring custom prayer hall capsule', 'special_features': ['staircase', 'prayer_hall']})
    plans.append({'index': 62, 'id': 'LV-5060-N-5BHK-DF', 'width': 50, 'depth': 60, 'facing': 'N', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with floating cantilever staircase design', 'special_features': ['staircase', 'floating_stair']})
    plans.append({'index': 63, 'id': 'LV-5060-N-5BHK-DT', 'width': 50, 'depth': 60, 'facing': 'N', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with dedicated home theater & gaming zone', 'special_features': ['staircase', 'theater_gaming']})
    plans.append({'index': 64, 'id': 'LV-5060-N-6BHK-DS', 'width': 50, 'depth': 60, 'facing': 'N', 'bhk': 6, 'type': 'D', 'title': '6BHK Duplex with separate staff quarters & entry', 'special_features': ['staircase', 'staff_quarters']})

    # West-Facing (65-70)
    plans.append({'index': 65, 'id': 'LV-5060-W-4BHK-SP', 'width': 50, 'depth': 60, 'facing': 'W', 'bhk': 4, 'type': 'S', 'title': '4BHK Single Floor with expansive rear patio layout', 'special_features': ['rear_patio']})
    plans.append({'index': 66, 'id': 'LV-5060-W-4BHK-SL', 'width': 50, 'depth': 60, 'facing': 'W', 'bhk': 4, 'type': 'S', 'title': '4BHK Single Floor with separate family lounge & hall', 'special_features': ['family_lounge']})
    plans.append({'index': 67, 'id': 'LV-5060-W-4BHK-DS', 'width': 50, 'depth': 60, 'facing': 'W', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with dramatic skylight framing over stairs', 'special_features': ['staircase', 'skylight']})
    plans.append({'index': 68, 'id': 'LV-5060-W-5BHK-DM', 'width': 50, 'depth': 60, 'facing': 'W', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with massive master suite on upper level', 'special_features': ['staircase', 'mega_master']})
    plans.append({'index': 69, 'id': 'LV-5060-W-5BHK-DS', 'width': 50, 'depth': 60, 'facing': 'W', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with solar panel array framing on roof', 'special_features': ['staircase', 'solar_roof']})
    plans.append({'index': 70, 'id': 'LV-5060-W-6BHK-DD', 'width': 50, 'depth': 60, 'facing': 'W', 'bhk': 6, 'type': 'D', 'title': '6BHK Duplex with dual living rooms (one on each level)', 'special_features': ['staircase', 'dual_living']})

    # South-Facing (71-75)
    plans.append({'index': 71, 'id': 'LV-5060-S-4BHK-SL', 'width': 50, 'depth': 60, 'facing': 'S', 'bhk': 4, 'type': 'S', 'title': '4BHK Single Floor with landscape boundary on South', 'special_features': ['south_landscape']})
    plans.append({'index': 72, 'id': 'LV-5060-S-4BHK-DP', 'width': 50, 'depth': 60, 'facing': 'S', 'bhk': 4, 'type': 'D', 'title': '4BHK Duplex with massive setback porch for 3-car parking', 'special_features': ['staircase', 'triple_porch']})
    plans.append({'index': 73, 'id': 'LV-5060-S-5BHK-DT', 'width': 50, 'depth': 60, 'facing': 'S', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with modern stepped-terrace facade', 'special_features': ['staircase', 'stepped_facade']})
    plans.append({'index': 74, 'id': 'LV-5060-S-5BHK-DE', 'width': 50, 'depth': 60, 'facing': 'S', 'bhk': 5, 'type': 'D', 'title': '5BHK Duplex with indoor elevator shaft column matrix', 'special_features': ['staircase', 'elevator']})
    plans.append({'index': 75, 'id': 'LV-5060-S-6BHK-DG', 'width': 50, 'depth': 60, 'facing': 'S', 'bhk': 6, 'type': 'D', 'title': '6BHK Duplex with semi-detached guest house wing', 'special_features': ['staircase', 'guest_wing']})

    # ------------------------------------------
    # Chapter 4: Specialized & Commercial-Mixed (Index 76 to 100)
    # ------------------------------------------
    # Narrow Plots 20x60 (76-85)
    for i in range(10):
        index = 76 + i
        orientations = ['E', 'N', 'W', 'S']
        facing = orientations[i % 4]
        bhk = (i % 3) + 2  # 2BHK to 4BHK
        ptype = 'S' if i < 4 else 'D'
        title = f"Row House Series Plan {i+1} ({bhk}BHK {'Single' if ptype == 'S' else 'Duplex'} linear layout)"
        plans.append({
            'index': index,
            'id': f'NH-2060-{facing}-{bhk}BHK-{"S" if ptype == "S" else "D"}',
            'width': 20,
            'depth': 60,
            'facing': facing,
            'bhk': bhk,
            'type': ptype,
            'title': title,
            'special_features': ['narrow_skywell', 'staircase'] if ptype == 'D' else ['narrow_skywell']
        })
        
    # Mixed & Apartment Frameworks (86-100)
    plans.append({'index': 86, 'id': 'MF-3050-N-2BHK-S', 'width': 30, 'depth': 50, 'facing': 'N', 'bhk': 2, 'type': 'S', 'title': 'The Builder Floor Layout: Independent flat template', 'special_features': ['independent_floor']})
    plans.append({'index': 87, 'id': 'MF-4060-E-3BHK-D', 'width': 40, 'depth': 60, 'facing': 'E', 'bhk': 3, 'type': 'D', 'title': 'The Commercial Ground Floor: Open shop floor layout', 'special_features': ['shops', 'staircase']})
    plans.append({'index': 88, 'id': 'MF-4050-N-4BHK-D', 'width': 40, 'depth': 50, 'facing': 'N', 'bhk': 4, 'type': 'D', 'title': 'The Under-Stilt Parking Layout: Open ground columns', 'special_features': ['under-stilt', 'staircase']})
    plans.append({'index': 89, 'id': 'MF-5050-E-2BHK-S', 'width': 50, 'depth': 50, 'facing': 'E', 'bhk': 2, 'type': 'S', 'title': 'The Clinic-cum-Home Layout: Doctor waiting & cabin', 'special_features': ['clinic']})
    plans.append({'index': 90, 'id': 'MF-4050-N-1BHK-S', 'width': 40, 'depth': 50, 'facing': 'N', 'bhk': 1, 'type': 'S', 'title': 'The Dual-Key Studio Layout: Two independent 1BHK flats', 'special_features': ['dual-key']})
    
    # 91 to 100 variations with varying loads & sizes
    for i in range(10):
        index = 91 + i
        w = 30 + (i % 3) * 10
        d = 40 + (i % 2) * 10
        facing = 'N' if i % 2 == 0 else 'E'
        plans.append({
            'index': index,
            'id': f'MF-{w}{d}-{facing}-3BHK-D',
            'width': w,
            'depth': d,
            'facing': facing,
            'bhk': 3,
            'type': 'D',
            'title': f'Varying Load Plan {i+1}: Column spacing structural variant ({w}x{d} plot)',
            'special_features': ['staircase', 'heavy_columns']
        })
        
    return plans


# ==========================================
# 2. PROCEDURAL LAYOUT PLANNING ENGINE
# ==========================================
def generate_layout(plan):
    """
    Computes grid coordinates, topological room zones, walls, 
    columns, and labels dynamically based on the plan metadata.
    """
    w_ft = plan['width']
    d_ft = plan['depth']
    w = w_ft * 12.0  # width in inches
    d = d_ft * 12.0  # depth in inches
    facing = plan['facing']
    bhk = plan['bhk']
    is_duplex = plan['type'] == 'D'
    features = plan['special_features']
    
    # Determine grid divisions
    if w_ft <= 24:  # Narrow Row House (20x60)
        x_grid = [0.0, w * 0.5, w]
        y_grid = [0.0, d * 0.25, d * 0.50, d * 0.75, d]
        cols, rows = 2, 4
        
        # Base cellular layout
        if bhk == 1:
            grid = [
                ["Lawn", "Porch"],
                ["Living Room", "Living Room"],
                ["Kitchen", "Toilet"],
                ["Bedroom", "O.T.S."]
            ]
        elif bhk == 2:
            grid = [
                ["Lawn", "Porch"],
                ["Living Room", "Living Room"],
                ["Bedroom-1", "Toilet"],
                ["Bedroom-2", "O.T.S."]
            ]
        else:
            grid = [
                ["Lawn", "Porch"],
                ["Living Room", "Staircase"],
                ["Bedroom-1", "Toilet-1"],
                ["Bedroom-2", "Toilet-2"]
            ]
    else:  # Standard Plots (30x40, 40x50, 50x60)
        x_grid = [0.0, w * 0.40, w * 0.60, w]
        y_grid = [0.0, d * 0.35, d * 0.70, d]
        cols, rows = 3, 3
        
        if bhk == 1:
            grid = [
                ["Lawn", "Lawn", "Porch"],
                ["Living Room", "Dining", "Kitchen"],
                ["Master Bed", "Toilet", "O.T.S."]
            ]
        elif bhk == 2:
            grid = [
                ["Lawn", "Lawn", "Porch"],
                ["Living Room", "Dining", "Kitchen"],
                ["Master Bed", "Toilet", "Bedroom-2"]
            ]
        elif bhk == 3:
            grid = [
                ["Lawn", "Lobby", "Porch"],
                ["Living Room", "Staircase", "Kitchen"],
                ["Master Bed", "Toilet", "Bedroom-2"]
            ]
            if not is_duplex:
                grid[1][1] = "Bedroom-3"
        elif bhk == 4:
            if not is_duplex:  # Single floor flat
                x_grid = [0.0, w * 0.30, w * 0.50, w * 0.75, w]
                cols = 4
                grid = [
                    ["Lawn", "Lobby", "Porch", "Bedroom-4"],
                    ["Living Room", "Dining", "Kitchen", "Toilet-2"],
                    ["Master Bed", "Toilet-1", "Bedroom-2", "Bedroom-3"]
                ]
            else:
                grid = [
                    ["Lawn", "Lobby", "Porch"],
                    ["Living Room", "Staircase", "Kitchen"],
                    ["Master Bed", "Toilet", "Bedroom-2"]
                ]
        else:  # 5BHK & 6BHK Duplexes
            grid = [
                ["Lawn", "Lobby", "Porch"],
                ["Living Room", "Staircase", "Kitchen"],
                ["Master Bed", "Toilet", "Bedroom-2"]
            ]
            
    # Apply Facing transformations (Vastu alignments)
    if facing == 'W':
        grid = [row[::-1] for row in grid]
    elif facing == 'S':
        grid = grid[::-1]
    elif facing == 'E':
        grid = [row[::-1] for row in grid]
        
    # Replace cells for special features
    if 'shops' in features:
        grid[0][0] = "Shop-1"
        if len(grid[0]) > 2:
            grid[0][2] = "Shop-2"
    if 'under-stilt' in features:
        grid = [["Stilt Parking" for _ in range(cols)] for _ in range(rows)]
    if 'clinic' in features:
        grid[0][0] = "Consultation"
        grid[0][1] = "Waiting Area"
        if len(grid[0]) > 2:
            grid[0][2] = "Pharmacy"
    if 'dual-key' in features:
        # Split half-half
        for r in range(rows):
            grid[r][0] = f"Flat-A: {grid[r][0]}"
            grid[r][cols-1] = f"Flat-B: {grid[r][cols-1]}"
            
    # Compile layout data
    layout = {
        'x_grid': x_grid,
        'y_grid': y_grid,
        'grid': grid,
        'cols': cols,
        'rows': rows,
        'width': w,
        'depth': d,
        'is_duplex': is_duplex,
        'features': features
    }
    
    return layout


# ==========================================
# 3. AUTOCAD RENDERER & TOPOLOGICAL SOLVER
# ==========================================
class AutoCADPortfolioRenderer:
    """Connects to AutoCAD and procedurally draws the layout."""
    
    # Layer colors
    COLOR_WHITE = 7
    COLOR_RED = 1
    COLOR_YELLOW = 2
    COLOR_GREEN = 3
    COLOR_CYAN = 4
    COLOR_BLUE = 5
    COLOR_MAGENTA = 6
    COLOR_GRAY = 8
    COLOR_DARK_GRAY = 251
    
    def safe_call(self, func, *args):
        """Executes a COM call with automatic retry on callee rejection."""
        import time
        max_retries = 200
        delay = 0.05
        for i in range(max_retries):
            try:
                return func(*args)
            except Exception as e:
                err_msg = str(e)
                if "rejected by callee" in err_msg or "-2147418111" in err_msg:
                    time.sleep(delay)
                    continue
                raise e
        return func(*args)

    def safe_set(self, obj, attr, value):
        """Sets an attribute on a COM object with automatic retry."""
        import time
        max_retries = 200
        delay = 0.05
        for i in range(max_retries):
            try:
                setattr(obj, attr, value)
                return
            except Exception as e:
                err_msg = str(e)
                if "rejected by callee" in err_msg or "-2147418111" in err_msg:
                    time.sleep(delay)
                    continue
                raise e
        setattr(obj, attr, value)

    def __init__(self):
        """Connects to a running AutoCAD instance."""
        try:
            self.acad = Autocad(create_if_not_exists=True)
            self.doc = self.acad.ActiveDocument
            self.model = self.acad.model
            
            # Setup Imperial Units (Inches)
            self.safe_call(self.doc.SetVariable, "INSUNITS", 1)  # 1 = Inches
            self.safe_call(self.doc.SetVariable, "LUNITS", 4)     # 4 = Architectural (Feet & Inches)
            self.safe_call(self.doc.SetVariable, "FILLMODE", 1)   # 1 = Turn on solid fills
            
        except Exception as e:
            print(f"Error connecting to AutoCAD: {e}")
            sys.exit(1)
            
    def create_layers(self):
        """Creates professional standard layers if they do not exist."""
        # Load Center linetype safely
        try:
            self.safe_call(self.doc.SendCommand, "_.linetype _load CENTER acad.lin \n")
        except:
            pass
            
        layers = [
            ("A-WALL-EXT", self.COLOR_WHITE, "Continuous"),
            ("A-WALL-INT", self.COLOR_GRAY, "Continuous"),
            ("A-COLUMN", self.COLOR_RED, "Continuous"),
            ("A-COL-HATCH", self.COLOR_DARK_GRAY, "Continuous"),
            ("A-DOOR", self.COLOR_MAGENTA, "Continuous"),
            ("A-WINDOW", self.COLOR_BLUE, "Continuous"),
            ("A-STAIR", self.COLOR_CYAN, "Continuous"),
            ("A-FIXTURE", self.COLOR_GRAY, "Continuous"),
            ("A-TEXT", self.COLOR_YELLOW, "Continuous"),
            ("A-DIM", self.COLOR_GREEN, "Continuous"),
            ("S-GRID-CENTER", self.COLOR_GRAY, "CENTER"),
            ("S-BUBBLE", self.COLOR_CYAN, "Continuous"),
            ("S-BEAM-FRAMING", self.COLOR_YELLOW, "Continuous"),
            ("S-TABLE", self.COLOR_WHITE, "Continuous"),
            ("S-TEXT", self.COLOR_GREEN, "Continuous")
        ]
        
        for name, color, linetype in layers:
            try:
                lyr = self.safe_call(self.doc.Layers.Add, name)
                self.safe_set(lyr, "Color", color)
                try:
                    self.safe_set(lyr, "Linetype", linetype)
                except:
                    pass  # Fallback to continuous if center is not loaded
            except Exception:
                pass  # Layer already exists
                
    def set_layer(self, name):
        """Sets the active layer."""
        try:
            lyr = self.safe_call(self.doc.Layers.Item, name)
            self.safe_set(self.doc, "ActiveLayer", lyr)
        except:
            pass
            
    def draw_line(self, x1, y1, x2, y2, layer):
        """Draws a simple line."""
        self.set_layer(layer)
        p1 = APoint(x1, y1)
        p2 = APoint(x2, y2)
        return self.safe_call(self.model.AddLine, p1, p2)
        
    def draw_rect(self, x1, y1, x2, y2, layer):
        """Draws a rectangle using 4 lines."""
        self.draw_line(x1, y1, x2, y1, layer)
        self.draw_line(x2, y1, x2, y2, layer)
        self.draw_line(x2, y2, x1, y2, layer)
        self.draw_line(x1, y2, x1, y1, layer)
        
    def draw_solid_col(self, cx, cy, w, h, layer):
        """Draws a solid filled column using AddSolid to prevent hatch issues."""
        self.set_layer(layer)
        hw = w / 2.0
        hh = h / 2.0
        p1 = APoint(cx - hw, cy - hh)
        p2 = APoint(cx + hw, cy - hh)
        p3 = APoint(cx - hw, cy + hh)
        p4 = APoint(cx + hw, cy + hh)
        # AddSolid order of points: P1, P2, P4, P3 (Z-shaped order)
        self.safe_call(self.model.AddSolid, p1, p2, p4, p3)
        # Outline
        self.draw_rect(cx - hw, cy - hh, cx + hw, cy + hh, "A-COLUMN")
        
    def draw_text(self, text, cx, cy, height, layer, align="C"):
        """Draws text centered or left aligned."""
        self.set_layer(layer)
        pt = APoint(cx, cy)
        txt = self.safe_call(self.model.AddText, text, pt, height)
        if align == "C":
            self.safe_set(txt, "Alignment", 4)  # Centered
            self.safe_set(txt, "TextAlignmentPoint", pt)
        return txt
        
    def draw_arc(self, cx, cy, radius, start_deg, end_deg, layer):
        """Draws an arc in AutoCAD (angles in radians)."""
        self.set_layer(layer)
        center = APoint(cx, cy)
        r_start = math.radians(start_deg)
        r_end = math.radians(end_deg)
        return self.safe_call(self.model.AddArc, center, radius, r_start, r_end)

    def draw_door(self, cx, cy, size, wall_dir, swing_dir):
        """Draws a professional door leaf & swing arc."""
        # wall_dir: 'H' (horizontal wall), 'V' (vertical wall)
        # swing_dir: +1 (up/right) or -1 (down/left)
        self.set_layer("A-DOOR")
        
        if wall_dir == 'H':
            # Door hinges on cx - size/2
            h_x = cx - size/2
            h_y = cy
            # Draw leaf
            if swing_dir > 0:
                self.draw_line(h_x, h_y, h_x, h_y + size, "A-DOOR")
                self.draw_arc(h_x, h_y, size, 0, 90, "A-DOOR")
            else:
                self.draw_line(h_x, h_y, h_x, h_y - size, "A-DOOR")
                self.draw_arc(h_x, h_y, size, 270, 360, "A-DOOR")
        else:
            # Vertical wall, hinges on cx, cy - size/2
            h_x = cx
            h_y = cy - size/2
            if swing_dir > 0:
                self.draw_line(h_x, h_y, h_x + size, h_y, "A-DOOR")
                self.draw_arc(h_x, h_y, size, 0, 90, "A-DOOR")
            else:
                self.draw_line(h_x, h_y, h_x - size, h_y, "A-DOOR")
                self.draw_arc(h_x, h_y, size, 90, 180, "A-DOOR")
                
    def draw_window_symbol(self, cx, cy, size, wall_dir, is_ventilator=False):
        """Draws double pane lines for windows or single crosses for vents."""
        layer = "A-WINDOW"
        self.set_layer(layer)
        half = size / 2.0
        
        if wall_dir == 'H':
            # Outer frame
            self.draw_rect(cx - half, cy - 4.5, cx + half, cy + 4.5, layer)
            if not is_ventilator:
                # Double glazing lines
                self.draw_line(cx - half, cy - 1.5, cx + half, cy - 1.5, layer)
                self.draw_line(cx - half, cy + 1.5, cx + half, cy + 1.5, layer)
            else:
                # Ventilator cross
                self.draw_line(cx - half, cy - 4.5, cx + half, cy + 4.5, layer)
                self.draw_line(cx - half, cy + 4.5, cx + half, cy - 4.5, layer)
        else:
            # Vertical
            self.draw_rect(cx - 4.5, cy - half, cx + 4.5, cy + half, layer)
            if not is_ventilator:
                self.draw_line(cx - 1.5, cy - half, cx - 1.5, cy + half, layer)
                self.draw_line(cx + 1.5, cy - half, cx + 1.5, cy + half, layer)
            else:
                self.draw_line(cx - 4.5, cy - half, cx + 4.5, cy + half, layer)
                self.draw_line(cx - 4.5, cy + half, cx + 4.5, cy - half, layer)
                
    def draw_staircase(self, sx, sy, sw, sl):
        """Draws standard stair treads, landing, and UP arrow."""
        layer = "A-STAIR"
        self.set_layer(layer)
        landing_w = 36.0
        tread_d = 10.0
        num_treads = int((sl - landing_w) / tread_d)
        
        # Outer boundary box
        self.draw_rect(sx, sy, sx + sw, sy + sl, layer)
        # landing divider
        self.draw_line(sx, sy + sl - landing_w, sx + sw, sy + sl - landing_w, layer)
        # Flight splitter line
        self.draw_line(sx + sw/2, sy, sx + sw/2, sy + sl - landing_w, layer)
        
        # Treads
        for i in range(1, num_treads):
            y = sy + (i * tread_d)
            self.draw_line(sx, y, sx + sw/2, y, layer)
            self.draw_line(sx + sw/2, y, sx + sw, y, layer)
            
        # Arrow line
        ax = sx + sw/4
        self.draw_line(ax, sy + 6.0, ax, sy + sl - landing_w - 6.0, layer)
        self.draw_circle(ax, sy + 6.0, 2.0, layer)
        # Arrowhead
        ay = sy + sl - landing_w - 6.0
        self.draw_line(ax, ay, ax - 3.0, ay - 6.0, layer)
        self.draw_line(ax, ay, ax + 3.0, ay - 6.0, layer)
        self.draw_text("UP", ax, sy + 24.0, 6.0, "A-TEXT")
        
    def draw_toilet_fittings(self, cx, cy):
        """Draws a toilet WC oval and flush tank."""
        self.set_layer("A-FIXTURE")
        # WC flush tank
        self.draw_rect(cx - 8.0, cy - 12.0, cx + 8.0, cy - 6.0, "A-FIXTURE")
        # Oval closet (represented by double circles)
        self.draw_circle(cx, cy + 2.0, 6.0, "A-FIXTURE")
        self.draw_circle(cx, cy + 2.0, 4.5, "A-FIXTURE")
        
    def draw_sink_symbol(self, cx, cy):
        """Draws a bathroom washbasin or kitchen sink."""
        self.set_layer("A-FIXTURE")
        self.draw_rect(cx - 10.0, cy - 8.0, cx + 10.0, cy + 8.0, "A-FIXTURE")
        self.draw_circle(cx, cy, 5.0, "A-FIXTURE")
        self.draw_circle(cx, cy, 1.5, "A-FIXTURE")
        
    def draw_stove_symbol(self, cx, cy):
        """Draws a kitchen 2-burner stove."""
        self.set_layer("A-FIXTURE")
        self.draw_rect(cx - 14.0, cy - 9.0, cx + 14.0, cy + 9.0, "A-FIXTURE")
        self.draw_circle(cx - 7.0, cy, 3.5, "A-FIXTURE")
        self.draw_circle(cx + 7.0, cy, 3.5, "A-FIXTURE")
        
    def draw_circle(self, cx, cy, r, layer):
        """Draws a basic circle."""
        self.set_layer(layer)
        center = APoint(cx, cy)
        return self.safe_call(self.model.AddCircle, center, r)

    def add_dimension(self, x1, y1, x2, y2, dim_x, dim_y, layer):
        """Adds a linear dimension line."""
        self.set_layer(layer)
        p1 = APoint(x1, y1)
        p2 = APoint(x2, y2)
        p_text = APoint(dim_x, dim_y)
        try:
            self.safe_call(self.model.AddDimLinear, p1, p2, p_text)
        except:
            pass

    # ==========================================
    # 4. PROCEDURAL PLAN DRAFTING IMPLEMENTATION
    # ==========================================
    def draw_plan(self, plan):
        """Executes the full drafting sequence for the given plan."""
        # 1. Clear active model space
        try:
            for obj in self.model:
                self.safe_call(obj.Delete)
        except:
            pass
            
        # 2. Setup layers
        self.create_layers()
        
        # 3. Generate procedural coordinate zones
        w_ft = plan['width']
        d_ft = plan['depth']
        bhk = plan['bhk']
        is_duplex = plan['type'] == 'D'
        layout = generate_layout(plan)
        x_grid = layout['x_grid']
        y_grid = layout['y_grid']
        grid = layout['grid']
        cols = layout['cols']
        rows = layout['rows']
        w = layout['width']
        d = layout['depth']
        features = layout['features']
        
        # 4. Topological Wall & Aperture Solver
        # Generate raw wall segments
        h_walls = []
        v_walls = []
        
        # Horizontal walls (along grid rows)
        for r in range(rows + 1):
            y = y_grid[r]
            for c in range(cols):
                x1, x2 = x_grid[c], x_grid[c+1]
                cell_below = grid[r-1][c] if r > 0 else None
                cell_above = grid[r][c] if r < rows else None
                
                draw = False
                thick = 4.5
                
                open_areas = ["Lawn", "Lawn/Garden", "Open Space", "Parking", "Stilt Parking"]
                
                if cell_below is None:
                    if cell_above not in open_areas:
                        draw, thick = True, 9.0
                elif cell_above is None:
                    if cell_below not in open_areas:
                        draw, thick = True, 9.0
                else:
                    if cell_below != cell_above:
                        if cell_below not in open_areas and cell_above not in open_areas:
                            draw, thick = True, 4.5
                        elif (cell_below in open_areas) != (cell_above in open_areas):
                            draw, thick = True, 9.0
                            
                if draw:
                    h_walls.append({'y': y, 'x1': x1, 'x2': x2, 'thick': thick, 'c': c, 'r': r})
                    
        # Vertical walls (along grid columns)
        for c in range(cols + 1):
            x = x_grid[c]
            for r in range(rows):
                y1, y2 = y_grid[r], y_grid[r+1]
                cell_left = grid[r][c-1] if c > 0 else None
                cell_right = grid[r][c] if c < cols else None
                
                draw = False
                thick = 4.5
                
                open_areas = ["Lawn", "Lawn/Garden", "Open Space", "Parking", "Stilt Parking"]
                
                if cell_left is None:
                    if cell_right not in open_areas:
                        draw, thick = True, 9.0
                elif cell_right is None:
                    if cell_left not in open_areas:
                        draw, thick = True, 9.0
                else:
                    if cell_left != cell_right:
                        if cell_left not in open_areas and cell_right not in open_areas:
                            draw, thick = True, 4.5
                        elif (cell_left in open_areas) != (cell_right in open_areas):
                            draw, thick = True, 9.0
                            
                if draw:
                    v_walls.append({'x': x, 'y1': y1, 'y2': y2, 'thick': thick, 'c': c, 'r': r})

        # 5. Extract distinct rooms via flood fill
        visited = set()
        rooms = []
        open_areas = ["Lawn", "Lawn/Garden", "Open Space", "Parking", "Stilt Parking"]
        
        for r in range(rows):
            for c in range(cols):
                name = grid[r][c]
                if (c, r) not in visited and name not in open_areas:
                    # Flood fill
                    room_cells = []
                    queue = [(c, r)]
                    visited.add((c, r))
                    while queue:
                        curr_c, curr_r = queue.pop(0)
                        room_cells.append((curr_c, curr_r))
                        for dc, dr in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                            nc, nr = curr_c + dc, curr_r + dr
                            if (0 <= nc < cols) and (0 <= nr < rows):
                                if (nc, nr) not in visited and grid[nr][nc] == name:
                                    visited.add((nc, nr))
                                    queue.append((nc, nr))
                    rooms.append({'name': name, 'cells': room_cells})

        # 6. Resolve openings (Doors and Windows) and split wall segments
        apertures = []  # list of openings to place: {'type': 'D'/'W'/'V', 'cx', 'cy', 'size', 'dir': 'H'/'V', 'swing': 1/-1}
        
        for room in rooms:
            room_name = room['name']
            cell_set = set(room['cells'])
            
            # Find bounds
            c_min = min(c for c, r in room['cells'])
            c_max = max(c for c, r in room['cells'])
            r_min = min(r for c, r in room['cells'])
            r_max = max(r for c, r in room['cells'])
            
            room['x1'] = x_grid[c_min]
            room['x2'] = x_grid[c_max + 1]
            room['y1'] = y_grid[r_min]
            room['y2'] = y_grid[r_max + 1]
            
            door_placed = False
            window_placed = False
            
            # Check edges
            for c, r in room['cells']:
                # Left Edge
                if c == 0 or (c-1, r) not in cell_set:
                    other = grid[r][c-1] if c > 0 else None
                    cy = (y_grid[r] + y_grid[r+1]) / 2.0
                    cx = x_grid[c]
                    
                    if other in open_areas or other is None: # Exterior
                        if not window_placed:
                            is_vent = "Toilet" in room_name or "Bath" in room_name or "O.T.S." in room_name
                            apertures.append({'type': 'V' if is_vent else 'W', 'cx': cx, 'cy': cy, 'size': 24.0 if is_vent else 48.0, 'dir': 'V'})
                            window_placed = True
                    else: # Interior
                        if not door_placed and ("Bed" in room_name or "Toilet" in room_name or "Kitchen" in room_name or "Shop" in room_name or "Consultation" in room_name):
                            is_toilet = "Toilet" in room_name or "Bath" in room_name
                            apertures.append({'type': 'D', 'cx': cx, 'cy': cy, 'size': 30.0 if is_toilet else 36.0, 'dir': 'V', 'swing': 1 if r == r_min else -1})
                            door_placed = True
                            
                # Right Edge
                if c == cols-1 or (c+1, r) not in cell_set:
                    other = grid[r][c+1] if c < cols-1 else None
                    cy = (y_grid[r] + y_grid[r+1]) / 2.0
                    cx = x_grid[c+1]
                    
                    if other in open_areas or other is None:
                        if not window_placed:
                            is_vent = "Toilet" in room_name or "Bath" in room_name or "O.T.S." in room_name
                            apertures.append({'type': 'V' if is_vent else 'W', 'cx': cx, 'cy': cy, 'size': 24.0 if is_vent else 48.0, 'dir': 'V'})
                            window_placed = True
                    else:
                        if not door_placed and ("Bed" in room_name or "Toilet" in room_name or "Kitchen" in room_name or "Shop" in room_name or "Consultation" in room_name):
                            is_toilet = "Toilet" in room_name or "Bath" in room_name
                            apertures.append({'type': 'D', 'cx': cx, 'cy': cy, 'size': 30.0 if is_toilet else 36.0, 'dir': 'V', 'swing': -1 if r == r_min else 1})
                            door_placed = True

                # Bottom Edge
                if r == 0 or (c, r-1) not in cell_set:
                    other = grid[r-1][c] if r > 0 else None
                    cx = (x_grid[c] + x_grid[c+1]) / 2.0
                    cy = y_grid[r]
                    
                    if other in open_areas or other is None:
                        if not window_placed:
                            is_vent = "Toilet" in room_name or "Bath" in room_name or "O.T.S." in room_name
                            apertures.append({'type': 'V' if is_vent else 'W', 'cx': cx, 'cy': cy, 'size': 24.0 if is_vent else 48.0, 'dir': 'H'})
                            window_placed = True
                    else:
                        if not door_placed and ("Bed" in room_name or "Toilet" in room_name or "Kitchen" in room_name or "Shop" in room_name or "Consultation" in room_name):
                            is_toilet = "Toilet" in room_name or "Bath" in room_name
                            apertures.append({'type': 'D', 'cx': cx, 'cy': cy, 'size': 30.0 if is_toilet else 36.0, 'dir': 'H', 'swing': 1 if c == c_min else -1})
                            door_placed = True

                # Top Edge
                if r == rows-1 or (c, r+1) not in cell_set:
                    other = grid[r+1][c] if r < rows-1 else None
                    cx = (x_grid[c] + x_grid[c+1]) / 2.0
                    cy = y_grid[r+1]
                    
                    if other in open_areas or other is None:
                        if not window_placed:
                            is_vent = "Toilet" in room_name or "Bath" in room_name or "O.T.S." in room_name
                            apertures.append({'type': 'V' if is_vent else 'W', 'cx': cx, 'cy': cy, 'size': 24.0 if is_vent else 48.0, 'dir': 'H'})
                            window_placed = True
                    else:
                        if not door_placed and ("Bed" in room_name or "Toilet" in room_name or "Kitchen" in room_name or "Shop" in room_name or "Consultation" in room_name):
                            is_toilet = "Toilet" in room_name or "Bath" in room_name
                            apertures.append({'type': 'D', 'cx': cx, 'cy': cy, 'size': 30.0 if is_toilet else 36.0, 'dir': 'H', 'swing': -1 if c == c_min else 1})
                            door_placed = True

        # Split walls around apertures to leave openings
        rendered_walls = []
        
        # Process Horizontal Wall Segments
        for w_seg in h_walls:
            y = w_seg['y']
            x1, x2 = w_seg['x1'], w_seg['x2']
            thick = w_seg['thick']
            
            # Find overlapping apertures
            seg_apertures = []
            for ap in apertures:
                if ap['dir'] == 'H' and abs(ap['cy'] - y) < 1.0 and ap['cx'] > x1 and ap['cx'] < x2:
                    seg_apertures.append(ap)
                    
            if not seg_apertures:
                rendered_walls.append({'type': 'H', 'y': y, 'x1': x1, 'x2': x2, 'thick': thick})
            else:
                # Sort apertures from left to right
                seg_apertures.sort(key=lambda a: a['cx'])
                curr_x = x1
                for ap in seg_apertures:
                    gap_start = ap['cx'] - ap['size']/2.0
                    gap_end = ap['cx'] + ap['size']/2.0
                    if gap_start > curr_x:
                        rendered_walls.append({'type': 'H', 'y': y, 'x1': curr_x, 'x2': gap_start, 'thick': thick})
                    curr_x = gap_end
                if curr_x < x2:
                    rendered_walls.append({'type': 'H', 'y': y, 'x1': curr_x, 'x2': x2, 'thick': thick})
                    
        # Process Vertical Wall Segments
        for w_seg in v_walls:
            x = w_seg['x']
            y1, y2 = w_seg['y1'], w_seg['y2']
            thick = w_seg['thick']
            
            # Find overlapping apertures
            seg_apertures = []
            for ap in apertures:
                if ap['dir'] == 'V' and abs(ap['cx'] - x) < 1.0 and ap['cy'] > y1 and ap['cy'] < y2:
                    seg_apertures.append(ap)
                    
            if not seg_apertures:
                rendered_walls.append({'type': 'V', 'x': x, 'y1': y1, 'y2': y2, 'thick': thick})
            else:
                # Sort from bottom to top
                seg_apertures.sort(key=lambda a: a['cy'])
                curr_y = y1
                for ap in seg_apertures:
                    gap_start = ap['cy'] - ap['size']/2.0
                    gap_end = ap['cy'] + ap['size']/2.0
                    if gap_start > curr_y:
                        rendered_walls.append({'type': 'V', 'x': x, 'y1': curr_y, 'y2': gap_start, 'thick': thick})
                    curr_y = gap_end
                if curr_y < y2:
                    rendered_walls.append({'type': 'V', 'x': x, 'y1': curr_y, 'y2': y2, 'thick': thick})

        # 7. DRAW WALLS
        for wall in rendered_walls:
            layer = "A-WALL-EXT" if wall['thick'] > 6.0 else "A-WALL-INT"
            x1, y1 = (wall['x1'], wall['y']) if wall['type'] == 'H' else (wall['x'], wall['y1'])
            x2, y2 = (wall['x2'], wall['y']) if wall['type'] == 'H' else (wall['x'], wall['y2'])
            
            # Draw double line wall centered around center axis
            thick = wall['thick']
            dx = x2 - x1
            dy = y2 - y1
            length = (dx**2 + dy**2)**0.5
            if length > 0:
                nx = -dy / length * thick / 2.0
                ny = dx / length * thick / 2.0
                self.draw_line(x1 - nx, y1 - ny, x2 - nx, y2 - ny, layer)
                self.draw_line(x1 + nx, y1 + ny, x2 + nx, y2 + ny, layer)

        # 8. DRAW COLUMNS
        # Place structural concrete columns at all main grid intersections
        col_w = 9.0
        col_h = 12.0
        col_idx = 1
        for y in y_grid:
            for x in x_grid:
                # Avoid placing columns inside lawns or stilt areas
                # Map coordinate to grid indices
                c_idx = next(i for i, val in enumerate(x_grid) if abs(val - x) < 1.0)
                r_idx = next(i for i, val in enumerate(y_grid) if abs(val - y) < 1.0)
                
                # Check adjacent cells
                adj_cells = []
                if c_idx > 0 and r_idx > 0: adj_cells.append(grid[r_idx-1][c_idx-1])
                if c_idx < cols and r_idx > 0: adj_cells.append(grid[r_idx-1][c_idx])
                if c_idx > 0 and r_idx < rows: adj_cells.append(grid[r_idx][c_idx-1])
                if c_idx < cols and r_idx < rows: adj_cells.append(grid[r_idx][c_idx])
                
                # If all adjacent cells are Lawn, skip column
                if adj_cells and all(cell in ["Lawn", "Lawn/Garden", "Open Space"] for cell in adj_cells):
                    continue
                    
                self.draw_solid_col(x, y, col_w, col_h, "A-COL-HATCH")
                self.draw_text(f"C{col_idx}", x, y + 10.0, 6.0, "A-TEXT")
                col_idx += 1

        # 9. DRAW APERTURES (Doors & Windows)
        for ap in apertures:
            if ap['type'] == 'D':
                self.draw_door(ap['cx'], ap['cy'], ap['size'], ap['dir'], ap['swing'])
            elif ap['type'] == 'W':
                self.draw_window_symbol(ap['cx'], ap['cy'], ap['size'], ap['dir'], is_ventilator=False)
            elif ap['type'] == 'V':
                self.draw_window_symbol(ap['cx'], ap['cy'], ap['size'], ap['dir'], is_ventilator=True)

        # 10. DRAW STAIRS & UTILITY FIXTURES
        for room in rooms:
            r_name = room['name']
            cx = (room['x1'] + room['x2']) / 2.0
            cy = (room['y1'] + room['y2']) / 2.0
            rw = room['x2'] - room['x1']
            rh = room['y2'] - room['y1']
            
            if "Staircase" in r_name:
                self.draw_staircase(room['x1'] + 6.0, room['y1'] + 6.0, rw - 12.0, rh - 12.0)
            elif "Toilet" in r_name or "Bath" in r_name:
                self.draw_toilet_fittings(cx, cy)
                self.draw_sink_symbol(room['x1'] + 15.0, cy)
            elif "Kitchen" in r_name:
                self.draw_stove_symbol(cx, room['y2'] - 15.0)
                self.draw_sink_symbol(room['x2'] - 15.0, room['y2'] - 15.0)

        # 11. DRAW ROOM LABELS & DIMENSIONS
        for room in rooms:
            cx = (room['x1'] + room['x2']) / 2.0
            cy = (room['y1'] + room['y2']) / 2.0
            w_ft_r = (room['x2'] - room['x1']) / 12.0
            h_ft_r = (room['y2'] - room['y1']) / 12.0
            
            # Format dimension text (e.g. 14'-3" x 11'-0")
            w_ft_int = int(w_ft_r)
            w_in_int = int(round((w_ft_r - w_ft_int) * 12.0))
            h_ft_int = int(h_ft_r)
            h_in_int = int(round((h_ft_r - h_ft_int) * 12.0))
            dim_str = f"{w_ft_int}'-{w_in_int}\" x {h_ft_int}'-{h_in_int}\""
            
            self.draw_text(room['name'].upper(), cx, cy + 6.0, 10.0, "A-TEXT")
            self.draw_text(dim_str, cx, cy - 6.0, 8.0, "A-TEXT")

        # 12. DRAW CENTERLINE GRID
        grid_ext = 48.0  # 4 feet extension
        
        # Draw vertical grid centerlines
        x_labels = ["A", "B", "C", "D", "E", "F"]
        for idx, x in enumerate(x_grid):
            self.draw_line(x, -grid_ext, x, d + grid_ext, "S-GRID-CENTER")
            # Bubbles
            self.draw_circle(x, -grid_ext - 12.0, 12.0, "S-BUBBLE")
            self.draw_text(x_labels[idx % len(x_labels)], x, -grid_ext - 16.0, 10.0, "S-TEXT")
            self.draw_circle(x, d + grid_ext + 12.0, 12.0, "S-BUBBLE")
            self.draw_text(x_labels[idx % len(x_labels)], x, d + grid_ext + 8.0, 10.0, "S-TEXT")
            
        # Draw horizontal grid centerlines
        y_labels = ["1", "2", "3", "4", "5", "6"]
        for idx, y in enumerate(y_grid):
            self.draw_line(-grid_ext, y, w + grid_ext, y, "S-GRID-CENTER")
            # Bubbles
            self.draw_circle(-grid_ext - 12.0, y, 12.0, "S-BUBBLE")
            self.draw_text(y_labels[idx % len(y_labels)], -grid_ext - 16.0, y - 4.0, 10.0, "S-TEXT")
            self.draw_circle(w + grid_ext + 12.0, y, 12.0, "S-BUBBLE")
            self.draw_text(y_labels[idx % len(y_labels)], w + grid_ext + 8.0, y - 4.0, 10.0, "S-TEXT")

        # 13. DRAW BEAM FRAMING LINES
        for idx in range(len(x_grid)):
            self.draw_line(x_grid[idx], y_grid[0], x_grid[idx], y_grid[-1], "S-BEAM-FRAMING")
        for idx in range(len(y_grid)):
            self.draw_line(x_grid[0], y_grid[idx], x_grid[-1], y_grid[idx], "S-BEAM-FRAMING")

        # 14. DRAW DIMENSIONS
        # Linear dimensions along the bottom grid spacing
        for i in range(len(x_grid) - 1):
            cx = (x_grid[i] + x_grid[i+1]) / 2.0
            self.add_dimension(x_grid[i], y_grid[0], x_grid[i+1], y_grid[0], cx, -grid_ext - 36.0, "A-DIM")
            
        # Overall width dimension
        self.add_dimension(x_grid[0], y_grid[0], x_grid[-1], y_grid[0], w/2.0, -grid_ext - 60.0, "A-DIM")
        
        # Linear dimensions along left side grid spacing
        for j in range(len(y_grid) - 1):
            cy = (y_grid[j] + y_grid[j+1]) / 2.0
            self.add_dimension(x_grid[0], y_grid[j], x_grid[0], y_grid[j+1], -grid_ext - 36.0, cy, "A-DIM")
            
        # Overall depth dimension
        self.add_dimension(x_grid[0], y_grid[0], x_grid[0], y_grid[-1], -grid_ext - 60.0, d/2.0, "A-DIM")

        # 15. DRAW SCHEDULE TABLE & SITE NOTES
        # Table position to the right of the plan
        tx = w + 100.0
        ty = d / 2.0 - 150.0
        th = 30.0
        
        # Header row
        self.draw_rect(tx, ty + th*6, tx + 380.0, ty + th*7, "S-TABLE")
        self.draw_text("RCC COLUMN & FOOTING REINFORCEMENT", tx + 190.0, ty + th*6 + 8.0, 11.0, "S-TEXT")
        
        # Column Labels
        labels = ["MARK", "SIZE", "REBARS", "TIES (LINKS)", "FOOTINGS"]
        widths = [60.0, 60.0, 120.0, 70.0, 70.0]
        curr_tx = tx
        for width, label in zip(widths, labels):
            self.draw_rect(curr_tx, ty + th*5, curr_tx + width, ty + th*6, "S-TABLE")
            self.draw_text(label, curr_tx + width/2.0, ty + th*5 + 8.0, 8.0, "S-TEXT")
            curr_tx += width
            
        # C1 to C4 data
        rows_data = [
            ["C1-C4", "9\"x12\"", "4 Nos #16 + 2 Nos #12", "#8 @ 150 c/c", "4'6\"x4'6\" (#12)"],
            ["C5-C12", "9\"x12\"", "4 Nos #16", "#8 @ 150 c/c", "4'0\"x4'0\" (#12)"],
            ["C13-C17", "9\"x9\"", "4 Nos #12", "#8 @ 200 c/c", "3'6\"x3'6\" (#10)"]
        ]
        for row_idx, r_data in enumerate(rows_data):
            curr_tx = tx
            y_pos = ty + th * (4 - row_idx)
            for width, val in zip(widths, r_data):
                self.draw_rect(curr_tx, y_pos, curr_tx + width, y_pos + th, "S-TABLE")
                self.draw_text(val, curr_tx + width/2.0, y_pos + 8.0, 8.0, "S-TEXT")
                curr_tx += width
                
        # Specs footer row
        concrete_mix = "M25 Grade" if w_ft >= 40 else "M20 Grade"
        self.draw_rect(tx, ty, tx + 190.0, ty + th*2, "S-TABLE")
        self.draw_text(f"CONCRETE: {concrete_mix}\nSTEEL: Fe 500 TMT", tx + 95.0, ty + 20.0, 8.0, "S-TEXT")
        self.draw_rect(tx + 190.0, ty, tx + 380.0, ty + th*2, "S-TABLE")
        self.draw_text("COVERS:\nFooting: 50mm | Column: 40mm", tx + 285.0, ty + 20.0, 8.0, "S-TEXT")

        # 16. DRAW TITLE BLOCK
        bx = tx
        by = ty + th*8
        self.draw_rect(bx, by, bx + 380.0, by + 180.0, "A-WALL-EXT")
        self.draw_line(bx, by + 120.0, bx + 380.0, by + 120.0, "A-WALL-EXT")
        self.draw_line(bx, by + 60.0, bx + 380.0, by + 60.0, "A-WALL-EXT")
        self.draw_line(bx + 190.0, by, bx + 190.0, by + 120.0, "A-WALL-EXT")
        
        self.draw_text(f"PLAN ID: {plan['id']}", bx + 190.0, by + 140.0, 14.0, "A-TEXT")
        self.draw_text(f"PLOT SIZE: {w_ft}' x {d_ft}'", bx + 95.0, by + 80.0, 10.0, "A-TEXT")
        self.draw_text(f"FACING: {plan['facing']}-FACING", bx + 285.0, by + 80.0, 10.0, "A-TEXT")
        self.draw_text(f"BHK: {bhk}BHK | {'DUPLEX' if is_duplex else 'SINGLE'}", bx + 95.0, by + 25.0, 9.0, "A-TEXT")
        self.draw_text(f"DATE: {datetime.now().strftime('%d/%m/%Y')}", bx + 285.0, by + 25.0, 9.0, "A-TEXT")
        
        # General Title Block at Top
        self.draw_text(f"PLAN {plan['index']}: {plan['title'].upper()}", w/2.0, d + grid_ext + 40.0, 18.0, "A-TEXT")

        # 17. Zoom Extents
        self.zoom_extents()

    def zoom_extents(self):
        """Zoom to fit everything in screen."""
        try:
            self.safe_call(self.doc.SendCommand, "_ZOOM _E\n")
        except:
            pass

    def save_drawing(self, filepath):
        """Saves the current drawing to the specified file path."""
        try:
            self.safe_call(self.doc.SaveAs, filepath)
            print(f"[Saved] DWG to: {filepath}")
        except Exception as e:
            print(f"Error saving DWG: {e}")


# ==========================================
# 5. CLI & BATCH PROCESSING CONTROLLER
# ==========================================
def main():
    parser = argparse.ArgumentParser(description="Procedural AutoCAD Floor Plan Portfolio Generator")
    parser.add_argument("--list", action="store_true", help="List all 100 plan configurations")
    parser.add_argument("--plan", type=str, help="Generate a specific plan by its Plan ID (e.g. CP-3040-E-1BHK-S)")
    parser.add_argument("--range", type=str, help="Generate a range of plans by indices (e.g. 1-10)")
    parser.add_argument("--all", action="store_true", help="Generate the entire 100 floor plan portfolio")
    parser.add_argument("--force", action="store_true", help="Bypass confirmation prompts")
    args = parser.parse_args()
    
    plans = get_plan_database()
    
    # 1. List Plans
    if args.list:
        print("\n=== 100 FLOORS PLANS DATABASE ===")
        for p in plans:
            print(f"{p['index']:3d}. ID: {p['id']:20s} | {p['width']}x{p['depth']} | {p['facing']}-Facing | {p['bhk']}BHK | {p['type']} | {p['title']}")
        print("================================")
        return
        
    # Setup directories
    portfolio_dir = Path(__file__).parent / "portfolio"
    os.makedirs(portfolio_dir, exist_ok=True)
    
    # Connect renderer
    renderer = AutoCADPortfolioRenderer()
    
    # 2. Generate Specific Plan
    if args.plan:
        plan_id = args.plan.upper().strip()
        matched = [p for p in plans if p['id'].upper() == plan_id or str(p['index']) == plan_id]
        if not matched:
            print(f"Error: Plan ID or Index '{plan_id}' not found in database. Run with --list to see all IDs.")
            return
            
        p = matched[0]
        print(f"\nGenerating Plan {p['index']}: {p['id']} - {p['title']}...")
        renderer.draw_plan(p)
        filepath = os.path.join(portfolio_dir, f"{p['id']}.dwg")
        renderer.save_drawing(filepath)
        print("[Success] Completed!\n")
        return
        
    # 3. Generate Range of Plans
    if args.range:
        try:
            start, end = map(int, args.range.split('-'))
        except:
            print("Error: Range must be formatted as START-END, e.g. 1-10")
            return
            
        to_generate = [p for p in plans if start <= p['index'] <= end]
        if not to_generate:
            print("Error: No plans found in specified range.")
            return
            
        print(f"\nStarting batch generation for plans {start} to {end} ({len(to_generate)} plans)...")
        for p in to_generate:
            print(f"\n[{p['index']}/{end}] Generating {p['id']} - {p['title']}...")
            renderer.draw_plan(p)
            filepath = os.path.join(portfolio_dir, f"{p['id']}.dwg")
            renderer.save_drawing(filepath)
            
        print("\n[Success] Batch generation range completed successfully!\n")
        return
        
    # 4. Generate All Plans
    if args.all:
        if not args.force:
            print("\nWARNING: Generating all 100 plans will open and save AutoCAD documents 100 times.")
            print("This can take 10-20 minutes and consume significant system resources.")
            confirm = input("Are you sure you want to proceed? (y/n): ")
            if confirm.lower().strip() != 'y':
                print("Cancelled.")
                return
            
        print("\nStarting full portfolio generation (100 plans)...")
        for p in plans:
            print(f"\n[{p['index']}/100] Generating {p['id']} - {p['title']}...")
            renderer.draw_plan(p)
            filepath = os.path.join(portfolio_dir, f"{p['id']}.dwg")
            renderer.save_drawing(filepath)
            
        print("\n[Success] Full portfolio compiled successfully inside /portfolio/ directory!\n")
        return

    # Default: Show help
    parser.print_help()


if __name__ == "__main__":
    main()
