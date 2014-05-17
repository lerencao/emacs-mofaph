;; magit
;; http://magit.github.com/magit/magit.html

(require 'magit)

(setq magit-repo-dirs '(
                        "/work"
                        "~/github"
                        "~/bitbucket"
                        "~/scm/git"
                        "~/bigstore/scm/git"
                        ))

(global-set-key (kbd "C-x C-z") 'magit-status)
(global-set-key (kbd "C-c m s") 'magit-status)
(global-set-key (kbd "C-c m g") 'magit-grep)
(global-set-key (kbd "C-c m l") 'magit-log)
(global-set-key (kbd "C-c m b") 'magit-branch-manager)

(provide 'init-magit)
