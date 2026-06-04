;;; rcc_structural_detail.lsp - Structural RCC Drawing Generator (40' x 50')
;;;
;;; Features:
;;; 1. Draws concrete structural columns at accurate engineered locations.
;;; 2. Generates a clean Centre Line Grid (A to F, 1 to 4) passing through column centers.
;;; 3. Places Grid Bubbles (circles) with lettering and numbering.
;;; 4. Adds linear grid-to-grid spacing dimensions.
;;; 5. Generates the Structural Beam framing grid layout.
;;; 6. Draws a complete, detailed Reinforcement Schedule Table to the right side:
;;;    - Size specifications, Main reinforcement bar count, Stirrup links, Footing reinforcement, concrete grades.
;;; 7. Includes structural General Notes for site construction.
;;;
;;; To load: (load "C:/Users/sarth/.gemini/antigravity-ide/scratch/autocad-lisp-scripts/rcc_structural_detail.lsp")
;;; Run command: DRAW_STRUCTURAL_SHEET

(defun c:draw_structural_sheet ( / 
                                ;; System settings
                                oldCmdEcho oldOsmode oldClayer oldHpname
                                ;; Layout parameters
                                w h textH gridExt
                                ;; Grid definitions
                                xGrid yGrid xLabels yLabels
                                ;; Iterators & Points
                                i j x y p1 p2 p3 tx ty th ny
                                ;; Helpers
                                draw_line draw_rect draw_circle draw_text
                                draw_table_cell apply_solid_hatch
                                )
  
  ;; Save state
  (setq oldCmdEcho (getvar "CMDECHO"))
  (setq oldOsmode (getvar "OSMODE"))
  (setq oldClayer (getvar "CLAYER"))
  (setq oldHpname (getvar "HPNAME"))
  
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0) ; Disable OSNAPs to prevent snapping to active geometry
  
  ;; Plot dimensions (40' x 50' in inches = 480" x 600")
  (setq w 480.0)
  (setq h 600.0)
  (setq textH 10.0)
  
  ;; Column center intersections:
  (setq xGrid '(9.0 190.0 250.0 290.0 330.0 471.0)) ; Grids A, B, C, D, E, F
  (setq yGrid '(9.0 210.0 420.0 591.0))            ; Grids 1, 2, 3, 4
  (setq xLabels '("A" "B" "C" "D" "E" "F"))
  (setq yLabels '("1" "2" "3" "4"))

  ;; Load CENTER linetype safely to avoid prompt conflicts
  (vl-load-com)
  (if (not (tblsearch "LTYPE" "CENTER"))
    (vl-catch-all-apply
      '(lambda () 
         (command "_.linetype" "_load" "CENTER" "acad.lin" "")
       )
    )
  )

  ;; --- LAYER CREATION (Single command to avoid active prompt locks) ---
  (if (tblsearch "LTYPE" "CENTER")
    (command "_.layer" 
             "_make" "S-GRID-CENTER" "_color" "8" "S-GRID-CENTER" "_ltype" "CENTER" "S-GRID-CENTER"
             "_make" "S-COLUMN"      "_color" "1" "S-COLUMN"
             "_make" "S-COL-HATCH"   "_color" "251" "S-COL-HATCH"
             "_make" "S-BEAM-FRAMING" "_color" "2" "S-BEAM-FRAMING"
             "_make" "S-BUBBLE"      "_color" "4" "S-BUBBLE"
             "_make" "S-TABLE"       "_color" "7" "S-TABLE"
             "_make" "S-TEXT"        "_color" "3" "S-TEXT"
             "_make" "S-DIM"         "_color" "5" "S-DIM"
             "")
    (command "_.layer" 
             "_make" "S-GRID-CENTER" "_color" "8" "S-GRID-CENTER"
             "_make" "S-COLUMN"      "_color" "1" "S-COLUMN"
             "_make" "S-COL-HATCH"   "_color" "251" "S-COL-HATCH"
             "_make" "S-BEAM-FRAMING" "_color" "2" "S-BEAM-FRAMING"
             "_make" "S-BUBBLE"      "_color" "4" "S-BUBBLE"
             "_make" "S-TABLE"       "_color" "7" "S-TABLE"
             "_make" "S-TEXT"        "_color" "3" "S-TEXT"
             "_make" "S-DIM"         "_color" "5" "S-DIM"
             "")
  )
  ;; Clear any active LAYER command hanging prompts
  (while (> (getvar "CMDACTIVE") 0) (command ""))

  ;; Set Hatch Pattern System Variable
  (setvar "HPNAME" "SOLID")

  ;; --- HELPERS (With CMDACTIVE safety loops to ensure clean termination) ---
  
  (defun draw_line (p1 p2 layer)
    (setvar "CLAYER" layer)
    (command "_.line" p1 p2 "")
    (while (> (getvar "CMDACTIVE") 0) (command ""))
  )
  
  (defun draw_rect (p1 p2 layer)
    (setvar "CLAYER" layer)
    (command "_.rectang" p1 p2)
    (while (> (getvar "CMDACTIVE") 0) (command ""))
  )
  
  (defun draw_circle (pt radius layer)
    (setvar "CLAYER" layer)
    (command "_.circle" pt radius)
    (while (> (getvar "CMDACTIVE") 0) (command ""))
  )
  
  (defun draw_text (pt height txt alignment layer / align)
    (setvar "CLAYER" layer)
    (cond
      ((= alignment "C") (setq align "_center"))
      ((= alignment "M") (setq align "_middle"))
      (t (setq align "_left"))
    )
    (if (= alignment "L")
      (entmake (list '(0 . "TEXT") (cons 10 pt) (cons 40 height) (cons 1 txt) (cons 8 layer)))
      (entmake (list '(0 . "TEXT") (cons 10 pt) (cons 11 pt) (cons 72 1) (cons 40 height) (cons 1 txt) (cons 8 layer)))
    )
  )

  ;; Draw Table Cell Text Helper
  (defun draw_table_cell (x y w h txt alignment)
    (setvar "CLAYER" "S-TABLE")
    (draw_rect (list x y 0.0) (list (+ x w) (+ y h) 0.0) "S-TABLE")
    (draw_text (list (+ x (/ w 2.0)) (+ y (/ h 2.0) -3.0) 0.0) 8.0 txt alignment "S-TEXT")
  )

  ;; Helper: Create Solid Hatch Safely with command loop cleanup
  (defun apply_solid_hatch (ent)
    (setvar "CLAYER" "S-COL-HATCH")
    (command "_.-hatch" "_select" ent "")
    (while (> (getvar "CMDACTIVE") 0) (command ""))
  )

  ;; --- 1. DRAW BEAM FRAMING ---
  (princ "\nDrawing structural beam framing plan...")
  ;; Drawing beams directly connecting all columns
  ;; Vertical Beams
  (foreach x xGrid
    (draw_line (list x 9.0 0.0) (list x 591.0 0.0) "S-BEAM-FRAMING")
  )
  ;; Horizontal Beams
  (foreach y yGrid
    (draw_line (list 9.0 y 0.0) (list 471.0 y 0.0) "S-BEAM-FRAMING")
  )

  ;; --- 2. DRAW COLUMNS ---
  (princ "\nDrawing columns at junctions...")
  
  ;; C1
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 3.0 4.5 0.0) (list 15.0 13.5 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 9.0 20.0 0.0) 6.0 "C1" "C" "S-TEXT")

  ;; C2
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 184.0 4.5 0.0) (list 196.0 13.5 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 190.0 20.0 0.0) 6.0 "C2" "C" "S-TEXT")

  ;; C3
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 284.0 4.5 0.0) (list 296.0 13.5 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 290.0 20.0 0.0) 6.0 "C3" "C" "S-TEXT")

  ;; C4
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 465.0 3.0 0.0) (list 477.0 15.0 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 471.0 20.0 0.0) 6.0 "C4" "C" "S-TEXT")

  ;; C5
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 4.5 205.5 0.0) (list 13.5 214.5 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 9.0 220.0 0.0) 6.0 "C5" "C" "S-TEXT")

  ;; C6
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 185.5 204.0 0.0) (list 194.5 216.0 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 190.0 220.0 0.0) 6.0 "C6" "C" "S-TEXT")

  ;; C7
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 285.5 204.0 0.0) (list 294.5 216.0 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 290.0 220.0 0.0) 6.0 "C7" "C" "S-TEXT")

  ;; C8
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 325.5 204.0 0.0) (list 334.5 216.0 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 330.0 220.0 0.0) 6.0 "C8" "C" "S-TEXT")

  ;; C9
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 465.0 205.5 0.0) (list 477.0 214.5 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 471.0 220.0 0.0) 6.0 "C9" "C" "S-TEXT")

  ;; C10
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 4.5 415.5 0.0) (list 13.5 424.5 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 9.0 430.0 0.0) 6.0 "C10" "C" "S-TEXT")

  ;; C11
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 185.5 414.0 0.0) (list 194.5 426.0 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 190.0 430.0 0.0) 6.0 "C11" "C" "S-TEXT")

  ;; C12
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 245.5 415.5 0.0) (list 254.5 424.5 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 250.0 430.0 0.0) 6.0 "C12" "C" "S-TEXT")

  ;; C13
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 325.5 414.0 0.0) (list 334.5 426.0 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 330.0 430.0 0.0) 6.0 "C13" "C" "S-TEXT")

  ;; C14
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 465.0 415.5 0.0) (list 477.0 424.5 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 471.0 430.0 0.0) 6.0 "C14" "C" "S-TEXT")

  ;; C15
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 3.0 586.5 0.0) (list 15.0 595.5 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 9.0 575.0 0.0) 6.0 "C15" "C" "S-TEXT")

  ;; C16
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 245.5 585.0 0.0) (list 254.5 597.0 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 250.0 575.0 0.0) 6.0 "C16" "C" "S-TEXT")

  ;; C17
  (setvar "CLAYER" "S-COLUMN")
  (command "_.rectang" (list 465.0 586.5 0.0) (list 477.0 595.5 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (apply_solid_hatch (entlast))
  (draw_text (list 471.0 575.0 0.0) 6.0 "C17" "C" "S-TEXT")


  ;; --- 3. CENTRE LINE GRID & BUBBLES ---
  (princ "\nDrawing centre line grids and bubbles...")
  (setq gridExt 48.0) ; 4 feet extension outside column lines
  
  ;; Vertical Grid Lines (X axis)
  (setq i 0)
  (foreach x xGrid
    ;; Dashed Centerline
    (draw_line (list x (- 9.0 gridExt) 0.0) (list x (+ 591.0 gridExt) 0.0) "S-GRID-CENTER")
    
    ;; Bottom Grid Bubble
    (draw_circle (list x (- 9.0 gridExt 12.0) 0.0) 12.0 "S-BUBBLE")
    (draw_text (list x (- 9.0 gridExt 16.0) 0.0) 10.0 (nth i xLabels) "C" "S-TEXT")
    
    ;; Top Grid Bubble
    (draw_circle (list x (+ 591.0 gridExt 12.0) 0.0) 12.0 "S-BUBBLE")
    (draw_text (list x (+ 591.0 gridExt 8.0) 0.0) 10.0 (nth i xLabels) "C" "S-TEXT")
    
    (setq i (1+ i))
  )

  ;; Horizontal Grid Lines (Y axis)
  (setq j 0)
  (foreach y yGrid
    ;; Dashed Centerline
    (draw_line (list (- 9.0 gridExt) y 0.0) (list (+ 471.0 gridExt) y 0.0) "S-GRID-CENTER")
    
    ;; Left Grid Bubble
    (draw_circle (list (- 9.0 gridExt 12.0) y 0.0) 12.0 "S-BUBBLE")
    (draw_text (list (- 9.0 gridExt 16.0) (- y 4.0) 0.0) 10.0 (nth j yLabels) "C" "S-TEXT")
    
    ;; Right Grid Bubble
    (draw_circle (list (+ 471.0 gridExt 12.0) y 0.0) 12.0 "S-BUBBLE")
    (draw_text (list (+ 471.0 gridExt 8.0) (- y 4.0) 0.0) 10.0 (nth j yLabels) "C" "S-TEXT")
    
    (setq j (1+ j))
  )

  ;; --- 4. GRID DIMENSIONS ---
  (princ "\nGenerating spacing dimensions...")
  (setvar "CLAYER" "S-DIM")
  
  ;; Vertical spacing dimensions (X spans) - placed at bottom
  (setq i 0)
  (while (< i (1- (length xGrid)))
    (setq p1 (list (nth i xGrid) (- 9.0 gridExt 36.0) 0.0))
    (command "_.dimlinear" (list (nth i xGrid) 9.0 0.0) (list (nth (1+ i) xGrid) 9.0 0.0) p1)
    (while (> (getvar "CMDACTIVE") 0) (command ""))
    (setq i (1+ i))
  )
  ;; Overall Horizontal Grid Span (A to F)
  (command "_.dimlinear" (list 9.0 9.0 0.0) (list 471.0 9.0 0.0) (list 240.0 (- 9.0 gridExt 60.0) 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))

  ;; Horizontal spacing dimensions (Y spans) - placed at left
  (setq j 0)
  (while (< j (1- (length yGrid)))
    (setq p1 (list (- 9.0 gridExt 36.0) (nth j yGrid) 0.0))
    (command "_.dimlinear" (list 9.0 (nth j yGrid) 0.0) (list 9.0 (nth (1+ j) yGrid) 0.0) p1)
    (while (> (getvar "CMDACTIVE") 0) (command ""))
    (setq j (1+ j))
  )
  ;; Overall Vertical Grid Span (1 to 4)
  (command "_.dimlinear" (list 9.0 9.0 0.0) (list 9.0 591.0 0.0) (list (- 9.0 gridExt 60.0) 300.0 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))

  ;; --- 5. REINFORCEMENT DETAIL SCHEDULE TABLE ---
  (princ "\nGenerating structural reinforcement schedule table...")
  
  ;; Table starting position: X = 550, Y = 180
  (setq tx 550.0)
  (setq ty 180.0)
  (setq th 30.0) ; row height
  
  ;; Draw Table Title
  (setvar "CLAYER" "S-TABLE")
  (draw_rect (list tx (+ ty (* th 6)) 0.0) (list (+ tx 380.0) (+ ty (* th 7)) 0.0) "S-TABLE")
  (draw_text (list (+ tx 190.0) (+ ty (* th 6) 8.0) 0.0) 12.0 "RCC COLUMN & FOOTING REINFORCEMENT SCHEDULE" "C" "S-TEXT")
  
  ;; Headers
  (draw_table_cell tx (+ ty (* th 5)) 60.0 th "MARK" "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 5)) 60.0 th "SIZE (w x d)" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 5)) 120.0 th "MAIN REINFORCEMENT" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 5)) 70.0 th "TIES (LINKS)" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 5)) 70.0 th "FOOTING DETAIL" "C")
  
  ;; Row 1: C1, C4, C15, C17 (Master corner columns)
  (draw_table_cell tx (+ ty (* th 4)) 60.0 th "C1,C4,C15,C17" "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 4)) 60.0 th "9\" x 12\"" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 4)) 120.0 th "4 Nos - #16 + 2 Nos - #12" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 4)) 70.0 th "#8 @ 150 c/c" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 4)) 70.0 th "4'6\"x4'6\"x12\" (#12@150)" "C")

  ;; Row 2: C2, C3, C6, C7, C9, C11, C13, C14, C16 (Intermediate frame columns)
  (draw_table_cell tx (+ ty (* th 3)) 60.0 th "C2,C3,C6,C7,C9,..." "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 3)) 60.0 th "9\" x 12\"" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 3)) 120.0 th "4 Nos - #16" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 3)) 70.0 th "#8 @ 150 c/c" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 3)) 70.0 th "4'0\"x4'0\"x12\" (#12@150)" "C")

  ;; Row 3: C5, C10, C12, C8 (Minor grid points)
  (draw_table_cell tx (+ ty (* th 2)) 60.0 th "C5,C8,C10,C12" "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 2)) 60.0 th "9\" x 9\"" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 2)) 120.0 th "4 Nos - #12" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 2)) 70.0 th "#8 @ 200 c/c" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 2)) 70.0 th "3'6\"x3'6\"x10\" (#10@150)" "C")

  ;; Concrete and Steel specification values block
  (draw_table_cell tx (+ ty (* th 0)) 180.0 (* th 2) "CONCRETE MIX: M25 Grade\nSTEEL TYPE: Fe 500 TMT bars" "C")
  (draw_table_cell (+ tx 180.0) (+ ty (* th 0)) 200.0 (* th 2) "CLEAR COVERS:\nFooting: 50mm | Column: 40mm | Beam: 25mm" "C")

  ;; --- 6. GENERAL STRUCTURAL ENGINEERING NOTES ---
  (princ "\nWriting general notes block...")
  (setvar "CLAYER" "A-TEXT")
  (setq ny (+ ty (* th 8)))
  (draw_text (list tx ny 0.0) 14.0 "GENERAL STRUCTURAL CONFORMANCE NOTES:" "L" "S-TEXT")
  (draw_text (list tx (- ny 20.0) 0.0) 9.0 "1. ALL STRUCTURAL DIMENSIONS ARE IN INCHES UNLESS SPECIFIED OTHERWISE." "L" "S-TEXT")
  (draw_text (list tx (- ny 35.0) 0.0) 9.0 "2. CLEAR SPANS AND COLUMN SHAFTS CORRESPOND TO ARRANGE DRAWING ALIGNMENT." "L" "S-TEXT")
  (draw_text (list tx (- ny 50.0) 0.0) 9.0 "3. CONCRETE GRADE SHIPPED SHALL CONFORM TO M25 (25 MPa CHARACTERISTIC COMPRESSIVE STRENGTH)." "L" "S-TEXT")
  (draw_text (list tx (- ny 65.0) 0.0) 9.0 "4. STEEL BARS REINFORCED SHALL COMPLY WITH Fe 500 TMT AS PER DESIGN IS 1786." "L" "S-TEXT")
  (draw_text (list tx (- ny 80.0) 0.0) 9.0 "5. LAP LENGTHS SHALL BE MAINTAINED AT A MINIMUM OF 50 * BAR DIAMETER (50d)." "L" "S-TEXT")
  (draw_text (list tx (- ny 95.0) 0.0) 9.0 "6. STIRRUP / TIE HOOKS MUST BEND AT 135 DEGREES IN ACCORDANCE WITH DUCTILE DETAILING." "L" "S-TEXT")
  (draw_text (list tx (- ny 110.0) 0.0) 9.0 "7. ENSURE DUST COMPACTING AND VIBRATORS ARE USED DURING PLINTH POURING." "L" "S-TEXT")
  
  ;; Sheet Main Title Header
  (draw_text (list 240.0 680.0 0.0) 24.0 "RCC CENTRE LINE GRID PLAN & REINFORCEMENT DETAILS" "C" "S-TEXT")
  (draw_text (list 240.0 655.0 0.0) 12.0 "BUILDING SPAN: 40'-0\" x 50'-0\" | STRUCTURAL DESIGN SHEET S-01" "C" "S-TEXT")

  ;; Restoring workspace settings
  (setvar "CLAYER" oldClayer)
  (setvar "CMDECHO" oldCmdEcho)
  (setvar "OSMODE" oldOsmode)
  (setvar "HPNAME" oldHpname)
  (princ "\n\nSuccess! RCC Structural Grid Sheet with Reinforcement Schedule generated.")
  (princ "\nType DRAW_STRUCTURAL_SHEET to draw again.")
  (princ)
)

(princ "\nType DRAW_STRUCTURAL_SHEET to generate structural schedule sheet.\n")
(princ)
