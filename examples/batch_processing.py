"""
Batch Processing Example

Demonstrates batch processing operations:
- Processing multiple drawing files
- Applying transformations to existing drawings
- Extracting information from drawings
"""

import sys
import os
from pathlib import Path

sys.path.insert(0, '..')

from src.autocad_app import AutoCADApp


def process_drawing(filepath: str) -> dict:
    """
    Process a single drawing file.
    
    Args:
        filepath: Path to the DWG file
        
    Returns:
        Dictionary with drawing information
    """
    try:
        app = AutoCADApp()
        app.open_drawing(filepath)
        
        drawing_name = app.get_drawing_name()
        model_space = app.acad.model
        
        # Count objects in the drawing
        object_count = model_space.Count
        
        # Collect information
        info = {
            'filepath': filepath,
            'name': drawing_name,
            'objects': object_count,
            'status': 'success'
        }
        
        app.prompt(f"Processed: {drawing_name} ({object_count} objects)")
        app.close_drawing()
        
        return info
        
    except Exception as e:
        return {
            'filepath': filepath,
            'status': 'error',
            'error': str(e)
        }


def batch_process_directory(directory: str) -> list:
    """
    Process all DWG files in a directory.
    
    Args:
        directory: Path to directory containing DWG files
        
    Returns:
        List of processing results
    """
    results = []
    dwg_files = Path(directory).glob("*.dwg")
    
    for dwg_file in dwg_files:
        print(f"Processing: {dwg_file.name}")
        result = process_drawing(str(dwg_file))
        results.append(result)
        
    return results


def main():
    """Run batch processing example."""
    print("=== Batch Processing Example ===")
    
    # Example: Process drawings in current directory
    # Change this path to your drawings location
    drawings_directory = r"C:\Users\YourUsername\Documents\AutoCAD Drawings"
    
    if os.path.exists(drawings_directory):
        results = batch_process_directory(drawings_directory)
        
        print("\n=== Processing Results ===")
        for result in results:
            if result['status'] == 'success':
                print(f"✓ {result['name']}: {result['objects']} objects")
            else:
                print(f"✗ {result['filepath']}: {result['error']}")
    else:
        print(f"Directory not found: {drawings_directory}")
        print("Please update the drawings_directory path in this script.")


if __name__ == "__main__":
    main()
