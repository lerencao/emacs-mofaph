;; -*- coding: utf-8 -*-

;;; 参考链接：
;; [1] https://github.com/DarwinAwardWinner/dotemacs/blob/master/site-lisp/el-get-init.el
;; [2] https://github.com/dimitri/el-get/blob/master/README.asciidoc
;; [3] http://www.emacswiki.org/emacs/el-get

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

;; 这些参数下面的代码需要用到
(setq el-get-install-branch "master"
      el-get-install-skip-emacswiki-recipes "yes"
      el-get-user-package-directory "~/.emacs.d")

;; 安装 el-get
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (end-of-buffer)
    (eval-print-last-sexp)))

(when (require 'el-get nil t)

  ;; 额外的安装包信息（不是直接由 el-get 提供）
  (setq el-get-sources
        '(
          (:name goto-last-change
                 :after (progn (global-set-key (kbd "C-x C-/") 'goto-last-change)))

          (:name magit
                 :after (progn (global-set-key (kbd "C-x C-z") 'magit-status)))

          (:name nav
                 :after (progn
                          (nav-disable-overeager-window-splitting)
                          (global-set-key [f8] 'nav-toggle)))))

  ;; 需要安装的插件列表
  (setq packages
        (append
         '(
           "auto-complete"
           "smex"
           "switch-window"
           )
         (mapcar 'el-get-source-name el-get-sources)))

  ;; 安装和初始化插件
  (el-get 'sync packages))

(provide 'conf-el-get)

;; Local Variables:
;; no-byte-compile: t
;; End:
