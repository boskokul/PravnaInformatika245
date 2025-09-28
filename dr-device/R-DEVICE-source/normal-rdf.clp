(defclass RDF-CLASS
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
	(slot uri (type SYMBOL))
	;(slot uri (type STRING))
	(slot source (type SYMBOL) (default rdf))
	;(multislot class-refs 
	;	(type SYMBOL) 
	;	(storage shared)
	;	(access read-only)
	;)
	;(multislot aliases 
	;	(type SYMBOL) 
	;	(storage shared)
	;	(access read-only)
	;)
)
