;;; shape_generator.lsp - Advanced AutoLISP script to create layers and draw shapes
;;;
;;; To load: (load "C:/Users/sarth/.gemini/antigravity-ide/scratch/autocad-lisp-scripts/shape_generator.lsp")
;;; Run command: GENSHAPE

(defun c:genshape ( / shapeType center radius p1 p2 oldLayer)
  ;; Save current layer to restore it later
  (setq oldLayer (getvar "CLAYER"))
  
  ;; Set up the "Antigravity_Shapes" layer with a cyan color (4)
  ;; -layer command: Make (M), Name, Color (C), color number, Name, enter to finish
  (command "_.layer" "_make" "Antigravity_Shapes" "_color" "4" "Antigravity_Shapes" "")
  
  ;; Ask user for shape type
  (initget "Circle Rectangle")
  (setq shapeType (getkword "\nWhat shape would you like to draw? [Circle/Rectangle] <Circle>: "))
  
  ;; Default to Circle if user just presses Enter
  (if (not shapeType) (setq shapeType "Circle"))
  
  (cond
    ;; Draw a Circle
    ((= shapeType "Circle")
     (setq center (getpoint "\nSpecify center point for circle: "))
     (if center
       (progn
         (setq radius (getdist center "\nSpecify circle radius: "))
         (if radius
           (progn
             (command "_.circle" center radius)
             (princ "\nCircle created on layer 'Antigravity_Shapes'.")
           )
           (princ "\nInvalid radius.")
         )
       )
     )
    )
    
    ;; Draw a Rectangle
    ((= shapeType "Rectangle")
     (setq p1 (getpoint "\nSpecify first corner of rectangle: "))
     (if p1
       (progn
         (setq p2 (getcorner p1 "\nSpecify opposite corner: "))
         (if p2
           (progn
             (command "_.rectang" p1 p2)
             (princ "\nRectangle created on layer 'Antigravity_Shapes'.")
           )
           (princ "\nInvalid opposite corner.")
         )
       )
     )
    )
  )
  
  ;; Restore the original layer
  (setvar "CLAYER" oldLayer)
  
  ;; Clean exit
  (princ)
)

(princ "\nType GENSHAPE to run the shape generator LISP command.\n")
(princ)
