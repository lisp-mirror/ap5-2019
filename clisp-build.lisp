#|
Date: Sun, 15 Jun 2008 15:02:45 -0400 
From: Sam Steingold <sds@gnu.org> 
Subject: Re: ap5 build script 

I found this script easier to use than your 2: 
save it in clisp-build.lisp and run like this: 
$ clisp clisp-build.lisp recompile 
$ clisp clisp-build.lisp savemem 
$ ./bin-2.45/ap5 

 2019/02/03 - here's how I currently use it
/tmp1/ap5-2019/source is where I have current ap5 source,
compiled files go into directories /tmp1/ap5-2019/bin-[version]

cd /home/don/clisp/build-mt/full/ 
(./lisp.run -M ./lispinit.mem \
 -i /tmp1/ap5-2019/source/clisp-build.lisp \
 -x "(ap5::recompile)" -- top "/tmp1/ap5-2019/"  && \
 ./lisp.run -M ./lispinit.mem \
 -i /tmp1/ap5-2019/source/clisp-build.lisp \
 -x "(ap5::load-save)" -- top "/tmp1/ap5-2019/")  >> transcript 2>&1

abcl: see file abcl-build (which uses this one)

sbcl: see file sbcl-build (which uses this one)
|#

(in-package :cl-user) 
(defpackage "AP5" (:use "CL") (:nicknames "ap5")) 
(in-package :ap5) 

;; too many warnings about functions not yet defined:
#+sbcl
(defun global-decls()
  (eval-when (:execute :compile-toplevel :load-toplevel)
    (proclaim '(optimize (debug 3)(safety 3)))
    (proclaim '(sb-ext:muffle-conditions SB-INT:TYPE-STYLE-WARNING))
    #+ignore (setf sb-ext::*evaluator-mode* :interpret)))

;; compatibility between clisp and sbcl and abcl
(defvar *args*
  #+abcl EXT:*COMMAND-LINE-ARGUMENT-LIST*
  #+sbcl sb-ext:*posix-argv*
  #+clisp ext:*args*
  #-(or clisp sbcl abcl) (error "don't know how to read command line args"))
#+(or abcl sb-thread) (push :mt *features*)

(format t "*args* = ~a" *args*)

(defparameter *top*
  (or (cadr (member "top" *args* :test 'string=))
      (error "need ap5 directory location")))
(defparameter *lit*
  #+abcl "ABCL" ;; lisp-implementation-type = "Armed Bear Common Lisp"
  #-abcl (lisp-implementation-type))
(defparameter *liv*
  (let ((liv (lisp-implementation-version))) 
    (or (cadr (member "liv" *args* :test 'string=))
	(subseq liv 0 (position #\Space liv)))))
(defparameter *bin* 
  (make-pathname 
   :directory (append (pathname-directory *top*) 
		      (list (concatenate 'string "bin-" *lit* *liv* #+mt "-MT")))
   :defaults *top*))
(load (merge-pathnames "source/compile-.lsp" *top*)) 
(setf source-default-path (merge-pathnames "source/foo.lsp" *top*) 
       bin-default-path (merge-pathnames "foo.fas" *bin*)) 
(ensure-directories-exist bin-default-path :verbose t) 
(defun recompile()(compile-ap5 :recompile t))

#+(or clisp sbcl) ;; abcl currently has no save!
(defun load-save()
  (load-ap5) 
  #+clisp
  (ext:saveinitmem (format nil "/tmp/ap5-~a~a" *liv* #+mt "MT" #-mt "")
		   :executable t :norc t :documentation "AP5")
  #+sbcl
  (sb-ext:save-lisp-and-die (format nil "/tmp/ap5-~a~a" *liv* #+mt "MT" #-mt "")
                            :executable t))

#+ignore 
(ext:fcase equal ext:*args* 
   ((("recompile")) (compile-ap5 :recompile t)) 
   ((("savemem")) (load-ap5) 
    (ext:saveinitmem (merge-pathnames "ap5" *bin*) :executable t :norc t 
        :documentation "AP5")) 
   ((NIL) (format t "usage: ~S [recompile|load]~%" *load-truename*)) 
   (t (error "invalid arguments: ~S" ext:*args*))) 
