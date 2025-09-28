(defglobal 
	?*current-dribble* = (create$)
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

(deffunction set-debug (?status)
	(bind ?*debug_status* ?status)
)

(deffunction get-debug ()
	?*debug_status*
)

(deffunction debug ($?list)
	(if (eq ?*debug_status* on)
	   then
	   	(funcall printout t (expand$ $?list))
	)
)

(deffunction set-time-report (?status)
	(bind ?*time_report* ?status)
)

(deffunction get-time-report ()
	?*time_report*
)

(deffunction time-report ($?list)
	(if (eq ?*time_report* on)
	   then
	   	(funcall printout t (expand$ $?list))
	)
)


(deffunction set-truth-maintenance (?status)
	(bind ?*truth_maintenance* ?status)
)

(deffunction get-truth-maintenance ()
	?*truth_maintenance*
)

(deffunction my-dribble-on (?file)
	(if (> (length$ ?*current-dribble*) 0)
	   then
		(dribble-off)
		(bind ?pfile (nth$ 1 ?*current-dribble*))
		(bind ?pnumber (nth$ 2 ?*current-dribble*))
		(bind ?pfilename (str-cat ?pnumber ?pfile ))
		(bind ?command (str-cat "type " ?pfilename " >> " ?pfile))
		(system ?command)
		(remove ?pfilename)
	)
	(bind ?*current-dribble* (create$ ?file 1 ?*current-dribble*))
	(if (open ?file ttt "r")
	   then
	   	(close ttt)
	   	(remove ?file)
	)
	(bind ?n-file (str-cat 1 ?file ))
	(dribble-on ?n-file)
)

(deffunction my-dribble-off ()
	(dribble-off)
	(bind ?file (nth$ 1 ?*current-dribble*))
	(bind ?number (nth$ 2 ?*current-dribble*))
	(bind ?command (str-cat "type " ?number ?file  " >> " ?file))
	(system ?command)
	(remove (str-cat ?number ?file ))
	(bind ?*current-dribble* (rest$ (rest$ ?*current-dribble*)))
	(if (> (length$ ?*current-dribble*) 0)
	   then
		(bind ?file (nth$ 1 ?*current-dribble*))
		(bind ?number (nth$ 2 ?*current-dribble*))
		(bind ?new-file (str-cat (+ ?number 1) ?file ))
		(bind ?*current-dribble* (create$ ?file (+ ?number 1) (rest$ (rest$ ?*current-dribble*))))
		(dribble-on ?new-file)
	   else
	   	TRUE
	)
)

(deffunction r-trim (?string)
	(bind ?len (str-length ?string))
	(bind ?lchar (sub-string ?len ?len ?string))
	(while (eq ?lchar " ")
		do
		(bind ?len (- ?len 1))
		(bind ?string (sub-string 1 ?len ?string))
		(bind ?lchar (sub-string ?len ?len ?string))
	)
	(return ?string)
)

(deffunction l-trim (?string)
	(bind ?pos (str-index " " ?string))
	(while (= ?pos 1)
		do
		(bind ?string (sub-string 2 (str-length ?string) ?string))
		(bind ?pos (str-index " " ?string))
	)
	(return ?string)
)


(deffunction str-replace (?original-string ?replace-string ?search-string)
	(bind ?search-length (length$ ?search-string))
	(bind ?pos (str-index ?search-string ?original-string))
	(while (neq ?pos FALSE)
	   do
	   	(bind ?original-string 
	   		(str-cat 
	   			(sub-string 1 (- ?pos 1) ?original-string)
	   			?replace-string
	   			(sub-string (+ ?pos ?search-length) (length$ ?original-string) ?original-string)
	   		)
	   	)
	   	(bind ?pos (str-index ?search-string ?original-string))
	)
	?original-string
)

(deffunction str-del (?original-string ?search-string)
	(bind ?search-length (length$ ?search-string))
	(bind ?pos (str-index ?search-string ?original-string))
	(while (neq ?pos FALSE)
	   do
	   	(bind ?original-string 
	   		(str-cat 
	   			(sub-string 1 (- ?pos 1) ?original-string)
	   			(sub-string (+ ?pos ?search-length) (length$ ?original-string) ?original-string)
	   		)
	   	)
	   	(bind ?pos (str-index ?search-string ?original-string))
	)
	?original-string
)

(deffunction my-round (?number ?digits)
	(/ (round (* ?number (** 10 ?digits))) (** 10 ?digits))
)

(deffunction instance-string (?x)
	(if (instancep ?x)
	   then
	   	(return (str-cat [ ?x ]))
	   else
	   	(return (str-cat ?x))
	)
)

(deffunction str-cat$ ($?list)
	(bind ?end (length$ $?list)) 
	(if (> ?end 0)
	   then
		(bind ?string-result (instance-string (nth$ 1 $?list)))
		(loop-for-count (?n 2 ?end)
		   do
			(bind ?string-result (str-cat ?string-result " " (instance-string (nth$ ?n $?list))))
		)
		(str-replace ?string-result "\"" "#$%")
	   else
	   	""
	)
)


(deffunction my-explode$ (?string)
	(explode$ (str-replace ?string "#$%" "\""))
)

(deffunction triple-explode$ (?string)
	(if (not (eq (sub-string 1 1 ?string) "<"))
	   then
	   	(return (create$))
	   else
		(bind ?pos1 (str-index " " ?string))
		(bind ?subject (sub-string 1 (- ?pos1 1) ?string))
		(bind ?rest-string (sub-string (+ ?pos1 1) (str-length ?string) ?string))
		(if (not (eq (sub-string 1 1 ?rest-string) "<"))
		   then
		   	(return (create$))
		   else
			(bind ?pos2 (str-index " " ?rest-string))
			(bind ?predicate (sub-string 1 (- ?pos2 1) ?rest-string))
			(bind ?rest-string (sub-string (+ ?pos2 1) (str-length ?rest-string) ?rest-string))
			(if (not (eq (sub-string 1 1 ?rest-string) "<"))
			   then
			   	(bind $?rest-triple (explode$ ?rest-string))
			   else
			   	(bind ?pos3 (str-index " " ?rest-string))
			   	(bind ?object (sub-string 1 (- ?pos3 1) ?rest-string))
			   	(bind ?rest-string (sub-string (+ ?pos3 1) (str-length ?rest-string) ?rest-string))
			   	(bind $?rest-triple (create$ ?object (explode$ ?rest-string)))
			)
			(return (create$ ?subject ?predicate $?rest-triple))
		)
	)
)

(deffunction double-member$ (?x $?list)
	(bind ?pos (member$ ?x $?list))
	(if (neq ?pos FALSE)
	   then
	   	(member$ ?x (subseq$ $?list (+ ?pos 1) (length$ $?list)))
	   else
	   	FALSE
	)
)

(deffunction odd-member$ (?x $?list)
	(bind ?pos (member$ ?x $?list))
	(if (integerp ?pos)
	   then
		(oddp ?pos)
	)
)

(deffunction associate-pairs (?x $?list)
	(bind $?result (create$))
	(while (> (length$ $?list) 0)
	   do
		(if (eq (nth$ 1 $?list) ?x)
		   then
		   	(bind $?result (create$ $?result (nth$ 2 $?list)))
		)
		(bind $?list (rest$ (rest$ $?list)))
	)
	$?result
)

;(deffunction subseq-pos ($?double-list)	
;	(bind $?small-list (subseq$ $?double-list 1 (- (member$ $$$ $?double-list) 1)))
;	(bind $?big-list (subseq$ $?double-list (+ (member$ $$$ $?double-list) 1) (length$ $?double-list)))
;	(bind ?big-index 1)
;	(bind ?big-length (length$ $?big-list))
;	(bind ?small-length (length$ $?small-list))
;	(while (<= ?big-index ?big-length)
;	  do
;	  	(bind ?small-index 1)
;	  	(while	(and
;	  			(<= ?small-index ?small-length)
;	  			(eq (nth$ (- (+ ?big-index ?small-index) 1) $?big-list) (nth$ ?small-index $?small-list))
;	  		)
;	  	   do
;	  	   	(bind ?small-index (+ ?small-index 1))
;	  	)
;	  	(if (> ?small-index ?small-length)
;	  	   then
;	  		(return ?big-index)
;	  	   else
;	  	   	(bind ?big-index (+ ?big-index 1))
;	  	)
;	)
;	FALSE
;)

(deffunction subseq-pos ($?double-list)
	(bind $?small-list (subseq$ $?double-list 1 (- (member$ $$$ $?double-list) 1)))
	(bind $?big-list (subseq$ $?double-list (+ (member$ $$$ $?double-list) 1) (length$ $?double-list)))
	(bind ?pos (member$ $?small-list $?big-list))
	(if (eq ?pos FALSE)
	   then
	   	(return FALSE)
	   else
	   	;(return (nth$ 1 ?pos))
	   	(return ?pos)
	)
)

(deffunction is-singlevar (?x)
	(if (and (stringp ?x) (eq (sub-string 1 1 ?x) "?"))
	   then
	   	TRUE
	   else
	   	FALSE
	)
)

(deffunction is-multivar (?x)
	(if (and (stringp ?x) (eq (sub-string 1 2 ?x) "$?"))
	   then
	   	TRUE
	   else
	   	FALSE
	)
)

(deffunction is-var (?x)
	(or (is-singlevar ?x) (is-multivar ?x))
)

(deffunction string> (?a ?b)
	(> (str-compare ?a ?b) 0)
)


(deffunction max-string ($?list)
	(if (= (length$ $?list) 0)
	   then
	   	nil
	   else
	   	(bind ?max-result (nth$ 1 $?list))
	   	(bind $?list (rest$ $?list))
	   	(while (> (length$ $?list) 0)
	   	   do
	   	   	(if (string> (nth$ 1 $?list) ?max-result)
	   	   	   then
	   	   	   	(bind ?max-result (nth$ 1 $?list))
	   	   	)
	   	   	(bind $?list (rest$ $?list))
	   	)
	   	?max-result
	)
)

(deffunction min-string ($?list)
	(if (= (length$ $?list) 0)
	   then
	   	nil
	   else
	   	(bind ?min-result (nth$ 1 $?list))
	   	(bind $?list (rest$ $?list))
	   	(while (> (length$ $?list) 0)
	   	   do
	   	   	(if (string> ?min-result (nth$ 1 $?list))
	   	   	   then
	   	   	   	(bind ?min-result (nth$ 1 $?list))
	   	   	)
	   	   	(bind $?list (rest$ $?list))
	   	)
	   	?min-result
	)
)

(deffunction min-int ($?list)
	(if (= (length$ $?list) 0)
	   then
	   	nil
	   else
	   	(if (= (length$ $?list) 1)
	   	   then
	   	   	(nth$ 1 $?list)
	   	   else
	   	   	(funcall min (expand$ $?list))
	   	)
	)
)

(deffunction max-int ($?list)
	(if (= (length$ $?list) 0)
	   then
	   	nil
	   else
	   	(if (= (length$ (rest$ $?list)) 0)
	   	   then
	   	   	(nth$ 1 $?list)
	   	   else
	   	   	(funcall max (expand$ $?list))
	   	)
	)
)

(deffunction sum$ ($?x)
	(if (= (length$ $?x) 0)
	   then
	   	0
	   else
	   	(if (= (length$ (rest$ $?x)) 0)
	   	   then
	   	   	(nth$ 1 $?x)
	   	   else
			(funcall + (expand$ $?x))
		)
	)
)
	   	   
(deffunction reverse$ ($?list)
	(bind $?result (create$))
	(bind ?end (length$ $?list))
	(loop-for-count (?n 1 ?end)
	   do
	   	(bind $?result (create$ (nth$ ?n $?list) $?result))
	)
	$?result
)

(deffunction remove-duplicates$ ($?list)
	(bind $?result (create$))
	(bind ?end (length$ $?list))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (not (member$ (nth$ ?n $?list) (subseq$ $?list (+ ?n 1) ?end)))
	   	   then
	   	   	(bind $?result (create$ $?result (nth$ ?n $?list)))
	   	)
	)
	$?result
)

(deffunction collect-singletons$ ($?list)
	(bind $?result (create$))
	(while (> (length$ $?list) 0)
	   do
	   	(if (not (member$ (nth$ 1 $?list) (rest$ $?list)))
	   	   then
	   	   	(bind $?result (create$ $?result (nth$ 1 $?list)))
	   	   	(bind $?list (rest$ $?list))
	   	   else
	   	   	(bind $?list (delete-member$ (rest$ $?list) (nth$ 1 $?list)))
	   	)
	)
	$?result
)

(deffunction difference$ ($?double-list)
	(bind $?first-list (subseq$ $?double-list 1 (- (member$ $$$ $?double-list) 1)))
	(bind $?second-list (subseq$ $?double-list (+ (member$ $$$ $?double-list) 1) (length$ $?double-list)))
	(bind $?result (create$))
	(bind ?end (length$ $?first-list))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (not (member$ (nth$ ?n $?first-list) $?second-list))
	   	   then
	   	   	(bind $?result (create$ $?result (nth$ ?n $?first-list)))
	   	)
	)
	$?result
)

(deffunction intersection$ ($?double-list)
	(bind $?list1 (subseq$ $?double-list 1 (- (member$ $$$ $?double-list) 1)))
	(bind $?list2 (subseq$ $?double-list (+ (member$ $$$ $?double-list) 1) (length$ $?double-list)))
	(bind $?intersection (create$))
	(bind ?end (length$ $?list1))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (member$ (nth$ ?n $?list1) $?list2)
	   	   then
	   	   	(bind $?intersection (create$ $?intersection (nth$ ?n $?list1)))
	   	)
	)
	(return $?intersection)
)

(deffunction union$ ($?double-list)
	;(printout t "union$: (BEFORE): " $?double-list crlf)
	(bind $?list1 (subseq$ $?double-list 1 (- (member$ $$$ $?double-list) 1)))
	(bind $?list2 (subseq$ $?double-list (+ (member$ $$$ $?double-list) 1) (length$ $?double-list)))
	(bind $?union (create$))
	(bind ?end (length$ $?list1))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (not (member$ (nth$ ?n $?list1) $?list2))
	   	   then
	   	   	(bind $?union (create$ $?union (nth$ ?n $?list1)))
	   	)
	)
	(bind $?union (create$ $?union $?list2))
	;(printout t "union$: (AFTER): " $?union crlf)
	(return $?union)
)
	

;(deffunction same-set$ ($?double-list)
;	(bind $?list1 (subseq$ $?double-list 1 (- (member$ $$$ $?double-list) 1)))
;	(bind $?list2 (subseq$ $?double-list (+ (member$ $$$ $?double-list) 1) (length$ $?double-list)))
;	(bind ?end (length$ $?list1))
;	(if (= ?end (length$ $?list2))
;	   then
;	   	(loop-for-count (?n 1 ?end)
;	   	   do
;	   	   	(if (not (member$ (nth$ ?n $?list1) $?list2))
;	   	   	   then
;	   	   	   	(return FALSE)
;	   	   	)
;	   	)
;	   	(return TRUE)
;	   else
;	   	FALSE
;	)
;)

(deffunction same-set$ ($?double-list)
	(bind $?first-list (subseq$ $?double-list 1 (- (member$ $$$ $?double-list) 1)))
	(bind $?second-list (subseq$ $?double-list (+ (member$ $$$ $?double-list) 1) (length$ $?double-list)))
	(and (subsetp $?first-list $?second-list) (subsetp $?second-list $?first-list))
)

;(deffunction supersetp ($?double-list)
;	(bind $?first-list (subseq$ $?double-list 1 (- (member$ $$$ $?double-list) 1)))
;	(bind $?second-list (subseq$ $?double-list (+ (member$ $$$ $?double-list) 1) (length$ $?double-list)))
;	(and (subsetp $?second-list $?first-list) (not (subsetp $?first-list $?second-list)))
;)

(deffunction get-token ($?condition)
	(bind ?count 0)
	(bind ?end (length$ $?condition))
	(loop-for-count (?pos 1 ?end)
	   do
	   	(if (eq (nth$ ?pos $?condition) "(")
	   	   then
	   	   	(bind ?count (+ ?count 1))
	   	   else
	   	   	(if (eq (nth$ ?pos $?condition) ")")
	   	   	   then
	   	   	   	(if (= ?count 1)
	   	   	   	   then
	   	   	   	   	(return ?pos)
	   	   	   	   else
	   	   	   	   	(bind ?count (- ?count 1))
	   	   	   	)
	   	   	)
	   	)
	)
	(return 0)
)


(deffunction token-length ($?code)
	(bind ?result 0)
	(while (> (length$ $?code) 0)
	   do
		(bind ?p2 (get-token $?code))
		(if (> ?p2 0)
		   then
			(bind $?code (subseq$ $?code (+ ?p2 1) (length$ $?code)))
			(bind ?result (+ ?result 1))
		   else
		   	(break)
		)
	)
	?result
)
	
(deffunction get-nth-token (?n $?token-list)
	(while (and (> (length$ $?token-list) 0) (>= ?n 1))
	   do
		(bind ?p2 (get-token $?token-list))
	   	(bind $?first-token (subseq$ $?token-list 1 ?p2))
		(bind $?token-list (subseq$ $?token-list (+ ?p2 1) (length$ $?token-list)))
		(bind ?n (- ?n 1))
	)
	(if (= ?n 0)
	   then
	   	$?first-token
	   else
	   	nil
	)
)

(deffunction make-symbol (?x)
	(if (instance-addressp ?x)
	   then
	   	(instance-name ?x)
	   else
	   	?x
	)
)

(deffunction inverse-brackets ($?code)
	(bind $?result (create$))
	(bind ?end (length$ $?code))
	(loop-for-count (?n 1 ?end)
	   do
	   	(if (eq (nth$ ?n $?code) ")")
	   	   then
	   	   	(bind $?result (create$ $?result "("))
	   	   else
	   	   	(if (eq (nth$ ?n $?code) "(")
	   	   	   then
	   	   	   	(bind $?result (create$ $?result ")" ))
	   	   	   else
	   	   	   	(bind $?result (create$ $?result (nth$ ?n $?code)))
	   	   	)
	   	)
	)
	$?result
)

(deffunction load-file (?file)
	(bind ?pos (str-index "." ?file))
	(if (neq ?pos FALSE)
	   then
	   	(bind ?suffix (sub-string (+ ?pos 1) (length ?file) ?file))
	   	(if (eq ?suffix "clp")
	   	   then
	   	   	(load* ?file)
	   	   else
	   	   	(if (eq ?suffix "bat")
	   	   	   then
	   	   	   	(batch* ?file)
	   	   	   else
	   	   	   	(printout t "Cannot handle file: " ?file crlf)
	   	   	   	(printout t "Can only handle .clp or .bat files!" crlf)
	   	   	)
	   	)
	   else
   	   	(printout t "Cannot handle file: " ?file crlf)
   	   	(printout t "Can only handle .clp or .bat files!" crlf)
	)
)

(deffunction load-files ($?file-list)
	(bind ?end (length$ $?file-list))
	(loop-for-count (?n 1 ?end)
	   do
	   	(load-file (nth$ ?n $?file-list))
	)
)


(deffunction replace-anonymous-variables (?rule-string-before)
	(bind $?rule (my-explode$ ?rule-string-before))
	(bind $?result (create$))
	(while (> (length$ $?rule) 0)
	   do
	   	(if (eq (nth$ 1 $?rule) "?")
	   	   then
	   	   	(bind $?result (create$ $?result (sym-cat "?" (gensym))))
	   	   else
	   	   	(bind $?result (create$ $?result (nth$ 1 $?rule)))
	   	)
	   	(bind $?rule (rest$ $?rule))
	)
	(str-cat$ $?result)
)

(deffunction run-goal (?goal)
;		(bind ?tb ?*triple_counter*)
;   	(bind ?time1 (timer (bind ?goal-id (assert (goal ?goal)))))
   	(bind ?goal-id (assert (goal ?goal)))
 ;  	(bind ?time (timer (run)))
 ;	(bind ?time2 (timer (run)))
 	(run)
 ;  	(bind ?time3 (timer (retract ?goal-id)))
    	(retract ?goal-id)
  	;(printout t ?goal "         " ?time crlf)
;  		(bind ?ta ?*triple_counter*)
;  		(bind ?tdiff (- ?tb ?ta))
  		;(printout t "Goal: " ?goal "  -  Triples consumed: " ?tdiff ", time1: " ?time1 " time2: " ?time2  " time3: " ?time3 " total time: " (+ ?time1 ?time2 ?time3) crlf)
;  		(printout t ?goal ", triples: " ?tdiff ", t1: " ?time1 ", t2: " ?time2  ", t3: " ?time3 ", total: " (+ ?time1 ?time2 ?time3) crlf)
;  		(if (> ?*test_counter* 0)
;  		   then
;  		   	(printout t "   Attempts: " ?*test_counter* crlf)
;  			(bind ?*test_counter* 0)
;  		)
;  		(printout t "      No of triples (DB): " (length$ (funcall get-template-specific-facts triple (get-fact-list))) crlf)
;		(printout t "      No of triples (counter): " ?*triple_counter* crlf)
)

(deffunction build-undefinitions (?file-name)
	(bind ?*undef_rules* (create$))
	(open ?file-name ttt "r")
	(bind ?line (readline ttt))
	(while (neq ?line EOF)
	   do
	   	(bind ?pos (str-index defrule ?line))
	   	(if (integerp ?pos)
	   	   then
	   	   	(bind ?line (sub-string (+ ?pos 8) (length ?line) ?line))
	   	   	(bind ?pos (str-index " " ?line))
	   	   	(if (integerp ?pos)
	   	   	   then
	   	   		(bind ?rule (sym-cat (sub-string 1 (- ?pos 1) ?line)))
	   	   	   else
	   	   	   	(bind ?rule (sym-cat ?line))
	   	   	)
			(bind ?*undef_rules* (create$ ?*undef_rules* ?rule))
		)
		(bind ?line (readline ttt))
	)
	(close ttt)
)

(deffunction undefine-rules ()
	(bind ?end (length$ ?*undef_rules*))
	(loop-for-count (?n 1 ?end)
	   do
	   	(undefrule (nth$ ?n ?*undef_rules*))
	)
	TRUE
	(bind ?*undef_rules* (create$))
)

(deffunction load-run-goal (?goal)
	(bind ?file-name (str-cat ?*R-DEVICE_PATH* "triple-transformation\\" ?goal ".clp"))
	(build-undefinitions ?file-name)
	(bind ?time1 (timer (load* ?file-name)))
;	(load* ?file-name)
;	(bind ?tb ?*triple_counter*)
; 	(run)
	(bind ?time2 (timer (run)))
   	(undefine-rules)
;	(bind ?ta ?*triple_counter*)
;	(bind ?tdiff (- ?tb ?ta))
	(time-report ?goal "," (my-round ?time1 3) "," (my-round ?time2 3) crlf)
)

(deffunction load*-run-goal (?goal)
	(bind ?file-name (str-cat ?*R-DEVICE_PATH* "triple-transformation\\" ?goal ".clp"))
	(build-undefinitions ?file-name)
	(load* ?file-name)
 	(run)
   	(undefine-rules)
)

(deffunction fake-run-goal (?goal)
	(bind ?file-name (str-cat ?*R-DEVICE_PATH* "triple-transformation\\" ?goal ".clp"))
	(build-undefinitions ?file-name)
	;(bind ?time1 (timer (load* ?file-name)))
;	(load* ?file-name)
		(bind ?tb ?*triple_counter*)
; 	(run)
	(bind ?time2 (timer (run)))
   	(undefine-rules)
  		(bind ?ta ?*triple_counter*)
 		(bind ?tdiff (- ?tb ?ta))
  		(printout t ?goal "," ?tdiff ",") 
  		(if (> ?*test_counter* 0)
  		   then
  		   	(printout t ?*test_counter* ",")
  			(bind ?*test_counter* 0)
  		   else
  		   	(printout t ",")
  		)
  		(printout t (my-round 0 3) "," (my-round ?time2 3) crlf)
)

(deffunction remove-vars ($?list)
	(bind $?result (create$))
	(while (> (length$ $?list) 0)
	   do
	   	(if (not (is-var (nth$ 1 $?list)))
	   	   then
	   	   	(bind $?result (create$ $?result (nth$ 1 $?list)))
	   	)
	   	(bind $?list (rest$ $?list))
	)
	$?result
)

(deffunction pair-member (?x1 ?x2 $?pair-list)
	(bind ?pos (member$ ?x1 $?pair-list))
	(if (neq ?pos FALSE)
	   then
	   	(if (eq (nth$ (+ ?pos 1) $?pair-list) ?x2)
	   	   then
	   	   	(return TRUE)
	   	   else
	   	   	(pair-member ?x1 ?x2 (subseq$ $?pair-list (+ ?pos 2) (length$ $?pair-list)))
	   	)
	   else
	   	FALSE
	)
)

(deffunction unique-pairs ($?pairs-list)
	(bind $?result (create$))
	(while (> (length$ $?pairs-list) 0)
	   do
;	   	(if (eq FALSE (subseq-pos (create$ (subseq$ $?pairs-list 1 2) $$$ (subseq$ $?pairs-list 3 (length$ $?pairs-list)))))
	   	(if (not (pair-member (nth$ 1 $?pairs-list) (nth$ 2 $?pairs-list) (subseq$ $?pairs-list 3 (length$ $?pairs-list))))
	   	   then
	   	   	(bind $?result (create$ $?result (subseq$ $?pairs-list 1 2)))
	   	)
	   	(bind $?pairs-list (subseq$ $?pairs-list 3 (length$ $?pairs-list)))
	)
	$?result
)

(deffunction my-build (?construct)
	(open "r-device-auxiliary-file.clp" fout "w")
	(printout fout ?construct crlf)
	(close fout)
	(load* "r-device-auxiliary-file.clp")
	(remove "r-device-auxiliary-file.clp")
)

(deffunction save-compiled-rule (?rule)
	(printout r-device-rule-out ?rule crlf)
)

(deffunction save-compiled-derived-class (?class)
	(printout r-device-derived-class-out ?class crlf)
)

(deffunction test-counter ()
	(bind ?*test_counter* (+ ?*test_counter* 1))
	(return TRUE)
)

(deffunction save-defglobals (?file)
	(bind $?var-names (get-defglobal-list))
	(bind ?end (length$ $?var-names))
	(bind $?defglobalparts (create$))
	(loop-for-count  (?n 1 ?end)
	   do
		(bind ?global-var (sym-cat "?*" (nth$ ?n $?var-names) *))
		(if (stringp (eval ?global-var))
		   then
		   	(bind ?global-var-value (str-cat "\"" (eval ?global-var) "\""))
		   else
		   	(if (multifieldp (eval ?global-var))
		   	   then
		   	   	(bind ?global-var-value (str-cat$ "(" create$ (eval ?global-var) ")"))
		   	   else
		   	   	(bind ?global-var-value (eval ?global-var))
		 	)
		)
	   	(bind $?defglobalparts (create$ $?defglobalparts 
	   		;?global-var = "(" create$ $?global-var-value ")" 
	   		?global-var =  ?global-var-value 
	   	))
	)
	(bind ?defglobals-string (str-cat$ (create$ "(" defglobal $?defglobalparts ")" )))
	(open ?file out "w")
	(printout out ?defglobals-string crlf)
	(close out)
)

(deffunction find-project-name (?URL-or-file)
	(bind ?pos1 (str-index "\\" ?URL-or-file))
	(bind ?pos2 (str-index "/" ?URL-or-file))
   	(while (or (neq ?pos1 FALSE) (neq ?pos2 FALSE))
   	   do
   	   	(if (and (neq ?pos1 FALSE) (neq ?pos2 FALSE))
   	   	   then
   	   	   	(bind ?pos (max ?pos1 ?pos2))
   	   	   else
   	   	   	(if (eq ?pos1 FALSE)
   	   	   	   then
   	   	   	   	(bind ?pos ?pos2)
   	   	   	   else
   	   	   	   	(bind ?pos ?pos1)
   	   	   	)
   	   	)
   	   	(bind ?URL-or-file (sub-string (+ ?pos 1) (str-length ?URL-or-file) ?URL-or-file))
   	   	(bind ?pos1 (str-index "\\" ?URL-or-file))
   	   	(bind ?pos2 (str-index "/" ?URL-or-file))
   	)
	(bind ?pos (str-index ".rdf" ?URL-or-file))
	(if (neq ?pos FALSE)
	   then
	   	(bind ?URL-or-file (sub-string 1 (- ?pos 1) ?URL-or-file))
	)
	(return ?URL-or-file)
)


;;; New 25-03-2005

;;; Check if pair exists in the list 
;;; Use second member in the pair as primary index
;;; return index number 1 right after the second val in the pair
(deffunction inv-pair-member (?x1 ?x2 $?pair-list)
	(bind ?pos (member$ ?x2 $?pair-list))
	(if (neq ?pos FALSE)
	   then
	   	(if (eq (nth$ (- ?pos 1) $?pair-list) ?x1)
	   	   then
	   	   	(return (+ ?pos 1))
	   	   else
	   	   	(bind ?rest-pos (pair-member ?x1 ?x2 (subseq$ $?pair-list (+ ?pos 2) (length$ $?pair-list))))
	   	   	(if (neq ?rest-pos FALSE)
	   	   	   then
	   	   		(return (+ ?pos 1 ?rest-pos))
	   	   	   else
	   	   	   	(return FALSE)
	   	   	)
	   	)
	   else
	   	(return FALSE)
	)
)

(deffunction parenthesis ($?values)
	(bind $?result (create$))
	(while (> (length$ $?values) 0)
	   do
	   	(bind ?value (nth$ 1 $?values))
	   	;(printout t "1 - value: " ?value crlf)
	   	(bind $?values (rest$ $?values))
	   	(if (stringp ?value)
	   	   then
	   	   	;(bind ?value (str-replace ?value "###[###" "("))
	   	   	;(bind ?value (str-replace ?value "\"(\"" "###[###"))
	   	   	;(printout t "2 - value: " ?value crlf)
	   	   	;(bind ?value (str-replace ?value "###]###" ")"))
	   	   	;(bind ?value (str-replace ?value "\")\"" "###]###"))
	   	   	;(printout t "3 - value: " ?value crlf)
	   	   	;(if (eq (sub-string 1 1 ?value) "?")
	   	   	;   then
	   	   	   	(bind ?value (str-cat "\"" ?value "\""))
	   	   	;)
	   	)
	   	(bind $?result (create$ ?value $?result))
	)
	;(printout t "$?result: " $?result crlf)
	(return $?result)
)
