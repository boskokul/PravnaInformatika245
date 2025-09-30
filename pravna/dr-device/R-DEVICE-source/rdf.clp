(defglobal 
	;?*fetched_url* = (create$)
	?*entities* = (create$)
	?*truth_maintenance* = on
	;?*resource_instances* = (create$)
	;?*resource_addresses* = (create$)
	;?*future_resource_instances* = (create$)
	;?*future_resource_addresses* = (create$)
	?*triple_counter* = 0
	?*test_counter* = 0
;	?*UsefulInfo* = (create$)   ; CUI
	;?*UsefulInfo-address-vars* = (create$)   ; CUI
	;?*UsefulInfo-value-vars* = (create$)   ; CUI
	;?*future_resource_instances-vars* = (create$)
	;?*future_resource_addresses-vars* = (create$)
	;?*temp-future_resource_instances-vars* = (create$)
	;?*temp-future_resource_addresses-vars* = (create$)
	?*HashBuckets_default* = 100	; CUI
	?*HashBuckets* = 1	; CUI
	?*divident-buckets* = 1
	?*rdf_triple_limit_default* = 10000  ; PLAI
	?*rdf_triple_limit* = 0  ; PLAI
	?*open_n3_file* = nil   ; PLAI
;	?*ContainerMembershipProperties* = (create$)   ; CUI
;	?*Properties* = (create$)   ; CUI
;	?*HasRange* = (create$)   ; CUI
;	?*HasType* = (create$)   ; CUI
;	?*HasType1* = (create$)   ; CUI
;	?*HasType2* = (create$)   ; CUI
	?*redefined_class_facts* = (create$)
	?*class_to_undefine_facts* = (create$)
	?*verbose_status* = off
	?*debug_status* = off
	?*time_report* = off
	?*rdf-caching* = on
	?*namespace-hunting* = off
	?*parsed-file* = (create$)
	?*cycle-change-flag* = false
	?*namespace-uris-labels* = 
		(create$ 
			;<http://www.w3.org/1999/02/22-rdf-syntax-ns#> rdf
			;<http://www.w3.org/2000/01/rdf-schema-more#> rdfs-more
			;<http://www.w3.org/2000/01/rdf-schema#> rdfs
			;<http://www.w3.org/2001/XMLSchema#> xsd
			(sym-cat "http://www.w3.org/1999/02/22-rdf-syntax-ns") rdf
			(sym-cat "http://www.w3.org/2000/01/rdf-schema-more") rdfs-more
			(sym-cat "http://www.w3.org/2000/01/rdf-schema") rdfs
			(sym-cat "http://www.w3.org/2001/XMLSchema") xsd
		)
)

(defglobal 
	?*undef_rules* = (create$)
	?*undef_functions* = (create$)
	?*restore_instances_filenames* = (create$)
)

;(defclass future-instance
;	(is-a USER)
;	(role concrete)
;	(pattern-match reactive)
;	(slot future_resource_address (type SYMBOL))
;	(slot future_resource_instance (type INSTANCE-NAME))
;)

(deftemplate triple
	(slot subject (type INSTANCE-NAME))
	(slot predicate (type INSTANCE-NAME))
	(slot object (type INSTANCE-NAME STRING INTEGER FLOAT))
	(slot object-datatype (type INSTANCE-NAME SYMBOL))
)

(deftemplate rejected-triple
	(slot subject (type INSTANCE-NAME))
	(slot predicate (type INSTANCE-NAME))
	(slot object (type INSTANCE-NAME STRING INTEGER FLOAT))
	(slot object-datatype (type INSTANCE-NAME SYMBOL))
)

(deftemplate candidate-class
	(slot name (type SYMBOL))
	(multislot isa-slot (type SYMBOL))
	(multislot slot-definitions (type LEXEME))
	(multislot class-refs-defaults (type SYMBOL))
	(multislot aliases-defaults (type SYMBOL))
)

(deftemplate redefined-class
	(slot name (type SYMBOL))
	(multislot isa-slot (type SYMBOL))
	(multislot slot-definitions (type LEXEME))
	(multislot class-refs-defaults (type SYMBOL))
	(multislot aliases-defaults (type SYMBOL))
)

(deftemplate candidate-object 
	(slot name (type INSTANCE-NAME)) 
	(multislot classes (type INSTANCE-NAME))
	;;; New 25-03-2005
	(multislot slot-values (type ?VARIABLE))
)

(defclass redefined-class-instance
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
	(slot class-instance-name (type INSTANCE-NAME))
	(multislot super-classes (type SYMBOL))
	(multislot class-refs (type SYMBOL))
	(multislot aliases (type SYMBOL))
)

;(defclass candidate-object 
;	(is-a USER)
;	(role concrete)
;	(pattern-match reactive)
;	(slot name (type INSTANCE-NAME)) 
;	(multislot classes (type INSTANCE-NAME))
;)

;(defclass RDF-CLASS
;	(is-a USER)
;	(role concrete)
;	(pattern-match reactive)
;	(slot uri (type SYMBOL))
;	(slot source (type SYMBOL) (default rdf))
;	(multislot class-refs 
;		(type SYMBOL) 
;		(storage shared)
;		(access read-only)
;	)
;	(multislot aliases 
;		(type SYMBOL) 
;		(storage shared)
;		(access read-only)
;	)
;)

;(defmessage-handler RDF-CLASS put-uri after (?uri)
;	(bind ?*resource_addresses* (create$ ?uri ?*resource_addresses*))
;	(bind ?*resource_instances* (create$ (instance-name ?self) ?*resource_instances*))
;	(bind ?*resource_instances* (create$ (sym-cat < ?uri >) (instance-name ?self) ?*resource_instances*))
;)

(defclass rdfs:Resource
	(is-a RDF-CLASS)
	(multislot rdfs:isDefinedBy (type INSTANCE-NAME))
	(multislot rdf:type (type INSTANCE-NAME))
	(multislot rdf:value)
	(multislot rdfs:comment (type LEXEME))
	(multislot rdfs:label (type LEXEME))
	(multislot rdfs:seeAlso (type INSTANCE-NAME))
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)

(defclass rdfs:Class
	(is-a rdfs:Resource meta-class)
	(multislot rdfs:subClassOf (type INSTANCE-NAME))
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;		rdfs:subClassOf rdfs:Class
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)

(defclass rdf:Property
	(is-a rdfs:Resource)
	(multislot rdfs:domain (type INSTANCE-NAME))
	(multislot rdfs:range (type INSTANCE-NAME))
	(multislot rdfs:subPropertyOf (type INSTANCE-NAME))
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;		rdfs:domain rdfs:Class
	;		rdfs:range rdfs:Class
	;		rdfs:subPropertyOf rdf:Property
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)

(defclass rdfs:Datatype        ; New
	(is-a rdfs:Class)
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;		rdfs:subClassOf rdfs:Class
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)	

(defclass rdf:Statement
	(is-a rdfs:Resource)
	(multislot rdf:subject (type INSTANCE-NAME))
	(multislot rdf:predicate (type INSTANCE-NAME))
	(multislot rdf:object)
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;		rdf:subject rdfs:Resource
	;		rdf:predicate rdf:Property
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)

(defclass rdfs:Container
	(is-a rdfs:Resource)
	(multislot rdfs:member)
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)

(defclass rdf:Alt
	(is-a rdfs:Container)
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)

(defclass rdf:Bag
	(is-a rdfs:Container)
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)

(defclass rdf:Seq
	(is-a rdfs:Container)
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)

(defclass rdfs:ContainerMembershipProperty
	(is-a rdf:Property)
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;		rdfs:domain rdfs:Class
	;		rdfs:range rdfs:Class
	;		rdfs:subPropertyOf rdf:Property
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)

(defclass rdf:List
	(is-a rdfs:Resource)
	(multislot rdf:first (type INSTANCE-NAME))
	(multislot rdf:rest (type INSTANCE-NAME))
	;(multislot class-refs 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:isDefinedBy rdfs:Resource
	;		rdf:type rdfs:Class
	;		rdfs:seeAlso rdfs:Resource
	;		rdf:first rdfs:Resource
	;		rdf:rest rdf:List
	;	))
	;)
	;(multislot aliases 
	;	(source composite) 
	;	(default (create$ 
	;		rdfs:seeAlso rdfs:isDefinedBy
	;	))
	;)
)



(definstances rdf_classes
	(rdf of rdfs:Resource 
		(rdfs:isDefinedBy [rdf])
		;Must be defined/inserted afterwards
		(rdf:type [rdfs:Resource])
		;(uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#>)
		(uri (sym-cat "http://www.w3.org/1999/02/22-rdf-syntax-ns"))
		(source system)
		(rdfs:comment "The core RDF syntax namespace")
		(rdfs:label rdf)
	)
	(rdfs-more of rdfs:Resource 
		(rdfs:isDefinedBy [rdfs-more])
		;Must be defined/inserted afterwards
		(rdf:type [rdfs:Resource])
		;(uri <http://www.w3.org/2000/01/rdf-schema-more#>)
		(uri (sym-cat "http://www.w3.org/2000/01/rdf-schema-more"))
		(source system)
		(rdfs:comment "This document provides additional statements about the RDF Schema namespace")
		(rdfs:label rdfs-more)
	)
	(rdfs of rdfs:Resource 
		(rdfs:isDefinedBy [rdfs])
		;Must be defined/inserted afterwards
		(rdf:type [rdfs:Resource])
		;(uri <http://www.w3.org/2000/01/rdf-schema#>)
		(uri (sym-cat "http://www.w3.org/2000/01/rdf-schema"))
		(source system)
		(rdfs:comment "The RDF Schema Vocabulary namespace")
		(rdfs:label rdfs)
		(rdfs:seeAlso [rdfs-more])
	)
	(xsd of rdfs:Resource 
		(rdfs:isDefinedBy [xsd])
		;Must be defined/inserted afterwards
		(rdf:type [rdfs:Resource])
		;(uri <http://www.w3.org/2001/XMLSchema#>)
		(uri (sym-cat "http://www.w3.org/2001/XMLSchema"))
		(source system)
		(rdfs:comment "The XML Schema namespace")
		(rdfs:label xsd)
	)
	(rdfs:Class of rdfs:Class 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdfs:Class])
		;Must be defined/inserted afterwards
		(rdfs:subClassOf [rdfs:Resource])
		(rdfs:label Class)
		(rdfs:comment "The concept of Class")
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
			rdfs:subClassOf rdfs:Class
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdfs:Resource of rdfs:Class 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdfs:Class])
		(rdfs:label Resource)
		(rdfs:comment "The class resource, everything.")
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdf:Property of rdfs:Class 
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdfs:Class])
		(rdfs:subClassOf [rdfs:Resource])
		(rdfs:label Property)
		(rdfs:comment "The concept of a property.")
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
			rdfs:domain rdfs:Class
			rdfs:range rdfs:Class
			rdfs:subPropertyOf rdf:Property
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdfs:Literal of rdfs:Class 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdfs:Class])
		(rdfs:label Literal)
		(rdfs:comment "This represents the set of atomic values, eg. textual strings.")
	)
	(rdfs:Datatype of rdfs:Class    ; New
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdfs:Class])
		(rdfs:label Datatype)
		(rdfs:comment "The class of RDF datatypes.")
		(rdfs:subClassOf [rdfs:Class])
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
			rdfs:subClassOf rdfs:Class
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdf:XMLLiteral of rdfs:Datatype    ; New
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdfs:Datatype])
		(rdfs:label XMLLiteral)
		(rdfs:comment "The class of XML literal values.")
		(rdfs:subClassOf [rdfs:Literal])
	)
;	(xsd:integer of rdfs:Datatype    ; New
;		(rdfs:isDefinedBy [xsd])
;		(rdf:type [rdfs:Datatype])
;		(rdfs:label xsd:integer)
;		(rdfs:comment "Integer")
;		(rdfs:subClassOf [rdfs:Literal])
;	)
	(rdf:Statement of rdfs:Class 
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdfs:Class])
		(rdfs:subClassOf [rdfs:Resource])
		(rdfs:label Statement)
		(rdfs:comment "The class of RDF statements.")
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
			rdf:subject rdfs:Resource
			rdf:predicate rdf:Property
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdfs:Container of rdfs:Class 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdfs:Class])
		(rdfs:subClassOf [rdfs:Resource])
		(rdfs:label Container)
		(rdfs:comment "This represents the set Containers.")
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdf:Alt of rdfs:Class 
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdfs:Class])
		(rdfs:subClassOf [rdfs:Container])
		(rdfs:label Alt)
		(rdfs:comment "A collection of alternatives.")
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdf:Bag of rdfs:Class 
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdfs:Class])
		(rdfs:subClassOf [rdfs:Container])
		(rdfs:label Bag)
		(rdfs:comment "An unordered collection.")
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdf:Seq of rdfs:Class 
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdfs:Class])
		(rdfs:subClassOf [rdfs:Container])
		(rdfs:label Seq)
		(rdfs:comment "An ordered collection.")
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdfs:ContainerMembershipProperty of rdfs:Class 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdfs:Class])
		(rdfs:subClassOf [rdf:Property])
		(rdfs:label ContainerMembershipProperty)
		(rdfs:comment "The container membership properties, rdf:1, rdf:2, ..., all of which are sub-properties of 'member'.")
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
			rdfs:domain rdfs:Class
			rdfs:range rdfs:Class
			rdfs:subPropertyOf rdf:Property
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdf:List of rdfs:Class         ; New
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdfs:Class])
		(rdfs:label List)
		(rdfs:comment "The class of RDF Lists.")
		(rdfs:subClassOf [rdfs:Resource])
		(class-refs 
			rdfs:isDefinedBy rdfs:Resource
			rdf:type rdfs:Class
			rdfs:seeAlso rdfs:Resource
			rdf:first rdfs:Resource
			rdf:rest rdf:List
		)
		(aliases 
			rdfs:seeAlso rdfs:isDefinedBy
		)
	)
	(rdf:nil of rdf:List         ; New
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdfs:List])
		(rdfs:label nil)
		(rdfs:comment "The empty list, with no items in it. If the rest of a list is nil then the list has no more items in it.")
	)
	(rdf:first of rdf:Property   ; New
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdf:List])
		(rdfs:range [rdfs:Resource])
		(rdfs:label first)
		(rdfs:comment "The first item in the subject RDF list.")
	)
	(rdf:rest of rdf:Property   ; New
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdf:List])
		(rdfs:range [rdf:List])
		(rdfs:label rest)
		(rdfs:comment "The rest of the subject RDF list after the first item.")
	)
	(rdf:object of rdf:Property 
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdf:Statement])
		(rdfs:label object)
		(rdfs:comment "Identifies the object of a statement when representing the statement in reified form")
	)
	(rdf:predicate of rdf:Property 
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdf:Statement])
		(rdfs:range [rdf:Property])
		(rdfs:label predicate)
		(rdfs:comment "Identifies the property used in a statement when representing the statement in reified form")
	)
	(rdf:subject of rdf:Property 
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdf:Statement])
		(rdfs:range [rdfs:Resource])
		(rdfs:label subject)
		(rdfs:comment "Identifies the resource that a statement is describing when representing the statement in reified form")
	)
	(rdf:type of rdf:Property 
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdfs:Resource])
		(rdfs:range [rdfs:Class])
		(rdfs:label type)
		(rdfs:comment "Identifies the Class of a resource")
	)
	(rdf:value of rdf:Property 
		(rdfs:isDefinedBy [rdf])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdfs:Resource])
		(rdfs:label value)
		(rdfs:comment "Identifies the principal value (usually a string) of a property when the property value is a structured resource")
	)
	(rdfs:comment of rdf:Property 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdfs:Resource])
		(rdfs:range [rdfs:Literal])
		(rdfs:label comment)
		(rdfs:comment "Use this for descriptions")
	)
	(rdfs:domain of rdf:Property 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdf:Property])
		(rdfs:range [rdfs:Class])
		(rdfs:label domain)
		(rdfs:comment "A domain class for a property type")
	)
	(rdfs:seeAlso of rdf:Property 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdfs:Resource])
		(rdfs:range [rdfs:Resource])
		(rdfs:label seeAlso)
		(rdfs:comment "A resource that provides information about the subject resource")
	)
	(rdfs:isDefinedBy of rdf:Property 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdfs:Resource])
		(rdfs:range [rdfs:Resource])
		(rdfs:subPropertyOf [rdfs:seeAlso])
		(rdfs:label isDefinedBy)
		(rdfs:comment "Indicates the namespace of a resource")
	)
	(rdfs:label of rdf:Property 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdfs:Resource])
		(rdfs:range [rdfs:Literal])
		(rdfs:label label)
		(rdfs:comment "Provides a human-readable version of a resource name.")
	)
	(rdfs:member of rdf:Property 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdfs:Container])
		(rdfs:label member)
		(rdfs:comment "Á member of a container")
	)
	(rdfs:range of rdf:Property 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdf:Property])
		(rdfs:range [rdfs:Class])
		(rdfs:label range)
		(rdfs:comment "A range class for a property type")
	)
	(rdfs:subClassOf of rdf:Property 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdfs:Class])
		(rdfs:range [rdfs:Class])
		(rdfs:label subClassOf)
		(rdfs:comment "Indicates membership of a class")
	)
	(rdfs:subPropertyOf of rdf:Property 
		(rdfs:isDefinedBy [rdfs])
		(rdf:type [rdf:Property])
		(rdfs:domain [rdf:Property])
		(rdfs:range [rdf:Property])
		(rdfs:label subPropertyOf)
		(rdfs:comment "Indicates specialization of properties")
	)

)

