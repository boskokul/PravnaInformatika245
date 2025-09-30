
(deffunction is-multislot (?class ?slot)
	;(printout t "is-multislot: ?class: " ?class crlf)
	;(printout t "is-multislot: ?slot: " ?slot crlf)
	(bind $?sub-classes (create$ ?class (class-subclasses ?class inherit)))
	(while (> (length$ $?sub-classes) 0)
	   do
	   	(bind ?current-class (nth$ 1 $?sub-classes))
   	   	(if (slot-existp ?current-class ?slot inherit)
   	   	   then
			(return (eq (nth$ 1 (slot-facets ?current-class ?slot)) MLT))
		)
		(bind $?sub-classes (rest$ $?sub-classes))
	)
	(printout t "ERROR! Slot " ?slot " is not present in either " ?class " or any of its subclasses!" crlf)
	(return FALSE)
)

(deffunction get-all-derived-classes ()
;	(bind $?classes (remove-duplicates$ (class-subclasses DERIVED-CLASS inherit)))
	(remove-duplicates$ (class-subclasses DERIVED-CLASS inherit))
;	(bind $?result (create$))
;	(while (> (length$ $?classes) 0)
;	   do
;		(bind $?result (create$ $?result (nth$ 1 $?classes)))
;	   	(bind $?classes (create$ (class-subclasses (nth$ 1 $?classes)) (rest$ $?classes)))
;	)
;	$?result
)

(deffunction get-super-classes ($?superclasses)
	(if (> (length$ $?superclasses) 0)
	   then
		(return $?superclasses)
	   else
	   	(return (create$ rdfs:Resource))
	)
)

(deffunction foreign-classes (?class1 ?class2)
	(and (neq ?class1 ?class2)
		(subclassp ?class1 ?class2)
		(subclassp ?class2 ?class1)
	)
)

(deffunction is-subsumed (?class $?classes)
	(bind ?end (length$ $?classes))
	(loop-for-count (?n 1 ?end)
	   do
		(if (subclassp ?class (nth$ ?n $?classes))
		   then
		   	(return TRUE)
		)
	)
	(return FALSE)
)

(deffunction remove-subsumed-classes ($?classes)
	(bind $?result (create$))
	(bind ?end (length$ $?classes))
	(loop-for-count (?n 1 ?end)
	   do
	   	;(bind ?next-class (nth$ ?n $?classes))
	   	;(bind $?rest-classes (subseq$ $?classes (+ ?n 1) ?end))
	   	;(bind ?RESULT (is-subsumed ?next-class $?rest-classes))
	   	;(if (not ?RESULT)
	   	(if (and
	   		(not (is-subsumed (nth$ ?n $?classes) (subseq$ $?classes (+ ?n 1) ?end)))
	   		(not (is-subsumed (nth$ ?n $?classes) $?result)))
	   	   then
	   	   	(bind $?result (create$ $?result (nth$ ?n $?classes)))
	   	)
	)
	$?result
)

(deffunction is-superclass (?class $?classes)
	(bind ?end (length$ $?classes))
	(loop-for-count (?n 1 ?end)
	   do
		(if (superclassp ?class (nth$ ?n $?classes))
		   then
			(return TRUE)
		)
	)
	(return FALSE)
)

(deffunction remove-superclasses ($?classes)
	(bind $?result (create$))
	(bind ?end (length$ $?classes))
	(loop-for-count (?n 1 ?end)
	   do
		(if (and (not (is-superclass (nth$ ?n $?classes) (subseq$ $?classes (+ ?n 1) ?end)))
			 (not (is-superclass (nth$ ?n $?classes) $?result)))
		   then
			(bind $?result (create$ $?result (nth$ ?n $?classes)))
		)
	)
	$?result
)

(deffunction no-of-derived-objects ()
	(bind $?classes (get-all-derived-classes))
	(bind ?result 0)
	(while (> (length$ $?classes) 0)
	   do
	   	(bind ?result (+ ?result (length$ (find-all-instances ((?x (nth$ 1 $?classes))) TRUE))))
	   	(bind $?classes (rest$ $?classes))
	)
	?result
)
	   
(deffunction exists-class (?class)
	(or
		(member$ ?class (get-deftemplate-list))
		(class-existp ?class)
	)
)

(deffunction exist-classes ($?classes)
	(bind $?result (create$))
	(bind ?end (length$ $?classes))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (not (exists-class (nth$ ?n $?classes)))
	   	   then
	   	   	(bind $?result (create$ $?result (nth$ ?n $?classes)))
	   	)
	)
	$?result
)

(deffunction classes-existp ($?classes)
	(bind ?end (length$ $?classes))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (not (class-existp (nth$ ?n $?classes)))
	   	   then
	   	   	(return FALSE)
	   	)
	)
	(return TRUE)
)

(deffunction get-template-specific-facts (?template $?facts)
	(bind $?result (create$))
	(bind ?end (length$ $?facts))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (eq (fact-relation (fact-index (nth$ ?n $?facts))) ?template)
	   	   then
	   	   	(bind $?result (create$ $?result (fact-index (nth$ ?n $?facts))))
	   	)
	)
	$?result
)

(deffunction get-slot-value-specific-facts (?slot ?value $?facts)
	(bind $?result (create$))
	(bind ?end (length$ $?facts))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (or 
	   		(eq (fact-slot-value (nth$ ?n $?facts) ?slot) ?value)
	   		(and 
	   			(eq (type (fact-slot-value (nth$ ?n $?facts) ?slot)) MULTIFIELD)
	   			(member$ ?value (fact-slot-value (nth$ ?n $?facts) ?slot))))
	   	   then
	   	   	(bind $?result (create$ $?result (nth$ ?n $?facts)))
	   	)
	)
	$?result
)


(deffunction get-specific-facts (?template ?slot ?value)
	;(bind $?all-facts (get-fact-list))
	;(bind $?temp-relative-facts (get-template-specific-facts ?template (get-fact-list)))
	(get-slot-value-specific-facts ?slot ?value (get-template-specific-facts ?template (get-fact-list)))
)


(deffunction check-non-existent-classes ($?cond-element)
)

(deffunction check-non-existent-classes-one ($?cond-element)
   	(if (or 
   		(eq (nth$ 2 $?cond-element) not)
   		(eq (nth$ 2 $?cond-element) or)
   		(eq (nth$ 2 $?cond-element) and))
   	   then
   	   	(check-non-existent-classes (subseq$ $?cond-element 3 (- (length$ $?cond-element) 1)))
   	   else
		(if (eq (nth$ 2 $?cond-element) <-)
		   then
			(if (eq (nth$ 4 $?cond-element) object)
		   	   then
		   		(bind ?class (nth$ (+ (member$ is-a $?cond-element) 1) $?cond-element))
		   	   else
		   	   	(bind ?class (nth$ 4 $?cond-element))
		   	)
		   else
			(if (eq (nth$ 2 $?cond-element) object)
		   	   then
		   		(bind ?class (nth$ (+ (member$ is-a $?cond-element) 1) $?cond-element))
		   	   else
		   	   	(bind ?class (nth$ 2 $?cond-element))
		   	)
		)
      		(if (not (exists-class ?class))
      	   	   then
      	   	   	?class
      	   	   else
      	   	   	(create$)
      	   	)
      	)
)


(deffunction check-non-existent-classes ($?cond-element)
	(bind $?result (create$))
	(while (> (length$ $?cond-element) 0)
	   do
   	   	(bind ?p2 (get-token $?cond-element))
		(bind $?result (create$ $?result (check-non-existent-classes-one (subseq$ $?cond-element 1 ?p2))))
		(bind $?cond-element (subseq$ $?cond-element (+ ?p2 1) (length$ $?cond-element)))
	)
	$?result
)

(deffunction is_derived (?class)
	(bind ?x (symbol-to-instance-name (sym-cat ?class -derived-class)))
	(and (instance-existp ?x) (eq (class ?x) derived-class-inst))
)

(deffunction is_namespace (?namespace)
	(bind ?x (symbol-to-instance-name ?namespace))
	(and (instance-existp ?x) (eq (class ?x) namespace))
)

(deffunction class-instance-name (?class)
	(if (is_derived ?class)
	   then
	   	(return (symbol-to-instance-name (sym-cat ?class -derived-class)))
	   else
	   	(return (symbol-to-instance-name ?class))
	)
)

(deffunction get-type-of (?class ?slot)
	;(bind $?class-refs (slot-default-value ?class class-refs))
	(bind $?class-refs (send (class-instance-name ?class) get-class-refs))
	(bind ?pos (member$ ?slot $?class-refs))
	(if (numberp ?pos)
	   then
		(nth$ (+ ?pos 1) $?class-refs)
	   else
	   	FALSE
	)
)

(deffunction all-instance-existp ($?list)
	(bind ?end (length$ $?list))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (not (instance-existp (nth$ ?n $?list)))
	   	   then
	   	   	(return FALSE)
	   	)
	)
	TRUE
)

(deffunction user-slots (?class)
	;(bind $?candidate-slots (delete-member$ (class-slots ?class inherit) counter derivators class-refs namespace source uri aliases))
	(bind $?candidate-slots (delete-member$ (class-slots ?class inherit) counter derivators namespace source uri))
	;(if (slot-existp ?class aliases inherit)
	(if (slot-existp (class (class-instance-name ?class)) aliases inherit)
	   then
	   	;(bind $?aliased-slots (slot-default-value ?class aliases))
	   	(bind $?aliased-slots (send (class-instance-name ?class) get-aliases))
		(bind $?result (create$))
		(bind ?end (length$ $?candidate-slots))
		(loop-for-count (?n 1 ?end)
		   do
		   	(if (not (odd-member$ (nth$ ?n $?candidate-slots) $?aliased-slots))
		   	   then
		   	   	(bind $?result (create$ $?result (nth$ ?n $?candidate-slots)))
		   	)
		)
		(return $?result)
	   else
	   	(return $?candidate-slots)
	)
)

(deffunction aliased-slot (?class ?slot)
	;(if (and (class-existp ?class) (slot-existp ?class aliases inherit))
	(if (and (class-existp ?class) (instance-existp (class-instance-name ?class)) (slot-existp (class (class-instance-name ?class)) aliases inherit))
	   then
	   	;(bind $?aliased-slots (slot-default-value ?class aliases))
	   	(bind $?aliased-slots (send (class-instance-name ?class) get-aliases))
		(if (odd-member$ ?slot $?aliased-slots)
		   then
		   	(return TRUE)
		   else
		   	(return FALSE)
		)
	   else
	   	(return FALSE)
	)
)

(deffunction normal-slot (?class ?slot)
	;(bind $?all-slots (delete-member$ (class-slots ?class inherit) counter derivators class-refs namespace source uri aliases))
	(bind $?all-slots (delete-member$ (class-slots ?class inherit) counter derivators namespace source uri))
	(if (not (member$ ?slot $?all-slots))
	   then
	   	(return FALSE)
	   else
		;(if (slot-existp ?class aliases inherit)
		(if (slot-existp (class (class-instance-name ?class)) aliases inherit)
		   then
		   	;(bind $?aliased-slots (slot-default-value ?class aliases))
		   	(bind $?aliased-slots (send (class-instance-name ?class) get-aliases))
			(if (odd-member$ ?slot $?aliased-slots)
			   then
		   		(return FALSE)
			   else
		   		(return TRUE)
			)
		   else
	   		(return TRUE)
		)
	)
)

(deffunction aliases-of (?class ?alias)
	;(bind $?aliased-slots (slot-default-value ?class aliases))
	(bind $?aliased-slots (send (class-instance-name ?class) get-aliases))
	(associate-pairs ?alias $?aliased-slots)
)

;; Needs to be expanded in the future - to cater for more cases
;; e.g. when NUMBER and INTEGER fuse to NUMBER
(deffunction fuse-types ($?types)
	(if (member$ (sym-cat "?VARIABLE") $?types)
	   then
	   	(return (create$ (sym-cat "?VARIABLE")))
	   else
	   	(return $?types)
	)
)

(deffunction needs-redefinition (?class $?slot-defs)
	(bind ?CHANGE FALSE)
	(bind $?result (create$))
	(bind $?copy-slot-defs $?slot-defs)
	(while (> (length$ $?copy-slot-defs) 0)
	   do
	   	(bind ?p2 (get-token $?copy-slot-defs))
	   	(bind $?first-slot-def (subseq$ $?copy-slot-defs 1 ?p2))
	   	(bind ?slot (nth$ 3 $?first-slot-def))
	   	(bind $?new-slot-types (subseq$ $?first-slot-def 6 (- (length$ $?first-slot-def) 2)))
	   	(bind $?old-slot-types (slot-types ?class ?slot))
		(if (or
			(and (eq $?new-slot-types (create$ (sym-cat "?VARIABLE"))) (same-set$ (create$ $?old-slot-types $$$ FLOAT INTEGER SYMBOL STRING EXTERNAL-ADDRESS FACT-ADDRESS INSTANCE-ADDRESS INSTANCE-NAME)))
			(subsetp $?new-slot-types $?old-slot-types))
		   then
			(bind $?result (create$ $?result "(" (nth$ 2 $?first-slot-def) ?slot "(" type $?old-slot-types ")" ")"))
		   else
		   	(bind $?result (create$ $?result "(" (nth$ 2 $?first-slot-def) ?slot "(" type (fuse-types (remove-duplicates$ (create$ $?new-slot-types $?old-slot-types))) ")" ")"))
		   	(bind ?CHANGE TRUE)
		)
	   	(bind $?copy-slot-defs (subseq$ $?copy-slot-defs (+ ?p2 1) (length$ $?copy-slot-defs)))
	)
	(if (eq ?CHANGE FALSE)
	   then
		(return FALSE)
	   else
	   	(return $?result)
	)
)

(deffunction backup-rules ($?rules)
	(bind ?end (length$ $?rules))
	(bind ?backup-file "DRB.clp")
	;(assert (rule-backup-file ?backup-file))
	(my-dribble-on ?backup-file)
	(loop-for-count (?n 1 ?end)
	   do
	   	;(bind ?rule-fact (nth$ ?n $?rules))
	   	(bind ?rule-oid (nth$ ?n $?rules))
	   	;(bind ?rule (fact-slot-value ?rule-fact name))
	   	(bind ?rule (send ?rule-oid get-pos-name))
	   	;(bind ?del-rule (fact-slot-value ?rule-fact del-name))
	   	(if (slot-existp (class ?rule-oid) del-name inherit)
	   	   then
	   		(bind ?del-rule (send ?rule-oid get-del-name))
	   	   else
	   	   	(bind ?del-rule nil)
	   	)
	   	(if (and (neq ?rule nil) (member$ ?rule (get-defrule-list)))
	   	   then
	   		(ppdefrule ?rule)
	   	)
	   	(if (and (neq ?del-rule nil) (member$ ?del-rule (get-defrule-list)))
	   	   then
	   		(ppdefrule ?del-rule)
	   	)
	)
	(my-dribble-off)
)

(deffunction undefine-rules-aux ($?rules)
	(bind ?end (length$ $?rules))
	(loop-for-count (?n 1 ?end)
	   do
	   	;(bind ?rule-fact (nth$ ?n $?rules))
	   	(bind ?rule-oid (nth$ ?n $?rules))
	   	;(facts ?rule-fact ?rule-fact)
	   	;(bind ?rule (fact-slot-value ?rule-fact name))
	   	(bind ?rule (send ?rule-oid get-pos-name))
	   	;(bind ?del-rule (fact-slot-value ?rule-fact del-name))
	   	(if (slot-existp (class ?rule-oid) del-name inherit)
	   	   then
	   		(bind ?del-rule (send ?rule-oid get-del-name))
	   	   else
	   	   	(bind ?del-rule nil)
	   	)
	   	(if (and (neq ?rule nil) (member$ ?rule (get-defrule-list)))
	   	   then
	   		(undefrule ?rule)
	   	)
	   	(if (and (neq ?del-rule nil) (member$ ?del-rule (get-defrule-list)))
	   	   then
	   		(undefrule ?del-rule)
	   	)
	)
)

(deffunction undefine-class-rules (?class)
	(bind $?rules (remove-duplicates$ (create$ 
		(find-all-instances ((?x deductive-rule)) (eq ?x:implies ?class))
		(find-all-instances ((?x derived-attribute-rule )) (eq ?x:implies ?class))
		(find-all-instances ((?x aggregate-attribute-rule )) (eq ?x:implies ?class))
		(find-all-instances ((?x deductive-rule )) (eq ?x:depends-on ?class))
		(find-all-instances ((?x derived-attribute-rule )) (eq ?x:depends-on ?class))
		(find-all-instances ((?x aggregate-attribute-rule )) (eq ?x:depends-on ?class))
		(find-all-instances ((?x ntm-deductive-rule)) (eq ?x:implies ?class))
		(find-all-instances ((?x ntm-deductive-rule )) (eq ?x:depends-on ?class))
	)))
	(backup-rules $?rules)
	(undefine-rules-aux $?rules)
)

; The following "empty" declarations serve the purpose 
; of forward declaration for functions defined in RDF\import.clp
(deffunction backup-class (?class)
)

(deffunction undefine-classes ()
)

(deffunction collect-defaults (?slot $?super-classes)
	(bind $?result (create$))
	(bind ?end (length$ $?super-classes))
	(loop-for-count (?n 1 ?end)
	   do
	   	;(bind $?result (create$ $?result (slot-default-value (nth$ ?n $?super-classes) ?slot)))
	   	(bind ?superclass (nth$ ?n $?super-classes))
	   	(if (and (neq ?superclass RDF-CLASS) (neq ?superclass meta-class) (neq ?superclass DERIVED-CLASS))
	   	   then
	   		(bind $?result (create$ $?result (funcall send (class-instance-name ?superclass) (sym-cat get- ?slot))))
	   	)
	)
	$?result
)

(deffunction restore-class (?class)
;	(bind ?class-factid (nth$ 1 (get-specific-facts redefined-class name ?class)))
	(bind ?class-factid (nth$ 1 ?*redefined_class_facts*))
;(facts (fact-index ?class-factid))
	(bind $?super-classes (fact-slot-value ?class-factid isa-slot))
	(bind $?slot-defs (fact-slot-value ?class-factid slot-definitions))
	(bind $?class-refs (fact-slot-value ?class-factid class-refs-defaults))
	(bind $?aliases (fact-slot-value ?class-factid aliases-defaults))
  	(debug  "Restoring class: " ?class crlf)
	(bind ?class-definition-string (str-cat$ 
		"(" defclass ?class
			"(" is-a 
				(if (> (length$ $?super-classes) 0)
				   then
				   	$?super-classes
				   else
				   	rdfs:Resource
				)
			")"
			$?slot-defs
			;"(" multislot class-refs 
			;	"(" source composite ")"
			;	"(" default (unique-pairs (create$ $?class-refs (collect-defaults class-refs $?super-classes))) ")"
			;")"
			;"(" multislot aliases 
			;	"(" source composite ")"
			;	"(" default (unique-pairs (create$ $?aliases (collect-defaults aliases $?super-classes))) ")"
			;")"
		")"
	))
	(my-build ?class-definition-string)
	(modify-instance (class-instance-name ?class) 
		(class-refs (unique-pairs (create$ $?class-refs (collect-defaults class-refs $?super-classes))))
		(aliases (unique-pairs (create$ $?aliases (collect-defaults aliases $?super-classes))))
	)
	(if (is_derived ?class)
	   then
		(save-compiled-derived-class ?class-definition-string)
	)
	(retract ?class-factid)
	(bind ?*redefined_class_facts* (rest$ ?*redefined_class_facts*))
	(bind ?backup-instances-file-factid (nth$ 1 (get-template-specific-facts backup-instances (get-fact-list))))
	(if (neq ?backup-instances-file-factid nil)
	   then
		(bind ?instances-backup-file (nth$ 1 (fact-slot-value ?backup-instances-file-factid implied)))
  		(restore-instances ?instances-backup-file)
  		(retract ?backup-instances-file-factid)
  		(remove ?instances-backup-file)
	)
  	;(bload-instances ?instances-backup-file)
)



(deffunction re-define-class (?class $?slot-defs)
	(backup-class ?class)   ; this asserts redefined-class fact
;	(bind ?factid (nth$ 1 (get-specific-facts redefined-class name ?class)))
	(bind ?factid (nth$ 1 ?*redefined_class_facts*))
	;(facts ?factid ?factid)
	(bind ?new-factid (modify ?factid (slot-definitions $?slot-defs)))
	(bind ?*redefined_class_facts* (create$ ?new-factid (rest$ ?*redefined_class_facts*)))
	;(bind ?factid (nth$ 1 (get-specific-facts redefined-class name ?class)))
	;(facts ?factid ?factid)
	(undefine-class-rules ?class)
	(undefine-classes)  ; this needs class-to-undefine fact
	;(load* (str-cat ?*RDF_PATH* "restore-classes.clp"))
	;(watch facts)
	;(watch rules)
	;(watch activations)
	(restore-class ?class)
	;(unwatch all)
	;(bind ?backup-file-factid (nth$ 1 (get-template-specific-facts rule-backup-file (get-fact-list))))
	;(facts ?backup-file-factid ?backup-file-factid)
	;(bind ?rule-backup-file (str-cat (nth$ 1 (fact-slot-value ?backup-file-factid implied)) 1))
	;(bind ?rule-backup-file (nth$ 1 (fact-slot-value ?backup-file-factid implied)))
	;(retract ?backup-file-factid)
	;(load* ?rule-backup-file)
	(load* "DRB.clp")
	;(remove ?rule-backup-file)
	(remove "DRB.clp")
)


;(deffunction candidate-instance-existp (?inst)
;	(and
;		(instance-existp ?inst)
;		(eq (class ?inst) candidate-object)
;	)
;)

;(deffunction real-instance-existp (?inst)
;	(and
;		(instance-existp ?inst)
;		(neq (class ?inst) candidate-object)
;	)
;)

;;; 25-03-2005 
;;; New Functions

;;; my-slot-existp
;;; Slot exists in any class in the list of classes
(deffunction multi-slot-existp (?slot $?classes)
	(while (> (length$ $?classes) 0)
	   do
	   	(if (slot-existp (nth$ 1 $?classes) ?slot inherit)
	   	   then
	   	   	(return TRUE)
	   	)
	   	(bind $?classes (rest$ $?classes))
	)
	(return FALSE)
)

(deffunction multi-slot-types (?slot $?classes)
	(while (> (length$ $?classes) 0)
	   do
	   	(bind ?class (nth$ 1 $?classes))
	   	(if (slot-existp ?class ?slot inherit)
	   	   then
	   	   	(return (slot-types ?class ?slot))
	   	)
	   	(bind $?classes (rest$ $?classes))
	)
	(return FALSE)
)

(deffunction multi-get-type-of (?slot $?classes)
	;(bind $?class-refs (slot-default-value ?class class-refs))
	(while (> (length$ $?classes) 0)
	   do
	   	(bind ?class (nth$ 1 $?classes))
		(bind $?class-refs (send (class-instance-name ?class) get-class-refs))
		(bind ?pos (member$ ?slot $?class-refs))
		(if (numberp ?pos)
		   then
			(return (nth$ (+ ?pos 1) $?class-refs))
		)
		(bind $?classes (rest$ $?classes))
	)
	(return FALSE)
)
