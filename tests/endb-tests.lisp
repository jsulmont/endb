(defpackage endb-tests
  (:use :cl :fiveam :endb))
(in-package endb-tests)

(def-suite endb-tests)
(in-suite endb-tests)

(test test-sanity
      (is (= (+ 1 1) 2)))

(test test-get-engine-name
      (is (equal "endb" (get-engine-name))))