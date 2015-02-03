(setq inhibit-splash-screen t)
(setq initial-scratch-message nil)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; packages
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages
  '(solarized-theme
    flycheck
    cider clojure-mode
    haskell-mode ghc flycheck-haskell
    idris-mode
    ace-jump-mode
    paredit
    rainbow-delimiters highlight-parentheses
    markdown-mode
    auctex
    company company-ghc
    exec-path-from-shell
    expand-region multiple-cursors
    helm
    llvm-mode)
  "A list of packages to ensure are installed at launch.")

(when (boundp 'package-pinned-packages)
  (setq package-pinned-packages
        '((idris-mode . "melpa-stable"))))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(exec-path-from-shell-initialize)

;; configuration
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(global-set-key (kbd "RET") 'newline-and-indent)

(setq indent-tabs-mode nil)
(setq apropos-do-all t
      mouse-yank-at-point t
      save-place-file (concat user-emacs-directory "places")
      backup-directory-alist `(("." . ,(concat user-emacs-directory "backups"))))

(delete-selection-mode 1)
(column-number-mode 1)
(highlight-parentheses-mode 1)
(require 'saveplace)
(setq save-place t)
(setq TeX-PDF-mode t)

(defalias 'yes-or-no-p 'y-or-n-p)
(windmove-default-keybindings)
(setq default-directory "~/")

(setq indent-tabs-mode nil)
(setq tab-width 2)
(setq indent-line-function 'insert-tab)

;; Mac: Command is Meta and leave Option alone
(if (eq system-type 'darwin)
    (progn
      (setq mac-option-key-is-meta nil)
      (setq mac-command-key-is-meta t)
      (setq mac-command-modifier 'meta)
      (setq mac-option-modifier nil)))

(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(load-theme 'solarized-light t)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode-enable)
(add-hook 'after-init-hook #'global-flycheck-mode)
(if (eq system-type 'darwin)
    (set-frame-font "Menlo 12")
  (set-frame-font "Dejavu Sans Mono 12"))

;; helm
(require 'helm)
(require 'helm-config)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
(define-key helm-map (kbd "C-z") 'helm-select-action)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "C-x b") 'helm-mini)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-c C-t") 'helm-semantic-or-imenu)

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t
      helm-move-to-line-cycle-in-source     t
      helm-ff-search-library-in-sexp        t
      helm-scroll-amount                    8
      helm-ff-file-name-history-use-recentf t
      helm-buffers-fuzzy-matching           t
      helm-recentf-fuzzy-match              t
      helm-semantic-fuzzy-match             t
      helm-imenu-fuzzy-match                t)

(helm-mode 1)

;; ace-jump-mode
(global-set-key (kbd "C-o") 'ace-jump-word-mode)

;; paredit
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)
(add-hook 'clojure-mode-hook 'paredit-mode)
(add-hook 'cider-repl-mode-hook 'paredit-mode)
(add-hook 'lisp-interaction-mode-hook 'paredit-mode)
(add-hook 'scheme-mode-hook 'paredit-mode)

;; rust
(add-hook 'rust-mode-hook 'flycheck-rust-setup)

;; company mode
(global-company-mode 1)
(setq company-tooltip-limit 20)
(setq company-idle-delay .2)
(setq company-echo-delay 0)
(setq company-require-match nil)
(add-to-list 'company-backends 'company-ghc)

;; clojure
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
(setq nrepl-hide-special-buffers t)
(setq cider-popup-stacktraces nil)
(add-hook 'clojure-mode-hook #'(lambda () (flycheck-mode -1)))

;; indentation, add more as needed
(add-hook 'clojure-mode-hook
          (lambda ()
            (put-clojure-indent 'div 1)
            (put-clojure-indent 'span 1)))

;; haskell
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(setq haskell-program-name "cabal repl")
(setq haskell-stylish-on-save t)

(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-haskell-setup))

;; ghc-mod
(autoload 'ghc-init "ghc" nil t)
(autoload 'ghc-debug "ghc" nil t)
(add-hook 'haskell-mode-hook (lambda () (ghc-init)))

;; flyspell
(setq ispell-program-name "aspell")
(add-hook 'text-mode-hook (lambda () (flyspell-mode 1)
                            (setq ispell-dictionary "da")))

;; expand-region
(global-set-key (kbd "C-=") 'er/expand-region)

;; multiple-cursors
(global-set-key (kbd "C-n") 'mc/mark-next-like-this)
(global-set-key (kbd "C-S-n") 'mc/mark-previous-like-this)

;; Lambdas
(defun lambda-as-lambda (mode pattern)
  (font-lock-add-keywords
   mode `((,pattern
           (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                     "λ" 'decompose-region)))))))

(lambda-as-lambda 'emacs-lisp-mode "(\\(\\<lambda\\>\\)")
(lambda-as-lambda 'scheme-mode "(\\(\\<lambda\\>\\)")
(lambda-as-lambda 'clojure-mode "(\\(\\<fn\\>\\)")

;; HDL
(add-to-list 'auto-mode-alist '("\\.hdl\\'" . java-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-command-list
   (quote
    (("TeX" "%(PDF)%(tex) %`%S%(PDFout)%(mode)%' %t" TeX-run-TeX nil
      (plain-tex-mode texinfo-mode ams-tex-mode)
      :help "Run plain TeX")
     ("LaTeX" "%`%l%(mode)%' %t" TeX-run-TeX nil
      (latex-mode doctex-mode)
      :help "Run LaTeX")
     ("Makeinfo" "makeinfo %t" TeX-run-compile nil
      (texinfo-mode)
      :help "Run Makeinfo with Info output")
     ("Makeinfo HTML" "makeinfo --html %t" TeX-run-compile nil
      (texinfo-mode)
      :help "Run Makeinfo with HTML output")
     ("AmSTeX" "%(PDF)amstex %`%S%(PDFout)%(mode)%' %t" TeX-run-TeX nil
      (ams-tex-mode)
      :help "Run AMSTeX")
     ("ConTeXt" "context --once --batchmode %t" TeX-run-TeX nil
      (context-mode)
      :help "Run ConTeXt once")
     ("ConTeXt Full" "context %t" TeX-run-TeX nil
      (context-mode)
      :help "Run ConTeXt until completion")
     ("BibTeX" "bibtex %s" TeX-run-BibTeX nil t :help "Run BibTeX")
     ("Biber" "biber %s" TeX-run-Biber nil t :help "Run Biber")
     ("View" "%V" TeX-run-discard-or-function t t :help "Run Viewer")
     ("Print" "%p" TeX-run-command t t :help "Print the file")
     ("Queue" "%q" TeX-run-background nil t :help "View the printer queue" :visible TeX-queue-command)
     ("File" "%(o?)dvips %d -o %f " TeX-run-command t t :help "Generate PostScript file")
     ("Index" "makeindex %s" TeX-run-command nil t :help "Create index file")
     ("Check" "lacheck %s" TeX-run-compile nil
      (latex-mode)
      :help "Check LaTeX file for correctness")
     ("Spell" "(TeX-ispell-document \"\")" TeX-run-function nil t :help "Spell-check the document")
     ("Clean" "TeX-clean" TeX-run-function nil t :help "Delete generated intermediate files")
     ("Clean All" "(TeX-clean t)" TeX-run-function nil t :help "Delete generated intermediate and output files")
     ("Other" "" TeX-run-command t t :help "Run an arbitrary command"))))
 '(custom-safe-themes
   (quote
    ("cdc7555f0b34ed32eb510be295b6b967526dd8060e5d04ff0dce719af789f8e5" "3a727bdc09a7a141e58925258b6e873c65ccf393b2240c51553098ca93957723" "6a37be365d1d95fad2f4d185e51928c789ef7a4ccf17e7ca13ad63a8bf5b922f" "756597b162f1be60a12dbd52bab71d40d6a2845a3e3c2584c6573ee9c332a66e" default)))
 '(flycheck-haskell-runhaskell "runhaskell")
 '(purescript-mode-hook
   (quote
    (capitalized-words-mode turn-on-eldoc-mode turn-on-purescript-indentation))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(preview-face ((t (:background "#fdf6e3"))))
 '(preview-reference-face ((t (:background "#fdf6e3")))))

(put 'upcase-region 'disabled nil)
