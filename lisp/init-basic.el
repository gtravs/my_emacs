;;; init-basic.el

;;; Commentary:
;; 这个文件为基本配置
;;; Code:
;; 基础设置
;; 开启 Repeat Mode，减少连续按键的修饰键 (比如 C-x ^ ^ ^)
(repeat-mode 1)
(setq confirm-kill-emacs #'yes-or-no-p)   ; 在关闭 Emacs 前询问是否确认关闭，防止误触
(electric-pair-mode t)            ; 自动补全括号
(add-hook 'prog-mode-hook #'show-paren-mode) ; 编程模式下，光标在括号上时高亮另一个括号
(column-number-mode t)            ; 在 Mode line 上显示列号
(global-auto-revert-mode t)         ; 当另一程序修改了文件时，让 Emacs 及时刷新 Buffer
(delete-selection-mode t)          ; 选中文本后输入文本会替换文本（更符合我们习惯了的其它编辑器的逻辑）
(setq inhibit-startup-message t)       ; 关闭启动 Emacs 时的欢迎界面
(setq make-backup-files nil)         ; 关闭文件自动备份
(add-hook 'prog-mode-hook #'hs-minor-mode)  ; 编程模式下，可以折叠代码块
(global-display-line-numbers-mode 1)     ; 在 Window 显示行号
(tool-bar-mode -1)              ; （熟练后可选）关闭 Tool bar
(when (display-graphic-p) (toggle-scroll-bar -1)) ; 图形界面时关闭滚动条

(setq display-line-numbers-type 'relative)  ; （可选）显示相对行号
(add-to-list 'default-frame-alist '(width . 90)) ; （可选）设定启动图形界面时的初始 Frame 宽度（字符数）
(add-to-list 'default-frame-alist '(height . 55)) ; （可选）设定启动图形界面时的初始 Frame 高度（字符数）
(setq dired-auto-revert-buffer t)
;; 字体
(set-frame-font "Hack Nerd Font-14" nil t)


;; 启用 ANSI 颜色显示
(require 'ansi-color)
(defun my-shell-mode-hook ()
  (setq-local ansi-color-faces-vector
              [default bold italic underline bold italic underline bold])
  (add-hook 'comint-output-filter-hook 'ansi-color-process-region))
(add-hook 'shell-mode-hook 'my-shell-mode-hook)


;; HTTP/HTTPS 代理
(setq url-proxy-services
      '(("no_proxy" . "^\\(localhost\\|127\\.0\\.0\\.1\\|10\\..*\\|192\\.168\\..*\\)")
        ("http" . "127.0.0.1:7897")
        ("https" . "127.0.0.1:7897")))

;; 为 package.el 设置
(setq package-archive-proxy
      '(("gnu" . "direct")
        ("melpa" . "direct")
        ("org" . "direct")))

;; 可选：为 git 命令设置代理（用于 straight.el 等）
(setenv "http_proxy" "http://127.0.0.1:7897")
(setenv "https_proxy" "http://127.0.0.1:7897")
(setenv "all_proxy" "socks5://127.0.0.1:7897")  ; Clash 的 SOCKS5 代理端口


;; 快速缩放窗口
(global-set-key (kbd "C-c <") 'shrink-window-horizontally)   ; 缩小宽度
(global-set-key (kbd "C-c >") 'enlarge-window-horizontally)   ; 增大宽度
(global-set-key (kbd "C-c ^") 'enlarge-window)                ; 增大高度
(global-set-key (kbd "C-c v") 'shrink-window)                 ; 缩小高度


(defun my-ultimate-kill-buffer-and-window ()
  "智能关闭当前缓冲区和窗口：
- 若是 Treemacs 缓冲区：彻底清除所有状态（内存 + 文件），下次打开可重新选目录；
- 若关联后台进程，先杀死；
- 若缓冲区已修改且可写，询问是否保存（y/n/c）；
- 否则直接关闭；
- 最后关闭当前窗口（如果不是唯一窗口）。"
  (interactive)

  ;; ✅ 关键修复：Treemacs 缓冲区 → 清除内存状态 + 删除文件
  (when (and (boundp 'treemacs--buffer)
             (buffer-live-p treemacs--buffer)
             (eq (current-buffer) treemacs--buffer))
    ;; 1. 清除所有 Treemacs 内存状态变量
    (setq treemacs--last-project nil
          treemacs--project nil
          treemacs--root nil
          treemacs--current-project nil)
    
    ;; 2. 删除持久化状态文件
    (let ((persist-file (or (bound-and-true-p treemacs-persist-file)
                            (expand-file-name "treemacs" user-emacs-directory))))
      (when (file-exists-p persist-file)
        (ignore-errors (delete-file persist-file))
        (message "✅ Treemacs 状态已彻底清除（内存 + 文件）")
        (sit-for 1))
      (message "ℹ️ Treemacs 无状态文件，已直接关闭")
      (sit-for 0.5))
    
    ;; 3. 关闭 Treemacs 缓冲区和窗口
    (kill-buffer treemacs--buffer)
    (unless (one-window-p)
      (delete-window))
    
    (cl-return-from my-ultimate-kill-buffer-and-window))

  ;; === 普通缓冲区逻辑 ===
  (let* ((current-buf (current-buffer))
         (process (get-buffer-process current-buf))
         (file-name (buffer-file-name current-buf))
         (buffer-name (buffer-name current-buf))
         (can-write (and file-name
                         (file-writable-p file-name)
                         (not buffer-read-only))))

    ;; 杀死进程
    (when (and process (process-live-p process))
      (message "正在停止关联的进程: %s" (process-name process))
      (kill-process process))

    ;; 询问保存
    (cond
     ((and (buffer-modified-p) can-write)
      (let ((response (read-char-choice
                       (format "缓冲区 ‘%s’ 已修改。是否保存？(y/n/c) " buffer-name)
                       '(?y ?n ?c))))
        (pcase response
          (?y (save-buffer))
          (?n (set-buffer-modified-p nil))
          (?c (message "操作已取消")
              (cl-return-from my-ultimate-kill-buffer-and-window nil)))))
     (t (set-buffer-modified-p nil)))

    ;; 关闭缓冲区
    (kill-buffer current-buf)

    ;; 关闭窗口
    (unless (one-window-p)
      (delete-window))))

;; 绑定快捷键（使用安全的 C-c q 避免冲突）
(global-set-key (kbd "C-q") 'my-ultimate-kill-buffer-and-window)


;;; M-! 异步 shell 

(defun my/shell-command-async-output (command)
  "执行 Shell 命令，强制输出到缓冲区，支持补全，并优先上下分屏显示。
  此版本使用异步执行，适用于服务器等长时间运行的进程。"
  (interactive
   (list
    (read-shell-command "Shell command: ")))
  
  (let* ((buffer-name (format "*Shell Command: %s*" command)) ; 使用动态 Buffer 名称
         (output-buffer (get-buffer-create buffer-name)))
    
    ;; 1. 启动前设置
    (with-current-buffer output-buffer
      (setq buffer-read-only nil) ; 确保缓冲区可写
      (erase-buffer))
    
    ;; 2. 启动异步进程
    ;; start-process-shell-command: 启动非阻塞 Shell 进程，解决卡死问题
    (start-process-shell-command buffer-name output-buffer command)
    
    ;; 3. 显示缓冲区（强制上下分屏）
    (let ((split-width-threshold nil) ; 禁止自动左右分屏
          (split-height-threshold 0)) ; 只要有高度，就允许上下分屏
      (pop-to-buffer output-buffer))
    
    ;; 4. 通知用户，并切换到该缓冲区
    (message "Started async process: %s" command)
    (select-window (get-buffer-window output-buffer))))

(global-set-key (kbd "M-!") 'my/shell-command-async-output)


;;; eshell setting 
(defvar my-eshell-toggle-buffer nil "记录当前的 eshell buffer。")
(defvar my-eshell-previous-window-config nil "记录切换前窗口配置。")

(defun my-eshell-toggle ()
  "切换显示或隐藏 eshell 缓冲区，并确保光标定位到 Eshell。"
  (interactive)
  (let ((buf (or my-eshell-toggle-buffer (get-buffer "*eshell*"))))
    (if (and buf (get-buffer-window buf 'visible))
        ;; 如果 eshell 缓冲区在当前某个窗口可见，则隐藏它
        (progn
          (setq my-eshell-previous-window-config (current-window-configuration))
          (delete-window (get-buffer-window buf))
          (message "Eshell hidden."))
      ;; 如果 eshell 缓冲区不可见（或不存在），则显示它
      (unless (and buf (buffer-live-p buf))
        ;; 如果缓冲区不存在，则创建新的 eshell 缓冲区
        (setq buf (generate-new-buffer "*eshell*"))
        (with-current-buffer buf
          (eshell-mode))
        (setq my-eshell-toggle-buffer buf))
      
      ;; 显示缓冲区并确保光标定位到 Eshell
      (let ((eshell-window (display-buffer-below-selected buf nil)))
        (select-window eshell-window)  ; 关键修改：切换窗口焦点
        (when (eq (window-buffer eshell-window) buf)
          (with-current-buffer buf
            (goto-char (point-max)))))  ; 光标移动到缓冲区末尾
      (message "Eshell shown."))))

;; 将函数绑定到 C-`
(global-set-key (kbd "C-`") 'my-eshell-toggle)


;;; init-basic.el end
(provide 'init-basic)
