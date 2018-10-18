;--------------------------------------------------------------------------------------
;  common setting
;----------------------------------------------------------------------------------

;;(load-theme 'manoj-dark t)

;; load-path に "~/.emacs.d/elisp" を追加
(setq load-path (cons "~/.emacs.d/elisp" load-path))

;display setting
;(setq frame-title-format &quot;%f&quot;)   ; タイトルバーにフルパス表示
(global-linum-mode t)     ; 行番号を常に表示する
(setq-default tab-width 4); TABの表示幅を4に設定
(setq-default indent-tabs-mode nil); インデントにタブ文字を使用しない
(column-number-mode t)    ; カラム番号を表示
(size-indication-mode t)  ; ファイルサイズを表示


;;ハイライト関係

;; https://emacs.stackexchange.com/questions/9740/how-to-define-a-good-highlight-face
(require 'color)
(defun set-hl-line-color-based-on-theme ()
    "Sets the hl-line face to have no foregorund and a background
    that is 10% darker than the default face's background."
    (set-face-attribute 'hl-line nil
                        :foreground nil
                        :background (color-darken-name (face-background 'default) 10)))
;(add-hook 'global-hl-line-mode-hook 'set-hl-line-color-based-on-theme)

(global-hl-line-mode t)       ;; 現在行をハイライト
(set-face-attribute 'default nil :background "gray10")
(set-face-attribute 'hl-line nil :foreground nil :background "gray5")


(setq transient-mark-mode t)  ;; リージョンをハイライト


;;--------------------

;; 2003.12.30
(define-key global-map "\C-h" 'delete-backward-char)
(define-key global-map "\M-?" 'help)

;; 2004.2.14
;; 奥村晴彦 http://oku.edu.mie-u.ac.jp/~okumura/c/style.html
(require 'cc-mode)
;; BackSpace キーを「賢く」し，インデント幅は4桁，タブはスペースに展開
(add-hook 'c-mode-common-hook
	  '(lambda ()
             (progn
               (c-toggle-hungry-state 1)
               (setq c-basic-offset 4 indent-tabs-mode nil)
               (which-function-mode 1))))


;; 2005.8.13
;; MacEmacsFaq (http://macemacsjp.sourceforge.jp/index.php?MacEmacsFaq)
;; 全角空白、タブ、末尾の無駄な空白の色付けをする
(defface my-mark-tabs 
  '(
    (t
;     (:foreground "red" :underline t)
     (:foreground "gray20" :underline t)
     )) nil)
(defface my-mark-whitespace
  '(
    (t
     (:background "gray")
     )) nil)
(defface my-mark-lineendspaces
  '(
    (t
     (:foreground "SteelBlue" :underline t)
     )) nil)
(defvar my-mark-tabs 'my-mark-tabs)
(defvar my-mark-whitespace 'my-mark-whitespace)
(defvar my-mark-lineendspaces 'my-mark-lineendspaces)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(
     ("\t" 0 my-mark-tabs append)
     ("　" 0 my-mark-whitespace append)
     ("[ \t]+$" 0 my-mark-lineendspaces append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)

;; 対応するカッコをハイライト
(show-paren-mode 1)
(setq show-paren-delay 0)
(setq show-paren-style 'parenthesis)
(set-face-attribute 'show-paren-match nil
                    :background "#00dd00" :foreground nil
                    :underline nil :weight 'extra-bold)


;; Command (Apple) キーを Meta キーとして利用
;;(setq mac-command-key-is-meta t)

;; フレームを縦分割したときも行の折り返しをする
(setq truncate-partial-width-windows nil)


;;>>>>>>
;; icomplete-modeで入力を完了するためのコマンドをまとめる
;; https://qiita.com/0x60df/items/e12544d2699eedbf36e1

(icomplete-mode 1)

;; ミニバッファで補完を行いたくないコマンドのリスト
(defvar icomplete-exceptional-command-list
  '(dired-create-directory
    dired-do-copy
    dired-do-rename))

;; 起動時のカーソル位置を保持するための変数
(defvar icomplete-initial-point-max nil)
;; 起動時の補完候補リストを保持するための変数
(defvar icomplete-initial-completions nil)
;; 起動時に呼び出し元のコマンド名を保持するための変数
(defvar icomplete-this-command nil)

;; 起動時に上記の変数に値を代入するフックをかける
(add-hook 'icomplete-minibuffer-setup-hook
          (lambda ()
            (setq icomplete-initial-point-max (point-max))
            (setq icomplete-initial-completions
                  (completion-all-sorted-completions
                   (icomplete--field-beg) (icomplete--field-end)))
            (setq icomplete-this-command this-command)))

;; 入力完了のコマンド定義
(defun minibuffer-force-complete-and-exit-dwim ()
  "Complete the minibuffer with first of the matches and exit."
  (interactive)
  (cond ((member icomplete-this-command icomplete-exceptional-command-list)
         (exit-minibuffer))
        ((and (eq (point-max) icomplete-initial-point-max)
              (equal (car (completion-all-sorted-completions
                           (icomplete--field-beg) (icomplete--field-end)))
                     (car icomplete-initial-completions))
              minibuffer-default)
         ;; Use the provided default if there's one (bug#17545).
         (minibuffer-complete-and-exit))
        (t (minibuffer-force-complete)
           (completion--complete-and-exit
            (minibuffer-prompt-end) (point-max) #'exit-minibuffer
            ;; If the previous completion completed to an element which fails
            ;; test-completion, then we shouldn't exit, but that should be rare.
            (lambda () (minibuffer-message "Incomplete"))))))

;; 入力完了をリターンキーにバインド
(define-key icomplete-minibuffer-map [return]
  'minibuffer-force-complete-and-exit-dwim)
;;<<<<<<<<


;; ソースコードに色を付ける
(global-font-lock-mode t)
(if (>= emacs-major-version 21)
  (setq font-lock-support-mode 'jit-lock-mode)    ; Just-In-Timeな文字装飾方式
  (setq font-lock-support-mode 'lazy-lock-mode))  ; Emacs20以前では古い方式


;; protobuf-mode
(require 'protobuf-mode)
(setq auto-mode-alist (append '(("\\.proto$" . protobuf-mode)) auto-mode-alist))


;; 181017 分割したウィンドウの大きさを変更する
;; https://qiita.com/icb54615/items/b04be54caf46d2bf721a
(defun window-resizer ()
  "Control window size and position."
  (interactive)
  (let ((window-obj (selected-window))
        (current-width (window-width))
        (current-height (window-height))
        (dx (if (= (nth 0 (window-edges)) 0) 1
              -1))
        (dy (if (= (nth 1 (window-edges)) 0) 1
              -1))
        action c)
    (catch 'end-flag
      (while t
        (setq action
              (read-key-sequence-vector (format "size[%dx%d]"
                                                (window-width)
                                                (window-height))))
        (setq c (aref action 0))
        (cond ((= c ?l)
               (enlarge-window-horizontally dx))
              ((= c ?h)
               (shrink-window-horizontally dx))
              ((= c ?j)
               (enlarge-window dy))
              ((= c ?k)
               (shrink-window dy))
              ;; otherwise
              (t
               (let ((last-command-char (aref action 0))
                     (command (key-binding action)))
                 (when command
                   (call-interactively command)))
               (message "Quit")
               (throw 'end-flag t)))))))
(global-set-key "\C-c\C-r" 'window-resizer)


;; 181018 multi-term: Managing multiple terminal buffers in Emacs
;; https://www.emacswiki.org/emacs/MultiTerm
;; http://sakito.jp/emacs/emacsshell.html
(require 'multi-term)
(setq multi-term-program shell-file-name)

(global-set-key (kbd "C-c t") '(lambda ()
                                 (interactive)
                                 (multi-term)))

;; 181018 fill-column-indicator.el --- Graphically indicate the fill column
;; https://www.emacswiki.org/emacs/FillColumnIndicator
(require 'fill-column-indicator)
(setq-default fci-rule-column 80)
(setq fci-rule-width 1)
(setq fci-rule-color "darkblue")
