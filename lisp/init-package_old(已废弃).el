;;; init-package

;;; Commentary:
;; 这个文件包含所有插件的配置

;;; Code:

;; ========== 软件源配置 ==========
(require 'package)

;; 设置软件源镜像（加速下载）
(setq package-archives
      '(("gnu"          . "https://elpa.gnu.org/packages/")
        ("melpa"        . "https://melpa.org/packages/")
        ("nongnu"       . "https://elpa.nongnu.org/nongnu/")
        ("org"          . "https://orgmode.org/elpa/")
        
        ;; 备用源
        ;; ("melpa-stable" . "https://stable.melpa.org/packages/")
        ;; ("gnu-cn"       . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ;; ("melpa-cn"     . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
        ))


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

;; ========== 常用插件配置示例 ==========
;; ========== 常用插件配置示例 ==========
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

;; ========== Ivy 核心插件（新增） ==========

;; Ivy - 强大的补全框架
(use-package ivy
  :ensure t
  :init
  (ivy-mode 1) ; 启用 Ivy 补全框架（全局生效）
  :config
  ;; 可选优化
  (setq ivy-use-virtual-buffers t)     ; 在 C-x b 中包含最近关闭的文件
  (setq enable-recursive-minibuffers t) ; 允许在 minibuffer 中执行 M-x
  (setq ivy-re-builders-alist
        '((t . ivy--regex-ignore-order))) ; 模糊匹配：顺序无关（如 "proj main" 匹配 "main-project.el"）
  (setq ivy-initial-inputs-alist nil)   ; 移除 M-x 中默认的 "*" 前缀
  )

(use-package counsel
  :after ivy
  :ensure t
  :config
  ;; 🎯 绑定所有关键快捷键
  (global-set-key (kbd "M-x")         'counsel-M-x)           ; 命令执行
  (global-set-key (kbd "C-x C-f")     'counsel-find-file)     ; 找文件
  (global-set-key (kbd "C-x d")       'counsel-dired)         ; Dired 目录（输入路径后打开）
  (global-set-key (kbd "C-x b")       'counsel-switch-buffer) ; 切换 buffer
  (global-set-key (kbd "C-x C-r")     'counsel-recentf)       ; 打开最近文件
  (global-set-key (kbd "C-c g f")     'counsel-git-files)     ; Git 项目文件（需在 git 仓库中）
  (global-set-key (kbd "C-c g g")     'counsel-git)           ; Git 命令
  (global-set-key (kbd "C-c i")       'counsel-imenu)         ; 当前文件函数/变量跳转
  (global-set-key (kbd "C-c j")       'counsel-bookmark)      ; 书签
  (global-set-key (kbd "C-h f")       'counsel-describe-function)
  (global-set-key (kbd "C-h v")       'counsel-describe-variable)

  ;; 💡 额外：让 C-x C-f 在输入目录时自动用 dirvish（如果你已配置 dirvish）
  ;; 注意：这依赖于 (dirvish-override-dired-mode)
  )



;; Swiper - 增强的搜索
(use-package swiper
  :ensure t
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

;; 增强 Ivy 的显示
(use-package ivy-rich
  :ensure t
  :after ivy
  :init (ivy-rich-mode 1))

;; 为 Ivy 添加图标
(use-package all-the-icons-ivy-rich
  :ensure t
  :after (ivy-rich all-the-icons)
  :init (all-the-icons-ivy-rich-mode 1))


(use-package xref
  :ensure nil
  :config
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read))

;; ========== 核心生产力插件 ==========
(use-package windmove
  :ensure t
  :bind (("C-<left>" . windmove-left)
         ("C-<right>" . windmove-right)
         ("M-<up>" . windmove-up)
         ("M-<down>" . windmove-down)))

;; 自动补全
(use-package company
  :hook (after-init . global-company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.1))

;; 语法检查
(use-package flycheck
  :hook (after-init . global-flycheck-mode))


(use-package projectile
  :ensure t ; 确保使用包管理器安装
  :config
  (projectile-mode +1) ; 使用 +1 是启用模式的惯例写法
  ;; 设置项目搜索路径（用于 projectile-switch-project 列出项目）
  (setq projectile-project-search-path '("~/Sec/Code/"))
  ;; 【关键配置】确保项目根目录识别函数链能识别 Cargo.toml
  ;; 特别是 `projectile-root-bottom-up` 函数会向上查找项目标记[1](@ref)
  (setq projectile-project-root-functions
        '(projectile-root-local
          projectile-root-marked
          projectile-root-bottom-up ; 这个函数会向上查找 .git, Cargo.toml 等标记[1](@ref)
          projectile-root-top-down
          projectile-root-top-down-recurring))
  ;; 【可选但推荐】明确将 Cargo.toml 添加到识别标记列表中[1](@ref)
  (add-to-list 'projectile-project-root-files-bottom-up "Cargo.toml")
  ;; 【可选】性能优化：使用 fd 替代 find 进行文件索引（如果系统有 fd）[2](@ref)
  (setq projectile-indexing-method 'alien)
  (setq projectile-generic-command "fd . -0 --type f --color=never"))

;; 将 M-p 直接绑定到 projectile-find-dir 命令
(define-key projectile-mode-map (kbd "M-p") 'projectile-find-file)

;; ========== 界面增强 ==========


;; 禁用 which-key 的自动模式，改为手动触发
(use-package which-key
  :config
  (which-key-mode -1)  ; 禁用自动模式
  
  ;; 设置手动调用的快捷键
  :bind (("C-h k" . which-key-show-top-level)         ; 显示顶层快捷键
         ("C-h p" . which-key-show-major-mode)         ; 显示当前主模式快捷键
         ("C-h w" . which-key-show-full-hierarchy)))   ; 显示完整层级


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

;; ========== 版本控制 ==========

;; Git 管理（Magit 是必装神器）
(use-package magit
  :bind ("C-x g" . magit-status))

;; ========== 编辑增强 ==========

;; 快速跳转
(use-package avy
  :bind (("C-." . avy-goto-char-timer)
         ("C-," . avy-goto-line)))


;; use-package with package.el:
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
    (setq dashboard-center-content t)
  (setq dashboard-items '((recents . 5)
                          (agenda . 5)
                          (bookmarks . 3)))
    ;; 自定义标题（选择您喜欢的方案）
  (setq dashboard-item-names '(("Recent Files:" . "🚀 快速开始")
                               ("Agenda for today:" . "")
                               ("Agenda for the coming week:" . "🌟 工作区")
			       ("Bookmarks:" ."🔖 书签")))
(setq dashboard-banner-logo-title "欢迎回家！")
(setq dashboard-startup-banner 'logo))




;; ============== 代码补全 ===================
(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)                ;; 启用循环选择
  (corfu-preselect 'valid)       ;; 智能预选择
  (corfu-auto t)                 ;; 自动触发补全
  (corfu-quit-at-boundary 'separator) ;; 智能退出边界
  (corfu-separator ?\s)          ;; Orderless风格分隔符
  (corfu-auto-prefix 2)          ;; 2字符触发自动补全
  (corfu-auto-delay 0.2)         ;; 补全延迟（秒）
  :bind (:map corfu-map
              ("TAB" . corfu-complete)  ;; TAB完成补全
              ("M-SPC" . corfu-insert-separator) ;; 插入分隔符
              ("M-q" . corfu-quick-complete)    ;; 快速选择
              ("M-h" . corfu-echo-documentation)) ;; 显示文档
  :init
  (global-corfu-mode))           ;; 全局启用


(use-package corfu-terminal
  :if (not (display-graphic-p))
  :after corfu
  :config
  (corfu-terminal-mode +1))


(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (orderless-component-separator #'orderless-escapable-split-on-space))

;; 在Corfu中启用Orderless
(add-hook 'corfu-mode-hook
          (lambda ()
            (setq-local completion-styles '(orderless basic))))



;; ========== Python 代码补全增强配置 ==========

;; LSP 支持
(use-package eglot
  :ensure t
  :hook ((python-mode python-ts-mode) . eglot-ensure)
  :config
  (setq eglot-autoshutdown t
        eglot-send-changes-idle-time 0.5)
  :bind (:map eglot-mode-map
              ("C-c l a" . eglot-code-actions)
              ("C-c l r" . eglot-rename)))

;; Python 主模式配置
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
(use-package python-black
  :ensure t
  :after python
  :hook (python-mode . python-black-on-save-mode-enable-dwim)
  :config
  (setq python-black-extra-args '("--line-length=88")))

;; 语法检查增强
(use-package flycheck
  :ensure t
  :hook (python-mode . flycheck-mode)
  :config
  (setq flycheck-check-syntax-automatically '(save mode-enabled)))

;; 公司模式后端支持
(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.2)
  :bind (:map company-active-map
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)))


;; ========== Rust 开发环境配置 ==========
;; Rust 主模式
(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'"
  :hook (rust-mode . (lambda ()
                      (setq indent-tabs-mode nil
                            tab-width 4
                            rust-format-on-save t)
                      (subword-mode +1)))
  :config
  (setq rust-format-show-buffer nil))

;; Eglot 集成（LSP 客户端）
(use-package eglot
  :ensure t
  :hook (rust-mode . eglot-ensure)
  :config
  (setq eglot-autoshutdown t
        eglot-send-changes-idle-time 0.5)
  (add-to-list 'eglot-server-programs
               '((rust-mode rust-ts-mode) . ("rust-analyzer"))))

;; Cargo 集成
(use-package cargo
  :ensure t
  :hook (rust-mode . cargo-minor-mode))



;; ========== C/C++ 开发环境配置 (基于 LSP) ==========
(use-package cc-mode
  :ensure nil
  :hook ((c-mode c++-mode) . (lambda ()
                              (setq indent-tabs-mode nil
                                    tab-width 4
                                    c-basic-offset 4)
                              (eglot-ensure))))

;; 配置 eglot 使用的服务器
(use-package eglot
  :ensure t
  :config
  (add-to-list 'eglot-server-programs
               '((c++-mode c-mode) . ("clangd" "--header-insertion=never"))) 
  ;; 可选：调整一些行为
  (setq eglot-autoshutdown t)
  (setq eglot-send-changes-idle-time 1.0))

;; Company-mode 作为补全前端
(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.3))



;; ========== Java 开发环境配置 (基于 Eglot) ==========
(use-package eglot
  :ensure t
  :config
  ;; 将 Java 语言服务器添加到 eglot 的管理列表
  (add-to-list 'eglot-server-programs
               `(java-mode . ,(eglot-alternatives
                               '("jdt-ls"))))


  ;; 可选：为 Java 项目设置更优的格式化和分析选项
  (add-hook 'java-mode-hook
            (lambda ()
              (setq-local tab-width 4)
              (setq-local indent-tabs-mode nil)
              (setq-local c-basic-offset 4)
              (eglot-ensure))))



;; ========== Go 开发环境配置 (基于 Eglot 和 gopls) ==========
(use-package go-mode
  :ensure t
  :mode "\\.go\\'"
  :hook (go-mode . (lambda ()
                    (setq tab-width 4)
                    (setq indent-tabs-mode t) ; Go 语言使用 Tab 进行缩进
                    (eglot-ensure))))


(use-package eglot
  :ensure t
  :config
  ;; 确保 gopls 被 eglot 识别
  (add-to-list 'eglot-server-programs
               '(go-mode . ("gopls"))))


  ;; 可选：在保存时自动格式化 Go 代码并组织 imports
  (add-hook 'go-mode-hook
            (lambda ()
              (add-hook 'before-save-hook #'eglot-format-buffer nil t)
              (add-hook 'before-save-hook #'eglot-code-action-organize-imports nil t)))


;; ========== JavaScript/TypeScript 开发环境配置 ==========
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

;; ========== Vue.js 开发环境配置 ==========
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
  (setq vue-modes
        '((vue-html-mode html-mode)
          (vue-style-mode css-mode)
          (vue-script-mode js-mode))))

;; ========== Web 开发通用工具 ==========
(use-package add-node-modules-path
  :ensure t
  :hook ((js-mode typescript-mode rjsx-mode vue-mode) . add-node-modules-path))

(use-package prettier-js
  :ensure t
  :hook ((js-mode typescript-mode js2-mode rjsx-mode vue-mode) . prettier-js-mode)
  :config
  (setq prettier-js-args '("--trailing-comma" "all"
                          "--single-quote" "true"
                          "--print-width" 80)))




;;; init-package end here
(provide 'init-package)
