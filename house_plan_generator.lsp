;;; house_plan_generator.lsp - Generates a 40' x 50' Architectural Floor Plan
;;;
;;; Features:
;;; - 3 Bedrooms (Master Bedroom, Bedroom 2, Bedroom 3)
;;; - 1 Kitchen
;;; - 2 Halls (Living/Drawing Hall & Family/Dining Hall)
;;; - 3 Bathrooms (Common Bath, and two Attached Baths)
;;; - Wall thicknesses (9" Exterior, 4.5" Interior)
;;; - Door symbols (swing arcs) and window symbols
;;; - Custom layered structure (Walls, Doors, Windows, Text, Dimensions)
;;;
;;; To load: (load "C:/Users/sarth/.gemini/antigravity-ide/scratch/autocad-lisp-scripts/house_plan_generator.lsp")
;;; Run command: DRAW_HOUSE_PLAN

(defun c:draw_house_plan ( / 
                          ;; System variables
                          oldCmdEcho oldOsmode
                          ;; Constants
                          w h extW intW textH
                          ;; Helper functions
                          draw_wall draw_door_symbol draw_window_symbol
                          )
  
  ;; Save system settings
  (setq oldCmdEcho (getvar "CMDECHO"))
  (setq oldOsmode (getvar "OSMODE"))
  
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0) ; Turn off snaps to draw cleanly via code
  
  ;; Dimensions (40' x 50' in inches = 480" x 600")
  (setq w 480.0)
  (setq h 600.0)
  (setq extW 9.0)    ; Exterior wall thickness (9 inches)
  (setq intW 4.5)    ; Interior wall thickness (4.5 inches)
  (setq textH 10.0)   ; Text height (10 inches)
  
  ;; Create Layers
  (command "_.layer" "_make" "A-WALL-EXT" "_color" "7" "A-WALL-EXT" "")  ; White/Black external walls
  (command "_.layer" "_make" "A-WALL-INT" "_color" "9" "A-WALL-INT" "")  ; Gray internal walls
  (command "_.layer" "_make" "A-DOOR" "_color" "30" "A-DOOR" "")       ; Orange doors
  (command "_.layer" "_make" "A-WINDOW" "_color" "4" "A-WINDOW" "")      ; Cyan windows
  (command "_.layer" "_make" "A-TEXT" "_color" "2" "A-TEXT" "")        ; Yellow text
  (command "_.layer" "_make" "A-DIM" "_color" "5" "A-DIM" "")         ; Magenta dimensions
  
  ;; --- HELPER FUNCTIONS ---
  
  ;; Helper: Draw simple wall line
  (defun draw_wall (p1 p2 layer thickness)
    (setvar "CLAYER" layer)
    (command "_.line" p1 p2 "")
  )
  
  ;; Helper: Draw door symbol (door frame line + swing arc)
  ;; direction: "NE", "NW", "SE", "SW" relative to starting point
  (defun draw_door_symbol (pt size dir / pEnd pArcCenter pArcStart pArcEnd)
    (setvar "CLAYER" "A-DOOR")
    (cond
      ((= dir "NW")
       (setq pEnd (list (car pt) (+ (cadr pt) size)))
       (setq pArcStart (list (- (car pt) size) (cadr pt)))
       (command "_.line" pt pEnd "")
       (command "_.arc" "_c" pt pEnd pArcStart)
      )
      ((= dir "NE")
       (setq pEnd (list (car pt) (+ (cadr pt) size)))
       (setq pArcStart (list (+ (car pt) size) (cadr pt)))
       (command "_.line" pt pEnd "")
       (command "_.arc" "_c" pt pArcStart pEnd)
      )
      ((= dir "SE")
       (setq pEnd (list (car pt) (- (cadr pt) size)))
       (setq pArcStart (list (+ (car pt) size) (cadr pt)))
       (command "_.line" pt pEnd "")
       (command "_.arc" "_c" pt pEnd pArcStart)
      )
      ((= dir "SW")
       (setq pEnd (list (car pt) (- (cadr pt) size)))
       (setq pArcStart (list (- (car pt) size) (cadr pt)))
       (command "_.line" pt pEnd "")
       (command "_.arc" "_c" pt pArcStart pEnd)
      )
    )
  )
  
  ;; Helper: Draw window symbol (rectangle with center line)
  ;; orientation: "H" (Horizontal), "V" (Vertical)
  (defun draw_window_symbol (pt width size orient / p1 p2 p3 p4)
    (setvar "CLAYER" "A-WINDOW")
    (if (= orient "H")
      (progn
        (setq p1 (list (- (car pt) (/ size 2.0)) (- (cadr pt) (/ width 2.0))))
        (setq p2 (list (+ (car pt) (/ size 2.0)) (+ (cadr pt) (/ width 2.0))))
        (command "_.rectang" p1 p2)
        (command "_.line" (list (- (car pt) (/ size 2.0)) (cadr pt)) (list (+ (car pt) (/ size 2.0)) (cadr pt)) "")
      )
      (progn
        (setq p1 (list (- (car pt) (/ width 2.0)) (- (cadr pt) (/ size 2.0))))
        (setq p2 (list (+ (car pt) (/ width 2.0)) (+ (cadr pt) (/ size 2.0))))
        (command "_.rectang" p1 p2)
        (command "_.line" (list (car pt) (- (cadr pt) (/ size 2.0))) (list (car pt) (+ (cadr pt) (/ size 2.0))) "")
      )
    )
  )
  
  ;; Helper: Draw multi-line text label (middle center alignment)
  (defun draw_room_label (pt line1 line2 / pt2)
    (setvar "CLAYER" "A-TEXT")
    (entmake (list
               '(0 . "TEXT")
               (cons 10 (list (- (car pt) (* textH 3.0)) (+ (cadr pt) (/ textH 2.0))))
               (cons 40 textH)
               (cons 1 line1)
               (cons 8 "A-TEXT")
             ))
    (entmake (list
               '(0 . "TEXT")
               (cons 10 (list (- (car pt) (* textH 2.5)) (- (cadr pt) (/ textH 1.2))))
               (cons 40 (* textH 0.8))
               (cons 1 line2)
               (cons 8 "A-TEXT")
             ))
  )

  ;; --- 1. DRAW OUTER WALLS (9" THICKNESS) ---
  (princ "\nDrawing exterior walls...")
  (setvar "CLAYER" "A-WALL-EXT")
  ;; Outer perimeter
  (command "_.rectang" (list 0.0 0.0) (list w h))
  ;; Inner boundary (offset by 9" inside)
  (command "_.rectang" (list extW extW) (list (- w extW) (- h extW)))
  
  ;; --- 2. DRAW INTERNAL PARTITION WALLS (4.5" THICKNESS) ---
  (princ "\nDrawing interior walls...")
  
  ;; Rear Bedroom Wall (Horizontal at Y = 410)
  (draw_wall (list extW 410.0) (list (- w extW) 410.0) "A-WALL-INT" intW)
  (draw_wall (list extW (- 410.0 intW)) (list (- w extW) (- 410.0 intW)) "A-WALL-INT" intW)
  
  ;; Partition between Bedroom 2 and Bedroom 3 (Vertical at X = 250, from Y = 410 to 591)
  (draw_wall (list 250.0 410.0) (list 250.0 (- h extW)) "A-WALL-INT" intW)
  (draw_wall (list (+ 250.0 intW) 410.0) (list (+ 250.0 intW) (- h extW)) "A-WALL-INT" intW)
  
  ;; Bath 3 wall (attached to Master Bedroom/Bedroom 2 on left, X = 9 to 90, Y = 480)
  (draw_wall (list extW 480.0) (list 90.0 480.0) "A-WALL-INT" intW)
  (draw_wall (list extW (- 480.0 intW)) (list 90.0 (- 480.0 intW)) "A-WALL-INT" intW)
  (draw_wall (list 90.0 410.0) (list 90.0 480.0) "A-WALL-INT" intW)
  (draw_wall (list (- 90.0 intW) 410.0) (list (- 90.0 intW) 480.0) "A-WALL-INT" intW)
  
  ;; Middle Bedroom 1 Wall (Horizontal at Y = 210, X = 9 to 190)
  (draw_wall (list extW 210.0) (list 190.0 210.0) "A-WALL-INT" intW)
  (draw_wall (list extW (- 210.0 intW)) (list 190.0 (- 210.0 intW)) "A-WALL-INT" intW)
  
  ;; Bedroom 1 right partition wall (Vertical at X = 190, from Y = 210 to 410)
  (draw_wall (list 190.0 210.0) (list 190.0 410.0) "A-WALL-INT" intW)
  (draw_wall (list (+ 190.0 intW) 210.0) (list (+ 190.0 intW) 410.0) "A-WALL-INT" intW)
  
  ;; Bath 2 wall (attached to Bedroom 1, X = 9 to 85, Y = 330)
  (draw_wall (list extW 330.0) (list 85.0 330.0) "A-WALL-INT" intW)
  (draw_wall (list extW (- 330.0 intW)) (list 85.0 (- 330.0 intW)) "A-WALL-INT" intW)
  (draw_wall (list 85.0 330.0) (list 85.0 410.0) "A-WALL-INT" intW)
  (draw_wall (list (- 85.0 intW) 330.0) (list (- 85.0 intW) 410.0) "A-WALL-INT" intW)
  
  ;; Kitchen wall (Vertical at X = 330, Y = 210 to 410)
  (draw_wall (list 330.0 210.0) (list 330.0 410.0) "A-WALL-INT" intW)
  (draw_wall (list (+ 330.0 intW) 210.0) (list (+ 330.0 intW) 410.0) "A-WALL-INT" intW)
  
  ;; Common Bath 1 wall (Vertical at X = 290, Y = extW to 210)
  (draw_wall (list 290.0 extW) (list 290.0 210.0) "A-WALL-INT" intW)
  (draw_wall (list (+ 290.0 intW) extW) (list (+ 290.0 intW) 210.0) "A-WALL-INT" intW)
  ;; Common Bath 1 front wall (Horizontal at Y = 110, X = 290 to 360)
  (draw_wall (list 290.0 110.0) (list 360.0 110.0) "A-WALL-INT" intW)
  (draw_wall (list 290.0 (- 110.0 intW)) (list 360.0 (- 110.0 intW)) "A-WALL-INT" intW)
  (draw_wall (list 360.0 110.0) (list 360.0 210.0) "A-WALL-INT" intW)
  (draw_wall (list (- 360.0 intW) 110.0) (list (- 360.0 intW) 210.0) "A-WALL-INT" intW)
  
  ;; Lobby entry / Passage partition (Vertical at X = 290 from Y = 210 to 280)
  (draw_wall (list 290.0 210.0) (list 290.0 280.0) "A-WALL-INT" intW)
  (draw_wall (list (+ 290.0 intW) 210.0) (list (+ 290.0 intW) 280.0) "A-WALL-INT" intW)
  (draw_wall (list 190.0 280.0) (list 290.0 280.0) "A-WALL-INT" intW)
  (draw_wall (list 190.0 (- 280.0 intW)) (list 290.0 (- 280.0 intW)) "A-WALL-INT" intW)
  
  ;; Entrance Porch Outer Beam/Pillar (X = 360 to 471, Y = 90)
  (draw_wall (list 360.0 90.0) (list (- w extW) 90.0) "A-WALL-EXT" extW)
  (draw_wall (list 360.0 (- 90.0 extW)) (list (- w extW) (- 90.0 extW)) "A-WALL-EXT" extW)
  (draw_wall (list 360.0 extW) (list 360.0 90.0) "A-WALL-EXT" extW)
  (draw_wall (list (- 360.0 extW) extW) (list (- 360.0 extW) 90.0) "A-WALL-EXT" extW)
  
  ;; --- 3. DRAW DOOR SYMBOLS ---
  (princ "\nDrawing door swings...")
  ;; Main Entrance door (width 40" at X = 295, Y = 90, opening into Hall 1)
  (draw_door_symbol (list 295.0 110.0) 36.0 "SE")
  
  ;; Bedroom 2 (Master) door (width 36", X = 200, Y = 410, opening NW)
  (draw_door_symbol (list 200.0 410.0) 36.0 "NW")
  ;; Bath 3 door (Master Bath) (width 30", X = 85, Y = 410, opening NE)
  (draw_door_symbol (list 85.0 410.0) 30.0 "NE")
  
  ;; Bedroom 3 door (width 36", X = 255, Y = 410, opening NE)
  (draw_door_symbol (list 255.0 410.0) 36.0 "NE")
  
  ;; Bedroom 1 door (width 36", X = 190, Y = 250, opening SW)
  (draw_door_symbol (list 190.0 250.0) 36.0 "SW")
  ;; Bath 2 door (width 30", X = 80, Y = 410, opening SE)
  (draw_door_symbol (list 80.0 410.0) 30.0 "SE")
  
  ;; Kitchen opening (width 48", X = 330, Y = 330, open entry - no door leaf)
  (setvar "CLAYER" "A-DOOR")
  (command "_.line" (list 330.0 330.0) (list 330.0 378.0) "")
  
  ;; Common Bath 1 door (width 30", X = 290, Y = 175, opening NE)
  (draw_door_symbol (list 290.0 175.0) 30.0 "NE")
  
  ;; --- 4. DRAW WINDOW SYMBOLS ---
  (princ "\nDrawing window frames...")
  ;; Master Bedroom window (bottom wall, center)
  (draw_window_symbol (list 130.0 extW) extW 48.0 "H")
  ;; Bedroom 3 window (bottom wall, center)
  (draw_window_symbol (list 360.0 extW) extW 48.0 "H")
  ;; Bedroom 1 window (left wall, center)
  (draw_window_symbol (list extW 310.0) extW 48.0 "V")
  ;; Kitchen window (right wall, center)
  (draw_window_symbol (list (- w extW) 310.0) extW 48.0 "V")
  ;; Living Hall window (left wall, front)
  (draw_window_symbol (list extW 110.0) extW 60.0 "V")
  ;; Dining Hall window (right wall, center)
  (draw_window_symbol (list (- w extW) 230.0) extW 48.0 "V")
  
  ;; --- 5. ROOM LABELS & DIMENSIONS ---
  (princ "\nAdding room annotations...")
  
  ;; Rear Bedrooms (Y = 410 to 600)
  (draw_room_label (list 135.0 500.0) "MASTER BEDROOM (BED-2)" "19'-3\" x 15'-0\"")
  (draw_room_label (list 50.0 445.0) "A. BATH-3" "6'-3\" x 5'-8\"")
  (draw_room_label (list 360.0 500.0) "BEDROOM-3" "18'-5\" x 15'-0\"")
  
  ;; Middle Area (Y = 210 to 410)
  (draw_room_label (list 135.0 330.0) "BEDROOM-1" "14'-3\" x 11'-3\"")
  (draw_room_label (list 45.0 365.0) "A. BATH-2" "5'-11\" x 6'-8\"")
  (draw_room_label (list 260.0 330.0) "HALL-2 (DINING)" "11'-3\" x 15'-10\"")
  (draw_room_label (list 400.0 310.0) "KITCHEN" "11'-9\" x 15'-10\"")
  
  ;; Front Area (Y = 0 to 210)
  (draw_room_label (list 150.0 110.0) "HALL-1 (LIVING ROOM)" "22'-7\" x 16'-0\"")
  (draw_room_label (list 325.0 160.0) "C. BATH-1" "5'-0\" x 7'-8\"")
  (draw_room_label (list 410.0 50.0) "ENTRANCE / PORCH" "15'-11\" x 6'-9\"")
  
  ;; --- 6. OVERALL FLOOR PLAN TEXT DETAILS ---
  (setvar "CLAYER" "A-TEXT")
  (entmake (list
             '(0 . "TEXT")
             (cons 10 (list (- (/ w 2.0) 120.0) (+ h 40.0)))
             (cons 40 (* textH 1.8))
             (cons 1 "40' x 50' RESIDENTIAL HOUSE PLAN")
             (cons 8 "A-TEXT")
           ))
  (entmake (list
             '(0 . "TEXT")
             (cons 10 (list (- (/ w 2.0) 115.0) (+ h 15.0)))
             (cons 40 textH)
             (cons 1 "3 Bedrooms, 1 Kitchen, 2 Halls, 3 Bathrooms & Porch")
             (cons 8 "A-TEXT")
           ))
           
  ;; --- 7. AUTOMATED PLAN DIMENSIONS ---
  (princ "\nAdding overall plan dimensions...")
  (setvar "CLAYER" "A-DIM")
  
  ;; Bottom Horizontal Overall Dimension (40 feet = 480 inches)
  (command "_.dimlinear" (list 0.0 0.0) (list w 0.0) (list (/ w 2.0) -48.0))
  
  ;; Right Vertical Overall Dimension (50 feet = 600 inches)
  (command "_.dimlinear" (list w 0.0) (list w h) (list (+ w 48.0) (/ h 2.0)))
  
  ;; Restore system settings
  (setvar "CMDECHO" oldCmdEcho)
  (setvar "OSMODE" oldOsmode)
  (princ "\n\nSuccess! House Floor Plan generated successfully on standard layer set.")
  (princ "\nType DRAW_HOUSE_PLAN to regenerate.")
  (princ)
)

(princ "\nType DRAW_HOUSE_PLAN to run the Floor Plan generator.\n")
(princ)
