(ns jg
  (:require [clojure.java.io]
            [clojure.reflect]
            [clojure.string :refer [starts-with?]]
            [clojure.pprint :refer [pp pprint print-table]]))

(defn with-filter
  "Filtering with fzf"
  [command coll]
  (let [sh  (or (System/getenv "SHELL") "sh")
        pb  (doto (ProcessBuilder. [sh "-c" command])
               (.redirectError
                 (java.lang.ProcessBuilder$Redirect/to (clojure.java.io/file "/dev/tty"))))
        p   (.start pb)
        in  (clojure.java.io/reader (.getInputStream p))
        out (clojure.java.io/writer (.getOutputStream p))]
    (binding [*out* out]
      (try (doseq [e coll] (println e))
           (.close out)
           (catch Exception e)))
    (take-while identity (repeatedly #(.readLine in)))))

(defmacro do-pprint
  "Executes each form and pretty-print the result"
  [& body]
  `(do
     ~@(map (fn [form]
              `(let [result# ~form]
                 (pprint (list (symbol "=") '~form result#))
                 result#))
            body)))

(defn print-members
  "Prints the members"
  [obj]
  (print-table (->> obj
                    clojure.reflect/reflect
                    :members
                    (filter (every-pred :exception-types :return-type))
                    (sort-by :name)
                    (map #(select-keys % [:name :parameter-types :return-type])))))

(defn fns
  "Selects namespace using fzf"
  []
  (if-let [selected
           (first (with-filter "fzf-tmux +m"
                    (->> (all-ns) (map #(.getName %)) sort)))]
    (in-ns (symbol selected))))

(defn pbcopy
  "Copies pretty-printed string to clipboard"
  [& [obj]]
  (let [p (.. (Runtime/getRuntime) (exec "pbcopy"))
        o (clojure.java.io/writer (.getOutputStream p))]
    (binding [*out* o] (pprint (or obj *1)))
    (.close o)
    (.waitFor p)))

(defn debug-form*
  [form]
  `(debug-form ~form))

(defmacro debug-form
  [& forms]
  (let [syms (keys &env)]
    `(let [st#      (System/nanoTime)
           result#  (do ~@forms)
           elapsed# (format "%.3f ms"
                            (double (/ (- (System/nanoTime) st#) 1000000)))]
       (pprint {:env {~@(mapcat (fn [s] [`'~s `~s]) syms) ~@[]}
                :form '~(last &form)
                :result result#
                :class (class result#)
                :caller (-> ^Throwable (ex-info "" {}) .getStackTrace (nth 3) str)
                :elapsed elapsed#})
       result#)))

(defn help
  []
  (print-table
    (for [[sym var] (ns-publics 'jg)
          :when (not (starts-with? (str sym) "debug"))]
      {:name sym :desc (-> var meta :doc)})))
