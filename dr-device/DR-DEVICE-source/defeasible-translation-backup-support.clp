
;;;;;;;;;;;;;;;;;;;;;
; Class declaration ;
;;;;;;;;;;;;;;;;;;;;;

; Input
; -----
; (defdefeasibleclass gap
;	(slot animal-name)
; )

; Output
; ------
; (defclass gap 
;	(is-a DEFEASIBLE-OBJECT)
;	(slot animal-name)
; )

; Translation for one class
(deffunction translate-defeasibleclass (?class-string)
	(bind $?class-defs (explode$ ?class-string))
	(bind ?class-name (nth$ 1 $?class-defs))
	(bind $?class-slots (rest$ $?class-defs))
	(bind $?new-class-defs (create$ 
		"(" defclass ?class-name
			;"(" is-a DEFEASIBLE-OBJECT ")"
			"(" is-a DERIVED-CLASS ")"
			$?class-slots
		")"
	))
	(build (str-cat$ $?new-class-defs))
	;(make-instance ?class-name of defeasible-class
	;	(class-name ?class-name)
	;)
	(bind ?mk-inst-string (str-cat$ (create$
		"(" make-instance ?class-name of defeasible-class
			"(" class-name ?class-name ")"
		")"
	)))
	(eval ?mk-inst-string)
)

; Translation for all classes
(deffunction translate-defeasibleclasses ($?class-strings)
	(while (> (length$ $?class-strings) 0)
	   do
	   	(translate-defeasibleclass (nth$ 1 $?class-strings))
	   	(bind $?class-strings (rest$ $?class-strings))
	)
	TRUE
)


;;;;;;;;;;;;;;;;;;;;
; Fact declaration ;
;;;;;;;;;;;;;;;;;;;;

; Input
; -----
; (defdefeasiblefacts tweety_fact
;	(gap (animal-name tweety))
; )

; Output
; ------
; (definstances tweety_fact
; 	(of gap (animal-name tweety) (positive 2))
; )

; Translation for one deffacts
(deffunction translate-defeasiblefacts (?facts-string)
	(bind $?facts-defs (explode$ ?facts-string))
	(bind ?facts-name (nth$ 1 $?facts-defs))
	(bind $?facts (rest$ $?facts-defs))
	(while (> (length$ $?facts) 0)
	   do
	   	(bind ?p2 (get-token $?facts))
	   	(bind $?fact (subseq$ $?facts 1 ?p2))
		(bind $?facts (subseq$ $?facts (+ ?p2 1) (length$ $?facts)))
		(bind $?instance (create$
			"(" make-instance of (subseq$ $?fact 2 (- (length$ $?fact) 1)) "(" positive 2 ")" ")"
		))
		(eval (str-cat$ $?instance))
	)
)

; Translation for all deffacts
(deffunction translate-defeasiblefacts-all ($?facts-strings)
	(while (> (length$ $?facts-strings) 0)
	   do
	   	(translate-defeasiblefacts (nth$ 1 $?facts-strings))
	   	(bind $?facts-strings (rest$ $?facts-strings))
	)
	TRUE
)

;(deffunction definite-rule-conclusion ($?conclusion)
;	(if (eq (nth$ 2 $?conclusion) not)
;	   then
;	   	(return (create$ "(" (nth$ 4 $?conclusion) "(" negative 2 ")" ")" ))
;	   else
;	   	(return (create$ "(" (nth$ 2 $?conclusion) "(" positive 2 ")" ")" ))
;	)
;)

(deffunction definite-rule-one-cond-elem ($?cond-elem)
	(if (eq (nth$ 2 $?cond-elem) test)
	   then
	   	(return $?cond-elem)
	   else
		(bind ?oid-var (sym-cat "?" (gensym))) ; PROOF NEW
		(if (eq (nth$ 2 $?cond-elem) not)
		   then
;		   	(return (insert$ $?cond-elem (length$ $?cond-elem) "(" negative 2 ")" ))
		   	(return (create$ ?oid-var "<-" (insert$ $?cond-elem (length$ $?cond-elem) "(" negative 2 ")" ))) ; PROOF
		   else
;		   	(return (insert$ $?cond-elem (length$ $?cond-elem) "(" positive 2 ")" ))
		   	(return (create$ ?oid-var "<-" (insert$ $?cond-elem (length$ $?cond-elem) "(" positive 2 ")" ))) ; PROOF
		)
	)
)

(deffunction definite-rule-condition ($?condition)
	(bind $?result (create$))
	(while (> (length$ $?condition) 0)
	   do
	   	(bind ?p2 (get-token $?condition))
		(bind $?result (create$ $?result (definite-rule-one-cond-elem (subseq$ $?condition 1 ?p2))))
		(bind $?condition (subseq$ $?condition (+ ?p2 1) (length$ $?condition)))
   	)
	$?result
)

(deffunction defeasible-rule-one-cond-elem ($?cond-elem)
	(if (eq (nth$ 2 $?cond-elem) test)
	   then
	   	(return $?cond-elem)
	   else
		(bind ?var1 (sym-cat "?" (gensym)))
		(bind ?oid-var (sym-cat "?" (gensym))) ; PROOF NEW
		(if (eq (nth$ 2 $?cond-elem) not)
		   then
		   	(bind $?cond-elem (subseq$ $?cond-elem 3 (- (length$ $?cond-elem) 1)) )
;		   	(return (insert$ $?cond-elem (length$ $?cond-elem) "(" negative ?var1 "&" ":(" ">=" ?var1 1")" ")" )) ; PROOF
		   	(return (create$ ?oid-var "<-" (insert$ $?cond-elem (length$ $?cond-elem) "(" negative ?var1 "&" ":" "(" ">=" ?var1 1")" ")" ))) ; PROOF
		   else
;		   	(return (insert$ $?cond-elem (length$ $?cond-elem) "(" positive ?var1 "&" ":(" ">=" ?var1 1")" ")" )) ; PROOF
		   	(return (create$ ?oid-var "<-" (insert$ $?cond-elem (length$ $?cond-elem) "(" positive ?var1 "&" ":" "(" ">=" ?var1 1")" ")" ))) ; PROOF
		)
	)
)

(deffunction defeasible-rule-condition ($?condition)
	(bind $?result (create$))
	(while (> (length$ $?condition) 0)
	   do
	   	(bind ?p2 (get-token $?condition))
		(bind $?result (create$ $?result (defeasible-rule-one-cond-elem (subseq$ $?condition 1 ?p2))))
		(bind $?condition (subseq$ $?condition (+ ?p2 1) (length$ $?condition)))
   	)
	$?result
)

(deffunction get-object-address-vars-2 ($?condition)
	(bind $?result (create$))
	(while (> (length$ $?condition) 0)
	   do
	   	(bind ?p2 (get-token $?condition))
		(if (eq (nth$ 2 $?condition) "<-")
		   then
			(bind $?result (create$ $?result (nth$ 1 $?condition)))
		)
		(bind $?condition (subseq$ $?condition (+ ?p2 1) (length$ $?condition)))
   	)
	(return $?result)
)

(deffunction translate-defeasiblerule (?rule-file ?defeasiblerule-string)
)

(deffunction transform-naf (?rule-file ?rule-name $?condition-conclusion-vars-and-condition)
	(bind $?condition-conclusion-vars (subseq$ $?condition-conclusion-vars-and-condition 1 (- (member$ $$$ $?condition-conclusion-vars-and-condition) 1)))
	(bind $?condition (subseq$ $?condition-conclusion-vars-and-condition (+ (member$ $$$ $?condition-conclusion-vars-and-condition) 1) (length$ $?condition-conclusion-vars-and-condition)))
	(bind $?total-condition $?condition)
	(bind $?positive-condition (create$))
	(while (> (length$ $?total-condition) 0)
	   do
	   	(bind ?p2 (get-token $?total-condition))
	   	(bind $?first-cond-elem (subseq$ $?total-condition 1 ?p2))
	   	(if (neq (nth$ 2 $?first-cond-elem) naf)
	   	   then
			(bind $?positive-condition (create$ $?positive-condition $?first-cond-elem))
		)
		(bind $?total-condition (subseq$ $?total-condition (+ ?p2 1) (length$ $?total-condition)))
   	)
   	(bind $?naf-object-template (create$))
   	(loop-for-count (?var-count 1 (length$ $?condition-conclusion-vars))
	   do
	   	(bind $?naf-object-template (create$ $?naf-object-template "(" (sym-cat var ?var-count) (nth$ ?var-count $?condition-conclusion-vars) ")"))
	)
	(bind $?naf-object-template (create$ "(" (sym-cat ?rule-name -naf-object) $?naf-object-template ")"))
	(bind $?new-condition (create$ $?positive-condition $?naf-object-template))
	(bind ?positive-naf-rule (str-cat$ (create$ 
		(sym-cat ?rule-name -naf-rule-pos)  ; Name of rule
		$?positive-condition
		=>
		$?naf-object-template
	)))
	;(printout t "transform-naf: ?positive-naf-rule: " ?positive-naf-rule crlf)
	(translate-defeasiblerule ?rule-file ?positive-naf-rule)
	(bind ?naf-counter 0)
	(while (> (length$ $?condition) 0)
	   do
	   	(bind ?p2 (get-token $?condition))
	   	(bind $?first-cond-elem (subseq$ $?condition 1 ?p2))
	   	(if (eq (nth$ 2 $?first-cond-elem) naf)
	   	   then
	   	   	(bind ?naf-counter (+ ?naf-counter 1))
	   		(bind $?naf-cond-part (subseq$ $?first-cond-elem 3 (- (length$ $?first-cond-elem) 1)))
	   		(if (eq (nth$ 2 $?naf-cond-part) and)
	   		   then
	   		   	(bind $?naf-cond-part (subseq$ $?naf-cond-part 3 (- (length$ $?naf-cond-part) 1)))
	   		)
			(bind ?negative-naf-rule (str-cat$ (create$ 
				(sym-cat ?rule-name -naf-rule-neg ?naf-counter)  ; Name of rule
				$?positive-condition
				$?naf-cond-part
				=>
				"(" not $?naf-object-template ")"
			)))
			;(printout t "transform-naf: ?negative-naf-rule: " ?negative-naf-rule crlf)
	   		(translate-defeasiblerule ?rule-file ?negative-naf-rule)
		)
		(bind $?condition (subseq$ $?condition (+ ?p2 1) (length$ $?condition)))
   	)
	(return $?new-condition)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Strict rule declaration ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Input
; (strictrule r2
;	(gap (animal-name ?X))
;   =>
;  	(penguin (animal-name ?X))
; )

; Output
; ------

; rule instance
; *************
; (definstances r2-defeasible-logic-rules 
;	(of strict-rule 
;		(rule-name r2) 
;		(original-rule "(gap (animal-name ?X)) => (penguin (animal-name ?X))")
;		(condition-classes gap)
;		(conclusion-class penguin)
;		(negated no)
;		(deductive-rule r2-deductive)
;		(definitely-rule r2-definitely)
;		(defeasibly-rule r2-defeasibly)
;		(overruled-rule r2-overruled)
;		(defeated-rule) ; not needed - no superiority declaration
;	)
; )

; deductive rule definition
; *************************
;(deductiverule r2-deductive
;	(gap (animal-name ?X))
;	(not (penguin (animal-name ?X)))
;  =>
;  	(penguin (animal-name ?X))
;)

; definite rule definition
; *************************
;(derivedattrule r2-definitely
;	[run-defeasible-rules] <- (DEFEASIBLE-CONTROL)
;	(gap (animal-name ?X) (positive 2))
;	?p <- (penguin (animal-name ?X))
;  =>
;  	?p <- (penguin (positive 2))
;)

; overruled rule definition
; *************************
;(aggregateattrule r2-overruled
;	[run-defeasible-rules] <- (DEFEASIBLE-CONTROL)
;	(gap (animal-name ?X) (positive ?P-VAL&:(>= ?P-VAL 1)) )
;	?r <- (supportive-rule (rule-name ?rn) (negated yes) (conclusion-class penguin))
;	?p <- (penguin (animal-name ?X)(positive-defeated $?PD&:(not (member$ r2 $?PD))))
;  =>
;  	?p <- (penguin (negative-overruled (list ?rn)))
;)

; defeasible rule definition
; **************************
;(derivedattrule r2-defeasibly
;	[run-defeasible-rules] <- (DEFEASIBLE-CONTROL)
;	(gap (animal-name ?X) (positive ?P-VAL&:(>= ?P-VAL 1)) )
;	?p <- (penguin (animal-name ?X) (positive 0) (negative ~2) (positive-overruled $?PO&:(not (member$ r2 $?PO))))
;  =>
;  	?p <- (penguin (positive 1))
;)


(deffunction translate-strictrule (?rule-file ?strictrule-string)
	(bind $?strictrule-def (my-explode$ ?strictrule-string))
	(bind ?strictrule-name (nth$ 1 $?strictrule-def))
	; competing rules
	(bind $?competing-rules (find-competing-rules (symbol-to-instance-name ?strictrule-name)))
	(bind $?strictrule (rest$ $?strictrule-def))
	; Find if there is superiority relation 
	(if (and (eq (nth$ 2 $?strictrule) declare) (eq (nth$ 4 $?strictrule) superior))
	   then
	      	(bind ?p2 (get-token $?strictrule))
		(bind $?superiority-declaration (subseq$ $?strictrule 1 ?p2))
		(bind $?inferior-rule (subseq$ $?superiority-declaration 5 (- ?p2 2)))
	   	;(bind ?inferior-rule (nth$ 5 $?strictrule))
		; competing rules
		(if (> (length$ $?competing-rules) 0)
		   then
			(bind $?inferior-rule (replace-competing-rules ?strictrule-name (create$ $?inferior-rule $$$ $?competing-rules)))
		)
	   	(bind ?defeated-rule-name (sym-cat ?strictrule-name "-defeated"))
	   	(bind $?actual-rule (subseq$ $?strictrule (+ ?p2 1) (length$ $?strictrule)))
	   else
	   	(bind $?inferior-rule (create$))
	   	(bind ?defeated-rule-name nil)
	   	(bind $?actual-rule $?strictrule)
	)
	(bind ?imp_pos (member$ => $?actual-rule))
	(bind $?condition (subseq$ $?actual-rule 1 (- ?imp_pos 1)))
	(if (= (length$ $?condition) 0)
	   then
	   	(bind ?aggregate-att-rule ntm-aggregateattrule)
	   	(bind ?derived-att-rule ntm-derivedattrule)
	   else
	   	(bind ?aggregate-att-rule aggregateattrule)
	   	(bind ?derived-att-rule derivedattrule)
	)
	(if (member$ naf $?condition)
	   then
	   	(bind $?condition-vars (find-vars $?condition))
	   	(bind $?conclusion-vars (find-vars $?conclusion))
	   	(bind $?condition-conclusion-vars (intersection$ (create$ $?condition-vars $$$ $?conclusion-vars)))
	   	(bind $?condition (transform-naf ?rule-file ?strictrule-name (create$ $?condition-conclusion-vars $$$ $?condition)))
	)
	(bind $?conclusion (subseq$ $?actual-rule (+ ?imp_pos 1) (length$ $?actual-rule)))
	(if (eq (nth$ 2 $?conclusion) calc)
	   then
	   	(bind $?actual-conclusion (integrate-calc $?conclusion))
	   	(bind $?pure-conclusion (get-pure-conclusion $?conclusion))
	   	(bind $?calc-test-function (get-calc-test-function $?conclusion))
	   else
	   	(bind $?actual-conclusion $?conclusion)
	   	(bind $?pure-conclusion $?conclusion)
	   	(bind $?calc-test-function (create$))
	)
	; Negated conclusion or not?
	(if (eq (nth$ 2 $?actual-conclusion) not)
	   then
	   	(bind ?negated-status yes)
	   	(bind ?conclusion-class (nth$ 4 $?actual-conclusion))
	   	(bind $?actual-conclusion (subseq$ $?actual-conclusion 3 (- (length$ $?actual-conclusion) 1)))
	   	(bind $?pure-conclusion (subseq$ $?pure-conclusion 3 (- (length$ $?pure-conclusion) 1)))
		(if (eq (nth$ 2 $?conclusion) calc)
		   then
		   	(bind $?conclusion (delete-member$ $?conclusion (create$ "(" not)))
		   	(bind $?conclusion (subseq$ $?conclusion 1 (- (length$ $?conclusion) 1)))
		   else
		   	(bind $?conclusion (subseq$ $?conclusion 3 (- (length$ $?conclusion) 1)))
		)
	   else
	   	(bind ?negated-status no)
	   	(bind ?conclusion-class (nth$ 2 $?actual-conclusion))
	)
	; Build rule instance
	(bind $?rule-instance (create$ 
		"(" make-instance ?strictrule-name of strict-rule 
			"(" rule-name ?strictrule-name ")" 
			;"(" original-rule "\"" (str-cat$ $?strictrule) "\"" ")"
			; "(" condition-classes ??? ")"  	; May not needed!
			"(" conclusion-class ?conclusion-class ")"
			"(" negated ?negated-status ")"
			;"(" conclusion-pattern (get-conclusion-pattern (subseq$ $?conclusion 3 (- (length$ $?conclusion) 1))) ")"
			"(" deductive-rule (sym-cat ?strictrule-name "-deductive") ")"
			"(" support-rule (sym-cat ?strictrule-name "-support") ")"
			"(" definitely-rule (sym-cat ?strictrule-name "-definitely") ")"
			"(" defeasibly-rule (sym-cat ?strictrule-name "-defeasibly") ")"
			"(" overruled-rule (sym-cat ?strictrule-name "-overruled") ")"
			"(" defeated-rule ?defeated-rule-name ")" 
			"(" superior $?inferior-rule ")"
		")"
	))
	(eval (str-cat$ $?rule-instance))
	(send (symbol-to-instance-name ?strictrule-name) put-original-rule ?strictrule-string)
	; Build defeasible class object
	(bind ?conclusion-class-inst (symbol-to-instance-name ?conclusion-class))
	(if (not (instance-existp ?conclusion-class-inst))
	   then
		;(make-instance ?conclusion-class-inst of defeasible-class
		;	(class-name ?conclusion-class)
		;	(rules (symbol-to-instance-name ?strictrule-name))
		;)
		(bind ?mk-inst-string (str-cat$ (create$
			"(" make-instance ?conclusion-class-inst of defeasible-class
				"(" class-name ?conclusion-class ")"
				"(" rules (symbol-to-instance-name ?strictrule-name) ")"
			")"
		)))
		(eval ?mk-inst-string)
		(if (member$ rdfs:Class (funcall class-superclasses defeasible-class))
		   then
		   	(modify-instance ?conclusion-class-inst
		   		(aliases rdfs:seeAlso rdfs:isDefinedBy)
				(rdf:type [rdfs:Class])
				(rdfs:subClassOf [defeasible-class])
				(rdfs:label ?conclusion-class)
			)
			(slot-insert$ ?conclusion-class-inst class-refs 1
				rdfs:isDefinedBy rdfs:Resource
				rdf:type rdfs:Class
				rdfs:seeAlso rdfs:Resource
				rdfs:subClassOf rdfs:Class
				rules defeasible-logic-rule
			)
		)
	   else
	   	(if (neq (class ?conclusion-class-inst) defeasible-class)
	   	   then
	   	   	(bind ?inst-aux (symbol-to-instance-name (sym-cat (instance-name-to-symbol ?conclusion-class-inst) -aux)))
   			(bind ?mk-inst-string (str-cat$ (create$
				"(" make-instance ?inst-aux of defeasible-class ")"
			)))
			(eval ?mk-inst-string)
			;(make-instance ?inst-aux of defeasible-class)
			(shallow-copy ?conclusion-class-inst ?inst-aux)
	   		;(duplicate-instance ?conclusion-class-inst to ?inst-aux)
	   		;(send ?conclusion-class-inst delete)
			;(make-instance ?conclusion-class-inst of defeasible-class)
   			(bind ?mk-inst-string (str-cat$ (create$
				"(" make-instance ?conclusion-class-inst of defeasible-class ")"
			)))
			(eval ?mk-inst-string)
			(shallow-copy ?inst-aux ?conclusion-class-inst)
	   		;(duplicate-instance ?inst-aux to ?conclusion-class-inst)
	   	)
	   	(slot-insert$ ?conclusion-class-inst rules 1 (symbol-to-instance-name ?strictrule-name))
	)
	; Build deductive rule
	(bind $?cond-without-strong-negation (remove-strong-negation $?condition))
	(bind $?deductive-rule (create$
		"(" ntm-deductiverule (sym-cat ?strictrule-name "-deductive")
			$?cond-without-strong-negation
			"(" not $?actual-conclusion ")"
		   =>
		   	$?conclusion
		")"
	))
	(printout ?rule-file (str-cat$ $?deductive-rule) crlf)
	; -----------------------	
	(bind ?var1 (sym-cat "?" (gensym)))
	(bind ?var2 (sym-cat "?" (gensym)))
	(bind ?var3 (sym-cat "$?" (gensym)))
	(bind ?var4 (sym-cat "$?" (gensym)))
	(bind ?var5 (sym-cat "$?" (gensym)))
	(bind ?var6 (sym-cat "$?" (gensym)))
	(if (eq ?negated-status no)
	   then
	   	(bind ?conclusion-status-slot positive)
	   	(bind ?support-slot positive-support)
	   	(bind ?derivator-slot positive-derivator)
	   	;(bind ?supportive-rule-status yes)
	   	(bind ?supportive-rule-status negative-support)
	   	(bind ?overruled-status-slot negative-overruled)
	   	(bind ?defeated-status-slot positive-defeated)
	   else
	   	(bind ?conclusion-status-slot negative)
	   	(bind ?support-slot negative-support)
	   	(bind ?derivator-slot negative-derivator)
	   	;(bind ?supportive-rule-status no)
	   	(bind ?supportive-rule-status positive-support)
	   	(bind ?overruled-status-slot positive-overruled)
	   	(bind ?defeated-status-slot negative-defeated)
	)
	; Build support rule
	(bind $?support-rule (create$
		"(" ntm-aggregateattrule (sym-cat ?strictrule-name "-support") 
			"(" declare "(" priority "(" calc-defeasible-priority 5 (symbol-to-instance-name ?strictrule-name) ")" ")" ")" 
			;"[run-defeasible-rules]" <- "(" DEFEASIBLE-CONTROL ")" 
			$?cond-without-strong-negation 
			?var1 <- (insert$ $?actual-conclusion (length$ $?actual-conclusion) (create$ "(" ?support-slot ?var3 "&" ":" "(" not "(" member$ ?strictrule-name ?var3 ")" ")" ")" ))
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
		=> 
		   	?var1 <- "(" ?conclusion-class "(" ?support-slot "(" list ?strictrule-name ")" ")" ")"
		")"
	))
	(printout ?rule-file (str-cat$ $?support-rule) crlf)
	; Build definite rule
	(bind $?definite-rule-condition (definite-rule-condition $?condition))
	;(printout t "$?definite-rule-condition: " $?definite-rule-condition crlf) ; PROOF
	(bind $?object-vars1 (get-object-address-vars-2 $?definite-rule-condition)) ; PROOF
	(bind $?definite-rule (create$
		"(" ntm-derivedattrule (sym-cat ?strictrule-name "-definitely")
			"(" declare "(" priority "(" calc-defeasible-priority 4 (symbol-to-instance-name ?strictrule-name) ")" ")" ")"
			$?definite-rule-condition
			?var1 <- (insert$ $?actual-conclusion (length$ $?actual-conclusion) "(" ?conclusion-status-slot "~" 2 ")" )
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
		   =>
		   	?var1 <- "(" ?conclusion-class "(" ?conclusion-status-slot 2 ")" "(" ?derivator-slot ?strictrule-name $?object-vars1 ")" ")"   ; PROOF
		")"
	))
	(printout ?rule-file (str-cat$ $?definite-rule) crlf)
	(if (> (token-length $?definite-rule-condition) 0)
	   then
	   	(bind $?negated-condition (create$ $?definite-rule-condition $?calc-test-function))
		(bind $?definite-rule-dot (create$
			"(" ntm-derivedattrule (sym-cat ?strictrule-name "-definitely-dot")
				"(" declare "(" priority "(" calc-defeasible-priority -4 (symbol-to-instance-name ?strictrule-name) ")" ")" ")"
				;?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) "(" ?conclusion-status-slot 2 ")" "(" ?support-slot "$?" ?strictrule-name "$?" ")" )
				?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) "(" ?conclusion-status-slot 2 ")" "(" ?derivator-slot ?strictrule-name "$?" ")" )  ; PROOF
				"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
			   	(if (= (token-length $?negated-condition) 1)
			   	   then
					(create$ "(" not $?negated-condition ")")
				   else
				   	(create$ "(" not "(" and $?negated-condition ")" ")" )
				)
			   =>
			   	?var1 <- "(" ?conclusion-class "(" ?conclusion-status-slot 0 ")" ")"
			")"
		))
		(printout ?rule-file (str-cat$ $?definite-rule-dot) crlf)
	)
	; -----------------------	
	; Build overruled rule
	(bind $?defeasible-rule-condition (defeasible-rule-condition $?condition))
	(bind $?overruled-rule (create$
		"(" ntm-derivedattrule (sym-cat ?strictrule-name "-overruled")
			"(" declare "(" priority "(" calc-defeasible-priority 2 (symbol-to-instance-name ?strictrule-name) ")" ")" ")"
			$?defeasible-rule-condition
			?var1 <- (insert$ $?actual-conclusion (length$ $?actual-conclusion) 
					(create$ "(" ?supportive-rule-status ?var4 ")" 
						"(" ?overruled-status-slot ?var5 "&" ":" "(" not "(" subseq-pos "(" create$ (sym-cat ?strictrule-name "-overruled") ?var4 $$$ ?var5 ")" ")"  ")" ")" 
						"(" ?defeated-status-slot ?var3 "&" ":" "(" not "(" member$ ?strictrule-name ?var3 ")" ")" ")" ))
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
		   =>
		   	"(" calc "(" bind ?var6 "(" create$ (sym-cat ?strictrule-name "-overruled") ?var4 ?var5 ")" ")" ")"
		   	?var1 <- "(" ?conclusion-class "(" ?overruled-status-slot ?var6 ")" ")"
		")"
	))
	(printout ?rule-file (str-cat$ $?overruled-rule) crlf)
	(bind $?overruled-rule-dot (create$
		"(" ntm-derivedattrule (sym-cat ?strictrule-name "-overruled-dot")
			"(" declare "(" priority "(" calc-defeasible-priority -2 (symbol-to-instance-name ?strictrule-name) ")" ")" ")"
			?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) (create$ 
					"(" ?supportive-rule-status ?var4 ")" 
					"(" ?overruled-status-slot ?var5 "&" ":" "(" subseq-pos "(" create$ (sym-cat ?strictrule-name "-overruled") ?var4 $$$ ?var5 ")" ")" ")" 
				))
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
			(if (> (length$ $?defeasible-rule-condition) 0)
			   then
			   	(create$ "(" not "(" and
					$?defeasible-rule-condition
					$?calc-test-function
					?var1 <- "(" (nth$ 2 $?pure-conclusion) 
							"(" ?defeated-status-slot ?var3 "&" ":" "(" not "(" member$ ?strictrule-name ?var3 ")" ")" ")" 
						")"
				")" ")")
			   else
			   	(create$ "(" not 
					?var1 <- "(" (nth$ 2 $?pure-conclusion) 
							"(" ?defeated-status-slot ?var3 "&" ":" "(" not "(" member$ ?strictrule-name ?var3 ")" ")" ")" 
						")"
				")" )
			)
		   =>
		   	"(" calc "(" bind ?var6 "(" delete-member$ ?var5 "(" create$ (sym-cat ?strictrule-name "-overruled") ?var4 ")" ")" ")" ")" 
		   	?var1 <- "(" ?conclusion-class "(" ?overruled-status-slot ?var6 ")" ")"
		")"
	))
	(printout ?rule-file (str-cat$ $?overruled-rule-dot) crlf)
	; -----------------------
	(if (eq ?conclusion-status-slot negative)
	   then
	   	(bind ?opposite-conclusion-status-slot positive)
	   	(bind ?overruled-status-slot negative-overruled)
	   else
	   	(bind ?opposite-conclusion-status-slot negative)
	   	(bind ?overruled-status-slot positive-overruled)
	)
	; Build defeasible rule
	(bind $?object-vars2 (get-object-address-vars-2 $?defeasible-rule-condition)) ; PROOF
	(bind $?defeasible-rule (create$
		"(" ntm-derivedattrule (sym-cat ?strictrule-name "-defeasibly")
			"(" declare "(" priority "(" calc-defeasible-priority 1 (symbol-to-instance-name ?strictrule-name) ")" ")" ")"
			$?defeasible-rule-condition
			?var1 <- (insert$ $?actual-conclusion (length$ $?actual-conclusion) "(" ?conclusion-status-slot 0 ")" "(" ?opposite-conclusion-status-slot "~" 2 ")" (create$ "(" ?overruled-status-slot ?var3 "&" ":" "(" not "(" member$ ?strictrule-name ?var3 ")" ")" ")" ))
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
		   =>
		   	?var1 <- "(" ?conclusion-class "(" ?conclusion-status-slot 1 ")" "(" ?derivator-slot ?strictrule-name $?object-vars2 ")" ")"   ; PROOF
		")"
	))
	(printout ?rule-file (str-cat$ $?defeasible-rule) crlf)
	(bind $?defeasible-rule-dot (create$
		"(" ntm-derivedattrule (sym-cat ?strictrule-name "-defeasibly-dot")
			"(" declare "(" priority "(" calc-defeasible-priority -1 (symbol-to-instance-name ?strictrule-name) ")" ")" ")"
			;?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) "(" ?conclusion-status-slot 1 ")" "(" ?support-slot "$?" ?strictrule-name "$?" ")" )
			?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) "(" ?conclusion-status-slot 1 ")" "(" ?derivator-slot ?strictrule-name "$?" ")")   ; PROOF
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
			(if (> (length$ $?defeasible-rule-condition) 0)
			   then
			   	(create$ "(" not "(" and
						$?defeasible-rule-condition
						$?calc-test-function
						?var1 <- "(" (nth$ 2 $?pure-conclusion) 
								"(" ?opposite-conclusion-status-slot "~" 2 ")" 
								"(" ?overruled-status-slot ?var3 "&" ":" "(" not "(" member$ ?strictrule-name ?var3 ")" ")" ")" ")"
				")" ")")
			   else
			   	(create$ "(" not 
						?var1 <- "(" (nth$ 2 $?pure-conclusion) 
								"(" ?opposite-conclusion-status-slot "~" 2 ")" 
								"(" ?overruled-status-slot ?var3 "&" ":" "(" not "(" member$ ?strictrule-name ?var3 ")" ")" ")" ")"
				")" )
			)
		   =>
		   	?var1 <- "(" ?conclusion-class "(" ?conclusion-status-slot 0 ")" ")"
		")"
	))
	(printout ?rule-file (str-cat$ $?defeasible-rule-dot) crlf)
	; -----------------------
	; Build defeated rule only if there is a declare superior statement
	(if (neq ?defeated-rule-name nil)
	   then
		(if (eq ?negated-status no)
		   then
		   	(bind ?defeated-status-slot negative-defeated)
		   else
		   	(bind ?defeated-status-slot positive-defeated)
		)
		(bind $?defeated-rule (create$
			"(" ntm-derivedattrule ?defeated-rule-name
				"(" declare "(" priority "(" calc-defeasible-priority 3 (symbol-to-instance-name ?strictrule-name) ")" ")" ")"
				$?defeasible-rule-condition
				?var1 <- (insert$ $?actual-conclusion (length$ $?actual-conclusion) 
						"(" ?defeated-status-slot ?var4 "&" ":" "(" not "(" subseq-pos "(" create$ ?defeated-rule-name $?inferior-rule $$$ ?var4 ")" ")" ")" ")" )
				"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
			   =>
			   	"(" calc "(" bind ?var3 "(" create$ ?defeated-rule-name $?inferior-rule ?var4 ")" ")" ")"
			   	?var1 <- "(" ?conclusion-class "(" ?defeated-status-slot ?var3 ")" ")"
			")"
		))
		(printout ?rule-file (str-cat$ $?defeated-rule) crlf)
		(if (> (token-length $?defeasible-rule-condition) 0)
		   then
		   	(bind $?negated-condition (create$ $?defeasible-rule-condition $?calc-test-function))
			(bind $?defeated-rule-dot (create$
				"(" ntm-derivedattrule (sym-cat ?defeated-rule-name "-dot")
					"(" declare "(" priority "(" calc-defeasible-priority -3 (symbol-to-instance-name ?strictrule-name) ")" ")" ")"
					?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) 
							"(" ?defeated-status-slot ?var4 "&" ":" "(" subseq-pos "(" create$ ?defeated-rule-name $?inferior-rule $$$ ?var4 ")" ")" ")" )
					(if (> (token-length $?negated-condition) 1)
					   then
					   	(create$ "(" not "(" and 
					   		$?negated-condition
					   	")" ")"	 )
					   else
				   		(create$ "(" not $?negated-condition ")" )
					)
				   =>
				   	"(" calc "(" bind ?var3 "(" delete-member$ ?var4 "(" create$ ?defeated-rule-name $?inferior-rule ")" ")" ")" ")"
				   	?var1 <- "(" ?conclusion-class "(" ?defeated-status-slot ?var3 ")" ")"
				")"
			))
			(printout ?rule-file (str-cat$ $?defeated-rule-dot) crlf)
		)
	)
	; competing rules
	(if (> (length$ $?competing-rules) 0)
	   then
	      	(bind ?comp-rule-constr-id (find-competing-rule-construct (symbol-to-instance-name ?strictrule-name)))
	   	(bind $?condition-vars (find-vars $?condition))
	   	(bind $?conclusion-vars (find-vars $?conclusion))
	   	(bind $?condition-conclusion-vars (intersection$ (create$ $?condition-vars $$$ $?conclusion-vars)))
	   	(while (> (length$ $?competing-rules) 0)
	   	   do
	   	   	(bind ?first-competing-rule (nth$ 1 $?competing-rules))
	   	   	(bind $?competing-rules (rest$ $?competing-rules))
	   		(bind $?new-condition-conclusion-vars (create$))
	   		(bind $?new-condition $?condition)
	   		(bind ?extra-rule-name (sym-cat ?strictrule-name -comp-rule- ?first-competing-rule))
	   		(loop-for-count (?n 1 (length$ $?condition-conclusion-vars))
	   		   do
	   		   	(bind ?condition-conclusion-var (nth$ ?n $?condition-conclusion-vars))
	   		   	(bind ?new-condition-conclusion-var (sym-cat ?condition-conclusion-var - ?extra-rule-name))
	   			(bind $?new-condition-conclusion-vars (create$ $?new-condition-conclusion-vars ?new-condition-conclusion-var))
	   			(bind $?new-condition (replace-member$ $?new-condition ?new-condition-conclusion-var ?condition-conclusion-var))
	   		)
	   		(if (not (instance-existp (symbol-to-instance-name ?extra-rule-name)))
	   		   then
	   			(make-instance ?extra-rule-name of extra-competing-rule
	   				(competing-rule-construct ?comp-rule-constr-id)
	   				(rule-type strictrule)
					(first-rule ?strictrule-name)
					(second-rule ?first-competing-rule)
					(first-rule-condition $?new-condition)
					(first-rule-condition-conclusion-vars $?new-condition-conclusion-vars)
				)
			   else
			   	(modify-instance (symbol-to-instance-name ?extra-rule-name)
					(first-rule-condition $?new-condition)
					(first-rule-condition-conclusion-vars $?new-condition-conclusion-vars)
				)
			)
	   		(bind ?opposite-extra-rule-name (sym-cat ?first-competing-rule -comp-rule- ?strictrule-name))
	   		(if (eq (nth$ 2 $?conclusion) calc)
			   then
			   	(bind ?p2 (get-token $?conclusion))
				(bind $?calc-expr (subseq$ $?conclusion 1 ?p2))
			   else
			   	(bind $?calc-expr (create$))
			)
			(if (eq ?negated-status yes)
			   then
			   	(bind $?new-conclusion (create$ $?calc-expr $?pure-conclusion))
			   else
			   	(bind $?new-conclusion (create$ $?calc-expr "(" not $?pure-conclusion ")" ))
			)
	   		(if (not (instance-existp (symbol-to-instance-name ?opposite-extra-rule-name)))
	   		   then
	   			(make-instance ?opposite-extra-rule-name of extra-competing-rule
	   				(competing-rule-construct ?comp-rule-constr-id)
	   				(rule-type strictrule)
					(first-rule ?first-competing-rule)
					(second-rule ?strictrule-name)
					(second-rule-condition $?condition)
					(second-rule-condition-conclusion-vars $?condition-conclusion-vars)
					(second-rule-conclusion $?new-conclusion)
				)
			   else
			   	(modify-instance (symbol-to-instance-name ?opposite-extra-rule-name)
					(second-rule-condition $?condition)
					(second-rule-condition-conclusion-vars $?condition-conclusion-vars)
					(second-rule-conclusion $?new-conclusion)
				)
			)
		)
	)
	(return (symbol-to-instance-name ?strictrule-name))
)

; Translation for all strict rules
(deffunction translate-strictrules (?rule-file $?strictrule-strings)
	(while (> (length$ $?strictrule-strings) 0)
	   do
	   	(bind ?rule-oid (translate-strictrule ?rule-file (nth$ 1 $?strictrule-strings)))
	   	(send ?rule-oid put-system no)
	   	(bind $?strictrule-strings (rest$ $?strictrule-strings))
	)
	TRUE
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Defeasible rule declaration ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Input
;(defeasiblerule r5
;	(declare (superior r4))
;	(penguin (animal-name ?X))
;  =>
;  	(not (flies (animal-name ?X)))
;)


; Output
; ------

; rule instance
; *************
;(definstances r5-defeasible-logic-rules 
;	(of defeasible-rule 
;		(rule-name r5) 
;		(original-rule "(declare (superior r4)) (penguin (animal-name ?X)) => (not (flies (animal-name ?X)))")
;		(condition-classes penguin)
;		(conclusion-class flies)
;		(negated yes)
;		(superior r4)
;		(deductive-rule r5-deductive)
;		(defeasibly-rule r5-defeasibly)
;		(overruled-rule r5-overruled)
;		(defeated-rule r5-defeated) ; there is superiority declaration!
;	)
;)

; deductive rule definition
; *************************
;(ntm-deductiverule r5-deductive
;	(penguin (animal-name ?X))
;	(not (flies (animal-name ?X)))
;  =>
;  	(flies (animal-name ?X))
;)

; defeated rule definition
; ************************
;(derivedattrule r5-defeated
;	[run-defeasible-rules] <- (DEFEASIBLE-CONTROL)
;	(penguin (animal-name ?X) (positive ?P-VAL&:(>= ?P-VAL 1)))
;	?p <- (flies (animal-name ?X))
;  =>
;  	(calc (bind $?rules (create$ r4)))
;  	?p <- (flies (positive-defeated $?rules))
;)

; overruled rule definition
; *************************
;(aggregateattrule r5-overruled
;	[run-defeasible-rules] <- (DEFEASIBLE-CONTROL)
;	(penguin (animal-name ?X) (positive ?P-VAL&:(>= ?P-VAL 1)) )
;	?r <- (supportive-rule (rule-name ?rn) (negated no) (conclusion-class flies))
;	?p <- (flies (animal-name ?X)(negative-defeated $?PD&:(not (member$ r5 $?PD))))
;  =>
;  	?p <- (flies (positive-overruled (list ?rn)))
;)

; defeasible rule definition
; **************************
;(derivedattrule r5-defeasibly
;	[run-defeasible-rules] <- (DEFEASIBLE-CONTROL)
;	(penguin (animal-name ?X) (positive ?P-VAL&:(>= ?P-VAL 1)) )
;	?p <- (flies (animal-name ?X) (negative 0) (positive ~2)(negative-overruled $?PO&:(not (member$ r5 $?PO))))
;  =>
;  	?p <- (flies (negative 1))
;)

(deffunction translate-defeasiblerule (?rule-file ?defeasiblerule-string)
	(bind $?defeasiblerule-def (my-explode$ ?defeasiblerule-string))
	(bind ?defeasiblerule-name (nth$ 1 $?defeasiblerule-def))
	; competing rules
	(bind $?competing-rules (find-competing-rules (symbol-to-instance-name ?defeasiblerule-name)))
	(bind $?defeasiblerule (rest$ $?defeasiblerule-def))
	; Find if there is superiority relation 
	(if (and (eq (nth$ 2 $?defeasiblerule) declare) (eq (nth$ 4 $?defeasiblerule) superior))
	   then
	      	(bind ?p2 (get-token $?defeasiblerule))
		(bind $?superiority-declaration (subseq$ $?defeasiblerule 1 ?p2))
		(bind $?inferior-rule (subseq$ $?superiority-declaration 5 (- ?p2 2)))
		; competing rules
		(if (> (length$ $?competing-rules) 0)
		   then
			(bind $?inferior-rule (replace-competing-rules ?defeasiblerule-name (create$ $?inferior-rule $$$ $?competing-rules)))
		)
	   	(bind ?defeated-rule-name (sym-cat ?defeasiblerule-name "-defeated"))
	   	(bind $?actual-rule (subseq$ $?defeasiblerule (+ ?p2 1) (length$ $?defeasiblerule)))
	   else
	   	(bind $?inferior-rule (create$))
	   	(bind ?defeated-rule-name nil)
	   	(bind $?actual-rule $?defeasiblerule)
	)
	(bind ?imp_pos (member$ => $?actual-rule))
	(bind $?condition (subseq$ $?actual-rule 1 (- ?imp_pos 1)))
	(if (= (length$ $?condition) 0)
	   then
	   	(bind ?aggregate-att-rule ntm-aggregateattrule)
	   	(bind ?derived-att-rule ntm-derivedattrule)
	   else
	   	(bind ?aggregate-att-rule aggregateattrule)
	   	(bind ?derived-att-rule derivedattrule)
	)
	(bind $?conclusion (subseq$ $?actual-rule (+ ?imp_pos 1) (length$ $?actual-rule)))
	(if (member$ naf $?condition)
	   then
	   	(bind $?condition-vars (find-vars $?condition))
	   	(bind $?conclusion-vars (find-vars $?conclusion))
	   	(bind $?condition-conclusion-vars (intersection$ (create$ $?condition-vars $$$ $?conclusion-vars)))
	   	(bind $?condition (transform-naf ?rule-file ?defeasiblerule-name (create$ $?condition-conclusion-vars $$$ $?condition)))
	)
	(if (eq (nth$ 2 $?conclusion) calc)
	   then
	   	(bind $?actual-conclusion (integrate-calc $?conclusion))
	   	(bind $?pure-conclusion (get-pure-conclusion $?conclusion))
	   	(bind $?calc-test-function (get-calc-test-function $?conclusion))
	   else
	   	(bind $?actual-conclusion $?conclusion)
	   	(bind $?pure-conclusion $?conclusion)
	   	(bind $?calc-test-function (create$))
	)
	; Negated conclusion or not?
	(if (eq (nth$ 2 $?actual-conclusion) not)
	   then
	   	(bind ?negated-status yes)
	   	(bind ?conclusion-class (nth$ 4 $?actual-conclusion))
	   	(bind $?actual-conclusion (subseq$ $?actual-conclusion 3 (- (length$ $?actual-conclusion) 1)))
	   	(bind $?pure-conclusion (subseq$ $?pure-conclusion 3 (- (length$ $?pure-conclusion) 1)))
		(if (eq (nth$ 2 $?conclusion) calc)
		   then
		   	(bind $?conclusion (delete-member$ $?conclusion (create$ "(" not)))
		   	(bind $?conclusion (subseq$ $?conclusion 1 (- (length$ $?conclusion) 1)))
		   else
		   	(bind $?conclusion (subseq$ $?conclusion 3 (- (length$ $?conclusion) 1)))
		)
	   else
	   	(bind ?negated-status no)
	   	(bind ?conclusion-class (nth$ 2 $?actual-conclusion))
	)
	; Build rule instance
	;(bind ?new-rule-string ( str-cat$ ( create$ "\"" $?defeasiblerule "\"" ) ) )
	;(printout t "new rule string:   " ?new-rule-string crlf)
	(bind $?rule-instance (create$ 
		"(" make-instance ?defeasiblerule-name of defeasible-rule 
			"(" rule-name ?defeasiblerule-name ")" 
			;"(" original-rule ?defeasiblerule-string ")"
			; "(" condition-classes ??? ")"  	; May not needed!
			"(" conclusion-class ?conclusion-class ")"
			"(" negated ?negated-status ")"
			;"(" conclusion-pattern (get-conclusion-pattern (subseq$ $?conclusion 3 (- (length$ $?conclusion) 1))) ")"
			"(" deductive-rule (sym-cat ?defeasiblerule-name "-deductive") ")"
			"(" support-rule (sym-cat ?defeasiblerule-name "-support") ")"
			"(" defeasibly-rule (sym-cat ?defeasiblerule-name "-defeasibly") ")"
			"(" overruled-rule (sym-cat ?defeasiblerule-name "-overruled") ")"
			"(" defeated-rule ?defeated-rule-name ")" 
			"(" superior $?inferior-rule ")"
		")"
	))
	(eval (str-cat$ $?rule-instance))
	(send (symbol-to-instance-name ?defeasiblerule-name) put-original-rule ?defeasiblerule-string)
	; Build defeasible class object
	(bind ?conclusion-class-inst (symbol-to-instance-name ?conclusion-class))
	(if (not (instance-existp ?conclusion-class-inst))
	   then
		;(make-instance ?conclusion-class-inst of defeasible-class
		;	(class-name ?conclusion-class)
		;	(rules (symbol-to-instance-name ?defeasiblerule-name))
		;)
		(bind ?mk-inst-string (str-cat$ (create$
			"(" make-instance ?conclusion-class-inst of defeasible-class
				"(" class-name ?conclusion-class ")"
				"(" rules (symbol-to-instance-name ?defeasiblerule-name) ")"
			")"
		)))
		(eval ?mk-inst-string)
		(if (member$ rdfs:Class (funcall class-superclasses defeasible-class))
		   then
		   	(modify-instance ?conclusion-class-inst
		   		(aliases rdfs:seeAlso rdfs:isDefinedBy)
				(rdf:type [rdfs:Class])
				(rdfs:subClassOf [defeasible-class])
				(rdfs:label ?conclusion-class)
			)
			(slot-insert$ ?conclusion-class-inst class-refs 1
				rdfs:isDefinedBy rdfs:Resource
				rdf:type rdfs:Class
				rdfs:seeAlso rdfs:Resource
				rdfs:subClassOf rdfs:Class
				rules defeasible-logic-rule
			)
		)
	   else
	   	(if (neq (class ?conclusion-class-inst) defeasible-class)
	   	   then
	   	   	(bind ?inst-aux (symbol-to-instance-name (sym-cat (instance-name-to-symbol ?conclusion-class-inst) -aux)))
			;(make-instance ?inst-aux of defeasible-class)
	   		(bind ?mk-inst-string (str-cat$ (create$
				"(" make-instance ?inst-aux of defeasible-class ")"
			)))
			(eval ?mk-inst-string)
			(shallow-copy ?conclusion-class-inst ?inst-aux)
	   		;(duplicate-instance ?conclusion-class-inst to ?inst-aux)
	   		;(send ?conclusion-class-inst delete)
			;(make-instance ?conclusion-class-inst of defeasible-class)
	   		(bind ?mk-inst-string (str-cat$ (create$
				"(" make-instance ?conclusion-class-inst of defeasible-class ")"
			)))
			(eval ?mk-inst-string)
			(shallow-copy ?inst-aux ?conclusion-class-inst)
	   		;(duplicate-instance ?inst-aux to ?conclusion-class-inst)
	   	)
	   	(slot-insert$ ?conclusion-class-inst rules 1 (symbol-to-instance-name ?defeasiblerule-name))
	)
	; Build deductive rule
	(bind $?cond-without-strong-negation (remove-strong-negation $?condition))
	(bind $?deductive-rule (create$
		"(" ntm-deductiverule (sym-cat ?defeasiblerule-name "-deductive")
			$?cond-without-strong-negation
			"(" not $?actual-conclusion ")"
		   =>
		   	$?conclusion
		")"
	))
	(printout ?rule-file (str-cat$ $?deductive-rule) crlf)
	; -----------------------	
	(bind ?var1 (sym-cat "?" (gensym)))
	(bind ?var2 (sym-cat "?" (gensym)))
	(bind ?var3 (sym-cat "$?" (gensym)))
	(bind ?var4 (sym-cat "$?" (gensym)))
	(bind ?var5 (sym-cat "$?" (gensym)))
	(bind ?var6 (sym-cat "$?" (gensym)))
	(if (eq ?negated-status no)
	   then
	   	(bind ?conclusion-status-slot positive)
	   	(bind ?derivator-slot positive-derivator)
	   	(bind ?support-slot positive-support)
;	   	(bind ?supportive-rule-status yes)
	   	(bind ?supportive-rule-status negative-support)
	   	(bind ?overruled-status-slot negative-overruled)
	   	(bind ?defeated-status-slot positive-defeated)
	   else
	   	(bind ?support-slot negative-support)
	   	(bind ?conclusion-status-slot negative)
	   	(bind ?derivator-slot negative-derivator)
	   	;(bind ?supportive-rule-status no)
	   	(bind ?supportive-rule-status positive-support)
	   	(bind ?overruled-status-slot positive-overruled)
	   	(bind ?defeated-status-slot negative-defeated)
	)
	; Build support rule
	(bind $?support-rule (create$
		"(" ntm-aggregateattrule (sym-cat ?defeasiblerule-name "-support") 
			"(" declare "(" priority "(" calc-defeasible-priority 5 (symbol-to-instance-name ?defeasiblerule-name) ")" ")" ")" 
			$?cond-without-strong-negation 
			?var1 <- (insert$ $?actual-conclusion (length$ $?actual-conclusion) (create$ "(" ?support-slot ?var3 "&" ":" "(" not "(" member$ ?defeasiblerule-name ?var3 ")" ")" ")" ))
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
		=> 
		   	?var1 <- "(" ?conclusion-class "(" ?support-slot "(" list ?defeasiblerule-name ")" ")" ")"
		")"
	))
	(printout ?rule-file (str-cat$ $?support-rule) crlf)
	; Build overruled rule
	(bind $?defeasible-rule-condition (defeasible-rule-condition $?condition))
	(bind $?overruled-rule (create$
		"(" ntm-derivedattrule (sym-cat ?defeasiblerule-name "-overruled")
			"(" declare "(" priority "(" calc-defeasible-priority 2 (symbol-to-instance-name ?defeasiblerule-name) ")" ")" ")"
			$?defeasible-rule-condition
			?var1 <- (insert$ $?actual-conclusion (length$ $?actual-conclusion) 
					(create$ "(" ?supportive-rule-status ?var4 ")" 
						"(" ?overruled-status-slot ?var5 "&" ":" "(" not "(" subseq-pos "(" create$ (sym-cat ?defeasiblerule-name "-overruled") ?var4 $$$ ?var5 ")" ")" ")" ")" 
						"(" ?defeated-status-slot ?var3 "&" ":" "(" not "(" member$ ?defeasiblerule-name ?var3 ")" ")" ")" ))
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
		   =>
		   	"(" calc "(" bind ?var6 "(" create$ (sym-cat ?defeasiblerule-name "-overruled") ?var4 ?var5 ")" ")" ")"
		   	?var1 <- "(" ?conclusion-class "(" ?overruled-status-slot ?var6 ")" ")"
		")"
	))
	(printout ?rule-file (str-cat$ $?overruled-rule) crlf)
	(bind $?overruled-rule-dot (create$
		"(" ntm-derivedattrule (sym-cat ?defeasiblerule-name "-overruled-dot")
			"(" declare "(" priority "(" calc-defeasible-priority -2 (symbol-to-instance-name ?defeasiblerule-name) ")" ")" ")"
			?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) (create$ 
					"(" ?supportive-rule-status ?var4 ")" 
					"(" ?overruled-status-slot ?var5 "&" ":" "(" subseq-pos "(" create$ (sym-cat ?defeasiblerule-name "-overruled") ?var4 $$$ ?var5 ")" ")" ")"
				))
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
			(if (> (length$ $?defeasible-rule-condition) 0)
			   then
			   	(create$ "(" not "(" and
					$?defeasible-rule-condition
					$?calc-test-function
					?var1 <- "(" (nth$ 2 $?pure-conclusion) 
							"(" ?defeated-status-slot ?var3 "&" ":" "(" not "(" member$ ?defeasiblerule-name ?var3 ")" ")" ")" 
						")"
				")" ")")
			   else
			   	(create$ "(" not 
					?var1 <- "(" (nth$ 2 $?pure-conclusion) 
							"(" ?defeated-status-slot ?var3 "&" ":" "(" not "(" member$ ?defeasiblerule-name ?var3 ")" ")" ")" 
						")"
				")" )
			)
		   =>
		   	"(" calc "(" bind ?var6 "(" delete-member$ ?var5 "(" create$ (sym-cat ?defeasiblerule-name "-overruled") ?var4 ")" ")" ")" ")"
		   	?var1 <- "(" ?conclusion-class "(" ?overruled-status-slot ?var6 ")" ")"
		")"
	))
	(printout ?rule-file (str-cat$ $?overruled-rule-dot) crlf)
	; -----------------------
	(if (eq ?conclusion-status-slot negative)
	   then
	   	(bind ?opposite-conclusion-status-slot positive)
	   	(bind ?overruled-status-slot negative-overruled)
	   else
	   	(bind ?opposite-conclusion-status-slot negative)
	   	(bind ?overruled-status-slot positive-overruled)
	)
	; Build defeasible rule
	; Defeasible rules need a counting mechanism + a derivators mechanism, just like
	; deductive rules
	; Here we only support a derivators mechanism, based solely on the rule that derived a specific
	; conclusion. In the future this should be extended with a counter mechanism and a mechanism that
	; keeps not only the rule that derived a conclusion, but also all the variables of the condition
	; Furthermore, here we suppose that each conclusion is supported by only one rule,
	; which is oversimplified.
	;(printout t "$?defeasible-rule-condition: " $?defeasible-rule-condition crlf) ; PROOF
	(bind $?object-vars (get-object-address-vars-2 $?defeasible-rule-condition))
	(bind $?defeasible-rule (create$
		"(" ntm-derivedattrule (sym-cat ?defeasiblerule-name "-defeasibly")
			"(" declare "(" priority "(" calc-defeasible-priority 1 (symbol-to-instance-name ?defeasiblerule-name) ")" ")" ")"
			$?defeasible-rule-condition
			?var1 <- (insert$ $?actual-conclusion (length$ $?actual-conclusion) "(" ?conclusion-status-slot 0 ")" "(" ?opposite-conclusion-status-slot "~" 2 ")" (create$ "(" ?overruled-status-slot ?var3 "&" ":" "(" not "(" member$ ?defeasiblerule-name ?var3 ")" ")" ")" ))
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
		   =>
;		   	?var1 <- "(" ?conclusion-class "(" ?conclusion-status-slot 1 ")" "(" ?derivator-slot ?defeasiblerule-name ")" ")"   ; PROOF
		   	?var1 <- "(" ?conclusion-class "(" ?conclusion-status-slot 1 ")" "(" ?derivator-slot ?defeasiblerule-name $?object-vars ")" ")"   ; PROOF
		")"
	))
	(printout ?rule-file (str-cat$ $?defeasible-rule) crlf)
	(bind $?defeasible-rule-dot (create$
		"(" ntm-derivedattrule (sym-cat ?defeasiblerule-name "-defeasibly-dot")
			"(" declare "(" priority "(" calc-defeasible-priority -1 (symbol-to-instance-name ?defeasiblerule-name) ")" ")" ")"
			;?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) "(" ?conclusion-status-slot 1 ")" "(" ?support-slot "$?" ?defeasiblerule-name "$?" ")")
			?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) "(" ?conclusion-status-slot 1 ")" "(" ?derivator-slot ?defeasiblerule-name "$?" ")")   ; PROOF
			"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
			(if (> (length$ $?defeasible-rule-condition) 0)
			   then
			   	(create$ "(" not "(" and
						$?defeasible-rule-condition
						$?calc-test-function
						?var1 <- "(" (nth$ 2 $?pure-conclusion) 
								"(" ?opposite-conclusion-status-slot "~" 2 ")" 
								"(" ?overruled-status-slot ?var3 "&" ":" "(" not "(" member$ ?defeasiblerule-name ?var3 ")" ")" ")" ")"
				")" ")")
			   else
			   	(create$ "(" not 
						?var1 <- "(" (nth$ 2 $?pure-conclusion) 
								"(" ?opposite-conclusion-status-slot "~" 2 ")" 
								"(" ?overruled-status-slot ?var3 "&" ":" "(" not "(" member$ ?defeasiblerule-name ?var3 ")" ")" ")" ")"
				")" )
			)
		   =>
		   	?var1 <- "(" ?conclusion-class "(" ?conclusion-status-slot 0 ")" ")"
		")"
	))
	(printout ?rule-file (str-cat$ $?defeasible-rule-dot) crlf)
	; -----------------------
	; Build defeated rule only if there is a declare superior statement
	(if (neq ?defeated-rule-name nil)
	   then
		(if (eq ?negated-status no)
		   then
		   	(bind ?defeated-status-slot negative-defeated)
		   else
		   	(bind ?defeated-status-slot positive-defeated)
		)
		(bind $?defeated-rule (create$
			"(" ntm-derivedattrule ?defeated-rule-name
				"(" declare "(" priority "(" calc-defeasible-priority 3 (symbol-to-instance-name ?defeasiblerule-name) ")" ")" ")"
				$?defeasible-rule-condition
				?var1 <- (insert$ $?actual-conclusion (length$ $?actual-conclusion) 
						"(" ?defeated-status-slot ?var4 "&" ":" "(" not "(" subseq-pos "(" create$ ?defeated-rule-name $?inferior-rule $$$ ?var4 ")" ")" ")" ")" )
				"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
			   =>
			   	"(" calc "(" bind ?var3 "(" create$ ?defeated-rule-name $?inferior-rule ?var4 ")" ")" ")"
			   	?var1 <- "(" ?conclusion-class "(" ?defeated-status-slot ?var3 ")" ")"
			")"
		))
		(printout ?rule-file (str-cat$ $?defeated-rule) crlf)
		(if (> (token-length $?defeasible-rule-condition) 0)
		   then
		   	(bind $?negated-condition (create$ $?defeasible-rule-condition $?calc-test-function))
			(bind $?defeated-rule-dot (create$
				"(" ntm-derivedattrule (sym-cat ?defeated-rule-name "-dot")
					"(" declare "(" priority "(" calc-defeasible-priority -3 (symbol-to-instance-name ?defeasiblerule-name) ")" ")" ")"
					?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) 
							"(" ?defeated-status-slot ?var4 "&" ":" "(" subseq-pos "(" create$ ?defeated-rule-name $?inferior-rule $$$ ?var4 ")" ")" ")" )
					"(" test "(" eq "(" class ?var1 ")" ?conclusion-class ")" ")"
					(if (> (token-length $?negated-condition) 1)
					   then
					   	(create$ "(" not "(" and 
					   		$?negated-condition
					   	")" ")"	 )
					   else
				   		(create$ "(" not $?negated-condition ")" )
					)
				   =>
				   	"(" calc "(" bind ?var3 "(" delete-member$ ?var4 "(" create$ ?defeated-rule-name $?inferior-rule ")" ")" ")" ")"
				   	?var1 <- "(" ?conclusion-class "(" ?defeated-status-slot ?var3 ")" ")"
				")"
			))
			(printout ?rule-file (str-cat$ $?defeated-rule-dot) crlf)
		)
	)
	; competing rules
	(if (> (length$ $?competing-rules) 0)
	   then
	   	(bind ?comp-rule-constr-id (find-competing-rule-construct (symbol-to-instance-name ?defeasiblerule-name)))
	   	(bind $?condition-vars (find-vars $?condition))
	   	(bind $?conclusion-vars (find-vars $?conclusion))
	   	(bind $?condition-conclusion-vars (intersection$ (create$ $?condition-vars $$$ $?conclusion-vars)))
	   	(while (> (length$ $?competing-rules) 0)
	   	   do
	   	   	(bind ?first-competing-rule (nth$ 1 $?competing-rules))
	   	   	(bind $?competing-rules (rest$ $?competing-rules))
	   		(bind $?new-condition-conclusion-vars (create$))
	   		(bind $?new-condition $?condition)
	   		(bind ?extra-rule-name (sym-cat ?defeasiblerule-name -comp-rule- ?first-competing-rule))
	   		(loop-for-count (?n 1 (length$ $?condition-conclusion-vars))
	   		   do
	   		   	(bind ?condition-conclusion-var (nth$ ?n $?condition-conclusion-vars))
	   		   	(bind ?new-condition-conclusion-var (sym-cat ?condition-conclusion-var - ?extra-rule-name))
	   			(bind $?new-condition-conclusion-vars (create$ $?new-condition-conclusion-vars ?new-condition-conclusion-var))
	   			(bind $?new-condition (replace-member$ $?new-condition ?new-condition-conclusion-var ?condition-conclusion-var))
	   		)
	   		(if (not (instance-existp (symbol-to-instance-name ?extra-rule-name)))
	   		   then
	   			(make-instance ?extra-rule-name of extra-competing-rule
	   				(competing-rule-construct ?comp-rule-constr-id)
	   				(rule-type defeasiblerule)
					(first-rule ?defeasiblerule-name)
					(second-rule ?first-competing-rule)
					(first-rule-condition $?new-condition)
					(first-rule-condition-conclusion-vars $?new-condition-conclusion-vars)
				)
			   else
			   	(modify-instance (symbol-to-instance-name ?extra-rule-name)
					(first-rule-condition $?new-condition)
					(first-rule-condition-conclusion-vars $?new-condition-conclusion-vars)
				)
			)
	   		(bind ?opposite-extra-rule-name (sym-cat ?first-competing-rule -comp-rule- ?defeasiblerule-name))
	   		(if (eq (nth$ 2 $?conclusion) calc)
			   then
			   	(bind ?p2 (get-token $?conclusion))
				(bind $?calc-expr (subseq$ $?conclusion 1 ?p2))
			   else
			   	(bind $?calc-expr (create$))
			)
			(if (eq ?negated-status yes)
			   then
			   	(bind $?new-conclusion (create$ $?calc-expr $?pure-conclusion))
			   else
			   	(bind $?new-conclusion (create$ $?calc-expr "(" not $?pure-conclusion ")" ))
			)
	   		(if (not (instance-existp (symbol-to-instance-name ?opposite-extra-rule-name)))
	   		   then
	   			(make-instance ?opposite-extra-rule-name of extra-competing-rule
	   				(competing-rule-construct ?comp-rule-constr-id)
	   				(rule-type defeasiblerule)
					(first-rule ?first-competing-rule)
					(second-rule ?defeasiblerule-name)
					(second-rule-condition $?condition)
					(second-rule-condition-conclusion-vars $?condition-conclusion-vars)
					(second-rule-conclusion $?new-conclusion)
				)
			   else
			   	(modify-instance (symbol-to-instance-name ?opposite-extra-rule-name)
					(second-rule-condition $?condition)
					(second-rule-condition-conclusion-vars $?condition-conclusion-vars)
					(second-rule-conclusion $?new-conclusion)
				)
			)
		)
	)
	(return (symbol-to-instance-name ?defeasiblerule-name))
)

; Translation for all defeasible rules
(deffunction translate-defeasiblerules (?rule-file $?defeasiblerule-strings)
	(while (> (length$ $?defeasiblerule-strings) 0)
	   do
	   	(bind ?rule-oid (translate-defeasiblerule ?rule-file (nth$ 1 $?defeasiblerule-strings)))
	   	(send ?rule-oid put-system no)
	   	(bind $?defeasiblerule-strings (rest$ $?defeasiblerule-strings))
	)
	TRUE
)

;;;;;;;;;;;;;;;;;;;;;;;;
; Defeater declaration ;
;;;;;;;;;;;;;;;;;;;;;;;;

; Input
;(defeater r6
;	(declare (superior r5))
;	(gap (animal-name ?X))
;  =>
;  	(flies (animal-name ?X))
;)


; Output
; ------

; rule instance
; *************
;(definstances r6-defeasible-logic-rules 
;	(of defeater 
;		(rule-name r6) 
;		(original-rule "(declare (superior r5)) (gap (animal-name ?X)) => (flies (animal-name ?X))")
;		(condition-classes gap)
;		(conclusion-class flies)
;		(negated no)
;		(superior r5)
;		(overruled-rule r6-overruled)
;	)
;)

; overruled rule definition
; *************************
;(aggregateattrule r6-overruled
;	[run-defeasible-rules] <- (DEFEASIBLE-CONTROL)
;	(gap (animal-name ?X) (positive ?P-VAL&:(>= ?P-VAL 1)) )
;	?r <- (supportive-rule (rule-name ?rn) (negated yes) (conclusion-class flies))
;	?p <- (flies (animal-name ?X)(positive-defeated $?PD&:(not (member$ r6 $?PD))))
;  =>
;  	?p <- (flies (negative-overruled (list ?rn)))
;)

(deffunction translate-defeater (?rule-file ?defeater-string)
	(bind $?defeater-def (my-explode$ ?defeater-string))
	(bind ?defeater-name (nth$ 1 $?defeater-def))
	(bind $?defeater (rest$ $?defeater-def))
	; Find if there is superiority relation - NOW only one rule !!!
	(if (and (eq (nth$ 2 $?defeater) declare) (eq (nth$ 4 $?defeater) superior))
	   then
	      	(bind ?p2 (get-token $?defeater))
		(bind $?superiority-declaration (subseq$ $?defeater 1 ?p2))
		(bind $?inferior-rule (subseq$ $?superiority-declaration 5 (- ?p2 2)))
	   	;(bind ?defeated-rule-name (sym-cat ?defeasiblerule-name "-defeated"))
	   	(bind $?actual-rule (subseq$ $?defeater (+ ?p2 1) (length$ $?defeater)))
	   else
	   	(bind $?inferior-rule (create$))
	   	;(bind ?defeated-rule-name nil)
	   	(bind $?actual-rule $?defeater)
	)
	(bind ?imp_pos (member$ => $?actual-rule))
	(bind $?condition (subseq$ $?actual-rule 1 (- ?imp_pos 1)))
	(if (= (length$ $?condition) 0)
	   then
	   	(bind ?aggregate-att-rule ntm-aggregateattrule)
	   	(bind ?derived-att-rule ntm-derivedattrule)
	   else
	   	(bind ?aggregate-att-rule aggregateattrule)
	   	(bind ?derived-att-rule derivedattrule)
	)
	(bind $?conclusion (subseq$ $?actual-rule (+ ?imp_pos 1) (length$ $?actual-rule)))
	(if (member$ naf $?condition)
	   then
	   	(bind $?condition-vars (find-vars $?condition))
	   	(bind $?conclusion-vars (find-vars $?conclusion))
	   	(bind $?condition-conclusion-vars (intersection$ (create$ $?condition-vars $$$ $?conclusion-vars)))
	   	(bind $?condition (transform-naf ?rule-file ?defeater-name (create$ $?condition-conclusion-vars $$$ $?condition)))
	)
	(if (eq (nth$ 2 $?conclusion) calc)
	   then
	   	(bind $?actual-conclusion (integrate-calc $?conclusion))
	   	(bind $?pure-conclusion (get-pure-conclusion $?conclusion))
	   	(bind $?calc-test-function (get-calc-test-function $?conclusion))
	   else
	   	(bind $?actual-conclusion $?conclusion)
	   	(bind $?pure-conclusion $?conclusion)
	   	(bind $?calc-test-function (create$))
	)
	; Negated conclusion or not?
	(if (eq (nth$ 2 $?actual-conclusion) not)
	   then
	   	(bind ?negated-status yes)
	   	(bind ?conclusion-class (nth$ 4 $?actual-conclusion))
	   	(bind $?actual-conclusion (subseq$ $?actual-conclusion 3 (- (length$ $?actual-conclusion) 1)))
	   	(bind $?pure-conclusion (subseq$ $?pure-conclusion 3 (- (length$ $?pure-conclusion) 1)))
		(if (eq (nth$ 2 $?conclusion) calc)
		   then
		   	(bind $?conclusion (delete-member$ $?conclusion (create$ "(" not)))
		   	(bind $?conclusion (subseq$ $?conclusion 1 (- (length$ $?conclusion) 1)))
		   else
		   	(bind $?conclusion (subseq$ $?conclusion 3 (- (length$ $?conclusion) 1)))
		)
	   else
	   	(bind ?negated-status no)
	   	(bind ?conclusion-class (nth$ 2 $?actual-conclusion))
	)
	; Build rule instance
	(bind $?rule-instance (create$ 
		"(" make-instance ?defeater-name of defeater 
			"(" rule-name ?defeater-name ")" 
			;"(" original-rule "\"" (str-cat$ $?defeater) "\"" ")"
			; "(" condition-classes ??? ")"  	; May not needed!
			"(" conclusion-class ?conclusion-class ")"
			"(" negated ?negated-status ")"
			;"(" conclusion-pattern (get-conclusion-pattern (subseq$ $?conclusion 3 (- (length$ $?conclusion) 1))) ")"
			"(" deductive-rule (sym-cat ?defeater-name "-deductive") ")"
			;"(" support-rule (sym-cat ?defeater-name "-support") ")"
			"(" overruled-rule (sym-cat ?defeater-name "-overruled") ")"
			"(" superior $?inferior-rule ")"
		")"
	))
	(eval (str-cat$ $?rule-instance))
	(send (symbol-to-instance-name ?defeater-name) put-original-rule ?defeater-string)
	; Build defeasible class object
	(bind ?conclusion-class-inst (symbol-to-instance-name ?conclusion-class))
	(if (not (instance-existp ?conclusion-class-inst))
	   then
		(bind ?mk-inst-string (str-cat$ (create$
			"(" make-instance ?conclusion-class-inst of defeasible-class
				"(" class-name ?conclusion-class ")"
				"(" rules (symbol-to-instance-name ?defeater-name) ")"
			")"
		)))
		(eval ?mk-inst-string)
		;(make-instance ?conclusion-class-inst of defeasible-class
		;	(class-name ?conclusion-class)
		;	(rules (symbol-to-instance-name ?defeater-name))
		;)
	   else
	   	(slot-insert$ ?conclusion-class-inst rules 1 (symbol-to-instance-name ?defeater-name))
	)
	; Build deductive rule
	(bind $?deductive-rule (create$
		"(" ntm-deductiverule (sym-cat ?defeater-name "-deductive")
			(remove-strong-negation $?condition)
			"(" not $?actual-conclusion ")"
		   =>
		   	$?conclusion
		")"
	))
	(printout ?rule-file (str-cat$ $?deductive-rule) crlf)
	; -----------------------	
	(bind ?var1 (sym-cat "?" (gensym)))
	(bind ?var2 (sym-cat "?" (gensym)))
	(bind ?var3 (sym-cat "$?" (gensym)))
	(bind ?var4 (sym-cat "$?" (gensym)))
	(bind ?var5 (sym-cat "$?" (gensym)))
	(bind ?var6 (sym-cat "$?" (gensym)))
	(if (eq ?negated-status no)
	   then
	   	;(bind ?supportive-rule-status yes)
	   	(bind ?supportive-rule-status negative-support)
	   	(bind ?overruled-status-slot negative-overruled)
	   	(bind ?support-slot positive-support)
	   	(bind ?defeated-status-slot positive-defeated)
	   else
	   	;(bind ?supportive-rule-status no)
	   	(bind ?supportive-rule-status positive-support)
	   	(bind ?overruled-status-slot positive-overruled)
	   	(bind ?support-slot negative-support)
	   	(bind ?defeated-status-slot negative-defeated)
	)
	; Build overruled rule
	(bind $?defeasible-rule-condition (defeasible-rule-condition $?condition))
	(bind $?overruled-rule (create$
		"(" ntm-derivedattrule (sym-cat ?defeater-name "-overruled")
			"(" declare "(" priority "(" calc-defeasible-priority 2 (symbol-to-instance-name ?defeater-name) ")" ")" ")"
			$?defeasible-rule-condition
			?var1 <- (insert$ $?actual-conclusion (length$ $?actual-conclusion) 
					(create$ "(" ?supportive-rule-status ?var4 ")" 
						"(" ?overruled-status-slot ?var5 "&" ":" "(" not "(" subseq-pos "(" create$ (sym-cat ?defeater-name "-overruled") ?var4 $$$ ?var5 ")"  ")" ")" ")"
						"(" ?defeated-status-slot ?var3 "&" ":" "(" not "(" member$ ?defeater-name ?var3 ")" ")" ")" ))
		   =>
		   	"(" calc "(" bind ?var6 "(" create$ (sym-cat ?defeater-name "-overruled") ?var4 ?var5 ")" ")" ")"
		   	?var1 <- "(" ?conclusion-class "(" ?overruled-status-slot ?var6 ")" ")"
		")"
	))
	(printout ?rule-file (str-cat$ $?overruled-rule) crlf)
	(bind $?overruled-rule-dot (create$
		"(" ntm-derivedattrule (sym-cat ?defeater-name "-overruled-dot")
			"(" declare "(" priority "(" calc-defeasible-priority -2 (symbol-to-instance-name ?defeater-name) ")" ")" ")"
			?var1 <- (insert$ $?pure-conclusion (length$ $?pure-conclusion) (create$ 
					"(" ?supportive-rule-status ?var4 ")" 
					"(" ?overruled-status-slot ?var5 "&" ":" "(" subseq-pos "(" create$ (sym-cat ?defeater-name "-overruled") ?var4 $$$ ?var5 ")" ")" ")"
				))
			(if (> (length$ $?defeasible-rule-condition) 0)
			   then
			   	(create$ "(" not "(" and
					$?defeasible-rule-condition
					$?calc-test-function
					?var1 <- "(" (nth$ 2 $?pure-conclusion) 
							"(" ?defeated-status-slot ?var3 "&" ":" "(" not "(" member$ ?defeater-name ?var3 ")" ")" ")" 
						")"
				")" ")")
			   else
			   	(create$ "(" not 
					?var1 <- "(" (nth$ 2 $?pure-conclusion) 
							"(" ?defeated-status-slot ?var3 "&" ":" "(" not "(" member$ ?defeater-name ?var3 ")" ")" ")" 
						")"
				")" )
			)
		   =>
		   	"(" calc "(" bind ?var6 "(" delete-member$ ?var5 "(" create$ (sym-cat ?defeater-name "-overruled") ?var4 ")" ")" ")" ")"
		   	?var1 <- "(" ?conclusion-class "(" ?overruled-status-slot ?var6 ")" ")"
		")"
	))
	(printout ?rule-file (str-cat$ $?overruled-rule-dot) crlf)
	(return (symbol-to-instance-name ?defeater-name))
)

; Translation for all defeaters
(deffunction translate-defeaters (?rule-file $?defeater-strings)
	(while (> (length$ $?defeater-strings) 0)
	   do
	   	(bind ?rule-oid (translate-defeater ?rule-file (nth$ 1 $?defeater-strings)))
	   	(send ?rule-oid put-system no)
	   	(bind $?defeater-strings (rest$ $?defeater-strings))
	)
	TRUE
)

; Just print to the file the r-device-rule
(deffunction noop-r-device-rules (?rule-file $?r-device-rules)
	(while (> (length$ $?r-device-rules) 0)
	   do
	   	(bind ?p2 (get-token $?r-device-rules))
	   	(bind $?first-rule (subseq$ $?r-device-rules 1 ?p2))
	   	(bind $?r-device-rules (subseq$ $?r-device-rules (+ ?p2 1) (length$ $?r-device-rules)))
	   	(bind ?r-device-rule (str-cat$ $?first-rule))
		(printout ?rule-file ?r-device-rule crlf)
	)
	TRUE
)

(deffunction create-competing-rules (?competing-rules-string)
	(bind $?competing-rules-def (my-explode$ ?competing-rules-string))
	(bind ?competing-rules-name (nth$ 1 $?competing-rules-def))
	(bind $?competing-rules (rest$ $?competing-rules-def))
	(bind ?pos (member$ _on_slots_ $?competing-rules))
	(if (integerp ?pos)
	   then
	   	(bind $?slots (subseq$ $?competing-rules (+ ?pos 1) (length$ $?competing-rules)))
	   	(bind $?competing-rules (subseq$ $?competing-rules 1 (- ?pos 1)))
	   else
	   	(bind $?slots (create$))
	)
	(make-instance ?competing-rules-name of competing-rules
		(original-rules (symbols-to-instances $?competing-rules))
		(unique-slots $?slots)
	)
)

(deffunction create-all-competing-rules ($?all-competing-rules)
	(while (> (length$ $?all-competing-rules) 0)
	   do
	   	(create-competing-rules (nth$ 1 $?all-competing-rules))
	   	(bind $?all-competing-rules (rest$ $?all-competing-rules))
	)
	TRUE
)

; Old definition - works in some cases only!
;(deffunction translate-extra-competing-rules (?rule-file)
;	(do-for-all-instances ((?extra-rule extra-competing-rule)) TRUE
;		(bind $?new-second-rule-condition ?extra-rule:second-rule-condition)
;		(loop-for-count (?n 1 (length$ ?extra-rule:second-rule-condition-conclusion-vars))
;		   do
;			(bind ?var-to-find (nth$ ?n ?extra-rule:second-rule-condition-conclusion-vars))
;			(bind ?var-to-negate (nth$ ?n ?extra-rule:first-rule-condition-conclusion-vars))
;			(bind ?pos (member$ ?var-to-find $?new-second-rule-condition))
;			(if (integerp ?pos)
;			   then
;			   	(bind $?new-second-rule-condition (insert$ $?new-second-rule-condition (+ ?pos 1) "&" "~" ?var-to-negate))
;			)
;		)
;		(bind ?extra-rule-string (str-cat$ (create$
;			(instance-name-to-symbol ?extra-rule)
;				?extra-rule:first-rule-condition
;				$?new-second-rule-condition
;			=>
;				?extra-rule:second-rule-conclusion
;		)))
;		(funcall (sym-cat translate- ?extra-rule:rule-type) ?rule-file ?extra-rule-string)
;		(printout t "translate-extra-competing-rules: ?extra-rule-string: " ?extra-rule-string crlf)
;		;(send ?extra-rule delete)
;	)
;)

; New improved definition
(deffunction translate-extra-competing-rules (?rule-file)
	(do-for-all-instances ((?extra-rule extra-competing-rule)) TRUE
		;(send ?extra-rule print)
		;(printout t crlf crlf)
		(bind $?new-second-rule-condition ?extra-rule:second-rule-condition)
		;(send ?extra-rule:competing-rule-construct print)
		(bind $?unique-slots (send ?extra-rule:competing-rule-construct get-unique-slots))
		(bind $?inequalities (create$))
		(bind $?equalities (create$))
		(bind ?inequalites-counter 0)
		(bind ?equalites-counter 0)
		(loop-for-count (?n 1 (length$ ?extra-rule:second-rule-condition-conclusion-vars))
		   do
			(bind ?var-to-find (nth$ ?n ?extra-rule:second-rule-condition-conclusion-vars))
			(bind ?var-to-negate (nth$ ?n ?extra-rule:first-rule-condition-conclusion-vars))
			(bind ?pos (member$ ?var-to-find ?extra-rule:second-rule-conclusion))
			(if (integerp ?pos)
			   then
			   	(bind ?slot-found (nth$ (- ?pos 1) ?extra-rule:second-rule-conclusion))
			   	;(printout t "?slot-found: " ?slot-found crlf)
			   	;(printout t "$?unique-slots: " $?unique-slots crlf)
			   	(if (or (= (length$ $?unique-slots) 0) (member$ ?slot-found $?unique-slots))
			   	   then
			   	   	(bind $?inequalities (create$ $?inequalities "(" neq ?var-to-find ?var-to-negate ")"))
			   	   	(bind ?inequalites-counter (+ ?inequalites-counter 1))
			   	   else
			   	   	(bind $?equalities (create$ $?equalities "(" eq ?var-to-find ?var-to-negate ")"))
			   	   	(bind ?equalites-counter (+ ?equalites-counter 1))
			   	)
			)
		)
		;(bind $?new-second-rule-condition ?extra-rule:second-rule-condition)
		(bind ?pos (member$ ?var-to-find $?new-second-rule-condition))
		(if (integerp ?pos)
		   then
		   	(if (= ?equalites-counter 1)
		   	   then
		   		(bind ?function-cond-string (str-cat$ $?equalities))
		   	   else
		   	   	(if (> ?equalites-counter 1)
		   	   	   then
		   			(bind ?function-cond-string (str-cat$ (create$ "(and" $?equalities ")" )))
		   		)
		   	)
	   	   	(if (= ?inequalites-counter 1)
	   	   	   then
	   	   		(bind ?function-concl-string (str-cat$ $?inequalities))
	   	   	   else
	   	   	   	(if (> ?inequalites-counter 1)
	   	   	   	   then
	   	   			(bind ?function-concl-string (str-cat$ (create$ "(or" $?inequalities ")" )))
	   	   		)
	   	   	)
		   	(if (= ?inequalites-counter 0)
		   	   then
		   	   	(bind ?function-string "")
		   	   else
		   	   	(if (= ?equalites-counter 0)
		   	   	   then
		   	   	   	(bind ?function-string (str-cat$ (create$ "&" ":" ?function-concl-string)))
		   	   	   else
		   	   	   	(bind ?function-string (str-cat$ (create$ "&" ":" "(" "if" ?function-cond-string then ?function-concl-string ")")))
		   	   	)
		   	)
		   	(bind $?new-second-rule-condition (insert$ $?new-second-rule-condition (+ ?pos 1) ?function-string))
		)
		(bind ?extra-rule-string (str-cat$ (create$
			(instance-name-to-symbol ?extra-rule)
				?extra-rule:first-rule-condition
				$?new-second-rule-condition
				;?extra-rule:second-rule-condition
				;"(test (or " $?inequalities "))"
			=>
				?extra-rule:second-rule-conclusion
		)))
		(funcall (sym-cat translate- ?extra-rule:rule-type) ?rule-file ?extra-rule-string)
		;(printout t "translate-extra-competing-rules: ?extra-rule-string: " ?extra-rule-string crlf)
		;(send ?extra-rule delete)
	)
)

; The following 2 functions are not needed any more due
; to the re-definition of function resource-make-instance!
; in file defeasible-functions.clp
;(deffunction import-rdf-defeasible ($?projects)
;	(bind $?rdf-classes1 (find-rdf-ground-classes))
;	(import-rdf $?projects)
;	(bind $?rdf-classes2 (find-rdf-ground-classes))
;	(bind $?defdefeasibleclasses (difference$ (create$ $?rdf-classes2 $$$ $?rdf-classes1)))
;	(initialize-defeasible-facts $?defdefeasibleclasses)
;)

;(deffunction import-rdf-files-defeasible ($?files)
;	(bind $?rdf-classes1 (find-rdf-ground-classes))
;	(import-rdf-files $?files)
;	(bind $?rdf-classes2 (find-rdf-ground-classes))
;	(bind $?defdefeasibleclasses (difference$ (create$ $?rdf-classes2 $$$ $?rdf-classes1)))
;	(initialize-defeasible-facts $?defdefeasibleclasses)
;)


(deffunction return-rulebase-address (?filename)
	(bind ?rulebase (sub-string 1 (- (str-index ".clp" ?filename) 1) ?filename))
	(bind ?pos (member$ ?rulebase ?*rulebases*))
	(if (integerp ?pos)
	   then
	   	(bind ?rulebase-address (nth$ (+ ?pos 1) ?*rulebases*))
	   else
	   	(bind ?rulebase-address (str-cat ?rulebase ".ruleml"))
	)
	(return ?rulebase-address)
)

; Load a file with defeasible rules and class/facts
(deffunction load-only-dr-device (?filename $?namespaces)
	(verbose crlf "Translating DR-DEVICE rules to R-DEVICE rules...")
	(bind ?rule-filename (str-cat "defeasible-r-device-rules-" ?filename))
	(bind ?rule-inst-filename (str-cat "defeasible-r-device-rule-instances-" ?filename))
	(bind ?rule-class-inst-filename (str-cat "defeasible-r-device-rule-class-instances-" ?filename))
	(bind ?run-compiled-bat-filename (str-cat (sub-string 1 (- (str-index ".clp" ?filename) 1) ?filename) "-comp.bat"))
	(bind ?construct-string "")
	(open ?filename construct "r")
	(bind ?line (readline construct))
	(while (neq ?line EOF)
	   do
	   	(bind ?construct-string (str-cat ?construct-string ?line))
	   	(bind ?line (readline construct))
	)
	(close construct)
	(bind $?construct-list (my-explode$ ?construct-string))
	(bind $?defdefeasibleclasses (create$))
	(bind $?import-rdf-files (create$))
	(bind ?export-rdf-file "")
	(bind ?export-proof-file nil)
	(bind $?export-rdf-classes (create$))
	(bind $?defeasiblefacts-all (create$))
	(bind $?competing-rules (create$))
	(bind $?strictrules (create$))
	(bind $?defeasiblerules (create$))
	(bind $?defeaters (create$))
	(bind $?r-device-rules (create$))
	(bind $?defeasibleclasses (create$))
	(while (> (length$ $?construct-list) 0)
	   do
	   	(bind ?p2 (get-token $?construct-list))
	   	(bind $?construct (subseq$ $?construct-list 1 ?p2))
	   	(bind ?construct-type (nth$ 2 $?construct))
	   	;(printout t "construct-type: " ?construct-type crlf)
	   	(bind ?construct-string (str-cat$ (subseq$ $?construct 3 (- (length$ $?construct) 1))))
	   	(switch ?construct-type
	   		(case defdefeasibleclasses
	   		   then
	   			(bind $?defdefeasibleclasses (subseq$ $?construct 3 (- (length$ $?construct) 1)))
	   		)
	   		(case import-rdf
	   		   then
	   		   	 (bind $?import-rdf-files (explode$ (str-cat$ (subseq$ $?construct 3 (- (length$ $?construct) 1)))))
	   		)
	   		(case export-rdf
	   		   then
	   		   	(bind ?export-rdf-file (str-cat$ (nth$ 3 $?construct)))
	   		   	(if (neq (str-index "\"" ?export-rdf-file) FALSE)
	   		   	   then
	   		   	   	(bind ?export-rdf-file (sub-string 2 (- (str-length ?export-rdf-file) 1) ?export-rdf-file))
	   		   	)
	   		   	(bind $?export-rdf-classes (subseq$ $?construct 4 (- (length$ $?construct) 1)))
	   		)
	   		(case export-proof
	   		   then
	   		   	(bind ?export-proof-file (str-cat$ (nth$ 3 $?construct)))
	   		   	(if (neq (str-index "\"" ?export-proof-file) FALSE)
	   		   	   then
	   		   	   	(bind ?export-proof-file (sub-string 2 (- (str-length ?export-proof-file) 1) ?export-proof-file))
	   		   	)
	   		)
	   		(case defeasibleclass 
	   		   then
	   			(bind $?defeasibleclasses (create$ $?defeasibleclasses ?construct-string))
	   		)
	   		(case defeasiblefacts
	   		   then
	   			(bind $?defeasiblefacts-all (create$ $?defeasiblefacts-all ?construct-string))
	   		)
	   		(case competing_rules 
	   		   then
	   			(bind $?competing-rules (create$ $?competing-rules ?construct-string))
	   		)
	   		(case strictrule
	   		   then
	   			(bind $?strictrules (create$ $?strictrules ?construct-string))
	   		)
	   		(case defeasiblerule
	   		   then
	   			(bind $?defeasiblerules (create$ $?defeasiblerules ?construct-string))
	   		)
	   		(case defeater
	   		   then
	   			(bind $?defeaters (create$ $?defeaters ?construct-string))
	   		)
	   		(case deductiverule
	   		   then
	   		   	(bind $?r-device-rules (create$ $?r-device-rules $?construct))
	   		)
	   		(case ntm-deductiverule
	   		   then
	   		   	(bind $?r-device-rules (create$ $?r-device-rules $?construct))
	   		)
	   		(case derivedattrule
	   		   then
	   		   	(bind $?r-device-rules (create$ $?r-device-rules $?construct))
	   		)
	   		(case ntm-derivedattrule
	   		   then
	   		   	(bind $?r-device-rules (create$ $?r-device-rules $?construct))
	   		)
	   		(case aggregateattrule
	   		   then
	   		   	(bind $?r-device-rules (create$ $?r-device-rules $?construct))
	   		)
	   		(case ntm-aggregateattrule
	   		   then
	   		   	(bind $?r-device-rules (create$ $?r-device-rules $?construct))
	   		)
	   		(default 
	   			(printout t "Unknown construct type: " crlf ?construct-string crlf)
	   		)
	   	)
	   	(bind $?construct-list (subseq$ $?construct-list (+ ?p2 1) (length$ $?construct-list)))
	)
	
	;(bind $?rdf-classes1 (find-rdf-ground-classes))   ; This is not needed any more!
	(if (eq ?*namespace-hunting* off)
	   then
	   	(import-rdf $?namespaces)
	)
	(import-rdf-files $?import-rdf-files)
	(bind ?*imported-rdf-files* (create$ ?*imported-rdf-files* $?import-rdf-files))
	;(bind $?rdf-classes2 (find-rdf-ground-classes))   ; This is not needed any more!  
	;(bind $?defdefeasibleclasses (create$ $?defdefeasibleclasses (difference$ (create$ $?rdf-classes2 $$$ $?rdf-classes1))))   ; This is not needed any more!
	(open ?rule-filename rule-out "w")
	(create-all-competing-rules $?competing-rules)
	(translate-defeasibleclasses $?defeasibleclasses)
	(translate-defeasiblefacts-all $?defeasiblefacts-all)
	(noop-r-device-rules rule-out $?r-device-rules)
	(translate-strictrules rule-out $?strictrules)
	(translate-defeasiblerules rule-out $?defeasiblerules)
	(translate-defeaters rule-out $?defeaters)
	; competing rules
	(translate-extra-competing-rules rule-out)
	(close rule-out)
	(verbose " ok" crlf crlf)
	(load-only-r-device ?rule-filename)
	(calc-defeasible-stratum)
	(save-instances ?rule-inst-filename visible inherit defeasible-logic-rule)
	(funcall save-instances ?rule-class-inst-filename visible defeasible-class)
	(open ?run-compiled-bat-filename bat-out "w")
	(printout bat-out "(import-rdf " (str-cat$ $?namespaces) ")" crlf)
	(printout bat-out "(import-rdf-files " (str-cat$ $?import-rdf-files) ")" crlf)
	(printout bat-out "(load-compiled-dr-device " ?filename ")" crlf)
	(printout bat-out "(go-dr-device)" crlf)
	(bind ?rulebase-address (return-rulebase-address ?filename))
	(printout bat-out "(dr-device_export_rdf " (str-cat$ ?rulebase-address ?export-rdf-file ?export-proof-file $?export-rdf-classes) ")" crlf)
	(close bat-out)
	;(initialize-defeasible-facts $?defdefeasibleclasses)  ; This is not needed any more!
;	(remove ?rule-filename)
;	(go-defeasible)
;	(if (neq ?export-rdf-file "")
;	   then
;		(defeasibly_export_rdf ?export-rdf-file $?export-rdf-classes)
;	)
	(bind ?*exported-derived-classes* (create$ ?*exported-derived-classes* $?export-rdf-classes))
	(return (create$ ?export-rdf-file ?export-proof-file $?export-rdf-classes))
)


(deffunction load-dr-device (?filename $?namespaces)
	(bind $?export-parameters (load-only-dr-device ?filename $?namespaces))
	(go-dr-device)
	(bind ?export-rdf-file (nth$ 1 $?export-parameters))
	(bind ?export-proof-file (nth$ 2 $?export-parameters))
	(bind $?export-rdf-classes (rest$ (rest$ $?export-parameters)))
	(if (neq ?export-rdf-file "")
	   then
		(bind ?rulebase-address (return-rulebase-address ?filename))
		(dr-device_export_rdf ?rulebase-address ?export-rdf-file ?export-proof-file $?export-rdf-classes)
	)	
)

(deffunction load-ruleml-dr-device (?filename ?address $?namespaces)
	(if (eq ?address local)
	   then
	   	(verbose crlf "Translating RuleML syntax to DR-DEVICE native syntax for file: " ?filename crlf crlf)
	   	(bind ?command (str-cat "cmd /c \"\".\\bin\\ruleml2drdevice.bat\" " ?filename "\""))
	   	;(bind ?command (str-cat "cmd /c .\\bin\\ruleml2drdevice.bat " ?filename))
	   	(system ?command)
	   	(load-dr-device (str-cat ?filename ".clp") $?namespaces)
	   else
	   	(verbose crlf "Remote RULE access at URL: " ?address crlf crlf)
	   	(open "loadfile.bat" mkbat "w")
		(printout mkbat "@echo off" crlf)
	   	(printout mkbat "@\".\\Libwww\\loadtofile.exe\" " ?address " -o " ?filename ".ruleml < \".\\bin\\y\"")
	   	(close mkbat)
	   	;(bind ?command (str-cat "cmd /c \".\\bin\\loadfile.bat\" " ?address " " ?filename ".ruleml") )
	   	(system "cmd /c loadfile.bat")
	   	(remove "loadfile.bat")
	   	(bind ?*rulebases* (create$ ?*rulebases* ?filename ?address))
		(load-ruleml-dr-device ?filename local $?namespaces)
	)
)

(deffunction load-ruleml-dr-device-local (?filename ?path-file $?namespaces)
	(if (eq ?path-file local)
	   then
	   	(verbose crlf "Translating RuleML syntax to DR-DEVICE native syntax for file: " ?filename crlf crlf)
	   	(bind ?command (str-cat "cmd /c \"\".\\bin\\ruleml2drdevice.bat\" " ?filename "\""))
	   	;(bind ?command (str-cat "cmd /c .\\bin\\ruleml2drdevice.bat " ?filename))
	   	(system ?command)
	   	(load-dr-device (str-cat ?filename ".clp") $?namespaces)
	   else
	   	(verbose crlf "Local RULE access at Path: " ?path-file crlf crlf)
	   	(bind ?cmd (str-cat "cmd /c copy /Y \"" ?path-file "\" " ".\\" ?filename ".ruleml"))
	   	(verbose crlf ?cmd crlf)
	   	(system ?cmd)
	   	;(open "loadfile.bat" mkbat "w")
		;(printout mkbat "@echo off" crlf)
	   	;(printout mkbat "@\".\\Libwww\\loadtofile.exe\" " ?address " -o " ?filename ".ruleml")
	   	;(close mkbat)
	   	;(bind ?command (str-cat "cmd /c \".\\bin\\loadfile.bat\" " ?address " " ?filename ".ruleml") )
	   	;(system "cmd /c loadfile.bat")
	   	;(remove "loadfile.bat")
	   	(bind ?*rulebases* (create$ ?*rulebases* ?filename ?path-file))
		(load-ruleml-dr-device-local ?filename local $?namespaces)
	)
)

(deffunction load-compiled-dr-device (?filename)
	(bind ?rule-filename (str-cat "defeasible-r-device-rules-" ?filename))
	(bind ?rule-inst-filename (str-cat "defeasible-r-device-rule-instances-" ?filename))
	(bind ?rule-class-inst-filename (str-cat "defeasible-r-device-rule-class-instances-" ?filename))
	(bind ?compiled-rule-file-exists (file-exists ?rule-filename))
	(if (eq ?compiled-rule-file-exists FALSE)
	   then
		(printout t "ERROR!" crlf)
		(printout t ?filename " has not yet been compiled!" crlf)
		(printout t "Use load-only-dr-device function instead!" crlf)
	   else
	   	(restore-instances ?rule-inst-filename)
	   	(restore-instances ?rule-class-inst-filename)
		(load-compiled-r-device ?rule-filename)
		;(calc-defeasible-stratum)
	)
)
