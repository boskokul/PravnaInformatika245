(defglobal 
	?*verbose_status* = off
	?*truth_maintenance* = on
	?*untranslated_rules* = 0
)

(deftemplate pending-rule 
	(slot production-rule (type STRING)) 
	(slot delete-production-rule (type STRING)) 
	(multislot non-existent-classes (type SYMBOL))
)

(defclass r-device-rule
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
	;(slot rule-name (type SYMBOL))
	(slot pos-name (type SYMBOL))
	(multislot depends-on (type SYMBOL))
	(slot implies (type SYMBOL))
)

(defclass tm-r-device-rule
	(is-a r-device-rule)
	(slot del-name (type SYMBOL))
)

(defclass ntm-r-device-rule
	(is-a r-device-rule)
)

(defclass gen-deductive-rule
	(is-a r-device-rule)
	(slot deductive-rule (type STRING))
	(slot production-rule (type STRING))
	(slot derived-class (type SYMBOL))
)

(defclass deductive-rule
	(is-a tm-r-device-rule gen-deductive-rule)
)

(defclass ntm-deductive-rule
	(is-a ntm-r-device-rule gen-deductive-rule)
)

(defclass derived-attribute-rule
	(is-a tm-r-device-rule)
	(slot derived-attribute-rule (type STRING))
)

(defclass aggregate-attribute-rule
	(is-a tm-r-device-rule)
	(slot aggregate-attribute-rule (type STRING))
)

(defclass meta-class
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
	(multislot class-refs (type SYMBOL))
	(multislot aliases (type SYMBOL))
)

(defclass derived-class-inst
	(is-a meta-class)
	;(slot name (type SYMBOL))
	(slot stratum (type INTEGER) (default 1))
	(multislot deductive-rules (type INSTANCE-NAME))
)

(defclass namespace
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
	;(slot name (type SYMBOL))
	(slot address (type STRING))
	(multislot classes (type SYMBOL))
)
