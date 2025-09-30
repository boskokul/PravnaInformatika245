(defrule translate-derived-attribute-rules
	(goal translate-derived-attribute-rules)
	?rule-idx <- (derivedattrule ?rule-string)
  =>
  	(bind $?rule-name-and-string (find-rule-name ?rule-string))
  	(bind ?rule-name (nth$ 1 $?rule-name-and-string))
  	(bind ?rule-string1 (nth$ 2 $?rule-name-and-string))
  	(bind $?classes (build-dependency-network ?rule-string1))
	(translate-derived-attribute-rule ?rule-string1 ?rule-name $?classes)
	(retract ?rule-idx)
	(bind ?*untranslated_rules* (- ?*untranslated_rules* 1))
)

(defrule translate-ntm-derived-attribute-rules
	(goal translate-derived-attribute-rules)
	?rule-idx <- (ntm-derivedattrule ?rule-string)
  =>
  	(bind $?rule-name-and-string (find-rule-name ?rule-string))
  	(bind ?rule-name (nth$ 1 $?rule-name-and-string))
  	(bind ?rule-string1 (nth$ 2 $?rule-name-and-string))
  	(bind $?classes (build-dependency-network ?rule-string1))
	(translate-ntm-derived-attribute-rule ?rule-string1 ?rule-name $?classes)
	(retract ?rule-idx)
	(bind ?*untranslated_rules* (- ?*untranslated_rules* 1))
)

(defrule translate-aggregate-attribute-rules
	(goal translate-aggregate-attribute-rules)
	?rule-idx <- (aggregateattrule ?rule-string)
  =>
  	(bind $?rule-name-and-string (find-rule-name ?rule-string))
  	(bind ?rule-name (nth$ 1 $?rule-name-and-string))
  	(bind ?rule-string1 (nth$ 2 $?rule-name-and-string))
  	(bind $?classes (build-dependency-network ?rule-string1))
	(translate-aggregate-attribute-rule ?rule-string1 ?rule-name $?classes)
	(retract ?rule-idx)
	(bind ?*untranslated_rules* (- ?*untranslated_rules* 1))
)

(defrule translate-ntm-aggregate-attribute-rules
	(goal translate-aggregate-attribute-rules)
	?rule-idx <- (ntm-aggregateattrule ?rule-string)
  =>
  	(bind $?rule-name-and-string (find-rule-name ?rule-string))
  	(bind ?rule-name (nth$ 1 $?rule-name-and-string))
  	(bind ?rule-string1 (nth$ 2 $?rule-name-and-string))
  	(bind $?classes (build-dependency-network ?rule-string1))
	;(printout t "rule: " ?rule-string1 crlf)
	;(printout t "?*untranslated_rules* (before) = " ?*untranslated_rules* crlf)
	(translate-ntm-aggregate-attribute-rule ?rule-string1 ?rule-name $?classes)
	(retract ?rule-idx)
	(bind ?*untranslated_rules* (- ?*untranslated_rules* 1))
	;(printout t "?*untranslated_rules* (after) = " ?*untranslated_rules* crlf)
)

(defrule translate-2nd-order-rules
	(goal translate-2nd-order-rules)
	?rule-idx <- (2nd-order-rule ?rule-name ?rule-string $?results-2nd-order)
  =>
	; Rulename not catered for
	(translate-2nd-order-rule ?rule-name ?rule-string $?results-2nd-order)
	(retract ?rule-idx)
	(bind ?*untranslated_rules* (- ?*untranslated_rules* 1))
)

(defrule translate-2nd-order-ntm-rules
	(goal translate-2nd-order-rules)
	?rule-idx <- (2nd-order-ntm-rule ?rule-name ?rule-string $?results-2nd-order)
  =>
	; Rulename not catered for
	(translate-2nd-order-ntm-rule ?rule-name ?rule-string $?results-2nd-order)
	;(printout t "Rule translate-2nd-order-ntm-rules: ?rule: " ?rule-name " " ?rule-string " " $?results-2nd-order crlf)
	(retract ?rule-idx)
	(bind ?*untranslated_rules* (- ?*untranslated_rules* 1))
)

(defrule pre-compile-deductive-rules
	(goal pre-compile-deductive-rules)
	?rule-idx <- (deductiverule ?rule-string)
  =>
	(pre-compile-deductive-rule ?rule-string)
	(retract ?rule-idx)
	(bind ?*untranslated_rules* (- ?*untranslated_rules* 1))
)

(defrule pre-compile-ntm-deductive-rules
	(goal pre-compile-deductive-rules)
	?rule-idx <- (ntm-deductiverule ?rule-string)
  =>
	(pre-compile-ntm-deductive-rule ?rule-string)
	(retract ?rule-idx)
	(bind ?*untranslated_rules* (- ?*untranslated_rules* 1))
)

(defrule translate-deductive-rules
	(goal translate-deductive-rules)
	(object (is-a deductive-rule) (name ?rule-name) (deductive-rule ?rule-string) (production-rule ""))
	; This is disabled to allow several recursive rules
	;?rule-idx <- (deductive-rule (rule-name ?rule-name) (deductive-rule ?rule-string) (production-rule "") (depends-on $? ?class $?))
	;(not (deductive-rule (rule-name ~?rule-name) (production-rule "") (implies ?class)))
  =>
	(translate-deductive-rule ?rule-name ?rule-string)
)

(defrule translate-ntm-deductive-rules
	(goal translate-deductive-rules)
	(object (is-a ntm-deductive-rule) (name ?rule-name) (deductive-rule ?rule-string) (production-rule ""))
	; This is disabled to allow several recursive rules
	; Needs better treatment in the future!
	;?rule-idx <- (ntm-deductive-rule (rule-name ?rule-name) (deductive-rule ?rule-string) (production-rule "") (depends-on $? ?class $?))
	;(not (ntm-deductive-rule (rule-name ~?rule-name) (production-rule "") (implies ?class)))
  =>
	(translate-ntm-deductive-rule ?rule-name ?rule-string)
)

(defrule insert-pending-rules
	(goal insert-pending-rules)
	?rule-idx <- (pending-rule (production-rule ?pr) (delete-production-rule ?dpr) (non-existent-classes $?classes))
  =>
 	(insert-pending-rule ?pr ?dpr $?classes)
	(retract ?rule-idx)
)

(defrule calc-stratum-for-all
	(goal calc-stratum-for-all)
	(object (is-a deductive-rule) (production-rule ?rule-condition&~"") (derived-class ?class&~nil))
  =>
 	(calc-stratum-afterwards ?rule-condition ?class)
)

