# Clojure Patterns

## Immutable Data and Transformations

```clojure
;; Prefer plain maps — treat data as the API
(def order {:id 42 :customer "Alice" :items [{:sku "A1" :qty 2} {:sku "B3" :qty 1}]})

;; Nested updates with update-in and assoc-in
(update-in order [:items 0 :qty] inc)
(assoc-in order [:shipping :address] "123 Main St")

;; Destructuring in function params
(defn total-qty [{:keys [items]}]
  (reduce + (map :qty items)))

;; select-keys to extract a subset
(select-keys order [:id :customer])
```

## Transducers

Compose transformations without intermediate collections.

```clojure
;; Without transducers — creates intermediate seqs
(->> orders (filter active?) (map :total) (reduce +))

;; With transducers — single pass, no intermediates
(transduce (comp (filter active?) (map :total)) + orders)

;; Reusable transducer
(def process-xf
  (comp
    (filter #(> (:amount %) 100))
    (map #(assoc % :flagged true))
    (take 50)))

;; Apply to different contexts
(into [] process-xf transactions)
(sequence process-xf transactions)
(transduce process-xf conj [] transactions)
```

## Protocols and Multimethods

```clojure
;; Protocols for type-based dispatch (fast)
(defprotocol Renderable
  (render [this format])
  (mime-type [this]))

(defrecord HtmlPage [title body]
  Renderable
  (render [_ _] (str "<html><h1>" title "</h1>" body "</html>"))
  (mime-type [_] "text/html"))

;; Multimethods for value-based dispatch (flexible)
(defmulti process-event :type)

(defmethod process-event :user/created [{:keys [user-id email]}]
  (send-welcome-email email))

(defmethod process-event :order/placed [{:keys [order-id]}]
  (fulfill-order order-id))

(defmethod process-event :default [event]
  (log/warn "Unknown event type" (:type event)))
```

## Spec for Validation

```clojure
(require '[clojure.spec.alpha :as s])

(s/def ::email (s/and string? #(re-matches #".+@.+\..+" %)))
(s/def ::age (s/and int? #(< 0 % 150)))
(s/def ::user (s/keys :req-un [::email ::age]))

;; Validate at boundaries
(defn create-user [params]
  (if (s/valid? ::user params)
    (db/insert! :users params)
    (throw (ex-info "Invalid user" (s/explain-data ::user params)))))

;; Generative testing
(require '[clojure.spec.gen.alpha :as gen])
(gen/sample (s/gen ::user) 5)
```

## Macros

```clojure
;; Timing macro
(defmacro with-timing [label & body]
  `(let [start# (System/nanoTime)
         result# (do ~@body)
         ms# (/ (- (System/nanoTime) start#) 1e6)]
     (println (str ~label ": " ms# "ms"))
     result#))

;; Use: (with-timing "db-query" (db/fetch-all))

;; Retry macro with exponential backoff
(defmacro with-retry [n & body]
  `(loop [attempts# ~n]
     (let [result# (try {:ok (do ~@body)} (catch Exception e# {:err e#}))]
       (if (:ok result#)
         (:ok result#)
         (if (pos? attempts#)
           (do (Thread/sleep (* 100 (- ~n attempts#))) (recur (dec attempts#)))
           (throw (:err result#)))))))
```

## Concurrency: Atoms, Refs, Agents, core.async

```clojure
;; Atoms for independent synchronous state
(def counter (atom 0))
(swap! counter inc)
(swap! counter + 10)

;; Refs for coordinated transactions
(def account-a (ref 1000))
(def account-b (ref 500))
(dosync
  (alter account-a - 200)
  (alter account-b + 200))

;; Agents for asynchronous independent state
(def logger (agent []))
(send logger conj {:ts (System/currentTimeMillis) :msg "started"})

;; core.async channels
(require '[clojure.core.async :as a])
(let [ch (a/chan 10)]
  (a/go-loop []
    (when-let [msg (a/<! ch)]
      (process msg)
      (recur)))
  (a/>!! ch {:type :event :data "hello"}))

;; Pipeline for parallel processing
(let [in (a/chan 100) out (a/chan 100)]
  (a/pipeline 4 out (map expensive-transform) in)
  ;; feed `in`, consume `out`
  )
```

## Performance: Transients and Type Hints

```clojure
;; Transients for building large collections
(defn build-index [items]
  (persistent!
    (reduce (fn [acc item]
              (assoc! acc (:id item) item))
            (transient {})
            items)))

;; Type hints to avoid reflection
(defn fast-length [^String s]
  (.length s))

;; Check for reflection warnings
;; (set! *warn-on-reflection* true)
```

## Testing

```clojure
(ns myapp.core-test
  (:require [clojure.test :refer [deftest testing is are]]
            [myapp.core :as sut]))

(deftest total-qty-test
  (testing "sums item quantities"
    (is (= 3 (sut/total-qty {:items [{:qty 2} {:qty 1}]}))))
  (testing "returns 0 for empty items"
    (is (= 0 (sut/total-qty {:items []})))))

;; Fixtures for setup/teardown
(use-fixtures :each
  (fn [test-fn]
    (db/with-test-transaction
      (test-fn))))
```
