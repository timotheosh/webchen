(defpackage webchen
  (:use :cl :trivial-signal)
  (:export #:-main))
(in-package :webchen)

(defparameter *server* nil)

(defun exit-on-signal (signo)
  (format *error-output* "~&received ~A~%" (signal-name signo))
  (sb-ext:exit :code 1 :abort t))

(defun server-start ()
  (setf *server* (make-instance 'hunchentoot:easy-acceptor :port 5000))
  (hunchentoot:start *server*))

(defun server-stop ()
  (hunchentoot:stop *server*))

(defun -main (&rest args)
  (declare (ignorable args))
  (setf (signal-handler :term) #'exit-on-signal)
  (setf (signal-handler :))
  (format t "Hello, world!~%")
  (loop (sleep 3)))
