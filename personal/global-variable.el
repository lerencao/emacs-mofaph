;; -*- coding: utf-8; -*-

(defvar elisp-dir (concat user-emacs-directory "elisp/")
  "The directory holds the Emacs Lisp code.")

(defvar personal-dir (concat user-emacs-directory "personal/")
  "The directory holds personal configuration.")

(add-to-list 'load-path elisp-dir)
(add-to-list 'load-path personal-dir)

(defvar c-related-mode '(
                         c++-mode
                         c-mode
                         java-mode
                         objc-mode
                         )
  "The C related mode.")

(defvar c-related-mode-hook
  (mapcar (lambda (mode)
            (intern (concat (symbol-name mode) "-hook")))
          c-related-mode)
  "The C related mode hook.")

(defvar lisp-related-mode '(
                            clojure-mode
                            common-lisp-mode
                            emacs-lisp-mode
                            eshell-mode
                            inferior-emacs-lisp-mode
                            lisp-interaction-mode
                            lisp-mode
                            scheme-mode
                            slime-repl-mode
                            )
  "The Lisp related mode.")

(defvar lisp-related-mode-hook
  (mapcar (lambda (mode)
            (intern (concat (symbol-name mode) "-hook")))
          lisp-related-mode)
  "The Lisp related mode hook.")

;; Local Variables:
;; no-byte-compile: t
;; End:
