;;; module-writing.el

(defvar biblio-directory (concat narf-dropbox-dir "docs/biblio/") "docstring")

(setq-default visual-fill-column-center-text t)

(defun narf|refresh-visual-fill-col ()
  (visual-fill-column-mode +1))

(defvar writing-mode-theme 'solarized-light)
(defvar writing-mode--last-mode-line mode-line-format)
(defvar writing-mode--last-indicator-list fringe-indicator-alist)
(define-minor-mode writing-mode "Mode for writing research papers or fiction."
  :lighter "swrite"
  :keymap (make-sparse-keymap)
  (let* ((mode-p writing-mode)
         (on-off (if mode-p +1 -1)))
    (visual-fill-column-mode on-off)
    (visual-line-mode on-off)
    (variable-pitch-mode on-off)
    (text-scale-set (if mode-p 2 0))
    (fringe-mode (if mode-p '6 narf-fringe-size))

    ;; (when writing-mode-theme
    ;;   (if mode-p
    ;;       (narf/load-theme writing-mode-theme)
    ;;     (narf/reset-theme)))

    (setq line-spacing (if mode-p '4 (default-value 'line-spacing)))
    (if (eq major-mode 'org-mode)
        (org-indent-mode (if mode-p -1 1))
      ;; (setq truncate-lines (if mode-p nil (default-value 'truncate-lines)))
      )

    (setq mode-line-format
          (if mode-p
              '("%e" (:eval (spaceline--prepare
                             '(narf-anzu narf-iedit narf-evil-substitute
                               (narf-buffer-path remote-host)
                               narf-buffer-modified
                               helm-number
                               helm-follow
                               helm-prefix-argument)
                             '((selection-info :face highlight-face :skip-alternate t)
                               narf-hud
                               ))))
            writing-mode--last-mode-line))

    (when IS-MAC
      (setq ;; sane trackpad/mouse scroll settings
       mac-mouse-wheel-smooth-scroll mode-p
       mouse-wheel-progressive-speed mode-p))))

;;; LaTeX

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq bibtex-dialect 'biblatex)
(setq bibtex-align-at-equal-sign t)
(setq bibtex-text-indentation 20)
(add-hook! bibtex-mode
  (local-set-key (kbd "C-c \\") 'bibtex-fill-entry)
  (setq fill-column 140))
(add-hook! latex-mode 'turn-on-auto-fill)
(add-hook! LaTeX-mode 'turn-on-auto-fill)

(use-package reftex
  :diminish reftex-mode
  :config
  (add-hook 'latex-mode-hook 'turn-on-reftex)
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  (setq reftex-plug-into-AUCTeX t
        reftex-ref-style-default-list '("Cleveref" "Hyperref" "Fancyref")
        reftex-default-bibliography
        `(,(expand-file-name "phys.bib" biblio-directory))))


;;; Bibtex

;; NOTE: http://bibdesk.sourceforge.net/

(use-package helm-bibtex
  :defer t
  :config
  (setq helm-bibtex-bibliography
        `(,(expand-file-name "phys.bib" biblio-directory))

        helm-bibtex-library-path
        `(,(expand-file-name "phys-pdf" biblio-directory))

        helm-bibtex-notes-path (expand-file-name "notes" biblio-directory)
        helm-bibtex-notes-extension ".org"

        helm-bibtex-pdf-open-function
        (lambda (fpath) (async-start-process "open-pdf" "/usr/bin/open" nil fpath))))


(provide 'module-writing)
;;; module-writing.el ends here
