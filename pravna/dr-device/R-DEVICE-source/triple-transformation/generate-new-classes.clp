(defrule generate-non-existing-classes_create-create-final-class
;	(goal generate-new-classes)
	?x <- (candidate-class 
			(name ?new-class) 
			(isa-slot $?super-classes) 
			(slot-definitions $?slot-defs) 
			(class-refs-defaults $?class-refs) 
			(aliases-defaults $?aliases))
	;(not (triple (predicate rdfs:domain) (object ?new-class)))
  =>
  	(debug  "Creating class: " ?new-class crlf)
	(my-build (str-cat$ 
		"(" defclass ?new-class
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
			;	"(" default (unique-pairs $?class-refs) ")"
			;")"
			;"(" multislot aliases 
			;	"(" source composite ")"
			;	"(" default (unique-pairs $?aliases) ")"
			;")"
		")"
	))
	(modify-instance (class-instance-name ?new-class)
		(class-refs (unique-pairs $?class-refs))
		(aliases (unique-pairs $?aliases))
	)
	;(ppdefclass ?new-class)
  	(retract ?x)
  	(bind ?*cycle-change-flag* true)
)
