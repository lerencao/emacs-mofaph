(require 'highlight-symbol)

(global-set-key [(control f7)] 'highlight-symbol-at-point)
(global-set-key [f7] 'highlight-symbol-next)
(global-set-key [(shift f7)] 'highlight-symbol-prev)
(global-set-key [(meta f7)] 'highlight-symbol-prev)
(global-set-key [(control shift f7)] 'highlight-symbol-query-replace)

(global-set-key (kbd "C-x w *") 'highlight-symbol-at-point)

(provide 'init-highlight-symbol)
