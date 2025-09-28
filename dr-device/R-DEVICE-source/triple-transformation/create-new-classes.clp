(defrule create-non-existing-classes_create-candidate-class
;	(goal create-new-classes)
  =>
  	(do-for-all-instances 
  		((?res rdfs:Class))
  		(and
  			(not (class-existp (instance-name-to-symbol ?res)))
  			;(not-rdf-resource (instance-name (nth$ 1 ?res:rdfs:isDefinedBy)))
  			(not (is-rdf-resource ?res))
  			(= (length$ (exist-classes (instances-to-symbols ?res:rdfs:subClassOf))) 0) ; All super-classes exist
  		)
		(assert 
			(candidate-class 
				(name (instance-name-to-symbol ?res)) 
				(isa-slot (instances-to-symbols ?res:rdfs:subClassOf))
				(class-refs-defaults (collect-defaults class-refs (get-super-classes (instances-to-symbols ?res:rdfs:subClassOf))))
				(aliases-defaults (collect-defaults aliases (get-super-classes (instances-to-symbols ?res:rdfs:subClassOf))))
			)
		)
	)
	(bind ?*cycle-change-flag* true)
)



; New
(defrule create-non-existing-classes_create-slots-type-Datatype
;	(goal create-new-classes)
	?x <- (candidate-class 
		(name ?new-class) 
		(isa-slot $?super-classes) 
		(slot-definitions $?slot-defs) 
		(aliases-defaults $?aliases))
	?y <- (object 
		(is-a rdf:Property) 
		(name ?new-slot) 
		(rdfs:domain $?domains) 
		(rdfs:range ?range&:(is-datatype ?range)) 
		(rdfs:subPropertyOf $?super-properties))
;	(object (is-a rdfs:Datatype) (name ?range) (rdfs:subClassOf [rdfs:Literal]))
	;(test (= (length$ (exist-classes $?domains)) 0))
	(test (aux-resource7 ?new-class $?domains))
;	(test (is-only-one-class (instances-to-symbols $?domains)))
;	(test (eq ?new-class (get-only-one-class (instances-to-symbols $?domains))))
	(not (test (member$ (instance-name-to-symbol ?new-slot) $?slot-defs)))
 => 
 	;(printout t "======= " "?new-class: " ?new-class crlf)
 	;(printout t "======= " "?new-slot: " ?new-slot crlf)
 	;(printout t "======= " "$?domains: " $?domains crlf)
	(modify ?x 
		(slot-definitions (create$ "(" multislot (instance-name-to-symbol ?new-slot) "(" type (find-correct-datatype (instance-name-to-symbol ?range)) ")" ")" $?slot-defs)) 
		(aliases-defaults (create$ (create-aliases (instance-name-to-symbol ?new-slot) (instances-to-symbols $?super-properties)) $?aliases))
	)
	(bind ?*cycle-change-flag* true)
)

(defrule create-non-existing-classes_create-slots-type-Resource
;	(goal create-new-classes)
	?x <- (candidate-class 
		(name ?new-class) 
		(isa-slot $?super-classes) 
		(slot-definitions $?slot-defs) 
		(class-refs-defaults $?class-refs) 
		(aliases-defaults $?aliases))
	?y <- (object 
		(is-a rdf:Property) 
		(name ?new-slot) 
		(rdfs:domain $?domains) 
		;(rdfs:range ?type&:(instance-existp ?type)&:(neq ?type [rdfs:Literal])) 
		(rdfs:range $?ranges&:(not-datatype $?ranges))
		(rdfs:subPropertyOf $?super-properties))
	;(test (= (length$ (exist-classes $?domains)) 0))
	(test (all-instance-existp $?domains))
	(test (aux-resource7 ?new-class $?domains))
;	(test (is-only-one-class (instances-to-symbols $?domains)))
;	(test (eq ?new-class (get-only-one-class (instances-to-symbols $?domains))))
	;(test (= (length$ (exist-classes (instances-to-symbols $?ranges))) 0))
	(test (all-instance-existp $?ranges))
	(test (is-only-one-class (instances-to-symbols $?ranges)))
;	(test (neq rdfs:Literal (get-only-one-class (instances-to-symbols $?ranges))))
	(not (test (member$ (instance-name-to-symbol ?new-slot) $?slot-defs)))
  =>
	(modify ?x 
		(slot-definitions (create$ "(" multislot (instance-name-to-symbol ?new-slot) "(" type INSTANCE-NAME ")" ")" $?slot-defs))
		(class-refs-defaults (create$ (instance-name-to-symbol ?new-slot) (get-only-one-class (instances-to-symbols $?ranges)) $?class-refs))
		(aliases-defaults (create$ (create-aliases (instance-name-to-symbol ?new-slot) (instances-to-symbols $?super-properties)) $?aliases))
	)
	(bind ?*cycle-change-flag* true)
)

(defrule create-non-existing-classes_create-slots-type-no-range
;	(goal create-new-classes)
	?x <- (candidate-class (name ?new-class) (isa-slot $?super-classes) (slot-definitions $?slot-defs) (aliases-defaults $?aliases))
	?y <- (object (is-a rdf:Property) (name ?new-slot) (rdfs:domain $?domains) (rdfs:range $?list&:(= (length$ $?list) 0)) (rdfs:subPropertyOf $?super-properties))
;	?y <- (triple (subject ?new-slot) (predicate rdfs:domain) (object ?new-class))
;	(not (triple (subject ?new-slot) (predicate rdfs:range)))
	;(test (= (length$ (exist-classes $?domains)) 0))
	(test (aux-resource7 ?new-class $?domains))
;	(test (is-only-one-class (instances-to-symbols $?domains)))
;	(test (eq ?new-class (get-only-one-class (instances-to-symbols $?domains))))
	(not (test (member$ (instance-name-to-symbol ?new-slot) $?slot-defs)))
  =>
	(modify ?x 
		(slot-definitions (create$ "(" multislot (instance-name-to-symbol ?new-slot) ")" $?slot-defs))
		(aliases-defaults (create$ (create-aliases (instance-name-to-symbol ?new-slot) (instances-to-symbols $?super-properties)) $?aliases))
	)
	(bind ?*cycle-change-flag* true)
)
