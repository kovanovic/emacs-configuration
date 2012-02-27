;;visual:colors:cursor
'(cursor-type bar width . start)
(setq djcb-read-only-cursor-type 'hbar)
(setq djcb-read-only-color        "green")

(setq djcb-overwrite-color       "red")
(setq djcb-overwrite-cursor-type 'box)

(setq djcb-normal-color          "yellow")
(setq djcb-normal-cursor-type    'bar)

(defun djcb-set-cursor-according-to-mode ()
  "change cursor color and type according to some minor modes."

  (cond
    (buffer-read-only
      (set-cursor-color djcb-read-only-color)
      (setq cursor-type djcb-read-only-cursor-type))
    (overwrite-mode
      (set-cursor-color djcb-overwrite-color)
      (setq cursor-type djcb-overwrite-cursor-type))
    (t 
      (set-cursor-color djcb-normal-color)
      (setq cursor-type djcb-normal-cursor-type))))

(add-hook 'post-command-hook 'djcb-set-cursor-according-to-mode)

(provide 'cursorbymode)
