(defclass TYPED-CLASS
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
	;(multislot class-refs 
	;	(type SYMBOL) 
	;	(storage shared)
	;	(access read-only)
	;)
	(slot namespace
		(type SYMBOL)
		(storage shared)
		(access read-only)
	)
)

(defclass DERIVED-CLASS
	(is-a TYPED-CLASS RDF-CLASS DEFEASIBLE-OBJECT)
	;(is-a rdfs:Class DEFEASIBLE-OBJECT)
)

(defclass tm-DERIVED-CLASS
	(is-a DERIVED-CLASS)
	(slot counter (type INTEGER) (default 1))
	(multislot derivators)
)

(defclass derived-class-inst
	(is-a rdfs:Class)
	;(slot name (type SYMBOL))
	(slot stratum (type INTEGER) (default 1))
	(multislot deductive-rules (type INSTANCE-NAME))
)

(definstances derived_class
	(derived-class-inst of rdfs:Class 
		(rdf:type [rdfs:Class])
		(rdfs:subClassOf [rdfs:Class])
		(rdfs:label Derived-Class)
		(rdfs:comment "The class of derived classes")
		; The following are inherited from rdfs:Class
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
			rdfs:subClassOf rdfs:Class
			; The following is defined here!
			deductive-rules r-device-rule
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
)

(defclass defeasible-class 
	(is-a rdfs:Class)
	(slot class-name (type SYMBOL))
	(multislot rules (type INSTANCE-NAME))
	(slot defeasible-stratum (type INTEGER) (default 0))
)

(definstances defeasible_class
	(defeasible-class of rdfs:Class 
		(rdf:type [rdfs:Class])
		(rdfs:subClassOf [rdfs:Class])
		(rdfs:label Defeasible-Class)
		(rdfs:comment "The class of defeasible classes")
		; The following are inherited from rdfs:Class
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
			rdfs:subClassOf rdfs:Class
			; The following is defined here!
			rules defeasible-logic-rule
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
)

