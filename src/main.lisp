(defpackage webchen
  (:use :cl :trivial-signal :cl-who)
  (:export #:-main))
(in-package :webchen)

(defparameter *server* nil)

(defun exit-on-signal (signo)
  (format *error-output* "~&received ~A~%" (signal-name signo))
  (sb-ext:exit :code 1 :abort t))

(defun server-start (&key (address "127.0.0.1") (port 5000) (access-log *error-output*) (message-log *error-output*))
  (setf *server* (make-instance 'easy-routes:routes-acceptor :address address
                                                             :port port
                                                             :access-log-destination access-log
                                                             :message-log-destination message-log))
  (hunchentoot:start *server*))

(defun server-stop ()
  (when (hunchentoot:stop *server*)
    (setf *server* nil)
    t))

(defun set-signals ()
  (loop for signal in '(:int :term)
        do (setf (signal-handler signal) #'exit-on-signal)))

(defun -main (&rest args)
  (declare (ignorable args))
  (server-start :port 5555)
  (tagbody
     (signal-handler-bind ((15 (lambda (c) (format t "Shutting down webserver~%") (go :escape)))
                           (2 (lambda (c) (format t "Shutting down webserver~%") (go :escape)))
                           )
       (loop (sleep 3)))
   :escape
     (server-stop)
     (format t "server is shut down~%")))
