;; -*- no-byte-compile: t; -*-
;;; lang/typst/packages.el

(package! typst-ts-mode
  :recipe (:host codeberg
           :repo "meow_king/typst-ts-mode"))

(package! typst-preview
  :recipe (:host github
           :repo "havarddj/typst-preview.el"))
