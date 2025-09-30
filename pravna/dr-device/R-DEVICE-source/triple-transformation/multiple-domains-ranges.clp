(defrule property-with-multiple-domains
	;(goal multiple-domains-ranges)
	?prop <- (object (is-a rdf:Property) (name ?property) (rdfs:domain $?domains&:(> (length$ $?domains) 1)))
	(test (aux-resource6 $?domains))
;	(test (= (length$ (exist-classes (instances-to-symbols $?domains))) 0)) ; All classes in range exist
;	(test (> (length$ (most-specific-classes (instances-to-symbols $?domains))) 1))  
  =>
  	(bind $?classes (instances-to-symbols $?domains))
 	(debug  "Property: " ?property " with multiple domains: " $?classes crlf)
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
				"(" is-a (most-specific-classes $?classes) ")"
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
	(send ?prop put-rdfs:domain (symbol-to-instance-name ?class-name))
	; Here 2 things must be checked!
	; The new class should directly host the property? or wait for class-redefinition
	; as it is now done! (check example ex1.n3 in ODP directory!)
	; Furthermore, the class-instance should have the correct rdfs:subClassOf properties 
	; or not? Now it does not have any rdfs:subClassOf property.
	; Its rdf:type property also seems to be wrong!
	(bind ?*cycle-change-flag* true)
)

(defrule property-with-multiple-ranges
	;(goal multiple-domains-ranges)
	?prop <- (object (is-a rdf:Property) (name ?property) (rdfs:range $?ranges&:(> (length$ $?ranges) 1)))
	(test (aux-resource6 $?ranges))
;	(test (= (length$ (exist-classes (instances-to-symbols $?ranges))) 0)) ; All classes in range exist
;	(test (> (length$ (most-specific-classes (instances-to-symbols $?ranges))) 1))
  =>
  	(bind $?classes (instances-to-symbols $?ranges))
 	(debug  "Property: " ?property " with multiple ranges: " $?classes crlf)
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
				"(" is-a (most-specific-classes $?classes) ")"
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
	(send ?prop put-rdfs:range (symbol-to-instance-name ?class-name))
	; Here the following thing must be checked!
	; The class-instance should have the correct rdfs:subClassOf properties 
	; or not? Now it does not have any rdfs:subClassOf property.
	; Its rdf:type property also seems to be wrong!
	(bind ?*cycle-change-flag* true)
)
