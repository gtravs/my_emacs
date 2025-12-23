;;; init-lsp-package.el --- 扩展插件配置 -*- lexical-binding: t -*-
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
;; 完整的 Emacs 配置示例
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (daemonp)  ; 如果以 daemon 模式运行
    (setq exec-path-from-shell-variables
          '("PATH"
            "MANPATH"
            "CARGO_HOME"
            "RUSTUP_HOME"
            "JENV_ROOT"
            "SSH_AUTH_SOCK"
            "LANG"
            "LC_CTYPE"))
    
    (setq exec-path-from-shell-shell-name "fish")
    (exec-path-from-shell-initialize)))


;; 规范临时文件
(use-package no-littering
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

;; 禁用备份文件
(setq make-backup-files nil)
(setq auto-save-default nil)

;; md 
(use-package flymd
  :ensure t)

;; ========== Ivy 系列插件的美化增强 ==========

;; **1. 增强 Ivy 的视觉显示**
(use-package ivy
  :ensure t
  :config
  ;; 基础设置（你已配置的部分保持不变）
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-re-builders-alist '((t . ivy--regex-ignore-order)))
  (setq ivy-initial-inputs-alist nil)

  ;; 🎨 新增：深度美化设置
  ;; 设置匹配结果的高亮面（face）
  (setq ivy-highlight-face 'font-lock-variable-name-face) ; 匹配部分高亮
  (setq ivy-current-match-face 'highlight) ; 当前选中项高亮
  ;; 最小高度和计数提示
  (setq ivy-height 15) ; 候选列表行数
  (setq ivy-count-format "(%d/%d) ") ; 显示计数，如 (5/10)
  ;; 使用箭头作为分隔符，更美观
  (setq ivy-format-function #'ivy-format-function-arrow)
  ;; 在命令顶部显示提示信息
  (setq ivy-display-style 'fancy)
  ;; 延迟后显示提示（避免输入时闪烁）
  (setq ivy-display-prompt-delay 0.2)
  (ivy-mode 1))

;; **2. 强化 Counsel 的样式集成**
(use-package counsel
  :after ivy
  :ensure t
  :config
  (global-set-key (kbd "M-x") 'counsel-M-x)
  ;; ... 你已有的其他按键绑定保持不变

  ;; 🎨 新增：为特定 Counsel 命令美化显示
  ;; 例如，让文件查找显示更丰富的文件信息
  (setq counsel-find-file-ignore-regexp "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)")
  ;; 启用文件预览（在光标悬停时）
  (setq counsel-find-file-preview-side 'right)
  (setq counsel-find-file-size-truncate t)
  )

;; **3. 美化 Swiper 的搜索界面**
(use-package swiper
  :ensure t
  :bind (("C-s" . swiper)
         ("C-r" . swiper-backward))
  :config
  ;; 🎨 新增：增强 Swiper 的视觉反馈
  (setq swiper-action-recenter t) ; 匹配项居中显示
  (setq swiper-include-line-number-in-search t) ; 搜索时包含行号
  ;; 高亮所有匹配项（而不仅仅是当前行）
  (setq swiper-font-lock-exclude-number t)

  ;; 自定义 Swiper 的高亮颜色以匹配你的 ef-dark 主题[4](@ref)
  (custom-set-faces
   `(swiper-line-face ((t (:background "#2a2e3a" :foreground unspecified :distant-foreground unspecified)))) ; 当前行背景
   `(swiper-match-face-1 ((t (:background "#5d4d7a" :foreground "#ffffff" :weight bold)))) ; 匹配项1
   `(swiper-match-face-2 ((t (:background "#3a5d7a" :foreground "#ffffff" :weight bold)))) ; 匹配项2
   `(swiper-match-face-3 ((t (:background "#7a5d3a" :foreground "#ffffff" :weight bold)))) ; 匹配项3
   `(swiper-match-face-4 ((t (:background "#4d7a5d" :foreground "#ffffff" :weight bold)))) ; 匹配项4
   ))

;; **4. 增强 Ivy-Rich 的显示模式**
(use-package ivy-rich
  :ensure t
  :after (ivy all-the-icons)
  :init (ivy-rich-mode 1)
  :config
  ;; 🎨 新增：更丰富的列显示和转换器
  ;; 为 buffer 列表添加更多列（图标、项目、路径、大小、模式）
  (setq ivy-rich-display-transformers-list
        '(ivy-switch-buffer
          (:columns
           ((all-the-icons-ivy-rich-buffer-icon) ; 图标
            (ivy-rich-candidate (:width 0.3))    ; Buffer名称
            (ivy-rich-switch-buffer-project (:width 0.2 :face success)) ; 项目
            (ivy-rich-switch-buffer-path (:width 0.4 :face font-lock-comment-face)) ; 路径
            (ivy-rich-switch-buffer-size (:width 7 :face font-lock-constant-face)) ; 大小
            (ivy-rich-switch-buffer-mode (:width 0.12 :face font-lock-type-face)) ; 主模式
            (ivy-rich-switch-buffer-indicator (:width 0.1 :face error))) ; 指示器（如*修改*）
           :predicate
           (lambda (cand) (get-buffer cand)))
          ;; 也可以为其他命令（如counsel-M-x）定义丰富显示
          counsel-M-x
          (:columns
           ((all-the-icons-ivy-rich-function-icon) ; 命令图标
            (ivy-rich-candidate (:width 0.4))       ; 命令名
            (ivy-rich-counsel-function-docstring (:width 0.6 :face font-lock-doc-face))) ; 文档字符串
           :predicate
           (lambda (cand) (fboundp (intern cand))))))

  ;; 设置项目名称的获取方式（如果你使用 Projectile）
  (setq ivy-rich-project-root-cache-mode t)
  (setq ivy-rich-path-style 'abbrev) ; 路径显示风格：abbrev（缩写）或full（完整）
  )

;; **5. 强化 All-The-Icons-Ivy-Rich**
(use-package all-the-icons-ivy-rich
  :ensure t
  :after (ivy-rich all-the-icons)
  :init (all-the-icons-ivy-rich-mode 1)
  :config
  ;; 🎨 新增：确保图标正确加载并显示
  ;; 设置图标大小（可能需要根据你的字体调整）
  (setq all-the-icons-ivy-rich-icon-size 1.0)
  ;; 如果图标显示为乱码，确保已安装字体：
  ;; M-x all-the-icons-install-fonts
  )

;; **6. 可选：添加边际注释（Marginalia）进一步美化**
(use-package marginalia
  :ensure t
  :after ivy
  :init
  (marginalia-mode 1)
  :config
  ;; 在 minibuffer 中显示丰富的注解信息
  (setq marginalia-annotators
        '(marginalia-annotators-heavy marginalia-annotators-light nil))
  ;; 为特定命令启用注解
  (setq marginalia-command-filters
        '((counsel-find-file marginalia-annotate-file)
          (counsel-recentf marginalia-annotate-file)
          (counsel-projectile-find-file marginalia-annotate-file)))
  )

;; **7. 可选：添加平滑滚动效果**
(use-package ivy-posframe
  :ensure t
  :after ivy
  :init
  ;; 使用 posframe 显示候选框（更现代的外观）
  ;; 注意：此包可能需要额外依赖，且在某些终端中可能不支持
  ;; 如果你使用图形界面，可以取消注释以下行尝试
   (setq ivy-display-function #'ivy-posframe-display-at-frame-center)
   (ivy-posframe-mode 1) ; 启用
  )

;; ========== 最终通用配置建议 ==========
;; 确保在所有配置加载后，设置与你的 ef-dark 主题[4](@ref)协调的颜色
(add-hook 'after-init-hook
          (lambda ()
            ;; 如果当前是 ef-dark 主题，确保 ivy 颜色协调
            (when (eq (car custom-enabled-themes) 'ef-dark)
              (custom-set-faces
               `(ivy-current-match ((t (:background "#4a4f5c" :foreground "#ffffff" :weight bold)))) ; 当前匹配项
               `(ivy-minibuffer-match-face-1 ((t (:foreground "#8f9bb3")))) ; 匹配面1
               `(ivy-minibuffer-match-face-2 ((t (:foreground "#7b88a1")))) ; 匹配面2
               `(ivy-minibuffer-match-face-3 ((t (:foreground "#676f87")))) ; 匹配面3
               `(ivy-minibuffer-match-face-4 ((t (:foreground "#535a6d")))) ; 匹配面4
               ))))

(message "Ivy、Counsel、Swiper 美化配置加载完成！")

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
;;(use-package doom-themes
;;  :config
;;  (load-theme 'doom-peacock t))

(use-package ef-themes
  :ensure t ; 确保包已安装，若不存在则自动从 GNU ELPA 安装[1,6](@ref)
  :demand t ; 确保在Emacs启动时立即加载
  :init
  ;; 基本自定义设置（必须在加载主题前完成）[4](@ref)
  ;; 启用混合字体，使表格、代码块等使用等宽字体，保证对齐
  (setq ef-themes-mixed-fonts t)
  ;; 让UI元素（如模式栏）使用比例字体（如果喜欢的话）
  ;; (setq ef-themes-variable-pitch-ui t) ; 取消注释以启用

  ;; 自定义标题样式：1级标题使用细体可变宽字体并放大，2级标题加粗并稍放大，其余级别使用等宽字体[4](@ref)
  (setq ef-themes-headings
        '((1 . (variable-pitch light 1.9))
          (2 . (variable-pitch bold 1.6))
          (t . (monospace 1.2))))

  ;; 可以设置在两个主题间快速切换，例如在 ef-dark 和 ef-light 之间切换[4](@ref)
  ;; (setq ef-themes-to-toggle '(ef-dark ef-light))

  :config
  ;; 在加载主题前，禁用所有其他已启用的主题，防止样式冲突[4](@ref)
  (mapc #'disable-theme custom-enabled-themes)

  ;; 加载 ef-dark 主题[4](@ref)
  (load-theme 'ef-elea-dark :no-confirm) ; 使用 :no-confirm 避免确认提示

  ;; 或者，使用 ef-themes 提供的命令加载，它会自动运行一些后期处理钩子[4](@ref)
  ;; (ef-themes-select 'ef-dark)
)



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




;; error

;; 1. 定义缺失的变量，解决 lsp-disabled-clients 未定义的问题
(defvar lsp-disabled-clients nil "List of disabled LSP clients.")

;; 2. 完全禁用 LSP 警告（包括 emacs-lisp-mode 中的警告）
(setq lsp-warn-no-matched-clients nil)  ; 禁用"没有匹配的LSP客户端"警告
(setq lsp-log-io nil)                   ; 不记录LSP IO
(setq lsp-print-io nil)                 ; 不打印LSP IO
(setq warning-minimum-level :error)     ; 只显示错误级别以上的警告

;; 3. 针对 ef-themes 的警告，通过设置变量来避免
(setq ef-themes-mixed-fonts nil)       ; 明确设置这些变量
(setq ef-themes-headings nil)

;; 4. 禁止显示警告缓冲区
(setq warning-minimum-log-level :error) ; 日志中只记录错误
(setq display-warning-minimum-level :error) ; 只显示错误以上的警告
(setq byte-compile-warnings nil)        ; 禁止字节编译警告


;;; init-package.el ends here
(provide 'init-lsp-package)
