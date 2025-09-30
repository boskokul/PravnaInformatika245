(defrule put-remaining-triples-container-membership-properties
	(declare (salience 100))
;	(goal put-remaining-triples)
	(triple (predicate ?p&:(and (not (instance-existp ?p)) 
					(is-membership-property (instance-name-to-symbol ?p)) 
					(not (search_useful_info ?p 7)))))
	;(test (not (instance-existp ?p)))
	;(test (is-membership-property (instance-name-to-symbol ?p)))
	; CUI
	;(test (not (search_useful_info ?p 7)))
	;(test (not (member$ ?p ?*ContainerMembershipProperties*)))
;	(not (triple (subject ?p) (predicate [rdf:type]) (object [rdfs:ContainerMembershipProperty])))
  =>
  	(if (assert (triple (subject ?p) (predicate [rdf:type]) (object [rdfs:ContainerMembershipProperty])))
  	   then
  		(debug "Asserting type rdfs:ContainerMembershipProperty for resource " ?p crlf)
  	   	(bind ?*triple_counter* (+ ?*triple_counter* 1))
  	)
  	(if (assert (triple (subject ?p) (predicate [rdfs:subPropertyOf]) (object [rdfs:member])))
  	   then
  		(bind ?*triple_counter* (+ ?*triple_counter* 1))
  	)
)

; New
(defrule put-remaining-triples-properties
	(declare (salience 100))
;	(goal put-remaining-triples)
	(triple (predicate ?p&:(and (not (instance-existp ?p)) 
				(not (is-membership-property (instance-name-to-symbol ?p))) 
				(not (search_useful_info ?p 3 5)))) 
		(object ?o) 
		(object-datatype ?obj-dt))
	;(test (not (instance-existp ?p)))
	;(test (not (is-membership-property (instance-name-to-symbol ?p))))
	; CUI
	;(test (not (search_useful_info ?p 3 5)))
	;(test (not (member$ ?p ?*Properties*)))
;	(not (triple (subject ?p) (predicate [rdf:type]) (object [rdf:Property])))
	; CUI
	;(test (not (member$ ?p ?*HasRange*)))
;	(not (triple (subject ?p) (predicate [rdfs:range])))
	;(not (triple (subject ?p) (predicate rdf:type) (object ?PropClass&:(and (class-existp ?PropClass) (subclassp ?PropClass rdf:Property)))))
  =>
   	;(bind ?data-type (inverse-transform-datatype ?o))
 	(if (assert (triple (subject ?p) (predicate [rdf:type]) (object [rdf:Property])))
 	   then
   		(debug "Asserting type rdf:Property for resource " ?p crlf)
 	   	(bind ?*triple_counter* (+ ?*triple_counter* 1))
 	)
 	(if (neq ?obj-dt nil)
 	   then
  	    	(if (assert (triple (subject ?p) (predicate [rdfs:range]) (object ?obj-dt)))
  	    	   then
   			(debug "Asserting datatype " ?obj-dt " for property " ?p crlf)
  			(bind ?*triple_counter* (+ ?*triple_counter* 1))
  		)
  	)
)


(defrule put-remaining-triples-subjects-with-and-without-domain
;	(goal put-remaining-triples)
	;(object (is-a rdf:Property) (name ?p) (rdfs:domain $?domains))
	(triple (subject ?s&:(and (not (instance-existp ?s))(not (search_useful_info ?s 2)) )) 
		(predicate ?p&~[rdf:type]&:(instance-existp ?p)))
	                       ; MIXED: this can be replaced by (not (instance-existp ?s)) alone
	; CUI
	;(test (not (search_useful_info ?s 2)))
	;(test (not (member$ ?s ?*HasType*)))
;	(test (not (searchHasType ?s)))
;	(not (hasType ?s))
;	(not (triple (subject ?s) (predicate [rdf:type])))
	;(test (not (instance-existp ?s)))
  =>
  	(bind $?domains (send ?p get-rdfs:domain))
 	(bind ?end (length$ $?domains))
 	(if (> ?end 0)
 	   then
 		(loop-for-count (?n 1 ?end)
 		   do
 		   	(bind ?domain (nth$ ?n $?domains))
 		   	(if (assert (triple (subject ?s) (predicate [rdf:type]) (object ?domain)))
 		   	   then
   				(debug "Asserting type " ?domain " for resource " ?s crlf)
 		   	   	(bind ?*triple_counter* (+ ?*triple_counter* 1))
 		   	)
 		)
 	   else
    	  	(if (assert (triple (subject ?s) (predicate [rdf:type]) (object [rdfs:Resource])))
	  	   then
	   		(debug "Asserting type rdfs:Resource for resource " ?s crlf)
	  		(bind ?*triple_counter* (+ ?*triple_counter* 1))
	  	)
	)
)

; Here the rule put-remaining-triples-subjects-no-domain is missing!
; It has been fused with the previous one!

(defrule put-remaining-triples-subjects-wrong-domain
;	(goal put-remaining-triples)
	;(object (is-a rdf:Property) (name ?p) (rdfs:domain $?domains&:(> (length$ $?domains) 0)))
	(triple (subject ?s&:(and (instance-existp ?s) (not (search_useful_info ?s 2)))) 
		;(predicate ?p&:(aux-resource5 ?s ?p)) 
		(predicate ?p&:(and (instance-existp ?p) 
				(not (slot-existp (class ?s) (instance-name-to-symbol ?p) inherit))))
		;(object ?o)
	)
		             ; MIXED: this cannot be replaced! Needs type info!
	;(test (aux-resource5 ?s ?p))
;	(test (instance-existp ?s))
;	(test (not (slot-existp (resource-class ?s) ?p inherit)))
	; CUI
	;(test (not (search_useful_info ?s 2)))
	;(test (not (member$ ?s ?*HasType*)))
;	(test (not (searchHasType ?s)))
;	(not (hasType ?s))
;  	(not (triple (subject ?s) (predicate [rdf:type])))
  =>
  	(bind $?domains (send ?p get-rdfs:domain))
  	(bind ?end (length$ $?domains))
  	(if (> ?end 0)
  	   then
  		(if (> ?end 1)
  		   then
  			(bind ?type (exists-class-with-super-classes (instances-to-symbols $?domains)))
  		   else
  			(bind ?type (instance-name-to-symbol (nth$ 1 $?domains)))
  		)
   		(bind ?res-type (class ?s))
		(if (not (compatible-types ?res-type ?type))
  		   then
  		   	(if (assert (triple (subject ?s) (predicate [rdf:type]) (object (symbol-to-instance-name ?type))))
  		   	   then
  		   		(debug "Asserting new type " ?type " for resource " ?s crlf)
  		   		(bind ?*triple_counter* (+ ?*triple_counter* 1))
  		   	)
  		   	;(debug "Type conflict!" crlf)
  		   	;(debug "Subject: " ?s " is of type " ?res-type " while predicate " ?p " has domain " $?domains crlf)
  			;(assert (rejected-triple (subject ?s) (predicate ?p) (object ?o)))
   			;(triple-retract ?x)
 		)
 	)
)

		
(defrule put-remaining-triples-objects-with-and-without-range
;	(goal put-remaining-triples)
	;(object (is-a rdf:Property) (name ?p) (rdfs:range $?ranges&:(not-datatype $?ranges)))
	(triple (predicate ?p&:(instance-existp ?p))
		(object ?o&:(and (instance-namep ?o) 
				(not (instance-existp ?o)) 
				(not (search_useful_info ?o 2)))))
		             ; MIXED: this can be replaced by (and (instance-namep ?o) (not (instance-existp ?o))) alone
	;(test (instance-namep ?o))
	;(test (not (instance-existp ?o)))
	;(neq $?ranges (create$ [rdfs:Literal]))))
	; CUI
	;(test (not (search_useful_info ?o 2)))
	;(test (not (member$ ?o ?*HasType*)))
;	(test (not (searchHasType ?o)))
;	(not (hasType ?o))
;   	(not (triple (subject ?o) (predicate [rdf:type])))
 =>
 	(bind $?ranges (send ?p get-rdfs:range))
 	(bind ?end (length$ $?ranges))
 	(if (> ?end 0)
 	   then
 	   	(if (not-datatype $?ranges)
 	   	   then
	 		(loop-for-count (?n 1 ?end)
	 		   do
	 		   	(bind ?range (nth$ ?n $?ranges))
	 		   	(if (assert (triple (subject ?o) (predicate [rdf:type]) (object ?range)))
	 		   	   then
	 		   		(debug "Asserting type " ?range " for resource " ?o crlf)
	 		   	   	(bind ?*triple_counter* (+ ?*triple_counter* 1))
	 		   	)
	 		)
	 	)
	    else
		(if (assert (triple (subject ?o) (predicate [rdf:type]) (object [rdfs:Resource])))
		   then
 	  		(debug "Asserting type rdfs:Resource for resource " ?o crlf)
			(bind ?*triple_counter* (+ ?*triple_counter* 1))
		)
	)
)

; Here the rule put-remaining-triples-objects-no-range is missing!
; It has been fused with the previous one!


(defrule put-remaining-triples-non-existing-classes
;	(goal create-instances)
	?x <- (candidate-object (classes $? ?class&:(not (instance-existp ?class)) $?))
  =>
	(if (assert (triple (subject ?class) (predicate [rdf:type]) (object [rdfs:Class])))
	   then
 		(debug "Asserting type rdfs:Class for resource " ?class crlf)
			(bind ?*triple_counter* (+ ?*triple_counter* 1))
	)
)
