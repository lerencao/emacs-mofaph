;;; elpa-mirror.el --- ELPA mirror from locally installed packages is easy

;; Copyright (C) 2014 Chen Bin

;; Author: Chen Bin <chenbin.sh@gmail.com>
;; URL: http://github.com/redguardtoo/elpa-mirror
;; Version: 1.1.5
;; Keywords: cloud mirror elpa
;;
;; This file is not part of GNU Emacs.

;;; License:

;; This file is part of elpa-mirror
;;
;; elpa-mirror is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as published
;; by the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; elpa-mirror is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;;  `M-x elpamr-create-mirror-for-installed` is the only command you need run.
;;

;;; Code:
(require 'package)

(defvar elpamr-default-output-directory
  nil
  "The output directory. If nil, user will be required provide one when running `elpamr-create-mirror-for-installed`")

(defvar elpamr-repository-name
  "myelpa"
  "repository name to be displayed in index.html.")

(defvar elpamr-repository-path
  "http://myelpa.mydomain.com"
  "Repository path to be displayed in index.html")

(defvar elpamr-email
  "name@mydomain.com"
  "Email to be displayed in index.html")

(defvar elpamr-exclude-package-from-repositories
  '("myelpa")
  "exclude packages from certain repositories")

(defvar elpamr-debug nil "show debug message")

(defun elpamr--get-info-array (item)
  (if (elpamr--is-new-package)
      (cadr item)
    (cdr item)))

(defun elpamr--create-one-item-for-archive-contents (pkg)
  "We can use package-alist directly. This API will append some meta info into package-alist."
  (let ((name (car pkg))
        item
        package-content
        repo
        found
        (i 0))

    ;; package-archive-contents is the list of ALL packages
    (while (and (not found)
                (< i (length package-archive-contents)))
      (setq package-content (nth i package-archive-contents))
      ;; well, all we need do is to write the actual version into package-content

      (when (equal name (car package-content))
        ;; real version used instead the one in archive-contents
        (if (arrayp (elpamr--get-info-array package-content))
            (elpamr--set-version
             package-content
             (elpamr--get-version pkg)))

        (setq item package-content)
        (setq found t)
        )
      (setq i (1+ i)))

    (unless found
      ;; make do with installed package, looks it's deleted in archive-contents
      (setq item pkg))

    (setq repo (elt (cdr package-content) 4))
    (if (listp repo)  (setq repo (elt (cdr package-content) 5)))
     (if (member repo elpamr-exclude-package-from-repositories)
      (setq item nil))

    item))


(defun elpamr--extract-info-from-dir (dirname)
  "return '(package-name integer-version-number) or nil"
  (interactive)
  (let (rlt name version)
    (when (string-match "\\(.*\\)-\\([0-9.]+\\)$" dirname)
      (setq name (match-string 1 dirname))
      (setq version (split-string (match-string 2 dirname) "\\."))
      (setq rlt (list name version)))
    rlt
    ))

(defun elpamr--is-new-package ()
  (or (and (>= emacs-major-version 24)
           (>= emacs-minor-version 4))
      (>= emacs-major-version 25))
  )

(defun elpamr--output-fullpath (file)
  "return full path of output file give the FILE"
  (file-truename (concat
                  (file-name-as-directory elpamr-default-output-directory)
                  file)))

(defun elpamr--get-string-from-file (filePath)
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))

(defun elpamr--clean-package-description (descr)
  (replace-regexp-in-string "-\*-.*-\*-" "" descr t))

(defun elpamr--set-version (item version)
  (let ((a (elpamr--get-info-array item)))
    (if (elpamr--is-new-package)
        (aset a 2 version)
      (aset a 0 version))
    ))

(defun elpamr--get-dependency (item)
  (let ((a (elpamr--get-info-array item)))
    (if (elpamr--is-new-package)
        (elt a 4)
      (elt a 1))
    ))

(defun elpamr--get-version (item)
  (let ((a (elpamr--get-info-array item)))
    (if (elpamr--is-new-package)
        (elt a 2)
      (elt a 0))
    ))

(defun elpamr--get-repo (item)
  (let ((a (elpamr--get-info-array item)))
    (if (elpamr--is-new-package)
        (if (> (length a) 6)
            (elt a 6) "legacy")
      (if (> (length a) 4)
          (elt a 4) "legacy"))
    ))

(defun elpamr--get-type (item)
  (let ((a (elpamr--get-info-array item))
        rlt)
    (setq rlt
          (if (elpamr--is-new-package)
              (if (> (length a) 5)
                  (elt a 5) 'tar)
            (if (> (length a) 3)
                (elt a 3) 'tar)
            ))
    (if (not rlt) (setq rlt 'tar))
    rlt))

(defun elpamr--create-complete-package-name (item)
  (concat (symbol-name (car item))
          "-"
          (mapconcat (lambda (arg) (format "%d" arg)) (elpamr--get-version item)  ".")))

(defun elpamr--format-package-list-into-json (list)
  (let (pkg-name)
    (mapconcat
     (lambda (item)
       (setq pkg-name (elpamr--create-complete-package-name item))
       (format "'%s'" pkg-name)
       ) list ",\n")
    ))

(defun elpamr--is-single-el (item)
  (equal 'single (elpamr--get-type item)))

(defun elpamr--get-description (item)
  (let ((a (elpamr--get-info-array item)) )
    (if (elpamr--is-new-package)
        (elt a 3)
      (elt a 2))
    ))

(defun elpamr--format-package-list-into-html (list)
  (let (tar-name (cnt 0))
    (mapconcat
     (lambda (item)
       (setq cnt (1+ cnt))
       (setq tar-name (concat (elpamr--create-complete-package-name item)
                              (if (elpamr--is-single-el item) ".el" ".tar")
                              ))
       (format "<div id='n%d' class='name'><a href='%s'>%s</a></div><div id='d%d' class='descr'>%s</div>\n"
               cnt
               tar-name
               tar-name
               cnt
               (elpamr--clean-package-description (elpamr--get-description item)))
       ) list "\n")
    ))

(defun elpamr--format-email ()
  (format "<a href='mailto:%s'>%s</a>" elpamr-email elpamr-email))

(defun elpamr--output-html (rlt)
  (let ((js-file (elpamr--output-fullpath "elpa-mirror.js"))
        (js-tmpl (concat
                  (file-name-directory (if load-file-name load-file-name (symbol-file 'elpamr--output-html)))
                  "elpa-mirror.js"))
        (html-file (elpamr--output-fullpath "index.html"))
        ;; @see http://stackoverflow.com/questions/145291/smart-home-in-emacs/145359#145359
        (html-tmpl (concat
                    (file-name-directory (if load-file-name load-file-name (symbol-file 'elpamr--output-html)))
                    "index.html")))

    ;; index.html
    (with-temp-buffer
      (let ((print-level nil)  (print-length nil) str)
        (setq str (replace-regexp-in-string
                 "elpamr-package-list-html"
                 (elpamr--format-package-list-into-html rlt)
                 (elpamr--get-string-from-file html-tmpl)
                 t))
        (setq str (replace-regexp-in-string
                   "elpamr-package-list-json"
                   (elpamr--format-package-list-into-json rlt)
                   str
                   t))
        (setq str (replace-regexp-in-string
                   "elpamr-email"
                   (elpamr--format-email)
                   str
                   t))
        (setq str (replace-regexp-in-string
                   "elpamr-repository-name"
                   elpamr-repository-name
                   str
                   t))
        (setq str (replace-regexp-in-string
                   "elpamr-repository-path"
                   elpamr-repository-path
                   str
                   t))
        (insert str))
      (write-file html-file))

    ;; js file
    (with-temp-buffer
      (let ((print-level nil)  (print-length nil))
        (insert (elpamr--get-string-from-file js-tmpl)))
      (write-file js-file))
    ))

(defun elpamr--is-single-el-by-name (name pkglist)
  (interactive)
  (let (rlt)
    (dolist (pkg pkglist)
      (if (string= (car pkg) name)
          (setq rlt (elpamr--is-single-el pkg))
        ))
    rlt))

(defun elpamr--one-item-for-archive-contents (final-pkg)
  (let ((a (elpamr--get-info-array final-pkg)) )
    (format " (%s . [%S %S \"%s\" %S])\n"
            (car final-pkg)
            (elpamr--get-version final-pkg)
            (elpamr--get-dependency final-pkg)
            (elpamr--get-description final-pkg)
            (elpamr--get-type final-pkg))
    ))

;;;###autoload
(defun elpamr--version ()
  (interactive)
  (message "1.1.5"))

;;;###autoload
(defun elpamr-create-mirror-for-installed ()
  "Export INSTALLED packages into a new directory. Create html files for the mirror site.
If elpamr-default-output-directory is not nil, it's assumed that is output directory. Or else, user will be asked to provide the output directory."
  (interactive)
  (let (item final-pkg-list pkg-dirname pkg-info tar-cmd len dirs cnt)
    ;; quoted from manual:
    ;;   Alist of all packages available for activation.
    ;;   Each element has the form (PKG . DESCS), where PKG is a package
    ;;   name (a symbol) and DESCS is a non-empty list of `package-desc' structure,
    ;;   sorted by decreasing versions.
    (dolist (pkg package-alist)
      (setq item (elpamr--create-one-item-for-archive-contents pkg))
      (if item (push item final-pkg-list))
      )

    ;; set output directory
    (unless (and elpamr-default-output-directory (file-directory-p elpamr-default-output-directory))
      (setq elpamr-default-output-directory (read-directory-name "Output directory:"))
      )

    (when (and (> (length final-pkg-list) 0)
               elpamr-default-output-directory
               (file-directory-p elpamr-default-output-directory))
      ;; package-user-dir is ~/.emacs.d/elpa by default
      (setq dirs (directory-files package-user-dir))
      ;; prepare to loop dirs
      (setq cnt 0)
      (setq len (length dirs))
      (dolist (dir dirs)
        (unless (or (member dir '("archives" "." ".."))
                    (not (setq pkg-info (elpamr--extract-info-from-dir dir))))

          (cond
           ;; copy single el
           ((elpamr--is-single-el-by-name (car pkg-info) final-pkg-list)
            (setq tar-cmd (concat "cd " package-user-dir
                                  "; cp "
                                  (file-name-as-directory dir) (car pkg-info) ".el"
                                  " "
                                  (elpamr--output-fullpath dir)
                                  ".el ")))
           ;; create tar using GNU tar or BSD tar
           (t
            (setq tar-cmd (concat "cd "
                                  package-user-dir
                                  "; COPYFILE_DISABLE=\"\" tar cf "
                                  (elpamr--output-fullpath dir) ".tar --exclude=\"*.elc\" --exclude=\"*~\" "
                                  dir))
            ))

          (when elpamr-debug
            (message "elpamr-default-output-directory=%s" elpamr-default-output-directory)
            (message "package-alist=%s" package-alist)
            (message "package-user-dir=%s" package-user-dir)
            (message "elpamr--output-fullpath" elpamr--output-fullpath)
            (message "tar-cmd=%s" tar-cmd))

          (shell-command tar-cmd)
          (setq cnt (1+ cnt))
          (message "Creating *.tar and *.el ... %d%%" (/ (* cnt 100) len))
          ))

      ;; output archive-contents
      (with-temp-buffer
        (let ((print-level nil)  (print-length nil))
          (insert "(1\n")
          (dolist (final-pkg final-pkg-list)
            ;; each package occupies one line
            (insert (elpamr--one-item-for-archive-contents final-pkg)))
          (insert ")"))
        (write-file (elpamr--output-fullpath "archive-contents")))
      (elpamr--output-html final-pkg-list)
      (message "DONE! Output into %s" elpamr-default-output-directory))
    ))

(provide 'elpa-mirror)
