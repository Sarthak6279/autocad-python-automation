"""
RCC (Reinforced Cement Concrete) Structural Drawing Generator

Professional structural drawing for RCC column & beam frame.
- Single bay, single story frame
- Column: 300×300 mm, Height: 3000 mm
- Beam: 300×450 mm, Span: 6000 mm
- Footing: 1200×1200 mm, Depth: 600 mm
- Complete with reinforcement details and BBS table

Author: Structural Engineer
Date: 2026
"""

import sys
from datetime import datetime
from pathlib import Path
import math

sys.path.insert(0, str(Path(__file__).parent.parent))

try:
    from pyautocad import Autocad, APoint
except ImportError:
    print("Error: pyautocad not installed. Install with: pip install pyautocad")
    sys.exit(1)


class RCCStructuralDrawing:
    """Professional RCC structural drawing class."""
    
    # Color constants
    COLOR_GRAY = 8
    COLOR_RED = 1
    COLOR_GREEN = 3
    COLOR_YELLOW = 2
    COLOR_CYAN = 4
    COLOR_WHITE = 7
    COLOR_LTGRAY = 9
    
    # Layer names
    LAYER_CONCRETE = "CONCRETE"
    LAYER_MAIN_BARS = "MAIN_BARS"
    LAYER_STIRRUPS = "STIRRUPS"
    LAYER_DIMENSIONS = "DIMENSIONS"
    LAYER_HATCH = "HATCH"
    LAYER_TEXT = "TEXT"
    LAYER_CENTERLINE = "CENTERLINE"
    LAYER_GRID = "GRID"
    
    # Dimensions in mm
    COL_SIZE = 300  # 300×300 mm
    BEAM_WIDTH = 300  # mm
    BEAM_DEPTH = 450  # mm
    COL_HEIGHT = 3000  # 3000 mm (10 feet)
    BEAM_SPAN = 6000  # 6000 mm (20 feet)
    FOOTING_SIZE = 1200  # 1200×1200 mm
    FOOTING_DEPTH = 600  # mm
    COVER = 40  # mm
    
    def __init__(self):
        """Initialize connection to AutoCAD."""
        try:
            self.acad = Autocad(create_if_not_exists=True)
            self.doc = self.acad.ActiveDocument
            self.model = self.acad.model
            print("✓ Connected to AutoCAD")
            
            # Set units to millimeters
            self.doc.SetVariable("INSUNITS", 4)  # Millimeters
            
        except Exception as e:
            print(f"✗ Failed to connect to AutoCAD: {e}")
            sys.exit(1)
    
    def create_layer(self, name: str, color: int, linetype: str = "Continuous") -> None:
        """Create a layer if it doesn't exist."""
        try:
            layers = self.doc.Layers
            layer = layers.Item(name)
        except:
            layer = layers.Add(name)
            layer.Color = color
            print(f"  ✓ Created layer '{name}'")
    
    def set_layer(self, layer_name: str) -> None:
        """Set current layer."""
        self.doc.ActiveLayer = self.doc.Layers.Item(layer_name)
    
    def draw_rect(self, x: float, y: float, w: float, h: float, layer: str) -> list:
        """Draw a rectangle."""
        self.set_layer(layer)
        lines = []
        
        # Bottom
        line = self.model.AddLine(APoint(x, y), APoint(x + w, y))
        lines.append(line)
        
        # Right
        line = self.model.AddLine(APoint(x + w, y), APoint(x + w, y + h))
        lines.append(line)
        
        # Top
        line = self.model.AddLine(APoint(x + w, y + h), APoint(x, y + h))
        lines.append(line)
        
        # Left
        line = self.model.AddLine(APoint(x, y + h), APoint(x, y))
        lines.append(line)
        
        return lines
    
    def draw_circle(self, cx: float, cy: float, radius: float, layer: str, filled: bool = True) -> None:
        """Draw a circle (for rebar representation)."""
        self.set_layer(layer)
        center = APoint(cx, cy)
        circle = self.model.AddCircle(center, radius)
        circle.Color = self.COLOR_RED if layer == self.LAYER_MAIN_BARS else self.COLOR_GREEN
    
    def draw_line(self, x1: float, y1: float, x2: float, y2: float, layer: str) -> None:
        """Draw a line."""
        self.set_layer(layer)
        line = self.model.AddLine(APoint(x1, y1), APoint(x2, y2))
        return line
    
    def add_text(self, x: float, y: float, text: str, height: float, layer: str) -> None:
        """Add text label."""
        self.set_layer(layer)
        point = APoint(x, y)
        txt = self.model.AddText(text, point, height)
        txt.Color = self.COLOR_WHITE
    
    def draw_elevation(self, x_start: float, y_start: float) -> None:
        """Draw elevation view of frame."""
        print("✓ Drawing elevation view...")
        
        self.set_layer(self.LAYER_CONCRETE)
        
        # Foundation/Footing
        footing_y = y_start
        footing_x = x_start + (self.BEAM_SPAN - self.FOOTING_SIZE) / 2
        self.draw_rect(footing_x, footing_y, self.FOOTING_SIZE, self.FOOTING_DEPTH, self.LAYER_CONCRETE)
        
        # Ground Line
        gl_y = footing_y + self.FOOTING_DEPTH
        self.draw_line(x_start, gl_y, x_start + self.BEAM_SPAN, gl_y, self.LAYER_CENTERLINE)
        self.add_text(x_start - 500, gl_y + 200, "GL", 200, self.LAYER_TEXT)
        
        # Left Column
        col_x_left = footing_x + (self.FOOTING_SIZE - self.COL_SIZE) / 2
        col_y = gl_y
        self.draw_rect(col_x_left, col_y, self.COL_SIZE, self.COL_HEIGHT, self.LAYER_CONCRETE)
        
        # Add stirrups visualization on left column
        for i in range(1, 15):  # Multiple stirrup levels
            stir_y = col_y + (i * 200)
            self.draw_line(col_x_left, stir_y, col_x_left + self.COL_SIZE, stir_y, self.LAYER_STIRRUPS)
        
        # Right Column
        col_x_right = x_start + self.BEAM_SPAN - footing_x - self.FOOTING_SIZE + (self.FOOTING_SIZE - self.COL_SIZE) / 2
        self.draw_rect(col_x_right, col_y, self.COL_SIZE, self.COL_HEIGHT, self.LAYER_CONCRETE)
        
        # Add stirrups on right column
        for i in range(1, 15):
            stir_y = col_y + (i * 200)
            self.draw_line(col_x_right, stir_y, col_x_right + self.COL_SIZE, stir_y, self.LAYER_STIRRUPS)
        
        # Beam
        beam_y = col_y + self.COL_HEIGHT
        beam_x = col_x_left
        self.draw_rect(beam_x, beam_y, self.BEAM_SPAN, self.BEAM_DEPTH, self.LAYER_CONCRETE)
        
        # Add stirrups on beam (vertical)
        for i in range(1, 30):
            stir_x = beam_x + (i * 200)
            if stir_x < beam_x + self.BEAM_SPAN:
                self.draw_line(stir_x, beam_y, stir_x, beam_y + self.BEAM_DEPTH, self.LAYER_STIRRUPS)
        
        # Slab on top
        slab_y = beam_y + self.BEAM_DEPTH
        slab_thickness = 125
        self.draw_rect(beam_x, slab_y, self.BEAM_SPAN, slab_thickness, self.LAYER_CONCRETE)
        
        # Add dimension lines
        print("✓ Adding elevation dimensions...")
        self.add_text(col_x_left - 300, col_y + self.COL_HEIGHT / 2, "3000\n(10')", 150, self.LAYER_TEXT)
        self.add_text(beam_x + self.BEAM_SPAN / 2, beam_y - 300, "6000 (20')", 150, self.LAYER_TEXT)
        self.add_text(col_x_left - 300, col_y + self.FOOTING_DEPTH / 2, "600", 120, self.LAYER_TEXT)
    
    def draw_column_section(self, x_start: float, y_start: float) -> None:
        """Draw column cross-section."""
        print("✓ Drawing column cross-section...")
        
        # Title
        self.add_text(x_start, y_start + 600, "COLUMN SECTION A-A", 250, self.LAYER_TEXT)
        
        # Main column section
        section_y = y_start
        section_x = x_start
        self.draw_rect(section_x, section_y, self.COL_SIZE, self.COL_SIZE, self.LAYER_CONCRETE)
        
        # Cover line (inner rectangle)
        cover_x = section_x + self.COVER
        cover_y = section_y + self.COVER
        cover_w = self.COL_SIZE - 2 * self.COVER
        cover_h = self.COL_SIZE - 2 * self.COVER
        self.draw_rect(cover_x, cover_y, cover_w, cover_h, self.LAYER_CONCRETE)
        
        # Main reinforcement bars (8 bars - corners + mid-sides)
        bar_positions = [
            (section_x + 40, section_y + 40),      # Bottom-left corner
            (section_x + self.COL_SIZE - 40, section_y + 40),  # Bottom-right
            (section_x + self.COL_SIZE - 40, section_y + self.COL_SIZE - 40),  # Top-right
            (section_x + 40, section_y + self.COL_SIZE - 40),  # Top-left
            (section_x + self.COL_SIZE / 2, section_y + 40),   # Bottom-center
            (section_x + self.COL_SIZE / 2, section_y + self.COL_SIZE - 40),  # Top-center
            (section_x + 40, section_y + self.COL_SIZE / 2),   # Left-center
            (section_x + self.COL_SIZE - 40, section_y + self.COL_SIZE / 2),  # Right-center
        ]
        
        for x, y in bar_positions:
            self.draw_circle(x, y, 8, self.LAYER_MAIN_BARS)
        
        # Dimensions
        self.add_text(section_x - 100, section_y - 100, "300", 120, self.LAYER_DIMENSIONS)
        self.add_text(section_x + self.COL_SIZE / 2 - 50, section_y - 100, "300", 120, self.LAYER_DIMENSIONS)
        self.add_text(section_x - 200, section_y + self.COL_SIZE / 2 - 50, "40", 100, self.LAYER_DIMENSIONS)
        
        # Stirrup indication
        self.draw_rect(section_x + self.COVER + 10, section_y + self.COVER + 10, 
                      cover_w - 20, cover_h - 20, self.LAYER_STIRRUPS)
    
    def draw_beam_section(self, x_start: float, y_start: float) -> None:
        """Draw beam cross-section at mid-span."""
        print("✓ Drawing beam cross-section...")
        
        # Title
        self.add_text(x_start, y_start + 700, "BEAM SECTION B-B", 250, self.LAYER_TEXT)
        
        # Main beam section
        section_y = y_start
        section_x = x_start
        self.draw_rect(section_x, section_y, self.BEAM_WIDTH, self.BEAM_DEPTH, self.LAYER_CONCRETE)
        
        # Cover rectangle
        cover_x = section_x + self.COVER
        cover_y = section_y + self.COVER
        cover_w = self.BEAM_WIDTH - 2 * self.COVER
        cover_h = self.BEAM_DEPTH - 2 * self.COVER
        self.draw_rect(cover_x, cover_y, cover_w, cover_h, self.LAYER_CONCRETE)
        
        # Bottom reinforcement (3 bars of 20mm dia)
        bottom_bar_y = section_y + self.COVER + 15
        bar_spacing = (self.BEAM_WIDTH - 2 * self.COVER) / 4
        for i in range(3):
            bar_x = section_x + self.COVER + bar_spacing * (i + 1)
            self.draw_circle(bar_x, bottom_bar_y, 10, self.LAYER_MAIN_BARS)
        
        # Top reinforcement (2 bars of 16mm dia)
        top_bar_y = section_y + self.BEAM_DEPTH - self.COVER - 15
        for i in range(2):
            bar_x = section_x + self.COVER + bar_spacing * (i + 1.5)
            self.draw_circle(bar_x, top_bar_y, 8, self.LAYER_MAIN_BARS)
        
        # Stirrups
        self.draw_rect(section_x + self.COVER + 5, section_y + self.COVER + 5,
                      cover_w - 10, cover_h - 10, self.LAYER_STIRRUPS)
        
        # Dimensions
        self.add_text(section_x - 100, section_y - 100, "300", 120, self.LAYER_DIMENSIONS)
        self.add_text(section_x + self.BEAM_WIDTH / 2 - 50, section_y - 100, "300", 120, self.LAYER_DIMENSIONS)
        self.add_text(section_x - 200, section_y + self.BEAM_DEPTH / 2 - 50, "450", 120, self.LAYER_DIMENSIONS)
    
    def draw_footing_plan(self, x_start: float, y_start: float) -> None:
        """Draw footing plan view."""
        print("✓ Drawing footing plan...")
        
        # Title
        self.add_text(x_start, y_start + 1300, "FOOTING PLAN", 250, self.LAYER_TEXT)
        
        # Footing outline
        footing_x = x_start
        footing_y = y_start
        self.draw_rect(footing_x, footing_y, self.FOOTING_SIZE, self.FOOTING_SIZE, self.LAYER_CONCRETE)
        
        # Column outline at center
        col_offset = (self.FOOTING_SIZE - self.COL_SIZE) / 2
        self.draw_rect(footing_x + col_offset, footing_y + col_offset, 
                      self.COL_SIZE, self.COL_SIZE, self.LAYER_CONCRETE)
        
        # Reinforcement mesh (grid lines @ 150mm spacing)
        for i in range(0, int(self.FOOTING_SIZE), 150):
            # Horizontal lines
            self.draw_line(footing_x, footing_y + i, footing_x + self.FOOTING_SIZE, footing_y + i, self.LAYER_STIRRUPS)
            # Vertical lines
            self.draw_line(footing_x + i, footing_y, footing_x + i, footing_y + self.FOOTING_SIZE, self.LAYER_STIRRUPS)
        
        # Center point
        cx = footing_x + self.FOOTING_SIZE / 2
        cy = footing_y + self.FOOTING_SIZE / 2
        self.draw_line(cx - 100, cy, cx + 100, cy, self.LAYER_CENTERLINE)
        self.draw_line(cx, cy - 100, cx, cy + 100, self.LAYER_CENTERLINE)
        
        # Dimensions
        self.add_text(footing_x - 200, footing_y - 150, "1200", 120, self.LAYER_DIMENSIONS)
        self.add_text(footing_x + self.FOOTING_SIZE / 2 - 100, footing_y - 150, "1200", 120, self.LAYER_DIMENSIONS)
    
    def draw_bbs_table(self, x_start: float, y_start: float) -> None:
        """Draw Bar Bending Schedule table."""
        print("✓ Creating Bar Bending Schedule...")
        
        # Title
        self.add_text(x_start, y_start + 600, "BAR BENDING SCHEDULE", 250, self.LAYER_TEXT)
        
        # Table data
        bbs_data = [
            ["Bar", "Dia", "Shape", "No.", "Length", "Total", "Weight (kg)"],
            ["T1", "20", "─────", "3", "6100", "18300", "17.2"],
            ["T2", "16", "─────", "2", "6100", "12200", "9.6"],
            ["L1", "16", "┐", "8", "3200", "25600", "20.2"],
            ["ST1", "8", "□", "40", "600", "24000", "12.0"],
            ["ST2", "8", "─", "30", "300", "9000", "4.5"],
            ["FM", "12", "─", "60", "1200", "72000", "53.6"],
        ]
        
        # Draw table
        col_widths = [150, 120, 150, 120, 150, 150, 180]
        row_height = 150
        
        # Table border
        total_width = sum(col_widths)
        self.draw_rect(x_start, y_start, total_width, len(bbs_data) * row_height, self.LAYER_CONCRETE)
        
        # Column dividers
        x_pos = x_start
        for width in col_widths[:-1]:
            x_pos += width
            self.draw_line(x_pos, y_start, x_pos, y_start + len(bbs_data) * row_height, self.LAYER_CONCRETE)
        
        # Row dividers
        for i in range(len(bbs_data) + 1):
            y_pos = y_start + i * row_height
            self.draw_line(x_start, y_pos, x_start + total_width, y_pos, self.LAYER_CONCRETE)
        
        # Fill table data
        for row_idx, row_data in enumerate(bbs_data):
            x_pos = x_start
            for col_idx, (col_width, cell_data) in enumerate(zip(col_widths, row_data)):
                text_x = x_pos + col_width / 2 - 50
                text_y = y_start + (len(bbs_data) - row_idx - 1) * row_height + row_height / 2 - 30
                
                # Bold header
                height = 120 if row_idx == 0 else 100
                self.add_text(text_x, text_y, str(cell_data), height, self.LAYER_TEXT)
                x_pos += col_width
    
    def draw_title_block(self, x_start: float, y_start: float) -> None:
        """Draw title block."""
        print("✓ Adding title block...")
        
        title_width = 2000
        title_height = 1000
        
        # Border
        self.draw_rect(x_start, y_start, title_width, title_height, self.LAYER_CONCRETE)
        
        # Vertical divider
        self.draw_line(x_start + 1200, y_start, x_start + 1200, y_start + title_height, self.LAYER_CONCRETE)
        
        # Horizontal dividers
        self.draw_line(x_start, y_start + 700, x_start + title_width, y_start + 700, self.LAYER_CONCRETE)
        self.draw_line(x_start, y_start + 400, x_start + 1200, y_start + 400, self.LAYER_CONCRETE)
        
        # Text content
        date_str = datetime.now().strftime("%d/%m/%Y")
        
        self.add_text(x_start + 100, y_start + 850, "RCC FRAMED STRUCTURE", 200, self.LAYER_TEXT)
        self.add_text(x_start + 100, y_start + 750, "STRUCTURAL DRAWING", 180, self.LAYER_TEXT)
        
        self.add_text(x_start + 100, y_start + 600, f"Date: {date_str}", 120, self.LAYER_TEXT)
        self.add_text(x_start + 100, y_start + 450, "Drawn By: Structural Engr.", 120, self.LAYER_TEXT)
        self.add_text(x_start + 100, y_start + 150, "Checked By: Senior Engr.", 120, self.LAYER_TEXT)
        
        self.add_text(x_start + 1300, y_start + 800, "Drawing No:", 120, self.LAYER_TEXT)
        self.add_text(x_start + 1400, y_start + 700, "S-01", 150, self.LAYER_TEXT)
        
        self.add_text(x_start + 1300, y_start + 550, "Scale:", 120, self.LAYER_TEXT)
        self.add_text(x_start + 1400, y_start + 450, "1:50", 150, self.LAYER_TEXT)
        
        self.add_text(x_start + 1300, y_start + 250, "Sheet:", 120, self.LAYER_TEXT)
        self.add_text(x_start + 1400, y_start + 150, "1 of 1", 150, self.LAYER_TEXT)
    
    def draw_codes_notes(self, x_start: float, y_start: float) -> None:
        """Add code references and notes."""
        print("✓ Adding notes and code references...")
        
        notes = [
            "As per IS 456:2000 — Code of Practice for Plain and RCC",
            "As per IS 13920:2016 — Ductile Detailing of RC Structures",
            "Clear Cover: 40 mm (all sides)",
            "Lap Splice Length = 50 × dia",
            "Development Length Ld = 40 × dia",
        ]
        
        for idx, note in enumerate(notes):
            self.add_text(x_start, y_start - (idx * 150), note, 80, self.LAYER_TEXT)
    
    def draw_complete(self) -> None:
        """Draw the complete structural drawing."""
        print("\n" + "="*60)
        print(" RCC STRUCTURAL DRAWING GENERATOR")
        print("="*60 + "\n")
        
        print("1/8 Creating layers...")
        self.create_layer(self.LAYER_CONCRETE, self.COLOR_GRAY)
        self.create_layer(self.LAYER_MAIN_BARS, self.COLOR_RED)
        self.create_layer(self.LAYER_STIRRUPS, self.COLOR_GREEN)
        self.create_layer(self.LAYER_DIMENSIONS, self.COLOR_YELLOW)
        self.create_layer(self.LAYER_HATCH, self.COLOR_LTGRAY)
        self.create_layer(self.LAYER_TEXT, self.COLOR_WHITE)
        self.create_layer(self.LAYER_CENTERLINE, self.COLOR_CYAN)
        self.create_layer(self.LAYER_GRID, self.COLOR_GRAY)
        
        print("2/8 Drawing elevation...")
        self.draw_elevation(0, 0)
        
        print("3/8 Drawing column section...")
        self.draw_column_section(8000, 6000)
        
        print("4/8 Drawing beam section...")
        self.draw_beam_section(8000, 3000)
        
        print("5/8 Drawing footing plan...")
        self.draw_footing_plan(8000, 0)
        
        print("6/8 Creating BBS table...")
        self.draw_bbs_table(0, -4000)
        
        print("7/8 Adding title block...")
        self.draw_title_block(0, -6500)
        
        print("8/8 Adding notes...")
        self.draw_codes_notes(2500, -7500)
        
        print("\nZooming to extents...")
        try:
            self.doc.SendCommand("_ZOOM _E\n")
        except:
            pass
        
        print("\nSaving drawing...")
        try:
            filepath = Path(__file__).parent.parent / "rcc_structural_drawing.dwg"
            self.doc.SaveAs(str(filepath))
            print(f"✓ Drawing saved: {filepath}")
        except:
            print("✗ Could not save drawing")


def main():
    """Main entry point."""
    drawing = RCCStructuralDrawing()
    
    try:
        drawing.draw_complete()
        
        print("\n" + "="*60)
        print("✓ SUCCESS! RCC Structural Drawing is ready.")
        print("="*60 + "\n")
        
    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
