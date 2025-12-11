;;; init-lsp-package.el --- Emacs 初始化配置
;;; Commentary:
;; 这个文件包含所有插件的配置
;;; Code:

;; ========== 软件源配置 ==========
(require 'package)
;; 设置软件源镜像（加速下载）
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("org" . "https://orgmode.org/elpa/")))

;; 初始化包系统
(package-initialize)

;; 刷新包内容（仅在需要时）
(unless package-archive-contents
  (package-refresh-contents))

;; ========== use-package 配置 ==========
;; 如果没有安装 use-package，则自动安装它
(unless (package-installed-p 'use-package)
  (message "正在安装 use-package...")
  (package-refresh-contents)
  (package-install 'use-package))

;; 配置 use-package
(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-verbose t)  ; 显示详细加载信息

;; ========== 核心设置 ==========
;; 从 shell 导入环境变量（macOS 重要）
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

;; 规范临时文件
(use-package no-littering
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

;; 禁用备份文件
(setq make-backup-files nil)
(setq auto-save-default nil)

;; ========== Ivy 搜索框架 ==========
;; Ivy - 强大的补全框架
(use-package ivy
  :ensure t
  :init
  (ivy-mode 1)  ; 启用 Ivy 补全框架（全局生效）
  :config
  ;; 可选优化
  (setq ivy-use-virtual-buffers t)  ; 在 C-x b 中包含最近关闭的文件
  (setq enable-recursive-minibuffers t)  ; 允许在 minibuffer 中执行 M-x
  (setq ivy-re-builders-alist '((t . ivy--regex-ignore-order)))  ; 模糊匹配：顺序无关
  (setq ivy-initial-inputs-alist nil))  ; 移除 M-x 中默认的 "*" 前缀

;; Counsel - Ivy 的扩展命令
(use-package counsel
  :after ivy
  :ensure t
  :config
  ;; 🎯 绑定所有关键快捷键
  (global-set-key (kbd "M-x") 'counsel-M-x)          ; 命令执行
  (global-set-key (kbd "C-x C-f") 'counsel-find-file) ; 找文件
  (global-set-key (kbd "C-x d") 'counsel-dired)       ; Dired 目录
  (global-set-key (kbd "C-x b") 'counsel-switch-buffer) ; 切换 buffer
  (global-set-key (kbd "C-x C-r") 'counsel-recentf)    ; 打开最近文件
  (global-set-key (kbd "C-c g f") 'counsel-git-files)  ; Git 项目文件
  (global-set-key (kbd "C-c g g") 'counsel-git)        ; Git 命令
  (global-set-key (kbd "C-c i") 'counsel-imenu)        ; 当前文件函数/变量跳转
  (global-set-key (kbd "C-c j") 'counsel-bookmark)     ; 书签
  (global-set-key (kbd "C-h f") 'counsel-describe-function)
  (global-set-key (kbd "C-h v") 'counsel-describe-variable))

;; Swiper - 增强的搜索
(use-package swiper
  :ensure t
  :bind
  (("C-s" . swiper)
   ("C-r" . swiper)))

;; 增强 Ivy 的显示
(use-package ivy-rich
  :ensure t
  :after ivy
  :init
  (ivy-rich-mode 1))

;; 为 Ivy 添加图标
(use-package all-the-icons-ivy-rich
  :ensure t
  :after (ivy-rich all-the-icons)
  :init
  (all-the-icons-ivy-rich-mode 1))

(use-package xref
  :ensure nil
  :config
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read))

;; ========== 窗口管理 ==========
(use-package windmove
  :ensure t
  :bind
  (("C-<left>" . windmove-left)
   ("C-<right>" . windmove-right)
   ("M-<up>" . windmove-up)
   ("M-<down>" . windmove-down)))

;; ========== 项目管理 ==========
(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  ;; 设置项目搜索路径
  (setq projectile-project-search-path '("~/Sec/Code/"))
  ;; 确保项目根目录识别函数链能识别各种项目标记
  (setq projectile-project-root-functions
        '(projectile-root-local
          projectile-root-marked
          projectile-root-bottom-up
          projectile-root-top-down
          projectile-root-top-down-recurring))
  ;; 添加 Cargo.toml 到识别标记列表中
  (add-to-list 'projectile-project-root-files-bottom-up "Cargo.toml")
  ;; 性能优化：使用 fd 替代 find
  (setq projectile-indexing-method 'alien)
  (setq projectile-generic-command "fd . -0 --type f --color=never"))

;; 将 M-p 绑定到 projectile-find-file 命令
(define-key projectile-mode-map (kbd "M-p") 'projectile-find-file)

;; ========== 界面增强 ==========
;; 禁用 which-key 的自动模式，改为手动触发
(use-package which-key
  :config
  (which-key-mode -1)  ; 禁用自动模式
  ;; 设置手动调用的快捷键
  :bind
  (("C-h k" . which-key-show-top-level)   ; 显示顶层快捷键
   ("C-h p" . which-key-show-major-mode)  ; 显示当前主模式快捷键
   ("C-h w" . which-key-show-full-hierarchy))) ; 显示完整层级

;; 现代化模式行
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :config
  (setq doom-modeline-height 25))

;; 精美主题
(use-package doom-themes
  :config
  (load-theme 'doom-peacock t))

;; 图标支持
(use-package all-the-icons
  :if (display-graphic-p))

;; ========== Git 集成 ==========
;; Git 管理（Magit 是必装神器）
(use-package magit
  :bind ("C-x g" . magit-status))

;; ========== 编辑增强 ==========
;; 快速跳转
(use-package avy
  :bind
  (("C-." . avy-goto-char-timer)
   ("C-," . avy-goto-line)))

;; Dashboard - 启动画面
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents . 5)
                          (agenda . 5)
                          (bookmarks . 3)))
  ;; 自定义标题
  (setq dashboard-item-names
        '(("Recent Files:" . "🚀 快速开始")
          ("Agenda for today:" . "")
          ("Agenda for the coming week:" . "🌟 工作区")
          ("Bookmarks:" ."🔖 书签")))
  (setq dashboard-banner-logo-title "欢迎回家！")
  (setq dashboard-startup-banner 'logo))

;; ========== 语法检查 ==========
(use-package flycheck
  :hook (after-init . global-flycheck-mode)
  :config
  ;; 配置 flycheck 使用 LSP 诊断
  (setq flycheck-check-syntax-automatically '(save mode-enabled)))

;; ========== LSP 配置 ==========
;; lsp-mode - 语言服务器协议支持
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (((prog-mode c-mode c++-mode python-mode rust-mode js-mode typescript-mode java-mode go-mode)
          . lsp-deferred))
  
  :config
  ;; 基本配置
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-headerline-breadcrumb-enable nil)
  
  ;; 性能优化
  (setq lsp-enable-symbol-highlighting nil)
  (setq lsp-enable-on-type-formatting nil)
  (setq lsp-enable-code-action-on-save t)  ; 启用代码操作（如组织导入）
  (setq lsp-enable-snippet t)  ; 启用代码片段支持
  
  ;; 诊断显示 - 使用 flycheck 而不是 lsp-ui
  (setq lsp-diagnostic-provider :none)  ; 不使用 lsp 的诊断，使用 flycheck
  (setq lsp-enable-file-watchers nil)
  
  ;; UI 配置
  (setq lsp-signature-auto-activate t)
  (setq lsp-modeline-diagnostics-scope :workspace)
  (setq lsp-modeline-code-actions-enable t)
  
  ;; 格式化设置
  (setq lsp-format-on-save nil)  ; 默认不格式化，由各语言配置决定
  
  ;; 启用 LSP 支持的补全
  (setq lsp-completion-provider :none)  ; 使用 Emacs 的 completion-at-point-functions
  (setq lsp-enable-completion t)
  (setq lsp-enable-indentation t)
  
  ;; 修复 LSP 与 company-mode 的集成
  (setq lsp-completion-enable-additional-text-edit nil)
  (setq lsp-completion-enable-snippet t))

;; lsp-ui - lsp-mode 的 UI 扩展
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-peek-enable t)
  (setq lsp-ui-sideline-enable nil)  ; 默认禁用 sideline
  (setq lsp-ui-doc-enable t)  ; 启用文档显示
  (setq lsp-ui-doc-show-with-cursor t)
  (setq lsp-ui-doc-show-with-mouse t)
  (setq lsp-ui-doc-delay 0.5)
  
  ;; 侧边栏符号导航
  (setq lsp-ui-sideline-ignore-duplicate t)
  (setq lsp-ui-sideline-show-hover nil))

;; 公司模式（自动补全）
(use-package company
  :hook (after-init . global-company-mode)
  :config
  (setq company-minimum-prefix-length 1)
  (setq company-idle-delay 0.1)
  (setq company-tooltip-limit 10)
  (setq company-selection-wrap-around t)
  
  ;; 配置公司模式后端
  (setq company-backends
        '((company-capf :with company-yasnippet)  ; completion-at-point-functions
          company-files
          company-keywords
          company-clang
          company-dabbrev))
  
  ;; 为 LSP 设置特别的补全设置
  (add-hook 'lsp-mode-hook
            (lambda ()
              (set (make-local-variable 'company-backends)
                   '((company-capf :with company-yasnippet)
                     company-files)))))

;; 代码片段支持
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

;; ========== 语言特定配置 ==========

;; Python 配置
(use-package python
  :ensure nil
  :hook (python-mode . (lambda ()
                         (setq indent-tabs-mode nil
                               tab-width 4
                               python-indent-offset 4)
                         (subword-mode 1)))
  :config
  (when (executable-find "python3")
    (setq python-shell-interpreter "python3")))

;; 虚拟环境管理
(use-package pyvenv
  :ensure t
  :hook (python-mode . pyvenv-mode)
  :config
  (setq pyvenv-mode-line-indicator '(pyvenv-virtual-env-name (" [venv:" pyvenv-virtual-env-name "] ")))
  :bind ("C-c v" . pyvenv-workon))

;; 代码格式化
(use-package blacken
  :ensure t
  :after python
  :hook (python-mode . blacken-mode)
  :config
  (setq blacken-line-length 88))

;; Rust 配置
(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'"
  :hook (rust-mode . (lambda ()
                       (setq indent-tabs-mode nil
                             tab-width 4)
                       (subword-mode +1)))
  :config
  (setq rust-format-on-save t)
  (setq rust-analyzer-server-command '("rust-analyzer")))

;; Cargo 集成
(use-package cargo
  :ensure t
  :hook (rust-mode . cargo-minor-mode))


;; C/C++ 配置
(use-package cc-mode
  :ensure nil
  :hook ((c-mode c++-mode) . (lambda ()
                              (setq indent-tabs-mode nil
                                    tab-width 4
                                    c-basic-offset 4))))




;; Go 配置
(use-package go-mode
  :ensure t
  :mode "\\.go\\'"
  :hook (go-mode . (lambda ()
                    (setq tab-width 4
                          indent-tabs-mode t))))  ; Go 语言使用 Tab 进行缩进


;; JavaScript/TypeScript 配置
(use-package typescript-mode
  :ensure t
  :mode ("\\.tsx?\\'" "\\.jsx?\\'")
  :hook (typescript-mode . (lambda ()
                            (setq indent-tabs-mode nil
                                  tab-width 2
                                  typescript-indent-level 2)
                            (subword-mode +1))))


;; JSX/TSX 支持
(use-package tree-sitter
  :ensure t
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs
  :ensure t
  :after tree-sitter)

;; React 专用模式
(use-package rjsx-mode
  :ensure t
  :mode ("\\.jsx\\'" "\\.tsx\\'")
  :hook (rjsx-mode . (lambda ()
                      (setq js-indent-level 2
                            js-switch-indent-offset 2))))

;; Vue.js 配置
(use-package vue-mode
  :ensure t
  :mode ("\\.vue\\'")
  :hook (vue-mode . (lambda ()
                     (setq indent-tabs-mode nil
                           tab-width 2
                           vue-html-indent 2
                           vue-attr-indent 2
                           vue-script-indent 2
                           vue-style-indent 2)
                     (subword-mode +1)))
  :config
  (setq vue-modes '((vue-html-mode html-mode)
                    (vue-style-mode css-mode)
                    (vue-script-mode js-mode))))

;; Web 开发通用工具
(use-package add-node-modules-path
  :ensure t
  :hook ((js-mode typescript-mode rjsx-mode vue-mode) . add-node-modules-path))

(use-package prettier-js
  :ensure t
  :hook ((js-mode typescript-mode js2-mode rjsx-mode vue-mode) . prettier-js-mode)
  :config
  (setq prettier-js-args '("--trailing-comma" "all"
                           "--single-quote" "true"
                           "--print-width" "80")))

;; ========== 快捷键增强 ==========
(global-set-key (kbd "C-c l r") #'lsp-rename)
(global-set-key (kbd "C-c l a") #'lsp-execute-code-action)
(global-set-key (kbd "C-c l d") #'lsp-describe-thing-at-point)
(global-set-key (kbd "C-c l h") #'lsp-ui-doc-glance)
(global-set-key (kbd "C-c l s") #'lsp-signature-help)

;; ========== 代码格式化函数 ==========
(defun my/lsp-format-buffer ()
  "Format buffer using LSP when saving."
  (when (and (lsp-mode) (lsp-feature? "format"))
    (lsp-format-buffer)))

(defun my/lsp-organize-imports ()
  "Organize imports using LSP."
  (when (and (lsp-mode) (lsp-feature? "organizeImports"))
    (lsp-organize-imports)))

;; 按语言模式添加保存钩子
(dolist (mode '(python-mode rust-mode c-mode c++-mode js-mode typescript-mode go-mode))
  (add-hook mode (lambda ()
                  (add-hook 'before-save-hook #'my/lsp-format-buffer nil t)
                  (add-hook 'before-save-hook #'my/lsp-organize-imports nil t))))

;; Python 使用 black
(add-hook 'python-mode-hook
          (lambda ()
            (remove-hook 'before-save-hook #'my/lsp-format-buffer t)
            (add-hook 'before-save-hook #'blacken-buffer nil t)))

;;; init-package.el ends here
(provide 'init-lsp-package)
