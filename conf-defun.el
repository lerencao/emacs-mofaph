;; -*- coding: utf-8 -*-

(defun open-newline-indent ()
  "Open new line and indent."
  (interactive)
  (move-end-of-line 1)
  (newline-and-indent))

(global-set-key (kbd "C-j") 'open-newline-indent)

(dolist (hook (append c-related-mode-hook
                      lisp-related-mode-hook
                      '(
                        asm-mode-hook
                        sh-mode-hook
                        )))
  (add-hook hook (lambda () (local-set-key (kbd "C-j") 'open-newline-indent))))

(defun open-newline-above ()
  "open a new line above current line."
  (interactive)
  (indent-according-to-mode)
  (move-end-of-line 1)
  (delete-horizontal-space t)
  (move-beginning-of-line 1)
  (open-line 1)
  (indent-according-to-mode))

(global-set-key (kbd "M-j") 'open-newline-above)

(dolist (hook (append c-related-mode-hook
                      lisp-related-mode-hook
                      '(
                        asm-mode-hook
                        sh-mode-hook
                        )))
  (add-hook hook (lambda () (local-set-key (kbd "M-j") 'open-newline-above))))

;; 使用 lambda 替代 _lambda_ （加下划线是因为在 Emacs 中设置会原地生效）
;; http://stackoverflow.com/questions/154097/whats-in-your-emacs
(defun sm-lambda-mode-hook ()
  (font-lock-add-keywords
   nil `(("\\<lambda\\>"
          (0 (progn (compose-region (match-beginning 0) (match-end 0)
                                    ,(make-char 'greek-iso8859-7 107))
                    nil))))))

(dolist (lisp-hook '(emacs-lisp-mode-hook
                     lisp-mode-hook
                     lisp-interactive-mode-hook
                     scheme-mode-hook))
  (add-hook lisp-hook 'sm-lambda-mode-hook))

(defun move-beginning-of-line-enhance ()
  "Enhance the default move-beginning-of-line.

When the cursor looks like:

`'    hello w|orld`'

you pressed `'C-a`', and the cursor move to the real beginning of line.

If you pressed `'C-a`' again, you will get the cursor at the
first non-whitespace char:

`'    |hello world`'
"
  (interactive)
  (let ((column (- (point) (point-at-bol))))
    (cond
     ((/= column 0) (move-beginning-of-line nil))
     (t (back-to-indentation)))))

(global-set-key (kbd "C-a") 'move-beginning-of-line-enhance)

(defun give-tips-when-want-quit-emacs ()
  "Prevent ancident hit C-x C-c."
  (interactive)
  (message "Please using save-buffers-kill-terminal to quit Emacs."))

(global-set-key (kbd "C-x C-c") 'give-tips-when-want-quit-emacs)

;; http://emacsredux.com/blog/2013/03/29/terminal-at-your-fingertips/
(defun visit-term-buffer ()
  "Create or visit a terminal buffer."
  (interactive)
  (if (not (get-buffer "*ansi-term*"))
      (progn
        (split-window-sensibly (selected-window))
        (other-window 1)
        (ansi-term (getenv "SHELL")))
    (switch-to-buffer-other-window "*ansi-term*")))

(global-set-key (kbd "C-c t") 'visit-term-buffer)

(provide 'conf-defun)
