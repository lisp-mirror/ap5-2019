#|
In ABCL I currently rely on a compiler patch to compile ap5.
Also I rely on bordeaux threads, which in turn requires asdf and alexandria.
I've not put these into the ap5 source.
So in order to build ap5 you need to know
- where to find the abcl jar (and java if not on default path)
- where to find the ap5 source
- where to find asdf, alexandria, bordeaux-threads

I'll assume asdf, alexandria, bordeaux-threads are all in the same place,
and that I'll call contrib.
The location of ap5 source (and directories for holding compiled code) 
I call top.

Unfortunately, there is no save image facility for abcl, so in order to
run the compiled code you have to know all the same stuff.

I'm hoping this command will do the build:

$ java -jar [abclpath]abcl-bin-1.5.0/abcl.jar --load [thisfile] --eval "(ap5::recompile)" -- top [ap5path] contrib [contribpath] 
and after that, the same code can be loaded (not recompiled) by
$ java -jar [abclpath]abcl-bin-1.5.0/abcl.jar --load [thisfile] --eval "(ap5::load-ap5)" -- top [ap5path] contrib [contribpath] 
e.g.
java -jar /home/don/Downloads/abcl-bin-1.5.0/abcl.jar --load /tmp1/ap5-2019/source/abcl-build.lisp --eval "(ap5::recompile)" -- top /tmp1/ap5-2019/ contrib /home/don/twrepo/tw/code/3rdParty/

2019-04-01 above command with load-ap5 took 35 sec, 23 for load-ap5 
so 12 sec before load-ap5.  Recompile took 50, so 62 from start of abcl.

|#
(in-package :cl-user)
(defvar *args* EXT:*COMMAND-LINE-ARGUMENT-LIST*)
(defparameter *contrib*
  (or (cadr (member "contrib" *args* :test 'string=))
      (error "need contrib directory location")))
(print "... loading asdf")
(load (merge-pathnames "asdf/asdf.lisp" *contrib*))
(in-package :asdf)
(print "... loading bordeaux")
(load (merge-pathnames "bordeaux-threads-master/bordeaux-threads.asd" cl-user::*contrib*))
(load (merge-pathnames "alexandria-master/alexandria.asd" cl-user::*contrib*))
(require "bordeaux-threads")

(in-package "SYSTEM")
(defun dump-uninterned-symbol-index (symbol)
  ;;; HACK Convert vector form to assoc list
  (when (vectorp *fasl-uninterned-symbols*)
    (setq *fasl-uninterned-symbols*
          (cl:loop
             :for index :upfrom 0
             :for symbol :across *fasl-uninterned-symbols*
               :collecting (cons symbol index))))
  (let ((index (cdr (assoc symbol *fasl-uninterned-symbols*))))
    (unless index
      (setq index (1+ (or (cdar *fasl-uninterned-symbols*) -1)))
      (setq *fasl-uninterned-symbols*
            (acons symbol index *fasl-uninterned-symbols*)))
    index))

(in-package :cl-user) 
(defparameter *top*
  (or (cadr (member "top" *args* :test 'string=))
      (error "need ap5 directory location")))
(print "... loading clisp-build")
(load (merge-pathnames "source/clisp-build.lisp" *top*)) 
