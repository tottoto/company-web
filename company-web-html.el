;;; company-web-html.el --- company for html-mode & web-mode

;; Copyright (C) 2015 Olexandr Sydorchuck

;; Author: Olexandr Sydorchuck <olexandr.syd@gmail.com>
;; Keywords: html, company, auto-complete

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

;; Configuration:
;;

;;; Code:

(require 'company-web)

(defconst company-web/html-get-tag-re
  (concat "<[[:space:]]*\\(" company-web-selector "+\\)[[:space:]]+")
  "Regexp of html tag")

(defconst company-web/html-get-attribute-re
  (concat "[^[:alnum:]-]\\(" company-web-selector "+\\)=")
  "Regexp of html attribute")

(defun company-web/current-html-tag ()
  "Return current html tag user is typing on."
  (save-excursion
    (re-search-backward company-web/html-get-tag-re nil t)
    (match-string 1)))

(defun company-web/current-html-attribute ()
  "Return current html tag's attribute user is typing on."
  (save-excursion
    (re-search-backward company-web/html-get-attribute-re nil t)
    (match-string 1)))

(defconst company-web/html-tag-regexp
  (concat "<[[:space:]]*\\("
          company-web-selector
          "*\\)")
  "A regular expression matching HTML tags.")

(defconst company-web/html-attribute-regexp
  (concat "<[[:space:]]*" company-web-selector "[^>]*[[:space:]]+\\(.*\\)")
  "A regular expression matching HTML attribute.")

(defconst company-web/html-value-regexp
  (concat "\\w=[\"]\\(?:[^\"]+[ ;:]\\|\\)"
          "\\(" company-web-selector "*\\)")
  "A regular expression matching HTML attribute.")

;;;###autoload
(defun company-web-html (command &optional arg &rest ignored)
  "`company-mode' completion back-end for `html-mode' and `web-mode'."
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-web-html))
    (ignore-case t)
    (duplicates nil)
    (prefix (and (or (derived-mode-p 'html-mode)
                     (derived-mode-p 'web-mode))
                 (or (company-grab company-web/html-value-regexp 1)
                     (company-grab company-web/html-tag-regexp 1)
                     (company-grab company-web/html-attribute-regexp 1)
                     )))
    (candidates
     (cond
      ;; value
      ((company-grab company-web/html-value-regexp 1)
       (message "!!VALUE of %s" arg)
       (all-completions arg (company-web-candidates-attrib-values (company-web/current-html-tag)
                                                                  (company-web/current-html-attribute))))
      ;; tag
      ((and (not (company-web-is-point-in-string-face))
            (company-grab company-web/html-tag-regexp 1))
       (message "!!TAG of %s" arg)
       (all-completions arg (company-web-candidates-tags)))
      ;; attr
      ((and (not (company-web-is-point-in-string-face))
            (company-grab company-web/html-attribute-regexp 1))
       (message "!!ATTR of %s" arg)
       (all-completions arg (company-web-candidates-attribute (company-web/current-html-tag))))))
    (annotation (company-web-annotation arg))
    (doc-buffer
     ;; No need grab for attribute value, attribute regexp will match enyway
     (cond
      ;; tag
      ((company-grab company-web/html-tag-regexp 1)
       (company-web-tag-doc arg))
      ;; attr
      ((company-grab company-web/html-attribute-regexp 1)
       (company-web-attribute-doc (company-web/current-html-tag) arg))))))

;;; company-web-html.el ends here
