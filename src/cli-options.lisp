(in-package :webchen)

(opts:define-opts
  (:name        :help
   :description "print this help text"
   :short       #\h
   :long        "help")
  (:name        :bind
   :description "Address to bind web server to."
   :short       #\b
   :long        "bind"
   :meta-var    "<bind address>"
   :arg-parser  #'identity
   :default     "127.0.0.1")
  (:name        :port
   :description "Port number to listen on."
   :short       #\p
   :long        "port"
   :meta-var    "<port>"
   :arg-parser  #'parse-integer
   :default     5000))

(defun unknown-option (condition)
  (format t "warning: ~s option is unknown!~%" (opts:option condition))
  (invoke-restart 'opts:skip-option))

(defun get-integer (string)
  (multiple-value-bind (value)
      (parse-integer string)
    value))

(defun parse-args (&rest args)
  (multiple-value-bind (options args)
      (handler-case
          (handler-bind ((opts:unknown-option #'unknown-option))
            (opts:get-opts))
        (opts:missing-arg (condition)
          (format t "fatal: option ~s needs an argument!~%"
                  (opts:option condition)))
        (opts:arg-parser-failed (condition)
          (format t "fatal: cannot parse ~s as argument of ~s~%"
                  (opts:raw-arg condition)
                  (opts:option condition))))
    ;; Here all options are checked independently, it's trivial to code any
    ;; logic to process them.
    (when (getf options :help)
      (progn (opts:describe
              :prefix (format nil "Webchen is a simple web application written in Common Lisp.")
              :usage-of "webchen")
             (opts:exit 1)))
    (list :bind (getf options :bind)
          :port (getf options :port))))
