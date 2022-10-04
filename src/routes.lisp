(in-package :webchen)

(defun html-header (stream)
  (with-html-output (stream)
    (:h1 :style "text-align: center; color: 0f0f0f; font-family: Ubuntu;"
         "WebChen")))

(defun html-footer (stream)
  (with-html-output (stream)
    (:div :style "text-align: center;"
          (:img :src "/img/made-with-lisp-logo.jpg" :alt "Made with Lisp"))))

(defun html-body (stream)
  (with-html-output (stream)
    (:div
     (:p :style "font-family: ubuntu"
         "Some text"))))

(easy-routes:defroute home ("/" :method :get) ()
  (with-html-output-to-string (s)
    (:html5
     (:head
      (:title "WebChen"))
     (:body :style "background-color: #ffffff"
            (:div :id "header"
                  (html-header s))
            (:div :id "body"
                  (html-body s))
            (:div :id "footer"
                  (html-footer s))))))
