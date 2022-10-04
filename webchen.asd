(defsystem "webchen"
  :version "0.1.0"
  :author "Tim Hawes"
  :license "MIT"
  :depends-on (#:cl-ppcre
               #:unix-opts
               #:hunchentoot
               #:easy-routes
               #:trivial-signal)
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "webchen/tests")))
  :build-operation "asdf:program-op"
  :build-pathname "target/webchen"
  :entry-point "webchen:-main")

(defsystem "webchen/tests"
  :author "Tim Hawes"
  :license "MIT"
  :depends-on ("webchen"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for webchen"
  :perform (test-op (op c) (symbol-call :rove :run c)))
