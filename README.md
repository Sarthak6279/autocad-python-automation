# Parametric Structural & Architectural Layout Matrix Generator (AutoLISP)

*"A generative design engine built in AutoLISP that bypasses traditional manual drafting hooks. It takes standard plot parameters and dynamically batch-compiles 100 distinctive residential blueprints side-by-side in under an hour."*

---

## 🚀 Key Features

*   **100% AutoCAD Native (Zero Dependencies)**: Bypasses Python COM layers and `pywin32` dependencies. Everything executes directly in AutoCAD's memory via native LISP.
*   **Unified Sheet compilation**: Drafts all 100 plans side-by-side in a customizable 10x10 layout grid with zero line overlaps.
*   **Integrated Civil Detailing**: Generates concrete columns, double-line walls, doorways, swing arcs, dog-legged staircases, and sanitary fixtures.
*   **Automatic Grid & Dim Lines**: Computes centerlines, grid bubble annotations, and dimensions.
*   **Reinforcement Schedules**: Generates structural concrete and steel rebars schedules and civil conformance notes on the sheet.

---

## 🧠 Core Algorithms Under the Hood

### 1. Iterative Flood-Fill Room Extractor
To merge adjacent grid cells with the same labels (e.g., Living Room), the engine runs an **iterative BFS Queue-based flood fill** in AutoLISP. This avoids recursion stack crashes and calculates the exact room bounding box:
$$x_{min}, x_{max}, y_{min}, y_{max}$$

### 2. Column Stiffness Alignment ($I = \frac{bh^3}{12}$)
Concrete column orientations are computed dynamically. Rectangular columns ($9" \times 12"$) are automatically aligned along the vertical axis of the grid nodes to maximize the second moment of area ($I$), providing maximum structural stiffness against bending moments ($M$) along the beam lines.

### 3. Split-Wall Topological Solver
To prevent lines from drawing through doors/windows, the wall solver finds all openings intersecting a wall path, sorts them coordinates-wise using `vl-sort`, and dynamically splits the double masonry walls:
$$\text{Wall Segment 1} = [x_1, \text{gap\_start}]$$
$$\text{Wall Segment 2} = [\text{gap\_end}, x_2]$$
This results in clean gaps where doors and windows are drawn.

### 4. Dynamic Scoping Matrix Mapping
Taking advantage of AutoLISP’s dynamic variable scoping, coordinates `dx` and `dy` are pushed to the stack at the parent level. All drawing primitives automatically read and apply the translation offsets on the fly, saving us from modifying the geometry signatures of the entire layout engine.

---

## 🛠️ How to Load and Run

### Step 1: Compile the LSP into a Secure Binary
To protect your raw source code, run this compilation line in your AutoCAD Command Bar. This compiles the `.lsp` code into a secure `.fas` binary:
```lisp
(vlisp-compile 'st "C:/Users/sarth/New folder (12)/lisp_portfolio_generator.lsp" "C:/Users/sarth/New folder (12)/lisp_portfolio_generator.fas")
```

### Step 2: Load the Wrapper
Load the wrapper commands file in AutoCAD:
```lisp
(load "C:/Users/sarth/New folder (12)/portfolio_generator.lsp")
```

### Step 3: Run the Commands
*   Type **`GENERATE_ALL_PLANS`** to draw the entire 100-plan matrix on a single sheet.
*   Type **`GENERATE_PLAN`** to draw a single layout.

---

## 📂 Repository Contents

*   `portfolio_generator.lsp` - The command wrapper.
*   `lisp_portfolio_generator.fas` - Compiled secure layout engine binary.
*   `portfolio/all_100_plans.dwg` - The compiled drawing containing all 100 residential floor plans.
