(defrule restore-classes
;	(goal restore-classes)
	?x <- (redefined-class (name ?class) (isa-slot $?super-classes) (slot-definitions $?slot-defs) (class-refs-defaults $?class-refs) (aliases-defaults $?aliases))
	(not (redefined-class (name ?super-class&:(member$ ?super-class $?super-classes))))
  =>
  	(debug  "Restoring class: " ?class crlf)
	(my-build (str-cat$ 
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
;	(modify-instance (class-instance-name ?class)
;		(class-refs (unique-pairs (create$ $?class-refs (collect-defaults class-refs $?super-classes))))
;		(aliases (unique-pairs (create$ $?aliases (collect-defaults aliases $?super-classes))))
;	)
	(make-instance of redefined-class-instance
		(class-instance-name (class-instance-name ?class))
		(super-classes $?super-classes)
		(class-refs $?class-refs)
		(aliases $?aliases)
	)
	(bind ?*redefined_class_facts* (delete-member$ ?*redefined_class_facts* ?x))
	(retract ?x)
	(bind ?*cycle-change-flag* true)
)
