(defpackage webchen
  (:use :cl :trivial-signal :cl-who)
  (:export #:-main))
(in-package :webchen)

(defparameter *server* nil)

(defun exit-on-signal (signo)
  (format *error-output* "~&received ~A~%" (signal-name signo))
  (sb-ext:exit :code 1 :abort t))

(defun array-to-ip4 (array)
  (format nil "~{~A~^.~}"  (map 'list #'identity array)))

(defun array-to-ip6 (array)
  (format nil "~{~A~^:~}"  (map 'list #'identity array)))

(defun get-host-by-name (host)
  (let ((ip-addresses '()))
    (multiple-value-bind (ipv4 ipv6)
        (handler-case
            (sb-bsd-sockets:get-host-by-name host)
          (sb-bsd-sockets:host-not-found-error (err)
            (format t "~A~%Host: ~A not found!" err host)))
      (when (and ipv4 ipv6)
        (when (slot-value ipv4 'SB-BSD-SOCKETS::addresses)
          (setf (getf ip-addresses :ip4)
                (mapcar 'array-to-ip4 (slot-value ipv4 'SB-BSD-SOCKETS::addresses))))
        (when (slot-value ipv6 'SB-BSD-SOCKETS::addresses)
          (format t "ipv6 is not nil: ~A" ipv6)
          (setf (getf ip-addresses :ip6)
                (mapcar 'array-to-ip6 (slot-value ipv6 'SB-BSD-SOCKETS::addresses))))
        ip-addresses))))

(defun get-ip4-by-host (host)
  (let ((ips (get-host-by-name host)))
    (if (getf ips :ip4)
        (first (getf ips :ip4))
        (first (getf ips :ip6)))))

(defun get-ip6-by-host (host)
  (let ((ips (get-host-by-name host)))
    (if (getf ips :ip6)
        (first (getf ips :ip6))
        (first (getf ips :ip4)))))


(defun server-start (&key (address "127.0.0.1") (port 5000) (access-log *error-output*) (message-log *error-output*))
  (let ((ip-address (get-ip4-by-host address)))
    (format t "Starting server, listening on http://~A:~A~%" ip-address port)
    (setf *server* (make-instance 'easy-routes:routes-acceptor :address ip-address
                                                               :port port
                                                               :access-log-destination access-log
                                                               :message-log-destination message-log))
    (hunchentoot:start *server*)))

(defun server-stop ()
  (when (hunchentoot:stop *server*)
    (setf *server* nil)
    t))

(defun set-signals ()
  (loop for signal in '(:int :term)
        do (setf (signal-handler signal) #'exit-on-signal)))

(defun -main (&rest args)
  (declare (ignorable args))
  (let* ((options (parse-args args)))
    (server-start :address (getf options :bind)
                  :port (getf options :port))
    (tagbody
       (signal-handler-bind ((15 (lambda (c) (format t "Shutting down webserver~%") (go :escape)))
                             (2 (lambda (c) (format t "Shutting down webserver~%") (go :escape)))
                             )
         (loop (sleep 3)))
     :escape
       (server-stop)
       (format t "server is shut down~%"))
    ))
