;;; lisp_portfolio_generator.lsp - Pure AutoLISP 100 Floor Plan Portfolio Compiler
;;;
;;; Features:
;;;   1. Procedural LISP Drafting Engine: Draws grids, columns, double-line walls, 
;;;      annotations, structural tables, and title blocks with coordinate offsets.
;;;   2. 100-Plan Matrix: Contains parametric specifications for all 100 distinct plans
;;;      (Compact, Executive, Villa, Narrow, and Commercial categories).
;;;   3. Single Sheet Layout: Arranges all 100 plans side-by-side in a 10x10 grid.
;;;
;;; Commands:
;;;   COMPILE_PORTFOLIO - Runs the full 100-plan batch generator on one sheet.
;;;   COMPILE_PLAN      - Prompts for a plan index (1-100) and compiles just that drawing at its offset.
;;;
;;; To Load: (load "C:/Users/sarth/New folder (12)/lisp_portfolio_generator.lsp")

(vl-load-com)

;; --- 1. ROUNDING HELPER ---
(defun round (x)
  (if (>= x 0)
    (fix (+ x 0.5))
    (fix (- x 0.5))
  )
)

;; --- 2. GRID UTILITIES ---
(defun get_cell (grid r c)
  (nth c (nth r grid))
)

(defun replace_cell (grid r c val / row new_row result i j item)
  (setq result '() i 0)
  (foreach row grid
    (if (= i r)
      (progn
        (setq new_row '() j 0)
        (foreach item row
          (if (= j c)
            (setq new_row (cons val new_row))
            (setq new_row (cons item new_row))
          )
          (setq j (1+ j))
        )
        (setq result (cons (reverse new_row) result))
      )
      (setq result (cons row result))
    )
    (setq i (1+ i))
  )
  (reverse result)
)

;; --- 3. PROCEDURAL CONFIGURATION DATABASE ---
(defun get_lisp_plan_specs (idx / w d facing bhk ptype title features id)
  (cond
    ;; Compact Series (30x40) - Index 1 to 25
    ((<= idx 25)
     (setq w 30 d 40)
     (cond
       ((<= idx 7)
        (setq facing "E")
        (cond
          ((= idx 1) (setq bhk 1 ptype "S" title "1BHK Single with large lawn" features '("lawn")))
          ((= idx 2) (setq bhk 2 ptype "S" title "2BHK Single Standard Layout" features '()))
          ((= idx 3) (setq bhk 2 ptype "S" title "2BHK Single with attached shops" features '("shops")))
          ((= idx 4) (setq bhk 3 ptype "S" title "3BHK Single Compact room sizing" features '()))
          ((= idx 5) (setq bhk 3 ptype "D" title "3BHK Duplex (Living/Kitchen/3 Bed)" features '("staircase")))
          ((= idx 6) (setq bhk 3 ptype "D" title "3BHK Duplex with study room" features '("staircase" "study")))
          (t (setq bhk 4 ptype "D" title "4BHK Duplex Compact design" features '("staircase")))
        ))
       ((<= idx 14)
        (setq facing "N")
        (cond
          ((= idx 8) (setq bhk 1 ptype "S" title "1BHK Single with deep veranda" features '("veranda")))
          ((= idx 9) (setq bhk 2 ptype "S" title "2BHK Single Vastu North Entrance" features '()))
          ((= idx 10) (setq bhk 2 ptype "S" title "2BHK Single with pooja room" features '("pooja")))
          ((= idx 11) (setq bhk 3 ptype "S" title "3BHK Single open-concept kitchen" features '("american_kitchen")))
          ((= idx 12) (setq bhk 3 ptype "D" title "3BHK Duplex central sky courtyard" features '("staircase" "courtyard")))
          ((= idx 13) (setq bhk 3 ptype "D" title "3BHK Duplex double-height ceiling" features '("staircase" "double_height")))
          (t (setq bhk 4 ptype "D" title "4BHK Duplex with family lounge" features '("staircase" "lounge")))
        ))
       ((<= idx 20)
        (setq facing "W")
        (cond
          ((= idx 15) (setq bhk 2 ptype "S" title "2BHK Single Agni corner kitchen" features '()))
          ((= idx 16) (setq bhk 2 ptype "S" title "2BHK Single with rear garden" features '("rear_garden")))
          ((= idx 17) (setq bhk 3 ptype "S" title "3BHK Single parallel service alleys" features '("service_alley")))
          ((= idx 18) (setq bhk 3 ptype "D" title "3BHK Duplex with attached balconies" features '("staircase" "balcony")))
          ((= idx 19) (setq bhk 3 ptype "D" title "3BHK Duplex integrated car porch" features '("staircase" "porch")))
          (t (setq bhk 4 ptype "D" title "4BHK Duplex with home theater" features '("staircase" "theater")))
        ))
       (t
        (setq facing "S")
        (cond
          ((= idx 21) (setq bhk 2 ptype "S" title "2BHK Single South Pada Entrance" features '()))
          ((= idx 22) (setq bhk 2 ptype "S" title "2BHK Single heavy structural South walls" features '("heavy_south_wall")))
          ((= idx 23) (setq bhk 3 ptype "S" title "3BHK Single massive master suite" features '("massive_master")))
          ((= idx 24) (setq bhk 3 ptype "D" title "3BHK Duplex overhanging front balcony" features '("staircase" "front_balcony")))
          (t (setq bhk 4 ptype "D" title "4BHK Duplex servant room entrance" features '("staircase" "servant_room")))
        ))
     )
    )
    ;; Executive Series (40x50) - Index 26 to 50
    ((<= idx 50)
     (setq w 40 d 50)
     (cond
       ((<= idx 32)
        (setq facing "E")
        (cond
          ((= idx 26) (setq bhk 2 ptype "S" title "2BHK Single massive living hall" features '("massive_hall")))
          ((= idx 27) (setq bhk 3 ptype "S" title "3BHK Single Executive Standard Layout" features '()))
          ((= idx 28) (setq bhk 3 ptype "S" title "3BHK Single with walk-in wardrobe" features '("wardrobe")))
          ((= idx 29) (setq bhk 4 ptype "S" title "4BHK Single sprawling level layout" features '()))
          ((= idx 30) (setq bhk 4 ptype "D" title "4BHK Duplex grand U-shaped stairs" features '("staircase" "u_stair")))
          ((= idx 31) (setq bhk 4 ptype "D" title "4BHK Duplex dedicated home gym" features '("staircase" "gym")))
          (t (setq bhk 5 ptype "D" title "5BHK Duplex capacity joint family" features '("staircase")))
        ))
       ((<= idx 39)
        (setq facing "N")
        (cond
          ((= idx 33) (setq bhk 2 ptype "S" title "2BHK Single wrap-around porch" features '("porch" "wrap_porch")))
          ((= idx 34) (setq bhk 3 ptype "S" title "3BHK Single wet/dry kitchen split" features '("wet_dry_kitchen")))
          ((= idx 35) (setq bhk 3 ptype "S" title "3BHK Single formal drawing room" features '("drawing_room")))
          ((= idx 36) (setq bhk 4 ptype "S" title "4BHK Single attached bath for all beds" features '("all_attached")))
          ((= idx 37) (setq bhk 4 ptype "D" title "4BHK Duplex central spiral staircase" features '("staircase" "spiral_stair")))
          ((= idx 38) (setq bhk 4 ptype "D" title "4BHK Duplex massive open roof terrace" features '("staircase" "roof_terrace")))
          (t (setq bhk 5 ptype "D" title "5BHK Duplex guest bedroom on GF" features '("staircase" "guest_room")))
        ))
       ((<= idx 45)
        (setq facing "W")
        (cond
          ((= idx 40) (setq bhk 3 ptype "S" title "3BHK Single integrated garage space" features '("garage")))
          ((= idx 41) (setq bhk 3 ptype "S" title "3BHK Single max natural cross-vent" features '("cross_vent")))
          ((= idx 42) (setq bhk 4 ptype "S" title "4BHK Single central dining lobby" features '("central_lobby")))
          ((= idx 43) (setq bhk 4 ptype "D" title "4BHK Duplex L-shaped stairs" features '("staircase" "l_stair")))
          ((= idx 44) (setq bhk 4 ptype "D" title "4BHK Duplex covered balcony lounge" features '("staircase" "balcony_lounge")))
          (t (setq bhk 5 ptype "D" title "5BHK Duplex dual master suites" features '("staircase" "dual_master")))
        ))
       (t
        (setq facing "S")
        (cond
          ((= idx 46) (setq bhk 3 ptype "S" title "3BHK Single water tank detail" features '("water_tank")))
          ((= idx 47) (setq bhk 3 ptype "S" title "3BHK Single private rear sit-out" features '("sitout")))
          ((= idx 48) (setq bhk 4 ptype "S" title "4BHK Single kitchen-utility zone" features '("utility_zone")))
          ((= idx 49) (setq bhk 4 ptype "D" title "4BHK Duplex canopy parking porch" features '("staircase" "parking_canopy")))
          (t (setq bhk 5 ptype "D" title "5BHK Duplex home bar & lounge" features '("staircase" "home_bar")))
        ))
     )
    )
    ;; Luxury Villa Series (50x60) - Index 51 to 75
    ((<= idx 75)
     (setq w 50 d 60)
     (cond
       ((<= idx 57)
        (setq facing "E")
        (cond
          ((= idx 51) (setq bhk 3 ptype "S" title "3BHK Bungalow 3-sided garden lawns" features '("three_sided_lawn")))
          ((= idx 52) (setq bhk 4 ptype "S" title "4BHK Single massive central hall" features '("formal_hall")))
          ((= idx 53) (setq bhk 4 ptype "D" title "4BHK Duplex 2-car automatic garage" features '("staircase" "double_garage")))
          ((= idx 54) (setq bhk 4 ptype "D" title "4BHK Duplex office & library wing" features '("staircase" "office_library")))
          ((= idx 55) (setq bhk 5 ptype "D" title "5BHK Duplex double-height grand lobby" features '("staircase" "grand_lobby")))
          ((= idx 56) (setq bhk 5 ptype "D" title "5BHK Duplex attached pool deck layout" features '("staircase" "pool")))
          (t (setq bhk 6 ptype "D" title "6BHK Duplex Elite joint family layout" features '("staircase")))
        ))
       ((<= idx 64)
        (setq facing "N")
        (cond
          ((= idx 58) (setq bhk 3 ptype "S" title "3BHK Single traditional inner courtyard" features '("courtyard")))
          ((= idx 59) (setq bhk 4 ptype "S" title "4BHK Single store and utility outhouse" features '("outhouse")))
          ((= idx 60) (setq bhk 4 ptype "D" title "4BHK Duplex modern glass-facade front" features '("staircase" "glass_facade")))
          ((= idx 61) (setq bhk 4 ptype "D" title "4BHK Duplex prayer hall capsule" features '("staircase" "prayer_hall")))
          ((= idx 62) (setq bhk 5 ptype "D" title "5BHK Duplex floating cantilever stairs" features '("staircase" "floating_stair")))
          ((= idx 63) (setq bhk 5 ptype "D" title "5BHK Duplex theater & gaming zone" features '("staircase" "theater_gaming")))
          (t (setq bhk 6 ptype "D" title "6BHK Duplex staff quarters & entry" features '("staircase" "staff_quarters")))
        ))
       ((<= idx 70)
        (setq facing "W")
        (cond
          ((= idx 65) (setq bhk 4 ptype "S" title "4BHK Single expansive rear patio" features '("rear_patio")))
          ((= idx 66) (setq bhk 4 ptype "S" title "4BHK Single family lounge & drawing" features '("family_lounge")))
          ((= idx 67) (setq bhk 4 ptype "D" title "4BHK Duplex skylight framing over stairs" features '("staircase" "skylight")))
          ((= idx 68) (setq bhk 5 ptype "D" title "5BHK Duplex master suite upper floor" features '("staircase" "mega_master")))
          ((= idx 69) (setq bhk 5 ptype "D" title "5BHK Duplex solar panel roof grid" features '("staircase" "solar_roof")))
          (t (setq bhk 6 ptype "D" title "6BHK Duplex dual living rooms" features '("staircase" "dual_living")))
        ))
       (t
        (setq facing "S")
        (cond
          ((= idx 71) (setq bhk 4 ptype "S" title "4BHK Single South landscape zoning" features '("south_landscape")))
          ((= idx 72) (setq bhk 4 ptype "D" title "4BHK Duplex 3-car parking porch" features '("staircase" "triple_porch")))
          ((= idx 73) (setq bhk 5 ptype "D" title "5BHK Duplex stepped-terrace facade" features '("staircase" "stepped_facade")))
          ((= idx 74) (setq bhk 5 ptype "D" title "5BHK Duplex indoor elevator shaft" features '("staircase" "elevator")))
          (t (setq bhk 6 ptype "D" title "6BHK Duplex semi-detached guest wing" features '("staircase" "guest_wing")))
        ))
     )
    )
    ;; Specialized & Mixed Series (76-100)
    (t
     (cond
       ;; Narrow Plots (76-85)
       ((<= idx 85)
        (setq w 20 d 60)
        (setq facing (nth (rem (- idx 76) 4) '("E" "N" "W" "S")))
        (setq bhk (+ (rem (- idx 76) 3) 2))
        (setq ptype (if (< idx 80) "S" "D"))
        (setq title (strcat "Narrow Series Plan " (itoa (- idx 75)) " (" (itoa bhk) "BHK)"))
        (setq features (if (= ptype "D") '("narrow_skywell" "staircase") '("narrow_skywell")))
       )
       ;; Mixed & Commercial (86-90)
       ((<= idx 90)
        (cond
          ((= idx 86) (setq w 30 d 50 facing "N" bhk 2 ptype "S" title "Builder Floor independent flat" features '("independent_floor")))
          ((= idx 87) (setq w 40 d 60 facing "E" bhk 3 ptype "D" title "Commercial Ground Shop Floor" features '("shops" "staircase")))
          ((= idx 88) (setq w 40 d 50 facing "N" bhk 4 ptype "D" title "Under-Stilt Parking Layout" features '("under-stilt" "staircase")))
          ((= idx 89) (setq w 50 d 50 facing "E" bhk 2 ptype "S" title "Clinic-cum-Home Layout" features '("clinic")))
          (t (setq w 40 d 50 facing "N" bhk 1 ptype "S" title "Dual-Key Studio Rental Unit" features '("dual-key")))
        ))
       ;; Varying Loads (91-100)
       (t
        (setq w (+ 30 (* (rem (- idx 91) 3) 10)))
        (setq d (+ 40 (* (rem (- idx 91) 2) 10)))
        (setq facing (if (= (rem (- idx 91) 2) 0) "N" "E"))
        (setq bhk 3 ptype "D")
        (setq title (strcat "Varying Load Plan " (itoa (- idx 90)) " (" (itoa w) "x" (itoa d) " plot)"))
        (setq features '("staircase" "heavy_columns"))
       )
     )
    )
  )
  
  ;; Create Plan ID
  (setq id (strcat 
             (cond ((<= idx 25) "CP") ((<= idx 50) "EX") ((<= idx 75) "LV") (t "MF"))
             "-" (itoa w) (itoa d) "-" facing "-" (itoa bhk) "BHK" "-" ptype
  ))
  
  (list idx id w d facing bhk ptype title features)
)

;; --- 4. FLOOD FILL CELL SOLVER ---
(defun flood_fill (grid cols rows start_c start_r visited / name queue room_cells curr c r)
  (setq name (get_cell grid start_r start_c))
  (setq queue (list (cons start_c start_r)))
  (setq room_cells '())
  (while queue
    (setq curr (car queue))
    (setq queue (cdr queue))
    (if (not (member curr visited))
      (progn
        (setq visited (cons curr visited))
        (setq room_cells (cons curr room_cells))
        ;; Left
        (setq c (1- (car curr)) r (cdr curr))
        (if (and (>= c 0) (= (get_cell grid r c) name) (not (member (cons c r) visited)))
          (setq queue (cons (cons c r) queue))
        )
        ;; Right
        (setq c (1+ (car curr)) r (cdr curr))
        (if (and (< c cols) (= (get_cell grid r c) name) (not (member (cons c r) visited)))
          (setq queue (cons (cons c r) queue))
        )
        ;; Bottom
        (setq c (car curr) r (1- (cdr curr)))
        (if (and (>= r 0) (= (get_cell grid r c) name) (not (member (cons c r) visited)))
          (setq queue (cons (cons c r) queue))
        )
        ;; Top
        (setq c (car curr) r (1+ (cdr curr)))
        (if (and (< r rows) (= (get_cell grid r c) name) (not (member (cons c r) visited)))
          (setq queue (cons (cons c r) queue))
        )
      )
    )
  )
  (list room_cells visited)
)

(defun get_unique_rooms (grid cols rows / visited rooms r c ff)
  (setq visited '())
  (setq rooms '())
  (setq r 0)
  (while (< r rows)
    (setq c 0)
    (while (< c cols)
      (if (not (member (cons c r) visited))
        (progn
          (setq ff (flood_fill grid cols rows c r visited))
          (setq rooms (cons (list (get_cell grid r c) (car ff)) rooms))
          (setq visited (cadr ff))
        )
      )
      (setq c (1+ c))
    )
    (setq r (1+ r))
  )
  (reverse rooms)
)

;; --- 5. ROOM EDGE EXTRACTOR ---
(defun get_room_edges (cells grid cols rows xGrid yGrid / edges c r x1 x2 y1 y2 neighbor)
  (setq edges '())
  (foreach cell cells
    (setq c (car cell)
          r (cdr cell))
    
    ;; Left Edge
    (if (or (= c 0) (not (member (cons (1- c) r) cells)))
      (progn
        (setq x1 (nth c xGrid)
              y1 (nth r yGrid)
              y2 (nth (1+ r) yGrid))
        (setq neighbor (if (> c 0) (get_cell grid r (1- c)) nil))
        (setq edges (cons (list "V" x1 y1 x1 y2 neighbor) edges))
      )
    )
    ;; Right Edge
    (if (or (= c (1- cols)) (not (member (cons (1+ c) r) cells)))
      (progn
        (setq x1 (nth (1+ c) xGrid)
              y1 (nth r yGrid)
              y2 (nth (1+ r) yGrid))
        (setq neighbor (if (< c (1- cols)) (get_cell grid r (1+ c)) nil))
        (setq edges (cons (list "V" x1 y1 x1 y2 neighbor) edges))
      )
    )
    ;; Bottom Edge
    (if (or (= r 0) (not (member (cons c (1- r)) cells)))
      (progn
        (setq x1 (nth c xGrid)
              x2 (nth (1+ c) xGrid)
              y1 (nth r yGrid))
        (setq neighbor (if (> r 0) (get_cell grid (1- r) c) nil))
        (setq edges (cons (list "H" x1 y1 x2 y1 neighbor) edges))
      )
    )
    ;; Top Edge
    (if (or (= r (1- rows)) (not (member (cons c (1+ r)) cells)))
      (progn
        (setq x1 (nth c xGrid)
              x2 (nth (1+ c) xGrid)
              y1 (nth (1+ r) yGrid))
        (setq neighbor (if (< r (1- rows)) (get_cell grid (1+ r) c) nil))
        (setq edges (cons (list "H" x1 y1 x2 y1 neighbor) edges))
      )
    )
  )
  edges
)

;; --- 6. PROCEDURAL GRID BUILDER ---
(defun get_layout_grid (w_ft d_ft facing bhk ptype features / cols rows grid xGrid yGrid w d row new_grid r c new_row item)
  (setq w (* w_ft 12.0)
        d (* d_ft 12.0))
  (if (<= w_ft 24)
    ;; Narrow Row House (20x60)
    (progn
      (setq xGrid (list 0.0 (* w 0.5) w))
      (setq yGrid (list 0.0 (* d 0.25) (* d 0.5) (* d 0.75) d))
      (setq cols 2 rows 4)
      (cond
        ((= bhk 1)
         (setq grid '(("Lawn" "Porch")
                      ("Living Room" "Living Room")
                      ("Kitchen" "Toilet")
                      ("Bedroom" "O.T.S."))))
        ((= bhk 2)
         (setq grid '(("Lawn" "Porch")
                      ("Living Room" "Living Room")
                      ("Bedroom-1" "Toilet")
                      ("Bedroom-2" "O.T.S."))))
        (t
         (setq grid '(("Lawn" "Porch")
                      ("Living Room" "Staircase")
                      ("Bedroom-1" "Toilet-1")
                      ("Bedroom-2" "Toilet-2"))))
      )
    )
    ;; Standard Plots
    (progn
      (if (and (= bhk 4) (= ptype "S"))
        (progn
          (setq xGrid (list 0.0 (* w 0.30) (* w 0.50) (* w 0.75) w))
          (setq yGrid (list 0.0 (* d 0.35) (* d 0.70) d))
          (setq cols 4 rows 3)
          (setq grid '(("Lawn" "Lobby" "Porch" "Bedroom-4")
                       ("Living Room" "Dining" "Kitchen" "Toilet-2")
                       ("Master Bed" "Toilet-1" "Bedroom-2" "Bedroom-3")))
        )
        (progn
          (setq xGrid (list 0.0 (* w 0.40) (* w 0.65) w))
          (setq yGrid (list 0.0 (* d 0.35) (* d 0.70) d))
          (setq cols 3 rows 3)
          (cond
            ((= bhk 1)
             (setq grid '(("Lawn" "Lawn" "Porch")
                          ("Living Room" "Dining" "Kitchen")
                          ("Master Bed" "Toilet" "O.T.S."))))
            ((= bhk 2)
             (setq grid '(("Lawn" "Lawn" "Porch")
                          ("Living Room" "Dining" "Kitchen")
                          ("Master Bed" "Toilet" "Bedroom-2"))))
            ((= bhk 3)
             (setq grid '(("Lawn" "Lobby" "Porch")
                          ("Living Room" "Staircase" "Kitchen")
                          ("Master Bed" "Toilet" "Bedroom-2")))
             (if (= ptype "S")
               (setq grid '(("Lawn" "Lobby" "Porch")
                            ("Living Room" "Bedroom-3" "Kitchen")
                            ("Master Bed" "Toilet" "Bedroom-2")))
             ))
            (t ; 4BHK Duplex or 5BHK/6BHK
             (setq grid '(("Lawn" "Lobby" "Porch")
                          ("Living Room" "Staircase" "Kitchen")
                          ("Master Bed" "Toilet" "Bedroom-2"))))
          )
        )
      )
    )
  )

  ;; Mirroring transformations (Vastu alignments)
  (if (or (= facing "W") (= facing "E"))
    (setq grid (mapcar 'reverse grid))
  )
  (if (= facing "S")
    (setq grid (reverse grid))
  )
  
  ;; Custom features
  (if (member "shops" features)
    (progn
      (setq grid (replace_cell grid 0 0 "Shop-1"))
      (if (> cols 2)
        (setq grid (replace_cell grid 0 2 "Shop-2"))
      )
    )
  )
  
  (if (member "under-stilt" features)
    (progn
      (setq new_grid '())
      (foreach row grid
        (setq new_grid (cons (mapcar '(lambda (x) "Stilt Parking") row) new_grid))
      )
      (setq grid (reverse new_grid))
    )
  )
  
  (if (member "clinic" features)
    (progn
      (setq grid (replace_cell grid 0 0 "Consultation"))
      (setq grid (replace_cell grid 0 1 "Waiting Area"))
      (if (> cols 2)
        (setq grid (replace_cell grid 0 2 "Pharmacy"))
      )
    )
  )
  
  (if (member "dual-key" features)
    (progn
      (setq new_grid '() r 0)
      (foreach row grid
        (setq new_row '() c 0)
        (foreach item row
          (cond
            ((= c 0) (setq new_row (cons (strcat "Flat-A: " item) new_row)))
            ((= c (1- cols)) (setq new_row (cons (strcat "Flat-B: " item) new_row)))
            (t (setq new_row (cons item new_row)))
          )
          (setq c (1+ c))
        )
        (setq new_grid (cons (reverse new_row) new_grid))
        (setq r (1+ r))
      )
      (setq grid (reverse new_grid))
    )
  )

  (list grid cols rows xGrid yGrid)
)


;; --- 7. DETAILED LAYOUT DRAFTING ENGINE WITH COORDINATE OFFSETS ---
(defun draw_lisp_plan (specs / 
                       idx id w_ft d_ft facing bhk ptype title features
                       w d extW intW textH gridExt dx dy grid_col grid_row
                       col_w col_h xGrid yGrid xLabels yLabels
                       oldCmdEcho oldOsmode oldClayer oldHpname
                       p1 p2 p3 p4 tx ty th ny i j x y
                       cols rows grid unique_rooms apertures
                       h_walls v_walls wall y x1 x2 thick cell_below cell_above open_areas
                       cell_left cell_right draw v_wall r c
                       seg_apertures ap ap_type ap_cx ap_cy ap_size ap_orient ap_swing
                       curr_x gap_start gap_end curr_y
                       room r_name cells c_min c_max r_min r_max
                       rx1 rx2 ry1 ry2 rcx rcy r_w r_h
                       w_ft_r h_ft_r w_ft_int w_in_int h_ft_int h_in_int dim_str
                       edges neighbor is_open_neighbor door_cands win_cands
                       selected_door_edge selected_win_edge d_size w_size is_toilet is_vent
                       col_idx is_open_col adj_cells cell conc_mix bx by grid_data
                       ;; nested subroutines
                       draw_line draw_rect draw_circle draw_text draw_table_cell
                       draw_solid_col draw_wall_double draw_door_symbol draw_window_symbol
                       draw_staircase draw_toilet_fittings draw_sink_symbol draw_stove_symbol offset_pt
                       )
  
  ;; Parse specs
  (setq idx (nth 0 specs)
        id (nth 1 specs)
        w_ft (nth 2 specs)
        d_ft (nth 3 specs)
        facing (nth 4 specs)
        bhk (nth 5 specs)
        ptype (nth 6 specs)
        title (nth 7 specs)
        features (nth 8 specs))
  
  ;; Spacing coordinate offsets (2500" spacing to layout in 10x10 sheet grid)
  (setq grid_col (rem (1- idx) 10)
        grid_row (/ (1- idx) 10))
  (setq dx (* grid_col 2500.0)
        dy (* grid_row 2500.0))
  
  ;; Dimensions in inches
  (setq w (* w_ft 12.0))
  (setq d (* d_ft 12.0))
  
  (setq extW 9.0)
  (setq intW 4.5)
  (setq textH 10.0)
  (setq gridExt 48.0)
  (setq col_w 9.0)
  (setq col_h 12.0)
  
  ;; Save system variables
  (setq oldCmdEcho (getvar "CMDECHO"))
  (setq oldOsmode (getvar "OSMODE"))
  (setq oldClayer (getvar "CLAYER"))
  (setq oldHpname (getvar "HPNAME"))
  
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)
  
  ;; 1. CALL PROCEDURAL GRID SOLVER
  (setq grid_data (get_layout_grid w_ft d_ft facing bhk ptype features))
  (setq grid (nth 0 grid_data)
        cols (nth 1 grid_data)
        rows (nth 2 grid_data)
        xGrid (nth 3 grid_data)
        yGrid (nth 4 grid_data))
  
  (setq xLabels '("A" "B" "C" "D" "E" "F"))
  (setq yLabels '("1" "2" "3" "4" "5" "6"))
  
  ;; Load Linetype safely
  (if (not (tblsearch "LTYPE" "CENTER"))
    (vl-catch-all-apply '(lambda () (command "_.linetype" "_load" "CENTER" "acad.lin" "")))
  )
  
  ;; Layers creation
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
  (setvar "FILLMODE" 1)
  
  ;; --- SUB-ROUTINES / DRAWING HELPERS ---
  (defun offset_pt (pt)
    (list (+ (car pt) dx) (+ (cadr pt) dy) 0.0)
  )
  (defun draw_line (p1 p2 layer)
    (setvar "CLAYER" layer)
    (command "_.line" (list (+ (car p1) dx) (+ (cadr p1) dy) 0.0) (list (+ (car p2) dx) (+ (cadr p2) dy) 0.0) "")
    (while (> (getvar "CMDACTIVE") 0) (command ""))
  )
  (defun draw_rect (p1 p2 layer)
    (setvar "CLAYER" layer)
    (command "_.rectang" (list (+ (car p1) dx) (+ (cadr p1) dy) 0.0) (list (+ (car p2) dx) (+ (cadr p2) dy) 0.0))
    (while (> (getvar "CMDACTIVE") 0) (command ""))
  )
  (defun draw_circle (pt radius layer)
    (setvar "CLAYER" layer)
    (command "_.circle" (list (+ (car pt) dx) (+ (cadr pt) dy) 0.0) radius)
    (while (> (getvar "CMDACTIVE") 0) (command ""))
  )
  (defun draw_text (pt height txt alignment layer / align opt)
    (setvar "CLAYER" layer)
    (setq opt (list (+ (car pt) dx) (+ (cadr pt) dy) 0.0))
    (cond
      ((= alignment "C") (setq align "_center"))
      ((= alignment "M") (setq align "_middle"))
      (t (setq align "_left"))
    )
    (if (= alignment "L")
      (entmake (list '(0 . "TEXT") (cons 10 opt) (cons 40 height) (cons 1 txt) (cons 8 layer)))
      (entmake (list '(0 . "TEXT") (cons 10 opt) (cons 11 opt) (cons 72 1) (cons 40 height) (cons 1 txt) (cons 8 layer)))
    )
  )
  (defun draw_table_cell (x y w h txt alignment)
    (draw_rect (list x y 0.0) (list (+ x w) (+ y h) 0.0) "S-TABLE")
    (draw_text (list (+ x (/ w 2.0)) (+ y (/ h 2.0) -3.0) 0.0) 8.0 txt alignment "S-TEXT")
  )
  (defun draw_solid_col (cx cy col_w col_h / p1 p2 p3 p4)
    (setvar "CLAYER" "A-COL-HATCH")
    (setq p1 (list (- cx (/ col_w 2.0)) (- cy (/ col_h 2.0)) 0.0))
    (setq p2 (list (+ cx (/ col_w 2.0)) (- cy (/ col_h 2.0)) 0.0))
    (setq p3 (list (- cx (/ col_w 2.0)) (+ cy (/ col_h 2.0)) 0.0))
    (setq p4 (list (+ cx (/ col_w 2.0)) (+ cy (/ col_h 2.0)) 0.0))
    (command "_.solid" 
             (list (+ (car p1) dx) (+ (cadr p1) dy) 0.0) 
             (list (+ (car p2) dx) (+ (cadr p2) dy) 0.0) 
             (list (+ (car p3) dx) (+ (cadr p3) dy) 0.0) 
             (list (+ (car p4) dx) (+ (cadr p4) dy) 0.0) 
             "")
    (while (> (getvar "CMDACTIVE") 0) (command ""))
    (draw_rect p1 p4 "A-COLUMN")
  )
  (defun draw_wall_double (x1 y1 x2 y2 thick layer / dx_w dy_w len nx ny)
    (setq dx_w (- x2 x1) dy_w (- y2 y1))
    (setq len (sqrt (+ (* dx_w dx_w) (* dy_w dy_w))))
    (if (> len 0)
      (progn
        (setq nx (* (/ (- dy_w) len) (/ thick 2.0)))
        (setq ny (* (/ dx_w len) (/ thick 2.0)))
        (draw_line (list (- x1 nx) (- y1 ny) 0.0) (list (- x2 nx) (- y2 ny) 0.0) layer)
        (draw_line (list (+ x1 nx) (+ y1 ny) 0.0) (list (+ x2 nx) (+ y2 ny) 0.0) layer)
      )
    )
  )
  (defun draw_door_symbol (cx cy size orient swing / h_x h_y)
    (setvar "CLAYER" "A-DOOR")
    (if (= orient "H")
      (progn
        (setq h_x (- cx (/ size 2.0)) h_y cy)
        (if (> swing 0)
          (progn
            (draw_line (list h_x h_y 0.0) (list h_x (+ h_y size) 0.0) "A-DOOR")
            (command "_.arc" "_c" 
                     (list (+ h_x dx) (+ h_y dy) 0.0) 
                     (list (+ (+ h_x size) dx) (+ h_y dy) 0.0) 
                     (list (+ h_x dx) (+ (+ h_y size) dy) 0.0))
             (while (> (getvar "CMDACTIVE") 0) (command ""))
          )
          (progn
            (draw_line (list h_x h_y 0.0) (list h_x (- h_y size) 0.0) "A-DOOR")
            (command "_.arc" "_c" 
                     (list (+ h_x dx) (+ h_y dy) 0.0) 
                     (list (+ h_x dx) (+ (- h_y size) dy) 0.0) 
                     (list (+ (+ h_x size) dx) (+ h_y dy) 0.0))
             (while (> (getvar "CMDACTIVE") 0) (command ""))
          )
        )
      )
      (progn
        (setq h_x cx h_y (- cy (/ size 2.0)))
        (if (> swing 0)
          (progn
            (draw_line (list h_x h_y 0.0) (list (+ h_x size) h_y 0.0) "A-DOOR")
            (command "_.arc" "_c" 
                     (list (+ h_x dx) (+ h_y dy) 0.0) 
                     (list (+ (+ h_x size) dx) (+ h_y dy) 0.0) 
                     (list (+ h_x dx) (+ (+ h_y size) dy) 0.0))
             (while (> (getvar "CMDACTIVE") 0) (command ""))
          )
          (progn
            (draw_line (list h_x h_y 0.0) (list (- h_x size) h_y 0.0) "A-DOOR")
            (command "_.arc" "_c" 
                     (list (+ h_x dx) (+ h_y dy) 0.0) 
                     (list (+ h_x dx) (+ (+ h_y size) dy) 0.0) 
                     (list (+ (- h_x size) dx) (+ h_y dy) 0.0))
             (while (> (getvar "CMDACTIVE") 0) (command ""))
          )
        )
      )
    )
  )
  (defun draw_window_symbol (cx cy size orient is_vent / half)
    (setvar "CLAYER" "A-WINDOW")
    (setq half (/ size 2.0))
    (if (= orient "H")
      (progn
        (draw_rect (list (- cx half) (- cy 4.5) 0.0) (list (+ cx half) (+ cy 4.5) 0.0) "A-WINDOW")
        (if (not is_vent)
          (progn
            (draw_line (list (- cx half) (- cy 1.5) 0.0) (list (+ cx half) (- cy 1.5) 0.0) "A-WINDOW")
            (draw_line (list (- cx half) (+ cy 1.5) 0.0) (list (+ cx half) (+ cy 1.5) 0.0) "A-WINDOW")
          )
          (progn
            (draw_line (list (- cx half) (- cy 4.5) 0.0) (list (+ cx half) (+ cy 4.5) 0.0) "A-WINDOW")
            (draw_line (list (- cx half) (+ cy 4.5) 0.0) (list (+ cx half) (- cy 4.5) 0.0) "A-WINDOW")
          )
        )
      )
      (progn
        (draw_rect (list (- cx 4.5) (- cy half) 0.0) (list (+ cx 4.5) (+ cy half) 0.0) "A-WINDOW")
        (if (not is_vent)
          (progn
            (draw_line (list (- cx 1.5) (- cy half) 0.0) (list (- cx 1.5) (+ cy half) 0.0) "A-WINDOW")
            (draw_line (list (+ cx 1.5) (- cy half) 0.0) (list (+ cx 1.5) (+ cy half) 0.0) "A-WINDOW")
          )
          (progn
            (draw_line (list (- cx 4.5) (- cy half) 0.0) (list (+ cx 4.5) (+ cy half) 0.0) "A-WINDOW")
            (draw_line (list (- cx 4.5) (+ cy half) 0.0) (list (+ cx 4.5) (- cy half) 0.0) "A-WINDOW")
          )
        )
      )
    )
  )
  (defun draw_staircase (sx sy sw sl / landingW stepD numSteps i yPos ax ay)
    (setvar "CLAYER" "A-STAIR")
    (setq landingW 36.0)
    (setq stepD 10.0)
    (setq numSteps (fix (/ (- sl landingW) stepD)))
    
    (draw_rect (list sx sy 0.0) (list (+ sx sw) (+ sy sl) 0.0) "A-STAIR")
    (draw_line (list sx (+ sy sl (- landingW)) 0.0) (list (+ sx sw) (+ sy sl (- landingW)) 0.0) "A-STAIR")
    (draw_line (list (+ sx (/ sw 2.0)) sy 0.0) (list (+ sx (/ sw 2.0)) (+ sy sl (- landingW)) 0.0) "A-STAIR")
    
    (setq i 1)
    (while (< i numSteps)
      (setq yPos (+ sy (* i stepD)))
      (draw_line (list sx yPos 0.0) (list (+ sx (/ sw 2.0)) yPos 0.0) "A-STAIR")
      (draw_line (list (+ sx (/ sw 2.0)) yPos 0.0) (list (+ sx sw) yPos 0.0) "A-STAIR")
      (setq i (1+ i))
    )
    
    (setq ax (+ sx (/ sw 4.0)))
    (draw_line (list ax (+ sy 6.0) 0.0) (list ax (- (+ sy sl) landingW 6.0) 0.0) "A-STAIR")
    (draw_circle (list ax (+ sy 6.0) 0.0) 2.0 "A-STAIR")
    (setq ay (- (+ sy sl) landingW 6.0))
    (draw_line (list ax ay 0.0) (list (- ax 3.0) (- ay 6.0) 0.0) "A-STAIR")
    (draw_line (list ax ay 0.0) (list (+ ax 3.0) (- ay 6.0) 0.0) "A-STAIR")
    (draw_text (list ax (+ sy 24.0) 0.0) 6.0 "UP" "C" "A-TEXT")
  )
  (defun draw_toilet_fittings (cx cy)
    (setvar "CLAYER" "A-FIXTURE")
    (draw_rect (list (- cx 8.0) (- cy 12.0) 0.0) (list (+ cx 8.0) (- cy 6.0) 0.0) "A-FIXTURE")
    (draw_circle (list cx (+ cy 2.0) 0.0) 6.0 "A-FIXTURE")
    (draw_circle (list cx (+ cy 2.0) 0.0) 4.5 "A-FIXTURE")
  )
  (defun draw_sink_symbol (cx cy)
    (setvar "CLAYER" "A-FIXTURE")
    (draw_rect (list (- cx 10.0) (- cy 8.0) 0.0) (list (+ cx 10.0) (+ cy 8.0) 0.0) "A-FIXTURE")
    (draw_circle (list cx cy 0.0) 5.0 "A-FIXTURE")
    (draw_circle (list cx cy 0.0) 1.5 "A-FIXTURE")
  )
  (defun draw_stove_symbol (cx cy)
    (setvar "CLAYER" "A-FIXTURE")
    (draw_rect (list (- cx 14.0) (- cy 9.0) 0.0) (list (+ cx 14.0) (+ cy 9.0) 0.0) "A-FIXTURE")
    (draw_circle (list (- cx 7.0) cy 0.0) 3.5 "A-FIXTURE")
    (draw_circle (list (+ cx 7.0) cy 0.0) 3.5 "A-FIXTURE")
  )

  ;; --- 2. COMPILE ROOM DATA (FLOOD FILL SOLVER) ---
  (setq unique_rooms (get_unique_rooms grid cols rows))
  
  ;; --- 3. DYNAMIC DOOR/WINDOW PLACEMENT ENGINE ---
  (setq apertures '())
  (foreach room unique_rooms
    (setq r_name (car room)
          cells (cadr room))
    
    (setq edges (get_room_edges cells grid cols rows xGrid yGrid))
    
    (setq needs_door nil)
    (foreach name '("BED" "TOILET" "BATH" "KITCHEN" "SHOP" "CONSULTATION" "WAITING" "PHARMACY" "STUDY" "OFFICE" "GYM" "THEATER" "LOUNGE" "POOJA")
      (if (vl-string-search name (strcase r_name))
        (setq needs_door t)
      )
    )
    
    (setq needs_window t)
    (foreach name '("LAWN" "PORCH" "GARDEN" "OPEN SPACE" "STILT PARKING")
      (if (vl-string-search name (strcase r_name))
        (setq needs_window nil)
      )
    )
    
    (setq door_cands '())
    (setq win_cands '())
    
    (foreach edge edges
      (setq neighbor (nth 5 edge))
      (setq is_open_neighbor nil)
      (if (or (null neighbor)
              (member neighbor '("Lawn" "Lawn/Garden" "Open Space" "Parking" "Stilt Parking" "Garden" "Rear setback" "O.T.S.")))
        (setq is_open_neighbor t)
      )
      (if is_open_neighbor
        (setq win_cands (cons edge win_cands))
        (setq door_cands (cons edge door_cands))
      )
    )
    
    ;; Choose Door
    (if needs_door
      (progn
        (setq selected_door_edge nil)
        (if door_cands
          (setq selected_door_edge (car door_cands))
          (if win_cands
            (setq selected_door_edge (car win_cands))
          )
        )
        (if selected_door_edge
          (progn
            (setq orient (nth 0 selected_door_edge)
                  x1 (nth 1 selected_door_edge)
                  y1 (nth 2 selected_door_edge)
                  x2 (nth 3 selected_door_edge)
                  y2 (nth 4 selected_door_edge))
            (setq is_toilet nil)
            (if (or (vl-string-search "TOILET" (strcase r_name))
                    (vl-string-search "BATH" (strcase r_name)))
              (setq is_toilet t)
            )
            (setq d_size (if is_toilet 30.0 36.0))
            (if (= orient "H")
              (setq cx (/ (+ x1 x2) 2.0) cy y1 swing 1)
              (setq cx x1 cy (/ (+ y1 y2) 2.0) swing 1)
            )
            (setq apertures (cons (list "D" cx cy d_size orient swing) apertures))
          )
        )
      )
    )
    
    ;; Choose Window
    (if (and needs_window win_cands)
      (progn
        (setq selected_win_edge (car win_cands))
        (setq orient (nth 0 selected_win_edge)
              x1 (nth 1 selected_win_edge)
              y1 (nth 2 selected_win_edge)
              x2 (nth 3 selected_win_edge)
              y2 (nth 4 selected_win_edge))
        (setq is_vent nil)
        (if (or (vl-string-search "TOILET" (strcase r_name))
                (vl-string-search "BATH" (strcase r_name))
                (vl-string-search "O.T.S." (strcase r_name)))
          (setq is_vent t)
        )
        (setq w_size (if is_vent 24.0 48.0))
        (if (= orient "H")
          (setq cx (/ (+ x1 x2) 2.0) cy y1)
          (setq cx x1 cy (/ (+ y1 y2) 2.0))
        )
        (setq apertures (cons (list (if is_vent "V" "W") cx cy w_size orient 0) apertures))
      )
    )
  )

  ;; --- 4. TOPOLOGICAL WALL GRAPH & DIVISION GENERATOR ---
  (setq h_walls '())
  (setq v_walls '())
  
  ;; Horizontal walls grid scan
  (setq r 0)
  (while (<= r rows)
    (setq y (nth r yGrid))
    (setq c 0)
    (while (< c cols)
      (setq x1 (nth c xGrid)
            x2 (nth (1+ c) xGrid))
      (setq cell_below (if (> r 0) (get_cell grid (1- r) c) nil))
      (setq cell_above (if (< r rows) (get_cell grid r c) nil))
      
      (setq draw nil thick 4.5)
      (setq open_areas '("Lawn" "Lawn/Garden" "Open Space" "Parking" "Stilt Parking" "Garden" "Rear setback"))
      
      (cond
        ((null cell_below)
         (if (not (member cell_above open_areas))
           (setq draw t thick 9.0)
         ))
        ((null cell_above)
         (if (not (member cell_below open_areas))
           (setq draw t thick 9.0)
         ))
        (t
         (if (/= cell_below cell_above)
           (cond
             ((and (not (member cell_below open_areas)) (not (member cell_above open_areas)))
              (setq draw t thick 4.5)
             )
             ((or (and (member cell_below open_areas) (not (member cell_above open_areas)))
                  (and (not (member cell_below open_areas)) (member cell_above open_areas)))
              (setq draw t thick 9.0)
             )
           )
         ))
      )
      (if draw
        (setq h_walls (cons (list y x1 x2 thick) h_walls))
      )
      (setq c (1+ c))
    )
    (setq r (1+ r))
  )
  
  ;; Vertical walls grid scan
  (setq c 0)
  (while (<= c cols)
    (setq x (nth c xGrid))
    (setq r 0)
    (while (< r rows)
      (setq y1 (nth r yGrid)
            y2 (nth (1+ r) yGrid))
      (setq cell_left (if (> c 0) (get_cell grid r (1- c)) nil))
      (setq cell_right (if (< c cols) (get_cell grid r c) nil))
      
      (setq draw nil thick 4.5)
      (setq open_areas '("Lawn" "Lawn/Garden" "Open Space" "Parking" "Stilt Parking" "Garden" "Rear setback"))
      
      (cond
        ((null cell_left)
         (if (not (member cell_right open_areas))
           (setq draw t thick 9.0)
         ))
        ((null cell_right)
         (if (not (member cell_left open_areas))
           (setq draw t thick 9.0)
         ))
        (t
         (if (/= cell_left cell_right)
           (cond
             ((and (not (member cell_left open_areas)) (not (member cell_right open_areas)))
              (setq draw t thick 4.5)
             )
             ((or (and (member cell_left open_areas) (not (member cell_right open_areas)))
                  (and (not (member cell_left open_areas)) (member cell_right open_areas)))
              (setq draw t thick 9.0)
             )
           )
         ))
      )
      (if draw
        (setq v_walls (cons (list x y1 y2 thick) v_walls))
      )
      (setq r (1+ r))
    )
    (setq c (1+ c))
  )

  ;; --- 5. EXECUTE SPLIT DRAFTING ---
  ;; Draw split horizontal walls
  (foreach wall h_walls
    (setq y (nth 0 wall)
          x1 (nth 1 wall)
          x2 (nth 2 wall)
          thick (nth 3 wall))
    (setq seg_apertures '())
    (foreach ap apertures
      (setq ap_cx (nth 1 ap)
            ap_cy (nth 2 ap)
            ap_size (nth 3 ap)
            ap_orient (nth 4 ap))
      (if (and (= ap_orient "H")
               (< (abs (- ap_cy y)) 1.0)
               (> ap_cx x1)
               (< ap_cx x2))
        (setq seg_apertures (cons ap seg_apertures))
      )
    )
    
    (if (null seg_apertures)
      (draw_wall_double x1 y x2 y thick (if (> thick 6.0) "A-WALL-EXT" "A-WALL-INT"))
      (progn
        (setq seg_apertures (vl-sort seg_apertures '(lambda (a b) (< (cadr a) (cadr b)))))
        (setq curr_x x1)
        (foreach ap seg_apertures
          (setq ap_cx (nth 1 ap)
                ap_size (nth 3 ap))
          (setq gap_start (- ap_cx (/ ap_size 2.0)))
          (setq gap_end (+ ap_cx (/ ap_size 2.0)))
          (if (> gap_start curr_x)
            (draw_wall_double curr_x y gap_start y thick (if (> thick 6.0) "A-WALL-EXT" "A-WALL-INT"))
          )
          (setq curr_x gap_end)
        )
        (if (< curr_x x2)
          (draw_wall_double curr_x y x2 y thick (if (> thick 6.0) "A-WALL-EXT" "A-WALL-INT"))
        )
      )
    )
  )

  ;; Draw split vertical walls
  (foreach wall v_walls
    (setq x (nth 0 wall)
          y1 (nth 1 wall)
          y2 (nth 2 wall)
          thick (nth 3 wall))
    (setq seg_apertures '())
    (foreach ap apertures
      (setq ap_cx (nth 1 ap)
            ap_cy (nth 2 ap)
            ap_size (nth 3 ap)
            ap_orient (nth 4 ap))
      (if (and (= ap_orient "V")
               (< (abs (- ap_cx x)) 1.0)
               (> ap_cy y1)
               (< ap_cy y2))
        (setq seg_apertures (cons ap seg_apertures))
      )
    )
    
    (if (null seg_apertures)
      (draw_wall_double x y1 x y2 thick (if (> thick 6.0) "A-WALL-EXT" "A-WALL-INT"))
      (progn
        (setq seg_apertures (vl-sort seg_apertures '(lambda (a b) (< (caddr a) (caddr b)))))
        (setq curr_y y1)
        (foreach ap seg_apertures
          (setq ap_cy (nth 2 ap)
                ap_size (nth 3 ap))
          (setq gap_start (- ap_cy (/ ap_size 2.0)))
          (setq gap_end (+ ap_cy (/ ap_size 2.0)))
          (if (> gap_start curr_y)
            (draw_wall_double x curr_y x gap_start thick (if (> thick 6.0) "A-WALL-EXT" "A-WALL-INT"))
          )
          (setq curr_y gap_end)
        )
        (if (< curr_y y2)
          (draw_wall_double x curr_y x y2 thick (if (> thick 6.0) "A-WALL-EXT" "A-WALL-INT"))
        )
      )
    )
  )

  ;; --- 6. DRAW COLUMNS ---
  (setq col_idx 1)
  (setq r_idx 0)
  (foreach y yGrid
    (setq c_idx 0)
    (foreach x xGrid
      (setq adj_cells '())
      (if (and (> c_idx 0) (> r_idx 0))
        (setq adj_cells (cons (get_cell grid (1- r_idx) (1- c_idx)) adj_cells))
      )
      (if (and (< c_idx cols) (> r_idx 0))
        (setq adj_cells (cons (get_cell grid (1- r_idx) c_idx) adj_cells))
      )
      (if (and (> c_idx 0) (< r_idx rows))
        (setq adj_cells (cons (get_cell grid r_idx (1- c_idx)) adj_cells))
      )
      (if (and (< c_idx cols) (< r_idx rows))
        (setq adj_cells (cons (get_cell grid r_idx c_idx) adj_cells))
      )
      
      (setq is_open_col t)
      (if adj_cells
        (progn
          (foreach cell adj_cells
            (if (not (member cell '("Lawn" "Lawn/Garden" "Open Space" "Parking" "Stilt Parking" "Garden" "Rear setback")))
              (setq is_open_col nil)
            )
          )
        )
      )
      
      (if (not is_open_col)
        (progn
          (draw_solid_col x y col_w col_h)
          (draw_text (list x (+ y 10.0) 0.0) 6.0 (strcat "C" (itoa col_idx)) "C" "A-TEXT")
          (setq col_idx (1+ col_idx))
        )
      )
      (setq c_idx (1+ c_idx))
    )
    (setq r_idx (1+ r_idx))
  )

  ;; --- 7. DRAW APERTURES ---
  (foreach ap apertures
    (setq ap_type (nth 0 ap)
          ap_cx (nth 1 ap)
          ap_cy (nth 2 ap)
          ap_size (nth 3 ap)
          ap_orient (nth 4 ap)
          ap_swing (nth 5 ap))
    (cond
      ((= ap_type "D")
       (draw_door_symbol ap_cx ap_cy ap_size ap_orient ap_swing)
      )
      ((= ap_type "W")
       (draw_window_symbol ap_cx ap_cy ap_size ap_orient nil)
      )
      ((= ap_type "V")
       (draw_window_symbol ap_cx ap_cy ap_size ap_orient t)
      )
    )
  )

  ;; --- 8. DRAW STAIRS, FIXTURES, AND ROOM LABELS ---
  (foreach room unique_rooms
    (setq r_name (car room)
          cells (cadr room))
    
    (setq c_min (car (car cells))
          c_max (car (car cells))
          r_min (cdr (car cells))
          r_max (cdr (car cells)))
    (foreach cell (cdr cells)
      (if (< (car cell) c_min) (setq c_min (car cell)))
      (if (> (car cell) c_max) (setq c_max (car cell)))
      (if (< (cdr cell) r_min) (setq r_min (cdr cell)))
      (if (> (cdr cell) r_max) (setq r_max (cdr cell)))
    )
    
    (setq rx1 (nth c_min xGrid)
          rx2 (nth (1+ c_max) xGrid)
          ry1 (nth r_min yGrid)
          ry2 (nth (1+ r_max) yGrid))
    (setq rcx (/ (+ rx1 rx2) 2.0)
          rcy (/ (+ ry1 ry2) 2.0))
    (setq r_w (- rx2 rx1)
          r_h (- ry2 ry1))
          
    (cond
      ((vl-string-search "STAIRCASE" (strcase r_name))
       (draw_staircase (+ rx1 6.0) (+ ry1 6.0) (- r_w 12.0) (- r_h 12.0))
      )
      ((or (vl-string-search "TOILET" (strcase r_name))
           (vl-string-search "BATH" (strcase r_name)))
       (draw_toilet_fittings rcx rcy)
       (draw_sink_symbol (+ rx1 15.0) rcy)
      )
      ((vl-string-search "KITCHEN" (strcase r_name))
       (draw_stove_symbol rcx (- ry2 15.0))
       (draw_sink_symbol (- rx2 15.0) (- ry2 15.0))
      )
    )
    
    (setq w_ft_r (/ r_w 12.0)
          h_ft_r (/ r_h 12.0))
    (setq w_ft_int (fix w_ft_r)
          w_in_int (fix (round (* (- w_ft_r w_ft_int) 12.0)))
          h_ft_int (fix h_ft_r)
          h_in_int (fix (round (* (- h_ft_r h_ft_int) 12.0))))
          
    (setq dim_str (strcat (itoa w_ft_int) "'-" (itoa w_in_int) "\" x " (itoa h_ft_int) "'-" (itoa h_in_int) "\""))
    
    (draw_text (list rcx (+ rcy 6.0) 0.0) 10.0 (strcase r_name) "C" "A-TEXT")
    (draw_text (list rcx (- rcy 6.0) 0.0) 8.0 dim_str "C" "A-TEXT")
  )

  ;; --- 9. DRAW CENTERLINE GRID ---
  (setq i 0)
  (foreach x xGrid
    (draw_line (list x (- extW gridExt) 0.0) (list x (+ (- d extW) gridExt) 0.0) "S-GRID-CENTER")
    (draw_circle (list x (- extW gridExt 12.0) 0.0) 12.0 "S-BUBBLE")
    (draw_text (list x (- extW gridExt 16.0) 0.0) 10.0 (nth i xLabels) "C" "S-TEXT")
    (draw_circle (list x (+ (- d extW) gridExt 12.0) 0.0) 12.0 "S-BUBBLE")
    (draw_text (list x (+ (- d extW) gridExt 8.0) 0.0) 10.0 (nth i xLabels) "C" "S-TEXT")
    (setq i (1+ i))
  )
  (setq j 0)
  (foreach y yGrid
    (draw_line (list (- extW gridExt) y 0.0) (list (+ (- w extW) gridExt) y 0.0) "S-GRID-CENTER")
    (draw_circle (list (- extW gridExt 12.0) y 0.0) 12.0 "S-BUBBLE")
    (draw_text (list (- extW gridExt 16.0) (- y 4.0) 0.0) 10.0 (nth j yLabels) "C" "S-TEXT")
    (draw_circle (list (+ (- w extW) gridExt 12.0) y 0.0) 12.0 "S-BUBBLE")
    (draw_text (list (+ (- w extW) gridExt 8.0) (- y 4.0) 0.0) 10.0 (nth j yLabels) "C" "S-TEXT")
    (setq j (1+ j))
  )

  ;; --- 10. DRAW BEAM FRAMING LINES ---
  (setq i 0)
  (while (< i (length xGrid))
    (draw_line (list (nth i xGrid) (nth 0 yGrid) 0.0) (list (nth i xGrid) (nth (1- (length yGrid)) yGrid) 0.0) "S-BEAM-FRAMING")
    (setq i (1+ i))
  )
  (setq j 0)
  (while (< j (length yGrid))
    (draw_line (list (nth 0 xGrid) (nth j yGrid) 0.0) (list (nth (1- (length xGrid)) xGrid) (nth j yGrid) 0.0) "S-BEAM-FRAMING")
    (setq j (1+ j))
  )

  ;; --- 11. DRAW DIMENSIONS ---
  (setvar "CLAYER" "A-DIM")
  (setq i 0)
  (while (< i (1- (length xGrid)))
    (setq p1 (list (nth i xGrid) (- extW gridExt 36.0) 0.0))
    (command "_.dimlinear" 
             (offset_pt (list (nth i xGrid) extW 0.0)) 
             (offset_pt (list (nth (1+ i) xGrid) extW 0.0)) 
             (offset_pt p1))
    (while (> (getvar "CMDACTIVE") 0) (command ""))
    (setq i (1+ i))
  )
  (command "_.dimlinear" 
           (offset_pt (list extW extW 0.0)) 
           (offset_pt (list (- w extW) extW 0.0)) 
           (offset_pt (list (/ w 2.0) (- extW gridExt 60.0) 0.0)))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  
  (setq j 0)
  (while (< j (1- (length yGrid)))
    (setq p1 (list (- extW gridExt 36.0) (nth j yGrid) 0.0))
    (command "_.dimlinear" 
             (offset_pt (list extW (nth j yGrid) 0.0)) 
             (offset_pt (list extW (nth (1+ j) yGrid) 0.0)) 
             (offset_pt p1))
    (while (> (getvar "CMDACTIVE") 0) (command ""))
    (setq j (1+ j))
  )
  (command "_.dimlinear" 
           (offset_pt (list extW extW 0.0)) 
           (offset_pt (list extW (- d extW) 0.0)) 
           (offset_pt (list (- extW gridExt 60.0) (/ d 2.0) 0.0)))
  (while (> (getvar "CMDACTIVE") 0) (command ""))

  ;; --- 12. RCC TABLE & CIVIL NOTES ---
  (setq tx (+ w 100.0))
  (setq ty (- (/ d 2.0) 150.0))
  (setq th 30.0)
  (setvar "CLAYER" "S-TABLE")
  
  (draw_rect (list tx (+ ty (* th 6)) 0.0) (list (+ tx 380.0) (+ ty (* th 7)) 0.0) "S-TABLE")
  (draw_text (list (+ tx 190.0) (+ ty (* th 6) 8.0) 0.0) 11.0 "RCC COLUMN & FOOTING REINFORCEMENT" "C" "S-TEXT")
  
  (draw_table_cell tx (+ ty (* th 5)) 60.0 th "MARK" "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 5)) 60.0 th "SIZE" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 5)) 120.0 th "REBARS" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 5)) 70.0 th "TIES (LINKS)" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 5)) 70.0 th "FOOTINGS" "C")
  
  (draw_table_cell tx (+ ty (* th 4)) 60.0 th "C1-C4" "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 4)) 60.0 th "9\"x12\"" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 4)) 120.0 th "4 Nos #16 + 2 Nos #12" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 4)) 70.0 th "#8 @ 150 c/c" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 4)) 70.0 th "4'6\"x4'6\" (#12)" "C")

  (draw_table_cell tx (+ ty (* th 3)) 60.0 th "C5-C12" "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 3)) 60.0 th "9\"x12\"" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 3)) 120.0 th "4 Nos #16" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 3)) 70.0 th "#8 @ 150 c/c" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 3)) 70.0 th "4'0\"x4'0\" (#12)" "C")

  (draw_table_cell tx (+ ty (* th 2)) 60.0 th "C13-C17" "C")
  (draw_table_cell (+ tx 60.0) (+ ty (* th 2)) 60.0 th "9\"x9\"" "C")
  (draw_table_cell (+ tx 120.0) (+ ty (* th 2)) 120.0 th "4 Nos #12" "C")
  (draw_table_cell (+ tx 240.0) (+ ty (* th 2)) 70.0 th "#8 @ 200 c/c" "C")
  (draw_table_cell (+ tx 310.0) (+ ty (* th 2)) 70.0 th "3'6\"x3'6\" (#10)" "C")

  (setq conc_mix (if (>= w_ft 40) "M25 Grade" "M20 Grade"))
  (draw_rect (list tx ty 0.0) (list (+ tx 190.0) (+ ty (* th 2)) 0.0) "S-TABLE")
  (draw_text (list (+ tx 95.0) (+ ty 30.0) 0.0) 8.0 (strcat "CONCRETE: " conc_mix) "C" "S-TEXT")
  (draw_text (list (+ tx 95.0) (+ ty 12.0) 0.0) 8.0 "STEEL: Fe 500 TMT" "C" "S-TEXT")
  
  (draw_rect (list (+ tx 190.0) ty 0.0) (list (+ tx 380.0) (+ ty (* th 2)) 0.0) "S-TABLE")
  (draw_text (list (+ tx 285.0) (+ ty 30.0) 0.0) 8.0 "COVERS:" "C" "S-TEXT")
  (draw_text (list (+ tx 285.0) (+ ty 12.0) 0.0) 8.0 "Footing: 50mm | Col: 40mm" "C" "S-TEXT")

  ;; --- 13. DRAW TITLE BLOCK ---
  (setq bx tx)
  (setq by (+ ty (* th 8.0)))
  (draw_rect (list bx by 0.0) (list (+ bx 380.0) (+ by 180.0) 0.0) "A-WALL-EXT")
  (draw_line (list bx (+ by 120.0) 0.0) (list (+ bx 380.0) (+ by 120.0) 0.0) "A-WALL-EXT")
  (draw_line (list bx (+ by 60.0) 0.0) (list (+ bx 380.0) (+ by 60.0) 0.0) "A-WALL-EXT")
  (draw_line (list (+ bx 190.0) by 0.0) (list (+ bx 190.0) (+ by 120.0) 0.0) "A-WALL-EXT")
  
  (draw_text (list (+ bx 190.0) (+ by 140.0) 0.0) 14.0 (strcat "PLAN ID: " id) "C" "A-TEXT")
  (draw_text (list (+ bx 95.0) (+ by 80.0) 0.0) 10.0 (strcat "PLOT SIZE: " (itoa w_ft) "' x " (itoa d_ft) "'") "C" "A-TEXT")
  (draw_text (list (+ bx 285.0) (+ by 80.0) 0.0) 10.0 (strcat "FACING: " facing "-FACING") "C" "A-TEXT")
  (draw_text (list (+ bx 95.0) (+ by 25.0) 0.0) 9.0 (strcat "BHK: " (itoa bhk) "BHK | " (if (= ptype "D") "DUPLEX" "SINGLE")) "C" "A-TEXT")
  (draw_text (list (+ bx 285.0) (+ by 25.0) 0.0) 9.0 (strcat "DATE: " (menucmd "M=$(or,$(getvar,date),0)")) "C" "A-TEXT")
  
  ;; Sheet Main Title
  (draw_text (list (/ w 2.0) (+ d gridExt 40.0) 0.0) 18.0 (strcat "PLAN " (itoa idx) ": " (strcase title)) "C" "A-TEXT")

  ;; Restore state
  (setvar "CLAYER" oldClayer)
  (setvar "CMDECHO" oldCmdEcho)
  (setvar "OSMODE" oldOsmode)
  (setvar "HPNAME" oldHpname)
  (princ)
)


;; --- 8. BATCH COMPILER COMMANDS ---
(defun c:compile_plan (/ idx specs oldFiledia)
  (setq idx (getint "\nEnter Plan Index (1-100): "))
  (if (and idx (>= idx 1) (<= idx 100))
    (progn
      ;; Clear screen once
      (command "_.erase" "_all" "")
      (while (> (getvar "CMDACTIVE") 0) (command ""))
      
      (setq specs (get_lisp_plan_specs idx))
      (draw_lisp_plan specs)
      
      ;; Zoom extents at the end
      (command "_.zoom" "_e")
      (while (> (getvar "CMDACTIVE") 0) (command ""))
      
      (princ (strcat "\n[Success] Plan " (itoa idx) " compiled side-by-side!"))
    )
    (princ "\nError: Invalid plan index. Please enter a number between 1 and 100.")
  )
  (princ)
)

(defun c:compile_portfolio (/ idx specs filepath oldFiledia)
  (alert "Starting pure AutoLISP portfolio compilation (100 plans) on a single sheet.\nThis will draw all plans in a 10x10 grid side-by-side. Please wait...")
  
  ;; Clear screen once at the beginning
  (command "_.erase" "_all" "")
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  
  (setq idx 1)
  (while (<= idx 100)
    (princ (strcat "\nCompiling [" (itoa idx) "/100]..."))
    (setq specs (get_lisp_plan_specs idx))
    (draw_lisp_plan specs)
    (setq idx (1+ idx))
  )
  
  ;; Zoom extents at the end
  (command "_.zoom" "_e")
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  
  ;; Save the final combined sheet as a single drawing
  (setq filepath "C:/Users/sarth/New folder (12)/portfolio/all_100_plans.dwg")
  (vl-file-delete filepath)
  
  (setq oldFiledia (getvar "FILEDIA"))
  (setvar "FILEDIA" 0)
  (command "_.saveas" "" filepath)
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (setvar "FILEDIA" oldFiledia)
  
  (alert "Success! All 100 plans compiled side-by-side on a single sheet and saved to 'C:\\Users\\sarth\\New folder (12)\\portfolio\\all_100_plans.dwg'.")
  (princ)
)

(princ "\n--> lisp_portfolio_generator.lsp loaded successfully!")
(princ "\n--> Type COMPILE_PORTFOLIO to compile all 100 plans.")
(princ "\n--> Type COMPILE_PLAN to compile a specific plan index (1-100).\n")
(princ)
