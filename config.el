(setq insert-directory-program "gls")


(use-package! typst-ts-mode
  :when (treesit-available-p)
  :mode "\\.typ\\'"
  :config
  ;; Point to the tree-sitter grammar
  (setopt typst-ts-grammar-location
          (expand-file-name "tree-sitter/libtree-sitter-typst.so" user-emacs-directory))

(after! typst-preview
  (advice-add 'typst-preview--connect-browser :around
              (lambda (orig browser hostname)
                (if (string= browser "xwidget")
                    (let ((url (concat "http://" hostname)))
                      (split-window-right)
                      (other-window 1)
                      (xwidget-webkit-browse-url url))
                  (funcall orig browser hostname)))))

  ;; Max syntax highlighting
  (setopt typst-ts-fontification-precision-level 'max)
  (setopt typst-ts-enable-raw-blocks-highlight t)
  (setopt typst-ts-indent-offset 2)

  ;; eglot + tinymist
  (set-eglot-client! 'typst-ts-mode '("tinymist"))
  (add-hook 'typst-ts-mode-local-vars-hook #'lsp! 'append)

  ;; dtrt-indent and editorconfig integration
  (after! dtrt-indent
    (add-to-list 'dtrt-indent-hook-mapping-list
                 '(typst-ts-mode default typst-ts-indent-offset)))
  (after! editorconfig
    (add-to-list 'editorconfig-indentation-alist
                 '(typst-ts-mode typst-ts-indent-offset)))

  ;; Disable smartparens pairs that conflict with Typst syntax
  (after! smartparens
    (sp-with-modes 'typst-ts-mode
      (sp-local-pair "+" "+" :actions '() :when nil)
      (sp-local-pair "|" "|" :actions '() :when nil)
      (sp-local-pair "=" "=" :actions '() :when nil)
      (sp-local-pair "/" "/" :actions '() :when nil)
      (sp-local-pair "~" "~" :actions '() :when nil)
      (sp-local-pair "*" "*"
                     :actions '(:add insert wrap autoskip navigate) :when nil
                     :unless (list #'+typst-sp--in-math-p
                                   #'sp-point-after-word-p
                                   #'sp-point-before-word-p))
      (sp-local-pair "_" "_"
                     :actions '(:add insert wrap autoskip navigate) :when nil
                     :unless (list #'+typst-sp--in-math-p
                                   #'sp-point-after-word-p
                                   #'sp-point-before-word-p))
      (sp-local-pair "`" "`"
                     :actions '(:add insert wrap autoskip navigate) :when nil
                     :unless (list #'+typst-sp--in-math-p))
      (sp-local-pair "$" "$"
                     :actions '(:add insert wrap autoskip navigate) :when nil))

    (defun +typst-sp--in-math-p (_id _action _context)
      (cl-block nil
        (when (derived-mode-p 'typst-ts-mode)
          (let ((node (treesit-node-at (point))))
            (while node
              (when (member (treesit-node-type node) '("math" "formula"))
                (cl-return t))
              (setq node (treesit-node-parent node)))
            nil))))))

(use-package! typst-preview
  :after typst-ts-mode
  :config
  (setopt typst-preview-browser "xwidget")
  (setopt typst-preview-open-browser-automatically t)
  (setopt typst-preview-invert-colors "never")
  (setopt typst-preview-partial-rendering t)
  (add-hook 'typst-ts-mode-hook
            (lambda () (run-with-idle-timer 1 nil #'typst-preview-mode)))
  (map! :map typst-ts-mode-map
        :localleader
        (:prefix ("p" . "preview")
                 "p" #'typst-preview-mode
                 "s" #'typst-preview-send-position
                 "l" #'typst-preview-list-active-files
                 "c" #'typst-preview-clear-active-files)))
