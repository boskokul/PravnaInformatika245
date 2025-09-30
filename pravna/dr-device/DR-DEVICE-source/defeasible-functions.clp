(deffunction calc-defeasible-priority (?base ?rule)
	;(printout t "rule: " ?rule crlf)
	(bind ?conclusion-class (send ?rule get-conclusion-class))
	;(bind ?differentiation1 0)
	;(do-for-instance 
	;	((?x ?conclusion-class)) 
	;	(and 	(member$ (instance-name-to-symbol ?rule) ?x:positive-support)
	;		(= (length$ ?x:negative-support) 0)) 
	;	(bind ?differentiation1 1)
	;)
	;(bind ?differentiation2 0)
	;(if (= ?differentiation1 0)
	;   then
	;   	(do-for-instance 
	;		((?x ?conclusion-class)) 
	;		(or
	;			(member$ (instance-name-to-symbol ?rule) ?x:positive-support)
	;			(member$ (instance-name-to-symbol ?rule) ?x:negative-support)
	;		)
	;		(bind ?differentiation2 (+ (length$ ?x:positive-defeated) (length$ ?x:negative-defeated) (length$ ?x:positive-overruled) (length$ ?x:negative-overruled)))
	;	)
	;)
	;(bind ?salience (+ (* 10 ?differentiation1) (* 5 ?differentiation2) ?base (* 20 (send (symbol-to-instance-name ?conclusion-class) get-defeasible-stratum))))
	;(bind ?salience (+ (* 10 ?differentiation1) ?base (* 20 (send (symbol-to-instance-name ?conclusion-class) get-defeasible-stratum))))
	(bind ?salience (+ ?base (* 10 (send (symbol-to-instance-name ?conclusion-class) get-defeasible-stratum))))
	;(printout t "Rule: " ?rule " - salience: " ?salience crlf)
	(return ?salience)
)

(deffunction calc-defeasible-stratum ()
	(bind $?defeasible-conclusion-classes (create$))
	(do-for-all-instances ((?x defeasible-rule)) TRUE
		(if (not (member$ ?x:conclusion-class $?defeasible-conclusion-classes))
		   then
		   	(bind $?defeasible-conclusion-classes (create$ $?defeasible-conclusion-classes ?x:conclusion-class))
		)
	)
	(while (> (length$ $?defeasible-conclusion-classes) 0)
	   do
	   	;(printout t "calc-defeasible-stratum: $?defeasible-conclusion-classes: " $?defeasible-conclusion-classes crlf)
	   	(bind ?first-defeasible-conclusion-class (nth$ 1 $?defeasible-conclusion-classes))
	   	(bind $?defeasible-conclusion-classes (rest$ $?defeasible-conclusion-classes))
	   	(do-for-all-instances 
	   		((?x defeasible-rule)) 
	   		(eq ?x:conclusion-class ?first-defeasible-conclusion-class)
	   		; Action
			(bind $?rule (my-explode$ ?x:original-rule))
			(bind ?imp_pos (member$ => $?rule))
			(bind $?condition (subseq$ $?rule 1 (- ?imp_pos 1)))
			;(bind $?conclusion (subseq$ $?rule (+ ?imp_pos 1) (length$ $?rule)))
			; Collect condition classes
			(bind $?positive-condition-classes (collect-positive-class-names $?condition))
			(bind $?negative-condition-classes (collect-negative-class-names $?condition))
			;(printout t "rule name: " ?x crlf)
			;(printout t "$?positive-condition-classes: " $?positive-condition-classes crlf)
			;(printout t "$?negative-condition-classes: " $?negative-condition-classes crlf)
			(bind ?max-positive-stratum 0)
			(bind ?positive-class-number (length$ $?positive-condition-classes))
			(loop-for-count (?n 1 ?positive-class-number)
			   do
			   	(bind ?other-stratum (send (symbol-to-instance-name (nth$ ?n $?positive-condition-classes)) get-defeasible-stratum))
			   	(if (< ?other-stratum ?max-positive-stratum)
			   	   then
			   	   	(bind ?max-positive-stratum ?other-stratum)
			   	)
			)
			(bind ?max-negative-stratum 0)
			(bind ?negative-class-number (length$ $?negative-condition-classes))
			(loop-for-count (?n 1 ?negative-class-number)
			   do
			   	(bind ?other-stratum (send (symbol-to-instance-name (nth$ ?n $?negative-condition-classes)) get-defeasible-stratum))
		   		(if (< ?other-stratum ?max-negative-stratum)
		   		   then
		   		   	(bind ?max-negative-stratum ?other-stratum)
		   		)
		   	)
		   	;(printout t "rule: " ?x crlf)
			;(printout t "?max-positive-stratum: " ?max-positive-stratum crlf)
			;(printout t "?max-negative-stratum: " ?max-negative-stratum crlf)
			(if (eq ?x:negated no)
			   then
			   	(if (> ?negative-class-number 0)
			   	   then
			   	   	(bind ?stratum (- ?max-negative-stratum 1))
			   	   else
			   	   	(bind ?stratum ?max-positive-stratum)
			   	)
			   else
			   	(if (> ?positive-class-number 0)
			   	   then
			   	   	(bind ?stratum (- ?max-positive-stratum 1))
			   	   else
			   	   	(bind ?stratum ?max-negative-stratum)
			   	)
			)
			;(bind ?stratum (- 0 ?stratum))
			(bind ?old-stratum (send (symbol-to-instance-name ?first-defeasible-conclusion-class) get-defeasible-stratum))
			(if (< ?stratum ?old-stratum)
			   then
				(send (symbol-to-instance-name ?first-defeasible-conclusion-class) put-defeasible-stratum ?stratum)
				;(printout t "?stratum: " ?stratum crlf)
			)
		)
	)  
	TRUE
)


; This function is re-defined in order to cater for RDF data
; that are also defeasible facts!
; The original function is in file load_rdf.clp of R-DEVICE
;;; Updated - 25-03-2005
;;; To consider slot-values
(deffunction resource-make-instance (?class ?resource $?types-and-slot-values)
	; new
	;(printout t "********* HERE *************** ?resource = " ?resource crlf)
	(bind ?pos (member$ $$$ $?types-and-slot-values))
	(if (neq ?pos FALSE)
	   then
	   	(bind $?types (subseq$ $?types-and-slot-values 1 (- ?pos 1)))
		(bind $?slot-values (subseq$ $?types-and-slot-values (+ ?pos 1) (length$ $?types-and-slot-values)))
	   else
	   	(bind $?types $?types-and-slot-values)
	   	(bind $?slot-values (create$))
	)
	;(printout t "+++++++++++++" "$?types: " $?types crlf)
	;(printout t "+++++++++++++" "$?slot-values: " $?slot-values crlf)
	; new
	(bind $?slot-value-string (create$))
	(while (> (length$ $?slot-values) 0)
	   do
	   	;(printout t "$?slot-values: " $?slot-values crlf)
	   	(bind $?slot-values (rest$ $?slot-values))
	   	(bind ?slot-name (nth$ 1 $?slot-values))
	   	(bind ?pos (member$ $slot $?slot-values))
	   	(if (neq ?pos FALSE)
	   	   then
	   		(bind $?values (subseq$ $?slot-values 2 (- ?pos 1)))
	   	   	;(printout t "+++++++++++++ " "$?values: " $?values crlf)
	   		(bind $?slot-values (subseq$ $?slot-values ?pos (length$ $?slot-values)))
	   	   else
	   	   	;(printout t "Here!" crlf)
	   	   	(bind $?values (subseq$ $?slot-values 2 (length$ $?slot-values)))
	   	   	;(printout t "+++++++++++++ " "$?values: " $?values crlf)
	   		(bind $?slot-values (create$))
	   	)
	   	(bind $?slot-value-string (create$ "(" ?slot-name (parenthesis $?values) ")" $?slot-value-string))
	)
	;(printout t "+++++++++++++ " "$?slot-value-string: " $?slot-value-string crlf crlf)
	(bind ?instance-create-string (str-cat$ (create$
		"(" make-instance ?resource of ?class
			"(" rdf:type (symbols-to-instances $?types) ")"
			"(" uri (instance-name-to-symbol ?resource) ")"
  			"(" positive 2 ")"
			$?slot-value-string
		")"
	)))
	;(printout t "?instance-create-string: " ?instance-create-string crlf crlf)
	(eval ?instance-create-string)
	; old
	;(make-instance ?resource of ?class
	;	(rdf:type (symbols-to-instances $?types))
	;	;(uri (str-cat (instance-name-to-symbol ?resource)))
	;	(uri (instance-name-to-symbol ?resource))
	;)
	(return ?resource)
)

; This is not needed any more, due to the above!!!
;(deffunction initialize-defeasible-facts ($?defdefeasibleclasses)
;	(while (> (length$ $?defdefeasibleclasses) 0)
;	   do
;	   	(bind ?class (nth$ 1 $?defdefeasibleclasses))
;	   	(if (class-existp ?class)
;	   	   then
;	   		(do-for-all-instances 
;	   			((?x ?class)) 
;	   			(and (= ?x:positive 0) (= ?x:negative 0))
;	   			(send ?x put-positive 2)
;	   		)
;	   	)
;	   	(bind $?defdefeasibleclasses (rest$ $?defdefeasibleclasses))
;	)
;	TRUE
;)

;(deffunction integrate-calc ($?conclusion)
;	(bind ?p2 (get-token $?conclusion))
;	(bind $?calc-command (subseq$ $?conclusion 3 (- ?p2 1)))
;	(bind $?conclusion (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
;	(while (> (length$ $?calc-command) 0)
;	   do
;	   	(bind ?p2 (get-token $?calc-command))
;		(bind $?first-calc-command (subseq$ $?calc-command 1 ?p2))
;		(bind $?calc-command (subseq$ $?calc-command (+ ?p2 1) (length$ $?calc-command)))
;		(if (eq (nth$ 2 $?first-calc-command) bind)
;		   then   ; It works only for multiple ...bind ?var...
;		          ; that do not chain with one another!
;		   	(bind ?var (nth$ 3 $?first-calc-command))
;		   	(bind ?pos (member$ ?var $?conclusion))
;		   	(bind $?function (subseq$ $?first-calc-command 4 (- (length$ $?first-calc-command) 1) ))
;		   	(bind $?function (create$ "&" ":" "(" = ?var $?function")" ) )
;		   	(bind $?conclusion (insert$ $?conclusion (+ ?pos 1) $?function))
;		   	;(bind $?conclusion (replace-member$ $?conclusion $?function ?var))
;		)
;	)
;	(return $?conclusion)
;)

(deffunction get-calc-test-function ($?conclusion)
	(bind $?function (create$))
	(bind ?p2 (get-token $?conclusion))
	(bind $?calc-command (subseq$ $?conclusion 3 (- ?p2 1)))
	;(bind $?conclusion (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
	(while (> (length$ $?calc-command) 0)
	   do
	   	(bind ?p2 (get-token $?calc-command))
		(bind $?first-calc-command (subseq$ $?calc-command 1 ?p2))
		(bind $?calc-command (subseq$ $?calc-command (+ ?p2 1) (length$ $?calc-command)))
		(if (eq (nth$ 2 $?first-calc-command) bind)
		   then   ; It works only for multiple ...bind ?var...
		          ; that do not chain with one another!
		   	(bind ?var (nth$ 3 $?first-calc-command))
		   	;(bind ?pos (member$ ?var $?conclusion))
		   	(bind $?one-function (subseq$ $?first-calc-command 4 (- (length$ $?first-calc-command) 1) ))
		   	(bind $?function (create$ $?function "(" eq ?var $?one-function")" ) )
		   	;(bind $?conclusion (insert$ $?conclusion (+ ?pos 1) $?function))
		   	;(bind $?conclusion (replace-member$ $?conclusion $?function ?var))
		)
	)
	(if (> (token-length $?function) 1)
	   then
		(bind $?function (create$ "(" test "(" and $?function ")" ")"  ))
	   else
		(bind $?function (create$ "(" test $?function ")"  ))
	)
	(return $?function)
)

(deffunction get-pure-conclusion ($?conclusion)
	(bind ?p2 (get-token $?conclusion))
	(bind $?conclusion (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
	(return $?conclusion)
)

;(deffunction get-conclusion-pattern ($?conclusion-slots)
;	(bind $?result (create$))
;	(while (> (length$ $?conclusion-slots) 0)
;	   do
;	   	(bind ?p2 (get-token $?conclusion-slots))
;		(bind $?conclusion-slot (subseq$ $?conclusion-slots 1 ?p2))
;		(bind $?conclusion-slots (subseq$ $?conclusion-slots (+ ?p2 1) (length$ $?conclusion-slots)))
;		(bind ?length (length$ $?conclusion-slot))
;		(if (and (= ?length 4) (not (is-var (nth$ 3 $?conclusion-slot))))
;		   then
;		   	(bind $?result (create$ (nth$ 2 $?conclusion-slot) (nth$ 3 $?conclusion-slot)))
;		)
;	)
;	(return $?result)
;)

(deffunction discover-object (?class $?slot-value-pairs)
	(bind $?query (create$))
	(bind ?counter 0)
	(while (> (length$  $?slot-value-pairs) 0)
	   do
	   	(bind ?p2 (get-token $?slot-value-pairs))
		(bind $?first-slot-value-pair (subseq$ $?slot-value-pairs 1 ?p2))
		(bind $?first-query (create$ "(" eq (sym-cat "?x:" (nth$ 2 $?first-slot-value-pair)) (nth$ 3 $?first-slot-value-pair) ")" ))
		(bind $?query (create$ $?query $?first-query))
		(bind ?counter (+ ?counter 1))
		(bind $?slot-value-pairs (subseq$ $?slot-value-pairs (+ ?p2 1) (length$ $?slot-value-pairs)))
	)
	(if (> ?counter 1)
	   then
	   	(bind $?query (create$ "(" and $?query ")"))
	)
	(bind ?query (str-cat$ (create$
		"(" find-instance "(" "(" "?x" ?class ")" ")" $?query ")" )))
	(bind $?result (eval ?query))
	(if (= (length$ $?result) 1)
	   then
	   	(return (nth$ 1 $?result))
	   else
	   	(return FALSE)
	)
)

(deffunction definitely-proven (?literal)
	(bind $?literal (explode$ ?literal))
	(if (eq (nth$ 2 $?literal) not)
	   then
		(bind ?class (nth$ 4 $?literal))
		(bind $?slot-value-pairs (subseq$ $?literal 5 (- (length$ $?literal) 2)))
		(bind ?oid (discover-object ?class $?slot-value-pairs))
		(if (neq ?oid FALSE)
		   then
			(bind ?negative (send ?oid get-negative))
			(if (= ?negative 2)
			   then
			   	TRUE
			   else
			   	FALSE
			)
		   else
		   	FALSE
		)
	   else
	   	(bind ?class (nth$ 2 $?literal))
		(bind $?slot-value-pairs (subseq$ $?literal 3 (- (length$ $?literal) 1)))
		(bind ?oid (discover-object ?class $?slot-value-pairs))
		(if (neq ?oid FALSE)
		   then
			(bind ?positive (send ?oid get-positive))
			(if (= ?positive 2)
			   then
			   	TRUE
			   else
			   	FALSE
			)
		   else
		   	FALSE
		)
	)
)

(deffunction not-definitely-proven (?literal)
	(not (definitely-proven ?literal))
)

(deffunction defeasibly-proven (?literal)
	(bind $?literal (explode$ ?literal))
	(if (eq (nth$ 2 $?literal) not)
	   then
		(bind ?class (nth$ 4 $?literal))
		(bind $?slot-value-pairs (subseq$ $?literal 5 (- (length$ $?literal) 2)))
		(bind ?oid (discover-object ?class $?slot-value-pairs))
		(if (neq ?oid FALSE)
		   then
			(bind ?negative (send ?oid get-negative))
			(if (>= ?negative 1)
			   then
			   	TRUE
			   else
			   	FALSE
			)
		   else
		   	FALSE
		)
	   else
	   	(bind ?class (nth$ 2 $?literal))
		(bind $?slot-value-pairs (subseq$ $?literal 3 (- (length$ $?literal) 1)))
		(bind ?oid (discover-object ?class $?slot-value-pairs))
		(if (neq ?oid FALSE)
		   then
			(bind ?positive (send ?oid get-positive))
			(if (>= ?positive 1)
			   then
			   	TRUE
			   else
			   	FALSE
			)
		   else
		   	FALSE
		)
	)
)

(deffunction not-defeasibly-proven (?literal)
	(not (defeasibly-proven ?literal))
)

(deffunction go-dr-device ()
	;(set-truth-maintenance off)
;	(do-for-all-instances 
;		((?x DEFEASIBLE-OBJECT)) 
;		(and (neq ?x:positive 0) (eq ?x:positive ?x:negative))
;		(send ?x put-positive 0)
;		(send ?x put-negative 0)
;	)
	(bind ?mods-before -1)
	(bind ?mods-after ?*attribute_modifications*)
	(while (<> ?mods-after ?mods-before)
	   do
		(bind ?mods-before ?mods-after)
		;(printout t "?mods-before: " ?mods-before crlf)
		; Run deductive rules
		(go-r-device)
		;(make-instance run-support-rules of DEFEASIBLE-CONTROL)
		;(go)
		;(send [run-support-rules] delete)
	;	(make-instance run-defeasible-rules of DEFEASIBLE-CONTROL)
		;(make-instance run-defeated-rules of DEFEASIBLE-CONTROL)
		;(make-instance run-overruled-rules of DEFEASIBLE-CONTROL)
		;(make-instance run-defeasibly-rules of DEFEASIBLE-CONTROL)
		; Run definite rules
	;	(make-instance run-definitely-rules of DEFEASIBLE-CONTROL)
	;	(go)
	;	(send [run-definitely-rules] delete)
		; Run defeated rules
	;	(make-instance run-defeated-rules of DEFEASIBLE-CONTROL)
	;	(go)
	;	(send [run-defeated-rules] delete)
		; Run overruled rules
	;	(make-instance run-overruled-rules of DEFEASIBLE-CONTROL)
	;	(go)
	;	(send [run-overruled-rules] delete)
		; Run defeasible rules
	;	(make-instance run-defeasibly-rules of DEFEASIBLE-CONTROL)
	;	(go)
	;	(send [run-defeasibly-rules] delete)
		(bind ?mods-after ?*attribute_modifications*)
		;(printout t "?mods-after: " ?mods-after crlf)
		;(send [run-defeasible-rules] delete)
			;(send [run-definitely-rules] delete)
			;(send [run-defeated-rules] delete)
			;(send [run-overruled-rules] delete)
			;(send [run-defeasibly-rules] delete)
	)
	;(set-truth-maintenance on)
	TRUE
)

; This is not needed any more, due to the re-definition of
; function resource-make-instance above!!!
;(deffunction find-rdf-ground-classes ()
;	(bind $?classes (find-all-instances ((?x rdfs:Class)) TRUE))
;	(return (instances-to-symbols $?classes))
;)

(deffunction user-slots (?class)
	;(bind $?candidate-slots (delete-member$ (class-slots ?class inherit) 
	;					counter derivators class-refs namespace 
	;					source uri aliases 
	;					positive negative 
	;					positive-support negative-support
	;					positive-overruled negative-overruled
	;					positive-defeated negative-defeated 
	;					class-name rules defeasible-stratum
	;))
	(bind $?candidate-slots (delete-member$ (class-slots ?class inherit) 
						counter derivators namespace source uri
						class-refs aliases
						positive negative 
						positive-support negative-support
						; new
						positive-derivator negative-derivator
						positive-overruled negative-overruled
						positive-defeated negative-defeated 
						class-name rules defeasible-stratum
						proof ; PROOF
						modality ; MODALITIES
	))
	;(if (slot-existp ?class aliases inherit)
	(if (slot-existp (class (class-instance-name ?class)) aliases inherit)
	   then
	   	;(bind $?aliased-slots (slot-default-value ?class aliases))
	   	(bind $?aliased-slots (send (class-instance-name ?class) get-aliases))
		(bind $?result (create$))
		(bind ?end (length$ $?candidate-slots))
		(loop-for-count (?n 1 ?end)
		   do
		   	(if (not (odd-member$ (nth$ ?n $?candidate-slots) $?aliased-slots))
		   	   then
		   	   	(bind $?result (create$ $?result (nth$ ?n $?candidate-slots)))
		   	)
		)
		(return $?result)
	   else
	   	(return $?candidate-slots)
	)
)

(deffunction find-competing-rules (?rule)
	(bind ?comp-rule-object (nth$ 1 (find-instance ((?x competing-rules)) (member$ ?rule ?x:original-rules))))
	(if (eq ?comp-rule-object nil)
	   then
	   	(return (create$))
	   else
	   	(return (instances-to-symbols (delete-member$ (send ?comp-rule-object get-original-rules) ?rule)))
	)
)

;(deffunction find-unique-slots-of-competing-rules (?rule)
;	(bind ?comp-rule-object (nth$ 1 (find-instance ((?x competing-rules)) (member$ ?rule ?x:original-rules))))
;	(if (eq ?comp-rule-object nil)
;	   then
;	   	(return (create$))
;	   else
;	   	(return (send ?comp-rule-object get-unique-slots))
;	)
;)

(deffunction find-competing-rule-construct (?rule)
	(bind ?comp-rule-object (nth$ 1 (find-instance ((?x competing-rules)) (member$ ?rule ?x:original-rules))))
	(if (eq ?comp-rule-object nil)
	   then
	   	(return FALSE)
	   else
	   	(return ?comp-rule-object)
	)
)

(deffunction replace-competing-rules (?superior-rule $?inferior-rules-and-competing-rules)
	(bind $?inferior-rules (subseq$ $?inferior-rules-and-competing-rules 1 (- (member$ $$$ $?inferior-rules-and-competing-rules) 1)))
	(bind $?competing-rules (subseq$ $?inferior-rules-and-competing-rules (+ (member$ $$$ $?inferior-rules-and-competing-rules) 1) (length$ $?inferior-rules-and-competing-rules)))
	(bind $?result (create$))
	(while (> (length$ $?inferior-rules) 0)
	   do
	   	(bind ?inferior-rule (nth$ 1 $?inferior-rules))
	   	(bind $?inferior-rules (rest$ $?inferior-rules))
	   	(if (member$ ?inferior-rule $?competing-rules)
	   	   then
	   	   	(bind $?result (create$ $?result (sym-cat ?inferior-rule -comp-rule- ?superior-rule)))
	   	   else
	   	   	(bind $?result (create$ $?result ?inferior-rule))
	   	)
	)
	(return $?result)
)

(deffunction find-vars ($?code)
	(bind $?vars (create$))
	(while (> (length$ $?code) 0)
	   do
	   	(bind ?head (nth$ 1 $?code))
	   	(if (and (is-var ?head) (not (member$ ?head $?vars)))
	   	   then
	   	   	(bind $?vars (create$ $?vars ?head))
	   	)
	   	(bind $?code (rest$ $?code))
	)
	(return $?vars)
)

(deffunction remove-strong-negation ($?condition)
	(bind $?positive-condition (create$))
	(while (> (length$ $?condition) 0)
	   do
	   	(bind ?p2 (get-token $?condition))
	   	(bind $?first-cond-elem (subseq$ $?condition 1 ?p2))
	   	(bind ?oid-var (sym-cat "?" (gensym))) ; PROOF NEW
	   	(if (eq (nth$ 2 $?first-cond-elem) test)
		   then
			(bind $?positive-condition (create$ $?positive-condition $?first-cond-elem))
		   else
	   		(if (neq (nth$ 2 $?first-cond-elem) not)
	   		   then
;				(bind $?positive-condition (create$ $?positive-condition $?first-cond-elem))
				(bind $?positive-condition (create$ $?positive-condition ?oid-var "<-" $?first-cond-elem)) ; PROOF
			   else
;			   	(bind $?positive-condition (create$ $?positive-condition (subseq$ $?first-cond-elem 3 (- (length$ $?first-cond-elem) 1))))
			   	(bind $?positive-condition (create$ $?positive-condition ?oid-var "<-" (subseq$ $?first-cond-elem 3 (- (length$ $?first-cond-elem) 1)))) ; PROOF
			)
		)
		(bind $?condition (subseq$ $?condition (+ ?p2 1) (length$ $?condition)))
   	)
	(return $?positive-condition)
)


(deffunction get-instances ($?list)
	(bind $?result (create$))
	(while (instancep (nth$ 1 $?list))
	   do
	   	(bind $?result (create$ $?result (first$ $?list)))
	   	(bind $?list (rest$ $?list))
	)
	(return $?result)
)

(deffunction inverse-negation (?status)
	(if (eq ?status yes)
	   then
	   	(return no)
	   else
	   	(return yes)
	)
)
