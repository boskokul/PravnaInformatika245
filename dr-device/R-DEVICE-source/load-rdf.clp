
;;; Updated - 25-03-2005
;;; To consider slot-values
(deffunction resource-make-instance (?class ?resource $?types-and-slot-values)
	; new
	;(printout t "********* HERE *************** ?resource = " ?resource crlf)
	(bind ?pos (member$ $$$ $?types-and-slot-values))
	(if (neq ?pos FALSE)
	   then
	   	(bind $?types (subseq$ $?types-and-slot-values 1 (- ?pos 1)))
		(bind $?slot-values (subseq$ $?types-and-slot-values (+ ?pos 1) (length$ $?types-and-slot-values)))
	   else
	   	(bind $?types $?types-and-slot-values)
	   	(bind $?slot-values (create$))
	)
	;(printout t "+++++++++++++" "$?types: " $?types crlf)
	;(printout t "+++++++++++++" "$?slot-values: " $?slot-values crlf)
	; new
	(bind $?slot-value-string (create$))
	(while (> (length$ $?slot-values) 0)
	   do
	   	;(printout t "$?slot-values: " $?slot-values crlf)
	   	(bind $?slot-values (rest$ $?slot-values))
	   	(bind ?slot-name (nth$ 1 $?slot-values))
	   	(bind ?pos (member$ $slot $?slot-values))
	   	(if (neq ?pos FALSE)
	   	   then
	   		(bind $?values (subseq$ $?slot-values 2 (- ?pos 1)))
	   	   	;(printout t "+++++++++++++ " "$?values: " $?values crlf)
	   		(bind $?slot-values (subseq$ $?slot-values ?pos (length$ $?slot-values)))
	   	   else
	   	   	;(printout t "Here!" crlf)
	   	   	(bind $?values (subseq$ $?slot-values 2 (length$ $?slot-values)))
	   	   	;(printout t "+++++++++++++ " "$?values: " $?values crlf)
	   		(bind $?slot-values (create$))
	   	)
	   	(bind $?slot-value-string (create$ "(" ?slot-name (parenthesis $?values) ")" $?slot-value-string))
	)
	;(printout t "+++++++++++++ " "$?slot-value-string: " $?slot-value-string crlf crlf)
	(bind ?instance-create-string (str-cat$ (create$
		"(" make-instance ?resource of ?class
			"(" rdf:type (symbols-to-instances $?types) ")"
			"(" uri (instance-name-to-symbol ?resource) ")"
			$?slot-value-string
		")"
	)))
	;(printout t "?instance-create-string: " ?instance-create-string crlf crlf)
	(eval ?instance-create-string)
	; old
	;(make-instance ?resource of ?class
	;	(rdf:type (symbols-to-instances $?types))
	;	;(uri (str-cat (instance-name-to-symbol ?resource)))
	;	(uri (instance-name-to-symbol ?resource))
	;)
	(return ?resource)
)

(deffunction find-all-super-properties (?property)
	(bind $?result (send (symbol-to-instance-name ?property) get-rdfs:subPropertyOf))
	(bind $?list $?result)
	(while (> (length$ $?list) 0)
	   do
;	   	(bind $?temp (send (symbol-to-instance-name (nth$ 1 $?list)) get-rdfs:subPropertyOf))
	   	(bind $?temp (send (nth$ 1 $?list) get-rdfs:subPropertyOf))
	   	(bind $?result (create$ $?result $?temp))
	   	(bind $?list (create$ $?temp (rest$ $?list)))
	)
	(instances-to-symbols $?result)
)

(deffunction create-aliases (?slot $?aliases)
	(bind $?result (create$))
	(bind ?end (length$ $?aliases))
	(loop-for-count (?n 1 ?end)
	   do
	   	(bind $?result 
	   		(create$ 
	   			$?result 
	   			(nth$ ?n $?aliases) ?slot 
	   			(create-aliases ?slot (find-all-super-properties (nth$ ?n $?aliases)))
	   		)
	   	)
	)
	$?result
)



;	(bind ?xml-schema-url "<http://www.w3.org/2001/XMLSchema#")
;	(if (eq (str-index ?xml-schema-url ?datatype) 1)
;	   then
;	   	(bind ?dt (sub-string (+ (length ?xml-schema-url) 1) (- (length ?datatype) 1) ?datatype))
;	   	(bind ?datatype-instance (create-datatype-instance ?dt))

(deffunction create-datatype-instance (?datatype)
	(bind ?datatype-label (sym-cat "xsd:" ?datatype))
	(bind ?datatype-instance (symbol-to-instance-name ?datatype-label))
	(if (not (instance-existp ?datatype-instance))
	   then
	   	(bind ?mk-inst-string (str-cat$ (create$
		   	"(" make-instance ?datatype-instance of rdfs:Datatype  
				"(" rdfs:isDefinedBy [xsd] ")"
				"(" rdf:type [rdfs:Datatype] ")"
				"(" rdfs:label ?datatype-label ")"
				"(" rdfs:subClassOf [rdfs:Literal]")"
			")"
		)))
		(eval ?mk-inst-string)
	)
	(return ?datatype-instance)
)

(deffunction future-resource (?node)
	; This works only for empty nodes of the ARP parser with the format _:jARPXX
	(bind ?node-number (string-to-field (sub-string 7 (str-length ?node) ?node)))
	(bind ?hash-bucket (mod ?node-number ?*HashBuckets*))
	(bind ?future_resource_instances-var (sym-cat "?*future_resource_instances" ?hash-bucket *))
	(bind ?future_resource_addresses-var (sym-cat "?*future_resource_addresses" ?hash-bucket *))
	(bind ?pos (eval (str-cat$ (create$ "(" member$ ?node ?future_resource_addresses-var ")" ))))
	(if (neq ?pos FALSE)
	   then
	   	(return (eval (str-cat$ (create$ "(" nth$ ?pos ?future_resource_instances-var ")" ))))
	   else
		(bind ?future-inst (symbol-to-instance-name (gensym*)))
		(bind ?future_resource_instances-var (sym-cat "?*future_resource_instances" ?hash-bucket *))
		(bind ?future_resource_addresses-var (sym-cat "?*future_resource_addresses" ?hash-bucket *))
		(eval (str-cat$ (create$ "(" bind ?future_resource_addresses-var "(" create$ ?node ?future_resource_addresses-var ")" ")" )))
		(eval (str-cat$ (create$ "(" bind ?future_resource_instances-var "(" create$ ?future-inst ?future_resource_instances-var ")" ")" )))
		(return ?future-inst)
	)
)

(deffunction import-resource (?resource)
	(if (is-uri ?resource)
	   then
	   	(bind ?counter 1)
	   	(bind ?list-length (length$ ?*namespace-uris-labels*))
	   	(bind ?l2 (str-length ?resource))
		(bind ?resource (sub-string 2 (- ?l2 1) ?resource)) 
		(bind ?l2 (- ?l2 2))
		(while (<= ?counter ?list-length)
		   do
	   		(bind ?uri1 (nth$ ?counter ?*namespace-uris-labels*))
	   		(bind ?l1 (str-length ?uri1))
	   	   	;(bind ?uri1 (sub-string 2 (- ?l1 1) ?uri1)) 
	   	   	;(bind ?l1 (- ?l1 2))
	   		(bind ?uri-alias (nth$ (+ ?counter 1) ?*namespace-uris-labels*))
	   		(bind ?pos (str-index ?uri1 ?resource))
			(if (eq ?pos 1)
			   then
	   	   		(if (or (eq (sub-string (+ ?l1 1) (+ ?l1 1) ?resource) "#")
	   	   			(eq (sub-string (+ ?l1 1) (+ ?l1 1) ?resource) "/"))
	   	   		   then
	   	   			(bind ?label (sub-string (+ ?l1 2) ?l2 ?resource))
	   	   		   else
	   	   		   	;(bind ?label (sub-string (+ ?l1 1) ?l2 ?resource))
	   	   		   	(bind ?label FALSE)
	   	   		)
	   	   		(if (and
	   	   			(eq ?uri-alias xsd)
	   	   			(neq ?label ""))
	   	   		   then
					(create-datatype-instance ?label)
				)
	   	   		(if (eq ?label "")
	   	   		   then
	   	   		   	(return (symbol-to-instance-name ?uri-alias))
	   	   		   else
	   	   		   	(if (neq ?label FALSE)
	   	   		   	   then
	   	   		   		(bind ?new-resource (symbol-to-instance-name (sym-cat ?uri-alias : ?label)))
						(return ?new-resource)
	   	   		   	)
	   	   		)
	   	   	)
	   	   	(bind ?counter (+ ?counter 2))
		)
;		(bind ?future-resource (find-future-resource ?resource))
;		(if (neq ?future-resource FALSE)
;		   then
;		   	(return ?future-resource)
;		   else
		      ;	(printout t "===> Not found resource (before): " ?resource crlf)
		      	;(bind ?l1 (str-length ?resource))
		      	;(bind ?resource1 (sub-string 2 (- ?l1 1) ?resource)) 
		      	;(bind ?l1 (- ?l1 2))
		      	(bind ?resource (sym-cat (strip-last ?resource)))
		      	(return (symbol-to-instance-name ?resource))
	; OPT  		(bind $?existing-resources 
	;  OPT 			(find-instance ((?rid rdfs:Resource)) (eq ?rid:uri ?resource)))
	   			;(find-instance ((?rid rdfs:Resource)) (and (neq ?rid:uri nil) (not (is-future-resource ?rid)) (eq ?rid:uri ?resource))))
	   			;(find-instance ((?rid rdfs:Resource)) (and (neq ?rid:uri nil) (similar-uri ?rid:uri ?resource1 ?l1))))
	; OPT  		(if (= (length$ $?existing-resources) 0)
	;  OPT 	   	   then
		      		;(printout t "===> Still not found resource (in): " ?resource crlf)
;				(return (future-resource ?resource))
	; OPT  	   	   else
	;  OPT 	   		(return (nth$ 1 $?existing-resources))
	;  OPT 		)
;		)
	   else
	   ; Treatment of empty nodes
	   	(if (is-empty-node ?resource)
	   	   then
	   	   	(return (future-resource ?resource))
	   	   else
	   		(return ?resource)
	   	)
	)
)

(deffunction load-header (?filename)
	(bind ?status off)
	(bind ?total-line "")
	(if (open ?filename rdf "r")
	   then
	   	(bind ?line (readline rdf))
	   	(bind ?total-line (str-cat ?total-line ?line))
	   	(bind ?pos1 (str-index "<rdf:RDF" ?line))
	   	(bind ?pos2 (str-index ">" ?line))
	   	(while (or (neq ?status on) (eq ?pos2 FALSE))
	   	   do
	   		(if (and (eq ?status off) (neq ?pos1 FALSE))
	   		   then
	   		   	(bind ?status on)
	   		)
	   		(bind ?line (readline rdf))
	   		(bind ?total-line (str-cat ?total-line ?line))
	   		(bind ?pos1 (str-index "<rdf:RDF" ?line))
	   		(bind ?pos2 (str-index ">" ?line))
	   	)
	   	(close rdf)
	)
	(return ?total-line)
)


(deffunction scan_namespaces (?line)
	(bind $?namespaces (create$))
   	(bind ?pos (str-index "xmlns:" ?line))
   	(while (neq ?pos FALSE)
   	   do
   	   	(bind ?line (sub-string (+ ?pos 6) (length ?line) ?line))
   	   	(bind ?pos (str-index "=" ?line))
   	   	(bind ?namespace (sym-cat (r-trim (sub-string 1 (- ?pos 1) ?line))));px owl
   	   	(bind ?line (sub-string (+ ?pos 1) (length ?line) ?line));the address
   	   	(bind ?pos (str-index "\"" ?line))
   	   	(bind ?line (sub-string (+ ?pos 1) (length ?line) ?line));the address
   	   	(bind ?pos (str-index "\"" ?line))   	   	
   	   	(if (and (neq ?pos FALSE) (neq (sub-string (- ?pos 1) (- ?pos 1) ?line) ";"))
   	   	   then
   	   		(bind ?uri (sub-string 1 (- ?pos 1) ?line))
   	   	   else
   	   	   	(bind ?pos (str-index ";" ?line))
  	   	   	(bind ?entity (sym-cat (sub-string 2 (- ?pos 1) ?line)))
  	   	   	;(bind ?entity (str-cat (sub-string 2 (- ?pos 1) ?line)))
   	   	   	(bind ?uri (nth$ (+ (member$ ?entity ?*entities*) 1) ?*entities*))
   	   	)
   	   	(bind ?address ?uri)
   	   	;(bind ?uri (sym-cat (strip-last (sym-cat < ?uri >))))  ; URI is a symbol!
   	   	(bind ?uri (sym-cat (strip-last ?uri)))  ; URI is a symbol!
   	   	;(bind ?uri  (strip-last ?uri))
    	   	;(bind ?str-uri  (str-cat "\"" ?uri "\""))
  	   	(bind ?fi-string (str-cat$ (create$ 
   	   		"(" find-instance "(" "(" "?rid" rdfs:Resource ")" ")"  "(" eq ?uri "?rid:uri" ")" ")"
   	   	)))
   	   	;(printout t "?fi-string: " ?fi-string crlf)
   	   	(bind $?existing-resources (eval ?fi-string))
	   	(if (= (length$ $?existing-resources) 0)
		   then
		   	(if (instance-existp (symbol-to-instance-name ?namespace))
		   	   then
			   	(bind ?namespace-id (unique-instance-name ?namespace))
			   	(bind ?mk-inst-string (str-cat$ (create$
					"(" make-instance ?namespace-id of rdfs:Resource
						"(" rdfs:isDefinedBy ?namespace-id ")"
						"(" rdf:type [rdfs:Resource] ")"
						"(" uri ?uri ")"
						"(" source system ")"
						;(rdfs:comment "Imported by X-DEVICE.")
				   		"(" rdfs:label ?namespace ")"
					")"
				)))
				(eval ?mk-inst-string)
			   else
			   	(bind ?mk-inst-string (str-cat$ (create$
					"(" make-instance (symbol-to-instance-name ?namespace) of rdfs:Resource
						"(" rdfs:isDefinedBy (symbol-to-instance-name ?namespace) ")"
						"(" rdf:type [rdfs:Resource] ")"
						"(" uri ?uri ")"
						"(" source system ")"
						;(rdfs:comment "Imported by X-DEVICE.")
				   		"(" rdfs:label ?namespace ")"
					")"
				)))
				(eval ?mk-inst-string)
			)
			(bind ?*namespace-uris-labels* (create$ ?uri ?namespace ?*namespace-uris-labels*))
			(if (eq ?*namespace-hunting* on)
			   then
				(parse-ntriples ?address ?namespace)
			)
			(bind $?namespaces (create$ $?namespaces ?namespace))
		   else
		   	(if (not (instance-existp (symbol-to-instance-name ?namespace)))
		   	   then
			   	(bind ?mk-inst-string (str-cat$ (create$
		   	   		"(" make-instance (symbol-to-instance-name ?namespace) of rdfs:Resource
			   	   		"(" rdfs:isDefinedBy (nth$ 1 $?existing-resources) ")"
						"(" source system ")"
			   		")"
				)))
				(eval ?mk-inst-string)
			)
		)
		(bind ?pos (str-index "xmlns:" ?line))
	)
	(return $?namespaces)
)

(deffunction scan_base (?namespace ?line)
   	(bind ?pos (str-index "xml:base" ?line))
   	(if (neq ?pos FALSE)
   	   then
   	   	(bind ?line (sub-string (+ ?pos 10) (length ?line) ?line)) ; count equal sign and quotation mark
   	   	(bind ?pos (str-index "\"" ?line))
   	   	(if (neq ?pos FALSE)
   	   	   then
   	   		(bind ?uri (sub-string 1 (- ?pos 1) ?line))
   	   	   else
   	   	   	(bind ?pos (str-index ";" ?line))
   	   	   	(bind ?entity (sym-cat (sub-string 2 (- ?pos 1) ?line)))
   	   	   	(bind ?uri (nth$ (+ (member$ ?entity ?*entities*) 1) ?*entities*))
   	   	)
   	   	(bind ?address ?uri)
   	   	;(bind ?uri (sym-cat < ?uri >))  ; URI is a symbol!
   	   	(bind ?uri (sym-cat ?uri))  ; URI is a symbol!
   	   	;(bind ?uri  (strip-last ?uri))
    	   	;(bind ?search-uri  (str-cat "\"" ?uri "\""))
  	   	(bind ?fi-string (str-cat$ (create$ 
   	   		"(" find-instance "(" "(" "?rid" rdfs:Resource ")" ")"  "(" eq ?uri "?rid:uri" ")" ")"
   	   	)))
   	   	(bind $?existing-resources (eval ?fi-string))
	   	(if (= (length$ $?existing-resources) 0)
		   then
		   	(if (instance-existp (symbol-to-instance-name ?namespace))
		   	   then
			   	(bind ?namespace-id (unique-instance-name ?namespace))
			   	(bind ?mk-inst-string (str-cat$ (create$
					"(" make-instance ?namespace-id of rdfs:Resource
						"(" rdfs:isDefinedBy ?namespace-id ")"
						"(" rdf:type [rdfs:Resource] ")"
						"(" uri ?uri ")"
						"(" source system ")"
						;(rdfs:comment "Imported by X-DEVICE.")
				   		"(" rdfs:label ?namespace ")"
					")"
				)))
				(eval ?mk-inst-string)
			   else
			   	(bind ?mk-inst-string (str-cat$ (create$
					"(" make-instance (symbol-to-instance-name ?namespace) of rdfs:Resource
						"(" rdfs:isDefinedBy (symbol-to-instance-name ?namespace) ")"
						"(" rdf:type [rdfs:Resource] ")"
						"(" uri ?uri ")"
						"(" source system ")"
						;(rdfs:comment "Imported by X-DEVICE.")
				   		"(" rdfs:label ?namespace ")"
					")"
				)))
				(eval ?mk-inst-string)
			)
			(bind ?*namespace-uris-labels* (create$ ?uri ?namespace ?*namespace-uris-labels*))
			(if (eq ?*namespace-hunting* on)
			   then
				(parse-ntriples ?address ?namespace)
			)
			(return FALSE)
		   else
		   	(if (not (instance-existp (symbol-to-instance-name ?namespace)))
		   	   then
			   	(bind ?mk-inst-string (str-cat$ (create$
		   	   		"(" make-instance (symbol-to-instance-name ?namespace) of rdfs:Resource
			   	   		"(" rdfs:isDefinedBy (nth$ 1 $?existing-resources) ")"
						"(" source system ")"
			   		")"
				)))
				(eval ?mk-inst-string)
			)
			(return TRUE)
		)
	   else
	   	(return nil)
	)
)

(deffunction scan_entities (?line)
	(bind $?tokens (explode$ ?line))
	(while (> (length$ $?tokens) 0)
	   do
		(if (eq (nth$ 1 $?tokens) <!ENTITY)
		   then
		   	(bind ?entity (nth$ 2 $?tokens))
		   	(bind ?address (nth$ 3 $?tokens))
		   	(if (eq (sub-string 1 1 ?address) "'")
		   	   then
		   	   	(bind ?address (sub-string 2 (- (length ?address) 2) ?address))
		   	)
		   	(bind ?*entities* (create$ ?*entities* ?entity (strip-last2 ?address)))
		   	(bind $?tokens (rest$ (rest$ (rest$ $?tokens))))
		   else
		   	(bind $?tokens (rest$ $?tokens))
		)
	)
)


(deffunction create-namespaces (?projectname)
	(bind $?new-namespaces (create$))
	(bind ?base-namespace-exist FALSE)
	(bind ?rdf-filename (str-cat ?projectname ".rdf"))
	(bind ?header (load-header ?rdf-filename))
   	(scan_entities ?header)
	;(if (eq ?*namespace-hunting* on)
	;   then
		(bind $?new-namespaces (create$ $?new-namespaces (scan_namespaces ?header)))
	;   else
	;   	(bind $?new-namespaces (create$ (sym-cat ?projectname)))
	;)
	(bind ?flag (scan_base (sym-cat ?projectname) ?header))
	(if (neq ?flag nil)
	   then
		(bind ?base-namespace-exist ?flag)
	)
	(if (eq ?*namespace-hunting* on)
	   then
		(bind $?copy-new-namespaces $?new-namespaces)
		(while (> (length$ $?copy-new-namespaces) 0)
		   do
		   	(bind $?new-namespaces (create$ (create-namespaces (nth$ 1 $?copy-new-namespaces)) $?new-namespaces))
		   	(bind $?copy-new-namespaces (rest$ $?copy-new-namespaces))
		)
	)
	(if (not ?base-namespace-exist)
	   then
	   	(bind $?new-namespaces (create$ $?new-namespaces (sym-cat ?projectname)))
	)
	(return $?new-namespaces)
)

(deffunction import-datatype (?value ?datatype)
	(bind ?xml-schema-url "<http://www.w3.org/2001/XMLSchema#")
	(if (eq (str-index ?xml-schema-url ?datatype) 1)
	   then
	   	(bind ?dt (sub-string (+ (length ?xml-schema-url) 1) (- (length ?datatype) 1) ?datatype))
	   	(bind ?datatype-instance (create-datatype-instance ?dt))
		(if (or
			(eq ?dt "integer")
			(eq ?dt "long")
			(eq ?dt "short")
			(eq ?dt "int")
			(eq ?dt "byte")
			; More datatypes are needed
		    )
	   	   then
	  		(bind ?return-value (string-to-field ?value))
	   	   else
	   	   	(if (or 
	   	   		(eq ?dt "float")
	   	   		(eq ?dt "double")
	   	   		(eq ?dt "decimal")
	   	   	    )
	   	   	   then
	   	   	   	(bind ?return-value (string-to-field ?value))
	   		   else
	   		   	(if (eq ?dt "string")
	   		   	   then
	   		   	   	(bind ?return-value ?value)
	   		   	   else
	   		   	   	(if (or
	   		   	   		(eq ?dt "boolean")
	   		   	   		(eq ?dt "anyURI")
	   		   	   	    )
	   		   	   	   then
	   		   	   	   	(bind ?return-value (sym-cat ?value))
	   		   	   	   else
	   		   	   	   	(bind ?return-value ?value)
	   		   	   	)
	   		   	)
	   		)
	 	)
	   else
	   	(if (eq ?datatype <http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral>)
	   	   then
	   	   	(bind ?return-value ?value)
	 		(bind ?datatype-instance [rdf:XMLLiteral])
	 	   else
	 	   	(bind ?return-value ?value)
	 		(bind ?datatype-instance nil)
	 	)
	)
	(return (create$ ?return-value ?datatype-instance))
)


(deffunction insert-triple (?triple-string ?namespace)
	;(bind ?triple-string (str-replace ?triple-string "%3A%3A" "::"))
	;(bind $?triple (triple-explode$ ?triple-string)) ; here!!
	(bind $?triple (explode$ ?triple-string)) ; here!!
	(bind ?object-datatype nil)
	;(pprint-list $?triple)
   	(if (or
   		(and 
   			(= (length$ $?triple) 4)
   			(eq (nth$ 4 $?triple) .))
		(and
   			(= (length$ $?triple) 5)
   			(eq (sub-string 1 1 (nth$ 4 $?triple)) "@")
     			(eq (nth$ 5 $?triple) .)))
     	   then
		(bind ?subject (nth$ 1 $?triple))
		(bind ?predicate (nth$ 2 $?triple))
   		(bind ?object (nth$ 3 $?triple))
   	   else
   	   	(if	(and
   	   			(= (length$ $?triple) 6)
   	   			(or
   	   				(eq (nth$ 4 $?triple) ^^)
   	   				(and
   	   					(eq (sub-string 1 1 (nth$ 4 $?triple)) "@")
   	   					(eq (sub-string (- (length$ (nth$ 4 $?triple)) 1) (length$ (nth$ 4 $?triple)) (nth$ 4 $?triple)) "^^")
   	   				)
   	   			)
				(eq (nth$ 6 $?triple) .)
   			)
   		   then
   		   	(bind ?subject (nth$ 1 $?triple))
   		   	(bind ?predicate (nth$ 2 $?triple))
   		   	(bind $?dt-result (import-datatype (nth$ 3 $?triple) (nth$ 5 $?triple)))
   			(bind ?object (nth$ 1 $?dt-result))
   			(bind ?object-datatype (nth$ 2 $?dt-result))
   		   else
   		   	(verbose "Cannot insert: " ?triple-string crlf)
   		   	(return)
   		)
   	)
   	(bind ?subject (import-resource ?subject))
   	(bind ?predicate (import-resource ?predicate))
   	; The following is true only for my specific example, needs special treatment
   	; in the future
   	(if (eq ?object <online:>)
   	    then
   	    	(bind ?object (send (symbol-to-instance-name ?namespace) get-uri))
   	    else
   		(bind ?object (import-resource ?object))
   	)
	(if (assert 
		(triple 
			(subject ?subject) 
			(predicate ?predicate) 
			(object ?object) 
			(object-datatype ?object-datatype)))
	   then
	   	(debug "Inserting: " ?triple-string crlf)
		(bind ?*triple_counter* (+ ?*triple_counter* 1))
		; New - to avoid joins of triples in triple-transformation.clp
		(collect-useful-info ?subject ?predicate ?object)
	)
)


(deffunction n3-open (?namespace)
	(bind ?n3-filename (str-cat ?namespace ".n3"))
	(bind ?nt-filename (str-cat ?namespace ".nt"))
	(if (eq ?*open_n3_file* nil)    ; PLAI
	   then
		(if (or 
			(open ?n3-filename n3 "r") (open ?nt-filename n3 "r")
		    )
		   then
		   	(bind ?*open_n3_file* ?namespace)    ; PLAI
			(return TRUE)
	  	   else
	  	 	(bind ?rdf-filename (str-cat ?namespace ".rdf"))
	  	 	(if (open ?rdf-filename rdf "r")
	  	 	   then
	  	 	   	(close rdf)
	  	 	   	(local-parse-ntriples ?namespace)
	  	 	   	(open ?n3-filename n3 "r")
		   		(bind ?*open_n3_file* ?namespace)    ; PLAI
	  	 	   	(return TRUE)
	  	 	   else
	  	 	   	(return FALSE)
	  	 	)
		)
	   else
	   	(return TRUE)
	)
)



(deffunction load-namespace (?namespace)
	(verbose  ?namespace " ")
	(if (n3-open ?namespace)
	   then
		(bind ?triple-string (readline n3))
		;(printout t crlf "=====> First triple: ========>" crlf)
		;(printout t ?triple-string crlf crlf)
		; Added for testing
		;(bind ?line-counter 1)   ; PLAI
		(while (and
			(neq ?triple-string EOF)
			(or (= ?*rdf_triple_limit* 0) (<= ?*triple_counter* ?*rdf_triple_limit*))   ; PLAI
			)
		   do
			(bind ?first-letter (sub-string 1 1 ?triple-string))
			(if (or (eq ?first-letter "<") (eq ?first-letter "_"))
			   then
				(insert-triple ?triple-string ?namespace)
			)
		   	(bind ?triple-string (readline n3))
		   	; Added for testing (6 lines)
	   		;(bind ?line-counter (+ ?line-counter 1))
;	   		(if (> ?line-counter ?*rdf_triple_limit*)
;	   		   then
;	   		   	(bind ?line-counter 1)
;	   		   	(partial-import)
;	   		)
		)
		(if (eq ?triple-string EOF)
		   then
			(close n3)
			(bind ?*open_n3_file* nil)
		)
		; Added for testing
;	   	(partial-import)
	)
)


(deffunction load-namespaces ($?namespaces)
	(verbose  "Loading namespaces: ")
	(bind ?end (length $?namespaces))
	(loop-for-count (?n 1 ?end)
	   do
	   	(load-namespace (nth$ ?n $?namespaces))
	)
	(verbose  crlf)
)



(deffunction load-rdf (?projectname ?address)
	(bind ?*parsed-file* (create$))
	(if (neq ?address local)
	   then
	   	(parse-ntriples ?address (sym-cat ?projectname))
	)
	(bind $?new-namespaces (remove-duplicates$ (create-namespaces ?projectname)))
;	(bind $?namespace-uris-labels (create$))
;   	(do-for-all-instances
;		((?rid rdfs:Resource)) 
;		(eq ?rid (nth$ 1 ?rid:rdfs:isDefinedBy))
;   		(bind $?namespace-uris-labels (create$ ?rid:uri (nth$ 1 ?rid:rdfs:label) $?namespace-uris-labels))
;	)
	(if (eq ?*namespace-hunting* on)
	   then
		(load-namespaces $?new-namespaces)
	   else
	   	(load-namespaces (create$ (sym-cat ?projectname)))
	)
;	(nullify-temp-hash-buckets)
	TRUE
)


	   	   	   	

(deffunction save-rdf (?projectname)
	(system (str-cat "mkdir " ?projectname))
	(save (str-cat ".\\" ?projectname "\\construct.clp"))
	(bind ?inst-file (str-cat ".\\" ?projectname "\\instances.ins"))
	(save-instances ?inst-file)
)

(deffunction restore-rdf (?projectname)
	(load* (str-cat ".\\" ?projectname "\\construct.clp"))
	(load-instances (str-cat ".\\" ?projectname "\\instances.ins"))
)
