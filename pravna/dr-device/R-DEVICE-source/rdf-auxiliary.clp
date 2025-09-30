; The functions below are new auxiliary functions


(deffunction set-namespace-hunting (?status)
	(bind ?*namespace-hunting* ?status)
)

(deffunction get-namespace-hunting ()
	?*namespace-hunting*
)

(deffunction set-rdf-caching (?status)
	(bind ?*rdf-caching* ?status)
)

(deffunction get-rdf-caching ()
	?*rdf-caching*
)

(deffunction set-verbose (?status)
	(bind ?*verbose_status* ?status)
)

(deffunction get-verbose ()
	?*verbose_status*
)

(deffunction verbose ($?list)
	(if (eq ?*verbose_status* on)
	   then
	   	(funcall printout t (expand$ $?list))
	)
)

(deffunction pprint-list ($?list)
	(if (eq ?*verbose_status* on)
	   then
		(bind ?end (length$ $?list))
		(loop-for-count (?n 1 ?end)
			(printout t (nth$ ?n $?list) crlf)
		)
		(return TRUE)
	)
)




(deffunction extract-filename (?filename)
	(bind ?pos (str-index "." ?filename))
	(if (neq ?pos FALSE)
	   then
	   	(return (sym-cat (sub-string 1 (- ?pos 1) ?filename)))
	   else
	   	(return (sym-cat ?filename))
	)
)

(deffunction is-uri (?string)
	(if (lexemep ?string)
	   then
	   	(bind ?l (length$ ?string))
		(if (and 
			(eq (sub-string 1 1 ?string) "<")
			(eq (sub-string ?l ?l ?string) ">")
			(not (str-index "<" (sub-string 2 (- ?l 1) ?string)))
			(not (str-index ">" (sub-string 2 (- ?l 1) ?string))))
	   	   then
	   		(return TRUE)
	   	   else
	   		(return FALSE)
	   	)
	   else
	   	(return FALSE)
	)
)

(deffunction is-empty-node (?string)
	(if (and (lexemep ?string) (eq (sub-string 1 2 ?string) "_:"))
	   then
	   	(return TRUE)
	   else
	   	(return FALSE)
	)
)

;(deffunction is-parsed-uri (?string)
;	(if (symbolp ?string)
;	   then
;		(bind ?pos (str-index ":" ?string))
;		(and
;			(neq ?pos FALSE)
;			;(member$ (symbol-to-instance-name (sym-cat (sub-string 1 (- ?pos 1) ?string))) ?*resource_instances*)
;			(instance-existp (symbol-to-instance-name (sym-cat (sub-string 1 (- ?pos 1) ?string))))
;			;(not (integerp (str-index ":" (sub-string (+ ?pos 1) (length ?string) ?string))))
;		)
;	   else
;	   	(return FALSE)
;	)
;)

(deffunction strip-last (?resource)
	;(bind ?l (- (str-length ?resource) 1))
	(bind ?l (str-length ?resource))
	(bind ?lchar (sub-string ?l ?l ?resource))
	(if (or (eq ?lchar "/") (eq ?lchar "#"))
	   then
	   	;(return (str-cat (sub-string 1 (- ?l 1) ?resource) ">"))
	   	(return (sub-string 1 (- ?l 1) ?resource))
	   else
	   	(return ?resource)
	)
)

(deffunction strip-last2 (?resource)
	(bind ?l (str-length ?resource))
	(bind ?lchar (sub-string ?l ?l ?resource))
	(if (or (eq ?lchar "/") (eq ?lchar "#"))
	   then
	   	(return (sub-string 1 (- ?l 1) ?resource))
	   else
	   	(return ?resource)
	)
)

(deffunction similar-uri (?uri1 ?uri2 ?l2)
	; The following two lines have been added because URI's contain <> chars.
	(bind ?l1 (str-length ?uri1))
   	(bind ?uri1 (sub-string 2 (- ?l1 1) ?uri1)) 
;   	(bind ?uri2 (sub-string 2 (- (length$ ?uri2) 1) ?uri2)) 
	(bind ?l1 (- ?l1 2))
;	(bind ?l1 (length$ ?uri1))
;	(bind ?l2 (length$ ?uri2))
	(if (= ?l1 ?l2)
	   then
	   	(if (eq ?uri1 ?uri2)
	   	   then
	   	   	(return TRUE)
	   	   else
	   		(bind ?uri1a (sub-string ?l1 ?l1 ?uri1))
	   		(bind ?uri2a (sub-string ?l2 ?l2 ?uri2))
	   		(if (or (and (eq ?uri1a "#") (eq ?uri2a "/"))
				(and (eq ?uri1a "/") (eq ?uri2a "#")))
	   	   	   then
	   			(return (eq (sub-string 1 (- ?l1 1) ?uri1) (sub-string 1 (- ?l1 1) ?uri2)))
	   	   	   else
	   	   		(return FALSE)
	   		)
	   	)
 	   else
		(if (= (- ?l1 ?l2) 1)
		   then
		   	(bind ?uri1a (sub-string ?l1 ?l1 ?uri1))
			(if (or (eq ?uri1a "#") (eq ?uri1a "/"))
		   	   then
		   		(return (eq (sub-string 1 (- ?l1 1) ?uri1) ?uri2))
		   	   else
		   	   	(return FALSE)
		   	)
		   else
		   	(if (= (- ?l2 ?l1) 1)
		   	   then
		   	   	(bind ?uri2a (sub-string ?l2 ?l2 ?uri2))
				(if (or (eq ?uri2a "#") (eq ?uri2a "/"))
				   then
				   	(return (eq (sub-string 1 (- ?l2 1) ?uri2) ?uri1))
				   else
				   	(return FALSE)
				)
			   else
			   	(return FALSE)
			)
		)
	)
)



(deffunction is-prefix-of (?uri1 ?uri2)
	; The following two lines have been added because URI's contain <> chars.
   	(bind ?uri1 (sub-string 2 (- (length$ ?uri1) 1) ?uri1)) 
   	(bind ?uri2 (sub-string 2 (- (length$ ?uri2) 1) ?uri2)) 
	(bind ?pos (str-index ?uri1 ?uri2))
	(if (or
		(eq ?pos FALSE) 
		(<> ?pos 1)
	    )
	   then
	   	(return FALSE)
	   else
	   	(bind ?suffix (sub-string (+ 1 (length ?uri1)) (length ?uri2) ?uri2))
	   	(if (neq (str-index "/" ?suffix) FALSE)
	   	   then
	   	   	(return FALSE)
	   	   else
	   	   	(return TRUE)
	   	)
	)
)

(deffunction is-rdf-resource (?rid)
	(bind ?pos (str-index ":" ?rid))
	(if (neq ?pos FALSE)
	   then
	   	(bind ?ns (sub-string 1 (- ?pos 1) ?rid))
	   	(if (or
			(eq ?ns "rdf")
			(eq ?ns "rdfs")
			(eq ?ns "xsd"))
	   	   then
	   		(return TRUE)
	   	   else
	   		(return FALSE)
	   	)
	   else
	   	(return FALSE)
	)
)

(deffunction is-rdf-property (?property)
	(or (neq (str-index "rdf:" ?property) FALSE) (neq (str-index "rdfs:" ?property) FALSE))
)

;(deffunction is-rdf-resource (?rid)
;	(bind $?docs (send ?rid get-rdfs:isDefinedBy))
;	(if (> (length$ $?docs) 0)
;	   then
	   	;(if (or	(member$ (instance-address [rdf]) $?docs) (member$ (instance-address [rdfs]) $?docs))
;	   	(if (or	(member$ [rdf] $?docs) (member$ [rdfs] $?docs))
;	   	   then
;	   	   	TRUE
;	   	   else
;	   	   	FALSE
;		)
;	   else
;	   	FALSE
;	)
;)

(deffunction compatible-types (?type1 ?type2)
	(if (or
		(eq ?type2 FALSE)
		(eq ?type1 ?type2)
		(subclassp ?type1 ?type2)
		)
	   then
	   	(return TRUE)
	   else
	   	(return FALSE)
	)
)

(deffunction subclass-of-one (?class $?super-classes)
	(if (member$ ?class $?super-classes)
	   then
	   	(return TRUE)
	   else
	   	(bind ?end (length$ $?super-classes))
	   	(loop-for-count (?n 1 ?end)
	   	   do
	   	   	(if (subclassp ?class (nth$ ?n $?super-classes))
	   	   	   then
	   	   	   	(return TRUE)
	   	   	)
	   	)
	   	(return FALSE)
	)
)

(deffunction superclass-of-one (?class $?sub-classes)
	(if (member$ ?class $?sub-classes)
	   then
	   	(return TRUE)
	   else
	   	(bind ?end (length$ $?sub-classes))
	   	(loop-for-count (?n 1 ?end)
	   	   do
	   	   	(if (superclassp ?class (nth$ ?n $?sub-classes))
	   	   	   then
	   	   	   	(return TRUE)
	   	   	)
	   	)
	   	(return FALSE)
	)
)

(deffunction most-specific-classes ($?classes)
	(bind $?result (create$))
	(while (> (length$ $?classes) 0)
	   do
	   	(if (not 
	   		(or 
	   			(superclass-of-one (nth$ 1 $?classes) (rest$ $?classes))
	   			(superclass-of-one (nth$ 1 $?classes) $?result)
	   		))
	   	   then
	   	   	(bind $?result (create$ $?result (nth$ 1 $?classes)))
	   	)
	   	(bind $?classes (rest$ $?classes))
	)
	(return $?result)
)

(deffunction is-only-one-class ($?classes)
	(if (or
		(= (length$ $?classes) 1)
		(= (length$ (most-specific-classes $?classes)) 1))
	   then
	   	(return TRUE)
	   else
	   	(return FALSE)
	)
)

(deffunction get-only-one-class ($?classes)
	(if (= (length$ $?classes) 1)
	   then
	   	(return (nth$ 1 $?classes))
	   else
		(return (nth$ 1 (most-specific-classes $?classes)))
	)
)

(deffunction is-datatype (?data-type)
	;(bind ?data-type (instance-name-to-symbol ?data-type))
	(if (or
		(eq ?data-type [rdfs:Literal])
		(eq ?data-type [rdf:XMLLiteral])
		(eq (sub-string 1 4 ?data-type) "xsd:"))
	   then
	   	(return TRUE)
	   else
	   	(return FALSE)
	)
)

(deffunction not-datatype ($?data-types)
	(if (= (length$ $?data-types) 1)
	   then
	   	(if (is-datatype (nth$ 1 $?data-types))
	   	   then
	   	   	(return FALSE)
	   	   else
	   	   	(return TRUE)
	   	)
	   else
	   	(return TRUE)
	)
)

(deffunction find-correct-datatype (?data-type)
	(if (or
		(eq ?data-type xsd:integer)
		(eq ?data-type xsd:long)
		(eq ?data-type xsd:short)
		(eq ?data-type xsd:int)
		(eq ?data-type xsd:byte)
		)
	   then
	   	(return INTEGER)
	   else
	   	(if (or	
	   	   	(eq ?data-type xsd:float)
	   	   	(eq ?data-type xsd:double)
	   	   	(eq ?data-type xsd:decimal)
	   		)
	   	   then
	   	   	(return FLOAT)
	   	   else
	   	   	(if (eq ?data-type xsd:string)
	   	   	   then
	   	   	   	(return STRING)
	   	   	   else
	   	   	   	(if (or
			   	   	(eq ?data-type xsd:boolean)
			   	   	(eq ?data-type xsd:anyURI)
	   		   	   	)
	   		   	   then
	   		   	   	(return SYMBOL)
	   		   	   else
	   		   	   	(return LEXEME)
	   		   	)
	   		)
	   	)
	)
)

(deffunction check-data-type (?value ?obj-datatype $?data-types)
	(if (eq (length$ $?data-types) 1)
	   then
	   	(bind ?datatype (nth$ 1 $?data-types))
		(bind ?current-datatype (find-correct-datatype (instance-name-to-symbol ?obj-datatype)))
		(if (eq ?datatype ?current-datatype)
		   then
		   	(if (eq (type ?value) ?current-datatype)
		   	   then
		   		(return ?value)
		   	   else
		   	   	(return FALSE)
		   	)
		   else
		   	(return FALSE)
		)
	   else
	   	(return ?value)
	)
)

(deffunction transform-datatype (?value ?obj-datatype $?data-types)
	(if (and 
		(eq $?data-types (create$ INTEGER))
		(eq (type ?value) STRING)
		(eq ?obj-datatype nil))
	   then
		(return (string-to-field ?value))
	   else
	   	(if (and
	   		(eq $?data-types (create$ FLOAT))
	   		(eq (type ?value) STRING)
			(eq ?obj-datatype nil))
	   	   then
	   	   	(return (string-to-field ?value))
		   else
		   	(if (and
		   		(eq $?data-types (create$ STRING))
		   		(eq (type ?value) STRING)
				(eq ?obj-datatype nil))
		   	   then
		   	   	(return ?value)
		   	   else
		   	   	(if (and
	   				(eq $?data-types (create$ SYMBOL))
	   				(eq (type ?value) STRING)
					(eq ?obj-datatype nil))
		   	   	   then
		   	   	   	(return (sym-cat ?value))
		   	   	   else
		   	   	   	(if (and
		   	   	   		(eq (type ?value) STRING)
						(eq ?obj-datatype nil))
		   	   	   	   then
		   	   	   		(return ?value)
		   	   	   	   else
		   	   	   	   	(return (check-data-type ?value ?obj-datatype $?data-types))
		   	   	   	)
		   	   	)
		   	)
		)
	)
	;(return ?return-value)
)

(deffunction is-property (?type)
	(if (eq ?type [rdf:Property])
	   then
	   	(return TRUE)
	   else
	   	(bind ?type-s (instance-name-to-symbol ?type))
		(if (and
			(class-existp ?type-s)
			(funcall subclassp ?type-s rdf:Property))
		   then
		   	(return TRUE)
		   else
		   	(return FALSE)
		)
	)
)

;(deffunction is-datatype ($?data-types)
;	(if (eq (length$ $?data-types) 1)
;	   then
;	   	(bind ?data-type (nth$ 1 $?data-types))
;	   	(if (or
;	   		(eq ?data-type [rdfs:Literal])
;	   		(eq (send ?data-type get-rdfs:subClassOf) (create$ [rdfs:Literal])))
;	   	   then
;	   	   	(return TRUE)
;	   	   else
;	   	   	(return FALSE)
;	   	)
;	   else
;	   	(return FALSE)
;	)
;)

; I should keep the actual datatype information along with the value (inside the triple), 
; in order to do the inverese transformation
;(deffunction inverse-transform-datatype (?value)
;	(bind ?type (type ?value))
;	(if (eq ?type INTEGER)
;	   then
;	   	(return [xsd:integer])
;	   else
;	   	(if (eq ?type FLOAT)
;	   	   then
;	   	   	(return [xsd:float])
;	   	   else
;	   	   	(return [rdfs:Literal])
;	   	)
;	)
;)

;(deffunction slot-defined (?slot $?slot-defs)
;	(bind ?end (length$ $?slot-defs))
;	(loop-for-count (?n 1 ?end)
;	   do
;	   	(if (integerp (str-index ?slot (nth$ ?n $?slot-defs)))
;	   	(if (member$ ?slot (explode$ (nth$ ?n $?slot-defs)))
;	   	   then
;	   	   	(return TRUE)
;	   	)
;	)
;	(return FALSE)
;)

(deffunction slot-defined (?slot $?slot-defs)
	(bind ?pos (member$ ?slot $?slot-defs))
	(if (neq ?pos FALSE)
	   then
	   	(return TRUE)
	   else
	   	(return FALSE)
	)
)

(deffunction instances-to-symbols ($?instances)
	(bind $?result (create$))
	(bind ?end (length$ $?instances))
	(loop-for-count (?n 1 ?end)
	   do
	   	(bind $?result (create$ $?result (instance-name-to-symbol (nth$ ?n $?instances))))
	)
	(return $?result)
)

(deffunction symbols-to-instances ($?symbols)
	(bind $?result (create$))
	(bind ?end (length$ $?symbols))
	(loop-for-count (?n 1 ?end)
	   do
	   	(bind $?result (create$ $?result (symbol-to-instance-name (nth$ ?n $?symbols))))
	)
	(return $?result)
)


;(deffunction super-class-aliases ($?super-classes)
;	(bind $?result (create$))
;	(bind ?end (length$ $?super-classes))
;	(loop-for-count (?n 1 ?end)
;	   do
;	   	(bind $?result (create$ $?result (slot-default-value (nth$ ?n $?super-classes) aliases)))
;	)
;	$?result
;)



(deffunction exists-class-with-super-classes ($?classes)
	(bind ?end (length$ $?classes))
	(bind $?sub-classes (class-subclasses (nth$ 1 $?classes)))
	(loop-for-count (?n 2 ?end)
	   do
	   	(bind $?sub-classes (intersection$ (create$ (class-subclasses (nth$ ?n $?classes)) $$$ $?sub-classes)))
	)
	(bind ?end (length$ $?sub-classes))
	(if (= ?end 0)
	   then
	   	(return FALSE)
	   else
	   	(loop-for-count (?n 1 ?end)
	   	   do
	   	   	(if (same-set$ (create$ (class-superclasses  (nth$ ?n $?sub-classes)) $$$ $?classes))
	   	   	   then
	   	   	   	(return (nth$ ?n $?sub-classes))
	   	   	)
	   	)
	   	(return FALSE)
	)
)

(deffunction unique-instance-name (?namespace)
	(if (instance-existp (symbol-to-instance-name ?namespace))
   	   then
	   	(bind ?n 1)
	   	(bind ?new-namespace (symbol-to-instance-name (sym-cat ?namespace ?n)))
	   	(while (instance-existp ?new-namespace)
	   	   do
	   	   	(bind ?n (+ ?n 1))
	   	   	(bind ?new-namespace (symbol-to-instance-name (sym-cat ?namespace ?n)))
	   	)
	   	(return ?new-namespace)
	   else
	   	(return (symbol-to-instance-name ?namespace))
	)
)



; new - extension
(deffunction resource-existp (?resource)
	(if (symbolp ?resource)
	   then
		(return (instance-existp (symbol-to-instance-name ?resource)))
	   else
	   	(return FALSE)
	)
)

; new - extension
(deffunction resource-instance (?resource)
	(return (symbol-to-instance-name ?resource))
)

(deffunction resource-class (?resource)
	(return (class (resource-instance ?resource)))
)



; new - extension
;(deffunction aux-resource1 (?resource ?class1)
;	(bind ?class (instance-name-to-symbol ?class1))
;	(if (and
;		(class-existp ?class)
;		;(instance-existp ?class1)
;		(instance-existp ?resource)
;		(neq (class ?resource) candidate-object)
;		(neq (class ?resource) ?class)
;		)
;	   then
;	   	(return TRUE)
;	   else
;	   	(return FALSE)
;	)
;)


; new - extension
(deffunction aux-resource2 (?resource ?property1)
	(bind ?property (instance-name-to-symbol ?property1))
;	(if (instance-existp ?resource)
;	   then
	   	(bind ?class (class ?resource))
	   	(if (and
	   		(slot-existp ?class ?property inherit)
	   		(member$ INSTANCE-NAME (slot-types ?class ?property)))
	   	   then
	   	   	(return TRUE)
	   	   else
	   	   	(return FALSE)
	   	)
;	   else
;	   	(return FALSE)
;	)
)

;	(test (resource-existp ?resource))
;	(test (slot-existp (resource-class ?resource) ?property inherit))
;	(test (member$ INSTANCE-NAME (slot-types (resource-class ?resource) ?property)))



; new - extension
(deffunction aux-resource3 (?resource ?property1)
	(bind ?property (instance-name-to-symbol ?property1))
;	(if (instance-existp ?resource)
;	   then
	   	(bind ?class (class ?resource))
	   	(if (and
	   		(slot-existp ?class ?property inherit)
	   		(neq (create$ INSTANCE-NAME) (slot-types ?class ?property)))
	   		;(neq INSTANCE-NAME (nth$ 1 (slot-types ?class ?property))))
	   	   then
	   	   	(return TRUE)
	   	   else
	   	   	(return FALSE)
	   	)
;	   else
;	   	(return FALSE)
;	)
)

;	(test (resource-existp ?s))
;	(test (slot-existp (resource-class ?s) ?p inherit))
;	(test (neq (create$ INSTANCE-NAME) (slot-types (resource-class ?s) ?p)))



; new - extension
;(deffunction aux-resource4 (?resource)
;	(if (is-parsed-uri ?resource)
;	   then
;	   	(return FALSE)
;	   else
;	   	(if (is-uri ?resource)
;		(if (member$ ?resource ?*future_resource_instances*)
;	   	   then
;	   	   	(return FALSE)
;	   	   else
;	   	   	(if (instance-existp ?resource)
;	   	   	   then
;	   	   	   	(return FALSE)
;	   	   	   else
;	   	   	   	(return TRUE)
;	   	   	)
;	   	)
;	)
;)

;	(test (not (resource-existp ?o)))
;	(test (not (is-uri ?o)))
;	(test (not (is-parsed-uri ?o)))



; new - extension
(deffunction aux-resource5 (?resource ?property)
	;(if (instance-existp ?resource)
	;   then
	   	(bind ?class (class ?resource))
	   	(if (not (slot-existp ?class (instance-name-to-symbol ?property) inherit))
	   	   then
	   	   	(return TRUE)
	   	   else
	   	   	(return FALSE)
	   	)
	;   else
	;   	(return FALSE)
	;)
)

;	(test (resource-existp ?s))
;	(test (not (slot-existp (resource-class ?s) ?p inherit)))


(deffunction aux-resource6 ($?classes)
	(bind $?classes (instances-to-symbols $?classes))
	(if (and
		(= (length$ (exist-classes $?classes)) 0)
		(> (length$ (most-specific-classes $?classes)) 1))
	   then
	   	(return TRUE)
	   else
	   	(return FALSE)
	)
)
;	(test (= (length$ (exist-classes (instances-to-symbols $?domains))) 0)) ; All classes in range exist
;	(test (> (length$ (most-specific-classes (instances-to-symbols $?domains))) 1))  

;;; UPDATED - 25-03-2005
(deffunction aux-resource7 (?new-class $?classes)
	(bind $?classes (instances-to-symbols $?classes))
	(if  (or
		(and
			(= (length$ $?classes) 1)
			(not (class-existp (nth$ 1 $?classes)))
			(eq ?new-class (nth$ 1 $?classes)))
		(and
			(= (length$ (exist-classes $?classes)) 0)
			(is-only-one-class $?classes)
			(eq ?new-class (get-only-one-class $?classes))))
	   then
	   	(return TRUE)
	   else
	   	(return FALSE)
	)
)
;	(test (is-only-one-class (instances-to-symbols $?domains)))
;	(test (eq ?new-class (get-only-one-class (instances-to-symbols $?domains))))


(deffunction triple-retract (?fid)
	(retract ?fid)
	(bind ?*triple_counter* (- ?*triple_counter* 1))
)

(deffunction is-membership-property (?prop)
	(if (symbolp ?prop)
	   then
	   	(bind ?pos (str-index ":" ?prop))
	   	(if (neq ?pos FALSE)
	   	   then
	   	   	(bind ?ns (sub-string 1 (- ?pos 1) ?prop))
	   	   	(bind ?label (sub-string (+ ?pos 1) (length ?prop) ?prop))
	   	   	(bind ?doc (nth$ 1 (send (symbol-to-instance-name (sym-cat ?ns)) get-rdfs:isDefinedBy)))
	   	   	(if	(and
	   	   			(eq ?doc [rdf])
	   	   			(eq (sub-string 1 1 ?label) "_")
	   	   			(numberp (string-to-field (sub-string 2 (length ?label) ?label)))
	   	   		)
	   	   	   then
	   	   	   	(return TRUE)
	   	   	   else
	   	   	   	(return FALSE)
	   	   	)
	   	   else
	   	   	(return FALSE)
	   	)
	   else
	   	(return FALSE)
	)
)

(deffunction get-namespace (?class)
	(bind ?pos (str-index ":" ?class))
	(if (integerp ?pos)
	   then
	   	(return (sym-cat (sub-string 1 (- ?pos 1) ?class)))
	   else
	   	(return FALSE)
	)
)

(deffunction get-label (?class)
	(bind ?pos (str-index ":" ?class))
	(if (integerp ?pos)
	   then
	   	(return (sym-cat (sub-string (+ ?pos 1) (length ?class) ?class)))
	   else
	   	(return FALSE)
	)
)

(deffunction get-ns-uri (?ns)
	(if (not (instancep ?ns))
	   then
	   	(bind ?ns (symbol-to-instance-name ?ns))
	)
	(bind ?uri (send ?ns get-uri))
;	(if (eq ?uri "")
	(if (eq ?uri nil)
	   then
	   	(return (get-ns-uri (send ?ns get-rdfs:isDefinedBy)))
	   else
	   	(return ?uri)
	)
)

(deffunction is-system-class (?class)
	(if (instance-existp (symbol-to-instance-name ?class))
	   then
		(return (eq (send (symbol-to-instance-name ?class) source) system))
	   else
	   	(return FALSE)
	)
)

(deffunction file-exists (?file)
	(if (open ?file test "r")
	   then
	   	(close test)
	   	(return TRUE)
	   else
	   	(return FALSE)
	)
)

(deffunction file-empty (?file)
	(if (open ?file test "r")
	   then
	   	(bind ?first-line (readline test))
	   	(close test)
	   	(if (eq ?first-line EOF)
	   	   then
	   	   	(return TRUE)
	   	   else
	   	   	(return FALSE)
	   	)
	   else
	   	(return FALSE)
	)
)

;(deffunction arp (?address ?projectname)
;	(bind ?command (str-cat "cmd /c \"c:\\Program Files\\Libwww\\loadtofile.exe\" " ?address " -o " ?projectname ".rdf"))
;	(system ?command)
;	(bind ?command (str-cat "cmd /c java -cp \"c:\\Program Files\\arp2\\lib\\arp2.jar;c:\\Program Files\\arp2\\lib\\xercesImpl.jar;c:\\Program Files\\arp2\\lib\\icu4j.jar\" com.hp.hpl.jena.rdf.arp.NTriple " ?address " > " ?projectname ".n3"))
;	(system ?command)
;	(bind ?command (str-cat "cmd /c replace.exe " ?projectname ".n3"))
;	(system ?command)
;)

(deffunction parse-ntriples (?address ?projectname)
	(bind ?filename (str-cat ?projectname ".rdf"))
	(bind ?n3-filename (str-cat ?projectname ".n3"))
	(if (and 
		(or (not (file-exists ?filename)) (eq ?*rdf-caching* off))
		(not (member$ ?projectname ?*parsed-file*)))
	   then
		(verbose crlf "Remote RDF access at URL: " ?address " for namespace: " ?projectname crlf crlf)
		(open "arp.bat" mkbat "w")
		(printout mkbat "@echo off" crlf)
		(printout mkbat "@\".\\Libwww\\loadtofile.exe\" " ?address " -o " ?projectname ".rdf  < \".\\bin\\y\"" crlf)
		(printout mkbat "@set arp2=.\\ARP2-alpha-1\\lib" crlf)
		(printout mkbat "@set CLASSPATH=.;%arp2%\\arp2.jar;%arp2%\\xercesImpl.jar;%arp2%\\icu4j.jar" crlf)
		(verbose crlf "Parsing RDF file: " ?projectname ".rdf" crlf crlf)
		(printout mkbat "@java com.hp.hpl.jena.rdf.arp.NTriple " ?address " > " ?projectname ".n3" crlf)
		(printout mkbat "@\".\\bin\\replace.exe\" " ?projectname ".n3" crlf)
		(close mkbat)
		;(bind ?command (str-cat "cmd /c \".\\bin\\arp.bat\" " ?address " " ?projectname))
		;(system ?command)
		(system "cmd /c arp.bat")
		(remove "arp.bat")
		;(arp ?address ?projectname)
		(if (file-empty ?filename)
		   then
		   	(printout t "There is a problem with URL: " ?address crlf)
		   	(printout t "File: " ?filename " is empty!" crlf crlf)
		   	(remove ?filename)
		   	(remove ?n3-filename)
		   else
			(if (file-empty ?n3-filename)
			   then
			   	(printout t "There is a problem with URL: " ?address crlf)
				(printout t "File: " ?filename " is probably not an RDF file!" crlf)
			   	(remove ?filename)
			   	(remove ?n3-filename)
			)
		)
		(bind ?*parsed-file* (create$ ?*parsed-file* ?projectname))
		;(bind ?*fetched_url* (create$ ?*fetched_url* ?address))
	)
)

;(deffunction arp-only (?projectname)
;	;(printout t "In arp-only:" crlf)
;	;(bind ?commandv "java -version")
;	;(system ?commandv)
;	;(bind ?command (str-cat "java -cp \"c:\\Program Files\\arp2\\lib\\arp2.jar;c:\\Program Files\\arp2\\lib\\xercesImpl.jar;c:\\Program Files\\arp2\\lib\\icu4j.jar\" com.hp.hpl.jena.rdf.arp.NTriple " ?projectname ".rdf" " > " ?projectname ".n3"))
;	(bind ?command (str-cat "cmd /c java com.hp.hpl.jena.rdf.arp.NTriple " ?projectname ".rdf" " > " ?projectname ".n3"))
;	;(printout t "command1: " ?command crlf)
;	(system ?command)
;	(bind ?command (str-cat "cmd /c replace.exe " ?projectname ".n3"))
;	;(printout t "command2: " ?command crlf)
;	(system ?command)
;)

(deffunction local-parse-ntriples (?projectname)
	(bind ?filename (str-cat ?projectname ".rdf"))
	;(arp-only ?projectname)
	(open "arp-only.bat" mkbat "w")
	(printout mkbat "@echo off" crlf)
	(printout mkbat "@set arp2=.\\ARP2-alpha-1\\lib" crlf)
	(printout mkbat "@set CLASSPATH=.;%arp2%\\arp2.jar;%arp2%\\xercesImpl.jar;%arp2%\\icu4j.jar" crlf)
	(verbose crlf "Parsing RDF file: " ?projectname ".rdf" crlf crlf)
	(printout mkbat "@java com.hp.hpl.jena.rdf.arp.NTriple " ?projectname ".rdf"  " > " ?projectname ".n3" crlf)
	(printout mkbat "@\".\\bin\\replace.exe\" " ?projectname ".n3" crlf)
	(close mkbat)
	(system "cmd /c arp-only.bat")
	(remove "arp-only.bat")
	;(bind ?command (str-cat "cmd /c \".\\bin\\arp-only.bat\" " ?projectname))
	;(system ?command)
)


(deffunction shallow-copy (?old-instance ?new-instance)
	(bind ?old-class (class ?old-instance))
	;(bind $?slots (delete-member$ (class-slots ?old-class inherit) class-refs aliases))
	(bind $?slots (class-slots ?old-class inherit))
	(while (> (length$ $?slots) 0)
	   do
	   	(bind ?slot (nth$ 1 $?slots))
	   	(bind ?get-command (sym-cat get- ?slot))
	   	(bind ?put-command (sym-cat put- ?slot))
	   	(bind ?value (funcall send ?old-instance ?get-command))
	   	(funcall send ?new-instance ?put-command ?value)
	   	(bind $?slots (rest$ $?slots))
	)
	(return TRUE)
)

(deffunction discover-disk-letter ()
	(system "cd > dir.txt")
	(open "dir.txt" file "r")
	(bind ?path (readline file))
	(bind ?disk-letter (sub-string 1 1 ?path))
	(close file)
	(remove "dir.txt")
	(return  ?disk-letter)
)

(deffunction namespace-to-entity (?uri)
	(if (integerp (str-index : ?uri))
	   then
	   	(bind ?uri (str-cat "&" (str-replace ?uri ";" :)))
	)
	(return ?uri)
)
