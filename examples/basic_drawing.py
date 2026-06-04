"""
Basic Drawing Example

Demonstrates basic drawing operations with pyautocad:
- Creating lines
- Creating circles
- Creating rectangles
- Adding text
"""

import sys
sys.path.insert(0, '..')

from src.autocad_app import AutoCADApp


def main():
    """Run basic drawing example."""
    try:
        # Initialize AutoCAD connection
        app = AutoCADApp()
        
        # Create a simple technical drawing
        app.prompt("=== Basic Drawing Example ===")
        
        # Add some lines
        app.add_line(0, 0, 100, 0)
        app.add_line(100, 0, 100, 100)
        app.add_line(100, 100, 0, 100)
        app.add_line(0, 100, 0, 0)
        
        # Add a circle in the center
        app.add_circle(50, 50, 25)
        
        # Add a rectangle
        app.add_rectangle(10, 10, 40, 40)
        
        # Add some text
        app.add_text("Basic Drawing", 50, 120, 5)
        app.add_text("(0,0)", 5, -10, 2)
        app.add_text("(100,100)", 95, 110, 2)
        
        # Zoom to fit all objects
        app.zoom_all()
        
        app.prompt("=== Drawing Complete ===")
        
    except Exception as e:
        print(f"Error: {str(e)}")
        print("Make sure AutoCAD is running and COM is enabled.")


if __name__ == "__main__":
    main()
