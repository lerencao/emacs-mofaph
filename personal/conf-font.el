;;; -*- coding: utf-8 -*-

;;; http://emacser.com/torture-emacs.htm

(defvar English-font-list '("Monaco"
                            "文泉驿等宽正黑"
                            "Monospace"
                            "Consolas"
                            "DejaVu Sans Mono"))

(defvar Chinese-font-list '("DejaVu Sans YuanTi Mono"
                            "华文黑体"
                            "文泉驿等宽正黑"
                            "文泉驿等宽微米黑"))

;; 首先，判断某个字体在系统中是否安装
(defun qiang-font-existsp (font)
  (not (null (x-list-fonts font))))

;; 还要有个辅助函数，用来生产带上 font size 信息的 font 描述文本
(defun qiang-make-font-string (font-name font-size)
  (if (and (stringp font-size)
           (equal ":" (string (elt font-size 0))))
      (format "%s%s" font-name font-size)
    (format "%s %s" font-name font-size)))

;; 有了这些函数，下面出场的就是自动设置字体函数了
(defun qiang-set-font (english-fonts
                       english-font-size
                       chinese-fonts
                       &optional chinese-font-size)
  "english-font-size could be set to \":pixelsize=18\" or a integer.
If set/leave chinese-font-size to nil, it will follow english-font-size"
  (require 'cl)                         ; for find-if
  (let ((en-font (qiang-make-font-string
                  (find-if #'qiang-font-existsp english-fonts)
                  english-font-size))
        (zh-font (font-spec :family (find-if #'qiang-font-existsp chinese-fonts)
                            :size chinese-font-size)))

    ;; Set the default English font
    ;;
    ;; The following 2 method cannot make the font settig work in new frames.
    ;; (set-default-font "Consolas:pixelsize=18")
    ;; (add-to-list 'default-frame-alist '(font . "Consolas:pixelsize=18"))
    ;; We have to use set-face-attribute
    (message "Set English Font to %s" en-font)
    (set-face-attribute 'default nil :font en-font)

    ;; Set Chinese font
    ;; Do not use 'unicode charset, it will cause the english font setting invalid
    (message "Set Chinese Font to %s" zh-font)
    (dolist (charset '(kana han symbol cjk-misc bopomofo))
      (set-fontset-font (frame-parameter nil 'font)
                        charset
                        zh-font))))

;; 利用这个函数，Emacs 字体设置就是小菜一碟了
(if window-system
    (let ((height (display-pixel-height))
          (width  (display-pixel-width)))
      (cond

       ((and (>= width 1920) (>= height 1080))
        (qiang-set-font English-font-list ":pixelsize=15"
                        Chinese-font-list 15))

       ((and (>= width 1366) (>= height 768))
        (qiang-set-font English-font-list ":pixelsize=14"
                        Chinese-font-list 14))

       ((and (>= width 1024) (>= height 600))
        (qiang-set-font English-font-list ":pixelsize=13"
                        Chinese-font-list 13))

       (t
        (qiang-set-font English-font-list ":pixelsize=12"
                        Chinese-font-list 12)))))

(provide 'conf-font)
