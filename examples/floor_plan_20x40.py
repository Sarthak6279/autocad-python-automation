"""
20x40 Residential Floor Plan Generator

Creates a professional CAD floor plan using pyautocad.
- Site: 20 feet wide × 40 feet deep
- Units: feet (1 unit = 1 foot)
- Scale: 1:50 annotation scale

Author: AutoCAD Python Engineer
Date: 2026
"""

import sys
from datetime import datetime
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

try:
    from pyautocad import Autocad, APoint
except ImportError:
    print("Error: pyautocad not installed. Install with: pip install pyautocad")
    sys.exit(1)


class FloorPlanDrawer:
    """Professional floor plan drawing class."""
    
    # Color constants
    COLOR_RED = 1
    COLOR_YELLOW = 2
    COLOR_GREEN = 3
    COLOR_CYAN = 4
    COLOR_BLUE = 5
    COLOR_WHITE = 7
    
    # Layer names
    LAYER_WALLS = "WALLS"
    LAYER_PARTITION = "PARTITION"
    LAYER_DOORS = "DOORS"
    LAYER_WINDOWS = "WINDOWS"
    LAYER_DIMENSIONS = "DIMENSIONS"
    LAYER_TEXT = "TEXT"
    LAYER_TITLEBLOCK = "TITLEBLOCK"
    
    def __init__(self):
        """Initialize connection to AutoCAD."""
        try:
            self.acad = Autocad(create_if_not_exists=True)
            self.doc = self.acad.ActiveDocument
            self.model = self.acad.model
            print("✓ Connected to AutoCAD")
        except Exception as e:
            print(f"✗ Failed to connect to AutoCAD: {e}")
            print("  Make sure AutoCAD is running!")
            sys.exit(1)
    
    def create_layer(self, name: str, color: int) -> None:
        """Create a layer if it doesn't exist."""
        try:
            layers = self.doc.Layers
            layer = layers.Item(name)
            print(f"  Layer '{name}' already exists")
        except:
            # Layer doesn't exist, create it
            layer = layers.Add(name)
            layer.Color = color
            print(f"  ✓ Created layer '{name}' (color {color})")
    
    def set_current_layer(self, layer_name: str) -> None:
        """Set the current drawing layer."""
        self.doc.ActiveLayer = self.doc.Layers.Item(layer_name)
    
    def draw_rectangle(self, x1: float, y1: float, x2: float, y2: float, 
                       layer: str, color: int = None) -> list:
        """
        Draw a rectangle (closed polyline).
        
        Args:
            x1, y1: Bottom-left corner
            x2, y2: Top-right corner
            layer: Layer name
            color: Color index (optional)
        
        Returns:
            List of line objects
        """
        self.set_current_layer(layer)
        lines = []
        
        # Bottom line
        p1 = APoint(x1, y1)
        p2 = APoint(x2, y1)
        line = self.model.AddLine(p1, p2)
        if color:
            line.Color = color
        lines.append(line)
        
        # Right line
        p3 = APoint(x2, y2)
        line = self.model.AddLine(p2, p3)
        if color:
            line.Color = color
        lines.append(line)
        
        # Top line
        p4 = APoint(x1, y2)
        line = self.model.AddLine(p3, p4)
        if color:
            line.Color = color
        lines.append(line)
        
        # Left line
        line = self.model.AddLine(p4, p1)
        if color:
            line.Color = color
        lines.append(line)
        
        return lines
    
    def draw_wall(self, x1: float, y1: float, x2: float, y2: float, 
                  thickness: float, layer: str) -> None:
        """
        Draw a wall as a rectangle with given thickness.
        
        Args:
            x1, y1: Start point
            x2, y2: End point
            thickness: Wall thickness in feet
            layer: Layer name
        """
        self.set_current_layer(layer)
        
        # Calculate perpendicular offset for wall thickness
        dx = x2 - x1
        dy = y2 - y1
        length = (dx**2 + dy**2)**0.5
        
        if length == 0:
            return
        
        # Normalize direction vector
        nx = -dy / length * thickness / 2
        ny = dx / length * thickness / 2
        
        # Create wall rectangle
        p1 = APoint(x1 - nx, y1 - ny)
        p2 = APoint(x2 - nx, y2 - ny)
        p3 = APoint(x2 + nx, y2 + ny)
        p4 = APoint(x1 + nx, y1 + ny)
        
        # Draw filled rectangle using 4 lines
        self.model.AddLine(p1, p2)
        self.model.AddLine(p2, p3)
        self.model.AddLine(p3, p4)
        self.model.AddLine(p4, p1)
    
    def draw_door(self, x: float, y: float, width: float, 
                  direction: str, layer: str) -> None:
        """
        Draw a simple door opening without overlapping.
        
        Args:
            x, y: Door center position
            width: Door width (typically 3 feet)
            direction: 'up', 'down', 'left', 'right'
            layer: Layer name
        """
        self.set_current_layer(layer)
        
        half_width = width / 2
        
        # Draw opening line (gap in wall)
        if direction == "up" or direction == "down":
            # Horizontal opening
            p1 = APoint(x - half_width, y)
            p2 = APoint(x + half_width, y)
            line = self.model.AddLine(p1, p2)
            line.Color = self.COLOR_GREEN
            
            if direction == "up":
                # Small arc swinging into room (upward)
                center = APoint(x + half_width, y)
                arc = self.model.AddArc(center, half_width * 0.8, 180, 270)
            else:  # down
                # Small arc swinging downward
                center = APoint(x - half_width, y)
                arc = self.model.AddArc(center, half_width * 0.8, 0, 90)
            arc.Color = self.COLOR_GREEN
            
        else:  # left or right
            # Vertical opening
            p1 = APoint(x, y - half_width)
            p2 = APoint(x, y + half_width)
            line = self.model.AddLine(p1, p2)
            line.Color = self.COLOR_GREEN
            
            if direction == "left":
                # Small arc swinging left
                center = APoint(x, y + half_width)
                arc = self.model.AddArc(center, half_width * 0.8, 270, 360)
            else:  # right
                # Small arc swinging right
                center = APoint(x, y - half_width)
                arc = self.model.AddArc(center, half_width * 0.8, 90, 180)
            arc.Color = self.COLOR_GREEN
    
    def draw_window(self, x: float, y: float, width: float, 
                    wall_side: str, layer: str) -> None:
        """
        Draw a window as double parallel lines.
        
        Args:
            x, y: Window position (center)
            width: Window width (typically 4 feet)
            wall_side: 'top', 'bottom', 'left', 'right'
            layer: Layer name
        """
        self.set_current_layer(layer)
        
        offset = 0.25  # Distance between parallel lines
        half_width = width / 2
        
        if wall_side in ["top", "bottom"]:
            # Horizontal window
            # Outer line
            p1 = APoint(x - half_width, y)
            p2 = APoint(x + half_width, y)
            line1 = self.model.AddLine(p1, p2)
            
            # Inner line
            p3 = APoint(x - half_width, y + offset)
            p4 = APoint(x + half_width, y + offset)
            line2 = self.model.AddLine(p3, p4)
        else:
            # Vertical window
            # Outer line
            p1 = APoint(x, y - half_width)
            p2 = APoint(x, y + half_width)
            line1 = self.model.AddLine(p1, p2)
            
            # Inner line
            p3 = APoint(x + offset, y - half_width)
            p4 = APoint(x + offset, y + half_width)
            line2 = self.model.AddLine(p3, p4)
        
        line1.Color = self.COLOR_BLUE
        line2.Color = self.COLOR_BLUE
    
    def add_text_label(self, text: str, x: float, y: float, 
                       height: float, layer: str) -> None:
        """Add a text label."""
        self.set_current_layer(layer)
        point = APoint(x, y)
        txt = self.model.AddText(text, point, height)
        txt.Color = self.COLOR_WHITE
        txt.Alignment = 4  # Centered
        txt.TextAlignmentPoint = point
    
    def add_dimension(self, x1: float, y1: float, x2: float, y2: float, 
                     offset: float, layer: str, text: str = "") -> None:
        """Add a linear dimension."""
        self.set_current_layer(layer)
        
        p1 = APoint(x1, y1)
        p2 = APoint(x2, y2)
        
        # Calculate offset point for dimension line
        dx = x2 - x1
        dy = y2 - y1
        length = (dx**2 + dy**2)**0.5
        
        if length > 0:
            # Perpendicular offset
            nx = -dy / length * offset
            ny = dx / length * offset
            
            p3 = APoint(x1 + nx, y1 + ny)
            
            try:
                dim = self.model.AddDimLinear(p1, p2, p3)
                dim.Color = self.COLOR_YELLOW
                
                if text:
                    dim.TextOverride = text
            except:
                pass  # Dimension might fail in some cases
    
    def draw_floor_plan(self) -> None:
        """Draw the complete 20x40 floor plan."""
        print("\n=== Drawing 20×40 Residential Floor Plan ===\n")
        
        # Create layers
        print("Creating layers...")
        self.create_layer(self.LAYER_WALLS, self.COLOR_RED)
        self.create_layer(self.LAYER_PARTITION, self.COLOR_CYAN)
        self.create_layer(self.LAYER_DOORS, self.COLOR_GREEN)
        self.create_layer(self.LAYER_WINDOWS, self.COLOR_BLUE)
        self.create_layer(self.LAYER_DIMENSIONS, self.COLOR_YELLOW)
        self.create_layer(self.LAYER_TEXT, self.COLOR_WHITE)
        self.create_layer(self.LAYER_TITLEBLOCK, self.COLOR_WHITE)
        
        # Floor plan dimensions
        site_width = 20.0
        site_depth = 40.0
        wall_thick = 0.75  # 9 inches
        partition_thick = 0.375  # 4.5 inches
        
        print("\n✓ Drawing outer walls...")
        # Outer walls (9-inch thick)
        self.draw_wall(0, 0, site_width, 0, wall_thick, self.LAYER_WALLS)
        self.draw_wall(site_width, 0, site_width, site_depth, wall_thick, self.LAYER_WALLS)
        self.draw_wall(site_width, site_depth, 0, site_depth, wall_thick, self.LAYER_WALLS)
        self.draw_wall(0, site_depth, 0, 0, wall_thick, self.LAYER_WALLS)
        
        # FRONT SECTION (0-14 ft from front)
        print("✓ Drawing room partitions...")
        
        # Horizontal partition separating front and rear (at 14 ft)
        self.draw_wall(wall_thick, 14, site_width - wall_thick, 14, 
                      partition_thick, self.LAYER_PARTITION)
        
        # Vertical partition between left and middle (at 10 ft)
        self.draw_wall(10, wall_thick, 10, 14 - wall_thick, 
                      partition_thick, self.LAYER_PARTITION)
        
        # Vertical partition between middle and right (at 15 ft)
        self.draw_wall(15, wall_thick, 15, 14 - wall_thick, 
                      partition_thick, self.LAYER_PARTITION)
        
        # REAR SECTION
        # Vertical partition between rear-left and center (at 9 ft)
        self.draw_wall(9, 14 + wall_thick, 9, site_depth - wall_thick, 
                      partition_thick, self.LAYER_PARTITION)
        
        # Vertical partition between center and rear-right (at 14.5 ft)
        self.draw_wall(14.5, 14 + wall_thick, 14.5, site_depth - wall_thick, 
                      partition_thick, self.LAYER_PARTITION)
        
        # FRONT ENTRANCE (center, 5x8)
        print("✓ Adding doors...")
        # Door to outside (front wall)
        self.draw_door(10, wall_thick/2, 3.0, "down", self.LAYER_DOORS)
        
        # Door: lobby to living room
        self.draw_door(10 - 1.5, 14 - wall_thick/2, 3.0, "up", self.LAYER_DOORS)
        
        # Door: lobby to kitchen
        self.draw_door(10 + 1.5, 14 - wall_thick/2, 3.0, "up", self.LAYER_DOORS)
        
        # Door: living room to corridor
        self.draw_door(10 - wall_thick/2, 9, 3.0, "left", self.LAYER_DOORS)
        
        # Door: kitchen to corridor
        self.draw_door(15 + wall_thick/2, 9, 3.0, "right", self.LAYER_DOORS)
        
        # Door: master bedroom to corridor
        self.draw_door(9 - wall_thick/2, 22, 3.0, "left", self.LAYER_DOORS)
        
        # Door: bedroom 2 to corridor
        self.draw_door(14.5 + wall_thick/2, 22, 3.0, "right", self.LAYER_DOORS)
        
        # Door: bathroom to corridor
        self.draw_door(12, 14 + wall_thick/2, 3.0, "down", self.LAYER_DOORS)
        
        # WINDOWS
        print("✓ Adding windows...")
        # Living room windows (front and side)
        self.draw_window(3, wall_thick/2, 4.0, "bottom", self.LAYER_WINDOWS)
        self.draw_window(wall_thick/2, 7, 4.0, "left", self.LAYER_WINDOWS)
        
        # Kitchen windows (front)
        self.draw_window(17, wall_thick/2, 4.0, "bottom", self.LAYER_WINDOWS)
        
        # Master bedroom window
        self.draw_window(wall_thick/2, 20, 4.0, "left", self.LAYER_WINDOWS)
        
        # Bedroom 2 window
        self.draw_window(site_width - wall_thick/2, 20, 4.0, "right", self.LAYER_WINDOWS)
        
        # Rear windows
        self.draw_window(3, site_depth - wall_thick/2, 4.0, "top", self.LAYER_WINDOWS)
        self.draw_window(17, site_depth - wall_thick/2, 4.0, "top", self.LAYER_WINDOWS)
        
        # ROOM LABELS
        print("✓ Adding room labels...")
        # Front section labels
        self.add_text_label("ENTRANCE\n5' × 8'", 10, 6, 1.0, self.LAYER_TEXT)
        self.add_text_label("LIVING ROOM\n5' × 14'", 4, 9, 1.0, self.LAYER_TEXT)
        self.add_text_label("KITCHEN\n5' × 14'", 17.5, 9, 1.0, self.LAYER_TEXT)
        
        # Rear section labels
        self.add_text_label("MASTER\nBEDROOM\n4.5' × 12'", 4, 22, 0.9, self.LAYER_TEXT)
        self.add_text_label("BEDROOM 2\n4.5' × 12'", 17, 22, 0.9, self.LAYER_TEXT)
        self.add_text_label("WC\n5.5' × 6'", 12, 27, 1.0, self.LAYER_TEXT)
        
        # Corridor label
        self.add_text_label("CORRIDOR\n4' wide", 12, 9, 0.9, self.LAYER_TEXT)
        
        # DIMENSIONS
        print("✓ Adding dimensions...")
        
        # Overall site dimensions
        self.add_dimension(wall_thick, -2.5, site_width - wall_thick, -2.5, -0.8, 
                          self.LAYER_DIMENSIONS, "20'-0\"")
        self.add_dimension(-2.5, wall_thick, -2.5, site_depth - wall_thick, -0.8, 
                          self.LAYER_DIMENSIONS, "40'-0\"")
        
        # Front section dimensions (horizontal)
        self.add_dimension(wall_thick, 1, 10 - wall_thick/2, 1, 0.5, 
                          self.LAYER_DIMENSIONS, "5'")
        self.add_dimension(10 + wall_thick/2, 1, 15 - wall_thick/2, 1, 0.5, 
                          self.LAYER_DIMENSIONS, "5'")
        self.add_dimension(15 + wall_thick/2, 1, site_width - wall_thick, 1, 0.5, 
                          self.LAYER_DIMENSIONS, "5'")
        
        # Front section dimensions (vertical)
        self.add_dimension(0.5, wall_thick, 0.5, 14 - wall_thick/2, -0.5, 
                          self.LAYER_DIMENSIONS, "14'")
        self.add_dimension(site_width - 0.5, wall_thick, site_width - 0.5, 14 - wall_thick/2, -0.5, 
                          self.LAYER_DIMENSIONS, "14'")
        
        # Rear section dimensions (vertical)
        self.add_dimension(0.5, 14 + wall_thick, 0.5, site_depth - wall_thick, -0.5, 
                          self.LAYER_DIMENSIONS, "26'")
        self.add_dimension(site_width - 0.5, 14 + wall_thick, site_width - 0.5, site_depth - wall_thick, -0.5, 
                          self.LAYER_DIMENSIONS, "26'")
        
        # Room width dimensions
        self.add_dimension(wall_thick, 13, 9 - wall_thick/2, 13, 0.3, 
                          self.LAYER_DIMENSIONS, "4.5'")
        self.add_dimension(10 + wall_thick/2, 13, 14.5 - wall_thick/2, 13, 0.3, 
                          self.LAYER_DIMENSIONS, "4'")
        self.add_dimension(14.5 + wall_thick/2, 13, site_width - wall_thick, 13, 0.3, 
                          self.LAYER_DIMENSIONS, "4.5'")
        
        # Bathroom dimensions
        self.add_dimension(9 - wall_thick/2, 30, 14.5 + wall_thick/2, 30, 0.3, 
                          self.LAYER_DIMENSIONS, "5.5'")
        
        # TITLE BLOCK
        print("✓ Adding title block...")
        title_x = 0.5
        title_y = -4.5
        
        self.add_text_label("20×40 RESIDENTIAL FLOOR PLAN", title_x, title_y, 
                          2.0, self.LAYER_TITLEBLOCK)
        
        date_str = datetime.now().strftime("%m/%d/%Y")
        self.add_text_label(f"Scale: 1:50  |  Date: {date_str}  |  Drawn by: Engineer", 
                          title_x, title_y - 1.5, 1.0, self.LAYER_TITLEBLOCK)
        
        print("\n✓ Floor plan drawing complete!")
    
    def zoom_extents(self) -> None:
        """Zoom to fit all objects."""
        print("✓ Zooming to extents...")
        try:
            self.doc.SendCommand("_ZOOM _E\n")
        except:
            print("  (Zoom command skipped)")
    
    def save_drawing(self, filename: str = "floor_plan.dwg") -> None:
        """Save the drawing."""
        try:
            filepath = Path(__file__).parent.parent / filename
            self.doc.SaveAs(str(filepath))
            print(f"✓ Drawing saved: {filepath}")
        except Exception as e:
            print(f"  Could not save: {e}")


def main():
    """Main entry point."""
    print("\n" + "="*60)
    print(" AutoCAD Floor Plan Generator")
    print(" 20×40 Residential Floor Plan with pyautocad")
    print("="*60)
    
    drawer = FloorPlanDrawer()
    
    try:
        drawer.draw_floor_plan()
        drawer.zoom_extents()
        drawer.save_drawing()
        
        print("\n" + "="*60)
        print("✓ SUCCESS! Floor plan is ready in AutoCAD.")
        print("="*60 + "\n")
        
    except Exception as e:
        print(f"\n✗ Error during drawing: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
