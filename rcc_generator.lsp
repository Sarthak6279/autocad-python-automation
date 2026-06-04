;;; rcc_generator.lsp - Generates an RCC Structural Drawing for a 40x50 Floor Plan
;;;
;;; Features:
;;; 1. Supports Imperial units (40' x 50' with columns in inches) or Decimal units (40 x 50).
;;; 2. Creates professional layers with custom colors: Grid, Slab, Columns, Beams, Text, and Dimensions.
;;; 3. Automatically calculates grid lines and intersections:
;;;    - X-Grids: 0, 14', 28', 40' (A, B, C, D)
;;;    - Y-Grids: 0, 15', 30', 50' (1, 2, 3, 4)
;;; 4. Draws 9"x12" concrete columns at all intersections with SOLID hatching.
;;; 5. Draws 9"-wide structural beams connecting all columns.
;;; 6. Places text labels for Grid IDs and titles.
;;; 7. Creates automated linear dimensions for grid intervals and overall dimensions.
;;;
;;; To load: (load "C:/Users/sarth/.gemini/antigravity-ide/scratch/autocad-lisp-scripts/rcc_generator.lsp")
;;; Run command: DRAW_RCC

(defun c:draw_rcc ( / 
                   ;; System variables
                   oldCmdEcho oldOsmode oldLuprec
                   ;; Options & Config
                   unitOpt unitScale width height colW colH beamW textH dimOffset gridExt
                   ;; Grid lists
                   xGrid yGrid xLabels yLabels
                   ;; Iterators
                   i j x y pt p1 p2 textPt dimPt colRect hatchEnt
                   )
  
  ;; Save system variables
  (setq oldCmdEcho (getvar "CMDECHO"))
  (setq oldOsmode (getvar "OSMODE"))
  (setq oldLuprec (getvar "LUPREC"))
  (setq oldHpname (getvar "HPNAME"))
  
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0) ; Disable Osnap during drawing to avoid snapping issues
  (setvar "HPNAME" "SOLID")
  
  ;; 1. Choose Unit System
  (initget "Imperial Decimal")
  (setq unitOpt (getkword "\nSelect drawing units: [Imperial (Feet/Inches) / Decimal (40x50 units)] <Imperial>: "))
  (if (not unitOpt) (setq unitOpt "Imperial"))
  
  ;; Configure parameters based on units
  (if (= unitOpt "Imperial")
    (progn
      ;; Imperial configuration: 1 unit = 1 inch
      ;; 40 feet = 480 inches, 50 feet = 600 inches
      (setq unitScale 12.0)
      (setq width 480.0)
      (setq height 600.0)
      ;; Grid lines in inches
      (setq xGrid '(0.0 168.0 336.0 480.0))  ; 0', 14', 28', 40'
      (setq yGrid '(0.0 180.0 360.0 600.0))  ; 0', 15', 30', 50'
      ;; Structural sizes in inches
      (setq colW 9.0)   ; Column width (X)
      (setq colH 12.0)  ; Column height (Y)
      (setq beamW 9.0)  ; Beam width (9 inches)
      (setq textH 12.0) ; Text height (12 inches)
      (setq dimOffset 48.0) ; Dimension line offset (4 feet)
      (setq gridExt 36.0)   ; Grid extension line length (3 feet)
      (princ "\nDrawing configured in Imperial Units (inches).")
    )
    (progn
      ;; Decimal configuration: 1 unit = 1 foot (or generic decimal units)
      (setq unitScale 1.0)
      (setq width 40.0)
      (setq height 50.0)
      ;; Grid lines in decimal units
      (setq xGrid '(0.0 14.0 28.0 40.0))
      (setq yGrid '(0.0 15.0 30.0 50.0))
      ;; Structural sizes in decimal units
      (setq colW 0.75)   ; Column width (9 inches = 0.75 ft)
      (setq colH 1.00)   ; Column height (12 inches = 1.0 ft)
      (setq beamW 0.75)  ; Beam width
      (setq textH 1.0)   ; Text height
      (setq dimOffset 4.0)  ; Dimension line offset
      (setq gridExt 3.0)    ; Grid extension
      (princ "\nDrawing configured in Decimal Units.")
    )
  )
  
  (setq xLabels '("A" "B" "C" "D"))
  (setq yLabels '("1" "2" "3" "4"))

  ;; 2. Create Layers
  (princ "\nCreating structural layers...")
  (command "_.layer" "_make" "S-GRID" "_color" "8" "S-GRID" "") ; Gray grids
  (command "_.layer" "_make" "S-SLAB" "_color" "4" "S-SLAB" "") ; Cyan slab boundary
  (command "_.layer" "_make" "S-COLUMN" "_color" "1" "S-COLUMN" "") ; Red columns
  (command "_.layer" "_make" "S-HATCH" "_color" "9" "S-HATCH" "") ; Dark gray hatching
  (command "_.layer" "_make" "S-BEAM" "_color" "2" "S-BEAM" "") ; Yellow beams
  (command "_.layer" "_make" "S-TEXT" "_color" "3" "S-TEXT" "") ; Green text
  (command "_.layer" "_make" "S-DIM" "_color" "5" "S-DIM" "") ; Magenta dimensions
  
  ;; 3. Draw Slab Boundary
  (princ "\nDrawing outer slab boundary...")
  (setvar "CLAYER" "S-SLAB")
  (command "_.rectang" (list 0.0 0.0) (list width height))
  
  ;; 4. Draw Grid Lines
  (princ "\nDrawing grid lines...")
  (setvar "CLAYER" "S-GRID")
  
  ;; Vertical Grid Lines
  (foreach x xGrid
    (setq p1 (list x (- gridExt) 0.0))
    (setq p2 (list x (+ height gridExt) 0.0))
    (command "_.line" p1 p2 "")
  )
  
  ;; Horizontal Grid Lines
  (foreach y yGrid
    (setq p1 (list (- gridExt) y 0.0))
    (setq p2 (list (+ width gridExt) y 0.0))
    (command "_.line" p1 p2 "")
  )
  
  ;; 5. Draw Beams (as 9" wide framing enclosing the grid lines)
  (princ "\nDrawing structural beams...")
  (setvar "CLAYER" "S-BEAM")
  (setq halfBeam (/ beamW 2.0))
  
  ;; Vertical Beams (Double lines offset from grid lines)
  (foreach x xGrid
    ;; Left beam boundary line
    (command "_.line" (list (- x halfBeam) 0.0) (list (- x halfBeam) height) "")
    ;; Right beam boundary line
    (command "_.line" (list (+ x halfBeam) 0.0) (list (+ x halfBeam) height) "")
  )
  
  ;; Horizontal Beams (Double lines offset from grid lines)
  (foreach y yGrid
    ;; Bottom beam boundary line
    (command "_.line" (list 0.0 (- y halfBeam)) (list width (- y halfBeam)) "")
    ;; Top beam boundary line
    (command "_.line" (list 0.0 (+ y halfBeam)) (list width (+ y halfBeam)) "")
  )
  
  ;; 6. Draw Columns & Hatching at intersections
  (princ "\nDrawing columns and solid concrete hatching...")
  
  (setq i 0)
  (foreach x xGrid
    (setq j 0)
    (foreach y yGrid
      ;; 6a. Draw Column Outline
      (setvar "CLAYER" "S-COLUMN")
      (setq p1 (list (- x (/ colW 2.0)) (- y (/ colH 2.0))))
      (setq p2 (list (+ x (/ colW 2.0)) (+ y (/ colH 2.0))))
      (command "_.rectang" p1 p2)
      
      ;; Get the entity of the newly created rectangle
      (setq colRect (entlast))
      
      ;; 6b. Apply Solid Hatching
      (setvar "CLAYER" "S-HATCH")
      (command "_.-hatch" "_select" colRect "" "")
      
      ;; 6c. Add Column Labels (e.g., C1, C2...)
      (setvar "CLAYER" "S-TEXT")
      (setq labelStr (strcat "C" (itoa (+ (* i (length yGrid)) j 1))))
      (setq textPt (list (+ x (/ colW 1.5)) (+ y (/ colH 1.5))))
      (entmake (list
                 '(0 . "TEXT")
                 (cons 10 textPt)
                 (cons 40 (/ textH 1.5))
                 (cons 1 labelStr)
                 (cons 8 "S-TEXT")
               ))
      
      (setq j (1+ j))
    )
    (setq i (1+ i))
  )
  
  ;; 7. Place Grid bubble texts
  (princ "\nPlacing grid labels...")
  (setvar "CLAYER" "S-TEXT")
  
  ;; Vertical Grid Labels (A, B, C, D) at top
  (setq i 0)
  (foreach x xGrid
    (setq textPt (list x (+ height gridExt (/ textH 2.0))))
    (entmake (list
               '(0 . "TEXT")
               (cons 10 (list (- (car textPt) (/ textH 4.0)) (cadr textPt))) ; Center text offset
               (cons 40 textH)
               (cons 1 (nth i xLabels))
               (cons 8 "S-TEXT")
             ))
    (setq i (1+ i))
  )
  
  ;; Horizontal Grid Labels (1, 2, 3, 4) at left
  (setq j 0)
  (foreach y yGrid
    (setq textPt (list (- (- gridExt) (/ textH 1.5)) y))
    (entmake (list
               '(0 . "TEXT")
               (cons 10 (list (- (car textPt) (/ textH 4.0)) (- (cadr textPt) (/ textH 2.0))))
               (cons 40 textH)
               (cons 1 (nth j yLabels))
               (cons 8 "S-TEXT")
             ))
    (setq j (1+ j))
  )
  
  ;; 8. Add Dimensions
  (princ "\nAdding dimensions...")
  (setvar "CLAYER" "S-DIM")
  
  ;; Horizontal Overall Dimension
  (command "_.dimlinear" (list 0.0 0.0) (list width 0.0) (list (/ width 2.0) (- (- dimOffset) (/ textH 2.0))))
  
  ;; Horizontal Grid Interval Dimensions
  (setq i 0)
  (while (< i (1- (length xGrid)))
    (setq p1 (list (nth i xGrid) 0.0))
    (setq p2 (list (nth (1+ i) xGrid) 0.0))
    (setq dimPt (list (/ (+ (car p1) (car p2)) 2.0) (- (/ dimOffset 2.0))))
    (command "_.dimlinear" p1 p2 dimPt)
    (setq i (1+ i))
  )
  
  ;; Vertical Overall Dimension
  (command "_.dimlinear" (list 0.0 0.0) (list 0.0 height) (list (- (- dimOffset) (/ textH 2.0)) (/ height 2.0)))
  
  ;; Vertical Grid Interval Dimensions
  (setq j 0)
  (while (< j (1- (length yGrid)))
    (setq p1 (list 0.0 (nth j yGrid)))
    (setq p2 (list 0.0 (nth (1+ j) yGrid)))
    (setq dimPt (list (- (/ dimOffset 2.0)) (/ (+ (cadr p1) (cadr p2)) 2.0)))
    (command "_.dimlinear" p1 p2 dimPt)
    (setq j (1+ j))
  )
  
  ;; 9. Add Drawing Title Block Text
  (setvar "CLAYER" "S-TEXT")
  (setq textPt (list (/ width 2.0) (+ height (* gridExt 2.0))))
  (entmake (list
             '(0 . "TEXT")
             (cons 10 (list (- (car textPt) (* textH 5)) (cadr textPt)))
             (cons 40 (* textH 1.5))
             (cons 1 "RCC BEAM & COLUMN GRID LAYOUT PLAN")
             (cons 8 "S-TEXT")
           ))
  (entmake (list
             '(0 . "TEXT")
             (cons 10 (list (- (car textPt) (* textH 3)) (- (cadr textPt) (* textH 1.5))))
             (cons 40 textH)
             (cons 1 (strcat "BUILDING SIZE: 40' x 50' (" unitOpt " Units)"))
             (cons 8 "S-TEXT")
           ))
  
  ;; Clean exit and restore settings
  (setvar "CMDECHO" oldCmdEcho)
  (setvar "OSMODE" oldOsmode)
  (setvar "LUPREC" oldLuprec)
  (setvar "HPNAME" oldHpname)
  (princ "\n\nSuccess! RCC Structural Plan generated successfully on standard layers.")
  (princ "\nType DRAW_RCC to run again or change unit settings.")
  (princ)
)

(princ "\nType DRAW_RCC to run the RCC drawing generator.\n")
(princ)
