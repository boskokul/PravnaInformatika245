(deffunction collect-all-vars ($?condition)
	(bind $?result (create$))
	(bind ?end (length$ $?condition))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (is-var (nth$ ?n $?condition))
	   	   then
	   	   	(bind $?result (create$ $?result (nth$ ?n $?condition)))
	   	)
	)
	$?result
)


(deffunction create-slot-var-pairs ($?vars)
	(bind $?result (create$))
	(bind ?end (length$ $?vars))
	(loop-for-count (?n 1 ?end)
	   do
	   	(bind $?result (create$ $?result "(" (gensym) (nth$ ?n $?vars) ")"))
	)
	$?result
)




(deffunction unique-slot-patterns ($?slot-value-list)
	(bind $?slots (create$))
	(bind $?paths (create$))
	(while (> (length$ $?slot-value-list) 0)
	   do
	   	(bind ?p2 (get-token $?slot-value-list))
	   	(bind $?first-slot-value (subseq$ $?slot-value-list 1 ?p2))
	   	(bind $?slot-value-list (subseq$ $?slot-value-list (+ ?p2 1) (length$ $?slot-value-list)))
	   	(if (eq (nth$ 2 $?first-slot-value) "(")
	   	   then
	   	   	(bind $?current-path (subseq$ $?first-slot-value 2 (member$ ")" $?first-slot-value)))
	   	   	(if (> (length$ $?current-path) 3)
	   	   	   then
	   	   	   	;(bind $?test-paths (delete-member$ $?paths (create$ $?current-path)))
	   	   		(if (eq (delete-member$ $?paths (create$ $?current-path)) $?paths)
	   	   		   then
	   	   			(bind $?paths (create$ $?paths $?current-path))
	   	   		   else
	   	   		   	(return FALSE)
	   	   		)
	   	   	   else
	   	   	   	(bind ?current-slot (nth$ 2 $?current-path))
				(if (member$ ?current-slot $?slots)
				   then
					(return FALSE)
		   	   	   else
		   	   	   	(bind $?slots (create$ $?slots ?current-slot))
		   	   	)
			)
	   	   else
	   	   	(bind ?current-slot (nth$ 2 $?first-slot-value))
	   	   	(if (member$ ?current-slot $?slots)
	   	   	   then
	   	   	   	(return FALSE)
	   	   	   else
	   	   	   	(bind $?slots (create$ $?slots ?current-slot))
	   	   	)
	   	)
	)
	TRUE
)

(deffunction create-slot-vector (?var $?slot-names)
	(bind $?vector (create$))
	(bind ?end (length$ $?slot-names))
	(loop-for-count (?n 1 ?end)
	   do
	   	(bind $?vector (create$ $?vector "(" (nth$ ?n $?slot-names) (str-cat ?var "-" (gensym)) ")"))
	)
	$?vector
)

(deffunction find-class (?class $?path-before)
	(bind ?end (length$ $?path-before))
	(loop-for-count (?n 1 ?end)
	   do
	   	(bind ?class (get-type-of ?class (nth$ ?n $?path-before)))
	   	(if (eq ?class FALSE)
	   	   then
	   	   	(return FALSE)
	   	)
	)
	?class
)



(deffunction compatible-with-next (?slot ?class ?end-type $?path-after)
	(if (= (length$ $?path-after) 0)
	   then
	   	(if (eq ?end-type nil)
	   	   then
	   	   	TRUE
	   	   else
	   		(member$ ?end-type (slot-types ?class ?slot))
	   	)
	   else
	   	(bind ?next-class (get-type-of ?class ?slot))
	   	(if (neq ?next-class FALSE)
	   	   then
		   	(bind ?next-step (nth$ 1 $?path-after))
		   	(bind $?all-slots (user-slots ?next-class))
		   	(if (not (is-var ?next-step))
		   	   then
		   		(member$ ?next-step $?all-slots)
		   	   else
		   	   	(while (> (length$ $?all-slots) 0)
		   	   	   do
		   	   	   	(if (compatible-with-next (nth$ 1 $?all-slots) ?next-class ?end-type (rest$ $?path-after))
		   	   	   	   then
		   	   	   	   	(break)
		   	   	   	   else
		   	   	   	   	(bind $?all-slots (rest$ $?all-slots))
		   	   	   	)
		   	   	)
		   	   	(if (= (length$ $?all-slots) 0)
		   	   	   then
		   	   	   	FALSE
		   	   	   else
		   	   	   	TRUE
		   	   	)
		   	)
		   else
		   	FALSE
		)
	)
)

(deffunction collect-slot-names ($?slot-value-list)
	(bind $?result (create$))
	(while (> (length$ $?slot-value-list) 0)
	   do
		(bind ?p2 (get-token $?slot-value-list))
		;(bind $?first-slot-value (subseq$ $?slot-value-list 1 ?p2))
		(bind $?result (create$ $?result (nth$ 2 (subseq$ $?slot-value-list 1 ?p2))))
		(bind $?slot-value-list (subseq$ $?slot-value-list (+ ?p2 1) (length$ $?slot-value-list)))
	)
	$?result
)

(deffunction analyze-2nd-order (?rule)
	(bind $?r (my-explode$ ?rule))
	;(bind ?imp_pos (member$ => $?r))
	(bind $?condition (subseq$ $?r 1 (- (member$ => $?r) 1)))
	(bind $?copy-condition $?condition)
	(while (> (length$ $?copy-condition) 0)
	   do
		(bind ?p2 (get-token $?copy-condition))
		(bind $?orig-first-cond-elem (subseq$ $?copy-condition 1 ?p2))
		;(printout t "analyze-2nd-order: $?orig-first-cond-elem: " $?orig-first-cond-elem crlf)
		(bind $?copy-condition (subseq$ $?copy-condition (+ ?p2 1) (length$ $?copy-condition)))
		(while TRUE
		   do
		   	(if (eq (nth$ 2 $?orig-first-cond-elem) not)
		   	   then
		   	   	(bind $?orig-first-cond-elem (subseq$ $?orig-first-cond-elem 3 (- (length$ $?orig-first-cond-elem) 1)))
		   	)
			(if (or 
				(eq (nth$ 2 $?orig-first-cond-elem) or)
				(eq (nth$ 2 $?orig-first-cond-elem) and))
			   then
		   		(bind $?encaps-cond (subseq$ $?orig-first-cond-elem 3 (- (length$ $?orig-first-cond-elem) 1)))
		   		(bind ?p2 (get-token $?encaps-cond))
		   		(bind $?orig-first-cond-elem (subseq$ $?encaps-cond 1 ?p2))
		   		(bind $?copy-condition (create$ (subseq$ $?encaps-cond (+ ?p2 1) (length$ $?encaps-cond)) $?copy-condition))
		   	   else
		   	   	(break)
		   	)
		)
		(if (eq (nth$ 2 $?orig-first-cond-elem) <-)
		   then
		   	(bind $?first-cond-elem (subseq$ $?orig-first-cond-elem 3 (length$ $?orig-first-cond-elem)))
		   else
	   		(bind $?first-cond-elem $?orig-first-cond-elem)
		)
		(bind ?class-expr (nth$ 2 $?first-cond-elem))
		(bind ?pos (str-index / ?class-expr))
		(if (and (eq ?pos FALSE) (is-var ?class-expr))
		   then
		   	(return (create$ class ?class-expr (collect-slot-names (subseq$ $?first-cond-elem 3 (- (length$ $?first-cond-elem) 1)))))
		)
		(if (neq ?pos FALSE)
		   then
			(bind ?class (string-to-field (sub-string 1 (- ?pos 1) ?class-expr)))
			(bind ?namespace-expr (string-to-field (sub-string (+ ?pos 1) (str-length ?class-expr) ?class-expr)))
		)
		(if (and (neq ?pos FALSE) (is-var ?class) (not (is-var ?namespace-expr)))
		   then
		   	(return (create$ class-namespace ?class-expr (collect-slot-names (subseq$ $?first-cond-elem 3 (- (length$ $?first-cond-elem) 1)))))
		)
	   	(if (and (neq ?pos FALSE) (not (is-var ?class)) (is-var ?namespace-expr))
	   	   then
	   	   	(return (create$ namespace ?class-expr (collect-slot-names (subseq$ $?first-cond-elem 3 (- (length$ $?first-cond-elem) 1)))))
	   	)
	   	(if (and (neq ?pos FALSE) (is-var ?class) (is-var ?namespace-expr))
	   	   then
	   	   	(return (create$ var-class-namespace ?class-expr (collect-slot-names (subseq$ $?first-cond-elem 3 (- (length$ $?first-cond-elem) 1)))))
	   	)
		(bind $?slot-patterns (subseq$ $?first-cond-elem 3 (- (length$ $?first-cond-elem) 1)))
		(bind $?slot-names (collect-slot-names $?slot-patterns))
		;(printout t "analyze-2nd-order: $?slot-patterns: " $?slot-patterns crlf)
		;(printout t "analyze-2nd-order: $?slot-names: " $?slot-names crlf)
		(loop-for-count (?n 1 (length$ $?slot-names))
		   do
		   	(if (is-var (nth$ ?n $?slot-names))
		   	   then
		   	   	;(bind ?slot-var (nth$ ?n $?slot-names))
		   	   	;(bind $?rest-slot-names (delete$ $?slot-names ?n ?n))
		   	   	(return (create$ slot (nth$ ?n $?slot-names) ?class-expr (delete$ $?slot-names ?n ?n)))
		   	)
		   	(if (aliased-slot ?class-expr (nth$ ?n $?slot-names))
		   	   then
		   	   	;(bind ?slot-var (nth$ ?n $?slot-names))
		   	   	;(bind $?rest-slot-names (delete$ $?slot-names ?n ?n))
		   	   	(return (create$ aliased-slot (nth$ ?n $?slot-names) ?class-expr (delete$ $?slot-names ?n ?n)))
		   	)
	   	   	(if (eq (nth$ ?n $?slot-names) "(")
	   	   	   then
	   	   	   	(bind $?slot-pattern (get-nth-token ?n $?slot-patterns))
	   	   	   	(bind $?slot-pattern (subseq$ $?slot-pattern 2 (- (length$ $?slot-pattern) 1)))
	   	   	   	;(printout t "analyze-2nd-order: $?slot-pattern: " $?slot-pattern crlf)
	   	   	   	(bind ?right-pos (get-token $?slot-pattern))
	   	   	   	(bind $?path (subseq$ $?slot-pattern 2 (- ?right-pos 1)))
	   	   	   	;(printout t "analyze-2nd-order: $?path: " $?path crlf)
	   	   	   	(bind $?value-expr (subseq$ $?slot-pattern (+ ?right-pos 1) (length$ $?slot-pattern)))
	   	   	   	(if (and (= (length$ $?value-expr) 1) (not (is-var (nth$ 1 $?value-expr))))
	   	   	   	   then
	   	   	   	   	(bind ?end-type (type (nth$ 1 $?value-expr)))
	   	   	   	   else
	   	   	   	      	(if (or 
	   	   	   	      		(and (= (length$ $?value-expr) 1) (is-var (nth$ 1 $?value-expr)))
	   	   	   	      		(and (= (length$ $?value-expr) 3) (is-var (nth$ 2 $?value-expr))))
				    	   then
				    	   	(bind ?this-cond-elem-pos (subseq-pos (create$ $?orig-first-cond-elem $$$ $?condition)))
				    	   	(bind $?condition-to-check (create$ 
			    	   			(subseq$ $?condition 1 (- ?this-cond-elem-pos 1))
			    	   			(subseq$ $?condition (+ ?this-cond-elem-pos (length$ $?orig-first-cond-elem)) (length$ $?condition))))
			    	   		(if (and (= (length$ $?value-expr) 1) (is-var (nth$ 1 $?value-expr)))
			    	   		   then
			    	   		   	(bind ?value (nth$ 1 $?value-expr))
			    	   		   else
			    	   		   	(bind ?value (nth$ 2 $?value-expr))
			    	   		)
				    	   	(bind $?type (discover-type ?value $?condition-to-check))
				   	   	(if (= (length$ $?type) 0)
				   	   	   then
				   	   	   	(bind $?type (discover-ref-type ?value $?condition-to-check))
				   	   	)
				   	   	(if (= (length$ $?type) 0)
				   	   	   then
				   	   	   	(bind ?end-type nil)
				   	      	   else
				   	   	   	(bind ?end-type (nth$ 1 $?type))
	   	   	   	   	   	)
	   	   	   	   	   else
	   	   	   	   		(bind ?end-type nil)
	   	   	   	   	)
	   	   	   	)
	   	   	   	;(printout t "analyze-2nd-order: ?end-type: " ?end-type crlf)
	   	   	   	(bind $?r-path (inverse-brackets (reverse$ $?path)))
	   	   	   	(loop-for-count (?m 1 (length$ $?r-path))
	   	   	   	   do
	   	   	   	   	(if (is-var (nth$ ?m $?r-path))
	   	   	   	   	   then
	   	   	   	   	   	;(bind ?slot-var (nth$ ?m $?r-path))
	   	   	   	   	   	(return (create$ path (nth$ ?m $?r-path) ?end-type ?class-expr $?r-path $$$ $?slot-patterns))
	   	   	   	   	)
   	   	   	   	   	(if (eq (nth$ ?m $?r-path) +)
   	   	   	   	   	   then
   	   	   	   	   	   	(return (create$ short-path ?class-expr (reverse$ $?r-path)))
   	   	   	   	   	)
   	   	   	   		(if (eq (nth$ ?m $?r-path) "(")
   	   	   	   		   then
   	   	   	   		   	;(bind ?right-pos (member ")" $?r-path))
   	   	   	   		   	;(bind $?rec-path (subseq$ $?r-path (+ ?m 1) (- (member ")" $?r-path) 1)))
   	   	   	   			(return (create$ rec-path ?class-expr (reverse$ (subseq$ $?r-path (+ ?m 1) (- (member ")" $?r-path) 1))) $$$ (inverse-brackets (reverse$ $?r-path))))
   	   	   	   		)
	   	   	   	)
	   	   	)
		)
	)
)

(deffunction translate-2nd-order-rule-class (?ntm-status ?rule-name ?rule $?aux-data)
	(bind $?r (my-explode$ ?rule))
	(bind ?imp_pos (member$ => $?r))
	(bind $?condition (subseq$ $?r 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?r (+ ?imp_pos 1) (length$ $?r)))
	;(bind $?all-classes (get-defclass-list))
	(bind $?all-classes (class-subclasses TYPED-CLASS inherit))
	(if (class-existp RDF-CLASS)
	   then
	   	(bind $?all-classes (create$ $?all-classes (class-subclasses RDF-CLASS inherit)))
	)
	(bind $?all-classes (delete-member$ (remove-duplicates$ $?all-classes) DERIVED-CLASS))
	(bind ?class-var (nth$ 1 $?aux-data))
	(bind $?class-slots1 (subseq$ $?aux-data 2 (length$ $?aux-data)))
	(bind $?class-slots (remove-vars $?class-slots1))
	(if (= (length$ $?class-slots) 0)
	   then
	   	(bind ?new-class (discover-class-of-var ?class-var $?condition))
	   	(if (neq ?new-class ?class-var)
	   	   then
	   	   	(bind $?all-classes (create$ ?new-class))
	   	)
	)
	(if (> (length$ $?class-slots) 0)
	   then
		(bind $?candidate-classes (create$))
		(while (> (length$ $?all-classes) 0)
		   do
		   	(bind ?actual-class (nth$ 1 $?all-classes))
		   	(bind $?actual-class-slots (class-slots ?actual-class inherit))
			(if (subsetp $?class-slots $?actual-class-slots)
			   then
				(bind $?candidate-classes (create$ $?candidate-classes ?actual-class))
		   	)
		   	(bind $?all-classes (rest$ $?all-classes))
		)
	   else
	   	(bind $?candidate-classes $?all-classes)
	)
	(if (and 
		(not (double-member$ ?class-var $?condition))
		(not (member$ ?class-var $?conclusion)))
	   then
		(bind $?candidate-classes (remove-subsumed-classes $?candidate-classes))
	)
	(bind ?end (length$ $?candidate-classes))
	(loop-for-count (?n 1 ?end)
	   do
	   	(bind $?new-condition (replace-member$ $?condition (nth$ ?n $?candidate-classes) ?class-var))
	   	;(if (test-2nd-order-conditions $?new-condition)
	   	;   then
	   	(bind $?new-conclusion (replace-member$ $?conclusion (nth$ ?n $?candidate-classes) ?class-var))
	   	(bind $?nr (create$ $?new-condition => $?new-conclusion))
	   	(bind ?new-rule (str-cat$ (create$ (str-cat ?rule-name ?n) $?nr)))
	   	(if (eq ?ntm-status yes)
	   	   then
	   		(assert (deductiverule ?new-rule))
	   	   else
	   	   	(assert (ntm-deductiverule ?new-rule))
	   	)
	   	(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
	   	;)
	)
)

(deffunction translate-2nd-order-rule-class-namespace (?ntm-status ?rule-name ?rule $?aux-data)
	(bind $?r (my-explode$ ?rule))
	(bind ?imp_pos (member$ => $?r))
	(bind $?condition (subseq$ $?r 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?r (+ ?imp_pos 1) (length$ $?r)))
	(bind ?class-namespace (nth$ 1 $?aux-data))
	(bind ?pos (str-index / ?class-namespace))
	(bind ?class-var (string-to-field (sub-string 1 (- ?pos 1) ?class-namespace)))
	(bind $?class-slots (subseq$ $?aux-data 2 (length$ $?aux-data)))
	(bind ?namespace (string-to-field (sub-string (+ ?pos 1) (str-length ?class-namespace) ?class-namespace)))
	 (bind ?namespace-index (symbol-to-instance-name ?namespace))
	(bind $?all-classes (send ?namespace-index get-classes))
	(while (> (length$ $?all-classes) 0)
	   do
	   	(bind ?class-prefix (nth$ 1 $?all-classes))
	   	(bind ?actual-class (string-to-field (str-cat ?class-prefix / ?namespace)))
		(if (subsetp $?class-slots (class-slots ?actual-class inherit))
		   then
	   		(bind ?new-rule (str-cat ?rule-name (length$ $?all-classes) " " (str-replace ?rule ?class-prefix ?class-var)))
		   	(if (eq ?ntm-status yes)
		   	   then
	   			(assert (deductiverule ?new-rule))
		   	   else
		   	   	(assert (ntm-deductiverule ?new-rule))
		   	)
		   	(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
	   	)
	   	(bind $?all-classes (rest$ $?all-classes))
	)
)

(deffunction translate-2nd-order-rule-namespace (?ntm-status ?rule-name ?rule $?aux-data)
	(bind $?r (my-explode$ ?rule))
	(bind ?imp_pos (member$ => $?r))
	(bind $?condition (subseq$ $?r 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?r (+ ?imp_pos 1) (length$ $?r)))
	(bind ?class-namespace (nth$ 1 $?aux-data))
	(bind ?pos (str-index / ?class-namespace))
	(bind ?class (string-to-field (sub-string 1 (- ?pos 1) ?class-namespace)))
	(bind $?class-slots (subseq$ $?aux-data 2 (length$ $?aux-data)))
	(bind ?namespace-var (string-to-field (sub-string (+ ?pos 1) (str-length ?class-namespace) ?class-namespace)))
	(bind ?counter 1)
	(do-for-all-instances 
		((?namespace-inst namespace))
		(member$ ?class ?namespace-inst:classes)
		(bind ?actual-namespace (instance-name-to-symbol ?namespace-inst))
		(bind ?actual-class (string-to-field (str-cat ?class / ?actual-namespace)))
		(if (subsetp $?class-slots (class-slots ?actual-class inherit))
		   then
   	  		(bind ?new-rule (str-replace ?rule ?actual-namespace ?namespace-var))
   	  		(if (eq ?ntm-status yes)
			   then
				(assert (deductiverule (str-cat ?rule-name ?counter " " ?new-rule)))
			   else
				(assert (ntm-deductiverule (str-cat ?rule-name ?counter " " ?new-rule)))
			)
			(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
			(bind ?counter (+ ?counter 1))
   		)
   	)
)

(deffunction translate-2nd-order-rule-var-class-namespace (?ntm-status ?rule-name ?rule $?aux-data)
	(bind $?r (my-explode$ ?rule))
	(bind ?imp_pos (member$ => $?r))
	(bind $?condition (subseq$ $?r 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?r (+ ?imp_pos 1) (length$ $?r)))
	(bind ?class-namespace (nth$ 1 $?aux-data))
	(bind ?pos (str-index / ?class-namespace))
	(bind ?class-var (string-to-field (sub-string 1 (- ?pos 1) ?class-namespace)))
	(bind $?class-slots (subseq$ $?aux-data 2 (length$ $?aux-data)))
	(bind ?namespace-var (string-to-field (sub-string (+ ?pos 1) (str-length ?class-namespace) ?class-namespace)))
	(bind ?counter 1)
	(do-for-all-instances 
		((?namespace-inst namespace))
		TRUE
		(bind ?actual-namespace (instance-name-to-symbol ?namespace-inst))
		(bind $?all-classes ?namespace-inst:classes)
	  	(while (> (length$ $?all-classes) 0)
	  	   do
	  	   	(bind ?class-prefix (nth$ 1 $?all-classes))
	  		(bind ?actual-class (string-to-field (str-cat ?class-prefix / ?actual-namespace)))
			(if (subsetp $?class-slots (class-slots ?actual-class inherit))
			   then
	  			(bind ?new-rule1 (str-replace ?rule ?actual-namespace ?namespace-var))
	  			(bind ?new-rule (str-replace ?new-rule1 ?class-prefix ?class-var))
	  			(if (eq ?ntm-status yes)
				   then
	  				(assert (deductiverule (str-cat ?rule-name ?counter "-" (length$ $?all-classes) " " ?new-rule)))
	  			   else
	  			   	(assert (ntm-deductiverule (str-cat ?rule-name ?counter "-" (length$ $?all-classes) " " ?new-rule)))
	  			)
		   		(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
		   		(bind ?counter (+ ?counter 1))
	  		)
	  		(bind $?all-classes (rest$ $?all-classes))
	  	)
   	)
)

(deffunction translate-2nd-order-rule-slot (?ntm-status ?rule-name ?rule $?aux-data)
	(bind $?r (my-explode$ ?rule))
	(bind ?imp_pos (member$ => $?r))
	(bind $?condition (subseq$ $?r 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?r (+ ?imp_pos 1) (length$ $?r)))
	(bind ?slot-var (nth$ 1 $?aux-data))
	(bind ?class (nth$ 2 $?aux-data))
	(bind $?rest-slots (subseq$ $?aux-data 3 (length$ $?aux-data)))
	(bind $?all-slots (user-slots ?class))
	(if (is-singlevar ?slot-var)
	   then
		(while (> (length$ $?all-slots) 0)
		   do
		   	(bind ?actual-slot (nth$ 1 $?all-slots))
		   	(if (not (member$ ?actual-slot $?rest-slots))
		   		;; Here another optimization can be performed!
		   		;; Check the type of the value expression (var or constant)
		   		;; and check the type of the ?actual-slot. If they are not
		   		;; compatible (e.g. STRING vs. INTEGER) then reject ?actual-slot
		   	   then
		   	   	(bind $?new-condition (replace-member$ $?condition ?actual-slot ?slot-var))
				(bind $?new-conclusion (replace-member$ $?conclusion ?actual-slot ?slot-var))
				(bind $?nr (create$ $?new-condition => $?new-conclusion))
				(bind ?new-rule (str-cat$ $?nr))
				(debug "New rule: " ?new-rule crlf)
				(if (eq ?ntm-status yes)
				   then
					(assert (deductiverule (str-cat ?rule-name (length$ $?all-slots) " " ?new-rule)))
				   else
				   	(assert (ntm-deductiverule (str-cat ?rule-name (length$ $?all-slots) " " ?new-rule)))
				)
				(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
			)
			(bind $?all-slots (rest$ $?all-slots))
		)
	   else
	   	(bind $?replacing-slots (create$))
	   	(while (> (length$ $?all-slots) 0)
		   do
		   	(bind ?actual-slot (nth$ 1 $?all-slots))
		   	(if (not (member$ ?actual-slot $?rest-slots))
		   	   then
		   	   	(bind $?replacing-slots (create$ $?replacing-slots ?actual-slot))
			)
			(bind $?all-slots (rest$ $?all-slots))
		)
		(bind ?slot-pos (member$ ?slot-var $?condition))
		(bind ?slot-value-var (nth$ (+ ?slot-pos 1) $?condition))
		(bind $?slot-vector (create-slot-vector ?slot-value-var $?replacing-slots))
		(bind $?new-condition (replace-member$ $?condition $?slot-vector (create$ "(" ?slot-var ?slot-value-var ")")))
		(bind $?new-conclusion (replace-member$ $?conclusion $?slot-vector (create$ "(" ?slot-var ?slot-value-var ")")))
		(bind $?nr (create$ $?new-condition => $?new-conclusion))
		(bind ?new-rule (str-cat$ $?nr))
		(if (eq ?ntm-status yes)
		   then
			(assert (deductiverule (str-cat ?rule-name ?new-rule)))
		   else
		   	(assert (ntm-deductiverule (str-cat ?rule-name ?new-rule)))
		)
		(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
	)
)

(deffunction translate-2nd-order-rule-aliased-slot (?ntm-status ?rule-name ?rule $?aux-data)
	(bind $?r (my-explode$ ?rule))
	(bind ?imp_pos (member$ => $?r))
	(bind $?condition (subseq$ $?r 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?r (+ ?imp_pos 1) (length$ $?r)))
	(bind ?aliased-slot (nth$ 1 $?aux-data))
	(bind ?class (nth$ 2 $?aux-data))
	(bind $?rest-slots (subseq$ $?aux-data 3 (length$ $?aux-data)))
	(bind $?all-slots (aliases-of ?class ?aliased-slot))
	(while (> (length$ $?all-slots) 0)
	   do
	   	(bind ?actual-slot (nth$ 1 $?all-slots))
	   	(if (not (member$ ?actual-slot $?rest-slots))
	   	   then
	   	   	(bind $?new-condition (replace-member$ $?condition ?actual-slot ?aliased-slot))
			;(bind $?new-conclusion (replace-member$ $?conclusion ?actual-slot ?slot-var))
			(bind $?nr (create$ $?new-condition => $?conclusion))
			(bind ?new-rule (str-cat$ $?nr))
			(debug "New rule: " ?new-rule crlf)
			(if (eq ?ntm-status yes)
			   then
				(assert (deductiverule (str-cat ?rule-name (length$ $?all-slots) " " ?new-rule)))
			   else
			   	(assert (ntm-deductiverule (str-cat ?rule-name (length$ $?all-slots) " " ?new-rule)))
			)
			(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
		)
		(bind $?all-slots (rest$ $?all-slots))
	)
)


(deffunction translate-2nd-order-rule-path (?ntm-status ?rule-name ?rule $?aux-data)
	(bind $?r (my-explode$ ?rule))
	(bind ?imp_pos (member$ => $?r))
	(bind $?condition (subseq$ $?r 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?r (+ ?imp_pos 1) (length$ $?r)))
	(bind ?slot-var (nth$ 1 $?aux-data))
	;(printout t "translate-2nd-order-rule-path: ?slot-var: " ?slot-var crlf)
	(bind ?end-type (nth$ 2 $?aux-data))
	(bind ?class (nth$ 3 $?aux-data))
	(bind $?path-and-slot-patterns (subseq$ $?aux-data 4 (length$ $?aux-data)))
	(bind $?path (subseq$ $?path-and-slot-patterns 1 (- (member$ $$$ $?path-and-slot-patterns) 1)))
	(bind $?slot-patterns (subseq$ $?path-and-slot-patterns (+ (member$ $$$ $?path-and-slot-patterns) 1) (length$ $?path-and-slot-patterns)))
	(bind $?path-before (subseq$ $?path 1 (- (member$ ?slot-var $?path) 1)))
	(bind $?path-after (subseq$ $?path (+ (member$ ?slot-var $?path) 1) (length$ $?path)))
	(if (is-singlevar ?slot-var)
	   then
	   	(bind ?search-class (find-class ?class $?path-before))
	   	(if (neq ?search-class FALSE)
	   	   then
			(bind $?all-slots (user-slots ?search-class))
			(while (> (length$ $?all-slots) 0)
			   do
			   	(bind ?actual-slot (nth$ 1 $?all-slots))
			   	(if (and 
			   		(compatible-with-next ?actual-slot ?search-class ?end-type $?path-after)
			   		(unique-slot-patterns (replace-member$ $?slot-patterns ?actual-slot ?slot-var)))
			   	   then
			   	   	;(bind $?new-condition (replace-member$ $?condition ?actual-slot ?slot-var))
					;(bind $?new-conclusion (replace-member$ $?conclusion ?actual-slot ?slot-var))
					(bind ?new-rule (str-cat$ (create$ 
						(replace-member$ $?condition ?actual-slot ?slot-var) 
						=> 
						(replace-member$ $?conclusion ?actual-slot ?slot-var)
					)))
					(if (eq ?ntm-status yes)
					   then
						(assert (deductiverule (str-cat ?rule-name (length$ $?all-slots) " " ?new-rule)))
					   else
					   	(assert (ntm-deductiverule (str-cat ?rule-name (length$ $?all-slots) " " ?new-rule)))
					)
					(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
				)
				(bind $?all-slots (rest$ $?all-slots))
			)
		)
	   else
	   	;(printout t "translate-2nd-order-rule-path: $?path-before: " $?path-before crlf)
	   	;(printout t "translate-2nd-order-rule-path: $?path-after: " $?path-after crlf)
	   	(if (> (length$ $?path-before) 0)
	   	   then
	   		(bind ?search-class (find-class ?class (subseq$ $?path-before 1 (- (length$ $?path-before) 1))))
			(bind ?actual-slot (nth$ (length$ $?path-before) $?path-before))
	   		(if (and 
	   			(neq ?search-class FALSE)
				(compatible-with-next ?actual-slot ?search-class ?end-type $?path-after)
				(unique-slot-patterns (delete-member$ $?slot-patterns ?slot-var)))
			   then
			   	;(bind $?new-condition (delete-member$ $?condition ?slot-var))
				;(bind $?new-conclusion (delete-member$ $?conclusion ?slot-var))
				(bind ?new-rule (str-cat$ (create$ 
					(delete-member$ $?condition ?slot-var) 
					=> 
					(delete-member$ $?conclusion ?slot-var)
				)))
				(debug "new-rule: " ?new-rule crlf)
				(if (eq ?ntm-status yes)
				   then
					(assert (deductiverule (str-cat ?rule-name 0 " " ?new-rule)))
				   else
				   	(assert (ntm-deductiverule (str-cat ?rule-name 0 " " ?new-rule)))
				)
			   	(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
			)
		   else
	   		(if (> (length$ $?path-after) 0)
			   then
				(bind ?next-step (nth$ 1 $?path-after))
				(bind $?all-slots (user-slots ?class))
				(if (or
					(and 
						(not (is-var ?next-step)) 
						(member$ ?next-step $?all-slots)
			   			(unique-slot-patterns (delete-member$ $?slot-patterns ?slot-var)))
			   		(is-var ?next-step))
			   	   then
			   		   ;(bind $?new-condition (delete-member$ $?condition ?slot-var))
					   ;(bind $?new-conclusion (delete-member$ $?conclusion ?slot-var))
					   (bind ?new-rule (str-cat$ (create$ 
					   	(delete-member$ $?condition ?slot-var) 
					   	=> 
					   	(delete-member$ $?conclusion ?slot-var)
					   )))
					   (debug "new-rule: " ?new-rule crlf)
					   (if (eq ?ntm-status yes)
					      then
					   	(assert (deductiverule (str-cat ?rule-name 0 " " ?new-rule)))
					      else
					      	(assert (ntm-deductiverule (str-cat ?rule-name 0 " " ?new-rule)))
					   )
					   (bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
				)
			)
		)
	   	(bind $?list-of-paths (create$ "(" ")" ))
	   	(bind $?list-of-recursive-paths (create$))
	   	(while (> (length$ $?list-of-paths) 0)
	   	   do
	   		(bind ?p2 (get-token $?list-of-paths))
			(bind $?first-path (subseq$ $?list-of-paths 1 ?p2))
			(bind $?list-of-paths (subseq$ $?list-of-paths (+ ?p2 1) (length$ $?list-of-paths)))
			(bind $?actual-path (subseq$ $?first-path 2 (- (length$ $?first-path) 1)))
	   		(bind ?search-class (find-class ?class (create$ $?path-before $?actual-path)))
	   		(if (neq ?search-class FALSE)
	   		   then
				(bind $?all-slots (user-slots ?search-class))
				(while (> (length$ $?all-slots) 0)
				   do
				   	(bind ?actual-slot (nth$ 1 $?all-slots))
				   	(if (not (member$ ?actual-slot $?actual-path))
				   	   then
				   		(bind $?r-actual-next-path (create$ $?actual-path ?actual-slot))
				   		(bind $?actual-next-path (reverse$ $?r-actual-next-path))
				   		(if (and 
				   			(compatible-with-next ?actual-slot ?search-class ?end-type $?path-after)
				   			(unique-slot-patterns (replace-member$ $?slot-patterns (create$ $?actual-next-path) ?slot-var)))
				   		   then
				   		   	;(bind $?new-condition (replace-member$ $?condition (create$ $?actual-next-path) ?slot-var))
							;(bind $?new-conclusion (replace-member$ $?conclusion (create$ $?actual-next-path) ?slot-var))
							(bind ?new-rule (str-cat$ (create$ 
								(replace-member$ $?condition (create$ $?actual-next-path) ?slot-var) 
								=> 
								(replace-member$ $?conclusion (create$ $?actual-next-path) ?slot-var)
							)))
							(debug "new-rule: " ?new-rule crlf)
							(if (eq ?ntm-status yes)
							   then
								(assert (deductiverule (str-cat ?rule-name (length$ $?list-of-paths) "-" (length$ $?all-slots) " " ?new-rule)))
							   else
							   	(assert (ntm-deductiverule (str-cat ?rule-name (length$ $?list-of-paths) "-" (length$ $?all-slots) " " ?new-rule)))
							)
							(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
						)
						(bind $?list-of-paths (create$ $?list-of-paths "(" $?r-actual-next-path ")"))
					   else
					   	;(bind ?pos (member$ ?actual-slot $?actual-path))
					   	;(bind $?recursive-actual-path (create$ (insert$ $?actual-path (member$ ?actual-slot $?actual-path) "(") ")"))
					   	(bind $?list-of-recursive-paths (create$ $?list-of-recursive-paths "(" (insert$ $?actual-path (member$ ?actual-slot $?actual-path) "(") ")" ")"))
					)
					(bind $?all-slots (rest$ $?all-slots))
				)
			)
		)
	   	;(printout t "translate-2nd-order-rule-path: $?list-of-paths: " $?list-of-paths crlf)
	   	;(printout t "translate-2nd-order-rule-path: $?list-of-recursive-paths: " $?list-of-recursive-paths crlf)
	   	(while (> (length$ $?list-of-recursive-paths) 0)
	   	   do
	   		(bind ?p2 (get-token $?list-of-recursive-paths))
			(bind $?first-path (subseq$ $?list-of-recursive-paths 1 ?p2))
			(bind $?list-of-recursive-paths (subseq$ $?list-of-recursive-paths (+ ?p2 1) (length$ $?list-of-recursive-paths)))
			(bind $?r-actual-path (subseq$ $?first-path 2 (- (length$ $?first-path) 1)))
	   		(bind $?actual-path (inverse-brackets (reverse$ $?r-actual-path)))
	   		; The following lines delete linear rules inserted by the first iteration
	   		(bind ?l-pos (member$ "(" $?actual-path))
			(bind ?r-pos (member$ ")" $?actual-path))
			(bind $?rec-path (subseq$ $?actual-path (+ ?l-pos 1) (- ?r-pos 1)))
			(bind $?l-path (subseq$ $?actual-path 1 (- ?l-pos 1)))
			;(printout t "l-path: " $?l-path crlf)
			;(printout t "path-after: " $?path-after crlf)
			;(bind $?l-path (create$ $?path-after (subseq$ $?actual-path 1 (- ?l-pos 1))))
			;(bind $?r-path (subseq$ $?actual-path (+ ?r-pos 1) (length$ $?actual-path)))
			(loop-for-count (?n 1 (length$ $?rec-path))
			   do
			   	(bind $?delete-path (create$ $?l-path (subseq$ $?rec-path 1 ?n)))
				;(bind $?del-condition (replace-member$ $?condition (create$ $?delete-path) ?slot-var))
				;(bind $?del-conclusion (replace-member$ $?conclusion (create$ $?delete-path) ?slot-var))
				(bind ?del-rule (str-cat$ (create$ 
					(replace-member$ $?condition (create$ $?delete-path) ?slot-var) 
					=> 
					(replace-member$ $?conclusion (create$ $?delete-path) ?slot-var)
				)))
				(loop-for-count (?CHECK1 1 100)
				   do
					(loop-for-count (?CHECK2 1 100)
					   do
						(bind $?del-rule-indices (get-specific-facts deductiverule implied (create$ (str-cat ?rule-name ?CHECK1 "-" ?CHECK2 " " ?del-rule))))
						(if (> (length$ $?del-rule-indices) 0)
						   then
						   	(debug "Retracting rule: " ?del-rule crlf)
							(retract (nth$ 1 $?del-rule-indices))
						)
					)
				)
			)
			(bind $?total-path (create$ $?path-before (delete-member$ $?r-actual-path "(" ")")))
			(bind ?search-class (find-class ?class (subseq$ $?total-path 1 (- (length$ $?total-path) 1))))
			(bind ?actual-slot (nth$ (length$ $?total-path) $?total-path))
			(if (and 
				(neq ?search-class FALSE)
				(compatible-with-next ?actual-slot ?search-class ?end-type $?path-after))
			   then
				(bind ?pos (member$ ?slot-var $?condition))
				(bind ?left-bracket-pos (- ?pos (member$ "(" (reverse$ (subseq$ $?condition 1 ?pos)))))
				(bind $?condition-before (subseq$ $?condition 1 (- ?left-bracket-pos 1)))
				(bind $?condition-after (subseq$ $?condition ?pos (length$ $?condition)))
				;(bind ?right-bracket-pos1 (member$ ")" $?condition-after))
				(bind $?condition-after (subseq$ $?condition-after (+ (member$ ")" $?condition-after) 1) (length$ $?condition-after)))
				(bind ?right-bracket-pos2 (member$ ")" $?condition-after))
				(bind $?predicate (subseq$ $?condition-after 1 (- ?right-bracket-pos2 1)))
				(bind $?condition-after (subseq$ $?condition-after (+ ?right-bracket-pos2 2) (length$ $?condition-after)))
				;(bind $?all-vars (collect-all-vars $?condition-before))
				(bind $?copy-vars (create-slot-var-pairs (collect-all-vars $?condition-before)))
				(bind ?temp-class-name (gensym*))
				(bind ?temp-var1 (str-cat "?" (gensym)))
				(bind ?temp-var2 (str-cat "?" (gensym)))
				;(bind ?l-pos (member$ "(" $?actual-path))
				;(bind ?l-pos 1)
				;(bind ?r-pos (member$ ")" $?actual-path))
				(bind $?l-path (create$ $?path-after (subseq$ $?actual-path 1 (- ?l-pos 1))))
				;(printout t "l-path: " $?l-path crlf)
				;(bind $?l-path $?path-after)
				;(bind $?rec-path (subseq$ $?actual-path (+ ?l-pos 1) (- ?r-pos 1)))
				(bind $?r-path (subseq$ $?actual-path (+ ?r-pos 1) (length$ $?actual-path)))
				(bind ?last-rec-class (find-class ?class (reverse$ (create$ (nth$ (length$ $?rec-path) $?rec-path) $?r-path))))
				(if (eq ?last-rec-class FALSE)
				   then
				   	(bind ?last-rec-class "?")
				)	   
				(bind ?first-rec-class (find-class ?class (reverse$ (create$ (rest$ $?rec-path) $?r-path))))
				(if (is-multislot ?first-rec-class (nth$ 1 $?rec-path))
				   then
				   	(bind $?temp-var-expr1 (create$ "$?" ?temp-var1 "$?"))
				   	(bind $?temp-var-expr2 (create$ "$?" ?temp-var2 "$?"))
				   else
				   	(bind $?temp-var-expr1 (create$ ?temp-var1))
				   	(bind $?temp-var-expr2 (create$ ?temp-var2))
				)
				               ;(nth$ (length$ $?rec-path) $?rec-path))
				(if (> (length$ (create$ $?rec-path $?r-path)) 1)
				   then
					(bind $?temp-path1 (create$ "(" $?rec-path $?r-path ")"))
				   else
				   	(bind $?temp-path1 (create$ $?rec-path $?r-path))
				)
				(bind ?new-rule1 (str-cat$ (create$
					$?condition-before "(" $?temp-path1  $?temp-var-expr1 ")" ")"
					=>
					"(" ?temp-class-name $?copy-vars "(" cnd_obj ?temp-var1 ")" ")"
				)))
				(if (> (length$ $?rec-path) 1)
				   then
					(bind $?temp-path2 (create$ "(" $?rec-path ")"))
				   else
				   	(bind $?temp-path2 $?rec-path)
				)
				(bind ?new-rule2 (str-cat$ (create$
					?temp-var1 <- "(" ?last-rec-class "(" $?temp-path2 $?temp-var-expr2 ")" ")"
					"(" ?temp-class-name $?copy-vars "(" cnd_obj ?temp-var1 ")" ")"
					=>
					"(" ?temp-class-name $?copy-vars "(" cnd_obj ?temp-var2 ")" ")"
				)))
				(bind ?new-rule3 (str-cat$ (create$
					"(" ?temp-class-name $?copy-vars "(" "(" $?l-path cnd_obj ")" $?predicate ")" ")"
					$?condition-after
					=>
					$?conclusion
				)))
				(debug "new-rule1: " ?new-rule1 crlf)
				(debug "new-rule2: " ?new-rule2 crlf)
				(debug "new-rule3: " ?new-rule3 crlf)
				(if (eq ?ntm-status yes)
				   then
					(assert (deductiverule (str-cat ?rule-name "1-" (length$ $?list-of-recursive-paths) " " ?new-rule1)))
					(assert (deductiverule (str-cat ?rule-name "2-" (length$ $?list-of-recursive-paths) " " ?new-rule2)))
					(assert (deductiverule (str-cat ?rule-name "3-" (length$ $?list-of-recursive-paths) " " ?new-rule3)))
				   else
				   	(assert (ntm-deductiverule (str-cat ?rule-name "1-" (length$ $?list-of-recursive-paths) " " ?new-rule1)))
					(assert (ntm-deductiverule (str-cat ?rule-name "2-" (length$ $?list-of-recursive-paths) " " ?new-rule2)))
					(assert (ntm-deductiverule (str-cat ?rule-name "3-" (length$ $?list-of-recursive-paths) " " ?new-rule3)))
				)
				(bind ?*untranslated_rules* (+ ?*untranslated_rules* 3))
			)
			;(bind $?actual-path (delete-member$ $?first-path "(" ")"))
	   		(bind ?search-class (find-class ?class (create$ $?path-before (delete-member$ $?actual-path "(" ")"))))
	   		(if (neq ?search-class FALSE)
	   		   then
				(bind $?all-slots (user-slots ?search-class))
				(while (> (length$ $?all-slots) 0)
				   do
				   	(bind ?actual-slot (nth$ 1 $?all-slots))
				   	(if (not (member$ ?actual-slot $?actual-path))
				   	   then
				   		;(bind $?r-actual-next-path (create$ $?actual-path ?actual-slot))
				   		;several lines have moved to not-used-functions.clp
						(bind $?list-of-recursive-paths (create$ $?list-of-recursive-paths "(" $?actual-path ?actual-slot ")"))
					)
					(bind $?all-slots (rest$ $?all-slots))
				)
			)
		)
	)
	;(release-mem)
)


(deffunction translate-2nd-order-rule-rec-path (?ntm-status ?rule-name ?rule $?aux-data)
	;(printout t "translate-2nd-order-rule-rec-path: ?rule-name: " ?rule-name crlf)
	;(printout t "translate-2nd-order-rule-rec-path: ?rule: " ?rule crlf)
	;(printout t "translate-2nd-order-rule-rec-path: $?aux-data: " $?aux-data crlf)
	(bind $?r (my-explode$ ?rule))
	(bind ?imp_pos (member$ => $?r))
	(bind $?condition (subseq$ $?r 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?r (+ ?imp_pos 1) (length$ $?r)))
	(bind ?class (nth$ 1 $?aux-data))
	(bind $?path-and-rec-path (subseq$ $?aux-data 2 (length$ $?aux-data)))
	(bind ?pos (member$ $$$ $?path-and-rec-path))
	(bind $?rec-path (subseq$ $?path-and-rec-path 1 (- ?pos 1)))
	(bind $?path (subseq$ $?path-and-rec-path (+ ?pos 1) (length$ $?path-and-rec-path)))
	(bind ?left-bracket-pos (- (subseq-pos (create$ $?path $$$ $?condition)) 2))
	(bind $?condition-before (subseq$ $?condition 1 (- ?left-bracket-pos 1)))
	(bind $?condition-after (subseq$ $?condition (+ ?left-bracket-pos (length$ $?path) 2) (length$ $?condition)))
	;(bind ?right-bracket-pos1 (member$ ")" $?condition-after))
	(bind $?condition-after (subseq$ $?condition-after (+ (member$ ")" $?condition-after) 1) (length$ $?condition-after)))
	(bind ?right-bracket-pos2 (member$ ")" $?condition-after))
	(bind $?predicate (subseq$ $?condition-after 1 (- ?right-bracket-pos2 1)))
	(bind $?condition-after (subseq$ $?condition-after (+ ?right-bracket-pos2 2) (length$ $?condition-after)))
	;(printout t "Before" crlf)
	;(printout t "translate-2nd-order-rule-rec-path: $?condition-before " $?condition-before crlf)
	;(printout t "translate-2nd-order-rule-rec-path: $?condition-after " $?condition-after crlf)
	; Case where in the cond element with the recursive item there are other slot-patterns after the recursive path
	(if (and (> (length$ $?condition-after) 0)
		 (not (or (eq (nth$ 1 $?condition-after) "(") 
		     	  (and (eq (nth$ 2 $?condition-after) "<-") 
		     	       (eq (nth$ 3 $?condition-after) "(")))))
	   then
	   	;(printout t "I'm in!" crlf)
	   	(bind ?cut-pos (- (get-token (create$ "(" "(" $?condition-after)) 2))
	   	(bind $?cut-from-after (subseq$ $?condition-after 1 ?cut-pos))
	   	(bind $?condition-after (subseq$ $?condition-after (+ ?cut-pos 1) (length$ $?condition-after)))
	   	(bind $?condition-before (create$ $?condition-before "(" (subseq$ $?cut-from-after 1 (- (length$ $?cut-from-after) 1))))
	)
	;(printout t "After" crlf)
	;(printout t "translate-2nd-order-rule-rec-path: $?condition-before " $?condition-before crlf)
	;(printout t "translate-2nd-order-rule-rec-path: $?condition-after " $?condition-after crlf)
	;(bind $?all-vars (collect-all-vars $?condition-before))
	(bind $?copy-vars (create-slot-var-pairs (collect-all-vars $?condition-before)))
	(bind ?temp-class-name (gensym*))
	(bind ?temp-var1 (str-cat "?" (gensym)))
	(bind ?temp-var2 (str-cat "?" (gensym)))
	;(bind ?l-pos (member$ "(" $?path))
	;(bind ?r-pos (member$ ")" $?path))
	(bind $?l-path (subseq$ $?path 1 (- (member$ "(" $?path) 1)))
	(bind $?r-path (subseq$ $?path (+ (member$ ")" $?path) 1) (length$ $?path)))
	(bind ?last-rec-class (find-class ?class (reverse$ (create$ (nth$ (length$ $?rec-path) $?rec-path) $?r-path))))
	(if (eq ?last-rec-class FALSE)
	   then
	   	(bind ?last-rec-class "?")
	)	   
	(bind ?first-rec-class (find-class ?class (reverse$ (create$ (rest$ $?rec-path) $?r-path))))
	(if (is-multislot ?first-rec-class (nth$ 1 $?rec-path))
	   then
	   	(bind $?temp-var-expr1 (create$ "$?" ?temp-var1 "$?"))
	   	(bind $?temp-var-expr2 (create$ "$?" ?temp-var2 "$?"))
	   else
	   	(bind $?temp-var-expr1 (create$ ?temp-var1))
	   	(bind $?temp-var-expr2 (create$ ?temp-var2))
	)
	(if (> (length$ (create$ $?rec-path $?r-path)) 1)
	   then
		(bind $?temp-path1 (create$ "(" $?rec-path $?r-path ")"))
	   else
	   	(bind $?temp-path1 (create$ $?rec-path $?r-path))
	)
	;Shortcut
	(if (> (length$ $?r-path) 0)
	   then
		(bind $?temp-path1 $?r-path)
	   else
	   	(bind $?temp-path1 $?rec-path)
	)
	; rule: p8 ?a <- ( LPISPubs:Author ( LPISPubs:authorSurName "Bassiliades" ) ) 
	;          ( LPISPubs:Entry ( ( rdf:first ( rdf:rest ) LPISPubs:authors ) ?a ) ( LPISPubs:publicationTitle ?t ) ) 
	;       => 
	;	   ( result8 ( title ?t) ) 
	; before: ("?a" <- "(" LPISPubs:Author "(" LPISPubs:authorSurName #$%Bassiliades#$% ")" ")" 
	;           "(" LPISPubs:Entry)
	; new-before: ("?a" <- "(" LPISPubs:Author "(" LPISPubs:authorSurName #$%Bassiliades#$% ")" ")" 
	;	    "(" LPISPubs:Entry "(" LPISPubs:publicationTitle "?t" ")")
	; after: (LPISPubs:publicationTitle "?t" ")" ")")
	; new rule1: ?a <- ( LPISPubs:Author ( LPISPubs:authorSurName "Bassiliades" ) ) 
	;		   ( LPISPubs:Entry ( ( rdf:rest LPISPubs:authors) $? ?gen613 $? ) ) 
	;	=> 
	;		( gen612 ( gen611 ?a ) ( cnd_obj ?gen613 ) )
	; new rule2: ?gen613 <- ( rdf:List ( rdf:rest $? ?gen614 $? ) ) 
	;			( gen612 ( gen611 ?a ) ( cnd_obj ?gen613 ) ) 
	;		=> 
	;			( gen612 ( gen611 ?a ) ( cnd_obj ?gen614 ) )
	; new rule3: ( gen612 ( gen611 ?a ) ( ( rdf:first cnd_obj ) ?a ) ) 
	;		LPISPubs:publicationTitle ?t ) ) 
	;	=> 
	;		( result8 ( title ?t ) )
	; ================================
	; Must become
	; ================================
	; new rule1: ?a <- ( LPISPubs:Author ( LPISPubs:authorSurName "Bassiliades" ) ) 
	;		   ( LPISPubs:Entry ( LPISPubs:authors $? ?gen613 $? ) ) 
	;	=> 
	;		( gen612 ( gen611 ?a ) ( cnd_obj ?gen613 ) )
	; new rule2: ?gen613 <- ( rdf:List ( rdf:rest $? ?gen614 $? ) ) 
	;			( gen612 ( gen611 ?a ) ( cnd_obj ?gen613 ) ) 
	;		=> 
	;			( gen612 ( gen611 ?a ) ( cnd_obj ?gen614 ) )
	; new rule3: ( gen612 ( gen611 ?a ) ( ( rdf:first cnd_obj ) ?a ) ) 
	;	     ( rdf:List ( rdf:first ?a ) ) 
	;	     ( LPISPubs:Entry ( LPISPubs:publicationTitle ?t ) ) 
	;	=> 
	;		( result8 ( title ?t ) )
	(bind ?new-rule1 (str-cat$ (create$
		$?condition-before "(" $?temp-path1  $?temp-var-expr1 ")" ")"
		=>
		"(" ?temp-class-name $?copy-vars "(" cnd_obj ?temp-var1 ")" ")"
	)))
	(if (> (length$ $?rec-path) 1)
	   then
		(bind $?temp-path2 (create$ "(" $?rec-path ")"))
	   else
	   	(bind $?temp-path2 $?rec-path)
	)
	(bind ?new-rule2 (str-cat$ (create$
		?temp-var1 <- "(" ?last-rec-class "(" $?temp-path2 $?temp-var-expr2 ")" ")"
		"(" ?temp-class-name $?copy-vars "(" cnd_obj ?temp-var1 ")" ")"
		=>
		"(" ?temp-class-name $?copy-vars "(" cnd_obj ?temp-var2 ")" ")"
	)))
	(bind ?new-rule3 (str-cat$ (create$
		"(" ?temp-class-name $?copy-vars "(" "(" $?l-path cnd_obj ")" $?predicate ")" ")"
		$?condition-after
		=>
		$?conclusion
	)))
	;(printout t "translate-2nd-order-rule-rec-path: ?new-rule1 " ?new-rule1 crlf)
	;(printout t "translate-2nd-order-rule-rec-path: ?new-rule2 " ?new-rule2 crlf)
	;(printout t "translate-2nd-order-rule-rec-path: ?new-rule3 " ?new-rule3 crlf)
	(if (eq ?ntm-status yes)
	   then
		(assert (deductiverule (str-cat ?rule-name "1 " ?new-rule1)))
		(assert (deductiverule (str-cat ?rule-name "2 " ?new-rule2)))
		(assert (deductiverule (str-cat ?rule-name "3 " ?new-rule3)))
	   else
	   	(assert (ntm-deductiverule (str-cat ?rule-name "1 " ?new-rule1)))
		(assert (ntm-deductiverule (str-cat ?rule-name "2 " ?new-rule2)))
		(assert (ntm-deductiverule (str-cat ?rule-name "3 " ?new-rule3)))
	)
	(bind ?*untranslated_rules* (+ ?*untranslated_rules* 3))

)

(deffunction translate-2nd-order-rule-short-path (?ntm-status ?rule-name ?rule $?aux-data)
	(bind $?r (my-explode$ ?rule))
	(bind ?imp_pos (member$ => $?r))
	(bind $?condition (subseq$ $?r 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?r (+ ?imp_pos 1) (length$ $?r)))
	(bind ?class (nth$ 1 $?aux-data))
	(bind $?path (subseq$ $?aux-data 2 (length$ $?aux-data)))
	(bind ?left-bracket-pos (- (subseq-pos (create$ $?path $$$ $?condition)) 2))
	(bind $?condition-before (subseq$ $?condition 1 (- ?left-bracket-pos 1)))
	(bind $?condition-after (subseq$ $?condition (+ ?left-bracket-pos (length$ $?path) 2) (length$ $?condition)))
	;(bind ?right-bracket-pos1 (member$ ")" $?condition-after))
	(bind $?condition-after (subseq$ $?condition-after (+ (member$ ")" $?condition-after) 1) (length$ $?condition-after)))
	(bind ?right-bracket-pos2 (member$ ")" $?condition-after))
	(bind $?predicate (subseq$ $?condition-after 1 (- ?right-bracket-pos2 1)))
	(bind $?condition-after (subseq$ $?condition-after (+ ?right-bracket-pos2 2) (length$ $?condition-after)))
	;(bind $?all-vars (collect-all-vars $?condition-before))
	(bind $?copy-vars (create-slot-var-pairs (collect-all-vars $?condition-before)))
	(bind ?temp-class-name1 (gensym*))
	(bind ?temp-class-name2 (gensym*))
	(bind ?temp-var1 (str-cat "?" (gensym)))
	(bind ?temp-var2 (str-cat "?" (gensym)))
	(bind ?temp-multi-var3 (str-cat "$?" (gensym)))
	(bind ?pos (member$ + $?path))
	(bind $?l-path (subseq$ $?path 1 (- ?pos 1)))
	(bind $?r-path (subseq$ $?path (+ ?pos 1) (length$ $?path)))
	(if (> (length$ $?r-path) 0)
	   then
	   	(bind ?mid-class (find-class ?class (reverse$ $?r-path)))
	   	(if (> (length$ (rest$ $?r-path)) 0)
	   	   then
	   	   	(bind ?prev-class (find-class ?class (reverse$ (rest$ $?r-path))))
	   	   else
	   	   	(bind ?prev-class ?class)
	   	)
		(if (is-multislot ?prev-class (nth$ 1 $?r-path))
		   then
		   	(bind $?temp-var-expr1 (create$ "$?" ?temp-var1 "$?"))
		   else
		   	(bind $?temp-var-expr1 (create$ ?temp-var1))
		)
		(bind ?new-rule1 (str-cat$ (create$
			?temp-var1 <- "(" ?mid-class "(" "(" $?l-path ?temp-multi-var3 ")" $?predicate ")" ")"
			$?condition-before "(" "(" $?r-path ")" $?temp-var-expr1 ")" ")"
			=>
			"(" ?temp-class-name1 $?copy-vars "(" cnd_obj ?temp-var1 ")" ")"
		)))
		(bind ?new-rule2 (str-cat$ (create$
			?temp-var1 <- "(" ?mid-class "(" "(" ?temp-multi-var3 ")" ?temp-var2 ")" ")"
			"(" ?temp-class-name1 "(" cnd_obj ?temp-var1 ")" ")"
			"(" ?temp-class-name1 "(" cnd_obj ?temp-var2 ")" ")"
			"(" test "(" neq ?temp-var1 ?temp-var2 ")" ")"
			=>
			"(" ?temp-class-name2 "(" cnd_obj ?temp-var1 ")" ")"
		)))
		(bind ?new-rule3 (str-cat$ (create$
			"(" ?temp-class-name1 $?copy-vars "(" cnd_obj ?temp-var1 ")" ")"
			 "(" not "(" ?temp-class-name2 "(" cnd_obj ?temp-var1 ")" ")" ")"
			$?condition-after
			=>
			$?conclusion
		)))
		(if (eq ?ntm-status yes)
		   then
			(assert (deductiverule (str-cat ?rule-name "1 " ?new-rule1)))
			(assert (deductiverule (str-cat ?rule-name "2 " ?new-rule2)))
			(assert (deductiverule (str-cat ?rule-name "3 " ?new-rule3)))
		   else
		   	(assert (ntm-deductiverule (str-cat ?rule-name "1 " ?new-rule1)))
			(assert (ntm-deductiverule (str-cat ?rule-name "2 " ?new-rule2)))
			(assert (ntm-deductiverule (str-cat ?rule-name "3 " ?new-rule3)))
		)
		(bind ?*untranslated_rules* (+ ?*untranslated_rules* 3))
	   else
		(bind ?class-pos (- (length$ $?condition-before) (member$ ?class (reverse$ $?condition-before)) 1))
		(if (eq (nth$ ?class-pos $?condition-before) <-)
		   then
		   	(bind ?class-var (nth$ (- ?class-pos 1) $?condition-before))
		   else
		   	(bind ?class-var (str-cat "?" (gensym)))
		   	(bind $?condition-before (insert$ $?condition-before (+ ?class-pos 1) ?class-var <-))
		)
		(bind ?new-rule1 (str-cat$ (create$
			$?condition-before "(" "(" $?l-path ?temp-multi-var3 ")" $?predicate ")" ")"
			=>
			"(" ?temp-class-name1 $?copy-vars "(" cnd_obj ?class-var ")" ")"
		)))
		(bind ?new-rule2 (str-cat$ (create$
			?temp-var1 <- "(" ?class "(" "(" ?temp-multi-var3 ")" ?temp-var2 ")" ")"
			"(" ?temp-class-name1 "(" cnd_obj ?temp-var1 ")" ")"
			"(" ?temp-class-name1 "(" cnd_obj ?temp-var2 ")" ")"
			"(" test "(" neq ?temp-var1 ?temp-var2 ")" ")"
			=>
			"(" ?temp-class-name2 "(" cnd_obj ?temp-var1 ")" ")"
		)))
		(bind ?new-rule3 (str-cat$ (create$
			"(" ?temp-class-name1 $?copy-vars "(" cnd_obj ?temp-var1 ")" ")"
			"(" not "(" ?temp-class-name2 "(" cnd_obj ?temp-var1 ")" ")" ")"
			;"(" ?temp-class-name2 "(" cnd_obj ?temp-var1 ")" ")"
			$?condition-after
			=>
			$?conclusion
		)))
		(debug "new-rule1: " ?new-rule1 crlf)
		(debug "new-rule2: " ?new-rule2 crlf)
		(debug "new-rule3: " ?new-rule3 crlf)
		(if (eq ?ntm-status yes)
		   then
			(assert (deductiverule (str-cat ?rule-name "1 " ?new-rule1)))
			(assert (deductiverule (str-cat ?rule-name "2 " ?new-rule2)))
			(assert (deductiverule (str-cat ?rule-name "3 " ?new-rule3)))
		   else
		   	(assert (ntm-deductiverule (str-cat ?rule-name "1 " ?new-rule1)))
			(assert (ntm-deductiverule (str-cat ?rule-name "2 " ?new-rule2)))
			(assert (ntm-deductiverule (str-cat ?rule-name "3 " ?new-rule3)))
		)
		(bind ?*untranslated_rules* (+ ?*untranslated_rules* 3))
	)
	;(release-mem)
)


(deffunction translate-2nd-order-rule (?rule-name ?rule $?aux-data)
	;(debug "Rule: " ?rule crlf "Aux data: " (str-cat$ $?aux-data) crlf)
	(if (eq (nth$ 1 $?aux-data) class)
	   then
	   	(translate-2nd-order-rule-class yes ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) class-namespace)
	   then
	   	(translate-2nd-order-rule-class-namespace yes ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) namespace)
	   then
	   	(translate-2nd-order-rule-namespace yes ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) var-class-namespace)
	   then
	   	(translate-2nd-order-rule-var-class-namespace yes ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) slot)
	   then
	   	(translate-2nd-order-rule-slot yes ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) aliased-slot)
	   then
	   	(translate-2nd-order-rule-aliased-slot yes ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) path)
	   then
	   	(translate-2nd-order-rule-path yes ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) rec-path)
	   then
	   	(translate-2nd-order-rule-rec-path yes ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) short-path)
	   then
	   	(translate-2nd-order-rule-short-path yes ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(return FALSE)
)

(deffunction translate-2nd-order-ntm-rule (?rule-name ?rule $?aux-data)
	;(debug "Rule: " ?rule crlf "Aux data: " (str-cat$ $?aux-data) crlf)
	(if (eq (nth$ 1 $?aux-data) class)
	   then
	   	(translate-2nd-order-rule-class no ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) class-namespace)
	   then
	   	(translate-2nd-order-rule-class-namespace no ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) namespace)
	   then
	   	(translate-2nd-order-rule-namespace no ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) var-class-namespace)
	   then
	   	(translate-2nd-order-rule-var-class-namespace no ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) slot)
	   then
	   	(translate-2nd-order-rule-slot no ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) aliased-slot)
	   then
	   	(translate-2nd-order-rule-aliased-slot no ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) path)
	   then
	   	(translate-2nd-order-rule-path no ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) rec-path)
	   then
	   	(translate-2nd-order-rule-rec-path no ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(if (eq (nth$ 1 $?aux-data) short-path)
	   then
	   	(translate-2nd-order-rule-short-path no ?rule-name ?rule (rest$ $?aux-data))
	   	(return)
	)
	(return FALSE)
)
