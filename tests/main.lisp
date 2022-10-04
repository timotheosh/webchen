(defpackage webchen/tests/main
  (:use :cl
        :webchen
        :rove))
(in-package :webchen/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :webchen)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
