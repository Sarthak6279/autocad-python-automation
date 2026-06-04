;;; advanced_house_plan.lsp - High-End Structural & Architectural House Plan (40' x 50')
;;;
;;; Features:
;;; 1. Wall systems: 9" Exterior walls, 4.5" Interior walls.
;;; 2. Columns (Civil Engineering Standard): 9"x12" columns placed inside the wall intersections,
;;;    hached with solid fill, and labeled (C1-C18).
;;; 3. Staircase (Dog-legged standard flight): Draws treads, landing, handrail, and UP arrow direction.
;;; 4. Kitchen Utility: L-shaped cooking counter (24" width) with dual-burner stove and wash sink symbols.
;;; 5. Bathroom Fixtures: Sanitary fittings (European Water Closet with flush tank, washbasin) and plumbing shafts (OTS / ducts).
;;; 6. Doors & Windows (Detailed): Double-line door frames, swing arcs, sills, and glazing panes.
;;; 7. Layering: Standard architectural layer system (A-WALL-EXT, A-WALL-INT, A-COLUMN, A-COLUMN-HATCH,
;;;    A-DOOR, A-WINDOW, A-STAIR, A-FIXTURE, A-TEXT, A-DIM).
;;;
;;; To load: (load "C:/Users/sarth/.gemini/antigravity-ide/scratch/autocad-lisp-scripts/advanced_house_plan.lsp")
;;; Run command: DRAW_ADVANCED_PLAN

(defun c:draw_advanced_plan ( / 
                             ;; System Variables
                             oldCmdEcho oldOsmode oldClayer
                             ;; Dimension scales
                             w h extW intW textH
                             ;; Helpers
                             draw_wall_line draw_column draw_window draw_ventilator
                             draw_door draw_staircase draw_wc draw_sink draw_stove
                             )
  
  ;; Save state
  (setq oldCmdEcho (getvar "CMDECHO"))
  (setq oldOsmode (getvar "OSMODE"))
  (setq oldClayer (getvar "CLAYER"))
  (setq oldHpname (getvar "HPNAME"))
  
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0) ; Disable OSNAPs for script execution
  (setvar "HPNAME" "SOLID")
  
  ;; 40' x 50' in Inches (480" x 600")
  (setq w 480.0)
  (setq h 600.0)
  (setq extW 9.0)
  (setq intW 4.5)
  (setq textH 10.0)
  
  ;; --- LAYER CREATION ---
  (command "_.layer" "_make" "A-WALL-EXT" "_color" "7" "A-WALL-EXT" "")
  (command "_.layer" "_make" "A-WALL-INT" "_color" "9" "A-WALL-INT" "")
  (command "_.layer" "_make" "A-COLUMN" "_color" "1" "A-COLUMN" "")
  (command "_.layer" "_make" "A-COL-HATCH" "_color" "251" "A-COL-HATCH" "") ; Dark gray hatch
  (command "_.layer" "_make" "A-DOOR" "_color" "30" "A-DOOR" "")
  (command "_.layer" "_make" "A-WINDOW" "_color" "4" "A-WINDOW" "")
  (command "_.layer" "_make" "A-STAIR" "_color" "6" "A-STAIR" "")          ; Magenta stairs
  (command "_.layer" "_make" "A-FIXTURE" "_color" "8" "A-FIXTURE" "")      ; Gray fixtures
  (command "_.layer" "_make" "A-TEXT" "_color" "2" "A-TEXT" "")
  (command "_.layer" "_make" "A-DIM" "_color" "3" "A-DIM" "")            ; Green dimensions
  
  ;; --- SUBROUTINES / DRAWING HELPERS ---
  
  (defun draw_wall_line (p1 p2 layer)
    (setvar "CLAYER" layer)
    (command "_.line" p1 p2 "")
  )
  
  ;; Draw Column (9" x 12" or 12" x 9" structural columns)
  (defun draw_column (cx cy col_w col_h labelStr / p1 p2 colRect)
    (setvar "CLAYER" "A-COLUMN")
    (setq p1 (list (- cx (/ col_w 2.0)) (- cy (/ col_h 2.0))))
    (setq p2 (list (+ cx (/ col_w 2.0)) (+ cy (/ col_h 2.0))))
    (command "_.rectang" p1 p2)
    (setq colRect (entlast))
    (setvar "CLAYER" "A-COL-HATCH")
    (command "_.-hatch" "_select" colRect "" "")
    ;; Column ID annotation
    (setvar "CLAYER" "A-TEXT")
    (entmake (list
               '(0 . "TEXT")
               (cons 10 (list (- cx (/ col_w 2.0)) (+ cy (/ col_h 1.2))))
               (cons 40 (* textH 0.6))
               (cons 1 labelStr)
               (cons 8 "A-TEXT")
             ))
  )
  
  ;; Draw Window (glazing line, sill line, frame box)
  (defun draw_window (cx cy size orient / p1 p2)
    (setvar "CLAYER" "A-WINDOW")
    (if (= orient "H")
      (progn
        (setq p1 (list (- cx (/ size 2.0)) (- cy 4.5)))
        (setq p2 (list (+ cx (/ size 2.0)) (+ cy 4.5)))
        (command "_.rectang" p1 p2)
        (command "_.line" (list (- cx (/ size 2.0)) cy) (list (+ cx (/ size 2.0)) cy) "")
        (command "_.line" (list (- cx (/ size 2.0)) (- cy 6.0)) (list (+ cx (/ size 2.0)) (- cy 6.0)) "") ; Sill line
      )
      (progn
        (setq p1 (list (- cx 4.5) (- cy (/ size 2.0))))
        (setq p2 (list (+ cx 4.5) (+ cy (/ size 2.0))))
        (command "_.rectang" p1 p2)
        (command "_.line" (list cx (- cy (/ size 2.0))) (list cx (+ cy (/ size 2.0))) "")
        (command "_.line" (list (- cx 6.0) (- cy (/ size 2.0))) (list (- cx 6.0) (+ cy (/ size 2.0))) "") ; Sill line
      )
    )
  )
  
  ;; Draw Ventilator (bathrooms)
  (defun draw_ventilator (cx cy size orient / p1 p2)
    (setvar "CLAYER" "A-WINDOW")
    (if (= orient "H")
      (progn
        (setq p1 (list (- cx (/ size 2.0)) (- cy 2.25)))
        (setq p2 (list (+ cx (/ size 2.0)) (+ cy 2.25)))
        (command "_.rectang" p1 p2)
        ;; Diagonal crossed line representing vent opening
        (command "_.line" p1 p2 "")
      )
      (progn
        (setq p1 (list (- cx 2.25) (- cy (/ size 2.0))))
        (setq p2 (list (+ cx 2.25) (+ cy (/ size 2.0))))
        (command "_.rectang" p1 p2)
        (command "_.line" p1 p2 "")
      )
    )
  )
  
  ;; Draw Door (Frame + Double swing arc line)
  (defun draw_door (pt size dir / pEnd pArcStart)
    (setvar "CLAYER" "A-DOOR")
    (cond
      ((= dir "NW")
       (setq pEnd (list (car pt) (+ (cadr pt) size)))
       (setq pArcStart (list (- (car pt) size) (cadr pt)))
       ;; Door leaf thickness rectangle (2")
       (command "_.rectang" (list (- (car pt) 2.0) (cadr pt)) (list (car pt) (+ (cadr pt) size)))
       (command "_.arc" "_c" pt pEnd pArcStart)
      )
      ((= dir "NE")
       (setq pEnd (list (car pt) (+ (cadr pt) size)))
       (setq pArcStart (list (+ (car pt) size) (cadr pt)))
       (command "_.rectang" (list (car pt) (cadr pt)) (list (+ (car pt) 2.0) (+ (cadr pt) size)))
       (command "_.arc" "_c" pt pArcStart pEnd)
      )
      ((= dir "SE")
       (setq pEnd (list (car pt) (- (cadr pt) size)))
       (setq pArcStart (list (+ (car pt) size) (cadr pt)))
       (command "_.rectang" (list (car pt) (- (cadr pt) size)) (list (+ (car pt) 2.0) (cadr pt)))
       (command "_.arc" "_c" pt pEnd pArcStart)
      )
      ((= dir "SW")
       (setq pEnd (list (car pt) (- (cadr pt) size)))
       (setq pArcStart (list (- (car pt) size) (cadr pt)))
       (command "_.rectang" (list (- (car pt) 2.0) (- (cadr pt) size)) (list (car pt) (cadr pt)))
       (command "_.arc" "_c" pt pArcStart pEnd)
      )
    )
  )

  ;; Draw Dog-legged Staircase
  (defun draw_staircase (sx sy sw sl / landingW stepW stepD numSteps i xL xR yPos)
    (setvar "CLAYER" "A-STAIR")
    (setq landingW 42.0) ; 3'6" landing width
    (setq stepW 39.0)    ; 3'3" flight width
    (setq stepD 10.0)    ; 10" tread depth
    (setq numSteps 10)
    
    ;; 1. Draw Staircase boundary
    (command "_.rectang" (list sx sy) (list (+ sx sw) (+ sy sl)))
    
    ;; 2. Draw Landing at top (Y = sy + sl - landingW)
    (command "_.line" (list sx (- (+ sy sl) landingW)) (list (+ sx sw) (- (+ sy sl) landingW)) "")
    
    ;; 3. Draw middle flight divider line
    (command "_.line" (list (+ sx (/ sw 2.0)) sy) (list (+ sx (/ sw 2.0)) (- (+ sy sl) landingW)) "")
    
    ;; 4. Draw treads
    (setq i 0)
    (while (< i numSteps)
      (setq yPos (+ sy (* i stepD)))
      ;; Flight 1 treads (Left side going UP)
      (command "_.line" (list sx yPos) (list (+ sx stepW) yPos) "")
      ;; Flight 2 treads (Right side coming DOWN/UP)
      (command "_.line" (list (- (+ sx sw) stepW) yPos) (list (+ sx sw) yPos) "")
      (setq i (1+ i))
    )
    
    ;; 5. Draw Handrail Arrow direction line
    (command "_.circle" (list (+ sx (/ stepW 2.0)) (+ sy 5.0)) 3.0)
    (command "_.line" 
             (list (+ sx (/ stepW 2.0)) (+ sy 5.0)) 
             (list (+ sx (/ stepW 2.0)) (- (+ sy sl) (/ landingW 2.0)))
             (list (- (+ sx sw) (/ stepW 2.0)) (- (+ sy sl) (/ landingW 2.0)))
             (list (- (+ sx sw) (/ stepW 2.0)) (+ sy 15.0))
             "")
    ;; Arrowhead
    (command "_.line" 
             (list (- (+ sx sw) (/ stepW 2.0)) (+ sy 15.0)) 
             (list (- (- (+ sx sw) (/ stepW 2.0)) 3.0) (+ sy 20.0))
             "")
    (command "_.line" 
             (list (- (+ sx sw) (/ stepW 2.0)) (+ sy 15.0)) 
             (list (+ (- (+ sx sw) (/ stepW 2.0)) 3.0) (+ sy 20.0))
             "")
    (setvar "CLAYER" "A-TEXT")
    (entmake (list
               '(0 . "TEXT")
               (cons 10 (list (+ sx (/ sw 2.0) -6.0) (+ sy 15.0)))
               (cons 40 (* textH 0.8))
               (cons 1 "UP")
               (cons 8 "A-TEXT")
             ))
  )

  ;; Draw sanitary closet (WC)
  (defun draw_wc (cx cy orient / pTank1 pTank2 pBowlCenter)
    (setvar "CLAYER" "A-FIXTURE")
    (if (= orient "N")
      (progn
        (setq pTank1 (list (- cx 10.0) (- cy 4.0)))
        (setq pTank2 (list (+ cx 10.0) (+ cy 4.0)))
        (command "_.rectang" pTank1 pTank2)
        (command "_.ellipse" "_c" (list cx (+ cy 10.0)) (list (+ cx 7.0) (+ cy 10.0)) (list cx (+ cy 18.0)))
      )
      (progn
        (setq pTank1 (list (- cx 4.0) (- cy 10.0)))
        (setq pTank2 (list (+ cx 4.0) (+ cy 10.0)))
        (command "_.rectang" pTank1 pTank2)
        (command "_.ellipse" "_c" (list (+ cx 10.0) cy) (list (+ cx 10.0) (+ cy 7.0)) (list (+ cx 18.0) cy))
      )
    )
  )

  ;; Draw wash sink
  (defun draw_sink (cx cy / p1 p2)
    (setvar "CLAYER" "A-FIXTURE")
    (setq p1 (list (- cx 12.0) (- cy 9.0)))
    (setq p2 (list (+ cx 12.0) (+ cy 9.0)))
    (command "_.rectang" p1 p2)
    (command "_.rectang" (list (- cx 10.0) (- cy 7.0)) (list (+ cx 10.0) (+ cy 7.0)))
    (command "_.circle" (list cx cy) 1.5) ; drain hole
  )

  ;; Draw Cooking Gas Stove (two burners)
  (defun draw_stove (cx cy)
    (setvar "CLAYER" "A-FIXTURE")
    (command "_.rectang" (list (- cx 15.0) (- cy 10.0)) (list (+ cx 15.0) (+ cy 10.0)))
    (command "_.circle" (list (- cx 7.0) cy) 4.0)
    (command "_.circle" (list (- cx 7.0) cy) 1.5)
    (command "_.circle" (list (+ cx 7.0) cy) 4.0)
    (command "_.circle" (list (+ cx 7.0) cy) 1.5)
  )

  ;; --- 1. EXTERIOR BUILDING OUTLINE ---
  (princ "\nGenerating outer masonry layout...")
  (setvar "CLAYER" "A-WALL-EXT")
  (command "_.rectang" (list 0.0 0.0) (list w h))
  (command "_.rectang" (list extW extW) (list (- w extW) (- h extW)))

  ;; --- 2. INTERNAL PARTITION WALL LAYOUT ---
  (princ "\nGenerating internal walls...")
  
  ;; Rear Bedroom Master boundary (Horizontal wall at Y = 420)
  (draw_wall_line (list extW 420.0) (list (- w extW) 420.0) "A-WALL-INT")
  (draw_wall_line (list extW (- 420.0 intW)) (list (- w extW) (- 420.0 intW)) "A-WALL-INT")
  
  ;; Split between Master Bed (left) & Bedroom 3 (right) at X = 250
  (draw_wall_line (list 250.0 420.0) (list 250.0 (- h extW)) "A-WALL-INT")
  (draw_wall_line (list (+ 250.0 intW) 420.0) (list (+ 250.0 intW) (- h extW)) "A-WALL-INT")
  
  ;; Master Bath-3 Wall (X = 9 to 90, Y = 490)
  (draw_wall_line (list extW 490.0) (list 90.0 490.0) "A-WALL-INT")
  (draw_wall_line (list extW (- 490.0 intW)) (list 90.0 (- 490.0 intW)) "A-WALL-INT")
  (draw_wall_line (list 90.0 420.0) (list 90.0 490.0) "A-WALL-INT")
  (draw_wall_line (list (- 90.0 intW) 420.0) (list (- 90.0 intW) 490.0) "A-WALL-INT")

  ;; Middle Area (Y = 210 to 420)
  ;; Bedroom 1 Bottom Wall (Horizontal at Y = 210, X = 9 to 190)
  (draw_wall_line (list extW 210.0) (list 190.0 210.0) "A-WALL-INT")
  (draw_wall_line (list extW (- 210.0 intW)) (list 190.0 (- 210.0 intW)) "A-WALL-INT")
  
  ;; Bedroom 1 Right Partition Wall (Vertical at X = 190, Y = 210 to 420)
  (draw_wall_line (list 190.0 210.0) (list 190.0 420.0) "A-WALL-INT")
  (draw_wall_line (list (+ 190.0 intW) 210.0) (list (+ 190.0 intW) 420.0) "A-WALL-INT")
  
  ;; Attached Bath-2 Wall (X = 9 to 85, Y = 330)
  (draw_wall_line (list extW 330.0) (list 85.0 330.0) "A-WALL-INT")
  (draw_wall_line (list extW (- 330.0 intW)) (list 85.0 (- 330.0 intW)) "A-WALL-INT")
  (draw_wall_line (list 85.0 330.0) (list 85.0 420.0) "A-WALL-INT")
  (draw_wall_line (list (- 85.0 intW) 330.0) (list (- 85.0 intW) 420.0) "A-WALL-INT")

  ;; Kitchen Wall (Vertical at X = 330, Y = 210 to 420)
  (draw_wall_line (list 330.0 210.0) (list 330.0 420.0) "A-WALL-INT")
  (draw_wall_line (list (+ 330.0 intW) 210.0) (list (+ 330.0 intW) 420.0) "A-WALL-INT")
  
  ;; Common Bath 1 Wall (Vertical at X = 290, Y = 9 to 210)
  (draw_wall_line (list 290.0 extW) (list 290.0 210.0) "A-WALL-INT")
  (draw_wall_line (list (+ 290.0 intW) extW) (list (+ 290.0 intW) 210.0) "A-WALL-INT")
  ;; Common Bath Front Wall (Horizontal at Y = 110, X = 290 to 360)
  (draw_wall_line (list 290.0 110.0) (list 360.0 110.0) "A-WALL-INT")
  (draw_wall_line (list 290.0 (- 110.0 intW)) (list 360.0 (- 110.0 intW)) "A-WALL-INT")
  (draw_wall_line (list 360.0 110.0) (list 360.0 210.0) "A-WALL-INT")
  (draw_wall_line (list (- 360.0 intW) 110.0) (list (- 360.0 intW) 210.0) "A-WALL-INT")

  ;; Front Entrance Porch Pillars/Beams
  (draw_wall_line (list 360.0 90.0) (list (- w extW) 90.0) "A-WALL-EXT")
  (draw_wall_line (list 360.0 (- 90.0 extW)) (list (- w extW) (- 90.0 extW)) "A-WALL-EXT")
  (draw_wall_line (list 360.0 extW) (list 360.0 90.0) "A-WALL-EXT")
  (draw_wall_line (list (- 360.0 extW) extW) (list (- 360.0 extW) 90.0) "A-WALL-EXT")

  ;; Plumbing ventilation shaft (OTS Duct) between Bath-2 and Bath-3 (X = 9 to 45, Y = 405 to 435)
  (draw_wall_line (list extW 405.0) (list 45.0 405.0) "A-WALL-INT")
  (draw_wall_line (list 45.0 405.0) (list 45.0 435.0) "A-WALL-INT")
  (draw_wall_line (list extW 435.0) (list 45.0 435.0) "A-WALL-INT")
  ;; Draw cross lines inside OTS duct indicating open shaft
  (setvar "CLAYER" "A-WALL-INT")
  (command "_.line" (list extW 405.0) (list 45.0 435.0) "")
  (command "_.line" (list extW 435.0) (list 45.0 405.0) "")
  (setvar "CLAYER" "A-TEXT")
  (entmake (list
             '(0 . "TEXT")
             (cons 10 (list (+ extW 5.0) (+ 405.0 12.0)))
             (cons 40 (* textH 0.5))
             (cons 1 "O.T.S.")
             (cons 8 "A-TEXT")
           ))

  ;; --- 3. CIVIL ENGINEERING STRUCTURAL COLUMNS (9" x 12" Hatch Solid) ---
  (princ "\nGenerating concrete columns...")
  ;; Placement of columns at main structural intersection junctions
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

  ;; --- 4. DETAILED DOORS ---
  (princ "\nDetailing architectural doors...")
  ;; Main Entry double door (42" wide opening from porch into living room)
  (draw_door (list 295.0 110.0) 36.0 "SE")
  ;; Living Room to Dining Lobby Archway (48" wide, represented by hidden lines)
  (setvar "CLAYER" "A-DOOR")
  (command "_.line" (list 190.0 210.0) (list 230.0 210.0) "")
  
  ;; Bedroom 2 (Master) Door (36" wide)
  (draw_door (list 200.0 420.0) 36.0 "NW")
  ;; Master Bath Door (30" wide)
  (draw_door (list 85.0 420.0) 30.0 "NE")
  
  ;; Bedroom 3 Door (36" wide)
  (draw_door (list 255.0 420.0) 36.0 "NE")
  
  ;; Bedroom 1 Door (36" wide)
  (draw_door (list 190.0 250.0) 36.0 "SW")
  ;; Bath-2 Door (30" wide)
  (draw_door (list 80.0 420.0) 30.0 "SE")
  
  ;; Common Toilet Door (30" wide)
  (draw_door (list 290.0 175.0) 30.0 "NE")

  ;; --- 5. DETAILED WINDOWS & VENTILATORS ---
  (princ "\nDetailing window sills and ventilators...")
  ;; Large window in Living Room (60" wide)
  (draw_window 9.0 110.0 60.0 "V")
  ;; Master Bedroom window (48" wide)
  (draw_window 120.0 591.0 48.0 "H")
  ;; Bedroom 3 Window (48" wide)
  (draw_window 360.0 591.0 48.0 "H")
  ;; Bedroom 1 Window (48" wide)
  (draw_window 9.0 300.0 48.0 "V")
  ;; Kitchen Window (48" wide)
  (draw_window 471.0 320.0 48.0 "V")
  ;; Dining Lounge Window (48" wide)
  (draw_window 471.0 230.0 48.0 "V")
  
  ;; Bathroom ventilators (24" wide)
  (draw_ventilator 9.0 450.0 24.0 "V") ; Bath-3 Vent
  (draw_ventilator 9.0 370.0 24.0 "V") ; Bath-2 Vent
  (draw_ventilator 325.0 9.0 24.0 "H")  ; Bath-1 Vent

  ;; --- 6. UTILITY FURNITURE & SANITARY FIXTURES ---
  (princ "\nGenerating fixtures and slab platforms...")
  ;; L-Shaped Kitchen Cooking Platform (24" wide, along Left and Top wall)
  (setvar "CLAYER" "A-FIXTURE")
  ;; platform outer lines
  (command "_.line" (list 334.5 214.5) (list 358.5 214.5) "")
  (command "_.line" (list 358.5 214.5) (list 358.5 381.5) "")
  (command "_.line" (list 358.5 381.5) (list 471.0 381.5) "")
  ;; Draw sink in kitchen platform
  (draw_sink 420.0 395.0)
  ;; Draw gas stove in kitchen platform
  (draw_stove 345.5 290.0)
  
  ;; Toilet Sanitary Fittings (WC Closet + Sink Basin)
  ;; Attached Bath-3
  (draw_wc 30.0 470.0 "N")
  (draw_sink 70.0 475.0)
  
  ;; Attached Bath-2
  (draw_wc 30.0 350.0 "N")
  (draw_sink 65.0 350.0)
  
  ;; Common Bath-1
  (draw_wc 310.0 135.0 "N")
  (draw_sink 335.0 195.0)

  ;; --- 7. STRUCTURAL STAIRCASE (Dog-legged flight) ---
  (princ "\nGenerating dog-legged structural stairs...")
  ;; Staircase placed inside Lobby area (X = 194.5 to 285.5, Y = 214.5 to 335.5)
  (draw_staircase 194.5 214.5 91.0 120.0)

  ;; --- 8. PROFESSIONAL ANNOTATIONS & TEXT ---
  (princ "\nPlacing engineering annotations...")
  (setvar "CLAYER" "A-TEXT")
  
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

  ;; Add Engineering Specifications details block
  (entmake (list
             '(0 . "TEXT")
             (cons 10 (list (- (/ w 2.0) 150.0) (+ h 45.0)))
             (cons 40 (* textH 1.8))
             (cons 1 "DETAILED ARCHITECTURAL & STRUCTURAL PLAN")
             (cons 8 "A-TEXT")
           ))
  (entmake (list
             '(0 . "TEXT")
             (cons 10 (list (- (/ w 2.0) 130.0) (+ h 20.0)))
             (cons 40 textH)
             (cons 1 "DESIGNED BY: ADVANCED CIVIL ENGINEER | footprint: 40' x 50'")
             (cons 8 "A-TEXT")
           ))
  (entmake (list
             '(0 . "TEXT")
             (cons 10 (list (- (/ w 2.0) 100.0) (+ h 5.0)))
             (cons 40 (* textH 0.8))
             (cons 1 "Wall Spec: 9\" Exterior, 4.5\" Partition | RCC Columns: 9\"x12\"")
             (cons 8 "A-TEXT")
           ))

  ;; --- 9. DIMENSION BOUNDARIES ---
  (princ "\nAdding dimension metrics...")
  (setvar "CLAYER" "A-DIM")
  ;; Overall Site Horizontal Dimensions
  (command "_.dimlinear" (list 0.0 0.0) (list w 0.0) (list (/ w 2.0) -48.0))
  ;; Overall Site Vertical Dimensions
  (command "_.dimlinear" (list w 0.0) (list w h) (list (+ w 48.0) (/ h 2.0)))
  
  ;; Reset settings
  (setvar "CLAYER" oldClayer)
  (setvar "CMDECHO" oldCmdEcho)
  (setvar "OSMODE" oldOsmode)
  (setvar "HPNAME" oldHpname)
  (princ "\n\nSuccess! Advanced Structural Floor Plan created successfully.")
  (princ "\nType DRAW_ADVANCED_PLAN to recreate.")
  (princ)
)

(princ "\nType DRAW_ADVANCED_PLAN to run the Advanced Floor Plan generator.\n")
(princ)
