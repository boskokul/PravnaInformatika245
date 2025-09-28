;(deffunction compatible-modality (?agentType ?actual-mod ?expected-mod)
;	(if (eq ?actual-mod ?expected-mod)
;	   then
;	   	(return TRUE)
;	   else
;	   	(if (eq ?agentType realistic)
;	   	   then
;	   	   	(if (and (eq ?actual-mod int) (eq ?expected-mod bel))
;	   	   	   then (return TRUE)
;	   	   	)
;	   	   	(if (and (eq ?actual-mod obl) (eq ?expected-mod bel))
;			   then (return TRUE)
;	   	   	)
;	   	   	(return FALSE)
;	   	)
;	   	
;	   	(if (eq ?agentType social)
;	   	   then
;	   	   	(if (and (eq ?actual-mod int) (eq ?expected-mod bel))
;	   	   	   then (return TRUE)
;	   	   	)
;	   	   	(if (and (eq ?actual-mod obl) (eq ?expected-mod bel))
;			   then (return TRUE)
;	   	   	)
;	   	   	(if (and (eq ?actual-mod int) (eq ?expected-mod obl))
;			   then (return TRUE)
;	   	   	)	   	   	
;	   	   	(return FALSE)
;	   	)
;	   	
;	   	(if (eq ?agentType deviant)
;	   	   then
;	   	   	(if (and (eq ?actual-mod int) (eq ?expected-mod bel))
;	   	   	   then (return TRUE)
;	   	   	)
;	   	   	(if (and (eq ?actual-mod obl) (eq ?expected-mod bel))
;			   then (return TRUE)
;	   	   	)
;	   	   	(if (and (eq ?actual-mod obl) (eq ?expected-mod int))
;			   then (return TRUE)
;	   	   	)	   	   	
;	   	   	(return FALSE)
;	   	)
;	)
;	(return FALSE)
;)



; Checks whether all modalities in the list are equal to a given modality
; (this function is essential for the "convert-modality" function)
(deffunction all-modalities (?mod $?list)
	(while (> (length$ $?list) 0)
	   do
	   	(if (neq ?mod (nth$ 1 $?list))
	   	   then
	   	   	(return FALSE)
	   	)
	   	(bind $?list (rest$ $?list))
	)
	(return TRUE)
)

(deffunction compatible-modality (?agentType ?rule-mode $?cond-mods)
	(if (> (length$ $?cond-mods) 0)
	   then
	   	; REALISTIC AGENT {BEL>INT, BEL>OBL}
	   	(if (eq ?agentType realistic)
	   	   then
	   	   	(if (and (eq ?rule-mode bel) (all-modalities int $?cond-mods))
			   then
			   	(return TRUE)
			)
			(if (and (eq ?rule-mode bel) (all-modalities obl $?cond-mods))
			   then
			   	(return TRUE)
			)
	   	)
	   	
	   	; SOCIAL AGENT {BEL>OBL>INT}
	   	(if (eq ?agentType social)
	   	   then
	   	   	(if (and (eq ?rule-mode bel) (all-modalities int $?cond-mods))
			   then
			   	(return TRUE)
			)
			(if (and (eq ?rule-mode bel) (all-modalities obl $?cond-mods))
			   then
			   	(return TRUE)
			)
			(if (and (eq ?rule-mode obl) (all-modalities int $?cond-mods))
			   then
			   	(return TRUE)
			)
	   	)
	   	
	   	; DEVIANT AGENT {BEL>INT>OBL}
	   	(if (eq ?agentType deviant)
	   	   then
	   	   	(if (and (eq ?rule-mode bel) (all-modalities int $?cond-mods))
			   then
			   	(return TRUE)
			)
			(if (and (eq ?rule-mode bel) (all-modalities obl $?cond-mods))
			   then
			   	(return TRUE)
			)
			(if (and (eq ?rule-mode int) (all-modalities obl $?cond-mods))
			   then
			   	(return TRUE)
			)	   	   
	   	)
	)	   
	(return FALSE)
)

; Rule conversion (depending on agent type)
(deffunction convert-modality (?agentType ?rule-mode $?cond-mods)
	(if (> (length$ $?cond-mods) 0)
	   then
	   	; REALISTIC AGENT {BEL>INT, BEL>OBL}
	   	(if (eq ?agentType realistic)
	   	   then
	   	   	(if (and (eq ?rule-mode bel) (all-modalities int $?cond-mods))
			   then
			   	(return int)
			)
			(if (and (eq ?rule-mode bel) (all-modalities obl $?cond-mods))
			   then
			   	(return obl)
			)
	   	)
	   	
	   	; SOCIAL AGENT {BEL>OBL>INT}
	   	(if (eq ?agentType social)
	   	   then
	   	   	(if (and (eq ?rule-mode bel) (all-modalities int $?cond-mods))
			   then
			   	(return int)
			)
			(if (and (eq ?rule-mode bel) (all-modalities obl $?cond-mods))
			   then
			   	(return obl)
			)
			(if (and (eq ?rule-mode obl) (all-modalities int $?cond-mods))
			   then
			   	(return int)
			)
	   	)
	   	
	   	; DEVIANT AGENT {BEL>INT>OBL}
	   	(if (eq ?agentType deviant)
	   	   then
	   	   	(if (and (eq ?rule-mode bel) (all-modalities int $?cond-mods))
			   then
			   	(return int)
			)
			(if (and (eq ?rule-mode bel) (all-modalities obl $?cond-mods))
			   then
			   	(return obl)
			)
			(if (and (eq ?rule-mode int) (all-modalities obl $?cond-mods))
			   then
			   	(return obl)
			)	   	   
	   	)
	)	   
	(return ?rule-mode)
)



;(defglobal ?*agentType* = "social")

;(deffunction agentType()
;	(printout t "Agent type: " ?*agentType* crlf)
;)

;(deffunction convert-modality (?rule-mode $?cond-mods)
;	(if (> (length$ $?cond-mods) 0)
;	   then
;		(if (and (eq ?rule-mode bel) (all-modalities int $?cond-mods))
;		   then
;		   	(return int)
;		)
;		(if (and (eq ?rule-mode bel) (all-modalities obl $?cond-mods))
;		   then
;		   	(return obl)
;		)
;	)	   
;	(return ?rule-mode)
;)

;(deffunction compatible-modality (?actual-mod ?expected-mod)
;	(if (eq ?actual-mod ?expected-mod)
;	   then
;	   	(return TRUE)
;	   else
;	   	(if (and (eq ?actual-mod int) (eq ?expected-mod bel))
;	   	   then
;	   	   	(return TRUE)
;	   	   else 
;	   		(return FALSE)
;	   	)
;	)
;)