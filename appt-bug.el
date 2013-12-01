;; appt-bug.el ---

;; Copyright (C) 2013 Philippe Coatmeur
;; URL: https://github.com/xaccrocheur/appt-bug/

;; Author: Philippe CM http://stackoverflow.com/users/539797/philippe-cm
;; Keywords: mail
;; Version 0.6b

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

(require 'appt)
(setq org-agenda-include-diary t)
(setq appt-time-msg-list nil)
(org-agenda-to-appt)

(defun testouille ()
  (interactive)
  (message "plopouz"))

(defadvice org-agenda-redo (after org-agenda-redo-add-appts)
  "Pressing `r' on the agenda will also add appointments."
  (progn
    (message "I'm useless")
    (setq appt-time-msg-list nil)
    (org-agenda-to-appt)))

(ad-activate 'org-agenda-redo)

;; The defun to defadvice is org-capture-finalize

;; (call-interactively 'appt-check)

(progn
  (appt-activate 1)
  (setq appt-display-format 'window)
  (setq appt-disp-window-function (function abug-display)))

(defun abug-display (min-to-app new-time msg)
  (abug-notify (format "Appointment in %s minute(s)" min-to-app) msg
               "/usr/share/icons/gnome/32x32/status/appointment-soon.png"
               "/usr/share/sounds/speech-dispatcher/test.wav")
  (abug-notify-modeline min-to-app new-time msg))
(setq appt-disp-window-function (function abug-display))

(defun abug-notify (title msg &optional icon sound)
  "Show a popup if we're on X, or echo it otherwise; TITLE is the title
of the message, MSG is the context. Optionally, you can provide an ICON and
a sound to be played"
  (interactive)
  (when sound (play-sound-file sound))
  (if (eq window-system 'x)
      (shell-command
       (concat "notify-send "
               (if icon (concat "-i " icon) "")
               " '" title "' '" msg "'"))
    (message (concat title ": " msg))))

;; (abug-notify "Warning" "The end is near" "/usr/share/icons/gnome/32x32/status/appointment-soon.png" "/usr/share/sounds/speech-dispatcher/test.wav")

;; Modeline Notification
(defcustom mail-bug-icon
  (when (image-type-available-p 'xpm)
    '(image :type xpm
            :file "~/.emacs.d/lisp/mail-bug/ladybug.xpm"
            :ascent center))
  "Icon for the first account.
Must be an XPM (use Gimp)."
  :group 'mail-bug-interface)

(defconst mail-bug-logo
  (if (and window-system
           mail-bug-icon)
      (apply 'propertize " " `(display ,mail-bug-icon))
    "appt"))

(defun abug-mode-line (min-to-app new-time msg)
  "Construct an emacs modeline object."
  (if (null msg)
      " "
    (let ((s 1)
          (map (make-sparse-keymap)))

      (define-key map (vector 'mode-line 'mouse-1)
        `(lambda (e)
           (interactive "e")
           (switch-to-buffer "mail-bug")))

      (add-text-properties 0 s
                           `(local-map
                             ,map mouse-face mode-line-highlight uri
                             ,msg help-echo
                             ,(format "
Appointement in %s minutes :
%s : %s
______________________________________
mouse-1: View in agenda" min-to-app new-time msg))
                           mail-bug-logo)
      mail-bug-logo)))

(defun abug-notify-modeline (min-to-app new-time msg)
  (progn (setq global-mode-string ())
         (add-to-list 'global-mode-string
                      (abug-mode-line min-to-app new-time msg))))

;; (abug-notify-modeline "3" "00:04" "plop")

(provide 'appt-bug)
