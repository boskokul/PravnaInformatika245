(defrule property-inheritance-domains
;	(goal property-inheritance)
	?prop <- (object (is-a rdf:Property) (name ?property) (rdfs:subPropertyOf $? ?super-property $?) (rdfs:domain $?domains))
	(object (is-a rdf:Property) (name ?super-property) (rdfs:domain $? ?domain $?))
	(test (not (member$ ?domain $?domains)))
  =>
  	(debug  "Inheriting domain " ?domain " to property " ?property " from super-property " ?super-property crlf)
  	(slot-insert$ ?prop rdfs:domain 1 ?domain)
  	(bind ?*cycle-change-flag* true)
)

(defrule property-inheritance-ranges
;	(goal property-inheritance)
	?prop <- (object (is-a rdf:Property) (name ?property) (rdfs:subPropertyOf $? ?super-property $?) (rdfs:range $?ranges))
	(object (is-a rdf:Property) (name ?super-property) (rdfs:range $? ?range $?))
	(test (not (member$ ?range $?ranges)))
  =>
  	(debug  "Inheriting range " ?range " to property " ?property " from super-property " ?super-property crlf)
  	(slot-insert$ ?prop rdfs:range 1 ?range)
  	(bind ?*cycle-change-flag* true)
)
