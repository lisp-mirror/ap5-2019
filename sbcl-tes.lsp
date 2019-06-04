(defvar sbcl-tests nil)
(defvar testnum 0)

(defun test-sbcl()
  (and (fboundp 'relationp) (relationp 'consistencyrule)
             (prevdef '|Test-CONSISTENCYRULE|)))
#+ignore 
(defun test-sbcl(&aux (name (format nil "abcl-test-~a" (incf testnum))))
    (compile (setf name (intern name (find-package :ap5)))
             (prevdef '|Test-CONSISTENCYRULE|))
    (atomic (++ consistencyrule 12 ) reveal
            (push (list name
                        (|Test-CONSISTENCYRULE| 12)
                        (funcall name 12))
                  sbcl-tests)
            (abort 'error "a") :ifabort nil)
    (format t "*** test: ~a" (car sbcl-tests))
    nil)

(trace :break (test-sbcl) show-time)
