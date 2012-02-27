(setq emacs-load-start-time (current-time))

(require 'static)
(shell-command (format "wmctrl -i -r %s -b add,maximized_vert,maximized_horz" (frame-parameter nil 'outer-window-id)) "*Messages*")

(defun log-status-msg (log-msg &optional found-status)
  (if (not found-status)
      (message log-msg)
    (message (concat log-msg (make-string (- 120 (length log-msg)) ?\ ) found-status) )))

(defun log-feature (feature found-status)
  (log-status-msg (format "    Checking for `%s'..." feature) found-status))

(defun section-start (section-name)
  (log-status-msg section-name))

(defun section-end (section-name)
  (log-status-msg section-name "Done"))

;; Erase messages
(progn
  (switch-to-buffer "*Messages*")
  (erase-buffer))

(section-start "* --[ Loading my Emacs init file ]--")

;; elpa initalization
(progn
  (when (load (expand-file-name "~/.emacs.d/elpa/package.el") t t)
    (package-initialize))

  (setq package-archives '(("ELPA" . "http://tromey.com/elpa/")
                           ("marmalade" . "http://marmalade-repo.org/packages/"))))

(section-start "Environment...")
(progn
  ;; OS type --- are we running Microsoft Windows?
  (defvar running-gnu-linux
    (string-match "linux" (prin1-to-string system-type)))

  ;; OS type --- are we running GNU Linux?
  (defmacro GNULinux (&rest body)
    (list 'if (string-match "linux" (prin1-to-string system-type))
          (cons 'progn body)))

  (defmacro XLaunch (&rest body)
    (list 'if (eq window-system 'x)(cons 'progn body)))

  ;; Emacs type --- are we running GNU Emacs?
  (defmacro GNUEmacs (&rest body)
    "Execute any number of forms if running under GNU Emacs."
    (list 'if (string-match "GNU Emacs" (version))
          (cons 'progn body)))

  ;; Emacs version
  (GNUEmacs
   (list emacs-version emacs-major-version emacs-minor-version
         system-type system-name system-configuration
         window-system
         (when (boundp 'aquamacs-version) aquamacs-version)))

  (when running-gnu-linux
    (modify-all-frames-parameters
     '((height . 32))))

  ;; (defadvice load (before debug-log activate)
  ;;   (message "Loading %s..." (locate-library (ad-get-arg 0))))

  ;; load-path enhancement
  (defun fni/add-to-load-path (this-directory &optional with-subdirs recursive)
    "Add THIS-DIRECTORY at the beginning of the load-path, if it exists.
Add all its subdirectories not starting with a '.' if the
optional argument WITH-SUBDIRS is not nil.  Do it recursively if
the third argument is not nil."
    (when (and this-directory
               (file-directory-p this-directory))
      (let* ((this-directory (expand-file-name this-directory))
             (files (directory-files this-directory t "^[^\\.]")))

        ;; completely canonicalize the directory name (*may not* begin with `~')
        (while (not (string= this-directory (expand-file-name this-directory)))
          (setq this-directory (expand-file-name this-directory)))

        ;; (message "Adding `%s' to load-path..." this-directory)
        (add-to-list 'load-path this-directory)

        (when with-subdirs
          (while files
            (setq dir-or-file (car files))
            (when (file-directory-p dir-or-file)
              (if recursive
                  (fni/add-to-load-path dir-or-file 'with-subdirs 'recursive)
                (fni/add-to-load-path dir-or-file)))
            (setq files (cdr files)))))))

  (defvar missing-packages-list nil
    "List of packages that `try-require' can't find.")

  ;; attempt to load a feature/library, failing silently
  (defun try-require (feature)
    "Attempt to load a library or module. Return true if the
library given as argument is successfully loaded. If not, instead
of an error, just add the package to a list of missing packages."
    (condition-case err
        ;; protected form
        (progn
          ;;(log-feature feature)
          (if (stringp feature)
              (load-library feature)
            (require feature))
	  (log-feature feature "Found"))
      ;; error handler
      (file-error                       ; condition
       (progn
	 (log-feature feature "Missing")
         (add-to-list 'missing-packages-list feature 'append))
       nil)))

  (defvar distro-site-lisp-directory
    (concat (or (getenv "SHARE")
                "/usr/share") "/emacs/site-lisp/")
    "Name of directory where additional Emacs goodies Lisp
files (from the distro optional packages) reside.")

  (fni/add-to-load-path distro-site-lisp-directory 'with-subdirs)
  (fni/add-to-load-path "~/.emacs.d"            'with-subdirs)
  (fni/add-to-load-path "~/.emacs.d/lib/manual" 'with-subdirs)
  (fni/add-to-load-path "~/.emacs.d/lib/auto"   'with-subdirs)

  (fni/add-to-load-path "~/.emacs.d/lib/auto/rob_myers_scripts/scripts/" 'with-subdirs)
  (fni/add-to-load-path "~/.emacs.d/lib/auto/anything-config/extensions")

  (fni/add-to-load-path "~/.emacs.d/lib/manual/auctex/preview")
  (fni/add-to-load-path "~/.emacs.d/lib/manual/org-mode/lisp")
  (fni/add-to-load-path "~/.emacs.d/lib/manual/org-mode/contrib/lisp")

  (load "tex.el" nil t t)
  (load "auctex.el" nil t t)
  (load "preview-latex.el" nil t t)

  (defun my-make-directory-yes-or-no (dir)
    "Ask user to create the DIR, if it does not already exist."
    (if dir
        (if (not (file-directory-p dir))
            (if (yes-or-no-p (concat "The directory `" dir
                                     "' does not exist currently. Create it? "))
                (make-directory dir t)
              (error
               (concat "Cannot continue without directory `" dir "'"))))
      (error "my-make-directory-yes-or-no: missing operand")))

  (defun my-file-executable-p (file)
    "Make sure the file FILE exists and is executable."
    (if file
        (if (file-executable-p file)
            file
          (message "WARNING: Can't find executable `%s'" file)
          ;; sleep 1 s so that you can read the warning
          (sit-for 1))
      (error "my-file-executable-p: missing operand"))))
(section-end "Environment")

(section-start "Main Config")

; commans are put here to be faster applied
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode 1)
(set-face-attribute 'default nil :font "Consolas-11")
(try-require 'show-wspace)
(try-require 'wc)
(try-require 'deft)
(try-require 'lorem-ipsum)
(try-require 'unbound)
(try-require 'minimap)
(try-require 'anything-startup)
(try-require 'cursorbymode)

;; show column and line numbers in the modeline
(line-number-mode 1)
(column-number-mode 1)

; highlight current line
(global-hl-line-mode 1)

;; highlight changes in the file
(global-highlight-changes-mode -1)

;; on yanking delete selected text
(delete-selection-mode 1)

;; don't add newlines to end of buffer when scrolling
(setq next-line-add-newlines nil)

(c-set-offset 'substatement-open 0)
(turn-on-font-lock)

;; visually indicate buffer boundaries and scrolling
(setq indicate-buffer-boundaries t)

;; make the help, apropos and completion windows the right height for their
;; contents
(temp-buffer-resize-mode t) ; auto-fit the *Help* buffer to its contents

;; see what I'm typing *immediately*
(setq echo-keystrokes 0.01)

(setq font-lock-maximum-size nil)
(setq anything-c-adaptive-history (quote nil))
(setq message-log-max t)
(setq user-full-name "Vitomir Kovanovic")
(setq doc-view-continuous t)
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(setq auto-save-default nil)
(setq backup-inhibited t)
(setq x-select-enable-clipboard t)
(setq require-final-newline t)
(setq next-line-add-newlines nil)
(setq default-truncate-lines 1)
(setq transient-mark-mode t)
(setq frame-title-format "%b")
(setq default-frame-alist '((vertical-scroll-bars . nil)))
(setq tab-width 4)
(setq c-basic-offset 4)
(setq indent-tabs-mode nil)
(setq search-highlight t)
(setq vc-follow-symlinks t)

(desktop-save-mode 1)

(put 'upcase-region             'disabled nil)
(put 'narrow-to-region          'disabled nil)

;; y and n can be used instead of yes and no
(fset 'yes-or-no-p 'y-or-n-p)
(fset 'vrbem [?\C-d ?\C-  ?\C-s ?| ?\C-f ?\C-b ?\C-b ?\C-c ?\C-f ?\C-e ?\C-f ?\C-d])

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Line numbering
(global-linum-mode 1)
(setq linum-format "%-3d")

;; Parenthesis ------------------------------------------------------------------------------------

(autoload 'paredit-mode "paredit" nil t)
(autoload 'rainbow-delimiters-mode "rainbow-delimiters" nil t)
(show-paren-mode 1)
(setq show-paren-style 'parenthesis)

;; Kill completition buffer after exit of minibufer
(add-hook 'minibuffer-exit-hook
          '(lambda ()
             (let ((buffer "*Completions*"))
               (and (get-buffer buffer)
                    (kill-buffer buffer)))))

;; Mercurial
(autoload 'ahg-status "ahg" nil t)

;; Spelling ------------------------------------------------------------------------------------

(setq ispell-dictionary "en_US")
(setq flyspell-highlight-flag t)

;; Commit After Save ------------------------------------------------------------------------------------

(defun commit-after-save ()
  (let* ((filename (buffer-file-name))
	 (olddir default-directory)
	 (commit-file (concat "    hg add " (buffer-file-name)
			      " && hg commit -m '" filename "'"
			      " && hg push http://localhost:8000")))
    (when (string-match "mscthesis" filename)
      (save-excursion
	(cd "/home/vita/mscthesis/")
	(shell-command commit-file))
      (cd olddir)
      (message "hg backup OK"))))

(add-hook 'after-save-hook           'commit-after-save)

(defun string-prefix (s1 s2)
  (if (> (length s1)
	 (length s2))
      nil
    (string-equal s1
		  (substring s2 0 (length s1)))))

(defun string-postfix (s1 s2)
  (if (> (length s1)
	 (length s2))
      nil
    (string-equal s1
		  (substring s2 (- (length s1))))))

(defun buffer-exists (bufname)
  (not (eq nil (get-buffer bufname))))

;; move (shift) a line of text up or down like you would do in Eclipse
;; pressing `M-up' (or `M-down')
(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (let ((col (current-column))
        start
        end)
    (beginning-of-line)
    (setq start (point))
    (end-of-line)
    (forward-char)
    (setq end (point))
    (let ((line-text (delete-and-extract-region start end)))
      (forward-line n)
      (insert line-text)
      ;; restore point to original column in moved line
      (forward-line -1)
      (forward-char col))))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(defun byte-compile-user-init-file ()
  (let ((byte-compile-warnings '(unresolved)))
    (when (file-exists-p (concat user-init-file ".elc"))
      (delete-file (concat user-init-file ".elc")))
    (byte-compile-file user-init-file)
    (message "%s compiled" user-init-file)))

(defun kill-all-buffers ()
  "using this function user can kill all buffers in emacs. pretty "
  (interactive)
  (when (y-or-n-p "Kill all buffers?")
    (dolist (buf (buffer-list))
      (kill-buffer buf))
    (delete-other-windows)))

(defun insert-empty-line ()
  "insert new empty line"
  (interactive)
  (move-end-of-line nil)
  (open-line 1)
  (next-line 1))

(defun save-macro (name)
  "save a macro. Take a name as argument
     and save the last defined macro under
     this name at the end of your .emacs"
  (interactive "SName of the macro :")  ; ask for the name of the macro
  (kmacro-name-last-macro name)         ; use this name for the macro
  (find-file (user-init-file))                   ; open ~/.emacs or other user init file
  (goto-char (point-max))               ; go to the end of the .emacs
  (newline)                             ; insert a newline
  (insert-kbd-macro name)               ; copy the macro
  (newline)                             ; insert a newline
  (switch-to-buffer nil))               ; return to the initial buffer

(defun set-serbian ()
  (interactive)
  (setq ispell-program-name "hunspell")
  (require 'rw-language-and-country-codes)
  (require 'rw-ispell)
  (require 'rw-hunspell)
  (setq ispell-dictionary "sh_YU")
  (setq rw-hunspell-default-dictionary "en_US")
  (setq rw-hunspell-dicpath-list (quote ("/usr/share/hunspell")))
  (setq rw-hunspell-make-dictionary-menu t)
  (setq rw-hunspell-use-rw-ispell t))

(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir)))))

(defadvice save-buffers-kill-emacs (around no-query-kill-emacs activate)
  "Prevent annoying \"Active processes exist\" query when you quit Emacs."
  (flet ((process-list ())) ad-do-it))

(defun my-wrap-mode-on ()
  "Minor mode for making buffer not wrap long lines to next line."
  (interactive)
  (setq truncate-lines nil))

(defun my-wrap-mode-off ()
  "Minor mode for making buffer wrap long lines to next line."
  (interactive)
  (setq truncate-lines t))

(defun my-toggle-wrap-mode ()
  "Switch wrap mode from wrap to non-wrap, or vice-versa."
  (interactive)
  (if (eq truncate-lines nil)
      (my-wrap-mode-off)
    (my-wrap-mode-on)))

(defun dos-to-unix ()
  "Cut all visible ^M from the current buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (search-forward "\r" nil t)
      (replace-match ""))))

(defun unix-to-dos ()
  "convert a buffer from Unix end of lines to DOS `^M' end of lines"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (search-forward "\n" nil t)
      (replace-match "\r\n"))))

(defmacro switchc (variable &rest conds)
  "Macro for simple cond that acts like switch on string value."
  `(cond ,@(mapcar (lambda (c)
		     `((equal ,variable ,(car c))
		       ,(cdr c))) conds)))

(defmacro vmenu (name msg &rest val-action-pairs)
  "Macro that creates new function with 'name' that defines a menu with
specified options. Each val-action-pair is a dotted pair of
string and elip function name. Also msg is message shown to the user"
  (let ((arg-name (gensym)))
    `(defun ,name(,arg-name)
       (interactive (list
		     (completing-read ,msg ',(mapcar 'car val-action-pairs) nil t))
		    (insert arg))
       (switchc ,arg-name ,@val-action-pairs))))

(vmenu run-vcs "Run desired version control client"
       ("Git"       . (egg-status))
       ("Mercurial" . (ahg-status)))

(vmenu toggle-modes "Toggle mode"
       ("Word count modeline" . (toggle-wc-modeline))
       ("ART bollocks"        . (artbollocks-mode))
       ("Menu bar"            . (menu-bar-mode))
       ("Text wrapping"       . (my-toggle-wrap-mode))
       ("Line numbers"        . (linum-mode)))

(vmenu quick-run "Toggle mode"
       ("Open .emacs"       . (find-file "~/.emacs"))
       ("Reload .emacs"     . (load-file "~/.emacs"))
       ("Open notes"        . (find-file "/media/data2/data/Documents/notes/Notes.org"))
       ("Open bibliography" . (find-file "~/Programming/latex/bibliography/bibliography.tex")))

;; Elscreen
(when
    (try-require 'elscreen)
  (require 'elscreen-buffer-list)
  (setq elscreen-display-screen-number nil)
  (setq elscreen-display-tab nil)

  (defun elscreen-frame-title-update ()
    (when (elscreen-screen-modified-p 'elscreen-frame-title-update)
      (let* ((screen-list (sort (elscreen-get-screen-list) '<))
	     (screen-to-name-alist (elscreen-get-screen-to-name-alist))
	     (title (mapconcat
		     (lambda (screen)
		       (format "%d%s %s"
			       screen (elscreen-status-label screen)
			       (get-alist screen screen-to-name-alist)))
		     screen-list " ")))
	(if (fboundp 'set-frame-name)
	    (set-frame-name title)
	  (setq frame-title-format title)))))

  (eval-after-load "elscreen"
    '(add-hook 'elscreen-screen-update-hook 'elscreen-frame-title-update)))

;; Abbrev
(progn
  (define-abbrev-table 'global-abbrev-table '(("simmilar" "similar" nil 0)
                                              ("teh" "the" nil 0)
                                              ("langauge" "language" nil 0)))

  (setq default-abbrev-mode t))

;; color config
(progn

  (load "~/.emacs.d/elpa/color-theme-solarized-20111121/color-theme-solarized.el" t t)

  (color-theme-solarized-dark)

  (defun s-color (name)
    (let ((index (if window-system
                     (if solarized-degrade 3 2)
                   (if (= solarized-termcolors 256) 3 4))))
      (nth index (assoc name solarized-colors))))

  (defvar sbase00  (s-color 'base00))
  (defvar sbase01  (s-color 'base01))
  (defvar sbase02  (s-color 'base02))
  (defvar sbase03  (s-color 'base03))

  (defvar sbase0   (s-color 'base0))
  (defvar sbase1   (s-color 'base1))
  (defvar sbase2   (s-color 'base2))
  (defvar sbase3   (s-color 'base3))

  (defvar syellow  (s-color 'yellow))
  (defvar sred     (s-color 'red))
  (defvar sorange  (s-color 'orange))
  (defvar smagenta (s-color 'magenta))
  (defvar sviolet  (s-color 'violet))
  (defvar sblue    (s-color 'blue))
  (defvar scyan    (s-color 'cyan))
  (defvar sgreen   (s-color 'green))

  (set-face-attribute 'hl-line nil
                      :background sbase02)

  (set-face-attribute 'region nil
                      :background sbase2)

  (set-face-attribute 'default nil
                      :height 130
                      :family "Consolas"))

;; Compilation
(progn

  (defun compilation-exit-autoclose (status code msg)
    ;; If M-x compile exists with a 0
    (when (and (eq status 'exit) (zerop code))
      ;; then bury the *compilation* buffer, so that C-x b doesn't go there
      (bury-buffer)
      ;; and delete the *compilation* window
      (delete-window (get-buffer-window (get-buffer "*compilation*")))
      (kill-buffer "*compilation*"))
    ;; Always return the anticipated result of compilation-exit-message-function
    (cons msg code))

  (setq compilation-read-command nil)
  (setq compilation-exit-message-function 'compilation-exit-autoclose))

;; Shell
(progn
  (defun n-shell-simple-send (proc command)
    "17Jan02 - sailor. Various commands pre-processing before sending to shell."
    (cond
     ;; Checking for clear command and execute it.
     ((string-match "^[ \t]*clear[ \t]*$" command)
      (comint-send-string proc "\n")
      (erase-buffer))

     ;; Checking for man command and execute it.
     ((string-match "^[ \t]*man[ \t]*" command)
      (comint-send-string proc "\n")
      (setq command (replace-regexp-in-string "^[ \t]*man[ \t]*" "" command))
      (setq command (replace-regexp-in-string "[ \t]+$" "" command))
      ;;(message (format "command %s command" command))
      (funcall 'man command))

     ;; Send other commands to the default handler.
     (t (comint-simple-send proc command))))

  (defun n-shell-mode-hook ()
    "12Jan2002 - sailor, shell mode customizations."
    (local-set-key '[up] 'comint-previous-input)
    (local-set-key '[down] 'comint-next-input)
    (local-set-key '[(shift tab)] 'comint-next-matching-input-from-input)
    (setq comint-input-sender 'n-shell-simple-send))

  (add-hook 'shell-mode-hook 'n-shell-mode-hook)

  (defun repeat-shell-command ()
    "Repeat most recently executed shell command."
    (interactive)
    (save-buffer)
    (or shell-command-history (error "Nothing to repeat."))
    (shell-command (car shell-command-history)))

  (global-set-key (kbd "C-c j") 'repeat-shell-command))

;; Diary
(when
    (try-require 'diary-lib)

  (setq diary-file "~/Documents/notes/Diary")

  (setq view-diary-entries-initially t
        mark-diary-entries-in-calendar t
        number-of-diary-entries 7)

  (add-hook 'diary-display-hook          'fancy-diary-display)
  (add-hook 'today-visible-calendar-hook 'calendar-mark-today))

;; Minibuffer
(progn
  ;; ignore case when reading a file name completion
  (setq read-file-name-completion-ignore-case t)

  ;; minibuffer window expands vertically as necessary to hold the text that you
  ;; put in the minibuffer
  (setq resize-mini-windows t)

  ;; minibuffer completion incremental feedback
  (icomplete-mode)

  ;; ignore case when reading a buffer name
  (setq read-buffer-completion-ignore-case t)

  ;; do not consider case significant in completion (GNU Emacs default)
  (setq completion-ignore-case t)

  ;; dim the ignored part of the file name
  (file-name-shadow-mode 1))

;; Info
(progn

  ;; check all variables and non-interactive functions as well
  (setq apropos-do-all t)

  ;; add apropos help about variables (bind `C-h A' to `apropos-variable')
  (define-key help-map (kbd "A") 'apropos-variable)


  ;; Info documentation browse
  (when (try-require 'info)

    ;; list of directories to search for Info documentation files
    ;; (in the order they are listed)
    (setq Info-directory-list '("./"
				"~/info/"
				"/usr/local/share/info/"
				"/usr/local/info/"
				"/usr/share/info/emacs-snapshot/"
				"/usr/share/info/emacs-23"
				"/usr/share/info/"))

    ;; display symbol definitions, as found in the relevant manual
    ;; (for C, Lisp, and other languages that have documentation in Info)
    (global-set-key (kbd "<C-f6>") 'info-lookup-symbol))

  ;; with `info+.el', you can merge an Info node with its subnodes into
  ;; the same buffer, by calling `Info-merge-subnodes' (bound to `+')
  (try-require 'info+)

  ;; avoid the description of all minor modes
  (defun describe-major-mode ()
    "Describe only `major-mode'."
    (interactive)
    (describe-function major-mode))

  ;; get a Unix manual page and put it in a buffer
  (global-set-key (kbd "<C-f1>") 'man-follow)

  ;; same behavior as woman when manpage is ready
  (setq Man-notify-method 'newframe)

  ;; (setq Man-frame-parameters '((foreground-color . "black")
  ;;                              (background-color . "grey90")
  ;;                              (cursor-color . "black")
  ;;                              (mouse-color . "gold")
  ;;                              (width . 80)
  ;;                              (tool-bar-lines . 0)))

  ;; browse Unix manual pages "W.o. (without) Man"
  (when (try-require 'woman)
    (setq woman-manpath '("/usr/share/man/" "/usr/local/man/"))))

;; Yanking
(progn

  ;;after yank(C-y) and yank-pop(M-y) run indenting
  (defadvice yank (after indent-region activate)
    (if (member major-mode
		'(emacs-lisp-mode scheme-mode lisp-mode c-mode c++-mode
				  objc-mode latex-mode plain-tex-mode python-mode))
	(indent-region (region-beginning) (region-end) nil)))

  (defadvice yank-pop (after indent-region activate)
    (if (member major-mode
		'(emacs-lisp-mode scheme-mode lisp-mode c-mode c++-mode
				  objc-mode latex-mode plain-tex-mode python-mode))
	(indent-region (region-beginning) (region-end) nil))))

;; Mode line customization
(progn
  ;; Extra mode line faces
  (make-face 'mode-line-folder-face)
  (make-face 'mode-line-wc-face)
  (make-face 'mode-line-pos)
  (make-face 'mode-line-80col-face)
  (make-face 'mode-line-filename-face)
  (make-face 'mode-line-maj)
  (make-face 'mode-line-min)
  (make-face 'mode-line-process-face)
  (make-face 'mode-line-read-only-face)
  (make-face 'mode-line-modified-face)

  (defvar wc-modeline-enabled nil)

  (defvar wc-modeline-format-old nil)

  (defun toggle-wc-modeline ()
    (interactive)
    (progn
      (if (not wc-modeline-enabled)
          (progn
            (message "enabling wc")
            (setq wc-modeline-format-old mode-line-format)
            (setq mode-line-format (append mode-line-format '(" wc: " (:propertize (:eval (number-to-string (wc-non-interactive (point-min) (point-max))))
                                                                                   face mode-line-folder-face)))))
        (progn (message "disabling wc")
               (setq mode-line-format wc-modeline-format-old)))
      (setq wc-modeline-enabled (not wc-modeline-enabled))))

  (defvar mode-line-default
    '((:propertize "%4l:" face mode-line-pos)
      (:eval (propertize "%3c" 'face
                         (if (>= (current-column) 80)
                             'mode-line-80col-face
                           'mode-line-pos)))

      mode-line-client
      "  "
      (:eval
       (cond (buffer-read-only
              (propertize " RO " 'face 'mode-line-read-only-face))
             ((buffer-modified-p)
              (propertize " ** " 'face 'mode-line-modified-face))
             (t "      ")))
      "   "
      (:propertize (:eval (shorten-directory default-directory 15))
                   face mode-line-folder-face)

      (:propertize "%b"
                   face mode-line-filename-face)

      " %n "

      (vc-mode vc-mode)

      "  %["
      (:propertize mode-name
                   face mode-line-maj)
      "%] "

      (:eval (propertize (format-mode-line minor-mode-alist)
                         'face 'mode-line-min))

      (:propertize mode-line-process
                   face mode-line-process-face)

      (global-mode-string global-mode-string)))

  (setq-default mode-line-format mode-line-default)

  ;; Helper function
  (defun shorten-directory (dir max-length)
    "Show up to `max-length' characters of a directory name `dir'."
    (let ((path (reverse (split-string (abbreviate-file-name dir) "/")))
          (output ""))
      (when (and path (equal "" (car path)))
        (setq path (cdr path)))
      (while (and path (< (length output) (- max-length 4)))
        (setq output (concat (car path) "/" output))
        (setq path (cdr path)))
      (when path
        (setq output (concat ".../" output)))
      output))

  (set-face-attribute 'mode-line nil
                      :foreground sgreen
                      :background sbase02
                      :inverse-video nil
                      :box (list :line-width 1 :color sgreen))

  (set-face-attribute 'mode-line-pos nil
                      :inherit 'mode-line-face)

  (set-face-attribute 'mode-line-80col-face nil
                      :inherit 'mode-line-position-face
                      :foreground sbase1
                      :background sred)

  (set-face-attribute 'mode-line-read-only-face nil
                      :inherit 'mode-line
                      :foreground sorange)

  (set-face-attribute 'mode-line-modified-face nil
                      :inherit 'mode-line
                      :foreground sred
                      :weight 'bold)

  (set-face-attribute 'mode-line-folder-face nil
                      :inherit 'mode-line)

  (set-face-attribute 'mode-line-filename-face nil
                      :inherit 'mode-line
                      :foreground syellow
                      :weight 'bold)

  (set-face-attribute 'mode-line-process-face nil
                      :inherit 'mode-line
                      :foreground sorange)

  (set-face-attribute 'mode-line-maj nil
                      :inherit 'mode-line
                      :foreground sblue)

  (set-face-attribute 'mode-line-min nil
                      :inherit 'mode-line
                      :foreground scyan)

  (set-face-attribute 'mode-line-wc-face nil
                      :inherit 'mode-line
                      :foreground sorange))

;; Code Folding
(when
    (try-require 'hideshow)

  (defun hs-hook ()
    (hs-minor-mode)
    (hs-hide-all))

  (add-hook 'c-mode-common-hook   'hs-hook)
  (add-hook 'c++-mode-hook        'hs-hook)
  (add-hook 'emacs-lisp-mode-hook 'hs-hook)
  (add-hook 'java-mode-hook       'hs-hook)
  (add-hook 'lisp-mode-hook       'hs-hook)
  (add-hook 'latex-mode-hook      'hs-hook)
  (add-hook 'python-mode-hook     'hs-hook)
  (add-hook 'clojure-mode-hook    'hs-hook)
  (add-hook 'haskell-mode-hook    'hs-hook)
  (add-hook 'go-mode-hook         'hs-hook)
  (add-hook 'sh-mode-hook         'hs-hook))

;; Mac config
(progn
  (setq mac-option-modifier 'control)
  (setq mac-command-modifier 'meta))

;; Scrolling configuration
(when
    (try-require 'smooth-scrolling)

  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
  (setq mouse-wheel-progressive-speed nil)
  (setq mouse-wheel-follow-mouse 't)
  (setq scroll-step 1))

;; Dired
(when
    (try-require 'dired+)
  (try-require 'dired-details+)
  (try-require 'dired-x)
  (try-require 'dired-external-apps)
  (eval-after-load 'dired '(progn (try-require 'joseph-single-dired)))

  (put 'dired-find-alternate-file 'disabled nil)

  (setq-default dired-omit-files-p t)
  (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
  (setq dired-guess-shell-alist-user '(("\\.pdf$" "evince * &")
				       ("\\.py$" "python")
				       ("\\.rar$" "unrar x")
				       ("\\.html?$" "firefox")
				       ("\\.rmvb$" "mplayer -framedrop -zoom -really-quiet"))))

;; Org-mode
(when
    (try-require 'org-install)

  (add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

  (setq org-return-follows-link t)
  (setq org-src-fontify-natively t)
  (setq org-log-done 'note)
  (setq org-agenda-include-diary nil)
  (setq org-agenda-window-frame-fractions '(1.0 . 1.0))
  (setq org-columns-default-format "%88ITEM %8TODO %3PRIORITY %22TAGS")
  (setq org-tags-column 120)

  (setq org-agenda-files '("/media/data2/data/Documents/notes/Notes.org"))

  ;; (setq org-agenda-files (file-expand-wildcards "~/Documents/notes/*.org"))

  (setq org-tag-alist '(("sfu" . ?s)
			("personal" . ?p)
			("izdavanje" . nil)
			("812" . nil)
			("813" . nil)))

  (setq org-todo-keywords
	'((sequence "TODO(t)" "STARTED(s)" "VERIFY(v)" "|" "DONE(d)" "CANCELED(c)")
	  (sequence "EVENT(e)" "|" "DONE(f)")))

  (setq org-todo-keyword-faces
	'(("TODO" . org-warning)
	  ("STARTED" . "yellow")
	  ("EVENT" . "#bd3612")
	  ("CANCELED" . (:foreground "blue" :weight bold))))

  (setq org-link-frame-setup '((vm . vm-visit-folder-other-frame)
			       (gnus . org-gnus-no-new-news)
			       (file . find-file)
			       (wl . wl-other-frame)))

  (org-babel-do-load-languages 'org-babel-load-languages
			       '((sh . true)
				 (python . true)
				 (R . true)
				 (java . true)
				 (clojure . true)))

  (add-hook 'org-mode-hook '(lambda ()
			      (define-key org-mode-map [(control tab)] nil)))

  (global-set-key (kbd "C-c t") 'org-store-link)
  (global-set-key (kbd "C-c c") 'org-capture)
  (global-set-key (kbd "C-c a") 'org-agenda)
  (global-set-key (kbd "C-c s") 'org-iswitchb)

  (set-face-attribute 'org-todo nil
                      :background sbase03
                      :foreground sred
                      :weight 'bold)

  (set-face-attribute 'org-column nil
                      :background sbase03
                      :foreground sblue)

  (set-face-attribute 'org-column-title nil
                      :background sbase02
                      :foreground scyan
                      :underline t
                      :weight 'bold))

;; ERC
(when
    (try-require 'erc)
  (setq erc-header-line-format nil)
  (setq erc-header-line-uses-tabbar-p t)
  (setq erc-mode-line-format "%t")

  (when (try-require 'erc-join)
    (erc-autojoin-mode 1))

  (defun myerc-join-channels (&rest channels)
    (interactive)
    (mapc 'erc-join-channel channels))

  (setq erc-autojoin-channels-alist
        '(("freenode.net" "#emacs")))

  (when (try-require 'erc-match)
    (setq erc-keywords '("vitomir"))
    (erc-match-mode))

  (when (try-require 'erc-track)
    (erc-track-mode t))

  (add-hook 'erc-mode-hook
            '(lambda ()
               (require 'erc-pcomplete)
               (pcomplete-erc-setup)
               (erc-completion-mode 1)))

  (when (try-require 'erc-fill)
    (setq erc-fill-column 135)
    (erc-fill-mode t))

  (when (try-require 'erc-netsplit)
    (erc-netsplit-mode t))

  ;; timestamps
  (setq erc-timestamp-only-if-changed-flag nil)
  (setq erc-timestamp-format "%H:%M ")
  (setq erc-user-full-name "Vitomir Kovanovic")
  (setq erc-email-userid "kovanovic@gmail.com")
  (setq erc-fill-prefix "      ")
  (setq erc-insert-timestamp-function 'erc-insert-timestamp-left)
  (erc-timestamp-mode t)

  (erc-button-mode t)

  ;; logging
  (setq erc-log-insert-log-on-open nil)
  (setq erc-log-channels t)
  (setq erc-log-channels-directory "~/.irclogs/")
  (setq erc-save-buffer-on-part t)
  (setq erc-hide-timestamps nil)

  (defadvice save-buffers-kill-emacs (before save-logs (arg) activate)
    (save-some-buffers t (lambda () (when (and (eq major-mode 'erc-mode)
                                               (not (null buffer-file-name)))))))

  (add-hook 'erc-insert-post-hook 'erc-save-buffer-in-logs)
  (add-hook 'erc-mode-hook '(lambda () (when (not (featurep 'xemacs))
                                         (set (make-variable-buffer-local
                                               'coding-system-for-write)
                                              'emacs-mule))))

  ;; Truncate buffers so they don't hog core.
  (setq erc-max-buffer-size 20000)
  (defvar erc-insert-post-hook)
  (add-hook 'erc-insert-post-hook 'erc-truncate-buffer)
  (setq erc-truncate-buffer-on-save t)

  (defun erc-cmd-FLUSH (&rest ignore)
    "Erase the current buffer."
    (interactive)
    (let ((inhibit-read-only t))
      (erase-buffer)
      (message "Flushed contents of channel")
      t))

  (vmenu join-freenode-channels "Which channels you want to join: "
         ("Lisp"    . (myerc-join-channels "#lisp"))
         ("LaTeX"   . (myerc-join-channels "#latex"))
         ("Clojure" . (myerc-join-channels "#clojure" "#compojure" "#seajure" "#clojure-web"))
         ("Haskell" . (myerc-join-channels "#haskell"))
         ("Python"  . (myerc-join-channels "#python" "#python-unregistered"))
         ("Web Dev" . (myerc-join-channels "#jquery" "#javascript" "#css"))
         ("Bash"    . (myerc-join-channels "#bash"))
         ("Go"      . (myerc-join-channels "#go-nuts")))

  (vmenu connect-to-chat "Connect to: "
         ("Bumblebee" . (erc :server "localhost" :port 6667 :nick "vita" :full-name erc-user-full-name))
         ("Freenode"  . (erc :server "irc.freenode.net" :port 6667 :nick "vitomir" :full-name erc-user-full-name))))

;; Gnus
(when
    (try-require 'gnus)
  (setq gnus-large-newsgroup 3000)
  (setq gnus-save-killed-list nil)
  (setq gnus-invalid-group-regexp "[:`'\"]\\|^$")
  (setq mail-host-address "kovanovic.info")
  (setq user-full-name "Vitomir Kovanovic")
  (setq user-mail-address "kovanovic@gmail.com")
  (setq gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject)
  (setq send-mail-function 'smtpmail-send-it)
  (setq gnus-agent nil)
  (setq gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

  (setq gnus-check-new-newsgroups 'ask-server)
  (setq gnus-use-dribble-file t)
  (setq gnus-always-read-dribble-file t)
  (setq gnus-read-newsrc-file t)

  (setq gnus-subscribe-newsgroup-method 'gnus-subscribe-alphabetically)

  (setq gnus-select-method '(nnimap "gmail"
                                    (nnimap-address "imap.gmail.com")
                                    (nnimap-server-port 993)
                                    (nnimap-stream ssl)))

  (setq message-send-mail-function 'smtpmail-send-it
        smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
        smtpmail-auth-credentials '(("smtp.gmail.com" 587 "kovanovic@gmail.com" "dustinlatimer"))
        smtpmail-default-smtp-server "smtp.gmail.com"
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587
        smtpmail-local-domain "kovanovic.info")

  (setq gnus-posting-styles
        '((".*"
           (name "Vitomir Kovanovic")
           ("X-URL" "http://blog.kovanovic.info/"))))

  (defun gmail-delete ()
    (interactive)
    (gnus-summary-move-article 1 "[Gmail]/Trash")
    (gnus-summary-rescan-group))

  (add-hook 'gnus-group-mode-hook '(lambda ()
                                     (gnus-topic-mode)
                                     (gnus-group-list-all-groups)))

  (add-hook 'gnus-summary-mode-hook '(lambda ()
                                       (local-set-key [(control x) (control d)] 'gmail-delete)))
  (add-hook 'message-sent-hook '(lambda ()
                                  (save-buffer "*mail*")
                                  (kill-buffer "*mail*")
                                  (kill-buffer "*trace of SMTP session to smtp.gmail.com*"))))

;; Tramp
(when
    (try-require 'tramp)

  (defvar find-file-root-history nil
    "History list for files found using `find-file-root'.")

  (defvar find-file-root-hook nil
    "Normal hook for functions to run after finding a \"root\" file.")

  (defun find-file-root ()
    "*Open a file as the root user.
   Prepends `find-file-root-prefix' to the selected file name so that it
   maybe accessed via the corresponding tramp method."

    (interactive)
    (let* ( ;; We bind the variable `file-name-history' locally so we can
           ;; use a separate history list for "root" files.
           (file-name-history find-file-root-history)
           (name (or buffer-file-name default-directory))
           (tramp (and (tramp-tramp-file-p name)
                       (tramp-dissect-file-name name)))
           path dir file)

      ;; If called from a "root" file, we need to fix up the path.
      (when tramp
        (setq path (tramp-file-name-localname tramp)
              dir (file-name-directory path)))

      (when (setq file (read-file-name "Find file (UID = 0): " dir path))
        (find-file (concat "/sudo:root@eldamar:" file))
        ;; If this all succeeded save our new history list.
        (setq find-file-root-history file-name-history)
        ;; allow some user customization
        (run-hooks 'find-file-root-hook))))

  (global-set-key [(control x) (control r)] 'find-file-root)

  ;; Kill Tramp buffer after exit

  (setq tramp-deletion-started nil)

  (defun trump-buffer (buffer)
    (eq 0 (string-match "*tramp" (buffer-name buffer))))

  (defun find-trump-buffer (buffers)
    (if (not buffers)
        nil
      (let ((current-buffer (car buffers)))
        (if (trump-buffer current-buffer)
            current-buffer
          (find-trump-buffer (cdr buffers))))))

  (defun kill-trump-log-file ()
    (let ((trump-buffer (find-trump-buffer (buffer-list))))
      (when (and trump-buffer
                 buffer-file-name
                 (string-match "sudo" buffer-file-name)
                 (not tramp-deletion-started))
        (setq tramp-deletion-started t)
        (kill-buffer trump-buffer)
        (setq tramp-deletion-started nil))))

  (add-hook 'kill-buffer-hook 'kill-trump-log-file))

;; Ack
(when
    (try-require 'full-ack)
  (autoload 'ack-same "full-ack" nil t)
  (autoload 'ack "full-ack" nil t)
  (autoload 'ack-find-same-file "full-ack" nil t)
  (autoload 'ack-find-file "full-ack" nil t))

;; Artbollocks
(when
    (try-require 'artbollocks-mode)
  (setq lexical-illusions nil)
  (setq artbollocks nil)

  (set-face-attribute 'font-lock-artbollocks-face nil
                      :background sbase03
                      :foreground sorange)

  (set-face-attribute 'font-lock-lexical-illusions-face nil
                      :background sbase03
                      :foreground sred)

  (set-face-attribute 'font-lock-passive-voice-face nil
                      :background sbase03
                      :foreground sviolet)

  (set-face-attribute 'font-lock-weasel-words-face nil
                      :background sbase03
                      :foreground scyan))

;; Mark more like this
(when
    (try-require 'mark-more-like-this)
  (global-set-key (kbd "C-<") 'mark-previous-like-this)
  (global-set-key (kbd "C->") 'mark-next-like-this)
  ;; like the other two, but takes an argument (negative is previous)
  (global-set-key (kbd "C-M-m") 'mark-more-like-this))

;; Jump char
(when
    (try-require 'jump-char)
  (global-set-key [(meta m)] 'jump-char-forward)
  (global-set-key [(shift meta m)] 'jump-char-backward))

;; EGG
(when
    (try-require 'egg))

;; Code Completition
(when
    (and (try-require 'auto-complete)
         (try-require 'auto-complete-config))

  (setq ac-dictionary-directories '("~/.emacs.d/lib/auto-complete-latex/ac-l-dict/"
                                    "~/.emacs.d/lib/auto-complete/dict"))

  ;; Use dictionaries by default
  (global-auto-complete-mode t)

  ;; Start auto-completion after 2 characters of a word
  (setq ac-auto-start 2)

  ;; case sensitivity is important when finding matches
  (setq ac-ignore-case nil)

  (when (try-require 'yasnippet)
    (yas/initialize)
    ;; Load the snippet files themselves
    (yas/load-directory "~/.emacs.d/yasnippet/snippets/text-mode/")
    (yas/load-directory "/usr/share/emacs/site-lisp/yasnippet/snippets/text-mode/")

    (defun ac-yasnippet-candidate ()
      (let ((table (yas/get-snippet-tables major-mode)))
        (if table
            (let (candidates (list))
              (mapcar (lambda (mode)
                        (maphash (lambda (key value)
                                   (push key candidates))
                                 (yas/snippet-table-hash mode)))
                      table)
              (all-completions ac-prefix candidates)))))

    (defface ac-yasnippet-candidate-face
      '((t (:background "sandybrown" :foreground "black")))
      "Face for yasnippet candidate.")

    (defface ac-yasnippet-selection-face
      '((t (:background "coral3" :foreground "white")))
      "Face for the yasnippet selected candidate.")

    (defvar ac-source-yasnippet
      '((candidates . ac-yasnippet-candidate)
        (action . yas/expand)
        (limit . 3)
        (candidate-face . ac-yasnippet-candidate-face)
        (selection-face . ac-yasnippet-selection-face))
      "Source for Yasnippet.")

    (setq-default ac-sources (add-to-list 'ac-sources 'ac-source-yasnippet))
    (setq yas/trigger-key (kbd "C-c C-v")))

  ;; Let's have snippets in the auto-complete dropdown
  (add-to-list 'ac-sources 'ac-source-dictionary))

;; Rectangle mark
(when
    (try-require 'rect-mark)
  (autoload 'rm-set-mark                "rect-mark" "Set mark for rectangle." t)
  (autoload 'rm-exchange-point-and-mark "rect-mark" "Exchange point and mark for rectangle." t)
  (autoload 'rm-kill-region             "rect-mark" "Kill a rectangular region and save it in the kill ring." t)
  (autoload 'rm-kill-ring-save          "rect-mark" "Copy a rectangular region to the kill ring." t)

  (global-set-key (kbd "C-x r C-SPC") 'rm-set-mark)
  (global-set-key (kbd "C-x r C-x")   'rm-exchange-point-and-mark)
  (global-set-key (kbd "C-x r C-w")   'rm-kill-region)
  (global-set-key (kbd "C-x r M-w")   'rm-kill-ring-save))

;; IBuffer
(when
    (try-require 'ibuffer)
  (setq ibuffer-saved-filter-groups
        '(("default"
           ("latex" (or (mode . latex-mode)
                        (mode . bibtex-mode)))
           ("shells" (or (mode . term-mode)
                         (name . "*Python*")
                         (name . "shell")
                         (name . "^\\*shell\\*$")
                         (name . "^\\*slime-repl clojure\\*$")))
           ("erc"   (mode . erc-mode))
           ("planner" (or
                       (name . "^\\*Calendar\\*$")
                       (name . "^diary$")
                       (mode . org-mode)
                       (mode . org-agenda-mode)))
           ("gnus" (or
                    (mode . message-mode)
                    (mode . bbdb-mode)
                    (mode . mail-mode)
                    (mode . gnus-group-mode)
                    (mode . gnus-summary-mode)
                    (mode . gnus-article-mode)
                    (name . "^\\.bbdb$")
                    (name . "^\\*Group\\*$")
                    (name . "^\\.newsrc-dribble"))))))

  (add-hook 'ibuffer-mode-hook
            (lambda ()
              (ibuffer-switch-to-saved-filter-groups "default")
              (setq ibuffer-formats
                    '((mark modified read-only " "
                            (name 38 38 :left :elide)
                            " "
                            filename-and-process)))
              (add-to-list 'ibuffer-never-show-predicates "^\\*any")
              (add-to-list 'ibuffer-never-show-predicates "^\\*Compile-Log*\\*$")))

  (setq ibuffer-show-empty-filter-groups nil)

  (defadvice ibuffer-update-title-and-summary (after remove-column-titles)
    (save-excursion
      (set-buffer "*Ibuffer*")
      (toggle-read-only 0)
      (goto-char 1)
      (search-forward "-\n" nil t)
      (delete-region 1 (point))
      (let ((window-min-height 1))
        ;; save a little screen estate
        (shrink-window-if-larger-than-buffer))
      (toggle-read-only)))

  (ad-activate 'ibuffer-update-title-and-summary)
  (setq ibuffer-use-header-line nil))

;; Bookmarks
(progn

  ;; bookmarks file
  (setq bookmark-default-file "~/.emacs.d/bookmarks.txt")

  ;; each command that sets a bookmark will also save your bookmarks
  (setq bookmark-save-flag 1)

  ;; BM File local bookmarks
  (when (try-require 'bm)

    ;; key binding
    (global-set-key (kbd "<C-f9>")  'bm-show)
    (global-set-key (kbd "<C-f10>") 'bm-previous)
    (global-set-key (kbd "<C-f11>") 'bm-next)
    (global-set-key (kbd "<C-f12>") 'bm-toggle)

    (set-face-attribute 'bm-persistent-face nil
			:foreground sbase0
			:background sbase02)

    ;; repository should be restored when loading `bm'
    (setq bm-restore-repository-on-load t)

    ;; buffer should be recentered around the bookmark
    (setq bm-recenter t)

    ;; make bookmarks persistent as default
    (setq-default bm-buffer-persistence t)

    ;; loading the repository from file when on start up
    (add-hook' after-init-hook 'bm-repository-load)

    ;; restoring bookmarks when on file find
    (add-hook 'find-file-hooks 'bm-buffer-restore)

    ;; saving bookmark data on killing a buffer
    (add-hook 'kill-buffer-hook 'bm-buffer-save)

    ;; saving the repository to file when on exit
    ;; `kill-buffer-hook' is not called when emacs is killed, so we
    ;; must save all bookmarks first
    (add-hook 'kill-emacs-hook '(lambda nil
				  (bm-buffer-save-all)
				  (bm-repository-save)))

    ;; update bookmark repository when saving the file
    (add-hook 'after-save-hook 'bm-buffer-save)
    ;; lists all bookmarks in all buffers
    (try-require 'bm-ext))
)

;; Isearch
(progn

  ;; always exit searches at the beginning of the expression found
  (add-hook 'isearch-mode-end-hook 'custom-goto-match-beginning)

  (defun custom-goto-match-beginning ()
    "Use with isearch hook to end search at first char of match."
    (when isearch-forward (goto-char isearch-other-end)))

  ;; occur from isearch
  (defun isearch-occur ()
    "Invoke `occur' from within isearch."
    (interactive)
    (let ((case-fold-search isearch-case-fold-search))
      (occur (if isearch-regexp isearch-string (regexp-quote isearch-string)))))

  (define-key isearch-mode-map (kbd "C-o") 'isearch-occur))

;; Iflipb
(when
    (try-require 'iflipb)

  (setq iflipb-cucle-buffers t)
  (setq iflipb-buffer-name-length 15)

  (setq iflipb-ignore-buffers '())
  (add-to-list 'iflipb-ignore-buffers "^\\*Ibuffer*\\*$")
  (add-to-list 'iflipb-ignore-buffers "^\\*Ibuffer-bs*\\*$")
  (add-to-list 'iflipb-ignore-buffers "^\\*Compile-Log*\\*$")
  (add-to-list 'iflipb-ignore-buffers "^\\*Help*\\*$")
  (add-to-list 'iflipb-ignore-buffers "^\\*anything*\\*$")
  (add-to-list 'iflipb-ignore-buffers "^\\*anything complete*\\*$")
  (add-to-list 'iflipb-ignore-buffers "output*\\*$")

  ;; (add-to-list 'iflipb-ignore-buffers "^\\*Messages*\\*$")
  ;; (add-to-list 'iflipb-ignore-buffers "^\\*scratch*\\*$")
)

;; Answers define
(defun answers-define ()
  "Look up the word under cursor in a browser."
  (interactive)
  (browse-url
   (concat "http://www.answers.com/main/ntquery?s="
           (thing-at-point 'word))))

;; Browser Kill-Ring
(when (try-require 'browse-kill-ring)

  (setq browse-kill-ring-separator "------------------------------------------------------------------------------------------------------------------------------")

  ;; temporarily highlight the inserted `kill-ring' entry
  (setq browse-kill-ring-highlight-inserted-item t)

  (make-face 'separator-face)
  (setq browse-kill-ring-separator-face 'separator-face)

  (set-face-attribute 'separator-face nil
                      :foreground sblue)


  ;; use `M-y' to invoke `browse-kill-ring'
  (browse-kill-ring-default-keybindings))

;; Shortcuts listings
(progn
 (defun my-keytable (arg)
   "Print the key bindings in a tabular form."
   (interactive "sEnter a modifier string:")
   (with-output-to-temp-buffer "*Key table*"
     (let* ((i 0)
	    (keys (list "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m"
			"n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"
			"<return>" "<down>" "<up>" "<right>" "<left>"
			"<home>" "<end>" "<f1>" "<f2>" "<f3>" "<f4>" "<f5>"
			"<f6>" "<f7>" "<f8>" "<f9>" "<f10>" "<f11>" "<f12>"
			"1" "2" "3" "4" "5" "6" "7" "8" "9" "0"
			"`" "~" "!" "@" "#" "$" "%" "^" "&" "*" "(" ")" "-"
			"_" "=" "+" "\\" "|" "{" "[" "]" "}" ";" "'" ":"
			"\"" "<" ">" "," "." "/" "?"))
	    (n (length keys))
	    (modifiers (list "" "S-" "C-" "M-" "M-C-"))
	    (k))
       (or (string= arg "") (setq modifiers (list arg)))
       (setq k (length modifiers))
       (princ (format " %-10.10s |" "Key"))
       (let ((j 0))
	 (while (< j k)
	   (princ (format " %-28.28s |" (nth j modifiers)))
	   (setq j (1+ j))))
       (princ "\n")
       (princ (format "_%-10.10s_|" "__________"))
       (let ((j 0))
	 (while (< j k)
	   (princ (format "_%-28.28s_|"
			  "_______________________________"))
	   (setq j (1+ j))))
       (princ "\n")
       (while (< i n)
	 (princ (format " %-10.10s |" (nth i keys)))
	 (let ((j 0))
	   (while (< j k)
	     (let* ((binding
		     (key-binding (read-kbd-macro (concat (nth j modifiers)
							  (nth i keys)))))
		    (binding-string "_"))
	       (when binding
		 (if (eq binding 'self-insert-command)
		     (setq binding-string (concat "'" (nth i keys) "'"))
		   (setq binding-string (format "%s" binding))))
	       (setq binding-string
		     (substring binding-string 0 (min (length
						       binding-string) 28)))
	       (princ (format " %-28.28s |" binding-string))
	       (setq j (1+ j)))))
	 (princ "\n")
	 (setq i (1+ i)))
       (princ (format "_%-10.10s_|" "__________"))
       (let ((j 0))
	 (while (< j k)
	   (princ (format "_%-28.28s_|"
			  "_______________________________"))
	   (setq j (1+ j))))))
   (delete-window)
   (hscroll-mode)
   (setq truncate-lines t))

 (defmacro rloop (clauses &rest body)
   (if (null clauses)
       `(progn ,@body)
     `(loop ,@(car clauses) do (rloop ,(cdr clauses) ,@body))))

 (defun all-bindings ()
   (interactive)
   (message "all-bindings: wait a few seconds please...")
   (let ((data
	  (with-output-to-string
	    (let ((bindings '()))
	      (rloop ((for C in '("" "C-"))       ; Control
		      (for M in '("" "M-"))       ; Meta
		      (for A in '("" "A-"))       ; Alt
		      (for S in '("" "S-"))       ; Shift
		      (for H in '("" "H-"))       ; Hyper
		      (for s in '("" "s-"))       ; super
		      (for x from 32 to 127))
		     (let* ((k (format "%s%s%s%s%s%s%c" C M A S H s x))
			    (key (ignore-errors (read-kbd-macro k))))
		       (when key
			 (push
			  (list k
				(format "%-12s  %-12s  %S\n" k key
					(or
					 ;; (string-key-binding key)
					 ;; What is this string-key-binding?
					 (key-binding key))))
			  bindings))))
	      (dolist (item
		       (sort bindings
			     (lambda (a b)
			       (or (< (length (first a))
				      (length (first b)))
				   (and (= (length (first a))
					   (length (first b)))
					(string< (first a)
						 (first b)))))))
		(princ (second item)))))))
     (switch-to-buffer (format "Keybindings in %s" (buffer-name)))
     (erase-buffer)
     (insert data)
     (goto-char (point-min))
     (values))))

;; Shortcuts config
(progn

  ;; Tab and Window Switching

  (global-set-key (kbd "s-<tab>")    nil)
  (global-set-key (kbd "C-<return>") 'other-window)

  (global-set-key (kbd "C-<tab>")           'iflipb-next-buffer)
  (global-set-key (kbd "C-S-<iso-lefttab>") 'iflipb-previous-buffer)

  ;; (global-set-key (kbd "C-<tab>")           'cycbuf-switch-to-next-buffer-no-timeout)
  ;; (global-set-key (kbd "C-S-<iso-lefttab>") 'cycbuf-switch-to-previous-buffer-no-timeout)


  (global-set-key (kbd "C-`")        'other-window)
  (global-set-key (kbd "C-x C-b")    'anything)
  (global-set-key (kbd "C-x b")      'anything)
  (global-set-key (kbd "M-i")        'ibuffer)

  ;; Mix shortcuts

  (global-set-key (kbd "C-x C-m")    'execute-extended-command)
  (global-set-key (kbd "C-c C-m")    'execute-extended-command)
  (global-set-key (kbd "C-q")        'backward-kill-word)
  (global-set-key (kbd "C-w")        'kill-region)
  (global-set-key (kbd "C-x K")      'kill-all-buffers)
  (global-set-key (kbd "M-S-<up>")   'move-line-up)       ;; alt-shift-up
  (global-set-key (kbd "M-S-<down>") 'move-line-down)   ;; alt-shift-down
  (global-set-key (kbd "s-<return>") 'insert-empty-line)

  (global-set-key (kbd "M-g w")      'what-line)

  (global-set-key (kbd "C-x 9") (lambda ()
                                  (interactive)
                                  (other-window 1)
                                  (kill-buffer)
                                  (delete-window)))

  ;; F1 - F12

  (global-set-key (kbd "<f1>")  'menu-bar-open)
  (global-set-key (kbd "<f2>")  'shell)
  (global-set-key (kbd "<f3>")  'run-python)
  (global-set-key (kbd "<f4>")  'clojure-jack-in)
  (global-set-key (kbd "<f5>")  'undo)
  (global-set-key (kbd "<f6>")  'info)
  (global-set-key (kbd "<f7>")  nil)
  (global-set-key (kbd "<f8>")  nil)
  (global-set-key (kbd "<f9>")  nil)
  (global-set-key (kbd "<f10>") 'run-vcs)
  (global-set-key (kbd "<f11>") 'toggle-modes)
  (global-set-key (kbd "<f12>") 'quick-run)

  ;; redo the most recent undo
  (when (try-require 'redo+)
    (global-set-key (kbd "<S-f5>") 'redo))

  ;; Outline mode shortcuts

  (define-prefix-command 'cm-map nil "Outline-")
  (global-set-key    "\M-e"  cm-map)

  ;; Show this heading's body
  (define-key cm-map "e"    'show-entry)
  ;; Hide body lines in this entry and sub-entries
  (define-key cm-map "\M-e" 'hide-entry)
  ;; Show (expand) everything in this heading & below
  (define-key cm-map "r"    'show-subtree)
  ;; Hide everything in this entry and sub-entries
  (define-key cm-map "\M-r" 'hide-leaves)
  ;; Show (expand) everything
  (define-key cm-map "a"    'show-all)
  ;; Hide everything but headings (all body lines)
  (define-key cm-map "\M-a" 'hide-body))

(section-end "Main Config")

(section-start "Langauges")
;; Lisp
(progn
  (setq lisp-body-indent 2)

  ;; Pretty Lambda
  (when
      (try-require 'lambda-mode)
    (setq lambda-symbol (string #x1d77a))

    (defun toggle-lambda-mode ()
      (lambda-mode 1))

    (add-hook 'emacs-lisp-mode-hook 'toggle-lambda-mode)
    (add-hook 'clojure-mode-hook 'toggle-lambda-mode)
    (add-hook 'scheme-mode-hook 'lispy-modes)
    (add-hook 'lisp-mode-hook 'lispy-modes)
    (add-hook 'lisp-interaction-mode-hook 'lispy-modes))

  ;; Slime
  (when
      (try-require 'slime)
    (setq slime-log-events nil)
    (setq slime-startup-animation nil)

    (when (try-require 'ac-slime)
      (add-hook 'slime-mode-hook 'set-up-slime-ac)))

  (defun lispy-modes ()
    (rainbow-delimiters-mode 1)
    (paredit-mode 1))

  (add-hook 'emacs-lisp-mode-hook 'lispy-modes)
  (add-hook 'clojure-mode-hook 'lispy-modes)
  (add-hook 'scheme-mode-hook 'lispy-modes)
  (add-hook 'lisp-mode-hook 'lispy-modes)
  (add-hook 'lisp-interaction-mode-hook 'lispy-modes))

;; Scheme
(when
    (try-require 'cmuscheme)
  (setq scheme-program-name "csi -:c")
  (define-key scheme-mode-map "\C-c\C-l" 'scheme-load-current-file)
  (define-key scheme-mode-map "\C-c\C-k" 'scheme-compile-current-file)

  (defun scheme-load-current-file (&optional switch)
    (interactive "P")
    (let ((file-name (buffer-file-name)))
      (comint-check-source file-name)
      (setq scheme-prev-l/c-dir/file (cons (file-name-directory    file-name)
					   (file-name-nondirectory file-name)))
      (comint-send-string (scheme-proc) (concat "(load \""
						file-name
						"\"\)\n"))
      (if switch
	  (switch-to-scheme t)
	(message "\"%s\" loaded." file-name) ) ) )

  (defun scheme-compile-current-file (&optional switch)
    (interactive "P")
    (let ((file-name (buffer-file-name)))
      (comint-check-source file-name)
      (setq scheme-prev-l/c-dir/file (cons (file-name-directory    file-name)
					   (file-name-nondirectory file-name)))
      (message "compiling \"%s\" ..." file-name)
      (comint-send-string (scheme-proc) (concat "(compile-file \""
						file-name
						"\"\)\n"))
      (if switch
	  (switch-to-scheme t)
	(message "\"%s\" compiled and loaded." file-name)))))

;; Clojure
(when
    (try-require 'clojure-mode)

  (defmacro defclojureface (name color desc &optional others)
    `(defface ,name '((((class color)) (:foreground ,color ,@others))) ,desc :group 'faces))

  (defclojureface clojure-parens "DimGrey" "Clojure parens")
  (defclojureface clojure-braces "#49b2c7" "Clojure braces")
  (defclojureface clojure-brackets "SteelBlue" "Clojure brackets")
  (defclojureface clojure-keyword "#4cbbd1" "Clojure keywords" (:background "#0e2125"))
  (defclojureface clojure-namespace "red" "Clojure namespace")
  (defclojureface clojure-java-call "#4bcf68" "Clojure Java calls")
  (defclojureface clojure-special "#5dff9e" "Clojure special" (:background "#0f291a"))
  (defclojureface clojure-double-quote "#5dff9e" "Clojure special" (:background "#0f291a"))

  (defun tweak-clojure-syntax ()
    (mapcar (lambda (x) (font-lock-add-keywords nil x))
	    '((("#?['`]*(\\|)" . 'clojure-parens))
	      (("#?\\^?{\\|}" . 'clojure-brackets))
	      (("\\[\\|\\]" . 'clojure-braces))
	      ((":\\w+" . 'clojure-keyword))
	      (("#?\"" 0 'clojure-double-quote prepend))
	      (("nil\\|true\\|false\\|%[1-9]?" . 'clojure-special))
	      (("(\\(\\.[^ \n)]*\\|[^ \n)]+\\.\\|new\\)\\([ )\n]\\|$\\)" 1 'clojure-java-call))
	      )))
  (add-hook 'clojure-mode-hook 'tweak-clojure-syntax)

  (defun clojure-etags (project-root)
    "Create tags file for clojure project."
    (interactive "DProject Root:")
    (eshell-command
     (format "find %s/src -name \'*.clj\' | xargs etags --regex=@/home/vita/Programming/emacs/clojureetags.txt -o %s/TAGS"
	     project-root
	     project-root)))

  (defun esk-pretty-fn ()
    (font-lock-add-keywords nil `(("(\\(\\<fn\\>\\)"
                                   (0 (progn (compose-region (match-beginning 1)
                                                             (match-end 1)
                                                             "\u0192"
                                                             'decompose-region)))))))
  (add-hook 'clojure-mode-hook 'esk-pretty-fn)
  (add-hook 'clojurescript-mode-hook 'esk-pretty-fn)


  ;; CDT
  ;; (setq cdt-dir "~/thirdparty/cdt")
  ;; (setq cdt-source-path
  ;;       (format "%s/src/jvm:%s/src/clj:%s/src/main/clojure"
  ;;               clj-dir clj-dir clj-contrib-dir))
  ;; (load-file (format "%s/ide/emacs/cdt.el" cdt-dir))

  (when (try-require 'ac-slime)
    (add-hook 'slime-repl-mode-hook 'clojure-mode-font-lock-setup)))

;; LaTeX
(when
    (try-require 'latex)

    (when (try-require 'auto-complete-latex)
      (setq ac-l-dict-directory "~/.emacs.d/lib/auto-complete-latex/ac-l-dict/")
      (add-to-list 'ac-modes 'latex-mode))

    (setq TeX-auto-local "~/.auctex/auto/")
    (setq TeX-auto-save t)
    (setq TeX-parse-self t)
    (setq TeX-debug-bad-boxes t)
    (setq TeX-debug-warnings t)
    (setq TeX-save-query nil)
    (setq TeX-show-compilation nil)
    (setq TeX-command-default "LaTeX")
    (setq reftex-plug-into-AUCTeX t)

    (defun guess-TeX-master (filename)
      "Guess the master file for FILENAME from currently open .tex files."
      (let ((candidate nil)
	    (filename (file-name-nondirectory filename)))
	(save-excursion
	  (dolist (buffer (buffer-list))
	    (with-current-buffer buffer
	      (let ((name (buffer-name))
		    (file buffer-file-name))
		(if (and file (string-match "\\.tex$" file))
		    (progn
		      (goto-char (point-min))
		      (if (re-search-forward (concat "\\\\input{" filename "}") nil t)
			  (setq candidate file))
		      (if (re-search-forward (concat "\\\\include{" (file-name-sans-extension filename) "}") nil t)
			  (setq candidate file))))))))
	(if candidate
	    (message "TeX master document: %s" (file-name-nondirectory candidate)))
	candidate))

    (defadvice compile (after view-after-compile (command &optional comint))
      (TeX-view))

    (add-hook 'LaTeX-mode-hook (lambda()
				 (auto-fill-mode)
				 (turn-on-auto-fill)
				 (turn-on-reftex)
				 (flyspell-mode)
				 (LaTeX-math-mode 1)
				 (TeX-fold-mode 1)
				 (TeX-PDF-mode 1)
				 (ad-activate 'compile)
				 (setq TeX-master (guess-TeX-master (buffer-file-name)))
				 (ac-l-setup))))

;; Javascript
(when
    (try-require 'js)


  (defun esk-paredit-nonlisp ()
    "Turn on paredit mode for non-lisps."
    (interactive)
    (set (make-local-variable 'paredit-space-for-delimiter-predicates)
	 '((lambda (endp delimiter) nil)))
    (paredit-mode 1))

  (add-to-list 'auto-mode-alist '("\\.json$" . js-mode))
  (add-to-list 'auto-mode-alist '("\\.js$" . js-mode))

  (eval-after-load 'js
    '(progn (define-key js-mode-map "{" 'paredit-open-curly)
	    (define-key js-mode-map "}" 'paredit-close-curly-and-newline)
	    (add-hook 'js-mode-hook 'esk-paredit-nonlisp)
	    (setq js-indent-level 2)
	    ;; fixes problem with pretty function font-lock
	    (define-key js-mode-map (kbd ",") 'self-insert-command)
	    (font-lock-add-keywords
	     'js-mode `(("\\(function *\\)("
			 (0 (progn (compose-region (match-beginning 1)
						   (match-end 1) "\u0192")
				   nil)))))))

  (when (try-require 'auto-complete)
    ;; configuration for auto-complte support
    (add-to-list 'ac-modes 'js-mode)))

;; Go
(when
    (try-require 'go-mode-load))

;; Haskell
(when
    (try-require 'inf-haskell)
  (setq haskell-font-lock-symbols 'unicode))

;; Octave
(when
    (try-require 'octave-mod)
    (when (try-require 'ac-octave)
      (add-to-list 'auto-mode-alist '("\\.m$"  . octave-mode))
      (add-to-list 'ac-modes 'octave-mode)
      (add-to-list 'ac-sources 'ac-source-octave)))

;;(try-require 'python-config)
(section-end "Langauges")
(section-end (format "* --[ Loading my Emacs init file ]-- Total time: %d seconds" (time-to-seconds (time-since emacs-load-start-time))))

;; Private customization
(let ((private-config-file ".emacs-private.el"))
  (if (file-exists-p private-config-file)
      (load private-config-file t t)))

(if missing-packages-list
    (progn (message "Packages not found: %S" missing-packages-list)))

;; Startup actions
(progn
  (when nil (switch-to-buffer "*Pymacs*")
        (erase-buffer)
        (switch-to-buffer "*ESS*")
        (erase-buffer)
        (switch-to-buffer "*scratch*"))
  (sit-for 1.5)
  (kill-buffer "*ESS*")
  (kill-buffer "*Egg:Select Action*"))
