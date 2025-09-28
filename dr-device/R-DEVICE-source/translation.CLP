(deffunction find-rule-name (?rule-string)
	(bind $?rule (my-explode$ ?rule-string))
	(if (or
		(eq (nth$ 1 $?rule) "(")
		(eq (nth$ 2 $?rule) "<-"))
	   then
	   	(bind ?rule-name (gensym*))
	   	(bind ?new-rule-string ?rule-string)
	   else
	   	(bind ?rule-name (nth$ 1 $?rule))
	   	(bind ?new-rule-string (str-cat$ (delete$ $?rule 1 1)))
	)
	(return (create$ ?rule-name ?new-rule-string))
)

(deffunction transform-cond-elem ($?cond-element)
)

(deffunction transform-one-cond-elem ($?cond-element)
	(if (eq (nth$ 2 $?cond-element) test)
	   then
	   	$?cond-element
	   else
		(if (or 
			(eq (nth$ 2 $?cond-element) not)
	   		(eq (nth$ 2 $?cond-element) or)
	   		(eq (nth$ 2 $?cond-element) and))
	   	   then
	   	   	(create$ "(" (nth$ 2 $?cond-element)
	   	   			(transform-cond-elem (subseq$ $?cond-element 3 (- (length$ $?cond-element) 1)))
	   	   		")"
	   	   	)
		   else
			(if (eq (nth$ 2 $?cond-element) <-)
			   then
			   	(if (is-var (nth$ 1 $?cond-element))
			   	   then
			   	   	(bind ?object-id (nth$ 1 $?cond-element))
			   	   else
			   	   	(bind ?object-id (str-cat "[" (nth$ 1 $?cond-element) "]"))
			   	)
				(if (eq (nth$ 4 $?cond-element) object)
			   	   then
			   		;$?cond-element
			   		(insert$ (subseq$ $?cond-element 3 (length$ $?cond-element)) 3 "(" name ?object-id ")")
			   	   else
			   	   	;(replace$ $?cond-element 4 4 object "(" is-a (nth$ 4 $?cond-element) ")")
			   	   	(replace$ (subseq$ $?cond-element 3 (length$ $?cond-element)) 2 2 object "(" name ?object-id ")" "(" is-a (nth$ 4 $?cond-element) ")")
			   	)
			   else
				(if (eq (nth$ 2 $?cond-element) object)
	   			   then
					$?cond-element
			   	   else
			   		(replace$ $?cond-element 2 2 object "(" is-a (nth$ 2 $?cond-element) ")")
			   	)
			)
		)
	)
)


(deffunction transform-cond-elem ($?cond-element)
	(bind $?result (create$))
	(while (> (length$ $?cond-element) 0)
	   do
	   	(bind ?p2 (get-token $?cond-element))
		(bind $?result (create$ $?result (transform-one-cond-elem (subseq$ $?cond-element 1 ?p2))))
		(bind $?cond-element (subseq$ $?cond-element (+ ?p2 1) (length$ $?cond-element)))
   	)
	$?result
)


(deffunction path-transform-one-slot-vector-aux (?previous-var ?current-class $?path-list)
	;(printout t "path-transform-one-slot-vector-aux: ?previous-var: " ?previous-var crlf)
	;(printout t "path-transform-one-slot-vector-aux: ?current-class: " ?current-class crlf)
	;(printout t "path-transform-one-slot-vector-aux: $?path-list: " $?path-list crlf)
	(if (= (length$ $?path-list) 0)
	   then
	   	(create$)
	   else
		(bind ?current-slot (nth$ 1 $?path-list))
	   	(bind ?next-var (str-cat "?" (gensym)))
		(if (is-multislot ?current-class ?current-slot)
		   then
		   	(bind $?next-var-expr (create$ "$?" ?next-var "$?"))
		   else
		   	(bind $?next-var-expr (create$ ?next-var))
		)
		;(printout t "path-transform-one-slot-vector-aux: $?next-var-expr: " $?next-var-expr crlf)
		;(bind ?next-class (get-type-of ?current-class ?current-slot))
	   	;(bind $?current-cond-elem (create$ ?previous-var <- "(" object "(" is-a ?current-class ")" "(" ?current-slot $?next-var-expr ")" ")"))
;	   	(bind $?rest-cond-elems (path-transform-one-slot-vector-aux ?next-var (get-type-of ?current-class ?current-slot) (rest$ $?path-list)))
;	   	(create$ (path-transform-one-slot-vector-aux ?next-var (get-type-of ?current-class ?current-slot) (rest$ $?path-list)) (create$ ?previous-var <- "(" object "(" is-a ?current-class ")" "(" ?current-slot $?next-var-expr ")" ")"))
	   	(bind $?result (create$ (path-transform-one-slot-vector-aux ?next-var (get-type-of ?current-class ?current-slot) (rest$ $?path-list)) (create$ "(" object "(" name ?previous-var ")" "(" is-a ?current-class ")" "(" ?current-slot $?next-var-expr ")" ")")))
	   	;(printout t "path-transform-one-slot-vector-aux: $?result: " $?result crlf)
	   	(return $?result)
;	   	(create$ $?current-cond-elem $?rest-cond-elems)
	)
)

(deffunction path-transform-one-slot-vector (?class $?slot-vector)
	(bind ?p2 (get-token (rest$ $?slot-vector)))
	(bind $?path-list (reverse$ (subseq$ $?slot-vector 3 ?p2)))
	;(bind $?rest-slot-vector (subseq$ $?slot-vector (+ ?p2 2) (- (length$ $?slot-vector) 1)))
	(if (> (length$ $?path-list) 1)
	   then
		(bind ?first-var (str-cat "?" (gensym)))
		(bind ?first-slot (nth$ 1 $?path-list))
		(if (is-multislot ?class ?first-slot)
		   then
		   	(bind $?first-var-expr (create$ "$?" ?first-var "$?"))
		   else
		   	(bind $?first-var-expr (create$ ?first-var))
		)
		;(bind $?new-slot-vector (create$ "(" ?first-slot ?first-var-expr ")"))
		;(bind ?next-class (get-type-of ?class ?first-slot))
		;(bind $?new-cond-elems1 (path-transform-one-slot-vector-aux ?first-var (get-type-of ?class ?first-slot) (rest$ $?path-list)))
;		(bind $?new-cond-elems (replace$ $?new-cond-elems1 (- (length$ $?new-cond-elems1) 2) (- (length$ $?new-cond-elems1) 2) $?rest-slot-vector))
;		(bind $?new-cond-elems (replace$ (path-transform-one-slot-vector-aux ?first-var (get-type-of ?class ?first-slot) (rest$ $?path-list)) 11 11 $?rest-slot-vector))
;		(create$ (replace$ (path-transform-one-slot-vector-aux ?first-var (get-type-of ?class ?first-slot) (rest$ $?path-list)) 11 11 (subseq$ $?slot-vector (+ ?p2 2) (- (length$ $?slot-vector) 1))) $$$ (create$ "(" ?first-slot ?first-var-expr ")"))
		(bind ?next-class (get-type-of ?class ?first-slot))
		(if (eq ?next-class FALSE)
		   then
		   	(bind ?next-class rdfs:Resource)  ; This is only valid for R-DEVICE!
		)
		(bind $?result (path-transform-one-slot-vector-aux ?first-var ?next-class (rest$ $?path-list)))
		(if (eq (nth$ 13 $?result) "$?")
		   then
			(create$ (replace$ $?result 13 15 (subseq$ $?slot-vector (+ ?p2 2) (- (length$ $?slot-vector) 1))) $$$ (create$ "(" ?first-slot ?first-var-expr ")"))
		   else
			(create$ (replace$ $?result 13 13 (subseq$ $?slot-vector (+ ?p2 2) (- (length$ $?slot-vector) 1))) $$$ (create$ "(" ?first-slot ?first-var-expr ")"))
		)
	   else
	   	(create$ $$$ "(" $?path-list (subseq$ $?slot-vector (+ ?p2 2) (- (length$ $?slot-vector) 1)) ")" )
	)
)

(deffunction path-transform-slot-vectors (?class $?slot-vectors)
	(if (= (length$ $?slot-vectors) 0)
	   then
	   	(create$)
	   else
	   	(bind ?p2 (get-token $?slot-vectors))
	   	(bind $?first-slot-vector (subseq$ $?slot-vectors 1 ?p2))
	   	;(bind $?rest-slot-vectors (subseq$ $?slot-vectors (+ ?p2 1) (length$ $?slot-vectors)))
	   	(if (eq (nth$ 2 $?first-slot-vector) "(")
	   	   then
	   	   	(bind $?altered-first-slot-vector (path-transform-one-slot-vector ?class $?first-slot-vector))
	   	   	(bind ?split-pos (member$ $$$ $?altered-first-slot-vector))
			(if (numberp ?split-pos)
			   then
		   		(bind $?new-first-slot-vector (subseq$ $?altered-first-slot-vector (+ ?split-pos 1) (length$ $?altered-first-slot-vector)))
				(bind $?new-first-cond-elems (subseq$ $?altered-first-slot-vector 1 (- ?split-pos 1)))
			   else
		   		(bind $?new-first-slot-vector $?altered-first-slot-vector)
		   		(bind $?new-first-cond-elems (create$))
			)
			;(printout t "path-transform-slot-vectors: $?new-first-cond-elems " $?new-first-cond-elems crlf)
	   	   else
	   	   	(bind $?new-first-slot-vector $?first-slot-vector)
	   	   	(bind $?new-first-cond-elems (create$))
		)
	   	(bind $?altered-rest-slot-vectors (path-transform-slot-vectors ?class (subseq$ $?slot-vectors (+ ?p2 1) (length$ $?slot-vectors))))
		(bind ?split-pos (member$ $$$ $?altered-rest-slot-vectors))
		(if (numberp ?split-pos)
		   then
		   	(bind $?new-rest-slot-vectors (subseq$ $?altered-rest-slot-vectors (+ ?split-pos 1) (length$ $?altered-rest-slot-vectors)))
			(bind $?new-rest-cond-elems (subseq$ $?altered-rest-slot-vectors 1 (- ?split-pos 1)))
		   else
		   	(bind $?new-rest-slot-vectors $?altered-rest-slot-vectors)
		   	(bind $?new-rest-cond-elems (create$))
		)
		(create$ $?new-first-cond-elems $?new-rest-cond-elems $$$ $?new-first-slot-vector $?new-rest-slot-vectors)
;		(create$ $?new-rest-cond-elems $?new-first-cond-elems $$$ $?new-first-slot-vector $?new-rest-slot-vectors)
	)
)
	   	
(deffunction path-transform ($?cond-element)
)

(deffunction path-transform-one ($?cond-element)
	(if (eq (nth$ 2 $?cond-element) test)
	   then
	   	$?cond-element
	   else
		(if (or 
			(eq (nth$ 2 $?cond-element) not)
	   		(eq (nth$ 2 $?cond-element) or)
	   		(eq (nth$ 2 $?cond-element) and))
	   	   then
	   	   	(create$ "(" (nth$ 2 $?cond-element)
	   	   			(path-transform (subseq$ $?cond-element 3 (- (length$ $?cond-element) 1)))
	   	   		")"
	   	   	)
		   else
	;		(if (eq (nth$ 2 $?cond-element) <-)
			(if (eq (nth$ 4 $?cond-element) name)
			   then
	;		   	(bind $?slot-vectors (subseq$ $?cond-element 9 (- (length$ $?cond-element) 1)))
			   	(bind $?slot-vectors (subseq$ $?cond-element 11 (- (length$ $?cond-element) 1)))
	;		   	(bind $?init-stuff (subseq$ $?cond-element 1 8))
			   	(bind $?init-stuff (subseq$ $?cond-element 1 10))
	;		   	(bind ?original-class (nth$ 7 $?cond-element))
			   	(bind ?original-class (nth$ 9 $?cond-element))
			   else
			   	(bind $?slot-vectors (subseq$ $?cond-element 7 (- (length$ $?cond-element) 1)))
			   	(bind $?init-stuff (subseq$ $?cond-element 1 6))
			   	(bind ?original-class (nth$ 5 $?cond-element))
			)
			(bind $?altered-slot-vectors (path-transform-slot-vectors ?original-class $?slot-vectors))
			(bind ?split-pos (member$ $$$ $?altered-slot-vectors))
			(if (numberp ?split-pos)
			   then
			   	(bind $?new-slot-vectors (subseq$ $?altered-slot-vectors (+ ?split-pos 1) (length$ $?altered-slot-vectors)))
				(bind $?new-cond-elems (subseq$ $?altered-slot-vectors 1 (- ?split-pos 1)))
			   else
			   	(bind $?new-slot-vectors $?altered-slot-vectors)
			   	(bind $?new-cond-elems (create$))
			)
			; This may change in the future, $?new-cond-elems could go back!
			(create$ $?new-cond-elems $?init-stuff $?new-slot-vectors ")" )
		)
	)
)


(deffunction path-transform ($?cond-element)
	;(printout t "path-transform: $?cond-element: " $?cond-element crlf)
	(bind $?result (create$))
	(while (> (length$ $?cond-element) 0)
	   do
	   	(bind ?p2 (get-token $?cond-element))
		(bind $?result (create$ $?result (path-transform-one (subseq$ $?cond-element 1 ?p2))))
		(bind $?cond-element (subseq$ $?cond-element (+ ?p2 1) (length$ $?cond-element)))
   	)
	;(printout t "path-transform: $?result: " $?result crlf)
	$?result
)

(deffunction object-index-transform ($?cond-element)
)

(deffunction object-index-transform-one ($?cond-element)
	(if (or 
   		(eq (nth$ 2 $?cond-element) or)
   		(eq (nth$ 2 $?cond-element) and))
   	   then
   	   	(create$ "(" (nth$ 2 $?cond-element)
   	   			(object-index-transform (subseq$ $?cond-element 3 (- (length$ $?cond-element) 1)))
   	   		")"
   	   	)
	   else
		(if (or 
   			(eq (nth$ 2 $?cond-element) test)
   			(eq (nth$ 2 $?cond-element) not)
;			(eq (nth$ 2 $?cond-element) <-)
			(eq (nth$ 4 $?cond-element) name))
   		   then
   		   	$?cond-element
   		   else
		   	;(bind ?varname (gensym))
			;(bind ?var (str-cat "?" (gensym)))
;			(create$ (str-cat "?" (gensym)) <- $?cond-element)
			(insert$ $?cond-element 3 "(" name (str-cat "?" (gensym)) ")" )
		)
	)
)

(deffunction object-index-transform ($?cond-element)
	(bind $?result (create$))
	(while (> (length$ $?cond-element) 0)
	   do
	   	(bind ?p2 (get-token $?cond-element))
		(bind $?result (create$ $?result (object-index-transform-one (subseq$ $?cond-element 1 ?p2))))
		(bind $?cond-element (subseq$ $?cond-element (+ ?p2 1) (length$ $?cond-element)))
   	)
	$?result
)


(deffunction translate-cond-element ($?cond-element)
	(if (eq (nth$ 2 $?cond-element) test)
	   then
	   	$?cond-element
   	   else
   	   	(bind $?non-existent-classes (check-non-existent-classes $?cond-element))
   	   	(if (> (length$ $?non-existent-classes) 0)
   	   	   then
   	   		(assert (non-existent-classes $?non-existent-classes))
   	   	)
   	   	;(printout t "Orig cond-elem: " $?cond-element crlf)
   	   	;(bind $?new-cond-elem1 (transform-cond-elem $?cond-element))
   	   	;(printout t "cond-elem after transform-cond-elem: " $?new-cond-elem1 crlf)
   	   	;(bind $?new-cond-elem (path-transform $?new-cond-elem1 ))
   	   	;(printout t "cond-elem after path-transform: " $?new-cond-elem crlf)
   	   	;(bind $?result (object-index-transform $?new-cond-elem))
   	   	;(printout t "cond-elem after object-index-transform: " $?result crlf)
   	   	;$?result
   	   	(object-index-transform (path-transform (transform-cond-elem $?cond-element)))
	)
)


(deffunction translate-condition ($?condition)	
	(bind $?result (create$))
	;   	(printout t "condition: " $?condition crlf)
	;   	(printout t "result: " $?result crlf)
	(while (> (length$ $?condition) 0)
	   do
	   	;(printout t "condition: " $?condition crlf)
	   	;(printout t "result: " $?result crlf)
		(bind ?p2 (get-token $?condition))
		;(bind $?cond-elem (subseq$ $?condition 1 ?p2))
		;(bind $?new-cond-elem (translate-cond-element $?cond-elem))
		;(bind $?new-cond-elem (translate-cond-element (subseq$ $?condition 1 ?p2)))
		;(bind $?result (create$ $?result $?new-cond-elem))
		(bind $?result (create$ $?result (translate-cond-element (subseq$ $?condition 1 ?p2))))
		(bind $?condition (subseq$ $?condition (+ ?p2 1) (length$ $?condition)))
	)
	$?result
)

(deffunction create-namespace (?class-namespace)
	(bind ?pos (str-index / ?class-namespace))
	(if (eq ?pos FALSE)
	   then
	   	nil
	   else
	   	(bind ?class (string-to-field (sub-string 1 (- ?pos 1) ?class-namespace)))
	   	(bind ?namespace (string-to-field (sub-string (+ ?pos 1) (str-length ?class-namespace) ?class-namespace)))
	   	(if (not (is_namespace ?namespace))
	   	   then
	   	   	(make-instance ?namespace of namespace (classes ?class))
	   	   else
	   	   	(bind $?old-classes (send (symbol-to-instance-name ?namespace) get-classes))
	   		(if (not (member$ ?class $?old-classes))
	   		   then
	   		   	(slot-insert$ (symbol-to-instance-name ?namespace) classes 1 ?class)
	   		)
	   	)
	   	?namespace
	)
)

(deffunction create-template (?tm-status ?rule-name $?condition-and-conclusion)
	;(bind $?condition (subseq$ $?condition-and-conclusion 1 (- (member$ $$$ $?condition-and-conclusion) 1)))
	(bind $?conclusion (subseq$ $?condition-and-conclusion (+ (member$ $$$ $?condition-and-conclusion) 1) (length$ $?condition-and-conclusion)))
	(bind ?class (nth$ 2 $?conclusion))
	(bind $?slot-and-ref-defs (guess-slot-defs (create$ (subseq$ $?condition-and-conclusion 1 (- (member$ $$$ $?condition-and-conclusion) 1)) $$$ (subseq$ $?conclusion 3 (- (length$ $?conclusion) 1)))))
	(bind $?slot-defs (subseq$ $?slot-and-ref-defs 1 (- (member$ $$$ $?slot-and-ref-defs) 1)))
	(bind $?reference-types (subseq$ $?slot-and-ref-defs (+ (member$ $$$ $?slot-and-ref-defs) 1) (length$ $?slot-and-ref-defs)))
	(if (eq ?tm-status yes)
	   then
		(bind ?derived-meta-class tm-DERIVED-CLASS)
	   else
	   	(bind ?derived-meta-class DERIVED-CLASS)
	)
	(if (and (not (is_derived ?class)) (not (class-existp ?class)))
	   then
		(bind ?namespace (create-namespace ?class))
		(bind ?mkinst-string (str-cat$ (create$
			"(" make-instance (sym-cat ?class -derived-class) of derived-class-inst 
				"(" deductive-rules (symbol-to-instance-name ?rule-name) ")"
				"(" class-refs $?reference-types ")"
			")"
		)))
		(eval ?mkinst-string)
		;(funcall make-instance (sym-cat ?class -derived-class) of derived-class-inst 
		;	(create$ deductive-rules (symbol-to-instance-name ?rule-name))
		;	(create$ class-refs $?reference-types)
		;)
		(if (member$ rdfs:Class (funcall class-superclasses derived-class-inst))
		   then
		   	(modify-instance (class-instance-name ?class) 
		   		(aliases rdfs:seeAlso rdfs:isDefinedBy)
				(rdf:type [rdfs:Class])
				(rdfs:subClassOf [derived-class-inst])
				(rdfs:label ?class)
			)
			(slot-insert$ (class-instance-name ?class) class-refs 1
				rdfs:isDefinedBy rdfs:Resource
				rdf:type rdfs:Class
				rdfs:seeAlso rdfs:Resource
				rdfs:subClassOf rdfs:Class
				deductive-rules r-device-rule
			)
		)
	   	(bind ?derived-class-definition-string
	   		(str-cat$ (create$ 
	   			"(" defclass ?class 
	   				"(" is-a ?derived-meta-class ")"
	   				$?slot-defs 
					;"(" multislot class-refs 
					;	"(" source composite ")"
					;	"(" default $?reference-types ")"
					;")"
					(if (eq ?namespace nil)
					   then
					   	(create$)
					   else
					   	(create$ "(" slot namespace
								"(" source composite ")"
								"(" default ?namespace ")"
							 ")"
						)
					)
	   			")"
	   		))
	   	)
	   	(my-build ?derived-class-definition-string)
	   	(save-compiled-derived-class ?derived-class-definition-string)
	   else
		 (if (instance-existp (symbol-to-instance-name (sym-cat ?class -derived-class)))
	   	   then
	   	   	(slot-insert$ (symbol-to-instance-name (sym-cat ?class -derived-class)) deductive-rules 1 (symbol-to-instance-name ?rule-name))
	   		(bind $?new-slot-defs (needs-redefinition ?class $?slot-defs))
	   		(if (neq $?new-slot-defs FALSE)
	   		   then
	   		   	(re-define-class ?class $?new-slot-defs)
	   		)
	   	   else
	   	   	(bind ?mkinst-string (str-cat$ (create$
				"(" make-instance (sym-cat ?class -derived-class) of derived-class-inst 
					"(" deductive-rules (symbol-to-instance-name ?rule-name) ")"
					"(" class-refs $?reference-types ")"
				")"
			)))
			(eval ?mkinst-string)
	   	   	;(funcall make-instance (sym-cat ?class -derived-class) of derived-class-inst 
	   	   	;	(create$ deductive-rules (symbol-to-instance-name ?rule-name))
			;	(create$ class-refs $?reference-types)
	   	   	;)
	   	   	(if (member$ rdfs:Class (funcall class-superclasses derived-class-inst))
			   then
			   	(modify-instance (class-instance-name ?class) 
			   		(aliases rdfs:seeAlso rdfs:isDefinedBy)
					(rdf:type [rdfs:Class])
					(rdfs:subClassOf [derived-class-inst])
					(rdfs:label ?class)
				)
				(slot-insert$ (class-instance-name ?class) class-refs 1
					rdfs:isDefinedBy rdfs:Resource
					rdf:type rdfs:Class
					rdfs:seeAlso rdfs:Resource
					rdfs:subClassOf rdfs:Class
					deductive-rules r-device-rule
				)
			)
	   	)
	)
	?class
)

(deffunction collect-slot-values ($?slot-vectors)
	(bind $?result (create$))
	(while (> (length$ $?slot-vectors) 0)
	   do
	   	(bind ?p2 (get-token $?slot-vectors))
	   	(bind $?first-slot-vector (subseq$ $?slot-vectors 1 ?p2))
	   	;(bind $?first-slot-value (subseq$ $?first-slot-vector 3 (- (length$ $?first-slot-vector) 1)))
	   	;(bind $?result (create$ $?result "(" make-symbol (subseq$ $?first-slot-vector 3 (- (length$ $?first-slot-vector) 1)) ")" ))
	   	(bind $?result (create$ $?result (subseq$ $?first-slot-vector 3 (- (length$ $?first-slot-vector) 1)) ))
	   	(bind $?slot-vectors (subseq$ $?slot-vectors (+ ?p2 1) (length$ $?slot-vectors)))
	)
	$?result
)



;(deffunction get-object-address-vars ($?condition)
;	(bind $?result (create$))
;	(while (> (length$ $?condition) 0)
;	   do
;		;(bind ?p2 (get-token $?condition))
;		(if (neq (nth$ 1 $?condition) "(")
;		   then
;			(bind $?result (create$ $?result "(" instance-name (nth$ 1 $?condition) ")" ))
;		)
;		(bind $?condition (subseq$ $?condition (+ (get-token $?condition) 1) (length$ $?condition)))
;	)
;	$?result
;)

(deffunction get-object-address-vars ($?condition)
	(bind $?result (create$))
	(while (> (length$ $?condition) 0)
	   do
		;(bind ?p2 (get-token $?condition))
		; Should cater for and/or conditions
		(if (and 
			(eq (nth$ 2 $?condition) object)
			(eq (nth$ 4 $?condition) name))
		   then
			(bind $?result (create$ $?result (nth$ 5 $?condition)))
		)
		(bind $?condition (subseq$ $?condition (+ (get-token $?condition) 1) (length$ $?condition)))
	)
	$?result
)

(deffunction get-object-names-and-classes ($?condition)
	(bind $?result (create$))
	(while (> (length$ $?condition) 0)
	   do
		;(bind ?p2 (get-token $?condition))
		; Should cater for and/or conditions
		(if (and 
			(eq (nth$ 2 $?condition) object)
			(eq (nth$ 4 $?condition) name))
		   then
			(bind $?result (create$ $?result (subseq$ $?condition 1 10) ")" ))
		)
		(bind $?condition (subseq$ $?condition (+ (get-token $?condition) 1) (length$ $?condition)))
	)
	$?result
)

(deffunction is-function ($?slot)
	(and
		(eq (nth$ 3 $?slot) "(")
	   	(is-aggregate-function (nth$ 4 $?slot))
	   	(is-var (nth$ 5 $?slot))
	)
)

(deffunction extract-functions ($?conclusion)
	(bind $?slots (subseq$ $?conclusion 3 (- (length$ $?conclusion) 1)))
	(bind $?result (create$))
	(while (> (length$ $?slots) 0)
	   do
	   	(bind ?p2 (get-token $?slots))
	   	(bind $?first-slot (subseq$ $?slots 1 ?p2))
	   	(if (is-function $?first-slot)
	   	   then
	   	   	(bind $?result (create$ $?result $?first-slot))
	   	   	(break)
	   	)
	   	(bind $?slots (subseq$ $?slots (+ ?p2 1) (length$ $?slots)))
	)
	(if (> (length$ $?result) 0)
	   then
		(return (create$ "(" (nth$ 2 $?conclusion) $?result ")"))
	   else
	   	(return (create$))
	)
)

(deffunction remove-functions ($?conclusion)
	(bind $?slots (subseq$ $?conclusion 3 (- (length$ $?conclusion) 1)))
	(bind $?result (create$))
	(while (> (length$ $?slots) 0)
	   do
	   	(bind ?p2 (get-token $?slots))
	   	(bind $?first-slot (subseq$ $?slots 1 ?p2))
	   	(if (not (is-function $?first-slot))
	   	   then
	   	   	(bind $?result (create$ $?result $?first-slot))
	   	)
	   	(bind $?slots (subseq$ $?slots (+ ?p2 1) (length$ $?slots)))
	)
	(return (create$ "(" (nth$ 2 $?conclusion) $?result ")"))
)

(deffunction integrate-calc2 ($?conclusion)
	(bind ?p2 (get-token $?conclusion))
	(bind $?calc-command (subseq$ $?conclusion 3 (- ?p2 1)))
	(bind $?conclusion (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
	(while (> (length$ $?calc-command) 0)
	   do
	   	(bind ?p2 (get-token $?calc-command))
		(bind $?first-calc-command (subseq$ $?calc-command 1 ?p2))
		(bind $?calc-command (subseq$ $?calc-command (+ ?p2 1) (length$ $?calc-command)))
		(if (eq (nth$ 2 $?first-calc-command) bind)
		   then   ; It works only for multiple ...bind ?var...
		          ; that do not chain with one another!
		   	(bind ?var (nth$ 3 $?first-calc-command))
		   	(bind ?pos (member$ ?var $?conclusion))
		   	(bind $?function (subseq$ $?first-calc-command 4 (- (length$ $?first-calc-command) 1) ))
		   	(bind $?conclusion (replace$ $?conclusion ?pos ?pos $?function))
		   	;(bind $?conclusion (replace-member$ $?conclusion $?function ?var))
		)
	)
	(return $?conclusion)
)

(deffunction translate-deductive-rule (?rule-inst ?deductive-rule)
	(bind ?rule-name (instance-name-to-symbol ?rule-inst))
	(bind $?dr (my-explode$ ?deductive-rule))
	(bind ?imp_pos (member$ => $?dr))
	(bind $?condition (subseq$ $?dr 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?dr (+ ?imp_pos 1) (length$ $?dr)))
	(bind $?new-condition (translate-condition $?condition))
	(bind ?p2 (get-token $?conclusion))
	(if (eq (nth$ 2 (subseq$ $?conclusion (member "(" $?conclusion) ?p2)) calc)
	   then
	   	(bind $?init-concl (subseq$ $?conclusion 3 (- ?p2 1)))
		(bind $?rest-concl (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
		(bind $?actual-concl (integrate-calc2 $?conclusion ))
	   else
	   	(bind $?init-concl (create$))
		(bind $?rest-concl $?conclusion )
		(bind $?actual-concl $?rest-concl)
	)
	;(bind $?conclusion-values (collect-slot-values (subseq$ $?rest-concl 3 (- (length$ $?rest-concl) 1))))
	(bind ?pos-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind ?class (create-template yes ?pos-rule-name (create$ $?new-condition $$$ $?rest-concl)))
	(bind $?function-concl (extract-functions $?rest-concl))
	(bind $?rest-concl (remove-functions $?rest-concl))
	(bind $?actual-concl (remove-functions $?actual-concl))
	(if (> (length$ $?function-concl) 0)
	   then
		(bind ?new-var (str-cat "?" (gensym)))
		(assert (aggregateattrule (str-cat$
			$?condition
			?new-var <- $?rest-concl
			  =>
			?new-var <- $?function-concl
		)))
		(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
	)
	;(bind $?inst (create$ "(" symbol-to-instance-name "(" sym-cat ?class (collect-slot-values (subseq$ $?rest-concl 3 (- (length$ $?rest-concl) 1))) ")" ")" ))
	(bind $?inst (create$ "(" symbol-to-instance-name "(" sym-cat ?class (collect-slot-values (subseq$ $?actual-concl 3 (- (length$ $?actual-concl) 1))) ")" ")" ))
	(bind $?object-address-vars (get-object-address-vars $?new-condition))
	(bind $?object-names-and-classes (get-object-names-and-classes $?new-condition))
	(bind $?derived-slots (subseq$ $?rest-concl 3 (- (length$ $?rest-concl) 1)))
	(bind ?production-rule (str-cat$ (create$ 
		"(" defrule ?pos-rule-name 
			"(" declare "(" salience "(" calc-salience ?class ")" ")" ")"
			"(" run-deductive-rules ")"
			$?new-condition 
			"(" not 
				"(" and
					"(" object 
				;		"(" name "?DO" "&" ":(" eq "?DO" $?inst ")" ")"
						"(" name "?DO" ")"
						"(" is-a ?class ")"
						$?derived-slots
				;		"(" counter "?old-counter" ")" 
				;		"(" derivators "$?" "?derivator" "$?" ")"
	;					"(" derivators "$?" +++ $?object-address-vars +++ "$?" ")"
						"(" derivators "$?" +++ "?" $?object-address-vars +++ "$?" ")"
					")"
					"(" test "(" eq "?DO" $?inst ")" ")"
				")"
			")"

;			"(" test
;				"(" or 
;					"(" not "(" instance-existp $?inst ")" ")"
;					"(" not "(" member$ "(" implode$ "(" create$ $?object-address-vars ")" ")" "(" send $?inst get-derivators ")" ")" ")"
;					"(" neq "(" subseq-pos "(" create$ +++ $?object-address-vars  +++ $$$ "(" send $?inst get-derivators ")" ")" ")" FALSE ")"
;				")"
;			")"
		  => 
			$?init-concl
			"(" bind "?oid" $?inst ")"
			"(" if "(" instance-existp "?oid" ")"
			   	then
;			   		"(" slot-insert$ "?oid" derivators 1 "(" implode$ "(" create$ $?object-address-vars ")" ")" ")"
;			   		"(" slot-insert$ "?oid" derivators 1 +++ $?object-address-vars +++ ")"
			   		"(" slot-insert$ "?oid" derivators 1 +++ ?pos-rule-name $?object-address-vars +++ ")"
			   		"(" send "?oid" put-counter "(" + "(" send "?oid" get-counter ")" 1 ")" ")"
			   	else		
					(insert$ 
						(insert$ 
							$?rest-concl 
							(length$ $?rest-concl)
;							"(" derivators "(" implode$ "(" create$ $?object-address-vars ")" ")" ")"
;							"(" derivators +++ $?object-address-vars +++ ")"
							"(" derivators +++ ?pos-rule-name $?object-address-vars +++ ")"
						)
						2 
						make-instance "?oid" of
					)
			")"
			;"(" send "?oid" print ")"
		")"
	)))
	;(printout t "production-rule: " ?production-rule crlf)
	(bind ?del-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind ?delete-production-rule (str-cat$ (create$ 
		"(" defrule ?del-rule-name 
			"(" declare "(" salience 2000 ")" ")"
			"(" run-deductive-rules ")"
			"(" test "(" eq "(" get-truth-maintenance ")" on ")" ")"
			;"?derived-object" <- 
				"(" object 
					"(" name "?derived-object" ")"
					"(" is-a ?class ")"
					$?derived-slots
					"(" counter "?old-counter" ")" 
;					"(" derivators "$?" "?derivator" "$?" ")"
;					"(" derivators "$?DER-B" +++ $?object-address-vars +++ "$?DER-A" ")"
					"(" derivators "$?DER-B" +++ ?pos-rule-name $?object-address-vars +++ "$?DER-A" ")"
				")"

			"(" or
				"(" test 
					"(" not
						;"("all-instance-existp "(" explode$ "?derivator" ")" ")"
						"("all-instance-existp "(" create$ $?object-address-vars ")" ")"
					")"
				")"
;				(build-queries (create$ $?object-address-vars +++ $?new-condition $$$ $?conclusion))
				"(" and
					$?object-names-and-classes
					"(" not 
						(if (> (token-length $?new-condition) 1)
						   then
							(create$ "(" and $?new-condition ")" )
						   else
						   	$?new-condition
						)
					")"
				")"
			")"
		  => 
		  	;"(" printout t "derivators: " $?object-address-vars crlf ")"
			"(" bind "?new-counter" "(" - "?old-counter" 1 ")" ")"
			"(" if "(" = "?new-counter" 0 ")"
				then
					"(" send "?derived-object" delete ")"
				else
					"(" message-modify-instance "?derived-object" 
						"(" counter "?new-counter" ")" 
						"(" derivators  "$?DER-B" "$?DER-A" ")"
;						"(" derivators "(" delete-member$ "(" send "?derived-object" get-derivators ")" "?derivator" ")" ")"
					")"
			")"
		")"
	)))
	;(printout t "delete-production-rule: " ?delete-production-rule crlf)
	(modify-instance ?rule-inst
		(pos-name ?pos-rule-name) 
		(del-name ?del-rule-name) 
		(production-rule ?production-rule)
		;(delete-production-rule ?delete-production-rule) 
		(derived-class ?class)
	)
	(bind $?non-existent-class-indices (get-template-specific-facts non-existent-classes (get-fact-list)))
	(if (= (length$ $?non-existent-class-indices) 0)
	   then
		(my-build ?production-rule)
		(save-compiled-rule ?production-rule)
		(my-build ?delete-production-rule)
		(save-compiled-rule ?delete-production-rule)
	   else	   
		(bind ?idx (nth$ 1 $?non-existent-class-indices))
		(bind $?non-existent-classes (fact-slot-value ?idx implied))
		(assert (pending-rule 
				(production-rule ?production-rule) 
				(delete-production-rule ?delete-production-rule)
				(non-existent-classes (fact-slot-value ?idx implied))))
		(retract ?idx)
	)
)


(deffunction translate-ntm-deductive-rule (?rule-inst ?deductive-rule)
	(bind ?rule-name (instance-name-to-symbol ?rule-inst))
	(bind $?dr (my-explode$ ?deductive-rule))
	(bind ?imp_pos (member$ => $?dr))
	(bind $?condition (subseq$ $?dr 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?dr (+ ?imp_pos 1) (length$ $?dr)))
	(bind $?new-condition (translate-condition $?condition))
	(bind ?p2 (get-token $?conclusion))
	(if (eq (nth$ 2 (subseq$ $?conclusion (member "(" $?conclusion) ?p2)) calc)
	   then
	   	(bind $?init-concl (subseq$ $?conclusion 3 (- ?p2 1)))
		(bind $?rest-concl (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
		(bind $?actual-concl (integrate-calc2 $?conclusion ))
	   else
	   	(bind $?init-concl (create$))
		(bind $?rest-concl $?conclusion )
		(bind $?actual-concl $?rest-concl)
	)
	;(bind $?conclusion-values (collect-slot-values (subseq$ $?rest-concl 3 (- (length$ $?rest-concl) 1))))
	(bind ?pos-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind ?class (create-template no ?pos-rule-name (create$ $?new-condition $$$ $?rest-concl)))
	(bind $?function-concl (extract-functions $?rest-concl))
	(bind $?rest-concl (remove-functions $?rest-concl))
	(bind $?actual-concl (remove-functions $?actual-concl))
	(if (> (length$ $?function-concl) 0)
	   then
		(bind ?new-var (str-cat "?" (gensym)))
		(assert (ntm-aggregateattrule (str-cat$
			$?condition
			?new-var <- $?rest-concl
			  =>
			?new-var <- $?function-concl
		)))
		(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
	)
	;(bind $?inst (create$ "(" symbol-to-instance-name "(" sym-cat ?class (collect-slot-values (subseq$ $?rest-concl 3 (- (length$ $?rest-concl) 1))) ")" ")" ))
	;(printout t "rule-name: " ?rule-name crlf)
	;(printout t "Actual concl: " $?actual-concl crlf)
	(bind $?inst (create$ "(" symbol-to-instance-name "(" sym-cat ?class (collect-slot-values (subseq$ $?actual-concl 3 (- (length$ $?actual-concl) 1))) ")" ")" ))
	;(bind $?object-address-vars (get-object-address-vars $?new-condition))
	;(bind $?object-names-and-classes (get-object-names-and-classes $?new-condition))
	;(bind $?derived-slots (subseq$ $?rest-concl 3 (- (length$ $?rest-concl) 1)))
	(bind ?production-rule (str-cat$ (create$ 
		"(" defrule ?pos-rule-name 
			"(" declare "(" salience "(" calc-salience ?class ")" ")" ")"
			"(" run-deductive-rules ")"
			$?new-condition 
			"(" test "(" not "(" instance-existp $?inst ")" ")" ")"
	;		"(" not 
;				"(" and
	;				"(" object 
	;					"(" name "?DO" "&" ":(" eq "?DO" $?inst ")" ")"
	;					"(" is-a ?class ")"
;						$?derived-slots
;						"(" derivators "$?" +++ "?" $?object-address-vars +++ "$?" ")"
	;				")"
;					"(" test "(" eq "?DO" $?inst ")" ")"
;				")"
	;		")"
		  => 
			$?init-concl
			"(" bind "?oid" $?inst ")"
;			"(" if "(" instance-existp "?oid" ")"
;			   	then
;			   		"(" slot-insert$ "?oid" derivators 1 +++ ?pos-rule-name $?object-address-vars +++ ")"
;			   		"(" send "?oid" put-counter "(" + "(" send "?oid" get-counter ")" 1 ")" ")"
;			   	else		
					(insert$ 
;						(insert$ 
							$?rest-concl 
;							(length$ $?rest-concl)
;							"(" derivators +++ ?pos-rule-name $?object-address-vars +++ ")"
;						)
						2 
						make-instance "?oid" of
					)
;			")"
		")"
	)))
;(printout t "production-rule: " ?production-rule crlf)
	(modify-instance ?rule-inst
		(pos-name ?pos-rule-name) 
		(production-rule ?production-rule)
		(derived-class ?class)
	)
	(bind $?non-existent-class-indices (get-template-specific-facts non-existent-classes (get-fact-list)))
	(if (= (length$ $?non-existent-class-indices) 0)
	   then
		(my-build ?production-rule)
		(save-compiled-rule ?production-rule)
	   else	   
		(bind ?idx (nth$ 1 $?non-existent-class-indices))
		(bind $?non-existent-classes (fact-slot-value ?idx implied))
		(assert (pending-rule 
				(production-rule ?production-rule) 
				(delete-production-rule "")
				(non-existent-classes (fact-slot-value ?idx implied))))
		(retract ?idx)
	)
)


(deffunction nullify-slots (?class $?slots)
	(bind $?result (create$))
	(while (> (length$ $?slots) 0)
	   do
	   	(bind ?p2 (get-token $?slots))
		(bind $?first-slot (subseq$ $?slots 1 ?p2))
		(bind ?slot-name (nth$ 2 $?first-slot))
		(bind ?default-value (slot-default-value ?class ?slot-name))
		(bind $?result (create$ $?result (replace$ $?first-slot 3 3 ?default-value)))
		(bind $?slots (subseq$ $?slots (+ ?p2 1) (length$ $?slots)))
	)
	$?result
)

(deffunction not-nil-slots ($?slots)
	(bind $?result (create$))
	(while (> (length$ $?slots) 0)
	   do
	   	(bind ?p2 (get-token $?slots))
		(bind $?first-slot (subseq$ $?slots 1 ?p2))
		(if (neq (nth$ 1 $?first-slot) "(")
		   then
			(bind ?class (nth$ 1 $?first-slot))
			(bind $?first-slot (rest$ $?first-slot))
		)
		(bind ?slot-name (nth$ 2 $?first-slot))
		(bind ?var-or-else (nth$ 3 $?first-slot))
		(if (and (is-var ?var-or-else) (= (length$ $?first-slot) 4))
		   then
		   	(if (slot-existp ?class ?slot-name inherit)
		   	   then
		   	   	(bind ?default-value (slot-default-value ?class ?slot-name))
		   	   else
		   	   	(bind ?default-value nil)
		   	)
			(if (eq ?default-value (create$))
			   then
			   	(bind ?default-value "(create$)")
			   else
			   	(if (eq ?default-value 0)
			   	   then
			   	   	(bind ?default-value nil)
			   	)
			)
			(bind $?result (create$ $?result "(" neq ?var-or-else ?default-value ")"))
		)
		(bind $?slots (subseq$ $?slots (+ ?p2 1) (length$ $?slots)))
	)
	$?result
)

(deffunction collect-condition-slots ($?condition)
	(bind $?result (create$))
	(while (> (length$ $?condition) 0)
	   do
	   	(bind ?p2 (get-token $?condition))
		(bind $?first-cond-elem (subseq$ $?condition 1 ?p2))
;		(bind $?result (create$ $?result (subseq$ $?first-cond-elem 9 (- (length$ $?first-cond-elem) 1))))
		(if (neq (nth$ 2 $?first-cond-elem) not)
		   then
		   	(bind $?slots (subseq$ $?first-cond-elem 11 (- (length$ $?first-cond-elem) 1)))
		   	(if (> (length$ $?slots) 0)
		   	   then
				(bind $?result (create$ $?result (nth$ 9 $?first-cond-elem) $?slots))
			)
		   ;else
			;(bind $?result (create$ $?result (nth$ 7 $?first-cond-elem) (subseq$ $?first-cond-elem 9 (- (length$ $?first-cond-elem) 2))))
		)
		(bind $?condition (subseq$ $?condition (+ ?p2 1) (length$ $?condition)))
	)
	$?result
)

(deffunction discover-salience ($?condition)
	(if (and (eq (nth$ 2 $?condition) declare)
		 (eq (nth$ 4 $?condition) priority))
	   then
		;(return (nth$ 5 $?condition))
		(bind ?p2 (get-token $?condition))
		(return (subseq$ $?condition 5 (- ?p2 2)))
	   else
	   	(return 0)
	)
)

(deffunction remove-salience ($?condition)
	(if (and (eq (nth$ 2 $?condition) declare)
		 (eq (nth$ 4 $?condition) priority))
	   then
		(bind ?p2 (get-token $?condition))
	   	(return (subseq$ $?condition (+ ?p2 1) (length$ $?condition)))
	   	;(return (subseq$ $?condition 8 (length$ $?condition)))
	   else
	   	(return $?condition)
	)
)

(deffunction integrate-calc ($?conclusion)
	(bind ?p2 (get-token $?conclusion))
	(bind $?calc-command (subseq$ $?conclusion 3 (- ?p2 1)))
	(bind $?conclusion (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
	(while (> (length$ $?calc-command) 0)
	   do
	   	(bind ?p2 (get-token $?calc-command))
		(bind $?first-calc-command (subseq$ $?calc-command 1 ?p2))
		(bind $?calc-command (subseq$ $?calc-command (+ ?p2 1) (length$ $?calc-command)))
		(if (eq (nth$ 2 $?first-calc-command) bind)
		   then   ; It works only for multiple ...bind ?var...
		          ; that do not chain with one another!
		   	(bind ?var (nth$ 3 $?first-calc-command))
		   	(bind ?pos (member$ ?var $?conclusion))
		   	(bind $?function (subseq$ $?first-calc-command 4 (- (length$ $?first-calc-command) 1) ))
		   	(bind $?function (create$ "&" ":" "(" eq ?var $?function")" ) )
		   	(bind $?conclusion (insert$ $?conclusion (+ ?pos 1) $?function))
		   	;(bind $?conclusion (replace-member$ $?conclusion $?function ?var))
		)
	)
	(return $?conclusion)
)

(deffunction delete-slot (?slot-name $?condition-element)
	(bind $?slots (subseq$ $?condition-element 11 (- (length$ $?condition-element) 1)))
	(bind $?new-slots (create$))
	(while (> (length$ $?slots) 0)
	   do
	   	(bind ?p2 (get-token $?slots))
	   	(bind $?first-slot (subseq$ $?slots 1 ?p2))
		(bind $?slots (subseq$ $?slots (+ ?p2 1) (length$ $?slots)))
		(if (neq (nth$ 2 $?first-slot) ?slot-name)
		   then
		   	(bind $?new-slots (create$ $?new-slots $?first-slot))
		)
	)
	(return (create$ (subseq$ $?condition-element 1 10) $?new-slots ")"))
)
	   	

(deffunction exclude-slots (?derived-object $?double-list)
	(bind $?delete-rule-slots (subseq$ $?double-list 1 (- (member$ $$$ $?double-list) 1)))
	(bind $?new-condition (subseq$ $?double-list (+ (member$ $$$ $?double-list) 1) (length$ $?double-list)))
	(bind $?result (create$))
	(while (> (length$ $?new-condition) 0)
	   do
	   	(bind ?p2 (get-token $?new-condition))
		(bind $?first-new-condition (subseq$ $?new-condition 1 ?p2))
		(bind $?new-condition (subseq$ $?new-condition (+ ?p2 1) (length$ $?new-condition)))
		(if (eq (nth$ 5 $?first-new-condition) ?derived-object)
		   then
		   	(while (> (length$ $?delete-rule-slots) 0)
		   	   do
		   	   	(bind ?p2a (get-token $?delete-rule-slots))
		   	   	(bind $?first-delete-rule-slot (subseq$ $?delete-rule-slots 1 ?p2a))
		   	   	(bind $?delete-rule-slots (subseq$ $?delete-rule-slots (+ ?p2a 1) (length$ $?delete-rule-slots)))
		   	   	(bind ?slot-name (nth$ 2 $?first-delete-rule-slot))
		   	   	(bind $?first-new-condition (delete-slot ?slot-name $?first-new-condition))
		   	   	;(bind $?first-new-condition (delete-member$ $?first-new-condition $?first-delete-rule-slot))
		   	)
		)
		(bind $?result (create$ $?result $?first-new-condition))
	)
	(return $?result)
)

;(deffunction translate-derived-attribute-rule (?rule-index ?derived-attribute-rule)
(deffunction translate-derived-attribute-rule (?derived-attribute-rule ?rule-name $?d-classes)
	(debug "Derived attribute rule: " ?rule-name " " ?derived-attribute-rule crlf)
	(bind $?dar (my-explode$ ?derived-attribute-rule))
	(bind ?imp_pos (member$ => $?dar))
	(bind $?condition (subseq$ $?dar 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?dar (+ ?imp_pos 1) (length$ $?dar)))
	(bind $?salience (discover-salience $?condition))
	(bind $?condition (remove-salience $?condition))
	(bind $?new-condition (translate-condition $?condition))
	(bind ?implies-class (nth$ 1 $?d-classes))
	(bind $?depends-classes (rest$ $?d-classes))
	;(bind ?p1 (member "(" $?conclusion))
	(bind ?p2 (get-token $?conclusion))
	;(bind $?first-concl-elem (subseq$ $?conclusion (member "(" $?conclusion) ?p2))
	(if (eq (nth$ 2 (subseq$ $?conclusion (member "(" $?conclusion) ?p2)) calc)
	   then
	   	(bind $?init-concl (subseq$ $?conclusion 3 (- ?p2 1)))
		(bind $?rest-concl (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
		(bind $?actual-concl (translate-condition (integrate-calc $?conclusion)))
	   else
	   	(bind $?init-concl (create$))
		(bind $?rest-concl $?conclusion )
		(bind $?actual-concl (translate-condition $?rest-concl))
	)
	(bind ?derived-object (nth$ 1 $?rest-concl))
	(bind $?derived-slots (subseq$ $?rest-concl 5 (- (length$ $?rest-concl) 1)))
	(bind ?pos-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind ?del-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind $?concl-as-cond (transform-one-cond-elem $?rest-concl))
	(bind $?var-class-pairs (collect-var-class-pairs $?concl-as-cond))
	;(bind $?slot-predicates (collect-slot-predicates $?concl-as-cond))
	(bind $?encaps-slots (create$ $?derived-slots (inverse-brackets (reverse$ $?var-class-pairs))))
	(bind $?encaps-preds (create$ $?init-concl (collect-slot-predicates $?concl-as-cond)))
	(while (> (length$ $?encaps-slots) 0)
	   do
	   	(bind ?p2 (get-token $?encaps-slots))
		;(bind $?first-slot (subseq$ $?encaps-slots 1 ?p2))
		;(bind ?current-value (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)))
		(bind $?encaps-preds (collapse-vars (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)) $?encaps-preds))
		(bind $?encaps-slots (subseq$ $?encaps-slots (+ ?p2 1) (length$ $?encaps-slots)))
	)
	;(bind $?copy-var-class-pairs $?var-class-pairs)
	;(while (> (length$ $?copy-var-class-pairs) 0)
	;   do
	;   	(bind ?p2 (get-token $?copy-var-class-pairs))
		;(bind $?first-pair (subseq$ $?copy-var-class-pairs 1 ?p2))
	;	(bind ?one-class-var (nth$ 2 (subseq$ $?copy-var-class-pairs 1 ?p2)))
	;	(bind $?encaps-preds (replace-member$ $?encaps-preds (create$ "(" instance-address ?one-class-var ")") ?one-class-var))
	;	(bind $?copy-var-class-pairs (subseq$ $?copy-var-class-pairs (+ ?p2 1) (length$ $?copy-var-class-pairs)))
	;)
	;(bind $?all-condition-slots (collect-condition-slots $?new-condition))
	(bind $?not-nil-slot-tests (not-nil-slots (collect-condition-slots $?new-condition)))
	(bind ?production-rule (str-cat$ (create$ 
		"(" defrule ?pos-rule-name 
			"(" declare "(" salience "(" + 1000 $?salience ")" ")" ")"          ; NEEDS STRATIFICATION
			"(" run-deductive-rules ")"
			$?new-condition
			(if (> (token-length $?not-nil-slot-tests) 0)
			   then
			   	(create$ 
					"(" test 
						(if (= (token-length $?not-nil-slot-tests) 1)
						   then
						   	(create$ $?not-nil-slot-tests)
						   else
							(create$ "(" and $?not-nil-slot-tests ")" )
						)
					")"
				)
			   else
			   	""
			)
	; I must remember what is the role of this, because it seems unnecessary
	; May be it can be transferred to the action of the rule
;			"(" not 
;				"(" test 
;					"(" any-instancep 
;						"(" $?var-class-pairs ")" 
;						(if (= (token-length $?encaps-preds) 1)
;						   then
;						   	(create$ $?encaps-preds)
;						   else
;						   	(create$ "(" and $?encaps-preds ")")
;						)
;					")" 
;				")"
;			")"
			"(" not $?actual-concl ")"
			"(" test "(" instance-existp ?derived-object ")" ")"
		  => 
			$?init-concl 
			"(" message-modify-instance ?derived-object $?derived-slots ")"
		")"
	)))
	(bind $?var-class-pairs (collect-var-class-pairs $?new-condition))
	;(bind $?slot-predicates (collect-slot-predicates $?new-condition))
	(bind $?encaps-slots (create$ $?derived-slots (inverse-brackets (reverse$ $?var-class-pairs))))
	(bind $?encaps-preds (create$ $?init-concl $?not-nil-slot-tests (collect-slot-predicates $?new-condition)))
	(while (> (length$ $?encaps-slots) 0)
	   do
	   	(bind ?p2 (get-token $?encaps-slots))
		;(bind $?first-slot (subseq$ $?encaps-slots 1 ?p2))
		;(bind ?current-value (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)))
		(bind $?encaps-preds (collapse-vars (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)) $?encaps-preds))
		(bind $?encaps-slots (subseq$ $?encaps-slots (+ ?p2 1) (length$ $?encaps-slots)))
	)
;	(bind $?copy-var-class-pairs $?var-class-pairs)
;	(while (> (length$ $?copy-var-class-pairs) 0)
;	   do
;	   	(bind ?p2 (get-token $?copy-var-class-pairs))
;		;(bind $?first-pair (subseq$ $?copy-var-class-pairs 1 ?p2))
;		(bind ?one-class-var (nth$ 2 (subseq$ $?copy-var-class-pairs 1 ?p2)))
;		(bind $?encaps-preds (replace-member$ $?encaps-preds (create$ "(" instance-address ?one-class-var ")") ?one-class-var))
;		(bind $?copy-var-class-pairs (subseq$ $?copy-var-class-pairs (+ ?p2 1) (length$ $?copy-var-class-pairs)))
;	)
	(bind $?not-nil-slot-tests (not-nil-slots (create$ ?implies-class $?derived-slots)))
	(bind $?delete-rule-slots (nullify-slots ?implies-class $?derived-slots))
	(bind $?delete-new-condition (exclude-slots ?derived-object (create$ $?delete-rule-slots $$$ $?new-condition)))
	(bind ?delete-production-rule (str-cat$ (create$ 
		"(" defrule ?del-rule-name 
			"(" declare "(" salience "(" + 500 $?salience ")" ")" ")"        ; NEEDS STRATIFICATION
			"(" run-deductive-rules ")"
			;"(" test "(" eq "(" get-truth-maintenance ")" on ")" ")"
			;$?concl-as-cond
			$?actual-concl
			(if (> (token-length $?not-nil-slot-tests) 0)
			   then
			   	(create$
					"(" test 
						(if (= (token-length $?not-nil-slot-tests) 1)
						   then
						   	(create$ $?not-nil-slot-tests)
						   else
							(create$ "(" and $?not-nil-slot-tests ")" )
						)
					")"
				)
			   else
			   	""
			)
	; I must remember what is the role of this, because it seems unnecessary
	; May be it can be transferred to the action of the rule
	;		"(" not 
	;			"(" test 
	;				"(" any-instancep 
	;					"(" $?var-class-pairs ")" 
	;					(if (= (token-length $?encaps-preds) 1)
	;					   then
	;					   	(create$ $?encaps-preds)
	;					   else
	;					   	(create$ "(" and $?encaps-preds ")")
	;					)
	;				")"
	;			")"
	;		")"
			"(" not 
				(if (= (token-length $?delete-new-condition) 1)
				   then
					$?delete-new-condition 
				   else
				   	(create$ "(" and $?delete-new-condition ")")
				)
			")"
			"(" test "(" instance-existp ?derived-object ")" ")"
		  => 
			"(" message-modify-instance ?derived-object $?delete-rule-slots ")"
		")"
	)))
	(make-instance  ?rule-name of derived-attribute-rule
		(derived-attribute-rule ?derived-attribute-rule)
		(pos-name ?pos-rule-name) 
		(del-name ?del-rule-name) 
		(implies ?implies-class)
		(depends-on $?depends-classes)
		;(production-rule ?production-rule) 
		;(delete-production-rule ?delete-production-rule)
	)
	(my-build ?production-rule)
	(save-compiled-rule ?production-rule)
	(my-build ?delete-production-rule)
	(save-compiled-rule ?delete-production-rule)
)

(deffunction translate-ntm-derived-attribute-rule (?derived-attribute-rule ?rule-name $?d-classes)
	(debug "Derived attribute rule: " ?rule-name " " ?derived-attribute-rule crlf)
	(bind $?dar (my-explode$ ?derived-attribute-rule))
	(bind ?imp_pos (member$ => $?dar))
	(bind $?condition (subseq$ $?dar 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?dar (+ ?imp_pos 1) (length$ $?dar)))
	(bind $?salience (discover-salience $?condition))
	(bind $?condition (remove-salience $?condition))
	(bind $?new-condition (translate-condition $?condition))
	(bind ?implies-class (nth$ 1 $?d-classes))
	(bind $?depends-classes (rest$ $?d-classes))
	;(bind ?p1 (member "(" $?conclusion))
	(bind ?p2 (get-token $?conclusion))
	;(bind $?first-concl-elem (subseq$ $?conclusion (member "(" $?conclusion) ?p2))
	(if (eq (nth$ 2 (subseq$ $?conclusion (member "(" $?conclusion) ?p2)) calc)
	   then
	   	(bind $?init-concl (subseq$ $?conclusion 3 (- ?p2 1)))
		(bind $?rest-concl (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
		(bind $?actual-concl (translate-condition (integrate-calc $?conclusion)))
	   else
	   	(bind $?init-concl (create$))
		(bind $?rest-concl $?conclusion )
		(bind $?actual-concl (translate-condition $?rest-concl))
	)
	(bind ?derived-object (nth$ 1 $?rest-concl))
	(bind $?derived-slots (subseq$ $?rest-concl 5 (- (length$ $?rest-concl) 1)))
	(bind ?pos-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind ?del-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind $?concl-as-cond (transform-one-cond-elem $?rest-concl))
	(bind $?var-class-pairs (collect-var-class-pairs $?concl-as-cond))
	;(bind $?slot-predicates (collect-slot-predicates $?concl-as-cond))
	(bind $?encaps-slots (create$ $?derived-slots (inverse-brackets (reverse$ $?var-class-pairs))))
	(bind $?encaps-preds (create$ $?init-concl (collect-slot-predicates $?concl-as-cond)))
	(while (> (length$ $?encaps-slots) 0)
	   do
	   	(bind ?p2 (get-token $?encaps-slots))
		;(bind $?first-slot (subseq$ $?encaps-slots 1 ?p2))
		;(bind ?current-value (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)))
		(bind $?encaps-preds (collapse-vars (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)) $?encaps-preds))
		(bind $?encaps-slots (subseq$ $?encaps-slots (+ ?p2 1) (length$ $?encaps-slots)))
	)
	(bind $?not-nil-slot-tests (not-nil-slots (collect-condition-slots $?new-condition)))
	(bind ?production-rule (str-cat$ (create$ 
		"(" defrule ?pos-rule-name 
			"(" declare "(" salience "(" + 1000 $?salience ")" ")" ")"          ; NEEDS STRATIFICATION
			"(" run-deductive-rules ")"
			$?new-condition
			(if (> (token-length $?not-nil-slot-tests) 0)
			   then
			   	(create$ 
					"(" test 
						(if (= (token-length $?not-nil-slot-tests) 1)
						   then
						   	(create$ $?not-nil-slot-tests)
						   else
							(create$ "(" and $?not-nil-slot-tests ")" )
						)
					")"
				)
			   else
			   	""
			)
			"(" not $?actual-concl ")"
			"(" test "(" instance-existp ?derived-object ")" ")"
		  => 
			$?init-concl 
			"(" message-modify-instance ?derived-object $?derived-slots ")"
		")"
	)))
	(make-instance  ?rule-name of derived-attribute-rule
		(derived-attribute-rule ?derived-attribute-rule)
		(pos-name ?pos-rule-name) 
		(del-name nil) 
		(implies ?implies-class)
		(depends-on $?depends-classes)
		;(production-rule ?production-rule) 
		;(delete-production-rule ?delete-production-rule)
	)
	(my-build ?production-rule)
	(save-compiled-rule ?production-rule)
)


(deffunction find-object-of-value (?value-var $?condition)
	(while (> (length$ $?condition) 0)
	   do
	   	(bind ?p2 (get-token $?condition))
		;(bind $?first-cond-elem (subseq$ $?condition 1 ?p2))
		(if (member$ ?value-var (subseq$ $?condition 1 ?p2))
		   then
		   	;(return (nth$ 1 $?condition))
		   	(return (nth$ 5 $?condition))
		)
		(bind $?condition (subseq$ $?condition (+ ?p2 1) (length$ $?condition)))
	)
	FALSE
)

(deffunction find-depend-var-aux ($?expression)
	(bind ?end (length$ $?expression))
	(loop-for-count (?n 1 ?end)
	   do
		(if (is-var (nth$ ?n $?expression))
		   then
		   	(return (nth$ ?n $?expression))
		)
	)
	FALSE
)

(deffunction find-depend-var (?var $?code)
	(while (> (length$ $?code) 0)
	   do
	   	(bind ?p2 (get-token $?code))
		(bind $?first-code-elem (subseq$ $?code 1 ?p2))
		(if (and
			(eq (nth$ 2 $?first-code-elem) bind)
			(eq (nth$ 3 $?first-code-elem) ?var))
		   then
			(return (find-depend-var-aux (subseq$ $?first-code-elem 4 (- (length$ $?first-code-elem) 1))))
		)
		(bind $?code (subseq$ $?code (+ ?p2 1) (length$ $?code)))
	)
	FALSE
)

(deffunction remove-aggregate-slot (?slot $?encaps-preds)
	(bind $?result (create$))
	(while (> (length$ $?encaps-preds) 0)
	   do
	   	(bind ?p2 (get-token $?encaps-preds))
	   	(bind $?first-pred (subseq$ $?encaps-preds 1 ?p2))
	   	(bind $?encaps-preds (subseq$ $?encaps-preds (+ ?p2 1) (length$ $?encaps-preds)))
	   	(bind ?end (length$ $?first-pred))
	   	(bind ?found FALSE)
	   	(loop-for-count (?n 1 ?end)
	   	   do
	   	   	(if (and 
	   	   		(lexemep (nth$ ?n $?first-pred)) 
	   	   		(neq (str-index ?slot (nth$ ?n $?first-pred)) FALSE))
	   	   	   then
	   	   	   	(bind ?found TRUE)
	   	   	   	(break)
	   	   	)
	   	)
	   	(if (eq ?found FALSE)
	   	   then
	   	   	(bind $?result (create$ $?result $?first-pred))
	   	)
	)
	(return $?result)
)

;(deffunction translate-aggregate-attribute-rule (?rule-index ?aggregate-attribute-rule)
(deffunction translate-aggregate-attribute-rule (?aggregate-attribute-rule ?rule-name $?d-classes)
	(debug "Aggregate attribute rule: " ?rule-name " " ?aggregate-attribute-rule crlf)
	(bind $?aar (my-explode$ ?aggregate-attribute-rule))
	(bind ?imp_pos (member$ => $?aar))
	(bind $?condition (subseq$ $?aar 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?aar (+ ?imp_pos 1) (length$ $?aar)))
	(bind $?salience (discover-salience $?condition))
	(bind $?condition (remove-salience $?condition))
	(bind $?new-condition (translate-condition $?condition))
	(bind ?implies-class (nth$ 1 $?d-classes))
	(bind $?depends-classes (rest$ $?d-classes))
	;(bind ?p1 (member "(" $?conclusion))
	(bind ?p2 (get-token $?conclusion))
	;(bind $?first-concl-elem (subseq$ $?conclusion (member "(" $?conclusion) ?p2))
	(if (eq (nth$ 2 (subseq$ $?conclusion (member "(" $?conclusion) ?p2)) calc)
	   then
	   	(bind $?init-concl (subseq$ $?conclusion 3 (- ?p2 1)))
		(bind $?rest-concl (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
		(bind $?actual-concl (translate-condition (integrate-calc $?conclusion)))
	   else
	   	(bind $?init-concl (create$))
		(bind $?rest-concl $?conclusion )
		(bind $?actual-concl (translate-condition $?rest-concl))
	)
	(bind ?pos-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind ?del-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind ?derived-object (nth$ 1 $?rest-concl))
	(bind ?class (nth$ 4 $?rest-concl))
	(bind ?att (nth$ 6 $?rest-concl))
	(bind ?aggregate-fun (nth$ 8 $?rest-concl))
	(bind ?current-value (nth$ 9 $?rest-concl))
	(if (member$ ?current-value $?new-condition)
	   then
		(bind ?object-of-value (find-object-of-value ?current-value $?new-condition))
	   else
	   	;(bind ?search-value (find-depend-var ?current-value $?init-concl))
	   	(bind ?object-of-value (find-object-of-value (find-depend-var ?current-value $?init-concl) $?new-condition))
	)
	;(bind $?all-condition-slots (collect-condition-slots $?new-condition))
	(bind $?not-nil-slot-tests (not-nil-slots (collect-condition-slots $?new-condition)))
	(bind $?check-old-att	
		(create$
			;"?aggr-fun-ind" <- 
				"(" object "(" name "?aggr-fun-ind" ")" "(" is-a ?aggregate-fun ")" "(" class ?class ")" "(" attribute ?att ")" "(" instance ?derived-object ")" "(" values "$?old"  ")" "(" objects "$?old-list"  ")" ")"
		)
	)
	(bind $?var-class-pairs (collect-var-class-pairs $?check-old-att))
	;(bind $?slot-predicates (collect-slot-predicates $?check-old-att))
	(bind $?encaps-slots (create$ "(" instance ?derived-object ")" (inverse-brackets (reverse$ $?var-class-pairs))))
	(bind $?encaps-preds 
		(create$ 
			$?init-concl 
			"(" or 
				"(" neq "(" member$ ?object-of-value "$?old-list" ")" 
					"(" member$ ?current-value "$?old" ")" 
				")"
				"(" eq	"(" member$ ?object-of-value "$?old-list" ")" 
					"(" member$ ?current-value "$?old" ")" 
					FALSE
				")"
			")"
			(collect-slot-predicates $?check-old-att)
		)
	)
	(while (> (length$ $?encaps-slots) 0)
	   do
	   	(bind ?p2 (get-token $?encaps-slots))
		;(bind $?first-slot (subseq$ $?encaps-slots 1 ?p2))
		;(bind ?c-value (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)))
		(bind $?encaps-preds (collapse-vars (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)) $?encaps-preds))
		(bind $?encaps-slots (subseq$ $?encaps-slots (+ ?p2 1) (length$ $?encaps-slots)))
	)
;	(bind $?copy-var-class-pairs $?var-class-pairs)
;	(while (> (length$ $?copy-var-class-pairs) 0)
;	   do
;	   	(bind ?p2 (get-token $?copy-var-class-pairs))
		;(bind $?first-pair (subseq$ $?copy-var-class-pairs 1 ?p2))
;		(bind ?one-class-var (nth$ 2 (subseq$ $?copy-var-class-pairs 1 ?p2)))
;		(bind $?encaps-preds (replace-member$ $?encaps-preds (create$ "(" instance-address ?one-class-var ")") ?one-class-var))
;		(bind $?copy-var-class-pairs (subseq$ $?copy-var-class-pairs (+ ?p2 1) (length$ $?copy-var-class-pairs)))
;	)
	(bind ?production-rule (str-cat$ (create$ 
		"(" defrule ?pos-rule-name 
			"(" declare "(" salience "(" + 1000 $?salience ")" ")" ")"   ; NEEDS STRATIFICATION
			"(" run-deductive-rules ")"
			$?new-condition
			(if (> (token-length $?not-nil-slot-tests) 0)
			   then
			   	(create$ 
					"(" test 
						(if (= (token-length $?not-nil-slot-tests) 1)
						   then
						   	(create$ $?not-nil-slot-tests)
						   else
							(create$ "(" and $?not-nil-slot-tests ")" )
						)
					")"
				)
			   else
			   	""
			)
;			"(" or
;				$?actual-concl
;				"(" test "(" not
;					"(" any-instancep
;						"(" "(" "?AF" ?aggregate-fun ")" ")" 
;						"(" and 
;							"(" eq "?AF:class" ?class ")" 
;							"(" eq "?AF:instance" ?derived-object ")" 
;							"(" eq "?AF:attribute" ?att ")" 
;						")" 
;					")" 
;				")" ")"
;			")"
			"(" test 
				"(" or
					"(" not
						"(" any-instancep
							"(" "(" "?AF" ?aggregate-fun ")" ")" 
							"(" and 
								"(" eq "?AF:class" ?class ")" 
								"(" eq "?AF:instance" ?derived-object ")" 
								"(" eq "?AF:attribute" ?att ")" 
							")" 
						")" 
					")"
					"(" any-instancep 
						"(" $?var-class-pairs ")" 
						(if (= (token-length $?encaps-preds) 1)
						   then
						   	(create$ $?encaps-preds)
						   else
						   	(create$ "(" and $?encaps-preds ")")
						)
					")"
				")"
			")"
			"(" test "(" instance-existp ?derived-object ")" ")"
		  => 
			$?init-concl 
			"(" bind "$?aggr-fun-ind1" 
				"(" find-instance 
					"(" "(" "?AF" ?aggregate-fun ")" ")" 
					"(" and 
						"(" eq "?AF:class" ?class ")" 
						"(" eq "?AF:instance" ?derived-object ")" 
						"(" eq "?AF:attribute" ?att ")" 
					")" 
				")" 
			")"
			"(" if "(" = "(" length$ "$?aggr-fun-ind1" ")" 0 ")"
			   then
			   	"(" bind "?aggr-fun-ind" 
			   		;"(" instance-address 
			   			"(" make-instance of ?aggregate-fun 
			   				"(" class ?class ")" 
			   				"(" instance ?derived-object ")" 
			   				"(" attribute ?att ")" 
			   			")" 
			   		;")" 
			   	")"
			   else
			   	"(" bind "?aggr-fun-ind" "(" nth$ 1 "$?aggr-fun-ind1" ")" ")"
			")"
			;"(" bind "$?old" "(" send "?aggr-fun-ind" get-values ")" ")"
			;"(" bind "$?old-list" "(" send "?aggr-fun-ind" get-objects ")" ")"
			"(" bind "$?new" "(" create$ "(" send "?aggr-fun-ind" get-values ")" ?current-value ")" ")"
			;"(" bind "$?new-list" "(" create$ "(" send "?aggr-fun-ind" get-objects ")" ?object-of-value ")" ")"
			;"(" bind "$?result" "(" send "?aggr-fun-ind" calc-result "$?new" ")" ")"
			"(" message-modify-instance ?derived-object "(" ?att "(" send "?aggr-fun-ind" calc-result "$?new" ")" ")" ")"
			"(" message-modify-instance "?aggr-fun-ind" "(" values "$?new" ")" "(" objects "(" create$ "(" send "?aggr-fun-ind" get-objects ")" ?object-of-value ")" ")" ")"
		")"
	)))
	(bind $?var-class-pairs (collect-var-class-pairs $?new-condition))
	;(bind $?slot-predicates (collect-slot-predicates $?new-condition))
	(bind $?encaps-slots (create$ "(" ?att ?current-value ")" (inverse-brackets (reverse$ $?var-class-pairs))))
	(bind $?encaps-preds (create$ $?not-nil-slot-tests $?init-concl (collect-slot-predicates $?new-condition)))
	(while (> (length$ $?encaps-slots) 0)
	   do
	   	(bind ?p2 (get-token $?encaps-slots))
		;(bind $?first-slot (subseq$ $?encaps-slots 1 ?p2))
		;(bind ?c-value (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)))
		(bind $?encaps-preds (collapse-vars (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)) $?encaps-preds))
		(bind $?encaps-slots (subseq$ $?encaps-slots (+ ?p2 1) (length$ $?encaps-slots)))
	)
	(bind $?encaps-preds (remove-aggregate-slot ?att $?encaps-preds))
;	(bind $?copy-var-class-pairs $?var-class-pairs)
;	(while (> (length$ $?copy-var-class-pairs) 0)
;	   do
;	   	(bind ?p2 (get-token $?copy-var-class-pairs))
		;(bind $?first-pair (subseq$ $?copy-var-class-pairs 1 ?p2))
;		(bind ?one-class-var (nth$ 2 (subseq$ $?copy-var-class-pairs 1 ?p2)))
;		(bind $?encaps-preds (replace-member$ $?encaps-preds (create$ "(" instance-address ?one-class-var ")") ?one-class-var))
;		(bind $?copy-var-class-pairs (subseq$ $?copy-var-class-pairs (+ ?p2 1) (length$ $?copy-var-class-pairs)))
;	)
	(bind ?c-value-var-list1 (sym-cat "$?" (gensym)))
	(bind ?o-value-var-list1 (sym-cat "$?" (gensym)))
	(bind ?c-value-var-list2 (sym-cat "$?" (gensym)))
	(bind ?o-value-var-list2 (sym-cat "$?" (gensym)))
	(bind $?delete-new-condition (exclude-slots ?derived-object (create$ "(" ?att ")" $$$ $?new-condition)))
	(bind ?delete-production-rule (str-cat$ (create$ 
		"(" defrule ?del-rule-name 
			"(" declare "(" salience "(" + 500 $?salience ")" ")" ")"   ; NEEDS STRATIFICATION
			"(" run-deductive-rules ")"
			;"(" test "(" eq "(" get-truth-maintenance ")" on ")" ")"
			;"?aggr-fun-ind" <- 
				"(" object 
					"(" name "?aggr-fun-ind" ")"
					"(" is-a ?aggregate-fun ")" 
					"(" class ?class ")" "(" attribute ?att ")" "(" instance ?derived-object ")" 
					"(" values ?c-value-var-list1 ?current-value ?c-value-var-list2  ")" 
					"(" objects ?o-value-var-list1 "&:(" eq "(" length$ ?c-value-var-list1 ")" "(" length$ ?o-value-var-list1 ")" ")" ?object-of-value ?o-value-var-list2  ")" ")"
;			"(" not 
;				(if (= (token-length $?delete-new-condition) 1)
;				   then
;					$?delete-new-condition 
;				   else
;				   	(create$ "(" and $?delete-new-condition ")")
;				)
;			")"
			"(" not 
				"(" test 
					"(" any-instancep 
						"(" $?var-class-pairs ")" 
						(if (= (token-length $?encaps-preds) 1)
						   then
						   	(create$ $?encaps-preds)
						   else
						   	(create$ "(" and $?encaps-preds ")")
						)
					")"
				")"
			")"
		  => 
			"(" bind "$?new" "(" create$ ?c-value-var-list1 ?c-value-var-list2 ")" ")"
			;"(" bind "$?new-list" "(" create$ ?o-value-var-list1 ?o-value-var-list2 ")" ")"
			;"(" bind "$?result" "(" send "?aggr-fun-ind" calc-result "$?new" ")" ")"
			"(" message-modify-instance ?derived-object "(" ?att "(" send "?aggr-fun-ind" calc-result "$?new" ")" ")" ")"
			"(" message-modify-instance "?aggr-fun-ind" "(" values "$?new" ")" "(" objects "(" create$ ?o-value-var-list1 ?o-value-var-list2 ")" ")" ")"
		")"
	)))
	(make-instance  ?rule-name of aggregate-attribute-rule
		(aggregate-attribute-rule ?aggregate-attribute-rule)
		(pos-name ?pos-rule-name) 
		(del-name ?del-rule-name) 
		(implies ?implies-class)
		(depends-on $?depends-classes)
		;(production-rule ?production-rule) 
		;(delete-production-rule ?delete-production-rule)
	)
	;(printout t "aggregate rule --> " ?production-rule crlf)
	(my-build ?production-rule)
	(save-compiled-rule ?production-rule)
	(my-build ?delete-production-rule)
	(save-compiled-rule ?delete-production-rule)
)

(deffunction translate-ntm-aggregate-attribute-rule (?aggregate-attribute-rule ?rule-name $?d-classes)
	(debug "Aggregate attribute rule: " ?rule-name " " ?aggregate-attribute-rule crlf)
	(bind $?aar (my-explode$ ?aggregate-attribute-rule))
	(bind ?imp_pos (member$ => $?aar))
	(bind $?condition (subseq$ $?aar 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?aar (+ ?imp_pos 1) (length$ $?aar)))
	(bind $?salience (discover-salience $?condition))
	(bind $?condition (remove-salience $?condition))
	(bind $?new-condition (translate-condition $?condition))
	(bind ?implies-class (nth$ 1 $?d-classes))
	(bind $?depends-classes (rest$ $?d-classes))
	;(bind ?p1 (member "(" $?conclusion))
	(bind ?p2 (get-token $?conclusion))
	;(bind $?first-concl-elem (subseq$ $?conclusion (member "(" $?conclusion) ?p2))
	(if (eq (nth$ 2 (subseq$ $?conclusion (member "(" $?conclusion) ?p2)) calc)
	   then
	   	(bind $?init-concl (subseq$ $?conclusion 3 (- ?p2 1)))
		(bind $?rest-concl (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
		(bind $?actual-concl (translate-condition (integrate-calc $?conclusion)))
	   else
	   	(bind $?init-concl (create$))
		(bind $?rest-concl $?conclusion )
		(bind $?actual-concl (translate-condition $?rest-concl))
	)
	(bind ?pos-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind ?del-rule-name (sym-cat ?rule-name - (gensym*)))
	(bind ?derived-object (nth$ 1 $?rest-concl))
	(bind ?class (nth$ 4 $?rest-concl))
	(bind ?att (nth$ 6 $?rest-concl))
	(bind ?aggregate-fun (nth$ 8 $?rest-concl))
	(bind $?current-value (subseq$ $?rest-concl 9 (- (member$ ")" $?rest-concl) 1)))  ; multi-values for aggregates
	(bind ?current-value (nth$ 9 $?rest-concl))
	(if (member$ ?current-value $?new-condition)
	   then
		(bind ?object-of-value (find-object-of-value ?current-value $?new-condition))
	   else
	   	;(bind ?search-value (find-depend-var ?current-value $?init-concl))
	   	(bind ?object-of-value (find-object-of-value (find-depend-var ?current-value $?init-concl) $?new-condition))
	)
	;(bind $?all-condition-slots (collect-condition-slots $?new-condition))
	(bind $?not-nil-slot-tests (not-nil-slots (collect-condition-slots $?new-condition)))
	(bind $?check-old-att	
		(create$
			;"?aggr-fun-ind" <- 
				"(" object "(" name "?aggr-fun-ind" ")" "(" is-a ?aggregate-fun ")" "(" class ?class ")" "(" attribute ?att ")" "(" instance ?derived-object ")" "(" values "$?old"  ")" "(" objects "$?old-list"  ")" ")"
		)
	)
	(bind $?var-class-pairs (collect-var-class-pairs $?check-old-att))
	;(bind $?slot-predicates (collect-slot-predicates $?check-old-att))
	(bind $?encaps-slots (create$ "(" instance ?derived-object ")" (inverse-brackets (reverse$ $?var-class-pairs))))
	(bind $?encaps-preds 
		(create$ 
			$?init-concl 
			"(" or 
				"(" neq "(" member$ ?object-of-value "$?old-list" ")" 
					"(" member$ ?current-value "$?old" ")" 
				")"
				"(" eq	"(" member$ ?object-of-value "$?old-list" ")" 
					"(" member$ ?current-value "$?old" ")" 
					FALSE
				")"
			")"
			(collect-slot-predicates $?check-old-att)
		)
	)
	(while (> (length$ $?encaps-slots) 0)
	   do
	   	(bind ?p2 (get-token $?encaps-slots))
		;(bind $?first-slot (subseq$ $?encaps-slots 1 ?p2))
		;(bind ?c-value (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)))
		(bind $?encaps-preds (collapse-vars (nth$ 3 (subseq$ $?encaps-slots 1 ?p2)) $?encaps-preds))
		(bind $?encaps-slots (subseq$ $?encaps-slots (+ ?p2 1) (length$ $?encaps-slots)))
	)
	(bind ?production-rule (str-cat$ (create$ 
		"(" defrule ?pos-rule-name 
			"(" declare "(" salience "(" + 1000 $?salience ")" ")" ")"   ; NEEDS STRATIFICATION
			"(" run-deductive-rules ")"
			$?new-condition
			(if (> (token-length $?not-nil-slot-tests) 0)
			   then
			   	(create$ 
					"(" test 
						(if (= (token-length $?not-nil-slot-tests) 1)
						   then
						   	(create$ $?not-nil-slot-tests)
						   else
							(create$ "(" and $?not-nil-slot-tests ")" )
						)
					")"
				)
			   else
			   	""
			)
;			"(" or
;				$?actual-concl
;				"(" test "(" not
;					"(" any-instancep
;						"(" "(" "?AF" ?aggregate-fun ")" ")" 
;						"(" and 
;							"(" eq "?AF:class" ?class ")" 
;							"(" eq "?AF:instance" ?derived-object ")" 
;							"(" eq "?AF:attribute" ?att ")" 
;						")" 
;					")" 
;				")" ")"
;			")"
			"(" test 
				"(" or
					"(" not
						"(" any-instancep
							"(" "(" "?AF" ?aggregate-fun ")" ")" 
							"(" and 
								"(" eq "?AF:class" ?class ")" 
								"(" eq "?AF:instance" ?derived-object ")" 
								"(" eq "?AF:attribute" ?att ")" 
							")" 
						")" 
					")"
					"(" any-instancep 
						"(" $?var-class-pairs ")" 
						(if (= (token-length $?encaps-preds) 1)
						   then
						   	(create$ $?encaps-preds)
						   else
						   	(create$ "(" and $?encaps-preds ")")
						)
					")"
				")"
			")"
			"(" test "(" instance-existp ?derived-object ")" ")"
		  => 
			$?init-concl 
			"(" bind "$?aggr-fun-ind1" 
				"(" find-instance 
					"(" "(" "?AF" ?aggregate-fun ")" ")" 
					"(" and 
						"(" eq "?AF:class" ?class ")" 
						"(" eq "?AF:instance" ?derived-object ")" 
						"(" eq "?AF:attribute" ?att ")" 
					")" 
				")" 
			")"
			"(" if "(" = "(" length$ "$?aggr-fun-ind1" ")" 0 ")"
			   then
			   	"(" bind "?aggr-fun-ind" 
			   		;"(" instance-address 
			   			"(" make-instance of ?aggregate-fun 
			   				"(" class ?class ")" 
			   				"(" instance ?derived-object ")" 
			   				"(" attribute ?att ")" 
			   			")" 
			   		;")" 
			   	")"
			   else
			   	"(" bind "?aggr-fun-ind" "(" nth$ 1 "$?aggr-fun-ind1" ")" ")"
			")"
			;"(" bind "$?old" "(" send "?aggr-fun-ind" get-values ")" ")"
			;"(" bind "$?old-list" "(" send "?aggr-fun-ind" get-objects ")" ")"
			"(" bind "$?new" "(" create$ "(" send "?aggr-fun-ind" get-values ")" ?current-value ")" ")"
			;"(" bind "$?new-list" "(" create$ "(" send "?aggr-fun-ind" get-objects ")" ?object-of-value ")" ")"
			;"(" bind "$?result" "(" send "?aggr-fun-ind" calc-result "$?new" ")" ")"
			"(" message-modify-instance ?derived-object "(" ?att "(" send "?aggr-fun-ind" calc-result "$?new" ")" ")" ")"
			"(" message-modify-instance "?aggr-fun-ind" "(" values "$?new" ")" "(" objects "(" create$ "(" send "?aggr-fun-ind" get-objects ")" ?object-of-value ")" ")" ")"
		")"
	)))
	(make-instance  ?rule-name of aggregate-attribute-rule
		(aggregate-attribute-rule ?aggregate-attribute-rule)
		(pos-name ?pos-rule-name) 
		(del-name nil) 
		(implies ?implies-class)
		(depends-on $?depends-classes)
		;(production-rule ?production-rule) 
		;(delete-production-rule ?delete-production-rule)
	)
	;(printout t "aggregate rule --> " ?production-rule crlf)
	(my-build ?production-rule)
	(save-compiled-rule ?production-rule)
)

(deffunction collect-class-names ($?condition)
	(bind $?result (create$))
	(while (> (length$ $?condition) 0)
	   do
		(bind ?p2 (get-token $?condition))
		(bind $?cond-elem (subseq$ $?condition 1 ?p2))
		(bind $?condition (subseq$ $?condition (+ ?p2 1) (length$ $?condition)))
   		(if (or 
   			(eq (nth$ 2 $?cond-elem) not)
   			(eq (nth$ 2 $?cond-elem) or)
   			(eq (nth$ 2 $?cond-elem) and))
   		   then
   		   	(bind $?result (create$ $?result (collect-class-names (subseq$ $?cond-elem 3 (- (length$ $?cond-elem) 1)))))
   		   else
   		   	(if (eq (nth$ 2 $?cond-elem) <-)
   		   	   then
   		   	   	(bind ?class (nth$ 4 $?cond-elem))
   		   	   else
   		   	   	(bind ?class (nth$ 2 $?cond-elem))
   		   	)
   		   	(if (neq ?class test)
   		   	   then
   		   		(bind $?result (create$ $?result ?class))
   		   	)
   		)
   	)
   	$?result
)
		

(deffunction build-dependency-network (?deductive-rule)
	(bind $?dr (my-explode$ ?deductive-rule))
	(bind ?imp_pos (member$ => $?dr))
	(bind $?condition (subseq$ $?dr 1 (- ?imp_pos 1)))
	(bind $?conclusion (subseq$ $?dr (+ ?imp_pos 1) (length$ $?dr)))
	;(bind $?depends-on-classes (collect-class-names (subseq$ $?dr 1 (- ?imp_pos 1))))
	(if (eq (nth$ 2 $?conclusion) calc)
	   then
		(bind ?p2 (get-token $?conclusion))
		(bind $?conclusion (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion)))
	)
	(if (eq (nth$ 2 $?conclusion) <-)
	   then
	   	(bind $?conclusion (subseq$ $?conclusion 3 (length$ $?conclusion)))
	)
	(bind ?p2 (get-token $?conclusion))
	(if (eq (nth$ 2 (subseq$ $?conclusion (member "(" $?conclusion) ?p2)) calc)
	   then
		(bind ?implies-class (nth$ 2 (subseq$ $?conclusion (+ ?p2 1) (length$ $?conclusion))))
	   else
		(bind ?implies-class (nth$ 2 $?conclusion))
	)
	(create$ ?implies-class (collect-class-names $?condition))
	;(modify ?idx (depends-on $?depends-on-classes) (implies ?implies-class))
)
	
(deffunction insert-pending-rule (?rule ?del-rule $?classes)
	(if (= (length$ (exist-classes $?classes)) 0)
	   then
	   	(my-build ?rule)
	   	(save-compiled-rule ?rule)
	   	(if (neq ?del-rule "")
	   	   then
	   		(my-build ?del-rule)
	   		(save-compiled-rule ?del-rule)
	   	)
	   else
	 	(printout t "Rule: " crlf ?rule crlf "cannot be created because classes " (exist-classes $?classes) " do not exist!" crlf) 
	)
)


(deffunction pre-compile-deductive-rule (?rule-string1)
   	(bind ?rule-string (replace-anonymous-variables ?rule-string1))
  	(bind $?rule-name-and-string (find-rule-name ?rule-string))
  	(bind ?rule-name (nth$ 1 $?rule-name-and-string))
  	(bind ?rule-string2 (nth$ 2 $?rule-name-and-string))
	(bind $?results-2nd-order (analyze-2nd-order ?rule-string2))
	(if (neq $?results-2nd-order FALSE)
	   then
	   	(debug "2nd order rule: " ?rule-string " auxiliary data: " $?results-2nd-order crlf)
	   	(assert (2nd-order-rule ?rule-name ?rule-string2 $?results-2nd-order))
   		(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))
		;(translate-2nd-order-rule ?rule $?results-2nd-order)
		;(printout t "ok!" crlf)
	)
	(if (or
		(eq $?results-2nd-order FALSE)
		(eq (nth$ 1 $?results-2nd-order) aliased-slot))
	   then
	   	(debug "deductive rule: " ?rule-string crlf)
		(bind $?dependencies (build-dependency-network ?rule-string2))
		(make-instance  ?rule-name of deductive-rule
			(deductive-rule ?rule-string2)
			(implies (nth$ 1 $?dependencies))
			(depends-on (rest$ $?dependencies))
		)
	)
)

(deffunction pre-compile-ntm-deductive-rule (?rule-string1)
	;(printout t "pre-compile-deductive-rule: ?rule-string1: " ?rule-string1 crlf)
   	(bind ?rule-string (replace-anonymous-variables ?rule-string1))
  	(bind $?rule-name-and-string (find-rule-name ?rule-string))
  	(bind ?rule-name (nth$ 1 $?rule-name-and-string))
  	(bind ?rule-string2 (nth$ 2 $?rule-name-and-string))
	(bind $?results-2nd-order (analyze-2nd-order ?rule-string2))
	;(printout t "pre-compile-deductive-rule: $?results-2nd-order:" $?results-2nd-order crlf)
	(if (neq $?results-2nd-order FALSE)
	   then
	   	(debug "2nd order rule: " ?rule-string " auxiliary data: " $?results-2nd-order crlf)
	   	;(printout t "2nd order rule: " ?rule-string " auxiliary data: " $?results-2nd-order crlf)
	   	(assert (2nd-order-ntm-rule ?rule-name ?rule-string2 $?results-2nd-order))
   		(bind ?*untranslated_rules* (+ ?*untranslated_rules* 1))   		
		;(translate-2nd-order-rule ?rule $?results-2nd-order)
		;(printout t "ok!" crlf)
	)
	(if (or
		(eq $?results-2nd-order FALSE)
		(eq (nth$ 1 $?results-2nd-order) aliased-slot))
	   then
	   	(debug "ntm deductive rule: " ?rule-string crlf)
		(bind $?dependencies (build-dependency-network ?rule-string2))
		(make-instance  ?rule-name of ntm-deductive-rule
			(deductive-rule ?rule-string2)
			(implies (nth$ 1 $?dependencies))
			(depends-on (rest$ $?dependencies))
		)
	)
)

(deffunction translate-device-rules ()
	(while (> ?*untranslated_rules* 0)
	   do
		(run-goal pre-compile-deductive-rules)
		(run-goal translate-deductive-rules)
		(run-goal translate-2nd-order-rules)
		(run-goal translate-derived-attribute-rules)
		(run-goal translate-aggregate-attribute-rules)
	)
	(run-goal insert-pending-rules)
	(run-goal calc-stratum-for-all)
	TRUE
)
