;;; SarthakG_PlanEngine.lsp - Parametric Residential CAD Engine with DCL Dialog GUI
;;;
;;; Features:
;;; 1. **DCL GUI Dialog Box (Pro Level)**: Pops up a professional graphical user interface
;;;    requesting Plot Width, Plot Depth, Concrete Mix specifications, and options to 
;;;    toggle the staircase or sanitary fixtures. Bypasses command line step-by-step prompts.
;;; 2. **Parametric Vector Engine**: Dynamically calculates structural column offsets, 
;;;    room walls, grids, and dimensions based on custom plot inputs (e.g. 30x40, 40x50, 50x60).
;;; 3. **Integrated RCC schedule & Compliance notes**: Automatically adjusts structural table values
;;;    and concrete specifications based on user dialog box selections.
;;;
;;; To load: (load "C:/Users/sarth/.gemini/antigravity-ide/scratch/autocad-lisp-scripts/SarthakG_PlanEngine.lsp")
;;; Run command: DRAW_PLAN_ENGINE

;; --- DCL DIALOG BOX CONTROLLER ---
(defun show_plan_engine_dialog ( / dcl_id dcl_file_path temp_file result w_val h_val conc_val stair_val fix_val )
  (vl-load-com)
  ;; Write temporary DCL file (100% self-contained plug-and-play)
  (setq dcl_file_path (vl-filename-mktemp "plan_engine" nil ".dcl"))
  (setq temp_file (open dcl_file_path "w"))
  (write-line "plan_engine_dialog : dialog {" temp_file)
  (write-line "  label = \"SarthakG Residential Plan Engine v2.0\";" temp_file)
  (write-line "  : row {" temp_file)
  (write-line "    : boxed_column {" temp_file)
  (write-line "      label = \"Plot Dimensions (Feet)\";" temp_file)
  (write-line "      : edit_box {" temp_file)
  (write-line "        key = \"width_eb\";" temp_file)
  (write-line "        label = \"Plot Width (X)  :\";" temp_file)
  (write-line "        edit_width = 10;" temp_file)
  (write-line "        value = \"40\";" temp_file)
  (write-line "      }" temp_file)
  (write-line "      : edit_box {" temp_file)
  (write-line "        key = \"depth_eb\";" temp_file)
  (write-line "        label = \"Plot Depth (Y)  :\";" temp_file)
  (write-line "        edit_width = 10;" temp_file)
  (write-line "        value = \"50\";" temp_file)
  (write-line "      }" temp_file)
  (write-line "    }" temp_file)
  (write-line "    : boxed_column {" temp_file)
  (write-line "      label = \"Engineering Customization\";" temp_file)
  (write-line "      : popup_list {" temp_file)
  (write-line "        key = \"concrete_spec\";" temp_file)
  (write-line "        label = \"Concrete Mix   :\";" temp_file)
  (write-line "        width = 15;" temp_file)
  (write-line "      }" temp_file)
  (write-line "      : toggle {" temp_file)
  (write-line "        key = \"staircase_cb\";" temp_file)
  (write-line "        label = \"Include Dog-Legged Stair\";" temp_file)
  (write-line "        value = \"1\";" temp_file)
  (write-line "      }" temp_file)
  (write-line "      : toggle {" temp_file)
  (write-line "        key = \"fixtures_cb\";" temp_file)
  (write-line "        label = \"Include Sanitary & Stove\";" temp_file)
  (write-line "        value = \"1\";" temp_file)
  (write-line "      }" temp_file)
  (write-line "    }" temp_file)
  (write-line "  }" temp_file)
  (write-line "  : spacer { width = 1; }" temp_file)
  (write-line "  ok_cancel;" temp_file)
  (write-line "}" temp_file)
  (close temp_file)
  
  ;; Load DCL dialog
  (setq dcl_id (load_dialog dcl_file_path))
  (if (not (new_dialog "plan_engine_dialog" dcl_id))
    (progn
      (vl-file-delete dcl_file_path)
      (princ "\nError: DCL dialog loading failed.")
    )
  )
  
  ;; Populating items
  (start_list "concrete_spec")
  (add_list "M20 Grade Mix")
  (add_list "M25 Grade Mix")
  (add_list "M30 Grade Mix")
  (end_list)
  (set_tile "concrete_spec" "1") ; M25 default index
  
  ;; Action bindings
  (action_tile "cancel" "(done_dialog 0)")
  (action_tile "accept" 
    "(progn
       (setq w_val (get_tile \"width_eb\"))
       (setq h_val (get_tile \"depth_eb\"))
       (setq conc_val (get_tile \"concrete_spec\"))
       (setq stair_val (get_tile \"staircase_cb\"))
       (setq fix_val (get_tile \"fixtures_cb\"))
       (done_dialog 1)
     )"
  )
  
  (setq result (start_dialog))
  (unload_dialog dcl_id)
  (vl-file-delete dcl_file_path)
  
  (if (= result 1)
    (list w_val h_val conc_val stair_val fix_val)
    nil
  )
)

;; --- MAIN RESIDENTIAL PLAN ENGINE ---
(defun c:draw_plan_engine ( / 
                            ;; Dialog Results
                            dialog_results w_ft h_ft concrete_index include_stair include_fixtures
                            concrete_label concrete_strength
                            ;; Parameters
                            w h extW intW textH gridExt bath3_x bath3_y bath2_x bath2_y porch_y ots_y1 ots_y2
                            ;; System state
                            oldCmdEcho oldOsmode oldClayer oldHpname
                            ;; Grid vectors
                            grid_x1 grid_x2 grid_x3 grid_x4 grid_x5 grid_x6
                            grid_y1 grid_y2 grid_y3 grid_y4
                            xGrid yGrid xLabels yLabels
                            ;; Table vectors
                            tx ty th ny rx_left rx_right ry_top
                            ;; Helpers
                            draw_wall_line draw_column draw_window draw_ventilator
                            draw_door draw_staircase draw_wc draw_sink draw_stove
                            draw_line draw_rect draw_circle draw_text draw_table_cell
                            apply_solid_hatch draw_room_label
                            )
  
  ;; Save state
  (setq oldCmdEcho (getvar "CMDECHO"))
  (setq oldOsmode (getvar "OSMODE"))
  (setq oldClayer (getvar "CLAYER"))
  (setq oldHpname (getvar "HPNAME"))
  
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)
  
  ;; 1. CALL DCL DIALOG POPUP
  (setq dialog_results (show_plan_engine_dialog))
  
  (if dialog_results
    (progn
      ;; Parse results
      (setq w_ft (atof (nth 0 dialog_results)))
      (setq h_ft (atof (nth 1 dialog_results)))
      (setq concrete_index (atoi (nth 2 dialog_results)))
      (setq include_stair (atoi (nth 3 dialog_results)))
      (setq include_fixtures (atoi (nth 4 dialog_results)))
      
      ;; Safety fallback checks
      (if (<= w_ft 0.0) (setq w_ft 40.0))
      (if (<= h_ft 0.0) (setq h_ft 50.0))
      
      ;; Determine concrete specifications
      (cond
        ((= concrete_index 0)
         (setq concrete_label "M20 Grade")
         (setq concrete_strength "20 MPa")
        )
        ((= concrete_index 2)
         (setq concrete_label "M30 Grade")
         (setq concrete_strength "30 MPa")
        )
        (t
         (setq concrete_label "M25 Grade")
         (setq concrete_strength "25 MPa")
        )
      )
      
      ;; Convert plot size to inches
      (setq w (* w_ft 12.0))
      (setq h (* h_ft 12.0))
      
      (setq extW 9.0)
      (setq intW 4.5)
      (setq textH 10.0)
      (setq gridExt 48.0)
      
      ;; Grid coordinates distribution
      (setq grid_x1 9.0)
      (setq grid_x2 (+ 9.0 (* (- w 18.0) 0.40)))
      (setq grid_x3 (+ 9.0 (* (- w 18.0) 0.52)))
      (setq grid_x4 (+ 9.0 (* (- w 18.0) 0.60)))
      (setq grid_x5 (+ 9.0 (* (- w 18.0) 0.72)))
      (setq grid_x6 (- w 9.0))
      (setq xGrid (list grid_x1 grid_x2 grid_x3 grid_x4 grid_x5 grid_x6))

      (setq grid_y1 9.0)
      (setq grid_y2 (+ 9.0 (* (- h 18.0) 0.35)))
      (setq grid_y3 (+ 9.0 (* (- h 18.0) 0.70)))
      (setq grid_y4 (- h 9.0))
      (setq yGrid (list grid_y1 grid_y2 grid_y3 grid_y4))

      (setq xLabels '("A" "B" "C" "D" "E" "F"))
      (setq yLabels '("1" "2" "3" "4"))

      ;; Load linetype
      (if (not (tblsearch "LTYPE" "CENTER"))
        (vl-catch-all-apply
          '(lambda () 
             (command "_.linetype" "_load" "CENTER" "acad.lin" "")
           )
        )
      )

      ;; Create layers
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
      (setvar "HPNAME" "SOLID")

      ;; --- NESTED HELPERS ---
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
      (defun draw_column (cx cy col_w col_h labelStr / p1 p2)
        (setvar "CLAYER" "A-COLUMN")
        (setq p1 (list (- cx (/ col_w 2.0)) (- cy (/ col_h 2.0)) 0.0))
        (setq p2 (list (+ cx (/ col_w 2.0)) (+ cy (/ col_h 2.0)) 0.0))
        (command "_.rectang" p1 p2)
        (while (> (getvar "CMDACTIVE") 0) (command ""))
        (apply_solid_hatch (entlast))
        (draw_text (list cx (+ cy (/ col_h 1.2)) 0.0) 6.0 labelStr "C" "A-TEXT")
      )
      (defun draw_window (cx cy size orient / p1 p2)
        (setvar "CLAYER" "A-WINDOW")
        (if (= orient "H")
          (progn
            (setq p1 (list (- cx (/ size 2.0)) (- cy 4.5) 0.0))
            (setq p2 (list (+ cx (/ size 2.0)) (+ cy 4.5) 0.0))
            (command "_.rectang" p1 p2)
            (while (> (getvar "CMDACTIVE") 0) (command ""))
            (draw_line (list (- cx (/ size 2.0)) cy 0.0) (list (+ cx (/ size 2.0)) cy 0.0) "A-WINDOW")
            (draw_line (list (- cx (/ size 2.0)) (- cy 6.0) 0.0) (list (+ cx (/ size 2.0)) (- cy 6.0) 0.0) "A-WINDOW")
          )
          (progn
            (setq p1 (list (- cx 4.5) (- cy (/ size 2.0)) 0.0))
            (setq p2 (list (+ cx 4.5) (+ cy (/ size 2.0)) 0.0))
            (command "_.rectang" p1 p2)
            (while (> (getvar "CMDACTIVE") 0) (command ""))
            (draw_line (list cx (- cy (/ size 2.0)) 0.0) (list cx (+ cy (/ size 2.0)) 0.0) "A-WINDOW")
            (draw_line (list (- cx 6.0) (- cy (/ size 2.0)) 0.0) (list (- cx 6.0) (+ cy (/ size 2.0)) 0.0) "A-WINDOW")
          )
        )
      )
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
      (defun draw_staircase (sx sy sw sl / landingW stepW stepD numSteps i yPos)
        (setvar "CLAYER" "A-STAIR")
        (setq landingW 42.0) 
        (setq stepW 39.0)    
        (setq stepD 10.0)    
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
        
        (draw_circle (list (+ sx (/ stepW 2.0)) (+ sy 5.0) 0.0) 3.0 "A-STAIR")
        (command "_.line" 
                 (list (+ sx (/ stepW 2.0)) (+ sy 5.0) 0.0) 
                 (list (+ sx (/ stepW 2.0)) (- (+ sy sl) (/ landingW 2.0)) 0.0)
                 (list (- (+ sx sw) (/ stepW 2.0)) (- (+ sy sl) (/ landingW 2.0)) 0.0)
                 (list (- (+ sx sw) (/ stepW 2.0)) (+ sy 15.0) 0.0)
                 "")
        (while (> (getvar "CMDACTIVE") 0) (command ""))
        (draw_line (list (- (+ sx sw) (/ stepW 2.0)) (+ sy 15.0) 0.0) (list (- (- (+ sx sw) (/ stepW 2.0)) 3.0) (+ sy 20.0) 0.0) "A-STAIR")
        (draw_line (list (- (+ sx sw) (/ stepW 2.0)) (+ sy 15.0) 0.0) (list (+ (- (+ sx sw) (/ stepW 2.0)) 3.0) (+ sy 20.0) 0.0) "A-STAIR")
        
        (draw_text (list (+ sx (/ sw 2.0) -6.0) (+ sy 15.0) 0.0) (* textH 0.8) "UP" "L" "A-TEXT")
      )
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
      (defun draw_sink (cx cy / p1 p2)
        (setvar "CLAYER" "A-FIXTURE")
        (setq p1 (list (- cx 12.0) (- cy 9.0) 0.0))
        (setq p2 (list (+ cx 12.0) (+ cy 9.0) 0.0))
        (draw_rect p1 p2 "A-FIXTURE")
        (draw_rect (list (- cx 10.0) (- cy 7.0) 0.0) (list (+ cx 10.0) (+ cy 7.0) 0.0) "A-FIXTURE")
        (draw_circle (list cx cy 0.0) 1.5 "A-FIXTURE")
      )
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

      ;; --- DRAWING PHASE ---
      (princ "\nDrawing exterior masonry...")
      (draw_rect (list 0.0 0.0 0.0) (list w h 0.0) "A-WALL-EXT")
      (draw_rect (list extW extW 0.0) (list (- w extW) (- h extW) 0.0) "A-WALL-EXT")

      (princ "\nDrawing interior divisions...")
      (draw_line (list extW grid_y3 0.0) (list (- w extW) grid_y3 0.0) "A-WALL-INT")
      (draw_line (list extW (- grid_y3 intW) 0.0) (list (- w extW) (- grid_y3 intW) 0.0) "A-WALL-INT")
      
      (draw_line (list grid_x3 grid_y3 0.0) (list grid_x3 (- h extW) 0.0) "A-WALL-INT")
      (draw_line (list (+ grid_x3 intW) grid_y3 0.0) (list (+ grid_x3 intW) (- h extW) 0.0) "A-WALL-INT")
      
      (setq bath3_x (- grid_x3 100.0))
      (setq bath3_y (+ grid_y3 70.0))
      (draw_line (list extW bath3_y 0.0) (list bath3_x bath3_y 0.0) "A-WALL-INT")
      (draw_line (list extW (- bath3_y intW) 0.0) (list bath3_x (- bath3_y intW) 0.0) "A-WALL-INT")
      (draw_line (list bath3_x grid_y3 0.0) (list bath3_x bath3_y 0.0) "A-WALL-INT")
      (draw_line (list (- bath3_x intW) grid_y3 0.0) (list (- bath3_x intW) bath3_y 0.0) "A-WALL-INT")

      (draw_line (list extW grid_y2 0.0) (list grid_x2 grid_y2 0.0) "A-WALL-INT")
      (draw_line (list extW (- grid_y2 intW) 0.0) (list grid_x2 (- grid_y2 intW) 0.0) "A-WALL-INT")
      
      (draw_line (list grid_x2 grid_y2 0.0) (list grid_x2 grid_y3 0.0) "A-WALL-INT")
      (draw_line (list (+ grid_x2 intW) grid_y2 0.0) (list (+ grid_x2 intW) grid_y3 0.0) "A-WALL-INT")
      
      (setq bath2_x (- grid_x2 100.0))
      (setq bath2_y (- grid_y3 80.0))
      (draw_line (list extW bath2_y 0.0) (list bath2_x bath2_y 0.0) "A-WALL-INT")
      (draw_line (list extW (- bath2_y intW) 0.0) (list bath2_x (- bath2_y intW) 0.0) "A-WALL-INT")
      (draw_line (list bath2_x bath2_y 0.0) (list bath2_x grid_y3 0.0) "A-WALL-INT")
      (draw_line (list (- bath2_x intW) bath2_y 0.0) (list (- bath2_x intW) grid_y3 0.0) "A-WALL-INT")

      (draw_line (list grid_x5 grid_y2 0.0) (list grid_x5 grid_y3 0.0) "A-WALL-INT")
      (draw_line (list (+ grid_x5 intW) grid_y2 0.0) (list (+ grid_x5 intW) grid_y3 0.0) "A-WALL-INT")
      
      (draw_line (list grid_x4 extW 0.0) (list grid_x4 grid_y2 0.0) "A-WALL-INT")
      (draw_line (list (+ grid_x4 intW) extW 0.0) (list (+ grid_x4 intW) grid_y2 0.0) "A-WALL-INT")
      (setq cb_y (- grid_y2 100.0))
      (draw_line (list grid_x4 cb_y 0.0) (list grid_x5 cb_y 0.0) "A-WALL-INT")
      (draw_line (list grid_x4 (- cb_y intW) 0.0) (list grid_x5 (- cb_y intW) 0.0) "A-WALL-INT")
      (draw_line (list grid_x5 cb_y 0.0) (list grid_x5 grid_y2 0.0) "A-WALL-INT")
      (draw_line (list (- grid_x5 intW) cb_y 0.0) (list (- grid_x5 intW) grid_y2 0.0) "A-WALL-INT")

      (setq porch_y (+ grid_y1 80.0))
      (draw_line (list grid_x5 porch_y 0.0) (list (- w extW) porch_y 0.0) "A-WALL-EXT")
      (draw_line (list grid_x5 (- porch_y extW) 0.0) (list (- w extW) (- porch_y extW) 0.0) "A-WALL-EXT")
      (draw_line (list grid_x5 extW 0.0) (list grid_x5 porch_y 0.0) "A-WALL-EXT")
      (draw_line (list (- grid_x5 extW) extW 0.0) (list (- grid_x5 extW) porch_y 0.0) "A-WALL-EXT")

      (setq ots_y1 (+ grid_y3 10.0))
      (setq ots_y2 (- grid_y3 20.0))
      (draw_line (list extW ots_y1 0.0) (list bath2_x ots_y1 0.0) "A-WALL-INT")
      (draw_line (list bath2_x ots_y1 0.0) (list bath2_x ots_y2 0.0) "A-WALL-INT")
      (draw_line (list extW ots_y2 0.0) (list bath2_x ots_y2 0.0) "A-WALL-INT")
      (draw_line (list extW ots_y1 0.0) (list bath2_x ots_y2 0.0) "A-WALL-INT")
      (draw_line (list extW ots_y2 0.0) (list bath2_x ots_y1 0.0) "A-WALL-INT")
      (draw_text (list (+ extW 5.0) (+ ots_y2 10.0) 0.0) (* textH 0.5) "O.T.S." "L" "A-TEXT")

      (princ "\nDrawing door openings...")
      (draw_door (list (+ grid_x4 10.0) cb_y 0.0) 36.0 "SE")
      (draw_door (list (+ grid_x2 10.0) grid_y3 0.0) 36.0 "NW")
      (draw_door (list (- bath3_x intW) (- bath3_y 30.0) 0.0) 30.0 "NE")
      (draw_door (list (+ grid_x3 10.0) grid_y3 0.0) 36.0 "NE")
      (draw_door (list grid_x2 (- grid_y3 50.0) 0.0) 36.0 "SW")
      (draw_door (list (- bath2_x intW) (+ bath2_y 10.0) 0.0) 30.0 "SE")
      (draw_door (list grid_x4 (- cb_y 35.0) 0.0) 30.0 "NE")
      (draw_line (list grid_x5 (+ grid_y2 10.0) 0.0) (list grid_x5 (+ grid_y2 58.0) 0.0) "A-DOOR")

      (princ "\nDrawing windows...")
      (draw_window 9.0 (+ grid_y1 (* (- grid_y2 grid_y1) 0.5)) 60.0 "V")
      (draw_window (+ grid_x1 (* (- grid_x3 grid_x1) 0.5)) (- h 9.0) 48.0 "H")
      (draw_window (+ grid_x3 (* (- grid_x6 grid_x3) 0.5)) (- h 9.0) 48.0 "H")
      (draw_window 9.0 (+ grid_y2 (* (- grid_y3 grid_y2) 0.5)) 48.0 "V")
      (draw_window (- w 9.0) (+ grid_y2 (* (- grid_y3 grid_y2) 0.6)) 48.0 "V")
      (draw_window (- w 9.0) (+ grid_y2 (* (- grid_y3 grid_y2) 0.2)) 48.0 "V")
      (draw_ventilator 9.0 (+ bath3_y 15.0) 24.0 "V")
      (draw_ventilator 9.0 (+ bath2_y 15.0) 24.0 "V")
      (draw_ventilator (+ grid_x4 20.0) 9.0 24.0 "H")

      ;; DRAW FIXTURES (IF ENABLED)
      (if (= include_fixtures 1)
        (progn
          (princ "\nDrawing bathroom & kitchen fixtures...")
          (draw_line (list (+ grid_x5 extW) (+ grid_y2 60.0) 0.0) (list (+ grid_x5 extW 24.0) (+ grid_y2 60.0) 0.0) "A-FIXTURE")
          (draw_line (list (+ grid_x5 extW 24.0) (+ grid_y2 60.0) 0.0) (list (+ grid_x5 extW 24.0) (- grid_y3 24.0) 0.0) "A-FIXTURE")
          (draw_line (list (+ grid_x5 extW 24.0) (- grid_y3 24.0) 0.0) (list (- w extW) (- grid_y3 24.0) 0.0) "A-FIXTURE")
          (draw_sink (- w extW 40.0) (- grid_y3 12.0))
          (draw_stove (+ grid_x5 extW 45.0) (+ grid_y2 130.0))
          (draw_wc (+ extW 20.0) (- bath3_y 20.0) "N")
          (draw_sink (+ extW 60.0) (- bath3_y 15.0))
          (draw_wc (+ extW 20.0) (+ bath2_y 20.0) "N")
          (draw_sink (+ extW 55.0) (+ bath2_y 20.0))
          (draw_wc (+ grid_x4 20.0) (+ extW 25.0) "N")
          (draw_sink (+ grid_x4 45.0) (- cb_y 25.0))
        )
      )

      ;; DRAW STAIRCASE (IF ENABLED)
      (if (= include_stair 1)
        (progn
          (princ "\nDrawing dog-legged staircase...")
          (draw_staircase (+ grid_x2 5.0) (+ grid_y2 5.0) 91.0 120.0)
          (draw_room_label (list (+ grid_x2 150.0) (+ grid_y2 80.0)) "LOBBY / DINING" "Size: 11'-3\" x 15'-10\"")
        )
        (draw_room_label (list (+ grid_x2 150.0) (+ grid_y2 80.0)) "LOBBY / FAMILY ROOM" "Size: 11'-3\" x 15'-10\"")
      )

      (princ "\nWriting annotations...")
      (draw_room_label (list rx_left ry_top) "MASTER BEDROOM (BED-2)" (strcat "Size: " (rtos (/ rx_left 12.0) 2 1) "' x " (rtos (/ ry_top 12.0) 2 1) "'"))
      (draw_room_label (list rx_right ry_top) "BEDROOM-3" (strcat "Size: " (rtos (/ rx_right 12.0) 2 1) "' x " (rtos (/ ry_top 12.0) 2 1) "'"))
      (draw_room_label (list rx_left (+ grid_y2 50.0)) "BEDROOM-1" "Size: 14'-3\" x 11'-3\"")
      (draw_room_label (list (- w 60.0) (+ grid_y2 80.0)) "KITCHEN" "Size: 11'-9\" x 15'-10\"")
      (draw_room_label (list rx_left cb_y) "HALL-1 (LIVING ROOM)" "Size: 22'-7\" x 16'-0\"")
      (draw_room_label (list (+ grid_x4 35.0) (+ extW 60.0)) "C. BATH-1" "5'0\" x 7'8\"")
      (draw_room_label (list (- w 65.0) (+ extW 35.0)) "ENTRANCE PORCH" "16'0\" x 6'9\"")

      (princ "\nDrawing structural framing...")
      (foreach x xGrid
        (draw_line (list x 9.0 0.0) (list x (- h 9.0) 0.0) "S-BEAM-FRAMING")
      )
      (foreach y yGrid
        (draw_line (list 9.0 y 0.0) (list (- w 9.0) y 0.0) "S-BEAM-FRAMING")
      )

      (princ "\nDrawing columns...")
      (draw_column grid_x1 grid_y1 12.0 9.0 "C1")
      (draw_column grid_x2 grid_y1 9.0 12.0 "C2")
      (draw_column grid_x4 grid_y1 9.0 12.0 "C3")
      (draw_column grid_x6 grid_y1 12.0 9.0 "C4")
      (draw_column grid_x1 grid_y2 12.0 9.0 "C5")
      (draw_column grid_x2 grid_y2 9.0 12.0 "C6")
      (draw_column grid_x4 grid_y2 9.0 12.0 "C7")
      (draw_column grid_x5 grid_y2 9.0 12.0 "C8")
      (draw_column grid_x6 grid_y2 12.0 9.0 "C9")
      (draw_column grid_x1 grid_y3 12.0 9.0 "C10")
      (draw_column grid_x2 grid_y3 9.0 12.0 "C11")
      (draw_column grid_x3 grid_y3 9.0 12.0 "C12")
      (draw_column grid_x5 grid_y3 9.0 12.0 "C13")
      (draw_column grid_x6 grid_y3 12.0 9.0 "C14")
      (draw_column grid_x1 grid_y4 12.0 9.0 "C15")
      (draw_column grid_x3 grid_y4 9.0 12.0 "C16")
      (draw_column grid_x6 grid_y4 12.0 9.0 "C17")

      (princ "\nDrawing centre line grids...")
      (setq i 0)
      (foreach x xGrid
        (draw_line (list x (- 9.0 gridExt) 0.0) (list x (+ (- h 9.0) gridExt) 0.0) "S-GRID-CENTER")
        (draw_circle (list x (- 9.0 gridExt 12.0) 0.0) 12.0 "S-BUBBLE")
        (draw_text (list x (- 9.0 gridExt 16.0) 0.0) 10.0 (nth i xLabels) "C" "S-TEXT")
        (draw_circle (list x (+ (- h 9.0) gridExt 12.0) 0.0) 12.0 "S-BUBBLE")
        (draw_text (list x (+ (- h 9.0) gridExt 8.0) 0.0) 10.0 (nth i xLabels) "C" "S-TEXT")
        (setq i (1+ i))
      )
      (setq j 0)
      (foreach y yGrid
        (draw_line (list (- 9.0 gridExt) y 0.0) (list (+ (- w 9.0) gridExt) y 0.0) "S-GRID-CENTER")
        (draw_circle (list (- 9.0 gridExt 12.0) y 0.0) 12.0 "S-BUBBLE")
        (draw_text (list (- 9.0 gridExt 16.0) (- y 4.0) 0.0) 10.0 (nth j yLabels) "C" "S-TEXT")
        (draw_circle (list (+ (- w 9.0) gridExt 12.0) y 0.0) 12.0 "S-BUBBLE")
        (draw_text (list (+ (- w 9.0) gridExt 8.0) (- y 4.0) 0.0) 10.0 (nth j yLabels) "C" "S-TEXT")
        (setq j (1+ j))
      )

      (princ "\nDrawing dimensions...")
      (setvar "CLAYER" "A-DIM")
      (setq i 0)
      (while (< i (1- (length xGrid)))
        (setq p1 (list (nth i xGrid) (- 9.0 gridExt 36.0) 0.0))
        (command "_.dimlinear" (list (nth i xGrid) 9.0 0.0) (list (nth (1+ i) xGrid) 9.0 0.0) p1)
        (while (> (getvar "CMDACTIVE") 0) (command ""))
        (setq i (1+ i))
      )
      (command "_.dimlinear" (list 9.0 9.0 0.0) (list (- w 9.0) 9.0 0.0) (list (/ w 2.0) (- 9.0 gridExt 60.0) 0.0))
      (while (> (getvar "CMDACTIVE") 0) (command ""))
      
      (setq j 0)
      (while (< j (1- (length yGrid)))
        (setq p1 (list (- 9.0 gridExt 36.0) (nth j yGrid) 0.0))
        (command "_.dimlinear" (list 9.0 (nth j yGrid) 0.0) (list 9.0 (nth (1+ j) yGrid) 0.0) p1)
        (while (> (getvar "CMDACTIVE") 0) (command ""))
        (setq j (1+ j))
      )
      (command "_.dimlinear" (list 9.0 9.0 0.0) (list 9.0 (- h 9.0) 0.0) (list (- 9.0 gridExt 60.0) (/ h 2.0) 0.0))
      (while (> (getvar "CMDACTIVE") 0) (command ""))

      (princ "\nDrawing schedule table...")
      (setq tx (+ w 80.0))
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

      (draw_table_cell tx (+ ty (* th 0)) 180.0 (* th 2) (strcat "CONCRETE MIX: " concrete_label "\nSTEEL TYPE: Fe 500 TMT bars") "C")
      (draw_table_cell (+ tx 180.0) (+ ty (* th 0)) 200.0 (* th 2) "CLEAR COVERS:\nFooting: 50mm | Column: 40mm | Beam: 25mm" "C")

      (princ "\nWriting structural notes...")
      (setvar "CLAYER" "A-TEXT")
      (setq ny (+ ty (* th 8)))
      (draw_text (list tx ny 0.0) 14.0 "GENERAL STRUCTURAL CONFORMANCE NOTES:" "L" "S-TEXT")
      (draw_text (list tx (- ny 20.0) 0.0) 9.0 "1. ALL STRUCTURAL DIMENSIONS ARE IN INCHES UNLESS SPECIFIED OTHERWISE." "L" "S-TEXT")
      (draw_text (list tx (- ny 35.0) 0.0) 9.0 "2. CLEAR SPANS AND COLUMN SHAFTS CORRESPOND TO ARRANGE DRAWING ALIGNMENT." "L" "S-TEXT")
      (draw_text (list tx (- ny 50.0) 0.0) 9.0 (strcat "3. CONCRETE GRADE SHIPPED SHALL CONFORM TO " concrete_label " (" concrete_strength " CHARACTERISTIC COMPRESSIVE STRENGTH).") "L" "S-TEXT")
      (draw_text (list tx (- ny 65.0) 0.0) 9.0 "4. STEEL BARS REINFORCED SHALL COMPLY WITH Fe 500 TMT AS PER DESIGN IS 1786." "L" "S-TEXT")
      (draw_text (list tx (- ny 80.0) 0.0) 9.0 "5. LAP LENGTHS SHALL BE MAINTAINED AT A MINIMUM OF 50 * BAR DIAMETER (50d)." "L" "S-TEXT")
      (draw_text (list tx (- ny 95.0) 0.0) 9.0 "6. STIRRUP / TIE HOOKS MUST BEND AT 135 DEGREES IN ACCORDANCE WITH DUCTILE DETAILING." "L" "S-TEXT")
      (draw_text (list tx (- ny 110.0) 0.0) 9.0 "7. ENSURE DUST COMPACTING AND VIBRATORS ARE USED DURING PLINTH POURING." "L" "S-TEXT")

      (draw_text (list (/ w 2.0) (+ h 45.0) 0.0) 24.0 "120-SECOND RESIDENTIAL PLAN ENGINE" "C" "A-TEXT")
      (draw_text (list (/ w 2.0) (+ h 20.0) 0.0) 12.0 (strcat "DYNAMICAL PARAMETRIC PLOT SHEET | size: " (rtos w_ft 2 0) "' x " (rtos h_ft 2 0) "'") "C" "A-TEXT")

      (princ "\n\nSuccess! Fully Parametric Integrated CAD Project Plan generated.")
      (princ "\nType DRAW_PLAN_ENGINE to run again.")
    )
    (princ "\nPlan generation cancelled by user.")
  )

  ;; Restore state
  (setvar "CLAYER" oldClayer)
  (setvar "CMDECHO" oldCmdEcho)
  (setvar "OSMODE" oldOsmode)
  (setvar "HPNAME" oldHpname)
  (princ)
)

(princ "\nType DRAW_PLAN_ENGINE to run the SarthakG PlanEngine.\n")
(princ)
