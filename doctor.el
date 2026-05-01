;;; lang/typst/doctor.el -*- lexical-binding: t; -*-

(assert! (modulep! :tools tree-sitter)
         "This module requires (:tools tree-sitter)")

(assert! (modulep! :tools lsp)
         "This module requires (:tools lsp)")

(unless (executable-find "typst")
  (warn! "Couldn't find the typst binary."))

(unless (executable-find "tinymist")
  (warn! "Couldn't find tinymist. Live preview will not work."))

(unless (executable-find "typstyle")
  (warn! "Couldn't find typstyle. Code formatting will not work."))