;; -*- lexical-binding: t; -*-

;; use-package is built-in. This is just for grouping options.
;; Also, statistics are only enabled from the next use-package
(use-package use-package
  :custom
  ;; (use-package-verbose 'debug)
  ;; (use-package-compute-statistics t)  ; Do use-package-report to profile init time
  (use-package-always-ensure t))

(use-package diminish) ; Do not show some common modes in the modeline, to save space

(use-package emacs
  :diminish which-key-mode
  :init
  (setq custom-file "~/.emacs.d/custom.el")
  (load custom-file)
  (set-face-attribute 'default nil
                      :font "Inconsolata"
		      :height 95
                      :weight 'normal)
  :custom
  (package-archives
      '(("melpa-stable" . "https://stable.melpa.org/packages/")
        ("melpa"        . "https://melpa.org/packages/")
	("gnu"          . "https://elpa.gnu.org/packages/")))
  (tab-bar-new-tab-choice "*scratch*")
  ;; Configure buffer name uniquification
  (uniquify-separator "/")               ;; The separator in buffer names.
  (uniquify-buffer-name-style 'forward) ;; names/in/this/style
  (scroll-step 1) ;; scroll just 1 line when hitting the bottom
  (make-backup-files nil) ; stop creating ~ files
  (revert-without-query '(".*")) ;; don't prompt on M-x revert-buffer
  (project-vc-include-untracked nil) ;; ignore untracked files for project.el commands
  (vc-follow-symlinks t) ;; when the file is symlink to version-controlled file, visit the linked file without prompting
  (warning-minimum-level :error) ; stop *Warnings* buffer immediately showing for every warning
  (compilation-skip-threshold 2)
  (display-time-default-load-average nil)
  ;; === Emacs minibuffer configurations ===
  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  :config
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (tab-bar-mode)
  (column-number-mode) ;; show column number
  (display-time-mode)
  (global-hl-line-mode)
  (which-key-mode) ;; Make it easier to discover key shortcuts
  (show-paren-mode) ;; show matching parenthesis
  (electric-pair-mode)
  (xterm-mouse-mode)
  (save-place-mode) ;; save cursor positions between sessions
  (savehist-mode) ;; save minibuffer history
  (desktop-save-mode) ;; save sessions and restore it automatically
  (ffap-bindings) ;; make find-file to try find-file-at-point first
  (windmove-default-keybindings) ;; switch windows with shift-arrows instead of "C-x o" all the time
  ;; faster async shell command
  (defun my-async-shell-command (command)
    "Execute COMMAND asynchronously in BUFFER with process-connection-type set to nil."
    (interactive
     (list (read-shell-command "Async shell command: ")))
    (let ((process-connection-type nil))
      (async-shell-command command)))
  :bind ("M-&" . my-async-shell-command)
  :mode
  ("Makefile" . makefile-mode)  ;; use makefile-mode for filenames containing "Makefile"
  (".gdb_breakpoints" . gdb-script-mode)
  :hook
  (prog-mode . (lambda()
		 (setq-local show-trailing-whitespace t))))

(use-package modus-themes
  :demand t
  :init
  (require 'modus-themes)
  :config
  (setq modus-themes-italic-constructs t
	modus-themes-bold-constructs t
	modus-themes-mixed-fonts t
	modus-themes-variable-pitch-ui t
	modus-themes-disable-other-themes t
	;; Options for `modus-themes-prompts' are either nil (the
	;; default), or a list of properties that may include any of those
	;; symbols: `italic', `WEIGHT'
	modus-themes-prompts '(italic bold)
	;; The `modus-themes-completions' is an alist that reads two
	;; keys: `matches', `selection'.  Each accepts a nil value (or
	;; empty list) or a list of properties that can include any of
	;; the following (for WEIGHT read further below):
	;;
	;; `matches'   :: `underline', `italic', `WEIGHT'
	;; `selection' :: `underline', `italic', `WEIGHT'
	modus-themes-completions
	'((matches . (extrabold))
          (selection . (semibold italic text-also)))
	modus-themes-headings
	'((1 . (variable-pitch 2.0))
	  (2 . (variable-pitch 1.7))
	  (3 . (variable-pitch 1.4))
	  (4 . (variable-pitch 1.1))))
  (modus-themes-load-theme 'modus-operandi))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

(use-package kind-icon
  :after corfu
  ;:custom
  ; (kind-icon-blend-background t)
  ; (kind-icon-default-face 'corfu-default) ; only needed with blend-background
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents . 100)
			  (projects . 5)))
  (setq dashboard-icon-type 'all-the-icons)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t))

(use-package recentf ;; built-in package
  :custom
  (recentf-max-saved-items 128)
  :config
  (add-to-list 'recentf-exclude "treemacs-persist")
  (add-to-list 'recentf-exclude "emacs.d/bookmarks"))

(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key)
  ("C-c C-d" . helpful-at-point))

(use-package xclip
  :config (xclip-mode))  ;; send killed text to system clipboard (need to install xclip)

(use-package undo-fu
  :config
  (global-set-key (kbd "C-/") 'undo-fu-only-undo)
  (global-set-key (kbd "M-/") 'undo-fu-only-redo))

(use-package undo-fu-session
  :hook (prog-mode . undo-fu-session-mode)) ;; Let's try using this only for prog mode

(use-package ediff ;; built-in package
  :defer t
  :custom
  (ediff-diff-options "-w")
  (ediff-split-window-function 'split-window-horizontally))

(use-package ace-window
  :config
  (global-set-key (kbd "M-o") 'ace-window))

(use-package ace-link
  :config
  (ace-link-setup-default))

(use-package vertico
  :init (vertico-mode)
  :config
  (vertico-indexed-mode)
  (keymap-set vertico-map "TAB" #'minibuffer-complete)
  ;; Clean shadowed path.
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(use-package marginalia
  :after vertico
  :init (marginalia-mode))

;; Example configuration for Consult
(use-package consult
  :demand t
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g f" . consult-flycheck)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-fd)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep-other-window)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any)
   consult-find consult-fd
   :state (consult--file-preview))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)

  ;; Make consult-multi-line to work on tab-local buffers instead of all buffers
  (setq consult-buffer-list-function 'consult--frame-buffer-list)

  ;; Add '--type file' to the default value to make consult-fd find files only by default
  (setq consult-fd-args
	'((if (executable-find "fdfind" 'remote) "fdfind" "fd")
	  "--full-path --color=never --type file"))

  ;; Previewing files in find-file. https://github.com/minad/consult/wiki#previewing-files-in-find-file
  ;; Code partially copied from read-file-name-default to mimic original find-file behavior
  (defun consult-find-file-with-preview (prompt &optional dir default-filename mustmatch initial pred)
    (interactive)
    (unless dir (setq dir (or default-directory "~/")))
    (unless (file-name-absolute-p dir) (setq dir (expand-file-name dir)))
    (unless default-filename
      (setq default-filename
            (cond
             ((null initial) buffer-file-name)
             ;; Special-case "" because (expand-file-name "" "/tmp/") returns
             ;; "/tmp" rather than "/tmp/" (bug#39057).
             ((equal "" initial) dir)
             (t (expand-file-name initial dir)))))
    ;; If dir starts with user's homedir, change that to ~.
    (setq dir (abbreviate-file-name dir))
    ;; Likewise for default-filename.
    (if default-filename
	(setq default-filename
	      (if (consp default-filename)
		  (mapcar 'abbreviate-file-name default-filename)
		(abbreviate-file-name default-filename))))
    (let ((insdef (cond
                   ((and insert-default-directory (stringp dir))
                    (if initial
			(cons (minibuffer-maybe-quote-filename (concat dir initial))
                              (length (minibuffer-maybe-quote-filename dir)))
                      (minibuffer-maybe-quote-filename dir)))
                   (initial (cons (minibuffer-maybe-quote-filename initial) 0))))
	  (minibuffer-completing-file-name t))
      (consult--read #'read-file-name-internal :state (consult--file-preview)
                     :prompt prompt
                     :initial insdef
                     :require-match mustmatch
                     :predicate pred
		     :default default-filename)))
  (setq read-file-name-function #'consult-find-file-with-preview)

  (defun consult-git-grep-other-window (&optional dir initial)
  "Variant of `consult-git-grep', switching to a buffer in another window."
  (interactive "P")
  (let ((consult--buffer-display #'switch-to-buffer-other-window))
    (consult-git-grep dir initial)))
  )

(use-package consult-dir
  :custom
  (consult-dir-shadow-filenames nil)
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

(use-package consult-lsp
  :after (consult lsp))

(use-package consult-yasnippet
  :after (consult yasnippet))

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings))  ;; alternative for `describe-bindings'
   ;; :map minibuffer-local-map
   ;; ("C-SPC" . embark-select))

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  ;; Add Embark to the mouse context menu. Also enable `context-menu-mode'.
  ;; (context-menu-mode 1)
  ;; (add-hook 'context-menu-functions #'embark-context-menu 100)

  :config
  ;; quit after action for embark-insert so that the candidate is inserted at the
  ;; original location rather than the preview location
  (setq embark-quit-after-action '((embark-insert . t) (t . nil)))

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Text completion
(use-package corfu
  ;; Optional customizations
  ;; :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match 'insert) ;; Configure handling of exact matches

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  :init

  ;; Recommended: Enable Corfu globally.  Recommended since many modes provide
  ;; Capfs and Dabbrev can be used globally (M-/).  See also the customization
  ;; variable `global-corfu-modes' to exclude certain modes.
  (global-corfu-mode)

  ;; Enable optional extension modes:
  (corfu-history-mode)
  (corfu-popupinfo-mode)
  (corfu-indexed-mode)
  :config
  ;; Enable auto completion, configure delay, trigger and quitting
  (setq corfu-auto t
	corfu-auto-delay 0.2
	corfu-auto-trigger "." ;; Custom trigger characters
	corfu-quit-no-match 'separator) ;; or t
  (keymap-unset corfu-map "RET")
  )

;; Add extensions
(use-package cape
  :custom
  (cape-dabbrev-buffer-function 'cape-text-buffers) ;; default was cape-same-mode-buffers
  ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
  ;; Press C-c p ? to for help.
  :bind ("C-c p" . cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
  ;; Alternatively bind Cape commands individually.
  ;; :bind (("C-c p d" . cape-dabbrev)
  ;;        ("C-c p h" . cape-history)
  ;;        ("C-c p f" . cape-file)
  ;;        ...)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  ;; (add-hook 'completion-at-point-functions #'cape-elisp-block)
  ;; (add-hook 'completion-at-point-functions #'cape-history)
  ;; ...
)

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))

;; Use Dabbrev with Corfu!
(use-package dabbrev
  ;; Swap M-/ and C-M-/
  ;; :bind (("M-/" . dabbrev-completion)
  ;;        ("C-M-/" . dabbrev-expand))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  (add-to-list 'dabbrev-ignored-buffer-modes 'authinfo-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

(use-package treemacs
  :defer t
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag))
  :config
  (progn (treemacs-resize-icons 16)))
(use-package treemacs-all-the-icons
  :after (treemacs all-the-icons))
(use-package treemacs-tab-bar
  :after (treemacs)
  :config (treemacs-set-scope-type 'Tabs))
(use-package treemacs-magit
  :after (treemacs magit))

(use-package vterm
  :defer t
  :custom
  (vterm-kill-buffer-on-exit nil)
  (vterm-max-scrollback 16000)
  ;; Added M-s to this list to enable M-s prefixed commands like consult-grep
  (vterm-keymap-exceptions
   '("C-c" "C-x" "C-u" "C-g" "C-h" "C-l" "M-x" "M-o" "C-y" "M-y" "M-s"))
  :hook
  ;; See info for font-lock-keywords
  (vterm-mode . (lambda ()
		  (font-lock-add-keywords nil
					  '(("\\(?:E\\(?:RROR\\|rror\\)\\|error\\)" 0 compilation-error-face t)
					    ("\\(?:W\\(?:ARNING\\|arning\\)\\|warning\\)" 0 font-lock-warning-face t))))))

;;; Dev env

;; An amazing git plugin
(use-package magit
  :defer t
  :custom
  (magit-diff-refine-hunk 'all)
  :init
  ;; Add "m" option to run magit in project-switch-project (C-x p p)
  ;; This is actually code in magit-extras, but copied here to avoid loading entire package.
  (with-eval-after-load 'project
    (define-key project-prefix-map "m" #'magit-project-status)
    (add-to-list 'project-switch-commands '(magit-project-status "Magit") t)))

;; highlight uncommitted changes in the gutter
(use-package diff-hl
  :after magit
  :config (global-diff-hl-mode))

;; Options for the builtin treesit.el
(use-package emacs
  :custom
  (treesit-font-lock-level 4)
  :config
  (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
  (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
  (add-to-list 'major-mode-remap-alist
               '(c-or-c++-mode . c-or-c++-ts-mode)))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; Language server protocol client
(use-package lsp-mode
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-file-watch-threshold 1000)
  ;; (lsp-clients-clangd-args '("--log=verbose"))
  (lsp-log-io nil) ;; this causes slow down
  (lsp-enable-on-type-formatting nil) ;; this somehow interferes with indentation (e.g., treesit-indent)
  (lsp-completion-provider :none) ;; we use Corfu!
  :init
  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless))
    ;; Optionally configure the cape-capf-buster.
    (setq-local completion-at-point-functions (list (cape-capf-buster #'lsp-completion-at-point))))
  :config
  (lsp-semantic-tokens-mode)
  (lsp-enable-which-key-integration t)
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\out\\'")
  :bind (("C-c e r" . lsp-find-references)
         ("C-c e R" . lsp-rename)
         ("C-c e i" . lsp-find-implementation)
         ("C-c e t" . lsp-find-type-definition))
  :hook
  ((c-mode-common . lsp-deferred)
   (c-ts-mode . lsp-deferred)
   (c++-ts-mode . lsp-deferred)
   (python-mode . lsp-deferred)
   (lsp-completion-mode . my/lsp-mode-setup-completion)))

(use-package lsp-ui
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-peek-peek-height 30)
  (lsp-ui-peek-list-width 65)
  (lsp-ui-doc-include-signature t)
  (lsp-ui-sideline-show-code-actions t)
  (lsp-ui-sideline-show-symbol nil)
  (lsp-imenu-sort-methods '(position))
  :bind (("C-c d" . lsp-ui-doc-show)
         ("C-c i" . lsp-ui-imenu)
	 ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
         ([remap xref-find-references] . lsp-ui-peek-find-references)))

(use-package lsp-treemacs
  :after (lsp treemacs))

(use-package yasnippet
  :config
  (yas-global-mode))

(use-package yasnippet-snippets)

(use-package flycheck
  :defer t
  :custom
  (flycheck-navigation-minimum-level 'error)
  :hook (after-init . global-flycheck-mode))

(use-package gud ;; built-in package
  :defer t
  :custom
  (gud-pdb-command-name "python3 -m pdb")
  :init
  (defun gdb-aarch64 ()
    (interactive)
    (gud-gdb "gdb-multiarch --fullname"))
  :hook (gud-mode . (lambda ()
		      ;; (setq-local company-idle-delay nil) ;; auto completion popup is annoying in GDB..
		      (setq-local comint-input-ring-file-name ".gdb_history")
		      (comint-read-input-ring))))

(use-package emacs
  :custom
  (setq sh-basic-offset 8))

(use-package c-ts-mode
  :custom
  (c-ts-mode-indent-offset 8)
  (c-ts-mode-indent-style 'linux))

(use-package markdown-mode
  :defer t
  :custom
  ;; (markdown-command "/home/shin/tools/Markdown_1.0.1/Markdown.pl")
  ;; (markdown-command "grip")
  ;; (markdown-command-needs-filename t)
  (markdown-header-scaling t)
  (markdown-fontify-code-blocks-natively t)
  (markdown-fontify-whole-heading-line t)
  (markdown-enable-highlighting-syntax t)
  :hook
  (markdown-mode . (lambda ()
		     (modify-syntax-entry ?_ "w") ;; regard underscore as part of the word
		     (setq-local indent-tabs-mode nil) ;; don't include tabs in indent
		     (outline-minor-mode))))
(use-package cmake-mode
  :defer t)
(use-package dockerfile-mode
  :defer t)

;;; Custom elisp functions
(defun my-highlight-region (beg end)
  "Highlight the region using an overlay."
  (interactive "r")
  (let ((hl-face '(:background "gold"))) ; Define your desired face
    ;; Create an overlay for the region
    (overlay-put (make-overlay beg end) 'face hl-face)))

(defun align-numbers (BEG END)
  "Align numbers in region BEG END."
  (interactive "r")
  (align-regexp BEG END "\\s-\\([0-9]+\\)\\s-" -1 0 t))

(defun count-visible-lines-in-buffer ()
  "Count all visible lines in the current buffer (excluding hidden lines)."
  (interactive)
  (let* ((visible-lines (count-lines (point-min) (point-max) t))
         (total-lines (count-lines (point-min) (point-max))))
    (message "Visible lines: %d / Total lines: %d" visible-lines total-lines)))

;; Local Variables:
;; flycheck-disabled-checkers: (emacs-lisp-checkdoc)
;; byte-compile-warnings: (not free-vars noruntime)
;; End:
