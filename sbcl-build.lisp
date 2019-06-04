#|
I have all sorts of strange problems trying to use the code in compile-ap
in sbcl.  However, the following recipe seems to work and surprisingly well.

sbcl --load /tmp1/ap5-2019/source/clisp-build.lisp --eval "(ap5::global-decls)" --eval "(sb-ext:describe-compiler-policy)" -- top "/tmp1/ap5-2019/"
|#
;;(setf sb-ext::*evaluator-mode* :interpret)
;; interpret mode loads in 4 min

(in-package :ap5)
(loadfile "ap5pkg")
(loadfile "declare")
(load (bin "ansi-loop"))
(cl:loop for f in 
  '("sys-depend" "tryfail" "utilities" "wffs" "wffmacros" "treegen"
    "generators" "implementat" "transactions" "triggers" "macros"
    "relations" "types" "rulerels" "ruledeclare" "final-boot"
    "maint-rels"
    "full-index" "typeconstra" "subtyperules" "countspecs" "disjoint"
    "defrel" "derivation" "stored-place" "idiom-rules" "tools"
    "misc-rules" "ccstub" "slot-place" "ap5-macro-extensions"
    "partial-order" "doc")
  do (loadfile f))
;; loads in 17 sec

;; in compiled mode everything seems to end up compiled so
(sb-ext:save-lisp-and-die
    (format nil "/tmp/ap5-~a~a" *liv* #+mt "MT" #-mt "")
    :executable t)

;; and now /tmp/ap5-1.4.3MT seems to work!

;; search for things in load order
;; grep -il pushassoc sys-depe.lsp tryfail.lsp utilitie.lsp wffs.lsp wffmacro.lsp treegen.lsp generato.lsp implemen.lsp transact.lsp triggers.lsp macros.lsp relation.lsp types.lsp rulerels.lsp ruledecl.lsp final-bo.lsp maint-re.lsp full-ind.lsp typecons.lsp subtyper.lsp countspe.lsp disjoint.lsp defrel.lsp derivati.lsp stored-p.lsp idiom-ru.lsp tools.lsp misc-rul.lsp ccstub.lsp slot-pla.lsp ap5-macr.lsp partial-.lsp doc.lsp