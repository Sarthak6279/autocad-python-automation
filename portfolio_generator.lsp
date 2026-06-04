;;; portfolio_generator.lsp - AutoCAD LISP Command wrapper (Pure AutoLISP Version)
;;;
;;; Commands:
;;;   GENERATE_ALL_PLANS - Generates all 100 plans natively using pure AutoLISP.
;;;   GENERATE_PLAN      - Prompts for a plan index and generates that plan in AutoCAD.
;;;
;;; To Load: (load "C:/Users/sarth/New folder (12)/portfolio_generator.lsp")

(defun c:generate_all_plans ()
  (vl-load-com)
  (load "C:/Users/sarth/New folder (12)/lisp_portfolio_generator.lsp")
  (c:compile_portfolio)
  (princ)
)

(defun c:generate_plan ()
  (vl-load-com)
  (load "C:/Users/sarth/New folder (12)/lisp_portfolio_generator.lsp")
  (c:compile_plan)
  (princ)
)

(princ "\n--> portfolio_generator.lsp loaded successfully!")
(princ "\n--> Type GENERATE_ALL_PLANS to generate all 100 plans using pure AutoLISP.")
(princ "\n--> Type GENERATE_PLAN to generate a specific plan.\n")
(princ)
