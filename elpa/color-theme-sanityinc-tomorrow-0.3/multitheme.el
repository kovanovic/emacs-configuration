(defmacro defmultitheme (theme doc faces &optional variables)
  "Declare THEME to be a Custom theme.
The argument DOC is a doc string describing the theme.

Any theme `foo' should be defined in a file called `foo-theme.el';
see `custom-make-theme-feature' for more information."
  (let ((theme-name (gensym))
        (theme-doc (gensym))
        (face-specs (gensym))
        (var-specs (gensym)))
    `(progn
       (let ((,theme-name ,theme)
             (,theme-doc ,doc)
             (,face-specs ,faces)
             (,var-specs ,variables))
         (custom-declare-theme ,theme-name ,theme-doc)
         (custom-theme-set-faces ,theme-name ,face-specs)
         (custom-theme-set-variables ,theme-name ,var-specs)
         (provide-theme ,theme-name))))
  )



(provide 'multitheme)
