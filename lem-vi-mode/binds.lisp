(defpackage :lem-vi-mode.binds
  (:use :cl
        :lem
        :lem.universal-argument
        :lem-vi-mode.core
        :lem-vi-mode.commands
        :lem-vi-mode.ex
        :lem-vi-mode.visual))
(in-package :lem-vi-mode.binds)

(define-key *command-keymap* "0" 'vi-move-to-beginning-of-line/universal-argument-0)
(define-key *command-keymap* "1" 'universal-argument-1)
(define-key *command-keymap* "2" 'universal-argument-2)
(define-key *command-keymap* "3" 'universal-argument-3)
(define-key *command-keymap* "4" 'universal-argument-4)
(define-key *command-keymap* "5" 'universal-argument-5)
(define-key *command-keymap* "6" 'universal-argument-6)
(define-key *command-keymap* "7" 'universal-argument-7)
(define-key *command-keymap* "8" 'universal-argument-8)
(define-key *command-keymap* "9" 'universal-argument-9)
(define-key *command-keymap* "l" 'vi-forward-char)
(define-key *command-keymap* "h" 'vi-backward-char)
(define-key *command-keymap* "j" 'vi-next-line)
(define-key *command-keymap* "k" 'vi-previous-line)
(define-key *command-keymap* "g j" 'vi-next-display-line)
(define-key *command-keymap* "g k" 'vi-previous-display-line)
(define-key *command-keymap* "w" 'vi-forward-word-begin)
(define-key *command-keymap* "b" 'vi-backward-word-begin)
(define-key *command-keymap* "W" 'vi-forward-word-begin-broad)
(define-key *command-keymap* "B" 'vi-backward-word-begin-broad)
(define-key *command-keymap* "e" 'vi-forward-word-end)
(define-key *command-keymap* "E" 'vi-forward-word-end-broad)
(define-key *command-keymap* "$" 'vi-move-to-end-of-line)
(define-key *command-keymap* "g _" 'vi-move-to-last-nonblank)
(define-key *command-keymap* "H" 'vi-move-to-window-top)
(define-key *command-keymap* "M" 'vi-move-to-window-middle)
(define-key *command-keymap* "L" 'vi-move-to-window-bottom)
(define-key *command-keymap* "^" 'vi-back-to-indentation)
(define-key *command-keymap* "=" 'vi-indent)
(define-key *command-keymap* "{" 'backward-paragraph)
(define-key *command-keymap* "}" 'forward-paragraph)
(define-key *command-keymap* "s" 'vi-substitute)
(define-key *command-keymap* "x" 'vi-delete-next-char)
(define-key *command-keymap* "X" 'vi-delete-previous-char)
(define-key *command-keymap* "d" 'vi-delete)
(define-key *command-keymap* "D" 'vi-delete-line)
(define-key *command-keymap* "c" 'vi-clear)
(define-key *command-keymap* "C" 'vi-clear-line)
(define-key *command-keymap* "g J" 'vi-join)
(define-key *command-keymap* "J" 'vi-join-line)
(define-key *command-keymap* "y" 'vi-yank)
(define-key *command-keymap* "p" 'vi-paste-after)
(define-key *command-keymap* "P" 'vi-paste-before)
(define-key *command-keymap* "r" 'vi-replace-char)
(define-key *command-keymap* "u" 'vi-undo)
(define-key *command-keymap* "C-r" 'vi-redo)
(define-key *command-keymap* "C-f" 'next-page)
(define-key *command-keymap* "C-b" 'previous-page)
(define-key *command-keymap* "%" 'vi-move-to-matching-paren)
(define-key *command-keymap* "/" 'vi-search-forward)
(define-key *command-keymap* "?" 'vi-search-backward)
(define-key *command-keymap* "n" 'vi-search-next)
(define-key *command-keymap* "N" 'vi-search-previous)
(define-key *command-keymap* "g g" 'vi-goto-first-line)
(define-key *command-keymap* "G" 'vi-goto-line)
(define-key *command-keymap* "f" 'vi-find-char)
(define-key *command-keymap* "F" 'vi-find-char-backward)
(define-key *command-keymap* "t" 'vi-find-char-before)
(define-key *command-keymap* "T" 'vi-find-char-backward-after)
(define-key *command-keymap* "z z" 'recenter)
(define-key *command-keymap* "Z Z" 'vi-write-quit)
(define-key *command-keymap* "C-w s" 'split-active-window-vertically)
(define-key *command-keymap* "C-w C-s" 'split-active-window-vertically)
(define-key *command-keymap* "C-w w" 'other-window)
(define-key *command-keymap* "C-w C-w" 'other-window)
(define-key *command-keymap* "C-w q" 'vi-quit)
(define-key *command-keymap* "C-w h" 'window-move-left)
(define-key *command-keymap* "C-w C-h" 'undefined-key)
(define-key *command-keymap* "C-w l" 'window-move-right)
(define-key *command-keymap* "C-w C-l" 'undefined-key)
(define-key *command-keymap* "C-w k" 'window-move-up)
(define-key *command-keymap* "C-w C-k" 'undefined-key)
(define-key *command-keymap* "C-w j" 'window-move-down)
(define-key *command-keymap* "C-w C-j" 'undefined-key)

(define-key *command-keymap* "v" 'vi-visual-char)
(define-key *command-keymap* "V" 'vi-visual-line)
(define-key *command-keymap* "C-v" 'vi-visual-block)

(define-key *command-keymap* "i" 'vi-insert)
(define-key *command-keymap* "I" 'vi-insert-line)
(define-key *command-keymap* "a" 'vi-append)
(define-key *command-keymap* "A" 'vi-append-line)
(define-key *command-keymap* "o" 'vi-open-below)
(define-key *command-keymap* "O" 'vi-open-adove)
(define-key *command-keymap* "C-o" 'vi-jump-back)
(define-key *command-keymap* "C-i" 'vi-jump-next)
(define-key *command-keymap* ":" 'vi-ex)
(define-key *command-keymap* 'delete-previous-char 'vi-backward-char)
(define-key *command-keymap* 'self-insert 'undefined-key)

(define-key *insert-keymap* "Escape" 'vi-end-insert)
(define-key *insert-keymap* "C-w" 'vi-kill-last-word)

(define-key *command-keymap* "C-p" 'yank-pop)
(define-key *command-keymap* "C-n" 'yank-pop-next)

(define-key *command-keymap* "C-g" 'vi-keyboard-quit)
(define-key *inactive-keymap* "Escape" 'vi-keyboard-quit)
