# AutoCAD Python Automation

Automate AutoCAD drawings and operations using Python with **pyautocad**.

## Prerequisites

- **Python 3.8+** installed on your system
- **AutoCAD** installed and running (2018 or later recommended)
- Windows OS (COM-based automation)
- Administrator privileges recommended

## Installation

### 1. Install Python Dependencies

```bash
pip install -r requirements.txt
```

If using a virtual environment:
```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Start AutoCAD

Open AutoCAD and create a new drawing before running any scripts.

## Quick Start

### Basic Example - Create Shapes

```bash
python examples/basic_drawing.py
```

Creates squares, circles, rectangles, and text in your active AutoCAD drawing.

### Professional Floor Plan (20×40 ft)

```bash
python examples/floor_plan_20x40.py
```

**Features:**
- 20 ft × 40 ft residential floor plan
- 7 rooms with proper dimensions
- Color-coded layers (walls, partitions, doors, windows)
- Door swing arcs and window symbols
- Dimension lines and room labels
- Professional title block with date
- Automatic zoom to extents

**Output:**
- Professional CAD file saved as `floor_plan.dwg`
- Ready for further editing in AutoCAD

### RCC Structural Drawing

```bash
python examples/rcc_structural_drawing.py
```

**Features:**
- Complete RCC (Reinforced Cement Concrete) structural frame
- Single bay, single story with columns, beam, and footing
- **Detailed Views:**
  - Elevation: Full frame with stirrup spacing shown
  - Column Cross-Section A-A: 300×300mm with 8 reinforcement bars
  - Beam Cross-Section B-B: 300×450mm with tension/compression bars
  - Footing Plan: 1200×1200mm with reinforcement mesh (150mm spacing)
  
- **Reinforcement Details:**
  - Column: 8 × 16mm dia bars + 8mm stirrups
  - Beam: 3 × 20mm (tension) + 2 × 16mm (compression) bars
  - Footing: 12mm mesh @ 150mm c/c + column starters
  
- **Professional Elements:**
  - Color-coded layers (concrete, reinforcement, dimensions, text)
  - Complete Bar Bending Schedule with calculations
  - Title block with drawing number, scale, date
  - IS Code references (IS 456:2000, IS 13920:2016)
  - Lap splice and development length notations

**Specifications:**
- Column height: 3000 mm (10 feet)
- Beam span: 6000 mm (20 feet)
- Column size: 300×300 mm
- Beam size: 300×450 mm
- Footing: 1200×1200 × 600 mm
- Clear cover: 40 mm
- Scale: 1:50

**Output:**
- Professional structural CAD file: `rcc_structural_drawing.dwg`
- Ready for submission to consultants/contractors
- Meets Indian Standards (IS 456:2000, IS 13920:2016)

### Batch Processing - Multiple Drawings

```bash
python examples/batch_processing.py
```

Process all `.dwg` files in a directory automatically.

## Example Scripts

| Script | Description |
|--------|-------------|
| `basic_drawing.py` | Create basic shapes (lines, circles, rectangles, text) |
| `floor_plan_20x40.py` | **Professional 20×40 ft residential floor plan** |
| `rcc_structural_drawing.py` | **Professional RCC structural frame drawing with reinforcement details** |
| `batch_processing.py` | Process multiple DWG files in batch |

## Using the AutoCADApp Class

```python
from src.autocad_app import AutoCADApp

# Connect to AutoCAD
app = AutoCADApp()

# Draw shapes
app.add_line(0, 0, 100, 100)
app.add_circle(50, 50, 25)
app.add_rectangle(10, 10, 90, 90)
app.add_text("My Label", 50, 50, 2.5)

# Manage drawings
app.save_drawing(r"C:\path\to\drawing.dwg")
app.open_drawing(r"C:\path\to\drawing.dwg")
app.zoom_all()
```

## Key pyautocad Features

- **Connect to AutoCAD**: Establish COM connection to running instance
- **Access Drawing Objects**: Lines, circles, polylines, arcs, text
- **Layer Management**: Create and organize layers with colors
- **Manipulate Geometry**: Create, modify, delete drawing elements
- **Batch Processing**: Script multiple operations on drawings
- **Dimensions & Annotations**: Add dimensions, text, and labels

## Technical Details

### Floor Plan 20×40 (floor_plan_20x40.py)

**Dimensions:**
- Site: 20 feet wide × 40 feet deep
- Units: 1 unit = 1 foot
- Scale: 1:50 for annotations

**Rooms:**
1. Entrance/Lobby (5×8 ft) - front center
2. Living Room (12×14 ft) - front left
3. Kitchen (10×10 ft) - front right
4. Master Bedroom (12×12 ft) - rear left
5. Bedroom 2 (10×10 ft) - rear right
6. Bathroom/WC (5×6 ft) - center rear
7. Corridor (4 ft wide) - middle passage

**Wall Specifications:**
- Outer walls: 9 inches thick (0.75 ft) - RED layer
- Partitions: 4.5 inches thick (0.375 ft) - CYAN layer
- Doors: 3 ft wide with swing arcs - GREEN layer
- Windows: 4 ft wide, double lines - BLUE layer
- Dimensions: Exterior and room dimensions - YELLOW layer
- Labels: Room names and title block - WHITE layer

## Troubleshooting

| Error | Solution |
|-------|----------|
| `"pyautocad.com_error"` | Ensure AutoCAD is running with an open drawing |
| `"Access Denied"` | Run Python with administrator privileges |
| `"Module not found"` | Install dependencies: `pip install -r requirements.txt` |
| `"Failed to get Document"` | Open a drawing in AutoCAD before running scripts |
| Zoom command fails | This is non-critical; drawing is still created |

## AutoCAD Requirements

- **AutoCAD 2018 or later** (tested on 2019+)
- **COM enabled** (default in most installations)
- **Running and visible** before executing Python scripts

## Resources

- [pyautocad Documentation](https://pypi.org/project/pyautocad/)
- [AutoCAD COM Reference](https://help.autodesk.com/view/ACD/2024/ENU/)
- [Python Documentation](https://docs.python.org/3/)

## License

Use according to your AutoCAD and Python licensing terms.
