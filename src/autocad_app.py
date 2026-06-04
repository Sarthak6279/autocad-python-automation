"""
AutoCAD Application Wrapper

This module provides a wrapper around pyautocad for easy interaction with AutoCAD.
"""

from pyautocad import Autocad, APoint


class AutoCADApp:
    """Wrapper class for AutoCAD automation via pyautocad."""

    def __init__(self):
        """Initialize connection to AutoCAD."""
        try:
            self.acad = Autocad()
            self.prompt("AutoCAD connection established")
        except Exception as e:
            raise RuntimeError(f"Failed to connect to AutoCAD: {str(e)}")

    def prompt(self, message: str) -> None:
        """Display a message in AutoCAD command line."""
        self.acad.prompt(message)

    def add_line(self, x1: float, y1: float, x2: float, y2: float):
        """Add a line to the drawing."""
        point1 = APoint(x1, y1)
        point2 = APoint(x2, y2)
        line = self.acad.model.AddLine(point1, point2)
        self.prompt(f"Line created from ({x1}, {y1}) to ({x2}, {y2})")
        return line

    def add_circle(self, center_x: float, center_y: float, radius: float):
        """Add a circle to the drawing."""
        center = APoint(center_x, center_y)
        circle = self.acad.model.AddCircle(center, radius)
        self.prompt(f"Circle created at ({center_x}, {center_y}) with radius {radius}")
        return circle

    def add_rectangle(self, x1: float, y1: float, x2: float, y2: float):
        """Add a rectangle using individual lines."""
        # Create rectangle using 4 lines instead of polyline for better compatibility
        self.add_line(x1, y1, x2, y1)  # Top
        self.add_line(x2, y1, x2, y2)  # Right
        self.add_line(x2, y2, x1, y2)  # Bottom
        self.add_line(x1, y2, x1, y1)  # Left
        self.prompt(f"Rectangle created from ({x1}, {y1}) to ({x2}, {y2})")
        return None

    def add_text(self, text: str, x: float, y: float, height: float = 2.5):
        """Add text to the drawing."""
        point = APoint(x, y)
        text_obj = self.acad.model.AddText(text, point, height)
        self.prompt(f"Text added: '{text}' at ({x}, {y})")
        return text_obj

    def zoom_all(self) -> None:
        """Zoom to fit all objects in view (optional)."""
        try:
            # Try to zoom to extents using ActiveX
            self.acad.ActiveDocument.SendCommand("_ZE\n")
        except:
            self.prompt("Zoom completed manually or skipped")

    def save_drawing(self, filepath: str = None) -> None:
        """Save the current drawing."""
        if filepath:
            self.acad.active_document.SaveAs(filepath)
            self.prompt(f"Drawing saved to: {filepath}")
        else:
            self.acad.active_document.Save()
            self.prompt("Drawing saved")

    def open_drawing(self, filepath: str) -> None:
        """Open a drawing file."""
        self.acad.open(filepath)
        self.prompt(f"Drawing opened: {filepath}")

    def close_drawing(self) -> None:
        """Close the current drawing."""
        self.acad.active_document.Close()
        self.prompt("Drawing closed")

    def get_drawing_name(self) -> str:
        """Get the name of the current drawing."""
        return self.acad.active_document.Name
