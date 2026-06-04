;;; hello_world.lsp - A simple AutoLISP script to get started in AutoCAD
;;;
;;; To load this script in AutoCAD:
;;; 1. Type APPLOAD in AutoCAD command line and press Enter.
;;; 2. Browse to and select this file, then click "Load".
;;; 3. Or, drag and drop this file from File Explorer into the AutoCAD drawing window.
;;; 4. Or, run: (load "C:/Users/sarth/.gemini/antigravity-ide/scratch/autocad-lisp-scripts/hello_world.lsp")
;;;
;;; Once loaded, type HELLO in the AutoCAD command line to run the command.

(defun c:hello ( / p1 p2 )
  ;; Display a message in the AutoCAD Command Line
  (princ "\nHello from Antigravity! LISP script loaded successfully.")
  
  ;; Show a message box to the user
  (alert "Welcome to AutoLISP scripting! Let's draw a line.")
  
  ;; Prompt user for the first point
  (setq p1 (getpoint "\nSpecify start point: "))
  
  (if p1
    (progn
      ;; Prompt user for the second point, showing a rubber-band line from the first
      (setq p2 (getpoint p1 "\nSpecify end point: "))
      
      (if p2
        (progn
          ;; Draw the line using command function
          (command "_.line" p1 p2 "")
          (princ "\nLine drawn successfully!")
        )
        (princ "\nSecond point not specified. Command cancelled.")
      )
    )
    (princ "\nStart point not specified. Command cancelled.")
  )
  
  ;; Clean exit (suppress returning the last expression's value)
  (princ)
)

(princ "\nType HELLO to run the custom LISP command.\n")
(princ)
