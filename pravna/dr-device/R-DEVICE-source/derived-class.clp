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
	(is-a TYPED-CLASS)
)

(defclass tm-DERIVED-CLASS
	(is-a DERIVED-CLASS)
	(slot counter (type INTEGER) (default 1))
	(multislot derivators)
)
