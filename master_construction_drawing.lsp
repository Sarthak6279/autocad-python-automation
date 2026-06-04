;;; master_construction_drawing.lsp - Complete Construction Working Drawing Sheet (40' x 50')
;;;
;;; Combines:
;;; 1. Full Architectural Floor Plan: Walls (9" ext, 4.5" int), doors with swings, windows with sills,
;;;    dog-legged staircase, kitchen platform with gas/sink, bathroom WC fittings, and OTS ventilation shafts.
;;; 2. Structural Steel Detailing: 17 columns (9"x12") placed precisely in wall junctions, hatched solid,
;;;    labeled C1 to C17.
;;; 3. Centre Line Grid: Dashed centerlines (Grids A-F, 1-4) passing through column centers with labeled bubbles.
;;; 4. Framing Plan: Yellow framing lines representing structural beams connecting column nodes.
;;; 5. Dimensions: Complete horizontal and vertical grid spacing dimensions + overall plot size dimensions.
;;; 6. Structural Schedule Table: Detailed rebar schedules (Main bars, stirrups, footing size, concrete grade).
;;; 7. Site General Notes: Standard civil engineering specifications.
;;;
;;; To load: (load "C:/Users/sarth/.gemini/antigravity-ide/scratch/autocad-lisp-scripts/master_construction_drawing.lsp")
;;; Run command: DRAW_MASTER_PLAN

(defun c:draw_master_plan ( / 
                           ;; System state
                           oldCmdEcho oldOsmode oldClayer oldHpname
                           ;; Grid parameters
                           w h extW intW textH gridExt
                           xGrid yGrid xLabels yLabels
                           ;; Table parameters
                           tx ty th ny
                           ;; Helpers
                           draw_wall_line draw_column draw_window draw_ventilator
                           draw_door draw_staircase draw_wc draw_sink draw_stove
                           draw_line draw_rect draw_circle draw_text draw_table_cell
                           apply_solid_hatch
                           )
  
  ;; Save state
  (setq oldCmdEcho (getvar "CMDECHO"))
  (setq oldOsmode (getvar "OSMODE"))
  (setq oldClayer (getvar "CLAYER"))
  (setq oldHpname (getvar "HPNAME"))
  
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0) ; Disable OSNAPs
  
  ;; Dimensions (40' x 50' in inches = 480" x 600")
  (setq w 480.0)
  (setq h 600.0)
  (setq extW 9.0)
  (setq intW 4.5)
  (setq textH 10.0)
  (setq gridExt 48.0) ; 4 feet grid lines extension outside columns
  
  ;; Column center intersections:
  (setq xGrid '(9.0 190.0 250.0 290.0 330.0 471.0)) ; Grids A, B, C, D, E, F
  (setq yGrid '(9.0 210.0 420.0 591.0))            ; Grids 1, 2, 3, 4
  (setq xLabels '("A" "B" "C" "D" "E" "F"))
  (setq yLabels '("1" "2" "3" "4"))

  ;; Load CENTER linetype safely
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
             "_make" "A-WALL-EXT"    "_color" "7" "A-WALL-EXT"
             "_make" "A-WALL-INT"    "_color" "9" "A-WALL-INT"
             "_make" "A-COLUMN"      "_color" "1" "A-COLUMN"
             "_make" "A-COL-HATCH"   "_color" "251" "A-COL-HATCH"
             "_make" "A-DOOR"        "_color" "30" "A-DOOR"
             "_make" "A-WINDOW"      "_color" "4" "A-WINDOW"
             "_make" "A-STAIR"       "_color" "6" "A-STAIR"
             "_make" "A-FIXTURE"     "_color" "8" "A-FIXTURE"
             "_make" "A-TEXT"        "_color" "2" "A-TEXT"
             "_make" "A-DIM"         "_color" "5" "A-DIM"
             "_make" "S-GRID-CENTER" "_color" "8" "S-GRID-CENTER" "_ltype" "CENTER" "S-GRID-CENTER"
             "_make" "S-BUBBLE"      "_color" "4" "S-BUBBLE"
             "_make" "S-BEAM-FRAMING" "_color" "2" "S-BEAM-FRAMING"
             "_make" "S-TABLE"       "_color" "7" "S-TABLE"
             "_make" "S-TEXT"        "_color" "3" "S-TEXT"
             "")
    (command "_.layer" 
             "_make" "A-WALL-EXT"    "_color" "7" "A-WALL-EXT"
             "_make" "A-WALL-INT"    "_color" "9" "A-WALL-INT"
             "_make" "A-COLUMN"      "_color" "1" "A-COLUMN"
             "_make" "A-COL-HATCH"   "_color" "251" "A-COL-HATCH"
             "_make" "A-DOOR"        "_color" "30" "A-DOOR"
             "_make" "A-WINDOW"      "_color" "4" "A-WINDOW"
             "_make" "A-STAIR"       "_color" "6" "A-STAIR"
             "_make" "A-FIXTURE"     "_color" "8" "A-FIXTURE"
             "_make" "A-TEXT"        "_color" "2" "A-TEXT"
             "_make" "A-DIM"         "_color" "5" "A-DIM"
             "_make" "S-GRID-CENTER" "_color" "8" "S-GRID-CENTER"
             "_make" "S-BUBBLE"      "_color" "4" "S-BUBBLE"
             "_make" "S-BEAM-FRAMING" "_color" "2" "S-BEAM-FRAMING"
             "_make" "S-TABLE"       "_color" "7" "S-TABLE"
             "_make" "S-TEXT"        "_color" "3" "S-TEXT"
             "")
  )
  (while (> (getvar "CMDACTIVE") 0) (command ""))

  ;; Set Hatch pattern
  (setvar "HPNAME" "SOLID")

  ;; --- SUBROUTINES / DRAWING HELPERS ---
  
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

  (defun draw_table_cell (x y w h txt alignment)
    (setvar "CLAYER" "S-TABLE")
    (draw_rect (list x y 0.0) (list (+ x w) (+ y h) 0.0) "S-TABLE")
    (draw_text (list (+ x (/ w 2.0)) (+ y (/ h 2.0) -3.0) 0.0) 8.0 txt alignment "S-TEXT")
  )

  (defun apply_solid_hatch (ent)
    (setvar "CLAYER" "A-COL-HATCH")
    (command "_.-hatch" "_select" ent "")
    (while (> (getvar "CMDACTIVE") 0) (command ""))
  )
  
  ;; Draw Column Outline & Hatch
  (defun draw_column (cx cy col_w col_h labelStr / p1 p2)
    (setvar "CLAYER" "A-COLUMN")
    (setq p1 (list (- cx (/ col_w 2.0)) (- cy (/ col_h 2.0)) 0.0))
    (setq p2 (list (+ cx (/ col_w 2.0)) (+ cy (/ col_h 2.0)) 0.0))
    (command "_.rectang" p1 p2)
    (while (> (getvar "CMDACTIVE") 0) (command ""))
    (apply_solid_hatch (entlast))
    ;; Column ID annotation
    (draw_text (list cx (+ cy (/ col_h 1.2)) 0.0) 6.0 labelStr "C" "A-TEXT")
  )
  
  ;; Draw Window (glazing line, sill line, frame box)
  (defun draw_window (cx cy size orient / p1 p2)
    (setvar "CLAYER" "A-WINDOW")
    (if (= orient "H")
      (progn
        (setq p1 (list (- cx (/ size 2.0)) (- cy 4.5) 0.0))
        (setq p2 (list (+ cx (/ size 2.0)) (+ cy 4.5) 0.0))
        (command "_.rectang" p1 p2)
        (while (> (getvar "CMDACTIVE") 0) (command ""))
        (draw_line (list (- cx (/ size 2.0)) cy 0.0) (list (+ cx (/ size 2.0)) cy 0.0) "A-WINDOW")
        (draw_line (list (- cx (/ size 2.0)) (- cy 6.0) 0.0) (list (+ cx (/ size 2.0)) (- cy 6.0) 0.0) "A-WINDOW") ; Sill line
      )
      (progn
        (setq p1 (list (- cx 4.5) (- cy (/ size 2.0)) 0.0))
        (setq p2 (list (+ cx 4.5) (+ cy (/ size 2.0)) 0.0))
        (command "_.rectang" p1 p2)
        (while (> (getvar "CMDACTIVE") 0) (command ""))
        (draw_line (list cx (- cy (/ size 2.0)) 0.0) (list cx (+ cy (/ size 2.0)) 0.0) "A-WINDOW")
        (draw_line (list (- cx 6.0) (- cy (/ size 2.0)) 0.0) (list (- cx 6.0) (+ cy (/ size 2.0)) 0.0) "A-WINDOW") ; Sill line
      )
    )
  )
  
  ;; Draw Ventilator
  (defun draw_ventilator (cx cy size orient / p1 p2)
    (setvar "CLAYER" "A-WINDOW")
    (if (= orient "H")
      (progn
        (setq p1 (list (- cx (/ size 2.0)) (- cy 2.25) 0.0))
        (setq p2 (list (+ cx (/ size 2.0)) (+ cy 2.25) 0.0))
        (command "_.rectang" p1 p2)
        (while (> (getvar "CMDACTIVE") 0) (command ""))
        (draw_line p1 p2 "A-WINDOW")
      )
      (progn
        (setq p1 (list (- cx 2.25) (- cy (/ size 2.0)) 0.0))
        (setq p2 (list (+ cx 2.25) (+ cy (/ size 2.0)) 0.0))
        (command "_.rectang" p1 p2)
        (while (> (getvar "CMDACTIVE") 0) (command ""))
        (draw_line p1 p2 "A-WINDOW")
      )
    )
  )
  
  ;; Draw Door (Frame + swing arc)
  (defun draw_door (pt size dir / pEnd pArcStart)
    (setvar "CLAYER" "A-DOOR")
    (cond
      ((= dir "NW")
       (setq pEnd (list (car pt) (+ (cadr pt) size) 0.0))
       (setq pArcStart (list (- (car pt) size) (cadr pt) 0.0))
       (command "_.rectang" (list (- (car pt) 2.0) (cadr pt) 0.0) (list (car pt) (+ (cadr pt) size) 0.0))
       (while (> (getvar "CMDACTIVE") 0) (command ""))
       (command "_.arc" "_c" pt pEnd pArcStart)
       (while (> (getvar "CMDACTIVE") 0) (command ""))
      )
      ((= dir "NE")
       (setq pEnd (list (car pt) (+ (cadr pt) size) 0.0))
       (setq pArcStart (list (+ (car pt) size) (cadr pt) 0.0))
       (command "_.rectang" (list (car pt) (cadr pt) 0.0) (list (+ (car pt) 2.0) (+ (cadr pt) size) 0.0))
       (while (> (getvar "CMDACTIVE") 0) (command ""))
       (command "_.arc" "_c" pt pArcStart pEnd)
       (while (> (getvar "CMDACTIVE") 0) (command ""))
      )
      ((= dir "SE")
       (setq pEnd (list (car pt) (- (cadr pt) size) 0.0))
       (setq pArcStart (list (+ (car pt) size) (cadr pt) 0.0))
       (command "_.rectang" (list (car pt) (- (cadr pt) size) 0.0) (list (+ (car pt) 2.0) (cadr pt) 0.0))
       (while (> (getvar "CMDACTIVE") 0) (command ""))
       (command "_.arc" "_c" pt pEnd pArcStart)
       (while (> (getvar "CMDACTIVE") 0) (command ""))
      )
      ((= dir "SW")
       (setq pEnd (list (car pt) (- (cadr pt) size) 0.0))
       (setq pArcStart (list (- (car pt) size) (cadr pt) 0.0))
       (command "_.rectang" (list (- (car pt) 2.0) (- (cadr pt) size) 0.0) (list (car pt) (cadr pt) 0.0))
       (while (> (getvar "CMDACTIVE") 0) (command ""))
       (command "_.arc" "_c" pt pArcStart pEnd)
       (while (> (getvar "CMDACTIVE") 0) (command ""))
      )
    )
  )

  ;; Draw Dog-legged Staircase
  (defun draw_staircase (sx sy sw sl / landingW stepW stepD numSteps i yPos)
    (setvar "CLAYER" "A-STAIR")
    (setq landingW 42.0) ; 3'6" landing width
    (setq stepW 39.0)    ; 3'3" flight width
    (setq stepD 10.0)    ; 10" tread depth
    (setq numSteps 10)
    
    (draw_rect (list sx sy 0.0) (list (+ sx sw) (+ sy sl) 0.0) "A-STAIR")
    (draw_line (list sx (- (+ sy sl) landingW) 0.0) (list (+ sx sw) (- (+ sy sl) landingW) 0.0) "A-STAIR")
    (draw_line (list (+ sx (/ sw 2.0)) sy 0.0) (list (+ sx (/ sw 2.0)) (- (+ sy sl) landingW) 0.0) "A-STAIR")
    
    (setq i 0)
    (while (< i numSteps)
      (setq yPos (+ sy (* i stepD)))
      (draw_line (list sx yPos 0.0) (list (+ sx stepW) yPos 0.0) "A-STAIR")
      (draw_line (list (- (+ sx sw) stepW) yPos 0.0) (list (+ sx sw) yPos 0.0) "A-STAIR")
      (setq i (1+ i))
    )
    
    ;; Arrow line indicators
    (draw_circle (list (+ sx (/ stepW 2.0)) (+ sy 5.0) 0.0) 3.0 "A-STAIR")
    (command "_.line" 
             (list (+ sx (/ stepW 2.0)) (+ sy 5.0) 0.0) 
             (list (+ sx (/ stepW 2.0)) (- (+ sy sl) (/ landingW 2.0)) 0.0)
             (list (- (+ sx sw) (/ stepW 2.0)) (- (+ sy sl) (/ landingW 2.0)) 0.0)
             (list (- (+ sx sw) (/ stepW 2.0)) (+ sy 15.0) 0.0)
             "")
    (while (> (getvar "CMDACTIVE") 0) (command ""))
    ;; Arrowhead
    (draw_line (list (- (+ sx sw) (/ stepW 2.0)) (+ sy 15.0) 0.0) (list (- (- (+ sx sw) (/ stepW 2.0)) 3.0) (+ sy 20.0) 0.0) "A-STAIR")
    (draw_line (list (- (+ sx sw) (/ stepW 2.0)) (+ sy 15.0) 0.0) (list (+ (- (+ sx sw) (/ stepW 2.0)) 3.0) (+ sy 20.0) 0.0) "A-STAIR")
    
    (draw_text (list (+ sx (/ sw 2.0) -6.0) (+ sy 15.0) 0.0) (* textH 0.8) "UP" "L" "A-TEXT")
  )

  ;; Draw WC Closet fitting
  (defun draw_wc (cx cy orient / pTank1 pTank2)
    (setvar "CLAYER" "A-FIXTURE")
    (if (= orient "N")
      (progn
        (setq pTank1 (list (- cx 10.0) (- cy 4.0) 0.0))
        (setq pTank2 (list (+ cx 10.0) (+ cy 4.0) 0.0))
        (draw_rect pTank1 pTank2 "A-FIXTURE")
        (command "_.ellipse" "_c" (list cx (+ cy 10.0) 0.0) (list (+ cx 7.0) (+ cy 10.0) 0.0) (list cx (+ cy 18.0) 0.0))
        (while (> (getvar "CMDACTIVE") 0) (command ""))
      )
      (progn
        (setq pTank1 (list (- cx 4.0) (- cy 10.0) 0.0))
        (setq pTank2 (list (+ cx 4.0) (+ cy 10.0) 0.0))
        (draw_rect pTank1 pTank2 "A-FIXTURE")
        (command "_.ellipse" "_c" (list (+ cx 10.0) cy 0.0) (list (+ cx 10.0) (+ cy 7.0) 0.0) (list (+ cx 18.0) cy 0.0))
        (while (> (getvar "CMDACTIVE") 0) (command ""))
      )
    )
  )

  ;; Draw washbasin sink fitting
  (defun draw_sink (cx cy / p1 p2)
    (setvar "CLAYER" "A-FIXTURE")
    (setq p1 (list (- cx 12.0) (- cy 9.0) 0.0))
    (setq p2 (list (+ cx 12.0) (+ cy 9.0) 0.0))
    (draw_rect p1 p2 "A-FIXTURE")
    (draw_rect (list (- cx 10.0) (- cy 7.0) 0.0) (list (+ cx 10.0) (+ cy 7.0) 0.0) "A-FIXTURE")
    (draw_circle (list cx cy 0.0) 1.5 "A-FIXTURE")
  )

  ;; Draw cooking platform stove burners
  (defun draw_stove (cx cy)
    (setvar "CLAYER" "A-FIXTURE")
    (draw_rect (list (- cx 15.0) (- cy 10.0) 0.0) (list (+ cx 15.0) (+ cy 10.0) 0.0) "A-FIXTURE")
    (draw_circle (list (- cx 7.0) cy 0.0) 4.0 "A-FIXTURE")
    (draw_circle (list (- cx 7.0) cy 0.0) 1.5 "A-FIXTURE")
    (draw_circle (list (+ cx 7.0) cy 0.0) 4.0 "A-FIXTURE")
    (draw_circle (list (+ cx 7.0) cy 0.0) 1.5 "A-FIXTURE")
  )

  (defun draw_room_label (pt line1 line2)
    (draw_text (list (- (car pt) (* textH 3.0)) (+ (cadr pt) (/ textH 2.0)) 0.0) textH line1 "L" "A-TEXT")
    (draw_text (list (- (car pt) (* textH 2.5)) (- (cadr pt) (/ textH 1.2)) 0.0) (* textH 0.8) line2 "L" "A-TEXT")
  )

  ;; --- 1. ARCHITECTURAL EXTERIOR WALLS (9" THICK) ---
  (princ "\nDrawing exterior walls...")
  (draw_rect (list 0.0 0.0 0.0) (list w h 0.0) "A-WALL-EXT")
  (draw_rect (list extW extW 0.0) (list (- w extW) (- h extW) 0.0) "A-WALL-EXT")

  ;; --- 2. ARCHITECTURAL INTERNAL WALL LAYOUT ---
  (princ "\nDrawing internal partitions...")
  
  ;; Rear Horizontal Wall (Y = 420)
  (draw_line (list extW 420.0 0.0) (list (- w extW) 420.0 0.0) "A-WALL-INT")
  (draw_line (list extW (- 420.0 intW) 0.0) (list (- w extW) (- 420.0 intW) 0.0) "A-WALL-INT")
  
  ;; Bedroom 2 & 3 Split (X = 250, Y = 420 to 591)
  (draw_line (list 250.0 420.0 0.0) (list 250.0 (- h extW) 0.0) "A-WALL-INT")
  (draw_line (list (+ 250.0 intW) 420.0 0.0) (list (+ 250.0 intW) (- h extW) 0.0) "A-WALL-INT")
  
  ;; Attached Bath-3 (X = 9 to 90, Y = 490)
  (draw_line (list extW 490.0 0.0) (list 90.0 490.0 0.0) "A-WALL-INT")
  (draw_line (list extW (- 490.0 intW) 0.0) (list 90.0 (- 490.0 intW) 0.0) "A-WALL-INT")
  (draw_line (list 90.0 420.0 0.0) (list 90.0 490.0 0.0) "A-WALL-INT")
  (draw_line (list (- 90.0 intW) 420.0 0.0) (list (- 90.0 intW) 490.0 0.0) "A-WALL-INT")

  ;; Middle Area (Y = 210 to 420)
  ;; Bedroom 1 Bottom Wall (Y = 210, X = 9 to 190)
  (draw_line (list extW 210.0 0.0) (list 190.0 210.0 0.0) "A-WALL-INT")
  (draw_line (list extW (- 210.0 intW) 0.0) (list 190.0 (- 210.0 intW) 0.0) "A-WALL-INT")
  
  ;; Bedroom 1 Right Partition Wall (X = 190, Y = 210 to 420)
  (draw_line (list 190.0 210.0 0.0) (list 190.0 420.0 0.0) "A-WALL-INT")
  (draw_line (list (+ 190.0 intW) 210.0 0.0) (list (+ 190.0 intW) 420.0 0.0) "A-WALL-INT")
  
  ;; Attached Bath-2 (X = 9 to 85, Y = 330)
  (draw_line (list extW 330.0 0.0) (list 85.0 330.0 0.0) "A-WALL-INT")
  (draw_line (list extW (- 330.0 intW) 0.0) (list 85.0 (- 330.0 intW) 0.0) "A-WALL-INT")
  (draw_line (list 85.0 330.0 0.0) (list 85.0 420.0 0.0) "A-WALL-INT")
  (draw_line (list (- 85.0 intW) 330.0 0.0) (list (- 85.0 intW) 420.0 0.0) "A-WALL-INT")

  ;; Kitchen Partition Wall (X = 330, Y = 210 to 420)
  (draw_line (list 330.0 210.0 0.0) (list 330.0 420.0 0.0) "A-WALL-INT")
  (draw_line (list (+ 330.0 intW) 210.0 0.0) (list (+ 330.0 intW) 420.0 0.0) "A-WALL-INT")
  
  ;; Common Bath 1 Wall (X = 290, Y = 9 to 210)
  (draw_line (list 290.0 extW 0.0) (list 290.0 210.0 0.0) "A-WALL-INT")
  (draw_line (list (+ 290.0 intW) extW 0.0) (list (+ 290.0 intW) 210.0 0.0) "A-WALL-INT")
  ;; Common Bath Front Wall (Y = 110, X = 290 to 360)
  (draw_line (list 290.0 110.0 0.0) (list 360.0 110.0 0.0) "A-WALL-INT")
  (draw_line (list 290.0 (- 110.0 intW) 0.0) (list 360.0 (- 110.0 intW) 0.0) "A-WALL-INT")
  (draw_line (list 360.0 110.0 0.0) (list 360.0 210.0 0.0) "A-WALL-INT")
  (draw_line (list (- 360.0 intW) 110.0 0.0) (list (- 360.0 intW) 210.0 0.0) "A-WALL-INT")

  ;; Entrance Porch Pillars/Beams
  (draw_line (list 360.0 90.0 0.0) (list (- w extW) 90.0 0.0) "A-WALL-EXT")
  (draw_line (list 360.0 (- 90.0 extW) 0.0) (list (- w extW) (- 90.0 extW) 0.0) "A-WALL-EXT")
  (draw_line (list 360.0 extW 0.0) (list 360.0 90.0 0.0) "A-WALL-EXT")
  (draw_line (list (- 360.0 extW) extW 0.0) (list (- 360.0 extW) 90.0 0.0) "A-WALL-EXT")

  ;; OTS Ventilation shaft (Duct) (X = 9 to 45, Y = 405 to 435)
  (draw_line (list extW 405.0 0.0) (list 45.0 405.0 0.0) "A-WALL-INT")
  (draw_line (list 45.0 405.0 0.0) (list 45.0 435.0 0.0) "A-WALL-INT")
  (draw_line (list extW 435.0 0.0) (list 45.0 435.0 0.0) "A-WALL-INT")
  (draw_line (list extW 405.0 0.0) (list 45.0 435.0 0.0) "A-WALL-INT")
  (draw_line (list extW 435.0 0.0) (list 45.0 405.0 0.0) "A-WALL-INT")
  (draw_text (list (+ extW 5.0) (+ 405.0 12.0) 0.0) (* textH 0.5) "O.T.S." "L" "A-TEXT")

  ;; --- 3. DETAILED DOORS ---
  (princ "\nDrawing doors...")
  (draw_door (list 295.0 110.0) 36.0 "SE")
  (draw_line (list 190.0 210.0 0.0) (list 230.0 210.0 0.0) "A-DOOR")
  (draw_door (list 200.0 420.0) 36.0 "NW")
  (draw_door (list 85.0 420.0) 30.0 "NE")
  (draw_door (list 255.0 420.0) 36.0 "NE")
  (draw_door (list 190.0 250.0) 36.0 "SW")
  (draw_door (list 80.0 420.0) 30.0 "SE")
  (draw_door (list 290.0 175.0) 30.0 "NE")

  ;; --- 4. DETAILED WINDOWS ---
  (princ "\nDrawing window pane systems...")
  (draw_window 9.0 110.0 60.0 "V")
  (draw_window 120.0 591.0 48.0 "H")
  (draw_window 360.0 591.0 48.0 "H")
  (draw_window 9.0 300.0 48.0 "V")
  (draw_window 471.0 320.0 48.0 "V")
  (draw_window 471.0 230.0 48.0 "V")
  
  (draw_ventilator 9.0 450.0 24.0 "V")
  (draw_ventilator 9.0 370.0 24.0 "V")
  (draw_ventilator 325.0 9.0 24.0 "H")

  ;; --- 5. FURNITURE/PLATFORM UTILITY DETAILS ---
  (princ "\nDrawing furniture platforms...")
  ;; Kitchen platform counter
  (draw_line (list 334.5 214.5 0.0) (list 358.5 214.5 0.0) "A-FIXTURE")
  (draw_line (list 358.5 214.5 0.0) (list 358.5 381.5 0.0) "A-FIXTURE")
  (draw_line (list 358.5 381.5 0.0) (list 471.0 381.5 0.0) "A-FIXTURE")
  (draw_sink 420.0 395.0)
  (draw_stove 345.5 290.0)
  
  ;; Toilets WC closets & hand washbasin sinks
  (draw_wc 30.0 470.0 "N")
  (draw_sink 70.0 475.0)
  (draw_wc 30.0 350.0 "N")
  (draw_sink 65.0 350.0)
  (draw_wc 310.0 135.0 "N")
  (draw_sink 335.0 195.0)

  ;; --- 6. STRUCTURAL STAIRCASE ---
  (princ "\nDrawing stairs...")
  (draw_staircase 194.5 214.5 91.0 120.0)

  ;; --- 7. ROOM LABELS ---
  (princ "\nAdding labels...")
  (draw_room_label (list 135.0 510.0) "MASTER BEDROOM (BED-2)" "Size: 19'-3\" x 14'-3\"")
  (draw_room_label (list 50.0 450.0) "A. BATH-3" "6'-3\" x 5'-8\"")
  (draw_room_label (list 360.0 510.0) "BEDROOM-3" "Size: 17'-11\" x 14'-3\"")
  (draw_room_label (list 135.0 330.0) "BEDROOM-1" "Size: 14'-3\" x 11'-3\"")
  (draw_room_label (list 45.0 375.0) "A. BATH-2" "5'-11\" x 6'-8\"")
  (draw_room_label (list 260.0 375.0) "HALL-2 (LOBBY/DINING)" "Size: 11'-3\" x 15'-10\"")
  (draw_room_label (list 400.0 310.0) "KITCHEN" "Size: 11'-9\" x 15'-10\"")
  (draw_room_label (list 150.0 110.0) "HALL-1 (LIVING ROOM)" "Size: 22'-7\" x 16'-0\"")
  (draw_room_label (list 325.0 160.0) "C. BATH-1" "5'-0\" x 7'-8\"")
  (draw_room_label (list 410.0 50.0) "ENTRANCE PORCH" "Size: 15'-11\" x 6'-9\"")

  ;; --- 8. STRUCTURAL BEAM FRAMING ---
  (princ "\nDrawing structural beam framing plan...")
  (foreach x xGrid
    (draw_line (list x 9.0 0.0) (list x 591.0 0.0) "S-BEAM-FRAMING")
  )
  (foreach y yGrid
    (draw_line (list 9.0 y 0.0) (list 471.0 y 0.0) "S-BEAM-FRAMING")
  )

  ;; --- 9. CIVIL ENGINEER STRUCTURAL COLUMNS (9" x 12" Hatch Solid) ---
  (princ "\nDrawing structural concrete columns...")
  (draw_column 9.0 9.0 12.0 9.0 "C1")
  (draw_column 190.0 9.0 9.0 12.0 "C2")
  (draw_column 290.0 9.0 9.0 12.0 "C3")
  (draw_column 471.0 9.0 12.0 9.0 "C4")
  
  (draw_column 9.0 210.0 12.0 9.0 "C5")
  (draw_column 190.0 210.0 9.0 12.0 "C6")
  (draw_column 290.0 210.0 9.0 12.0 "C7")
  (draw_column 330.0 210.0 9.0 12.0 "C8")
  (draw_column 471.0 210.0 12.0 9.0 "C9")
  
  (draw_column 9.0 420.0 12.0 9.0 "C10")
  (draw_column 190.0 420.0 9.0 12.0 "C11")
  (draw_column 250.0 420.0 9.0 12.0 "C12")
  (draw_column 330.0 420.0 9.0 12.0 "C13")
  (draw_column 471.0 420.0 12.0 9.0 "C14")
  
  (draw_column 9.0 591.0 12.0 9.0 "C15")
  (draw_column 250.0 591.0 9.0 12.0 "C16")
  (draw_column 471.0 591.0 12.0 9.0 "C17")

  ;; --- 10. CENTRE LINE GRID & BUBBLES ---
  (princ "\nDrawing centerline grids & bubbles...")
  (setq i 0)
  (foreach x xGrid
    (draw_line (list x (- 9.0 gridExt) 0.0) (list x (+ 591.0 gridExt) 0.0) "S-GRID-CENTER")
    (draw_circle (list x (- 9.0 gridExt 12.0) 0.0) 12.0 "S-BUBBLE")
    (draw_text (list x (- 9.0 gridExt 16.0) 0.0) 10.0 (nth i xLabels) "C" "S-TEXT")
    (draw_circle (list x (+ 591.0 gridExt 12.0) 0.0) 12.0 "S-BUBBLE")
    (draw_text (list x (+ 591.0 gridExt 8.0) 0.0) 10.0 (nth i xLabels) "C" "S-TEXT")
    (setq i (1+ i))
  )
  (setq j 0)
  (foreach y yGrid
    (draw_line (list (- 9.0 gridExt) y 0.0) (list (+ 471.0 gridExt) y 0.0) "S-GRID-CENTER")
    (draw_circle (list (- 9.0 gridExt 12.0) y 0.0) 12.0 "S-BUBBLE")
    (draw_text (list (- 9.0 gridExt 16.0) (- y 4.0) 0.0) 10.0 (nth j yLabels) "C" "S-TEXT")
    (draw_circle (list (+ 471.0 gridExt 12.0) y 0.0) 12.0 "S-BUBBLE")
    (draw_text (list (+ 471.0 gridExt 8.0) (- y 4.0) 0.0) 10.0 (nth j yLabels) "C" "S-TEXT")
    (setq j (1+ j))
  )

  ;; --- 11. GRID SPACING DIMENSIONS ---
  (princ "\nGenerating structural dimensions...")
  (setvar "CLAYER" "A-DIM")
  (setq i 0)
  (while (< i (1- (length xGrid)))
    (setq p1 (list (nth i xGrid) (- 9.0 gridExt 36.0) 0.0))
    (command "_.dimlinear" (list (nth i xGrid) 9.0 0.0) (list (nth (1+ i) xGrid) 9.0 0.0) p1)
    (while (> (getvar "CMDACTIVE") 0) (command ""))
    (setq i (1+ i))
  )
  (command "_.dimlinear" (list 9.0 9.0 0.0) (list 471.0 9.0 0.0) (list 240.0 (- 9.0 gridExt 60.0) 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  
  (setq j 0)
  (while (< j (1- (length yGrid)))
    (setq p1 (list (- 9.0 gridExt 36.0) (nth j yGrid) 0.0))
    (command "_.dimlinear" (list 9.0 (nth j yGrid) 0.0) (list 9.0 (nth (1+ j) yGrid) 0.0) p1)
    (while (> (getvar "CMDACTIVE") 0) (command ""))
    (setq j (1+ j))
  )
  (command "_.dimlinear" (list 9.0 9.0 0.0) (list 9.0 591.0 0.0) (list (- 9.0 gridExt 60.0) 300.0 0.0))
  (while (> (getvar "CMDACTIVE") 0) (command ""))

  ;; --- 12. REINFORCEMENT SCHEDULE TABLE ---
  (princ "\nGenerating schedule table...")
  (setq tx 550.0)
  (setq ty 180.0)
  (setq th 30.0)
  
  (setvar "CLAYER" "S-TABLE")
  (draw_rect (list tx (+ ty (* th 6)) 0.0) (list (+ tx 380.0) (+ ty (* th 7)) 0.0) "S-TABLE")
  (draw_text (list (+ tx 190.0) (+ ty (* th 6) 8.0) 0.0) 12.0 "RCC COLUMN & FOOTING REINFORCEMENT SCHEDULE" "C" "S-TEXT")
  
  (draw_table_cell tx (+ ty (* th 5)) 60.0 th "MARK" "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 5)) 60.0 th "SIZE (w x d)" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 5)) 120.0 th "MAIN REINFORCEMENT" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 5)) 70.0 th "TIES (LINKS)" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 5)) 70.0 th "FOOTING DETAIL" "C")
  
  (draw_table_cell tx (+ ty (* th 4)) 60.0 th "C1,C4,C15,C17" "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 4)) 60.0 th "9\" x 12\"" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 4)) 120.0 th "4 Nos - #16 + 2 Nos - #12" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 4)) 70.0 th "#8 @ 150 c/c" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 4)) 70.0 th "4'6\"x4'6\"x12\" (#12@150)" "C")

  (draw_table_cell tx (+ ty (* th 3)) 60.0 th "C2,C3,C6,C7,..." "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 3)) 60.0 th "9\" x 12\"" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 3)) 120.0 th "4 Nos - #16" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 3)) 70.0 th "#8 @ 150 c/c" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 3)) 70.0 th "4'0\"x4'0\"x12\" (#12@150)" "C")

  (draw_table_cell tx (+ ty (* th 2)) 60.0 th "C5,C8,C10,C12" "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 2)) 60.0 th "9\" x 9\"" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 2)) 120.0 th "4 Nos - #12" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 2)) 70.0 th "#8 @ 200 c/c" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 2)) 70.0 th "3'6\"x3'6\"x10\" (#10@150)" "C")

  (draw_table_cell tx (+ ty (* th 0)) 180.0 (* th 2) "CONCRETE MIX: M25 Grade\nSTEEL TYPE: Fe 500 TMT bars" "C")
  (draw_table_cell (+ tx 180.0) (+ ty (* th 0)) 200.0 (* th 2) "CLEAR COVERS:\nFooting: 50mm | Column: 40mm | Beam: 25mm" "C")

  ;; --- 13. SITE NOTES ---
  (princ "\nWriting site notes...")
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

  ;; Sheet Main Title Headers
  (draw_text (list 240.0 680.0 0.0) 24.0 "MASTER CONSTRUCTION WORKING DRAWING SET" "C" "A-TEXT")
  (draw_text (list 240.0 655.0 0.0) 12.0 "40' x 50' RESIDENTIAL PROJECT | ARCHITECTURAL & STRUCTURAL INTEGRATED SHEET" "C" "A-TEXT")

  ;; Restore state
  (setvar "CLAYER" oldClayer)
  (setvar "CMDECHO" oldCmdEcho)
  (setvar "OSMODE" oldOsmode)
  (setvar "HPNAME" oldHpname)
  (princ "\n\nSuccess! Unified Master Construction Sheet generated successfully.")
  (princ "\nType DRAW_MASTER_PLAN to regenerate.")
  (princ)
)

(princ "\nType DRAW_MASTER_PLAN to generate integrated project sheet.\n")
(princ)
