;;; color-theme-sanityinc-tomorrow.el --- A version of Chris Kempson's "tomorrow" themes

;; Copyright (C) 2012 Steve Purcell

;; Author: Steve Purcell <steve@sanityinc.com>
;; Keywords: themes
;; X-URL: http://github.com/purcell/color-theme-sanityinc-tomorrow
;; URL: http://github.com/purcell/color-theme-sanityinc-tomorrow
;; Version: 0.3

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; In Emacs versions without built-in theme support, ie. < 24,
;; color-theme.el is required.

;; Use:

;;   M-x color-theme-tomorrow-day

;;   M-x color-theme-tomorrow-night

;;   M-x color-theme-tomorrow-blue

;;   M-x color-theme-tomorrow-bright

;;   M-x color-theme-tomorrow-eighties
;;
;;; Credit:

;; Colour selection by Chris Kempson:
;; https://github.com/ChrisKempson/Tomorrow-Theme

;;; Code:

(defconst color-theme-sanityinc-tomorrow-colors
      '(night (background   "#1d1f21"
                            current-line "#282a2e"
                            selection    "#373b41"
                            foreground   "#c5c8c6"
                            comment      "#969896"
                            red          "#cc6666"
                            orange       "#de935f"
                            yellow       "#f0c674"
                            green        "#b5bd68"
                            aqua         "#8abeb7"
                            blue         "#81a2be"
                            purple       "#b294bb")
              day (background   "#ffffff"
                                current-line "#efefef"
                                selection    "#d6d6d6"
                                foreground   "#4d4d4c"
                                comment      "#8e908c"
                                red          "#c82829"
                                orange       "#f5871f"
                                yellow       "#eab700"
                                green        "#718c00"
                                aqua         "#3e999f"
                                blue         "#4271ae"
                                purple       "#8959a8")
              eighties (background   "#2d2d2d"
                                     current-line "#393939"
                                     selection    "#515151"
                                     foreground   "#cccccc"
                                     comment      "#999999"
                                     red          "#f2777a"
                                     orange       "#f99157"
                                     yellow       "#ffcc66"
                                     green        "#99cc99"
                                     aqua         "#66cccc"
                                     blue         "#6699cc"
                                     purple       "#cc99cc")
              blue (background   "#002451"
                                 current-line "#00346e"
                                 selection    "#003f8e"
                                 foreground   "#ffffff"
                                 comment      "#7285b7"
                                 red          "#ff9da4"
                                 orange       "#ffc58f"
                                 yellow       "#ffeead"
                                 green        "#d1f1a9"
                                 aqua         "#99ffff"
                                 blue         "#bbdaff"
                                 purple       "#ebbbff")
              bright (background   "#000000"
                                   current-line "#2a2a2a"
                                   selection    "#424242"
                                   foreground   "#eaeaea"
                                   comment      "#969896"
                                   red          "#d54e53"
                                   orange       "#e78c45"
                                   yellow       "#e7c547"
                                   green        "#b9ca4a"
                                   aqua         "#70c0b1"
                                   blue         "#7aa6da"
                                   purple       "#c397d8")))



(defmacro color-theme-sanityinc-tomorrow--with-colors (mode &rest body)
  "Execute `BODY' in a scope with variables bound to the various tomorrow colors.

`MODE' should be set to either 'day, 'night, 'eighties, 'blue or 'bright."
  `(let* ((colors (or (plist-get color-theme-sanityinc-tomorrow-colors ,mode)
                      (error "no such theme flavor")))
          (background   (plist-get colors 'background))
          (current-line (plist-get colors 'current-line))
          (selection    (plist-get colors 'selection))
          (foreground   (plist-get colors 'foreground))
          (comment      (plist-get colors 'comment))
          (red          (plist-get colors 'red))
          (orange       (plist-get colors 'orange))
          (yellow       (plist-get colors 'yellow))
          (green        (plist-get colors 'green))
          (aqua         (plist-get colors 'aqua))
          (blue         (plist-get colors 'blue))
          (purple       (plist-get colors 'purple))
          (class '((class color) (min-colors 89))))
     ,@body))

(defmacro color-theme-sanityinc-tomorrow--face-specs ()
  "Return a backquote which defines a list of face specs.

It expects to be evaluated in a scope in which the various color
names to which it refers are bound."
  (quote
   `(;; Standard font lock faces
     (default ((,class (:foreground ,foreground :background ,background))))
     (bold ((,class (:weight bold))))
     (bold-italic ((,class (:slant italic :weight bold))))
     (underline ((,class (:underline t))))
     (italic ((,class (:slant italic))))
     (font-lock-builtin-face ((,class (:foreground ,purple))))
     (font-lock-comment-delimiter-face ((,class (:foreground ,comment :slant italic))))
     (font-lock-comment-face ((,class (:foreground ,comment :slant italic))))
     (font-lock-constant-face ((,class (:foreground ,purple))))
     (font-lock-doc-face ((,class (:foreground ,purple))))
     (font-lock-doc-string-face ((,class (:foreground ,yellow))))
     (font-lock-function-name-face ((,class (:foreground ,blue))))
     (font-lock-keyword-face ((,class (:foreground ,green))))
     (font-lock-negation-char-face ((,class (:foreground ,green))))
     (font-lock-preprocessor-face ((,class (:foreground ,purple))))
     (font-lock-regexp-grouping-backslash ((,class (:foreground ,yellow))))
     (font-lock-regexp-grouping-construct ((,class (:foreground ,purple))))
     (font-lock-string-face ((,class (:foreground ,aqua))))
     (font-lock-type-face ((,class (:foreground ,orange))))
     (font-lock-variable-name-face ((,class (:foreground ,yellow))))
     (font-lock-warning-face ((,class (:weight bold :foreground ,red))))
     (shadow ((,class (:foreground ,comment))))
     (success ((,class (:foreground ,green))))
     (error ((,class (:foreground ,red))))
     (warning ((,class (:foreground ,orange))))

     ;; Flymake
     (flymake-warnline ((,class (:underline ,orange :background ,background))))
     (flymake-errline ((,class (:underline ,red :background ,background))))

     ;; Clojure errors
     (clojure-test-failure-face ((,class (:background nil :inherit flymake-warnline))))
     (clojure-test-error-face ((,class (:background nil :inherit flymake-errline))))
     (clojure-test-success-face ((,class (:background nil :foreground nil :underline ,green))))

     ;; For Brian Carper's extended clojure syntax table
     (clojure-keyword ((,class (:foreground ,yellow))))
     (clojure-parens ((,class (:foreground ,foreground))))
     (clojure-braces ((,class (:foreground ,green))))
     (clojure-brackets ((,class (:foreground ,yellow))))
     (clojure-double-quote ((,class (:foreground ,aqua :background nil))))
     (clojure-special ((,class (:foreground ,blue))))
     (clojure-java-call ((,class (:foreground ,purple))))

     ;; Rainbow-delimiters
     (rainbow-delimiters-depth-1-face ((,class (:foreground ,foreground))))
     (rainbow-delimiters-depth-2-face ((,class (:foreground ,aqua))))
     (rainbow-delimiters-depth-3-face ((,class (:foreground ,yellow))))
     (rainbow-delimiters-depth-4-face ((,class (:foreground ,green))))
     (rainbow-delimiters-depth-5-face ((,class (:foreground ,blue))))
     (rainbow-delimiters-depth-6-face ((,class (:foreground ,foreground))))
     (rainbow-delimiters-depth-7-face ((,class (:foreground ,aqua))))
     (rainbow-delimiters-depth-8-face ((,class (:foreground ,yellow))))
     (rainbow-delimiters-depth-9-face ((,class (:foreground ,green))))
     (rainbow-delimiters-unmatched-face ((,class (:foreground ,red))))

     ;; MMM-mode
     (mmm-code-submode-face ((,class (:background ,current-line))))
     (mmm-comment-submode-face ((,class (:inherit font-lock-comment-face))))
     (mmm-output-submode-face ((,class (:background ,current-line))))

     ;; Search
     (match ((,class (:foreground ,blue :background ,background :inverse-video t))))
     (isearch ((,class (:foreground ,yellow :background ,background :inverse-video t))))
     (isearch-lazy-highlight-face ((,class (:foreground ,aqua :background ,background :inverse-video t))))
     (isearch-fail ((,class (:background ,background :inherit font-lock-warning-face :inverse-video t))))

     ;; IDO
     (ido-subdir ((,class (:foreground ,purple))))
     (ido-first-match ((,class (:foreground ,yellow))))
     (ido-only-match ((,class (:foreground ,green))))

     ;; Emacs interface
     (cursor ((,class (:background ,red))))
     (fringe ((,class (:background ,current-line))))
     (border ((,class (:background ,current-line))))
     (border-glyph ((,class (nil))))
     (highlight ((,class (:inverse-video nil :background ,current-line))))
     (gui-element ((,class (:background ,current-line :foreground ,foreground))))
     (mode-line ((,class (:foreground nil :background ,current-line
                                      :box (:line-width 1 :color ,foreground)))))
     (mode-line-buffer-id ((,class (:foreground ,purple :background nil))))
     (mode-line-inactive ((,class (:inherit mode-line
                                       :foreground ,comment
                                       :background ,current-line :weight normal
                                       :box (:line-width 1 :color ,foreground)))))
     (mode-line-emphasis ((,class (:foreground ,foreground :slant italic))))
     (mode-line-highlight ((,class (:foreground ,purple :box nil :weight bold))))
     (minibuffer-prompt ((,class (:foreground ,blue))))
     (region ((,class (:background ,selection))))
     (secondary-selection ((,class (:background ,current-line))))

     (header-line ((,class (:background nil :foreground ,foreground :weight bold :inherit nil))))
     (trailing-whitespace ((,class (:background ,red :underline nil))))

     ;; Parenthesis matching (built-in)
     (show-paren-match ((,class (:background nil :foreground nil :inverse-video t))))
     (show-paren-mismatch ((,class (:background ,purple :foreground ,background))))

     ;; Parenthesis matching (mic-paren)
     (paren-face-match ((,class (:foreground nil :background nil :inherit show-paren-match))))
     (paren-face-mismatch ((,class (:foreground nil :background nil :inherit show-paren-mismatch))))
     (paren-face-no-match ((,class (:foreground nil :background nil :inherit show-paren-mismatch))))

     ;; Parenthesis dimming (parenface)
     (paren-face ((,class (:foreground ,comment :background nil))))

     (sh-heredoc ((,class (:foreground nil :inherit font-lock-string-face :weight normal))))
     (sh-quoted-exec ((,class (:foreground nil :inherit font-lock-preprocessor-face))))
     (slime-highlight-edits-face ((,class (:weight bold))))
     (slime-repl-input-face ((,class (:weight normal :underline nil))))
     (slime-repl-prompt-face ((,class (:underline nil :weight bold :foreground ,purple))))
     (slime-repl-result-face ((,class (:foreground ,green))))
     (slime-repl-output-face ((,class (:foreground ,blue :background ,background))))

     (diff-added ((,class (:foreground ,green))))
     (diff-changed ((,class (:foreground ,purple))))
     (diff-removed ((,class (:foreground ,orange))))
     (diff-header ((,class (:foreground ,aqua :background nil))))
     (diff-file-header ((,class (:foreground ,blue :background nil))))
     (diff-hunk-header ((,class (:foreground ,purple))))

     ;; undo-tree
     (undo-tree-visualizer-default-face ((,class (:foreground ,foreground))))
     (undo-tree-visualizer-current-face ((,class (:foreground ,green :weight bold))))
     (undo-tree-visualizer-active-branch-face ((,class (:foreground ,red))))
     (undo-tree-visualizer-register-face ((,class (:foreground ,yellow))))

     ;; dired+
     (diredp-dir-heading ((,class (:foreground nil :background nil :inherit heading))))
     (diredp-dir-priv ((,class (:foreground ,aqua :background nil))))
     (diredp-exec-priv ((,class (:foreground ,blue :background nil))))
     (diredp-file-name ((,class (:foreground ,yellow))))
     (diredp-file-suffix ((,class (:foreground ,green))))
     (diredp-flag-mark-line ((,class (:background nil :inherit highlight))))
     (diredp-ignored-file-name ((,class (:foreground ,comment))))
     (diredp-link-priv ((,class (:background nil :foreground ,purple))))
     (diredp-no-priv ((,class (:background nil))))
     (diredp-number ((,class (:foreground ,yellow))))
     (diredp-other-priv ((,class (:background nil :foreground ,purple))))
     (diredp-rare-priv ((,class (:foreground ,red :background nil))))
     (diredp-read-priv ((,class (:foreground ,green :background nil))))
     (diredp-symlink ((,class (:foreground ,purple))))
     (diredp-write-priv ((,class (:foreground ,yellow :background nil))))

     ;; Magit (a patch is pending in magit to make these standard upstream)
     (magit-branch ((,class (:foreground ,green))))
     (magit-item-highlight ((,class (:inherit highlight :background nil))))
     (magit-log-graph ((,class (:foreground ,comment))))
     (magit-log-sha1 ((,class (:foreground ,yellow))))
     (magit-log-head-label-bisect-bad ((,class (:foreground ,red))))
     (magit-log-head-label-bisect-good ((,class (:foreground ,green))))
     (magit-log-head-label-default ((,class (:foreground ,yellow :box nil :weight bold))))
     (magit-log-head-label-local ((,class (:foreground ,purple :box nil :weight bold))))
     (magit-log-head-label-remote ((,class (:foreground ,purple :box nil :weight bold))))
     (magit-log-head-label-tags ((,class (:foreground ,aqua :box nil :weight bold))))
     (magit-section-title ((,class (:foreground ,blue :weight bold))))

     (link ((,class (:foreground nil :underline t))))
     (widget-button ((,class (:underline t))))
     (widget-field ((,class (:background ,current-line :box (:line-width 1 :color ,foreground)))))

     ;; Compilation (most faces politely inherit from 'success, 'error, 'warning etc.)
     (compilation-column-number ((,class (:foreground ,yellow))))
     (compilation-line-number ((,class (:foreground ,yellow))))
     (compilation-message-face ((,class (:foreground ,blue))))

     ;; Grep
     (grep-context-face ((,class (:foreground ,comment))))
     (grep-error-face ((,class (:foreground ,red :weight bold :underline t))))
     (grep-hit-face ((,class (:foreground ,blue))))
     (grep-match-face ((,class (:foreground nil :background nil :inherit match))))

     ;; Stop outline-3 from inheriting font-lock-keyword-face, which we've made bold
     (outline-3 ((,class (:inherit nil :foreground ,green))))

     (org-link ((,class (:foreground ,blue :underline t))))
     (org-date ((,class (:foreground ,blue :underline t))))
     (org-agenda-structure ((,class (:foreground ,purple))))
     (org-agenda-date ((,class (:foreground ,blue :underline nil))))
     (org-done ((,class (:foreground ,green))))
     (org-todo ((,class (:foreground ,red))))
     (org-special-keyword ((,class (:foreground ,orange))))
     (org-table ((,class (:foreground ,purple))))

     (org-document-title ((,class (:weight bold))))
     (org-document-info ((,class (:foreground ,aqua))))
     (org-column ((,class (:background ,current-line))))
     (org-warning ((,class (:weight bold :foreground ,red))))

     (org-scheduled-previously ((,class (:foreground ,orange))))

     (markdown-header-face ((,class (:inherit header-line))))
     (markdown-url-face ((,class (:inherit link))))
     (markdown-link-face ((,class (:foreground ,blue :underline t))))

     (hl-sexp-face ((,class (:background ,current-line))))
     (highlight-80+ ((,class (:background ,current-line))))

     ;; Python-specific overrides
     (py-builtins-face ((,class (:foreground ,orange :weight normal))))

     ;; js2-mode
     (js2-warning ((,class (:underline ,yellow))))
     (js2-error ((,class (:underline ,red))))
     (js2-external-variable ((,class (:foreground ,purple))))

     ;; nxml
     (nxml-name-face ((,class (:foreground unspecified :inherit font-lock-constant-face))))
     (nxml-attribute-local-name-face ((,class (:foreground unspecified :inherit font-lock-variable-name-face))))
     (nxml-ref-face ((,class (:foreground unspecified :inherit font-lock-preprocessor-face))))
     (nxml-delimiter-face ((,class (:foreground unspecified :inherit font-lock-keyword-face))))
     (nxml-delimited-data-face ((,class (:foreground unspecified :inherit font-lock-string-face))))
     (rng-error-face ((,class (:underline ,red))))

     ;; RHTML
     (erb-delim-face ((,class (:background ,current-line))))
     (erb-exec-face ((,class (:background ,current-line :weight bold))))
     (erb-exec-delim-face ((,class (:background ,current-line))))
     (erb-out-face ((,class (:background ,current-line :weight bold))))
     (erb-out-delim-face ((,class (:background ,current-line))))
     (erb-comment-face ((,class (:background ,current-line :weight bold :slant italic))))
     (erb-comment-delim-face ((,class (:background ,current-line))))

     ;; Message-mode
     (message-header-other ((,class (:inherit header-line :foreground nil :background nil :weight normal))))
     (message-header-subject ((,class (:inherit message-header-other :weight bold :foreground ,yellow))))
     (message-header-to ((,class (:inherit message-header-other :weight bold :foreground ,orange))))
     (message-header-cc ((,class (:inherit message-header-to :foreground nil))))
     (message-header-name ((,class (:inherit header-line :foreground ,green :background nil))))
     (message-header-newsgroups ((,class (:foreground ,aqua :background nil :slant normal))))
     (message-separator ((,class (:foreground ,purple))))

     ;; Gnus
     (gnus-cite-1 ((,class (:inherit outline-1 :foreground nil))))
     (gnus-cite-2 ((,class (:inherit outline-2 :foreground nil))))
     (gnus-cite-3 ((,class (:inherit outline-3 :foreground nil))))
     (gnus-cite-4 ((,class (:inherit outline-4 :foreground nil))))
     (gnus-cite-5 ((,class (:inherit outline-5 :foreground nil))))
     (gnus-cite-6 ((,class (:inherit outline-6 :foreground nil))))
     (gnus-cite-7 ((,class (:inherit outline-7 :foreground nil))))
     (gnus-cite-8 ((,class (:inherit outline-8 :foreground nil))))
     ;; there are several more -cite- faces...
     (gnus-header-content ((,class (:inherit header-line :foreground nil :background nil :weight normal))))
     (gnus-header-subject ((,class (:inherit gnus-header-content :weight bold :foreground ,yellow))))
     (gnus-header-from ((,class (:inherit gnus-header-content :weight bold :foreground ,orange))))
     (gnus-header-name ((,class (:inherit header-line :foreground ,green :background nil))))
     (gnus-button ((,class (:inherit link :foreground nil))))
     (gnus-signature ((,class (:inherit font-lock-comment-face))))

     (gnus-summary-normal-unread ((,class (:foreground ,blue :weight normal))))
     (gnus-summary-normal-read ((,class (:foreground ,foreground :weight normal))))
     (gnus-summary-normal-ancient ((,class (:foreground ,aqua :weight normal))))
     (gnus-summary-normal-ticked ((,class (:foreground ,orange :weight normal))))
     (gnus-summary-low-unread ((,class (:foreground ,comment :weight normal))))
     (gnus-summary-low-read ((,class (:foreground ,comment :weight normal))))
     (gnus-summary-low-ancient ((,class (:foreground ,comment :weight normal))))
     (gnus-summary-high-unread ((,class (:foreground ,yellow :weight normal))))
     (gnus-summary-high-read ((,class (:foreground ,green :weight normal))))
     (gnus-summary-high-ancient ((,class (:foreground ,green :weight normal))))
     (gnus-summary-high-ticked ((,class (:foreground ,orange :weight normal))))
     (gnus-summary-cancelled ((,class (:foreground ,red :background nil :weight normal))))

     (gnus-group-mail-low ((,class (:foreground ,comment))))
     (gnus-group-mail-low-empty ((,class (:foreground ,comment))))
     (gnus-group-mail-1 ((,class (:foreground nil :weight normal :inherit outline-1))))
     (gnus-group-mail-2 ((,class (:foreground nil :weight normal :inherit outline-2))))
     (gnus-group-mail-3 ((,class (:foreground nil :weight normal :inherit outline-3))))
     (gnus-group-mail-4 ((,class (:foreground nil :weight normal :inherit outline-4))))
     (gnus-group-mail-5 ((,class (:foreground nil :weight normal :inherit outline-5))))
     (gnus-group-mail-6 ((,class (:foreground nil :weight normal :inherit outline-6))))
     (gnus-group-mail-1-empty ((,class (:inherit gnus-group-mail-1 :foreground ,comment))))
     (gnus-group-mail-2-empty ((,class (:inherit gnus-group-mail-2 :foreground ,comment))))
     (gnus-group-mail-3-empty ((,class (:inherit gnus-group-mail-3 :foreground ,comment))))
     (gnus-group-mail-4-empty ((,class (:inherit gnus-group-mail-4 :foreground ,comment))))
     (gnus-group-mail-5-empty ((,class (:inherit gnus-group-mail-5 :foreground ,comment))))
     (gnus-group-mail-6-empty ((,class (:inherit gnus-group-mail-6 :foreground ,comment))))

     (custom-variable-tag ((,class (:foreground ,blue))))
     (custom-group-tag ((,class (:foreground ,blue))))
     )))

(defmacro color-theme-sanityinc-tomorrow--frame-parameter-specs ()
  "Return a backquote which defines a list of frame parameter specs.

These are required by color-theme's `color-theme-install', but
not by the new `deftheme' mechanism. It expects to be evaluated
in a scope in which the various color names to which it refers
are bound."
  (quote
   `(((background-color . ,background)
      (background-mode . light)
      (border-color . ,foreground)
      (cursor-color . ,purple)
      (foreground-color . ,foreground)
      (mouse-color . ,aqua)))))

(defun color-theme-sanityinc-tomorrow--theme-name (mode)
  (intern (format "sanityinc-tomorrow-%s" (symbol-name mode))))

(defmacro color-theme-sanityinc-tomorrow--define-theme (mode)
  "Define a theme for the tomorrow variant `MODE'."
  (let ((name (color-theme-sanityinc-tomorrow--theme-name mode))
        (doc (format "A version of Chris Kempson's 'Tomorrow' theme (%s version)" mode)))
    `(progn
       (deftheme ,name ,doc)
       (color-theme-sanityinc-tomorrow--with-colors
        ',mode
        (apply 'custom-theme-set-faces ',name
               (color-theme-sanityinc-tomorrow--face-specs))
        (custom-theme-set-variables
         ',name
         `(ansi-color-names-vector (vector ,foreground ,red ,green ,yellow ,blue ,purple ,aqua ,background))
         '(ansi-color-faces-vector [default bold shadow italic underline bold bold-italic bold])))
       (provide-theme ',name))))


(defun color-theme-sanityinc-tomorrow (mode)
  "Apply the tomorrow variant theme."
  (if (fboundp 'load-theme)
      (let ((name (color-theme-sanityinc-tomorrow--theme-name mode)))
        (if (> emacs-major-version 23)
            (load-theme name t)
          (load-theme name)))
    (progn
      (require 'color-theme)
      (color-theme-sanityinc-tomorrow--with-colors
       mode
       (color-theme-install
        `(,(intern (concat "color-theme-sanityinc-tomorrow-" (symbol-name mode)))
          ,@(color-theme-sanityinc-tomorrow--frame-parameter-specs)
          ,@(color-theme-sanityinc-tomorrow--face-specs)))
       ;; ansi-color - comint and other modes that handle terminal color escape sequences
       (setq ansi-color-names-vector (vector foreground red green yellow blue purple aqua background))
       (setq ansi-color-faces-vector [default bold shadow italic underline bold bold-italic bold])))))

;;;###autoload
(when (boundp 'custom-theme-load-path)
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

;;;###autoload
(defun color-theme-sanityinc-tomorrow-night ()
  (interactive)
  (color-theme-sanityinc-tomorrow 'night))

;;;###autoload
(defun color-theme-sanityinc-tomorrow-day ()
  (interactive)
  (color-theme-sanityinc-tomorrow 'day))

;;;###autoload
(defun color-theme-sanityinc-tomorrow-bright ()
  (interactive)
  (color-theme-sanityinc-tomorrow 'bright))

;;;###autoload
(defun color-theme-sanityinc-tomorrow-eighties ()
  (interactive)
  (color-theme-sanityinc-tomorrow 'eighties))

;;;###autoload
(defun color-theme-sanityinc-tomorrow-blue ()
  (interactive)
  (color-theme-sanityinc-tomorrow 'blue))


(provide 'color-theme-sanityinc-tomorrow)

;;; color-theme-sanityinc-tomorrow.el ends here
