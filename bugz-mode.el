;;; bugz-mode.el --- Accessing bugzilla from Emacs

;; Copyright (C) 2013 Jose E. Marchesi

;; Author: Jose E. Marchesi <jemarch@gnu.org>
;; Version: 0.1
;; Keywords: bugzilla

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; bugz-mode provides an user interface to the bugzilla bug tracking
;; system.  Underneath it uses the pybugz command-line program to
;; communicate with the remote server.
;;
;; bugz-mode is designed to provide a simple but complete interface to
;; bugzilla: the goal is that you must be able to do all kind of
;; activities in the bug tracker without leaving Emacs, without
;; X-window and without a bloated modern web brower like firefox.
;;
;; Just say NO to bloated computing!.
;;
;; Requirements for running bugz-mode
;; ----------------------------------
;;
;; As already mentioned, bugz-mode depends on Pybugz, which is
;; available at http://www.liquidx.net/pybugz/
;;
;; You can either download and compile the python stuff or use a
;; binary package provided by your GNU/Linux distribution.  `apt-get
;; install bugz' worked for me in my Debian system.  The redhat
;; package seems to be named pybugz instead.  No idea about other
;; distros.
;;
;; Installing bugz-mode
;; --------------------
;;
;; If you are not using the new Emacs packaging system, just drop this
;; file in some directory in your load-path and do a require:
;;
;;    (add-to-list 'load-path "/path/to/dir/containing/bugz-mode")
;;    (require 'bugz-mode)
;;
;; Otherwise you can use M-xpackage-install-file for the elpa-like
;; installation.
;;
;; Configuring bugz-mode
;; ---------------------
;;
;; The minimal configuration you need is to set a few variables
;; telling bugz-mode where is your bugzilla server and which
;; credentials you will be using for accessing it.  Put something like
;; the following in your .emacs file:
;;
;;   (setq bugz-db-base "http://path.to.bugzilla.net/bugzilla/xmlrpc.cgi")
;;   (setq bugz-db-user "mr.foo@bar.net")
;;
;; Note that bugz-db-base expects the full path to the CGI script
;; implementing bugzilla's xmlrpc interface.  This is probably always
;; under /bugzilla/xmlrpc.cgi, but who knows...
;;
;; By default bugz-mode assumes that you will be storing your local
;; cache of bugs in ~/bugs.  While it is a very reasonable default
;; most likely you will want to use some other location.  Easy, add
;; something like this to your .emacs:
;;
;;   (setq bugz-db-dir "~/company/bugs")
;;
;; Just make sure the directory exists!  bugz-mode is lazy and wont
;; create it for you.
;;
;; You will also probably want to associate the bugz-mode major mode
;; to edit files having the .bugz extension.  So add it to your
;; auto-mode alist:
;;
;;   (add-to-list 'auto-mode-alist
;;                (cons "\\.bugz$" 'bugz-mode))
;;
;; And that is all!  Well, actually there are several other not very
;; important things you can customize.  Fire up M-xcustomize-group
;; bugz and take a look...
;;
;; Getting started
;; ---------------
;;
;; The main entry point of bugz-mode is M-xbugz.  Launch it!
;;
;; If you did not do your homework and did not create a directory for
;; bugz-db-dir then M-xbugz will barf at you and fail.  In that case
;; create the directory and try again.
;;
;; Done?  Good, run M-xbugz again and you will find yourself in the
;; so-called bugz summary buffer.  This is the buffer where you do
;; searches and manage the resulting sets of bugs.  By default the
;; summary buffer shows you the set of bugs which have been already
;; fetched from the bugzilla server and put in the local database in
;; bugz-db-dir.  This fact is reflected by the [local] mark in the
;; buffer.  Of course since this is the first time you run M-xbugz you
;; did not download any bug yet, so the list is empty.  How boring :(
;;
;; So, where are your bugs?  Well, hopefully they are at the bugzilla
;; server whose url you configured in bugz-db-base.  We have to fetch
;; them.  For that purpose you must perform a search using some
;; criteria.
;;
;; If you push the key 's' while in the summary buffer you will be
;; presented with a "fast selection" buffer ala org-mode where you can
;; select the search criteria: bugs assigned to some specific hacker,
;; bugs having some severity, bugs containing `fuck' in some comment,
;; etc.  Just select 'a' for getting the buffers assigned to you and
;; enter your username in the minibuffer.  Then you will be back to
;; the fast selection buffer to add a new criteria.  This way you can
;; add any number of search criterias to your search.  End by pressing
;; 'E' to submit your search or by pressing ENTER in order to cancel
;; the search.  For the moment just search for bugs assigned to you.
;; If there are bugs satisfying your criteria then bugz-mode will
;; populate your summary buffer with a list of lines describing them.
;; Hurrah!
;;
;; Note how the selection criteria used to fetch these bugs is
;; reflected in the [...] mark in the summary buffer.  It must read
;; now something like [:assigned-to "my@email.com"]. Unless you used
;; the "local" search criteria, in which case it will read [local].
;;
;; So, very nice, you have the list of bugs assigned to you in front
;; of you.  You can navigate through them using the keys n, p and TAB.
;; But know what, the truth is that these bugs are not yet in your
;; local database!  You fetched what could be considered some
;; "headers" describing which bugs satisfied your search criteria.
;;
;; Now, there are several ways to get a bug fetched from the bugzilla
;; server.  One is to simply select it. Go the entry of some of the
;; bugs (over the "bug XXXX" which looks like a link) and press ENTER.
;;
;; After some seconds you will be drop in a buffer called XXXXX.bugz
;; where XXXXX is the id of the bug.  Now this is much more
;; interesting!  The buffer is in the Bugz major mode, and it is
;; divided into two well diferentiated parts.
;;
;; The first part contains the headers of the bug: Title, Assigneee,
;; Reported, etc.  What you see is actually a summary of the headers.
;; Push the key 't' in order to toggle the full view to see all the
;; headers.
;;
;; The second part of the buffer contains whatever comments associated
;; with the bug.  Each comment is preceded by a highlighted header of
;; the form [Comment #XX] blah.
;;
;; Note how the bugzilla-like links ("bug xxx" and "attachment xxx")
;; that may be in the bug comments look like links.  You can navigate
;; through the comment headers and the links using the TAB key.
;;
;; But we will play with the links later.  Now go back to the summary
;; buffer by either pressing 'h' or switching to the *Bugz* buffer.
;; Note that there is an asterisk at the beginning of the entry for
;; the bug that we just visited.  This means that the bug is in the
;; local database.  Visit the bug again... it must be instantaneous!
;; Nothing has to be fetched from the server.
;;
;; Go back again to the summary buffer pressing 'h'.  Select another
;; bug and press 'r'.  This will fetch the bug from the bugzilla
;; server without visiting the bug.  An asterisk mark must appear at
;; the left of this bug entry as well.
;;
;; So if you are stil with me at this point you have a list of bugs in
;; the summary buffer.  Some of them have been fetched (marked with an
;; asterisk) some others have been not.  Now press 'l'.  This shows
;; you the "local" bugs, i.e. the bugs stored in the local database.
;; Those are the bugs which are shown when you launch M-xbugz.  You
;; will see that the [...] mark changes to [local] and that now the
;; list only contains the bugs which are in the local database.
;;
;; Do another search and press 'R' in the summary buffer.  This will
;; fetch all the bugs from the server, including the ones already
;; fetched!  The reason for this is that it is possible for the bugs
;; to have changed in the bugzilla server.  A new comment may have
;; been added, for example.  Anytime, to make sure that your local
;; database is up to date with the bugzilla server, update your local
;; bugs by pressing 'l' and then 'R'.  It is slow as hell but life
;; sucks sometimes.
;;
;; Lets focus now on the bug buffers.  Do some search and visit a bug
;; containing bugzilla links to other bugs and/or attachments.  Then
;; go to some link and press ENTER.  If it is a ling to a bug the bug
;; will be fetched and visited.  If it is a link to an attachment the
;; attachment will be fetched and opened in an Emacs buffer.  Once
;; fetched the attachments are stored in the bug-db-dir/attachments/
;; directory.
;;
;; Pressing 'R' while in a bug buffer will re-fetch the bug from the
;; server and revert the buffer if needed.  'A' will fetch all links
;; present in the bug.
;;
;; While visiting a buffer, it is possible to visit the next bug in
;; the summary buffer by pressing 'n'.  The same for the previous bug
;; pressing 'p'.  This makes it easy to quickly navigate through the
;; result of some search.
;;
;; Stored custom queries
;; ---------------------
;;
;; Having to introduce the same search criteria using 's', again and
;; again, can be a bit cumbersome and inconvenient.  In order to
;; alleviate the pain you can define your own named queries in the
;; variable `bugz-custom-queries'.  This is an example:
;;
;;  (setq bugz-custom-queries
;;    '(("My bugs" ?m (:assigned-to user-mail-address :ordered-by "importance"))
;;      ("Blockers" ?b (:severity "blocker"))))
;;
;; Here we are defining two queries, "My bugs" which refers to the
;; bugs assigned to me, and "Blockers" which refers to, well, nice
;; bugs blocking someone.  The letter after the name will be used to
;; identify the query in a fast-selection buffer, so make it
;; meaningful.
;;
;; The command to search for predefined queries is activated by
;; pressing 'S' in both the summary buffer and bug buffers.
;;
;; See the documentation of `bugz-custom-queries' for more information
;; about the keywords that you can use to define your search.
;;
;; The unplugged mode
;; ------------------
;;
;; If you press 'J' in either the summary buffer or in some bug buffer
;; you will be toggling the bugz unplugged mode.  When this minor mode
;; is activated then bugz-mode will never attempt to contact the
;; bugzilla server.  Your actions will be limited in accordance!  You
;; will still be able to access fetched buffers, but not a lot more.
;;
;; So if you are going on a trip with no connectivity and foresee you
;; will be working in some bugs, search for them in the summary buffer
;; and fetch them all!  I would also recommend doing 'A' in all of
;; them in order to fetch all their direct dependencies, attachments
;; and what not.
;;
;; Changing bugs
;; -------------
;;
;; You can add a comment to a bug by visiting its buffer and then
;; pressing 'C'.  An input buffer will be opened where you must write
;; whatever you want to comment.  Then press C-cC-c to submit the
;; comment to the server.  After that you will be back in the bug
;; buffer and you will see it is updated with your new command in it.
;;
;; The local database
;; ------------------
;;
;; bugz-mode maintains a small database of text files containing bugs
;; and attachments in whatever directory configured in bugz-db-base.
;; This is known as the "local database" and it is a sort of a cache
;; between bugz-mode and the remote bugzilla server.  An example local
;; database looks like this:
;;
;;    ~/bugs/14776.bugz
;;           15522.bugz
;;           15654.bugz
;;           15724.bugz
;;           attachments/2212
;;                       2100
;;
;; The files having the .bugz extension are text files containing bug
;; descriptions as returned by pybugz.  The files in the attachments/
;; directory contain... well, attachments.
;;
;; Bugs for which there are a file in the local database are known to
;; be "local bugs".  Note however that all the bugs in the local
;; database must also be present in the remote bugzilla: they were
;; fetched from it at some point.
;;
;; Need more help
;; --------------
;;
;; No, you don't.  Explore, have fun, use C-hm, read the code...
;;
;; Happy bug fixing!

;;; Code:

(eval-when-compile (require 'cl))

;;; Customization

(defgroup bugz-mode nil
  "bugz-mode subsystem"
  :group 'applications
  :link '(url-link "http://www.jemarch.net/bugz-mode"))

(defcustom bugz-db-dir "~/bugs"
  "Directory containing the bugs database."
  :type 'string
  :group 'bugz-mode)

(defcustom bugz-db-base nil
  "URL of the bugzilla installation. Set this to nil if you are
using bugz's own configuration scheme."
  :type 'string
  :group 'bugz-mode)

(defcustom bugz-db-user nil
  "User name to use in bugzilla. Set this to nil if bugz's own
configuration scheme is used."
  :type 'string
  :group 'bugz-mode)

(defcustom bugz-command "bugz"
  "Name of the pybugz script installed in the system."
  :type 'string
  :group 'bugz-mode)

(defcustom bugz-hidden-headers
  '("CC" "Comments" "Attachments")
  "List of header names that are hidden by default in a bugz
buffer."
  :type 'list
  :group 'bugz-mode)

(defcustom bugz-start-unplugged
  nil
  "Whether to install bugz in unplugged mode."
  :type 'boolean
  :group 'bugz-mode)

(defcustom bugz-custom-queries
  nil
  "List of user-defined custom queries for bugz-mode.

The value must be a list of named queries, with the following
structure:

 (QUERY-NAME CHAR (:keyword1 val1 :keyword2 val2 ...))

Where QUERY-NAME is a string with name of the query, which can
contain blanks, and CHAR is a letter or digit that will be
associated with the query in a fast-selection buffer.

The recognized keywords are:

  :assigned-to
       Search by the user id of the assignee of the bug.
  :reporter
       Search by the user id of the person who reported the bug.
  :cc
       Search by the user id of someone who is in CC.
  :commenter
       Search by the User id of a person who commented the bug.
  :status
       Search by the status of the bug.
  :comments
       Search for the occurrence of some string in the bug
       comments.
  :product
  :component
       Search by the product and component of the bug.
  :severity
        One of \"blocker\", \"critical\", \"major\", \"normal\",
        \"minor\", \"trivial\", \"enhancement\", \"QA\".
  :priority
        One of \"Highest\", \"High\", \"Normal\", \"Low\", \"Lowest\".
  :keywords
        Keywords.
  :ordered-by
        One of \"importance\", \"assignee\", \"date\", \"number\".

Example:

  (setq bugz-custom-queries
        '((\"my-bugs\" ?m (:assigned-to \"jose.marchesi@oracle.com\" :ordered-by \"importance\"))
          (\"recutils\" ?r (:product \"recutils\" :status \"NEW\"))))
")

;;; Faces

(defface bugz-comment-header-face
  '((t (:weight bold)))
  "Face used for comment headers in bugz files."
  :group 'bugz-mode)

(defface bugz-attachment-header-face
  '((t (:inherit bugz-link-face)))
  "Face used for attachment headers in bugz files."
  :group 'bugz-mode)

(defface bugz-header-underline-face
  '((t (:weight bold)))
  "Face used for underlines in bugz files."
  :group 'bugz-mode)

(defface bugz-header-name-face
  '((t (:inherit 'font-lock-variable-name-face)))
  "Face used for header names in bugz files."
  :group 'bugz-mode)

(defface bugz-link-face
  '((t (:underline t)))
  "Face used for links in bugz files."
  :group 'bugz-mode)

;;; Internal variables

(defconst bugz-headers-alt
  '("Title" "Assignee" "AssignedTo" "Reported" "Updated" "Status"
    "Severity" "Priority" "Reporter" "Product"
    "Component" "CC" "Comments" "Attachments" "Blocked"
    "DependsOn")
  "List of headers that can appear in a bugz file.")

(defconst bugz-header-regexp (regexp-opt bugz-headers-alt))

(defconst bugz-comment-header-regexp
  "^\\[Comment #[0-9]+\\].*$"
  "Regexp denoting a comment header line.")

(defconst bugz-attachment-header-regexp
  "^\\[Attachment] \\[\\([0-9]+\\)\\] \\[\\(.*\\)\\]$"
  "Regexp denoting an attachment header line.")

(defconst bugz-link-bug-regexp
  "\\(\\(?:bug\\)\\) \\([0-9]+\\)"
  "Regexp denoting a link to a bug.")  

(defconst bugz-link-regexp
  "\\(\\(?:attachment\\|bug\\)\\) \\([0-9]+\\)"
  "Regexp denoting a link to an attachment or a bug.")

(defconst bugz-ordering-criterias
  '("importance" "assignee" "date" "number")
  "List of criterias that can be used to order bugs when searching.")

(defconst bugz-severity-levels
  '("blocker" "critical" "major" "normal" "minor"
    "trivial" "enhancement" "QA")
  "Severity levels supported by bugzilla")

(defconst bugz-priority-levels
  '("Highest" "High" "Normal" "Low"  "Lowest")
  "Priority levels supported by bugzilla")

;;; Interface with the bugz command line program

(defun* bugz-prog-search (&rest args
                          &key (assigned-to nil) (ordered-by nil) (reporter nil)
                          (cc nil) (commenter nil) (status nil)
                          (severity nil) (priority nil) (comments nil)
                          (product nil) (component nil) (keywords nil))
  "Perform a search for bugzilla bugs.

ARGS contains the arguments to pass to the program.
This function returns a list of bug lists of the form:

  (BUG-ID ASSIGNEE TITLE)
"
  (let ((buffer (generate-new-buffer "bugz search "))
        args exec-status bugs)
    ;; Prepare the arguments to 'bugz search' based on the arguments
    ;; passed to this funcion.
    (when (stringp assigned-to)
      (setq args (cons "-a" (cons assigned-to args))))
    (when (stringp ordered-by)
      (if (member ordered-by bugz-ordering-criterias)
          (setq args (cons "-o" (cons ordered-by args)))
        (error "invalid sort criteria passed to bugz-prog-search")))
    (when (stringp reporter)
      (setq args (cons "-r" (cons reporter args))))
    (when (stringp cc)
      (setq args (cons "--cc" (cons cc args))))
    (when (stringp commenter)
      (setq args (cons "--commenter" (cons commenter args))))
    (cond
     ((stringp status)
      (setq args (cons "-s" (cons status args))))
     ((listp status)
      (cl-loop for st being the elements of status
               if (stringp st)
               do (setq args (cons "-s" (cons st args))))))
    (when (stringp severity)
      (if (member severity bugz-severity-levels)
          (setq args (cons "--severity" (cons severity args)))
        (error "invalid severity passed to bugz-prog-search")))
    (when (stringp priority)
      (if (member priority bugz-priority-levels)
          (setq args (cons "--priority" (cons priority args)))
        (error "invalid priority passed to bugz-prog-search")))
    (when (stringp comments)
      (setq args (cons "-c" (cons comments args))))
    (when (stringp product)
      (setq args (cons "--product" (cons product args))))
    (when (stringp component)
      (setq args (cons "-C" (cons component args))))
    (when (stringp keywords)
      (setq args (cons "-k" (cons keywords args))))
    ;; Prepare the bugz general arguments and command.
    (setq args (cons "search" args))
    (when (stringp bugz-db-base)
        (setq args (cons "-b" (cons bugz-db-base args))))
    (when (stringp bugz-db-user)
        (setq args (cons "-u" (cons bugz-db-user args))))
    (setq args (cons "--encoding" (cons "utf-8" args)))
    (setq args (cons "--quiet" args))
    (setq args (cons "--columns" (cons "1000" args)))
    (when (and bugz-db-base bugz-db-user)
        (let ((passwd (bugz-read-passwd)))
          (unless (equal passwd "")
            (setq args (cons "-p" (cons passwd args))))))
    ;; Call 'bugz' to perform the query.
    (unwind-protect
        (progn
          (setq exec-status (apply #'call-process-region
                                   (point-min) (point-max)
                                   bugz-command
                                   nil ; delete
                                   buffer
                                   nil ; display
                                   args))
          (if (/= exec-status 0)
              (with-current-buffer buffer
                (error (concat "bugz returned error: " (buffer-substring (point-min) (point-max))))))
          (with-current-buffer buffer
            ;; Parse output.
            (goto-char (point-min))
            (while (search-forward-regexp "^\\([0-9]+\\) +\\([^[:blank:]]+\\) +\\([^[:blank:]].*\\)$" nil t)
              (let ((bug-id (match-string-no-properties 1))
                    (bug-owner (match-string-no-properties 2))
                    (bug-description (match-string-no-properties 3)))
                (setq bugs (cons (list bug-id bug-owner bug-description) bugs))))))
      (kill-buffer buffer))
    bugs))

(defun bugz-fetch-attachment (attachment-id filename)
  "Fetch the attachment with the given Id and store it in
FILENAME.

Any previous contents on FILENAME are lost.

Signal and error if the attachment does not exist on the server."
  (message (concat "Fetching attachment " attachment-id "..."))
  (let (args)
    (with-temp-file filename
      ;; Parepare the 'attachment' specific arguments.
      (setq args (cons attachment-id args))
      (setq args (cons "-v" args))
      ;; Prepare the bugz general arguments and command.
      (setq args (cons "attachment" args))
      (setq args (cons "-b" (cons bugz-db-base args)))
      (setq args (cons "-u" (cons bugz-db-user args)))
      (setq args (cons "--encoding" (cons "utf-8" args)))
      (setq args (cons "--quiet" args))
      (let ((passwd (bugz-read-passwd)))
        (unless (equal passwd "")
          (setq args (cons "-p" (cons passwd args)))))
      ;; Call 'bugz' to perform the operation.
      (unwind-protect
          (progn
            (delete-region (point-min) (point-max))
            (setq status (apply #'call-process-region
                                (point-min) (point-max)
                                bugz-command
                                nil ; delete
                                (current-buffer)
                                nil ; display
                                args))
            (if (/= status 0)
                (error (concat "bugz returned error: " (buffer-substring (point-min) (point-max)))))))))
  (message "Attachment fetched"))

(defun bugz-fetch-bug (bug-id filename)
  "Fetch the bug with the given Id and store it in FILENAME.

Any previous contents on FILENAME are lost.

Signal an error if the bug does not exist on the server."
  (message (concat "Fetching bug " bug-id "..."))
  (let (args)
    (with-temp-file filename
      ;; Parepare the 'get' specific arguments.
      (setq args (cons bug-id args))
      ;; Prepare the bugz general arguments and command.
      (setq args (cons "get" args))
      (setq args (cons "-b" (cons bugz-db-base args)))
      (setq args (cons "-u" (cons bugz-db-user args)))
      (setq args (cons "--encoding" (cons "utf-8" args)))
      (setq args (cons "--quiet" args))
      (let ((passwd (bugz-read-passwd)))
        (unless (equal passwd "")
          (setq args (cons "-p" (cons passwd args)))))
      ;; Call 'bugz' to perform the operation.
      (unwind-protect
          (progn
            (delete-region (point-min) (point-max))
            (setq status (apply #'call-process-region
                                (point-min) (point-max)
                                bugz-command
                                nil ; delete
                                (current-buffer)
                                nil ; display
                                args))
            (if (/= status 0)
                (error (concat "bugz returned error: " (buffer-substring (point-min) (point-max)))))))))
  (bugz-sum-mark-bug-as-local bug-id)
  (message "Bug fetched"))

(defun bugz-add-comment (bug-id comment)
  "Add the given string to a bug as a new comment.

Signal an error if the bug does not exist on the server."
  (message (concat "Adding comment to bug " bug-id "..."))
  (let ((buffer (generate-new-buffer "bugz comment "))
        args)
    ;; Parepare the 'modify' specific arguments.
    (setq args (cons bug-id args))
    (setq args (cons "-c" (cons comment args)))
    ;; Prepare the bugz general arguments and command.
    (setq args (cons "modify" args))
    (setq args (cons "-b" (cons bugz-db-base args)))
    (setq args (cons "-u" (cons bugz-db-user args)))
    (setq args (cons "--encoding" (cons "utf-8" args)))
    (setq args (cons "--quiet" args))
    (let ((passwd (bugz-read-passwd)))
      (unless (equal passwd "")
        (setq args (cons "-p" (cons passwd args)))))
    ;; Call 'bugz' to perform the operation.
    (unwind-protect
        (progn
          (setq status (apply #'call-process-region
                              (point-min) (point-min)
                              bugz-command
                              nil ; delete
                              buffer
                              nil ; display
                              args))
          (if (/= status 0)
              (with-current-buffer buffer
                (error (concat "bugz returned error: " (buffer-substring (point-min) (point-max)))))))
      (kill-buffer buffer))
    (message "Comment added")))
  

;;; Parsing routines

(defun bugz-parse-headers ()
  "Parse and return the headers of the bug in the current buffer.

The headers are a list of (HEADER_NAME HEADER_VALUE) pairs."
  (save-excursion
    (let (headers)
      (goto-char (point-min))
      (while (search-forward-regexp
              (concat "^\\(" bugz-header-regexp "\\) *: +\\(.*\\)$")
              nil t)
        (setq headers (cons (list (match-string-no-properties 1) (match-string-no-properties 2)) headers)))
      headers)))

(defun bugz-parse-attachment-header ()
  "Parse the attachment header at point.

A list with the following contents is returned:

  (ATTACHMENT-ID ATTACHMENT-DESCRIPTION)
"
  (when (looking-at bugz-attachment-header-regexp)
    (list (match-string-no-properties 1) (match-string-no-properties 2))))

;;; Bugs and attachments management

(defun bugz-current-bug ()
  "Return the ID of the bug stored in the buffer."
  (let* ((buffer-name (buffer-name))
         (base (file-name-base buffer-name)))
    (when (and (string-match "[0-9]+" base)
               (equal (file-name-extension buffer-name) "bugz"))
      base)))

(defun* bugz-open-bug (bug-id 
                       &rest args
                       &key (force-download nil) (other-window nil) (external nil)
                            (only-fetch nil))
  "Open the referred bug in a sibling window.

If FORCE-DOWNLOAD is not nil then force the download of the bug
from the server even if it already exists in the local database.

If the bug is not present in the local database then fetch it
from the server."
  (unless (file-exists-p bugz-db-dir)
    (error (concat "The directory "  bugz-db-dir " does not exist")))
  (let ((bug-file-name (bugz-bug-filename bug-id)))
    (when (or force-download (not (file-exists-p bug-file-name)))
      (when (and (not external) bugz-unplugged-mode)
        (error "Sorry, unplugged mode is activated.  Not connecting to server."))
      ;; Fetch the bug from the server.
      (bugz-fetch-bug bug-id bug-file-name))
    ;; Open the bug in a sibling buffer.
    (unless only-fetch 
      (if other-window
          (find-file-other-window bug-file-name)
        (find-file bug-file-name))
      (when (not (eql major-mode 'bugz-mode)) (bugz-mode)))))

(defun* bugz-open-attachment (attachment-id
                              &rest args
                              &key (force-download nil) (only-fetch nil) (other-window nil))
  "Open the attachment with the given Id in a sibling window.

If the attachment is not present in the local database then fetch
it from the server."
  (unless (file-exists-p (concat bugz-db-dir "/attachments"))
    (make-directory (concat bugz-db-dir "/attachments")))
  (let ((attachment-file (concat bugz-db-dir "/attachments/" attachment-id)))
    (when (or force-download (not (file-exists-p attachment-file)))
      (when bugz-unplugged-mode
        (error "Sorry, unplugged mode is activated.  Not connecting to server."))
      ;; Fetch the attachment from the server.
      (bugz-fetch-attachment attachment-id attachment-file))
    ;; Open the attachment file in a sibling buffer.
    (unless only-fetch
      (if other-window
          (find-file-other-window attachment-file)
        (find-file attachment-file)))))

(defun* bugz-open-whatever (&rest args
                            &key (force-download nil) (only-fetch nil) (other-window nil))
  "Open the entity whose header or link is behind the cursor in a
sibling window.  Download it from the server if needed or if
FORCE-DOWNLOAD is non-nil."
  (cond
   ;; Attachments can be referred by both a header and a link.
   ((equal (get-text-property (point) 'link-kind) "attachment")
    (bugz-open-attachment (get-text-property (point) 'target-id)
                          :force-download force-download
                          :only-fetch only-fetch
                          :other-window other-window))
   ((progn (save-excursion (beginning-of-line)
                           (looking-at bugz-attachment-header-regexp)))
    (save-excursion (beginning-of-line) ; Yes, the code in this cond entry sucks
                    (bugz-open-attachment (car (bugz-parse-attachment-header))
                                          :force-download force-download
                                          :other-window other-window)
                                          :only-fetch only-fetch))
   ;; Bugs can be referred by links.
   ((equal (get-text-property (point) 'link-kind) "bug")
    (bugz-open-bug (get-text-property (point) 'target-id) 
                   :force-download force-download
                   :only-fetch only-fetch
                   :other-window other-window))
   (t
    (message "Move to a link or a header to open something..."))))

(defun bugz-get-local-bugs ()
  "Get the list of bugs which are present in the local database."
  (let ((bug-files (directory-files bugz-db-dir t "^[0-9]+\\.bugz$"))
        bugs)
    (mapc
     (lambda (bug-file)
       (with-temp-buffer
         (insert-file-contents bug-file)
         (let* ((headers (bugz-parse-headers))
                (bug-id (file-name-base bug-file))
                (bug-title (assoc "Title" headers))
                (bug-assignee (or (assoc "Assignee" headers)
                                  (assoc "AssignedTo" headers))))
           (unless bug-title (error (concat "Missing Title header in " bug-file)))
           (unless bug-assignee (error (concat "Missing Assignee header in " bug-file)))
           (setq bugs (cons (list bug-id (cadr bug-assignee) (cadr bug-title)) bugs)))))
     bug-files)
    bugs))

(defun bugz-search-bugs (search-args)
  "Get the list of bugs which are the result of a search in the
server."
  (unwind-protect
      (apply #'bugz-prog-search search-args)))

(defun bugz-bug-filename (bug-id)
  "Return the full path for the filename corresponding to BUG-ID."
  (concat bugz-db-dir "/" bug-id ".bugz"))

(defun bugz-bug-local-p (bug-id)
  "Determine whether a given bug is in the local database."
  (file-exists-p (bugz-bug-filename bug-id)))

;;; Printing routines

(defun bugz-print-bug-sum (bug)
  "Print the summary line for a given bug."
  (let ((bug-id (car bug))
        (bug-assignee (cadr bug))
        (bug-title (caddr bug)))
    (if (file-exists-p (bugz-bug-filename bug-id))
        (insert "*  ")
      (insert "   "))
    (insert "bug " bug-id "\t" bug-assignee "\t" bug-title "\n")))

(defun bugz-print-bugs-sum (bugs)
  "Print the summary lines for a set of bugs."
  (if bugs
      (mapcar (lambda (bug) (bugz-print-bug-sum bug)) bugs)
    (insert "   No bugs, definitely good news!")))

(defun bugz-update-sum ()
  "Update the contents of the Bugz Summary buffer using the
search criteria in the buffer-local variable
`bugz-sum-current-search'."
  (message "Updating summary...")
  (let ((buffer (get-buffer-create "*Bugz*")))
    (let ((bugs (if bugz-sum-current-search
                    (bugz-search-bugs bugz-sum-current-search)
                  (bugz-get-local-bugs))))
      (set-buffer buffer)
      (let ((buffer-read-only nil))
        (delete-region (point-min) (point-max))
        (insert "These are your bugs, give them love.  Press 's' for a new search, 'l' for local bugs.\n\n")
        (insert (concat "Query: ["
                        (if (listp bugz-sum-current-search)
                            (mapconcat (lambda (elm)
                                         (if (symbolp elm)
                                             (symbol-name elm)
                                           (concat (prin1-to-string elm t)
                                                   ";")))
                                       bugz-sum-current-search " ")
                          (warn "bugz-sum-current-search has invalid value.")
                          "local")
                        "]"))
        (insert "\n\n")
        (bugz-print-bugs-sum bugs)
        (goto-char (point-min))
        (bugz-cmd-jump-to-next-whatever))
      (bugz-sum-mode)))
  (message "done"))

(defun bugz-sum-mark-bug-as-local (bug-id)
  (save-excursion
    (let ((buffer-read-only nil))
      (goto-char (point-min))
      (when (search-forward-regexp (concat "^...bug " bug-id) nil t)
        (beginning-of-line)
        (delete-char 1)
        (insert "*")))))

;;; Links management

(defun bugz-mark-links ()
  "Search for links (attachments, bugs, etc) and mark them as
such using text properties."
  (save-excursion
    (goto-char (point-min))
    (while (search-forward-regexp bugz-link-regexp nil t)
      (let ((kind (match-string-no-properties 1))
            (id (match-string-no-properties 2)))
        (put-text-property (match-beginning 0) (match-end 0)
                           'link-kind kind)
        (put-text-property (match-beginning 0) (match-end 0)
                           'target-id id)))))
;;; Header hidding

(defvar bugz-header-hidding-overlays nil
  "Overlays hidding headers.")

(defun bugz-headers-visible-p ()
  "Return whether the hidden headers are visible on the current
buffer."
  (not bugz-header-hidding-overlays))

(defun bugz-hide-headers ()
  "Hide the headers whose names are in `bugz-hidden-headers'."
  (save-excursion
    (goto-char (point-min))
    (while (search-forward-regexp
            (concat "^\\(" bugz-header-regexp "\\) *: +\\(.*\\)$")
            nil t)
      (when (member (match-string-no-properties 1) bugz-hidden-headers)
        (let (ov)
          (setq ov (make-overlay (match-beginning 0) (+ (match-end 0) 1)))
          (overlay-put ov 'invisible t)
          (push ov bugz-header-hidding-overlays))))))

(defun bugz-unhide-headers ()
  "Show all headers."
  (mapc 'delete-overlay bugz-header-hidding-overlays)
  (setq bugz-header-hidding-overlays nil))

;;; Unplugged support

(define-minor-mode bugz-unplugged-mode
  "Minor mode to manipulate bugz files in an unplugged state.
When this mode is on then no communication with the bugzilla
server is performed at all."
  nil
  :global t :group 'bugz)

;;;; Fast selection

(defun bugz-fast-selection (names prompt)
  "Fast group tag selection with single keys.

NAMES is an association list of the form:

    ((\"NAME1\" char1) ...)

Each character should identify only one name."
  ;; Adapted from `org-fast-tag-selection' in org.el by Carsten Dominic
  ;; Thanks Carsten! :D
  (let* ((maxlen (apply 'max (mapcar (lambda (name)
                                       (string-width (car name))) names)))
         (buf (current-buffer))
         (fwidth (+ maxlen 3 1 3))
         (ncol (/ (- (window-width) 4) fwidth))
         name count result char i key-list)
    (save-window-excursion
      (set-buffer (get-buffer-create " *Rec Fast Selection*"))
      (delete-other-windows)
      (switch-to-buffer-other-window (get-buffer-create " *Rec Fast Selection*"))
      (erase-buffer)
      (insert prompt ":")
      (insert "\n\n")
      (setq count 0)
      (while (setq name (pop names))
        (setq key-list (cons (cadr name) key-list))
        (insert "[" (cadr name) "] "
                (car name)
                (make-string (- fwidth 4 (length (car name))) ?\ ))
        (when (= (setq count (+ count 1)) ncol)
          (insert "\n")
          (setq count 0)))
      (goto-char (point-min))
      (if (fboundp 'fit-window-to-buffer)
          (fit-window-to-buffer))
      (catch 'exit
        (while t
          (message "[a-z0-9...]: Select entry   [RET]: Exit")
          (setq char (let ((inhibit-quit t)) (read-char-exclusive)))
          (cond
           ((= char ?\r)
            (setq result nil)
            (throw 'exit t))
           ((member char key-list)
            (setq result char)
            (throw 'exit t)))))
      result)))

;;; Misc functions

(defun bugz-read-passwd ()
  "Ask interactively for a password unless bugz has a login cookie for
`bugz-db-base'."
  (let* ((domain (if (string-match "^.*//\\([^/]*\\)/.*$" bugz-db-base)
                     (substring bugz-db-base (match-beginning 1) (match-end 1))
                   (error "Invalid url in bugz-db-base")))
         (ask-for-passwd (not (when (file-exists-p "~/.bugz_cookie")
                                (with-temp-buffer
                                  (insert-file-contents "~/.bugz_cookie")
                                  (goto-char (point-min))
                                  (search-forward-regexp (concat "Bugzilla_logincookie.*" domain ".*$") nil t))))))
    (if ask-for-passwd
        (read-passwd (concat "Password for " bugz-db-base " [default: NO password]: "))
      "")))

(defun bugz-sum-previous-bug (bug-id)
  "Return the Id of the bug listed immediately before the bug with
Id BUG-ID, if any."
  (save-excursion
    (when (get-buffer "*Bugz*")
      (set-buffer "*Bugz*")
      (goto-char (point-min))
      (when (search-forward-regexp (concat "^...bug " bug-id) nil t)
        (goto-char (match-beginning 0))
        (when (search-backward-regexp bugz-link-bug-regexp nil t)
          (match-string-no-properties 2))))))

(defun bugz-sum-next-bug (bug-id)
  "Return the Id of the bug listed immediately after the bug with
Id BUG-ID, if any."
  (save-excursion
    (when (get-buffer "*Bugz*")
      (set-buffer "*Bugz*")
      (goto-char (point-min))
      (when (search-forward-regexp (concat "^...bug " bug-id) nil t)
        (when (search-forward-regexp bugz-link-bug-regexp nil t)
          (match-string-no-properties 2))))))

;;; Interactive commands

(defun bugz-cmd-toggle-hidden-headers ()
  "Toggle the visibility of hidden headers."
  (interactive)
  (if (bugz-headers-visible-p)
      (bugz-hide-headers)
    (bugz-unhide-headers)))

(defun bugz-cmd-jump-to-next-whatever ()
  "Move the cursor to the next interesting thing in the buffer."
  (interactive)
  (let ((thing-regexp (concat "\\("
                            bugz-comment-header-regexp
                            "\\|"
                            bugz-attachment-header-regexp
                            "\\|"
                            bugz-link-regexp
                            "\\)")))
    (when (looking-at thing-regexp)
      (forward-char))
    (if (search-forward-regexp thing-regexp nil t)
        (goto-char (match-beginning 0))
      (when (/= (point) (point-min))
        (message "Back to the beginning!")
        (setq bugz-found-last-comment nil)
        (goto-char (point-min))
        (bugz-cmd-jump-to-next-whatever)))))

(defun bugz-cmd-open-whatever (n)
  "Open the entity whose header or link is behind the cursor in a
sibling window, downloading it from the server if needed.

With a numeric prefix force the download."
  (interactive "P")
  (bugz-open-whatever :force-download n))

(defun bugz-cmd-open-whatever-other-window (n)
  "Open the entity whose header or link is behind the cursor,
downloading it from the server if needed.

With a numeric prefix force the download."
  (interactive "P")
  (bugz-open-whatever :force-download n
                      :other-window t))

(defun bugz-cmd-update-bug ()
  "Re-fetch the bug in the current file from the bugzilla
server."
  (interactive)
  (when bugz-unplugged-mode
    (error "Sorry, unplugged mode is activated.  Not connecting to server."))
  (let ((bug-id (bugz-current-bug))
        (current-char (point)))
    (unless bug-id
      (error "Hmm, is this a bugz buffer? It does not look like one"))
    (bugz-open-bug (bugz-current-bug) :force-download t :only-fetch t)
    (revert-buffer t t)
    (goto-char current-char)))

(defun bugz-cmd-toggle-unplugged ()
  "Toggle the unplugged state of bugz-mode."
  (interactive)
  (bugz-set-unplugged (not bugz-unplugged))
  (message (concat "Bugz-mode is now "
                   (if bugz-unplugged "unplugged" "plugged")
                   "!")))

(defun bugz-cmd-fetch-all ()
  "Fetch all the bugs and attachments referenced in the current
bug."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (search-forward-regexp
            (concat "\\("
                    bugz-attachment-header-regexp
                    "\\|"
                    bugz-link-regexp
                    "\\)")
            nil t)
      (backward-char) ; The matched strings have at least one character.
      (bugz-open-whatever :only-fetch t))))

(defun bugz-cmd-search ()
  "Ask for a search criteria and add a new section to the Bugz
Summary buffer with the result."
  (interactive)
  (when bugz-unplugged-mode
    (error "Sorry, unplugged mode is activated.  Not connecting to server."))
  (let ((keywords '((?a ":assigned-to") (?r ":reporter") (?c ":comments")
                    (?s ":status") (?S ":severity") (?p ":priority")
                    (?P ":product") (?C ":component") (?m ":commenter") (?q ":cc")))
        letter args)
    ;; Get the search criteria from the user, accumulating pairs of
    ;; ':keyword value' until the user introduces End or ENTER.
    (while (and (not (equal (setq letter (bugz-fast-selection '(("Assigned to" ?a) ("Reporter" ?r)
                                                                ("Comments" ?c)
                                                                ("Status" ?s) ("Severity" ?S) ("Priority" ?p)
                                                                ("Product" ?P) ("Component" ?C)
                                                                ("Commenter" ?m) ("CC" ?q)
                                                                ("End" ?E))
                                                              (concat "Add to search criteria [" args "]"))) ?E))
                letter)
      (let* ((keyword (cadr (assoc letter keywords)))
             (value (let ((prompt (concat (substring keyword 1) ": ")))
                      (cond
                       ((equal keyword ":severity")
                        (completing-read prompt bugz-severity-levels nil t))
                       ((equal keyword ":priority")
                        (completing-read prompt bugz-priority-levels nil t))
                       ((equal keyword ":ordered-by")
                        (completing-read prompt bugz-orderint-criterias nil t))
                       (t (read-from-minibuffer prompt))))))
        (setq args (concat args keyword " \"" value "\" "))))
    (if (and letter args)
        (progn
          (setq args (substring args 0 -1)) ; Remove trailing space
          ;; Fetch the bugs from the server and add them to the bugz summary
          ;; buffer.
          (setq bugz-sum-current-search (if (equal args "") nil args))
          (bugz-update-sum)
          (switch-to-buffer "*Bugz*"))
      (message "Never mind"))))

(defun bugz-cmd-search-user ()
  "Search for one of the user-defined queries in `bugz-custom-queries'."
  (interactive)
  (if (not bugz-custom-queries)
      (message "Sorry, define some queries in bugz-custom-queries first.")
    (let* ((letter (bugz-fast-selection 
                    (mapcar (lambda (query) (list (car query) (cadr query)))
                            bugz-custom-queries)
                    "Select query"))
           args)
      (if letter
          (progn
            (setq args (cadr (assoc letter (mapcar (lambda (query) (cdr query)) bugz-custom-queries))))
            ;; Fetch the bugs from the server and add them to the bugz
            ;; summary buffer.
            (setq bugz-sum-current-search args)
            (bugz-update-sum)
            (switch-to-buffer "*Bugz*"))
        (message "Never mind")))))

(defun bugz-cmd-local ()
  "List the local symbols."
  (interactive)
  (setq bugz-sum-current-search nil)
  (bugz-update-sum)
  (switch-to-buffer "*Bugz*"))

(defun bugz-sum-cmd-update-all ()
  "Update all the bugs in the bugz summary buffer from the
bugzilla server."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (search-forward-regexp bugz-link-bug-regexp nil t)
      (let ((bug-id (match-string 2)))
      (bugz-fetch-bug bug-id (bugz-bug-filename bug-id))
      (bugz-sum-mark-bug-as-local bug-id)))))

(defun bugz-sum-cmd-update ()
  "Update the bug under pointer from the bugzilla server."
  (interactive)
  (let ((link-kind (get-text-property (point) 'link-kind))
        (target-id (get-text-property (point) 'target-id)))
    (if (equal link-kind "bug")
        (progn
          (bugz-fetch-bug target-id (bugz-bug-filename target-id))
          (bugz-sum-mark-bug-as-local target-id))
      (message "Not on a bug"))))

(defun bugz-sum-cmd-jump-to-next-bug ()
  "Goto the next bug link in a bugz summary buffer."
  (interactive)
  (when (looking-at bugz-link-bug-regexp)
    (forward-char))
  (if (search-forward-regexp bugz-link-bug-regexp nil t)
      (goto-char (match-beginning 0))
    (backward-char)
    (message "No more bugs")))

(defun bugz-sum-cmd-jump-to-previous-bug ()
  "Goto the previous bug link in a bugz summary buffer."
  (interactive)
  (if (search-backward-regexp bugz-link-bug-regexp nil t)
      (goto-char (match-beginning 0))
    (message "No more bugs")))

(defun bugz-sum-cmd-quit ()
  "Quit bugz."
  (interactive)
  (when (eql major-mode 'bugz-sum-mode)
    (kill-buffer)))

(defun bugz-cmd-open-previous-bug ()
  "Open the previous bug listed in the summary buffer. If the bug is
not stored locally then fetch it frmo the server if not
in unplugged mode."
  (interactive)
  (let ((bug-id (bugz-current-bug))
        prev-bug-id)
    (while (and (setq bug-id (bugz-sum-previous-bug bug-id))
                (or (bugz-bug-local-p bug-id) (not bugz-unplugged-mode))
                (not prev-bug-id))
      (setq prev-bug-id bug-id))
    (if prev-bug-id
        (progn
          (bugz-open-bug prev-bug-id)
          (goto-char (point-min)))
      (message "No more bugs"))))

(defun bugz-cmd-open-next-bug ()
  "Open the next bug listed in the summary buffer.  If the bug is
not stored locally then fetch it from the server if not in
unplugged mode."
  (interactive)
  (let ((bug-id (bugz-current-bug))
        next-bug-id)
    (while (and (setq bug-id (bugz-sum-next-bug bug-id))
                (or (bugz-bug-local-p bug-id) (not bugz-unplugged-mode))
                (not next-bug-id))
      (setq next-bug-id bug-id))
    (if next-bug-id
        (progn
          (bugz-open-bug next-bug-id)
          (goto-char (point-min)))
      (message "No more bugs"))))

(defun bugz-cmd-bugz ()
  (interactive)
  (bugz))

;;; Comment editing mode

(defvar bugz-prev-buffer nil)
(defvar bugz-prev-bug-id nil)

(defun bugz-cmd-add-comment ()
  "Add a new comment to the current bug and refresh it."
  (interactive)
  (let ((bug-id (bugz-current-bug)))
    (when bug-id
      (setq bugz-prev-bug-id bug-id)
      (setq bugz-prev-buffer (current-buffer)) ; Used by bugz-finish-editing-comment.
      (let ((edit-buf (get-buffer-create "*Bugz comment*")))
        (set-buffer edit-buf)
        (delete-region (point-min) (point-max))
        (bugz-comment-edition-mode)
        (switch-to-buffer-other-window edit-buf)
        (message "Edit contents of the comment and use C-c C-c to exit")))))

(defun bugz-finish-editing-comment ()
  "Submit the just edited comment."
  (interactive)
  (let ((edit-buffer (current-buffer)))
    (bugz-add-comment bugz-prev-bug-id
                      (buffer-substring-no-properties (point-min) (point-max)))
    (if (equal (length (window-list)) 1)
        (set-window-buffer (selected-window) bugz-prev-buffer)
      (delete-window))
    (switch-to-buffer bugz-prev-buffer)
    (kill-buffer edit-buffer)
    (bugz-cmd-update-bug)))

(defvar bugz-comment-edition-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-c" 'bugz-finish-editing-comment)
    map)
  "Keymap for bugz-comment-edition-mode")

(defun bugz-comment-edition-mode ()
  "A major mode for editing bugz comments.

Commands:
\\{bugz-comment-edition-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (use-local-map bugz-comment-edition-mode-map)
  (setq mode-name "Bugz Comment Edit")
  (setq major-mode 'bugz-comment-edition-mode))
      
;;; Definition of the bugz major mode

(defvar bugz-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "t" 'bugz-cmd-toggle-hidden-headers)
    (define-key map (kbd "TAB") 'bugz-cmd-jump-to-next-whatever)
    (define-key map (kbd "RET") 'bugz-cmd-open-whatever)
    (define-key map "o" 'bugz-cmd-open-whatever-other-window)
    (define-key map "R" 'bugz-cmd-update-bug)
    (define-key map "J" 'bugz-unplugged-mode)
    (define-key map "A" 'bugz-cmd-fetch-all)
    (define-key map "s" 'bugz-cmd-search)
    (define-key map "S" 'bugz-cmd-search-user)
    (define-key map "h" 'bugz-cmd-bugz)
    (define-key map "n" 'bugz-cmd-open-next-bug)
    (define-key map "p" 'bugz-cmd-open-previous-bug)
    (define-key map "C" 'bugz-cmd-add-comment)
    (define-key map (kbd "SPC") 'scroll-up-command)
    map)
  "Keymap for bugz-mode")

(defconst bugz-font-lock-keywords
  `((,(concat "^" "--------+") . 'bugz-header-underline-face)
    ("\\(bug\\|attachment\\) [0-9]+" . 'bugz-link-face)
    (,(concat "^" bugz-header-regexp " *:") . 'bugz-header-name-face)
    (,bugz-comment-header-regexp . 'bugz-comment-header-face)
    ("^\\[Attachment\\].*$" . 'bugz-attachment-header-face))
  "Font lock keywords used in bugz-mode")

;;;###autoload
(defun bugz-mode ()
  "A major mode for editing bugzilla bugs fetched by pybugz.

Commands:
\\{bugz-mode-map}

Turning on bugz-mode calls the members of the variable
`bugz-mode-hook' with no args, if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
  (setq font-lock-defaults '(bugz-font-lock-keywords))
  (use-local-map bugz-mode-map)
  ;; (set-syntax-table rec-mode-syntax-table)
  (make-local-variable 'bugz-header)
  (unless (setq bugz-headers (bugz-parse-headers))
    (error "parsing bug headers"))
  (let ((buffer-read-only nil))
    (bugz-hide-headers)
    (bugz-mark-links))
;;    (when (bugz-current-bug)
;;      (save-buffer)))
  (setq mode-name "Bugz")
  (setq major-mode 'bugz-mode)
  (when bugz-start-unplugged
    (bugz-unplugged-mode 1))
  (read-only-mode 1)
  (run-hooks 'bugz-mode-hooks))

;;; Definition of the bugz-sum major mode

(defvar bugz-sum-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "TAB") 'bugz-cmd-jump-to-next-whatever)
    (define-key map (kbd "RET") 'bugz-cmd-open-whatever)
    (define-key map "o" 'bugz-cmd-open-whatever-other-window)
    (define-key map "J" 'bugz-unplugged-mode)
    (define-key map "A" 'bugz-cmd-fetch-all)
    (define-key map "s" 'bugz-cmd-search)
    (define-key map "S" 'bugz-cmd-search-user)
    (define-key map "l" 'bugz-cmd-local)
    (define-key map "R" 'bugz-sum-cmd-update-all)
    (define-key map "r" 'bugz-sum-cmd-update)
    (define-key map "q" 'bugz-sum-cmd-quit)
    (define-key map "n" 'bugz-sum-cmd-jump-to-next-bug)
    (define-key map "p" 'bugz-sum-cmd-jump-to-previous-bug)
    map)
  "Keymap for bugz-mode")

(defvar bugz-sum-current-search nil
  "Current search shown in bugz summary.")
(make-variable-buffer-local 'bugz-sum-current-search)

;;;###autoload
(defun bugz-sum-mode ()
  "A major mode for editing bugz summary buffers.

Commands:
\\{bugz-sum-mode-map}

Turning on bugz-sum-mode calls the members of the variable
`bugz-sum-mode-hook' with no args, if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
  (setq font-lock-defaults '(bugz-font-lock-keywords))
  (use-local-map bugz-sum-mode-map)
  (let ((buffer-read-only nil))
    (bugz-mark-links))
  (setq mode-name "Bugz Summary")
  (setq major-mode 'bugz-sum-mode)
  (when bugz-start-unplugged
    (bugz-unplugged-mode 1))
  (setq truncate-lines t)
  (read-only-mode 1)
  (run-hooks 'bugz-sum-mode-hook))
    
;;; Entry points

(defun bugz-open (bug-id)
  "Open a bug from some bugzilla server and display it."
  (interactive "sBug Id: ")
  (bugz-open-bug bug-id :external t))

;;;###autoload
(defun bugz ()
  "Populate a bugz summary buffer and show it in a new window."
  (interactive)
  (unless (file-exists-p bugz-db-dir)
    (error (concat "Can't open " bugz-db-dir ".  Create it first.")))
  (unless (get-buffer "*Bugz*")
    (bugz-update-sum))
  (switch-to-buffer "*Bugz*"))
      
;;; Epilog
  
(provide 'bugz-mode)

;;; bugz-mode.el ends here
