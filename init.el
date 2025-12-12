;;; init.el

;;; Commentary:


;;; Code:
(add-to-list 'load-path "~/.emacs.d/lisp")
(require 'init-basic)
;;(require 'init-package)
(require 'init-lsp-package)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(add-node-modules-path all-the-icons-dired all-the-icons-ivy-rich
			   blacken cape cargo centaur-tabs company-box
			   company-c-headers company-jedi
			   company-racer consult corfu-terminal
			   counsel dash-docs dashboard diff-hl
			   dired-sidebar doom-modeline doom-themes
			   dumb-jump ef-themes exec-path-from-shell
			   fd-dired flycheck-rust format-all go-mode
			   imenu-list ivy-posframe lsp-java
			   lsp-python-ms lsp-ui magit marginalia
			   no-littering orderless org-plus-contrib
			   prettier-js projectile-ripgrep pytest
			   python-black python-mode pyvenv rjsx-mode
			   rust-mode tree-sitter-langs treemacs-evil
			   treemacs-projectile typescript-mode vertico
			   vterm vue-mode yasnippet-snippets)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(swiper-line-face ((t (:background "#2a2e3a" :foreground unspecified :distant-foreground unspecified))))
 '(swiper-match-face-1 ((t (:background "#5d4d7a" :foreground "#ffffff" :weight bold))))
 '(swiper-match-face-2 ((t (:background "#3a5d7a" :foreground "#ffffff" :weight bold))))
 '(swiper-match-face-3 ((t (:background "#7a5d3a" :foreground "#ffffff" :weight bold))))
 '(swiper-match-face-4 ((t (:background "#4d7a5d" :foreground "#ffffff" :weight bold)))))
(put 'scroll-left 'disabled nil)
