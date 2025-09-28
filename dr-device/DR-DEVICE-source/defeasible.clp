(defglobal 
	?*attribute_modifications* = 0
	?*defeasible_classes* = (create$)
)

(defclass DEFEASIBLE-OBJECT
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
	(slot positive  (default 0))
	(slot negative  (default 0))
	; new
	(multislot positive-derivator (type ?VARIABLE)) ; PROOF
	(multislot negative-derivator (type ?VARIABLE)) ; PROOF
;	(slot positive-derivator (type ?SYMBOL)) ; PROOF
;	(slot negative-derivator (type ?SYMBOL)) ; PROOF
	(multislot positive-support (type SYMBOL) (default (create$)))
	(multislot negative-support (type SYMBOL) (default (create$)))
	(multislot positive-overruled (type SYMBOL) (default (create$)))
	(multislot negative-overruled (type SYMBOL) (default (create$)))
	(multislot positive-defeated (type SYMBOL) (default (create$)))
	(multislot negative-defeated (type SYMBOL) (default (create$)))
	(slot proof (type SYMBOL))  ; PROOF
)

(defclass DEFEASIBLE-CONTROL
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
)

(defmessage-handler DEFEASIBLE-OBJECT put-positive after (?x)
	(bind ?*attribute_modifications* (+ ?*attribute_modifications* 1))
)

(defmessage-handler DEFEASIBLE-OBJECT put-negative after (?x)
	(bind ?*attribute_modifications* (+ ?*attribute_modifications* 1))
)

(defmessage-handler DEFEASIBLE-OBJECT put-positive-overruled after ($?x)
	(bind ?*attribute_modifications* (+ ?*attribute_modifications* 1))
	;(refresh-agenda)
)

(defmessage-handler DEFEASIBLE-OBJECT put-negative-overruled after ($?x)
	(bind ?*attribute_modifications* (+ ?*attribute_modifications* 1))
	;(refresh-agenda)
)

(defmessage-handler DEFEASIBLE-OBJECT put-positive-defeated after ($?x)
	(bind ?*attribute_modifications* (+ ?*attribute_modifications* 1))
	;(refresh-agenda)
)

(defmessage-handler DEFEASIBLE-OBJECT put-negative-defeated after ($?x)
	(bind ?*attribute_modifications* (+ ?*attribute_modifications* 1))
	;(refresh-agenda)
)

(defclass defeasible-logic-rule
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
	(slot rule-name (type SYMBOL))
	(slot original-rule (type STRING))
	(multislot condition-classes (type SYMBOL))
	(slot conclusion-class (type SYMBOL))
	(slot negated (type SYMBOL))
	;(multislot conclusion-pattern)
	;(slot defeasible-stratum (type INTEGER) (default 0))
	(multislot superior (type SYMBOL))
	(slot deductive-rule (type SYMBOL))
	(slot overruled-rule (type SYMBOL))
	(slot system (type SYMBOL) (allowed-symbols yes no))
)

(defclass supportive-rule
	(is-a defeasible-logic-rule)
	(slot support-rule (type SYMBOL))
	(slot defeasibly-rule (type SYMBOL))
	(slot defeated-rule (type SYMBOL))
)

(defclass defeater
	(is-a defeasible-logic-rule)
)

(defclass strict-rule
	(is-a supportive-rule)
	(slot definitely-rule (type SYMBOL))
)

(defclass defeasible-rule
	(is-a supportive-rule)
)

(defclass competing-rules
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
	(multislot original-rules (type INSTANCE-NAME))
	(multislot extra-rules (type INSTANCE-NAME))
	(multislot unique-slots (type SYMBOL))
)

(defclass extra-competing-rule
	(is-a USER)
	(role concrete)
	(pattern-match reactive)
	;(slot rule-name (type SYMBOL))
	(slot competing-rule-construct (type INSTANCE-NAME))
	(slot rule-type (type SYMBOL))
	(slot first-rule (type SYMBOL))
	(slot second-rule (type SYMBOL))
	(multislot first-rule-condition (type STRING))
	(multislot first-rule-condition-conclusion-vars (type STRING))
	(multislot second-rule-condition (type STRING))
	(multislot second-rule-condition-conclusion-vars (type STRING))
	(multislot second-rule-conclusion (type STRING))
)
