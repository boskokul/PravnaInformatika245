
(deffunction backup-class-def (?class)
	;(bind $?all-slots (delete-member$ (class-slots ?class) class-refs aliases))
	(bind $?all-slots (class-slots ?class))
	(bind $?slot-defs (create$))
	(while (> (length$ $?all-slots) 0)
	   do
	   	(bind $?slot-types (slot-types ?class (nth$ 1 $?all-slots)))
	   	(if (is-multislot ?class (nth$ 1 $?all-slots))
	   	   then
	   	   	(bind ?slot-field multislot)
	   	   else
	   	   	(bind ?slot-field slot)
	   	)
	   	(bind $?slot-defs (create$ $?slot-defs "(" ?slot-field (nth$ 1 $?all-slots) "(" type $?slot-types ")" ")"))
	   	(bind $?all-slots (rest$ $?all-slots))
	)
	(bind ?fact-id 
		(assert (redefined-class 
			(name ?class) 
			(isa-slot (class-superclasses ?class))
			(slot-definitions $?slot-defs)
			;(class-refs-defaults (slot-default-value ?class class-refs))
			(class-refs-defaults (send (class-instance-name ?class) get-class-refs))
			(aliases-defaults (send (class-instance-name ?class) get-aliases))
		))
	)
	(bind ?*redefined_class_facts* (create$ ?fact-id ?*redefined_class_facts*))
)

(deffunction backup-class-hierarchy (?class)
	(bind $?classes (create$ ?class (class-subclasses ?class inherit)))
	(bind ?end (length$ $?classes))
	(loop-for-count (?n 1 ?end)
	   do
	   	(backup-class-def (nth$ ?n $?classes))
	)
)

(deffunction backup-class (?class)
	(bind ?filename (str-cat "backup-class-" (str-replace ?class "-" ":") "-instances.txt"))
	(bind ?t1 (timer (save-instances ?filename visible inherit ?class)))
	;(bind ?t1 (timer (bsave-instances ?filename visible inherit ?class)))
	(time-report "===> save-instances: " ?t1 crlf)
	(bind ?*restore_instances_filenames* (create$ ?filename ?*restore_instances_filenames*))
	;(do-for-all-instances ((?x ?class)) TRUE (send ?x delete))
	(bind ?t3 (timer (backup-class-hierarchy ?class)))
	(time-report "===> backup-class-hierarchy: " ?t3 crlf)
	(bind ?t4 (timer (bind ?factid (assert (class-to-undefine ?class)))))
	(time-report "===> assert class-to-undefine: " ?t4 crlf)
	(bind ?*class_to_undefine_facts* (create$ ?factid ?*class_to_undefine_facts*))
	;(undefclass ?class)
)



(deffunction undefine-classes ()
	;(bind $?facts (get-template-specific-facts class-to-undefine (get-fact-list)))
	;(printout t "classes-to-undefine: " ?*class_to_undefine_facts* crlf)
	(bind $?facts ?*class_to_undefine_facts*)
	(bind ?end (length$ $?facts))
	(bind ?tt (timer
	(loop-for-count (?n 1 ?end)
	   do
	   	(bind ?class (nth$ 1 (fact-slot-value (nth$ ?n $?facts) implied)))
	   	(if (class-existp ?class)
	   	   then
	   		(do-for-all-instances ((?x ?class)) TRUE (send ?x delete))
	   		(undefclass ?class)
	   	)
	   	(retract (nth$ ?n $?facts))
	   	(bind ?*class_to_undefine_facts* (rest$ ?*class_to_undefine_facts*))
	)
	))
	(time-report "undefine-classes,," (my-round ?tt 3) crlf)

)





;(deffunction undefine-functions ()
;	(undeffunction load-rdf)
;	(undeffunction load-namespaces)
;	(undeffunction load-namespace)
;	(undeffunction insert-triple)
;	(undeffunction create-namespaces)
;	(undeffunction scan_base)
;	(undeffunction scan_namespaces)
;	(undeffunction import-resource)
;	(undeffunction create-aliases)
;	(undeffunction find-all-super-properties)
;	(undeffunction resource-make-instance)
;	(undeffunction import-datatype)
;	(undeffunction collect-useful-info)  ; CUI
;	(undeffunction create-datatype-instance)
;)




(deffunction my-restore-instances ()
	(bind ?time (timer
	(while (> (length$ ?*restore_instances_filenames*) 0)
	   do
	   	(bind ?filename (nth$ 1 ?*restore_instances_filenames*))
	   	(bind ?*restore_instances_filenames* (rest$ ?*restore_instances_filenames*))
	   	(restore-instances ?filename)
	   	;(bload-instances ?filename)
	   	; This is new
	   	;(load-instances ?filename)
	   	;(batch ?filename)
		(remove ?filename)
	)
	(do-for-all-instances ((?x redefined-class-instance)) TRUE
		(modify-instance ?x:class-instance-name
			(class-refs (unique-pairs (create$ ?x:class-refs (collect-defaults class-refs ?x:super-classes))))
			(aliases (unique-pairs (create$ ?x:aliases (collect-defaults aliases ?x:super-classes))))
		)
		(send ?x delete)
	)
	))
	(time-report "restore-instances,," (my-round ?time 3) crlf)
)

;;; Updated - 25-03-2005
(deffunction import ()
	;(build-undefinitions)   ;newstyle
   	;(set-strategy mea)   ;newstyle
	(set-strategy depth)
;   	(set-strategy lex)   ;newstyle
;	(run-goal create-properties)
;	(run-goal put-slot-values)
;	(run-goal property-inheritance)
;	(run-goal multiple-domains-ranges)
;	(printout t "triples (counter from the DB): " (length$ (get-template-specific-facts triple (get-fact-list))) crlf)
	;;; If the outer loop does not consume triples between two loops
	;;; then the triple import function terminates and reports un-consumed triples
 	(bind ?no-of-triples-start (+ ?*triple_counter* 1))
 	(bind ?no-of-triples-end ?*triple_counter*)
 	;(do-for-all-instances ((?x rdfs:Resource)) TRUE (send ?x print) (printout t crlf))
 	(bind ?*cycle-change-flag* false)
 	(while (and	(> ?*triple_counter* 0) 
 			;(or (neq ?no-of-triples-start ?no-of-triples-end) (eq ?*cycle-change-flag* true)) 
 			(neq ?no-of-triples-start ?no-of-triples-end)
 		)
 	   do
 	   	(bind ?no-of-triples-start ?no-of-triples-end)
 	   	(bind ?*cycle-change-flag* false)
		;(load-run-goal put-remaining-triples)
		(bind ?no-of-triples-before (+ ?*triple_counter* 1))
		(bind ?no-of-triples-after ?*triple_counter*)
		(while (> ?no-of-triples-before ?no-of-triples-after)
		   do
		   	(bind ?no-of-triples-before ?no-of-triples-after)
;				(run-goal put-remaining-triples)
		   	(load-run-goal create-instances)
			(load-run-goal put-slot-values)
			(load-run-goal property-inheritance)
			(load-run-goal multiple-domains-ranges)
			(load-run-goal create-new-classes)
			(load-run-goal generate-new-classes)
			(bind ?no-of-triples-after ?*triple_counter*)
		)
		(load-run-goal put-new-properties)
 		(bind ?redef-classes (length$ ?*redefined_class_facts*))
		(if (> ?redef-classes 0)
		   then
			;(undefine-rules)   ; newstyle
			;(undefine-functions)           ; May be this is not needed!!!
			(if (member$ rdf_classes (get-definstances-list))
			   then
				(undefinstances rdf_classes)
			)
			(if (member$ derived_class (get-definstances-list))
			   then
				(undefinstances derived_class)
			)
			(if (member$ defeasible_class (get-definstances-list))
			   then
				(undefinstances defeasible_class)
			)
			(undefine-classes)
	;		(load* (str-cat ?*R-DEVICE_PATH* "restore-classes.clp"))
			(load-run-goal restore-classes)
			(my-restore-instances)
			; Conflict between DR-DEVICE and R-DEVICE
			; The goal is to eliminate the following as well as
			; undefining functions. Probably use indirect (funcall) function calls
			; in functions of load_rdf.clp
			;(load* (str-cat ?*R-DEVICE_PATH* "useful_info.clp"))     ; May be this is not needed!!!
			;(load* (str-cat ?*R-DEVICE_PATH* "load-rdf.clp"))     ; May be this is not needed!!!
			;(load* (str-cat ?*R-DEVICE_PATH* "triple-transformation.clp"))  ;newstyle
			;(set-strategy breadth)
			(load-run-goal put-slot-values)
			;(load-run-goal put-slot-values1)
			;(load-run-goal put-slot-values2)
		)
;		(set-strategy depth)
		(load-run-goal put-remaining-triples)
		;(save-facts "triples.txt" visible triple)
		(bind ?no-of-triples-end ?*triple_counter*)
		;(printout t "Cycle: " ?*triple_counter* " - flag = " ?*cycle-change-flag* crlf) 
	)
	(if (> ?*triple_counter* 0)
	   then
 	   	(printout t "No of un-consumed triples: " ?*triple_counter* crlf)
 	   	(facts)
 	   	;(list-defclasses)
 	   	;(eval "(do-for-all-instances ((?x rdfs:Class)) (send ?x print))")
 	)
	TRUE
)

;(deffunction import-rdf ($?projects)
;	(bind ?*rdf_triple_limit* 0)
;	(while (> (length$ $?projects) 0)
;	   do
;	   	(bind ?projectname (nth$ 1 $?projects))
;	   	(bind ?address (nth$ 2 $?projects))
;	   	(bind $?projects (rest$ (rest$ $?projects)))
;	   	(bind ?time (timer (funcall load-rdf ?projectname ?address)))
;	   	(printout t "Load RDF: " ?projectname " " ?address " -  Time: " ?time crlf)
;	)
;	(printout t crlf)
;	(bind ?time (timer (import)))
;	(printout t crlf "Import Time: " ?time crlf crlf)
;)

(deffunction inc-import-rdf (?limit ?hash-buckets $?projects)
	(bind ?no-projects (length$ $?projects))
	(if (> ?no-projects 0)
	   then
	(if (numberp ?limit)
	   then
		(bind ?*rdf_triple_limit* ?limit)
	   else
	   	(bind ?*rdf_triple_limit* ?*rdf_triple_limit_default*)
	)
	(if (numberp ?hash-buckets)
	   then
		(bind ?*HashBuckets* ?hash-buckets)
	   else
	   	(if (>= ?*rdf_triple_limit* 100)
	   	   then
	   		(bind ?*HashBuckets* (div ?*rdf_triple_limit* 100))
	   	   else
	   		(bind ?*HashBuckets* 1)
	   	)
	)
	(if (= ?*HashBuckets* 1)
	   then
	   	(bind ?*divident-buckets* 0)
	   else
	   	(bind ?*divident-buckets* (log10 (div ?*HashBuckets* 10)))
	)
	(bind ?time-hash (timer (init-hash-buckets ?*HashBuckets*)))
	(bind ?import_time 0)
	(bind ?load_time 0)
	(bind ?cycle 0)
	(printout t crlf)
	(while (> (length$ $?projects) 0)
	   do
	   	(bind ?projectname (str-cat (nth$ 1 $?projects)))
	   	(bind ?address (str-cat (nth$ 2 $?projects)))
	   	(bind ?time (timer (funcall load-rdf ?projectname ?address)))
	   	(bind ?load_time (+ ?load_time ?time))
	   	;(bind ?cycle (+ ?cycle 1))
	   	;(printout t crlf "Cycle: " ?cycle crlf)
	   	(time-report "Load RDF: " ?projectname " " ?address " -  Time: " ?time crlf)
	   	;(display-hash-buckets)
	   	(if (eq ?*open_n3_file* nil)
	   	   then
	   	   	(if  (> ?cycle 1)
	   	   	   then
	   	   		; When a triple file has been fully loaded, then import it
	   	   		; regardless if you have reached the triple limit
		      		(bind ?cycle (+ ?cycle 1))
		   		(time-report "Cycle: " ?cycle crlf crlf)
				(bind ?time (timer (import)))
	   			(bind ?import_time (+ ?import_time ?time))
	   			(bind ?time-hash (+ ?time-hash (timer (nullify-hash-buckets))))
				(time-report crlf "Import Time: " ?time crlf crlf)
			)
			; Then go to the next file
		   	(bind $?projects (rest$ (rest$ $?projects)))
		   else
		      	(bind ?cycle (+ ?cycle 1))
		   	(time-report "Cycle: " ?cycle crlf crlf)
			(bind ?time (timer (import)))
	   		(bind ?import_time (+ ?import_time ?time))
	   		(bind ?time-hash (+ ?time-hash (timer (nullify-hash-buckets))))
			(time-report crlf "Import Time: " ?time crlf crlf)
		)
	)
	(if (> ?*triple_counter* 0)
	   then
	      	(bind ?cycle (+ ?cycle 1))
	   	(time-report "Cycle: " ?cycle crlf crlf)
		(bind ?time (timer (import)))
	   	(bind ?import_time (+ ?import_time ?time))
	   	(bind ?time-hash (+ ?time-hash (timer (nullify-hash-buckets))))
		(time-report crlf "Import Time: " ?time crlf)
	)
		(time-report crlf "Hash Management time: " ?time-hash crlf)
		(time-report "Total Load Time: " ?load_time crlf)
		(time-report "Total Import Time: " ?import_time crlf)
		(time-report "Global Time: " (+ ?time-hash ?load_time ?import_time) crlf crlf)
		(nullify-future-resource-hash-buckets)
	)
)

(deffunction import-rdf ($?projects)
	(inc-import-rdf 0 def $?projects)
)

(deffunction import-rdf-files ($?URL-or-files)
	(bind $?result (create$))
	(while (> (length$ $?URL-or-files) 0)
	   do
	   	(bind ?URL-or-file (nth$ 1 $?URL-or-files))
	   	(bind ?project (find-project-name ?URL-or-file))
	   	(bind $?result (create$ ?project ?URL-or-file $?result))
	   	(bind $?URL-or-files (rest$ $?URL-or-files))
	)
	(import-rdf $?result)
)
