; May need optimization - calls instance-name-to-symbol 3 times!
(defrule add-extra-superclass
;	(goal put-new-properties)
	(object (is-a rdfs:Class) (name ?class) (rdfs:subClassOf $?superclasses))
	(not (class-to-undefine ?c&:(eq ?c (instance-name-to-symbol ?class))))
	(test (class-existp (instance-name-to-symbol ?class)))
	(test (> (length$ (difference$ (create$ (most-specific-classes (instances-to-symbols $?superclasses)) $$$ (class-superclasses (instance-name-to-symbol ?class))))) 0))
  =>
  	(debug  "Backing up class: " (instance-name-to-symbol ?class) crlf)
	(backup-class (instance-name-to-symbol ?class))
	(bind ?*cycle-change-flag* true)
)


(defrule put-new-properties-no-domain
;	(goal put-new-properties)
	(object (is-a rdf:Property) (name ?new-slot) (rdfs:domain $?list&:(= (length$ $?list) 0)))
	(not (class-to-undefine rdfs:Resource))
	(test (class-existp rdfs:Resource))
	(test (not (slot-existp rdfs:Resource (instance-name-to-symbol ?new-slot) inherit)))
  =>
  	(debug  "Backing up class: rdfs:Resource" crlf)
	(backup-class rdfs:Resource)
	(bind ?*cycle-change-flag* true)
)

; May need optimization - calls instances-to-symbols 4 times!
(defrule put-new-properties-with-one-domain
;	(goal put-new-properties)
;	(object (is-a rdf:Property) (name ?new-slot) (rdfs:domain ?class))
	(object (is-a rdf:Property) (name ?new-slot) (rdfs:domain $?domains))
	(test (= (length$ (exist-classes $?domains)) 0))
	(test (is-only-one-class (instances-to-symbols $?domains)))
	(not (class-to-undefine ?c&:(eq ?c (get-only-one-class (instances-to-symbols $?domains)))))
	(test (class-existp (get-only-one-class (instances-to-symbols $?domains))))
	(test (not (slot-existp (get-only-one-class (instances-to-symbols $?domains)) (instance-name-to-symbol ?new-slot) inherit)))
  =>
  	(debug  "Backing up class: " (get-only-one-class (instances-to-symbols $?domains)) crlf)
	(backup-class (get-only-one-class (instances-to-symbols $?domains)))
	(bind ?*cycle-change-flag* true)
)

(defrule insert-extra-superclass
;	(goal put-new-properties)
	?x <- (redefined-class (name ?class) (isa-slot $?existing-superclasses))
	(object (is-a rdfs:Class) (name ?c&:(eq ?c (symbol-to-instance-name ?class))) (rdfs:subClassOf $?new-superclasses))
	(test (> (length$ (difference$ (create$ (most-specific-classes (instances-to-symbols $?new-superclasses)) $$$ (instances-to-symbols $?existing-superclasses)))) 0))
  =>
  	(bind $?superclasses (most-specific-classes (union$ (create$ $?new-superclasses $$$ $?existing-superclasses))))
  	(debug  "New superclass(es): " (instances-to-symbols $?superclasses) " for class " ?class crlf)
	(bind ?new-factid (modify ?x (isa-slot $?superclasses)))
	(bind ?*redefined_class_facts* (create$ ?new-factid (delete-member$ ?*redefined_class_facts* ?x)))
	(bind ?*cycle-change-flag* true)
)


; New
(defrule insert-new-property-no-domain-Datatype
;	(goal put-new-properties)
	?x <- (redefined-class (name rdfs:Resource) (slot-definitions $?slot-defs) (aliases-defaults $?aliases))
	?y <- (object (is-a rdf:Property) (name ?new-slot) (rdfs:domain $?list&:(= (length$ $?list) 0)) (rdfs:range ?range&:(is-datatype ?range)) (rdfs:subPropertyOf $?super-properties))
;	(object (is-a rdfs:Datatype) (name ?range) (rdfs:subClassOf [rdfs:Literal]))
	(not (test (member$ (instance-name-to-symbol ?new-slot) $?slot-defs)))
  =>
  	(debug  "New property: " (instance-name-to-symbol ?new-slot) " for rdfs:Resource." crlf)
	(bind ?new-factid 
		(modify ?x 
			(slot-definitions (create$ "(" multislot (instance-name-to-symbol ?new-slot) "(" type (find-correct-datatype (instance-name-to-symbol ?range)) ")" ")" $?slot-defs)) 
			(aliases-defaults (create$ (create-aliases (instance-name-to-symbol ?new-slot) (instances-to-symbols $?super-properties)) $?aliases))
		)
	)
	(bind ?*redefined_class_facts* (create$ ?new-factid (delete-member$ ?*redefined_class_facts* ?x)))
	(bind ?*cycle-change-flag* true)
)

(defrule insert-new-property-no-domain-Resource
;	(goal put-new-properties)
	?x <- (redefined-class (name rdfs:Resource) (slot-definitions $?slot-defs) (class-refs-defaults $?class-refs) (aliases-defaults $?aliases))
	?y <- (object 
		(is-a rdf:Property) 
		(name ?new-slot) 
		(rdfs:domain $?list&:(= (length$ $?list) 0)) 
		(rdfs:range $?ranges&:(not-datatype $?ranges)) 
;		(rdfs:range $?ranges) 
		(rdfs:subPropertyOf $?super-properties))
	(test (= (length$ (exist-classes $?ranges)) 0))
	(test (is-only-one-class (instances-to-symbols $?ranges)))
;	(test (neq rdfs:Literal (get-only-one-class (instances-to-symbols $?ranges))))
	(not (test (member$ (instance-name-to-symbol ?new-slot) $?slot-defs)))
  =>
  	(debug  "New property: " (instance-name-to-symbol ?new-slot) " for rdfs:Resource." crlf)
	(bind ?new-factid 
		(modify ?x 
			(slot-definitions (create$ "(" multislot (instance-name-to-symbol ?new-slot) "(" type INSTANCE-NAME ")" ")" $?slot-defs))
			(class-refs-defaults (create$ (instance-name-to-symbol ?new-slot) (get-only-one-class (instances-to-symbols $?ranges)) $?class-refs))
			(aliases-defaults (create$ (create-aliases (instance-name-to-symbol ?new-slot) (instances-to-symbols $?super-properties)) $?aliases))
		)
	)
	(bind ?*redefined_class_facts* (create$ ?new-factid (delete-member$ ?*redefined_class_facts* ?x)))
	(bind ?*cycle-change-flag* true)
)

(defrule insert-new-property-no-domain-no-range
;	(goal put-new-properties)
	?x <- (redefined-class (name rdfs:Resource) (slot-definitions $?slot-defs) (aliases-defaults $?aliases))
	?y <- (object (is-a rdf:Property) (name ?new-slot) (rdfs:domain $?list1&:(= (length$ $?list1) 0)) (rdfs:range $?list2&:(= (length$ $?list2) 0)) (rdfs:subPropertyOf $?super-properties))
	(not (test (member$ (instance-name-to-symbol ?new-slot) $?slot-defs)))
  =>
  	(debug  "New property: " (instance-name-to-symbol ?new-slot) " for rdfs:Resource." crlf)
	(bind ?new-factid 
		(modify ?x 
			(slot-definitions (create$ "(" multislot (instance-name-to-symbol ?new-slot) ")" $?slot-defs))
			(aliases-defaults (create$ (create-aliases (instance-name-to-symbol ?new-slot) (instances-to-symbols $?super-properties)) $?aliases))
		)
	)
	(bind ?*redefined_class_facts* (create$ ?new-factid (delete-member$ ?*redefined_class_facts* ?x)))
	(bind ?*cycle-change-flag* true)
)


; New
(defrule insert-new-property-one-domain-Datatype
;	(goal put-new-properties)
	?x <- (redefined-class (name ?class) (isa-slot $?super-classes) (slot-definitions $?slot-defs) (aliases-defaults $?aliases))
	(test (instance-existp (symbol-to-instance-name ?class))) ; this refers to "blank" multi-typing classes
	?y <- (object (is-a rdf:Property) (name ?new-slot) (rdfs:domain $?domains) (rdfs:range ?range&:(is-datatype ?range)) (rdfs:subPropertyOf $?super-properties))
;	(object (is-a rdfs:Datatype) (name ?range) (rdfs:subClassOf [rdfs:Literal]))
	(test (= (length$ (exist-classes $?domains)) 0))
	(test (aux-resource7 ?class $?domains))
;	(test (is-only-one-class (instances-to-symbols $?domains)))
;	(test (eq ?class (get-only-one-class (instances-to-symbols $?domains))))
	(not (test (member$ (instance-name-to-symbol ?new-slot) $?slot-defs)))
  =>
  	(debug  "New property: " (instance-name-to-symbol ?new-slot) " for class " ?class crlf)
	(bind ?new-factid 
		(modify ?x 
			(slot-definitions (create$ "(" multislot (instance-name-to-symbol ?new-slot) "(" type (find-correct-datatype (instance-name-to-symbol ?range)) ")" ")" $?slot-defs)) 
			(aliases-defaults (create$ (create-aliases (instance-name-to-symbol ?new-slot) (instances-to-symbols $?super-properties)) $?aliases))
		)
	)
	(bind ?*redefined_class_facts* (create$ ?new-factid (delete-member$ ?*redefined_class_facts* ?x)))
	(bind ?*cycle-change-flag* true)
)


(defrule insert-new-property-one-domain-Resource
;	(goal put-new-properties)
	?x <- (redefined-class (name ?class) (isa-slot $?super-classes) (slot-definitions $?slot-defs) (class-refs-defaults $?class-refs) (aliases-defaults $?aliases))
	(test (instance-existp (symbol-to-instance-name ?class))) ; this refers to "blank" multi-typing classes
	?y <- (object 
		(is-a rdf:Property) 
		(name ?new-slot) 
		(rdfs:domain $?domains) 
		(rdfs:range $?ranges&:(not-datatype $?ranges)) 
		(rdfs:subPropertyOf $?super-properties))
	(test (= (length$ (exist-classes $?domains)) 0))
	(test (aux-resource7 ?class $?domains))
;	(test (is-only-one-class (instances-to-symbols $?domains)))
;	(test (eq ?class (get-only-one-class (instances-to-symbols $?domains))))
	(test (= (length$ (exist-classes $?ranges)) 0))
	(test (is-only-one-class (instances-to-symbols $?ranges)))
;	(test (neq rdfs:Literal (get-only-one-class (instances-to-symbols $?ranges))))
	(not (test (member$ (instance-name-to-symbol ?new-slot) $?slot-defs)))
  =>
  	(debug  "New property: " (instance-name-to-symbol ?new-slot) " for class " ?class crlf)
	(bind ?new-factid 
		(modify ?x 
			(slot-definitions (create$ "(" multislot (instance-name-to-symbol ?new-slot) "(" type INSTANCE-NAME ")" ")" $?slot-defs))
			(class-refs-defaults (create$ (instance-name-to-symbol ?new-slot) (get-only-one-class (instances-to-symbols $?ranges)) $?class-refs))
			(aliases-defaults (create$ (create-aliases (instance-name-to-symbol ?new-slot) (instances-to-symbols $?super-properties)) $?aliases))
		)
	)
	(bind ?*redefined_class_facts* (create$ ?new-factid (delete-member$ ?*redefined_class_facts* ?x)))
	(bind ?*cycle-change-flag* true)
)

(defrule insert-new-property-one-domain-no-range
;	(goal put-new-properties)
	?x <- (redefined-class (name ?class) (isa-slot $?super-classes) (slot-definitions $?slot-defs) (aliases-defaults $?aliases))
	(test (instance-existp (symbol-to-instance-name ?class))) ; this refers to "blank" multi-typing classes
	?y <- (object (is-a rdf:Property) (name ?new-slot) (rdfs:domain $?domains) (rdfs:range $?list&:(= (length$ $?list) 0)) (rdfs:subPropertyOf $?super-properties))
	(test (= (length$ (exist-classes $?domains)) 0))
	(test (aux-resource7 ?class $?domains))
;	(test (is-only-one-class (instances-to-symbols $?domains)))
;	(test (eq ?class (get-only-one-class (instances-to-symbols $?domains))))
	(not (test (member$ (instance-name-to-symbol ?new-slot) $?slot-defs)))
  =>
  	(debug  "New property: " (instance-name-to-symbol ?new-slot) " for class " ?class crlf)
	(bind ?new-factid 
		(modify ?x 
			(slot-definitions (create$ "(" multislot (instance-name-to-symbol ?new-slot) ")" $?slot-defs))
			(aliases-defaults (create$ (create-aliases (instance-name-to-symbol ?new-slot) (instances-to-symbols $?super-properties)) $?aliases))
		)
	)
	(bind ?*redefined_class_facts* (create$ ?new-factid (delete-member$ ?*redefined_class_facts* ?x)))
	(bind ?*cycle-change-flag* true)
)
