
(defrule change-type-of-existing-instances
;	(declare (salience 100))
;	(goal create-instances)
;	?x <- (triple 	(subject ?res&:(and (instance-existp ?res)
;						(neq (class ?res) candidate-object))) 
	?x <- (triple 	(subject ?res&:(instance-existp ?res))
			(predicate [rdf:type]) 
			;(object ?class&:(and (neq (class ?res) (instance-name-to-symbol ?class)) 
			;			(class-existp (instance-name-to-symbol ?class))))
			(object ?class&:(class-existp (instance-name-to-symbol ?class)))
		)
;	?x <- (triple (subject ?res) (predicate [rdf:type]) (object ?class))
	;(test (test-counter))
	;(test (class-existp (instance-name-to-symbol ?class)))
  =>
  	(retract ?x)
	(bind ?*triple_counter* (- ?*triple_counter* 1))
; TEMP	(delete_useful_info ?res 2 5)
	(bind ?class (instance-name-to-symbol ?class))
	(bind ?current-class (class ?res))
	(if (foreign-classes ?class ?current-class)
	   then
		(bind ?new-class (exists-class-with-super-classes (create$ ?class ?current-class)))
		(if (eq ?new-class FALSE)
		   then
			(bind ?new-class (gensym*))
			(resource-make-instance rdfs:Class ?new-class (create$ ?new-class))
			(modify-instance (symbol-to-instance-name ?new-class) 
				(source system)
				(class-refs (unique-pairs (collect-defaults class-refs (create$ ?class ?current-class))))
				(aliases (unique-pairs (collect-defaults aliases (create$ ?class ?current-class))))
			)
			(my-build (str-cat$ 
				"(" defclass ?new-class
					"(" is-a (create$ ?class ?current-class) ")"
					;"(" multislot class-refs 
					;	"(" source composite ")"
					;	"(" default (unique-pairs (collect-defaults class-refs (create$ ?class ?current-class))) ")"
					;")"
					;"(" multislot aliases 
					;	"(" source composite ")"
					;	"(" default (unique-pairs (collect-defaults aliases (create$ ?class ?current-class))) ")"
					;")"
				")"
			))
		)
		(bind ?new-instance (make-instance of ?new-class))
		(shallow-copy ?res ?new-instance)
		(send ?new-instance put-rdf:type (create$ ?class ?current-class))
		(duplicate-instance ?new-instance to ?res)
		(send ?new-instance delete)
	)
)

(defrule create-candidate-instance
;	(declare (salience 100))
;	(goal create-instances)
	?x <- (triple 	(subject ?res&:(not (instance-existp ?res))) 
			(predicate [rdf:type]) 
			;(object ?class&:(class-existp (instance-name-to-symbol ?class)))
			(object ?class))
;	?x <- (triple (subject ?res) (predicate [rdf:type]) (object ?class))
	;(test (test-counter))
	;(test (class-existp (instance-name-to-symbol ?class)))
  =>
	;(bind ?class (instance-name-to-symbol ?class))
   	;(make-instance ?res of candidate-object (classes (instance-name-to-symbol ?class)))
   	(retract ?x)
  	(assert (candidate-object (name ?res) (classes ?class)))
	(bind ?*triple_counter* (- ?*triple_counter* 1))
; TEMP	(delete_useful_info ?res 2 5)
)

(defrule create-candidate-instance-cont
	(declare (salience 100))
;	(goal create-instances)
	?y <- (candidate-object (name ?res) (classes $?classes))
;	?x <- (triple 	(subject ?res&:(and (instance-existp ?res) 
;						(eq (class ?res) candidate-object))) 
	?x <- (triple 	(subject ?res)
			(predicate [rdf:type]) 
			;(object ?class&:(class-existp (instance-name-to-symbol ?class)))
			(object ?class))
;	?x <- (triple (subject ?res) (predicate [rdf:type]) (object ?class))
	;(test (test-counter))
	;(test (class-existp (instance-name-to-symbol ?class)))
  =>
	;(bind ?class (instance-name-to-symbol ?class))
	(retract ?x)
	(modify ?y (classes (create$ ?class $?classes)))
   	;(slot-insert$ ?res classes 1 (instance-name-to-symbol ?class))
	(bind ?*triple_counter* (- ?*triple_counter* 1))
; TEMP	(delete_useful_info ?res 2 5)
)

;;; New - 25-03-2005
;;; Collect slot-value pairs inside the candidate-object
;;; so that make-instance will include them
;;; This rule is for object properties
(defrule create-candidate-instance-cont2
	(declare (salience 50))
	?y <- (candidate-object (name ?res) (classes $?classes&:(classes-existp $?classes)) (slot-values $?old-slot-values))
	?x <- (triple 	(subject ?res)
			(predicate ?p&~[rdf:type]&:(and	(multi-slot-existp (instance-name-to-symbol ?p) $?classes) (member$ INSTANCE-NAME (multi-slot-types (instance-name-to-symbol ?p) $?classes)))) 
			(object ?o))
  =>
	(retract ?x)
	(bind ?*triple_counter* (- ?*triple_counter* 1))
  	(bind ?p (instance-name-to-symbol ?p))
	(bind ?p-type (multi-get-type-of ?p $?classes))
	(if (and (instance-namep ?o) (instance-existp ?o))
  	   then
  		(bind ?o-class (class ?o))
		(if (not (compatible-types ?o-class ?p-type))
		   then
		 	(assert (triple (subject ?o) (predicate [rdf:type]) (object (symbol-to-instance-name ?p-type))))
		 	(bind ?*triple_counter* (+ ?*triple_counter* 1))
		)
	   else
	 	(if (assert (triple (subject ?o) (predicate [rdf:type]) (object (symbol-to-instance-name ?p-type))))
	 	   then
	 		(bind ?*triple_counter* (+ ?*triple_counter* 1))
	 	)
	)
	(bind ?pos (inv-pair-member $slot ?p $?old-slot-values))
	(if (neq ?pos FALSE)
	   then
	   	(bind $?new-slot-values (insert$ $?old-slot-values ?pos ?o))
	   else
	   	(bind $?new-slot-values (create$ $slot ?p ?o $?old-slot-values))
	)
	(modify ?y (slot-values $?new-slot-values))
)

;;; New - 25-03-2005
;;; Collect slot-value pairs inside the candidate-object
;;; so that make-instance will include them
;;; This rule is for datatype properties
(defrule create-candidate-instance-cont3
	(declare (salience 50))
	?y <- (candidate-object (name ?res) (classes $?classes&:(classes-existp $?classes)) (slot-values $?old-slot-values))
	?x <- (triple 	(subject ?res)
			(predicate ?p&~[rdf:type]&:(and	(multi-slot-existp (instance-name-to-symbol ?p) $?classes) (neq (create$ INSTANCE-NAME) (multi-slot-types (instance-name-to-symbol ?p) $?classes)))) 
			(object ?o&:(not (instance-namep ?o))) 
			(object-datatype ?obj-dt))
  =>
  	(retract ?x)
	(bind ?*triple_counter* (- ?*triple_counter* 1))
  	(bind ?p (instance-name-to-symbol ?p))
  	(bind $?datatypes (multi-slot-types ?p $?classes))
  	(bind ?new-o (transform-datatype ?o ?obj-dt $?datatypes))
	;(printout t "=========== " "?res: " ?res crlf)
	;(printout t "=========== " "?p: " ?p crlf)
	;(printout t "=========== " "?o: " ?o crlf)
	;(printout t "=========== " "?new-o: " ?new-o crlf)
  	(if (neq ?new-o FALSE)
  	   then
		(bind ?pos (inv-pair-member $slot ?p $?old-slot-values))
		(if (neq ?pos FALSE)
		   then
		   	(bind $?new-slot-values (insert$ $?old-slot-values ?pos ?o))
		   else
		   	(bind $?new-slot-values (create$ $slot ?p ?o $?old-slot-values))
		)
		;(printout t "=========== " "$?new-slot-values: " $?new-slot-values crlf crlf)
		(modify ?y (slot-values $?new-slot-values))
  	)
)


;;; Updated - 25-03-2005
;;; Takes into consideration slot-values
(defrule generate-instances-of-classes
;	(goal create-instances)
	?x <- (candidate-object (name ?res) (classes $?classes&:(classes-existp $?classes)) (slot-values $?slot-values))
	;(object (is-a candidate-object) (name ?res) (classes $?classes))
	;(object (is-a candidate-object) (name ?res) (classes $?classes&:(classes-existp $?classes)))
	;(not (triple (subject ?res) (predicate [rdf:type])))
	;(test (not (instance-existp ?res)))
  =>
  	;(do-for-all-instances ((?res candidate-object)) TRUE
  	(retract ?x)
	(bind $?classes (remove-superclasses (remove-duplicates$ $?classes)))
  	;(bind $?classes (remove-duplicates$ $?classes))
  	(if (> (length$ $?classes) 1)
  	;(if (> (length$ ?res:classes) 1)
  	   then
  		(bind $?classes (instances-to-symbols $?classes))
  		;(bind $?classes (instances-to-symbols ?res:classes))
		(bind ?class-name (exists-class-with-super-classes $?classes))
		(if (eq ?class-name FALSE)
		   then
			(bind ?class-name (gensym*))
			(resource-make-instance rdfs:Class ?class-name (create$ ?class-name))
			(modify-instance (symbol-to-instance-name ?class-name) 
				(source system)
				(class-refs (unique-pairs (collect-defaults class-refs $?classes)))
				(aliases (unique-pairs (collect-defaults aliases $?classes)))
			)
			(my-build (str-cat$ 
				"(" defclass ?class-name
					"(" is-a $?classes ")"
					;"(" multislot class-refs 
					;	"(" source composite ")"
					;	"(" default (unique-pairs (collect-defaults class-refs $?classes)) ")"
					;")"
					;"(" multislot aliases 
					;	"(" source composite ")"
					;	"(" default (unique-pairs (collect-defaults aliases $?classes)) ")"
					;")"
				")"
			))
		)  
		;(send ?res delete) ; new - may not needed
  	   else
  		(bind ?class-name (instance-name-to-symbol (nth$ 1 $?classes)))
  		;(bind ?class (instance-name-to-symbol (nth$ 1 ?res:classes)))
		;(send ?res delete) ; new - may not needed
  		;(resource-make-instance ?class ?res ?res:classes)
  	)
  	;(printout t "***************" "$?slot-values: " $?slot-values crlf)
  	;(printout t "***** HERE *** ?class-name = " ?class-name crlf)
  	;(printout t "***** HERE *** ?res = " ?res crlf)
  	;(printout t "***** HERE *** $?classes = " $?classes crlf)
  	;(printout t "***** HERE *** $?slot-values = " $?slot-values crlf)
  	(resource-make-instance ?class-name ?res $?classes $$$ $?slot-values)
  ;	)
  ; TEMP	(delete_useful_info ?res 2 5)
  (bind ?*cycle-change-flag* true)
)
