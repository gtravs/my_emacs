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
   '(add-node-modules-path all-the-icons-dired all-the-icons-dirvish
			   all-the-icons-ivy-rich blacken cape cargo
			   company-box company-c-headers company-jedi
			   company-lsp company-racer consult-dirvish
			   corfu corfu-terminal counsel dap-mode
			   dash-docs dashboard diff-hl dired-sidebar
			   doom-modeline doom-themes dumb-jump
			   exec-path-from-shell fd-dired flycheck-rust
			   format-all go-mode imenu-list lsp-clangd
			   lsp-go lsp-java lsp-python-ms lsp-rust
			   lsp-rust-analyzer lsp-typescript lsp-ui
			   magit maven-mode no-littering orderless
			   org-plus-contrib prettier-js
			   projectile-ripgrep pytest python-black
			   python-mode pyvenv rjsx-mode rust-mode
			   tree-sitter tree-sitter-langs treemacs-evil
			   treemacs-projectile vue-mode
			   yasnippet-snippets)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'scroll-left 'disabled nil)
