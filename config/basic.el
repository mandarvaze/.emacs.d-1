;;;;
;; Basic
;;;;


(defmacro enable-eldoc-mode ()
  "After Emacs 24.4 `turn-on-eldoc-mode is obsoleted, use `eldoc-mode indeed.
  `eldoc-mode shows documentation in the minibuffer when writing code.
  http://www.emacswiki.org/emacs/ElDoc"
  `(version-supported-if < 24.0
                         (eldoc-mode)
                         (turn-on-eldoc-mode)))


(defmacro linum-mode-supported-p ()
  "Check Emacs version supports linum mode. "
  `(version-supported-p <= 23.1 t))

(defmacro toggle-linum-mode (option)
  "Toggle linum-mode based on option."
  `(when (linum-mode-supported-p) (linum-mode ,option)))

(defmacro enable-global-linum-mode ()
  "Eanble global linum mode."
  `(when (linum-mode-supported-p) (global-linum-mode)))


;; Default web browser: eww `C-d C-d h'
(when (eq browse-url-browser-function
          'browse-url-default-browser)
  (safe-do eww-browse-url
           (setq browse-url-browser-function 'eww-browse-url)
           (add-hook 'eww-mode-hook
                     (lambda () (toggle-linum-mode -1)))))


(defmacro add-lisp-mode-hook (hook &rest body)
  "Enable basic modes for lisp editing, 
  (reset-emacs) after packages had been installed."
  (declare (indent 1) (debug t))
  `(add-hook ,hook
             (lambda ()
               (package-supported-p
                (safe-call enable-paredit-mode)
                (safe-call aggressive-indent-mode)
                (safe-call rainbow-delimiters-mode))
               ,@body)))

;; *scratch* 
(add-lisp-mode-hook 'emacs-lisp-mode-hook
  (progn
    (enable-eldoc-mode)
    (local-set-key (kbd "TAB") #'complete-symbol)
    (cond ((string= "*scratch*" (buffer-name))
           (local-set-key (kbd "RET")
                          (lambda () (interactive)
                            (eval-print-last-sexp)
                            (newline)))))))



;; Disable linum mode
(add-hook 'Man-mode-hook (lambda () (toggle-linum-mode -1)))
(add-hook 'help-mode-hook (lambda () (toggle-linum-mode -1)))
(add-hook 'completion-list-mode-hook (lambda () (toggle-linum-mode -1)))
(add-hook 'Info-mode-hook (lambda () (toggle-linum-mode -1)))
(add-hook 'ibuffer-mode-hook (lambda () (toggle-linum-mode -1)))


(defmacro safe-setq-inferior-lisp-program (lisp &optional force)
  "Safe set inferior-lisp-program var, it must be set before slime start."
  `(if (boundp 'inferior-lisp-program)
       (if ,force
           (setq inferior-lisp-program ,lisp)
         (when (or (not (string= ,lisp inferior-lisp-program))
                   (string= "lisp" inferior-lisp-program))
           (setq inferior-lisp-program ,lisp)))
     (setq-default inferior-lisp-program ,lisp)))


