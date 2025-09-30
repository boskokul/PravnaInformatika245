(defglobal
	?*rule-base-oid* = ""
	?*system-export-prefix* = "http://startrek.csd.auth.gr/dr-device/"
	?*rulebases* = (create$)
	?*proof-counter* = 0
	?*unexported-uris* = (create$)
	?*unexported-namespaces* = (create$)
	?*unexported-rulebase-namespaces* = (create$)
	?*compact-proofs* = on
	?*export-non-proved* = off
)

(deffunction set-compact-proofs (?status)
	(bind ?*compact-proofs* ?status)
)

(deffunction get-compact-proofs ()
	?*compact-proofs*
)

(deffunction set-export-non-proved (?status)
	(bind ?*export-non-proved* ?status)
)

(deffunction get-export-non-proved ()
	?*export-non-proved*
)

(deffunction get-truth-status (?positive ?negative)
	(if (= ?positive 2) 
	   then
		(bind ?truth-status definitely-proven-positive)
	   else
	   	(if (= ?positive 1)
	   	   then
	   	   	(bind ?truth-status defeasibly-proven-positive)
	   	   else
	   	   	(if (= ?negative 2)
	   	   	   then
			   	(bind ?truth-status definitely-proven-negative)
			   else
			   	(if (= ?negative 1)
			   	   then
			   		(bind ?truth-status defeasibly-proven-negative)
			   	   else
			   	   	(bind ?truth-status not-defeasibly-proven)
			   	)
			)
		)
	)
	(return ?truth-status)
)

(deffunction get-modality (?mode)
	(switch ?mode
	   (case bel then belief)
	   (case int then intention)
	   (case obl then obligation)
	   (case per then permission)
	   (case age then agency)
	)
)

(deffunction get-rule-tag (?rule-type)
	(if (eq ?rule-type strictrule)
	   then
	   	(return "Strict_rule")
	   else
	   	(if (eq ?rule-type defeasiblerule)
	   	   then
	   	   	(return "Defeasible_rule")
	   	   else
	   	   	(return "Defeater")
	   	)
	)
 )
			
; PROOF
(deffunction construct-proof-namespace (?export-namespace)
	(bind ?proof-namespace (str-replace ?export-namespace "proof-" "export-"))
	(if (eq ?proof-namespace ?export-namespace)
	   then
	   	(bind ?proof-namespace (str-cat "proof-" ?export-namespace))
	)
	(return ?proof-namespace)
)

(deffunction export-proof-header (?proof-file ?proof-file-name ?proof-namespace ?export-file ?current-namespace ?rulebase)
	(printout ?proof-file "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" crlf) ; XML header
	(printout ?proof-file "<!DOCTYPE RuleML [" crlf)
	(printout ?proof-file (str-cat "     <!ENTITY " ?current-namespace " \"" ?*system-export-prefix* "export/" ?export-file "#\">" ) crlf)
	(printout ?proof-file (str-cat "     <!ENTITY " ?proof-namespace " \"" ?*system-export-prefix* "proof/" ?proof-file-name "#\">" )  crlf)
	(printout ?proof-file "]>" crlf crlf)
	; Start RuleML (header) tag
	(printout ?proof-file "<RuleML ")
	; import-rdf attribute 
	(printout ?proof-file "rdf_import='" (implode$ ?*imported-rdf-files*) "' ")
	; export-rdf attribute 
	(printout ?proof-file "rdf_export='" ?export-file "' ")
	(printout ?proof-file "rdf_export_classes=\"" (implode$ ?*exported-derived-classes*) "\" ")
	(printout ?proof-file "rulebase='" ?rulebase "' ")
	(printout ?proof-file "xmlns=\"http://www.ruleml.org/0.91/xsd\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xsi:schemaLocation=\"http://www.ruleml.org/0.91/xsd http://lpis.csd.auth.gr/systems/dr-device/dr-device-0.81.xsd\">" crlf)
	(printout ?proof-file "<Grounds>" crlf)

)

(deffunction export-proof-footer (?proof-file)
	(printout ?proof-file "</Grounds>" crlf)
	(printout ?proof-file "</RuleML>" crlf)
)

(deffunction replace-unexported-uris (?proof-file $?oids)
	(bind $?uris (create$))
	(bind ?end (length$ $?oids))
	(loop-for-count (?x 1 ?end)
	   do
	   	(bind $?uris (create$ $?uris (send (nth$ ?x $?oids) get-uri)))
	)
	(open ?proof-file ppp "r")
	(bind ?proof-file-aux (str-cat ?proof-file "-aux"))
	(open ?proof-file-aux ttt "w")
	(bind ?line (readline ppp))
	(while (neq ?line "]>")
	   do
	   	(printout ttt ?line crlf)
	   	(bind ?line (readline ppp))
	)
	(while (> (length$ ?*unexported-rulebase-namespaces*) 0)
	   do
	   	(bind ?ns (nth$ 1 ?*unexported-rulebase-namespaces*))
	   	(bind ?pos (member$ ?ns ?*rulebases*))
	   	(bind ?ns-uri (nth$ (+ ?pos 1) ?*rulebases*))
		(printout ttt (str-cat "     <!ENTITY " ?ns " \"" ?ns-uri "\">") crlf)
		(bind ?*unexported-rulebase-namespaces* (rest$ ?*unexported-rulebase-namespaces*))
	)
	(while (> (length$ ?*unexported-namespaces*) 0)
	   do
	   	(bind ?ns (sym-cat (nth$ 1 ?*unexported-namespaces*)))
   		(bind ?ns-uri (get-ns-uri ?ns))
		(printout ttt (str-cat "     <!ENTITY " ?ns " \"" ?ns-uri "\">") crlf)
		(bind ?*unexported-namespaces* (rest$ ?*unexported-namespaces*))
	)
	(printout ttt "]>" crlf crlf)
	(bind ?line (readline ppp))
	(while (neq ?line EOF)
	   do
	   	(bind ?line-out ?line)
		(loop-for-count (?x 1 ?end)
		   do
		   	(bind ?line-out (str-replace ?line (nth$ ?x $?uris) (nth$ ?x $?oids)))
			(if (neq ?line ?line-out)
			   then
			   	(bind $?oids (delete$ $?oids ?x ?x))
		   		(bind $?uris (delete$ $?uris ?x ?x))
		   		(bind ?end (- ?end 1))
		   		(break)
		   	)
		)
		(printout ttt ?line-out crlf)
		(bind ?line (readline ppp))
	)
	(close ttt)
	(close ppp)
	(remove ?proof-file)
	(rename ?proof-file-aux ?proof-file)
)

(deffunction register-namespace (?uri ?export-ns)
	(bind ?pos1 (str-index "&" ?uri))
	(bind ?pos2 (str-index ";" ?uri))
	(if (and (neq ?pos1 FALSE) (neq ?pos2 FALSE))
	   then
	   	(bind ?ns (sub-string (+ ?pos1 1) (- ?pos2 1) ?uri))
	   else
	   	(bind ?pos (str-index ":" ?uri))
	   	(if (neq ?pos FALSE)
	   	   then
	   	   	(bind ?ns (sub-string 1 (- ?pos 1) ?uri))
	   	   else
	   	   	(return)
	   	)
	)
	(if (and (neq ?ns ?export-ns) (not (member$ ?ns ?*unexported-namespaces*)))
	   then
	   	(bind ?*unexported-namespaces* (create$ ?*unexported-namespaces* ?ns))
	)
)

(deffunction register-rulebase-namespace (?ns)
	(if (not (member$ ?ns ?*unexported-rulebase-namespaces*))
	   then
	   	(bind ?*unexported-rulebase-namespaces* (create$ ?*unexported-rulebase-namespaces* ?ns))
	)
)

(deffunction get-rule-uri (?rule ?rulebase ?export-ns)
	(bind ?p1 (str-index "#" ?rule))
	(if (integerp ?p1)
	   then
	   	(bind ?main-address (sub-string 1 (- ?p1 1) ?rule))
	   	(bind ?local-address (sub-string (+ ?p1 1) (str-length ?rule) ?rule))
	   else
	   	(bind ?main-address ?rulebase)
	   	(bind ?local-address ?rule)
	)
   	(bind ?pos (member$ ?main-address ?*rulebases*))
	(if (integerp ?pos)
	   then
	   	(bind ?rulebase-ns (nth$ (- ?pos 1) ?*rulebases*))
	   	(bind ?rule-uri (str-cat "&" ?rulebase-ns ";" ?local-address))
	   	(register-rulebase-namespace ?rulebase-ns)
	   else
	   	(bind ?rule-uri ?rule)
	)
	(return ?rule-uri)
)

(deffunction start-tag (?tag-name $?attribute-value-pairs)
	(bind ?result (str-cat "<" ?tag-name))
	(while (> (length$ $?attribute-value-pairs) 0)
	   do
	   	(bind ?attribute (nth$ 1 $?attribute-value-pairs))
	   	(bind ?value (nth$ 2 $?attribute-value-pairs))
	   	(bind ?result (str-cat ?result " " ?attribute "='" ?value "'"))
	   	(bind $?attribute-value-pairs (rest$ (rest$ $?attribute-value-pairs)))
	)
	(bind ?result (str-cat ?result ">"))
	(return ?result)
)

(deffunction end-tag (?tag-name)
	(return (str-cat "</" ?tag-name ">"))
)

(deffunction empty-element (?tag-name $?attribute-value-pairs)
	(bind ?result (str-cat "<" ?tag-name))
	(while (> (length$ $?attribute-value-pairs) 0)
	   do
	   	(bind ?attribute (nth$ 1 $?attribute-value-pairs))
	   	(bind ?value (nth$ 2 $?attribute-value-pairs))
	   	(bind ?result (str-cat ?result " " ?attribute "='" ?value "'"))
	   	(bind $?attribute-value-pairs (rest$ (rest$ $?attribute-value-pairs)))
	)
	(bind ?result (str-cat ?result "/>"))
	(return ?result)
)

(deffunction pcdata-element (?tag-name ?content)
	(return (str-cat "<" ?tag-name ">" ?content "</" ?tag-name ">"))
)

(deffunction export-literal (?proof-file ?oid ?negative-status)
   	(bind ?class (class ?oid))
	(bind $?properties (user-slots ?class))
	(if (eq ?negative-status yes)
	   then
	   	(printout ?proof-file (start-tag "Neg") crlf)
	)
	(if (slot-existp ?class modality inherit)
	   then
		(printout ?proof-file (start-tag "Atom" modality (send ?oid get-modality)) crlf)
	   else
	   	(printout ?proof-file (start-tag "Atom") crlf)
	)
	(printout ?proof-file (start-tag "op") crlf)
	(if (neq (str-index : ?class) FALSE)
	   then
	   	(printout ?proof-file (empty-element "Rel" uri ?class) crlf)
	   else
		(printout ?proof-file (pcdata-element "Rel" ?class) crlf)
	)
	(printout ?proof-file (end-tag "op") crlf)
	(while (> (length$ $?properties) 0)
	   do
	   	(bind ?property (nth$ 1 $?properties))
	   	(if (not (is-rdf-property ?property))
	   	   then
			(if (is-multislot ?class ?property)
			   then
				(bind ?val (str-cat$ (funcall send ?oid (sym-cat get- ?property)))) ; I ignore multi-field properties!
			   else
			   	(bind ?val (funcall send ?oid (sym-cat get- ?property)))
			)
		   	(if (and (neq ?val nil) (neq ?val ""))
			   then
		   		(printout ?proof-file (start-tag "slot") crlf)
				(if (neq (str-index : ?property) FALSE)
				   then
				   	(printout ?proof-file (empty-element "Ind" uri ?property) crlf)
				   else
					(printout ?proof-file (pcdata-element "Ind" ?property) crlf)
				)
			   	(bind $?datatypes (slot-types ?class ?property))
				(if (or (eq $?datatypes (create$ SYMBOL STRING)) (eq $?datatypes (create$ STRING)))
				   then
				   	(printout ?proof-file (start-tag "Data" xsi:type xs:string))
				   	(printout ?proof-file ?val)
				   	(printout ?proof-file (end-tag "Data") crlf)
				   else
				   	(printout ?proof-file (pcdata-element "Ind" ?val) crlf)
				)
			   	(printout ?proof-file (end-tag "slot") crlf)
			)
		)
		(bind $?properties (rest$ $?properties))
	)
	(printout ?proof-file (end-tag "Atom") crlf)
	(if (eq ?negative-status yes)
	   then
	   	(printout ?proof-file (end-tag "Neg") crlf)
	)
)

(deffunction export-rule (?file ?operand ?tag $?construct)
) ;;; it is defined below, but it is also needed for exporting rules in proofs

(deffunction export-rule-ref (?proof-file ?rule ?rulebase ?export-ns)
)

(deffunction export-proof-for-object (?proof-file ?rulebase ?proof-namespace ?export-ns ?oid ?uri ?proof-id ?truth-status $?exported-classes)
)

(deffunction export-blocked-attackers (?proof-file ?oid ?negative-status ?rule ?rulebase ?proof-namespace ?export-ns $?exported-classes)
)

(deffunction export-body-grounds (?proof-file ?rulebase ?proof-namespace ?export-ns ?tag $?double-list)
	(bind $?body-objects (subseq$ $?double-list 1 (- (member$ $$$ $?double-list) 1)))
	(bind $?exported-classes (subseq$ $?double-list (+ (member$ $$$ $?double-list) 1) (length$ $?double-list)))
	(if (> (length$ $?body-objects) 0)
	   then
	   	(printout ?proof-file (start-tag ?tag) crlf)
		(while (> (length$ $?body-objects) 0)
		   do
		   	(bind ?body-object (nth$ 1 $?body-objects))
		   	(bind $?body-objects (rest$ $?body-objects))
		   	(bind ?body-object-class (class ?body-object))
		   	(bind ?old-proof-id (send ?body-object get-proof))
		   	(if (eq ?old-proof-id nil)
		   	   then
		  	   	(if (is_derived ?body-object-class)
		  	   	   then
		  	   	   	(bind ?new-uri (send ?body-object get-uri))
		  	   	   	(if (and (eq ?new-uri nil) (member$ ?body-object-class $?exported-classes))
		  	   	   	   then
		  	   	   	   	(bind ?new-uri ?body-object)
		  	   	   	   	(bind ?*unexported-uris* (create$ ?*unexported-uris* ?body-object))
		  	   	   	)
		  	   	   	(bind ?new-proof-id (sym-cat proof ?*proof-counter*))
		  	   	   	(send ?body-object put-proof ?new-proof-id)
					(bind ?*proof-counter* (+ ?*proof-counter* 1))
		  	   	   else
		  	   	   	(bind ?new-uri (namespace-to-entity (send ?body-object get-uri)))
		  	   	   	(bind ?new-proof-id nil)
		  	   	)
		  	   	(export-proof-for-object ?proof-file ?rulebase ?proof-namespace ?export-ns ?body-object ?new-uri ?new-proof-id (get-truth-status (send ?body-object get-positive) (send ?body-object get-negative)) $?exported-classes)
		  	   else
		  	   	(printout ?proof-file (empty-element "proof_ref" proof (str-cat "&" ?proof-namespace ";" ?old-proof-id)) crlf)
		  	)
		)
	   	(printout ?proof-file (end-tag ?tag) crlf)
	)
)

(deffunction export-proof-for-object (?proof-file ?rulebase ?proof-namespace ?export-ns ?oid ?uri ?proof-id ?truth-status $?exported-classes)
	(switch ?truth-status
		(case definitely-proven-positive
		   then
		   	(bind ?sub-tag "Definitely_Proved")
		   	(bind ?proof-type "Definite_Proof")
		   	(bind ?negative-status no)
		)
		(case defeasibly-proven-positive
		   then
		   	(bind ?sub-tag "Defeasibly_Proved")
		   	(bind $?derivators (send ?oid get-positive-derivator))
		   	(bind ?derivator-rule (nth$ 1 $?derivators))
		   	(bind ?ruletype (class (symbol-to-instance-name ?derivator-rule)))
		   	(switch ?ruletype
		   		(case strict-rule
		   		   then
		   		   	(bind ?proof-type "Definite_Proof")
		   		)
		   		(case defeasible-rule
		   		   then
		   		   	(bind ?proof-type "Defeasible_Proof")
		   		)
		   	)
		   	(bind ?negative-status no)
		)
		(case defeasibly-proven-negative
		   then
		   	(bind ?sub-tag "Defeasibly_Proved")
		   	(bind $?derivators (send ?oid get-negative-derivator))
		   	(bind ?derivator-rule (nth$ 1 $?derivators))
		   	(bind ?ruletype (class (symbol-to-instance-name ?derivator-rule)))
		   	(switch ?ruletype
		   		(case strict-rule
		   		   then
		   		   	(bind ?proof-type "Definite_Proof")
		   		)
		   		(case defeasible-rule
		   		   then
		   		   	(bind ?proof-type "Defeasible_Proof")
		   		)
		   	)
		   	(bind ?negative-status yes)
		)
		(case definitely-proven-negative
		   then
		   	(bind ?sub-tag "Definitely_Proved")
		   	(bind ?proof-type "Definite_Proof")
		   	(bind ?negative-status yes)
		)
		(case not-defeasibly-proven
		   then
		   	(bind ?sub-tag "Not_Defeasibly_Proved")
		   	(bind ?proof-type "Not_Defeasible_Proof")
		   	(bind $?supporters (send ?oid get-positive-support))
		   	(if (> (length$ $?supporters) 0)
		   	   then
		   		(bind ?negative-status no)
		   	   else
		   	   	(bind $?supporters (send ?oid get-negative-support))
		   	   	(bind ?negative-status yes)
		   	)
		   	;; May be not-proofs should move into a completely different function
		)
	)
	(printout ?proof-file (start-tag ?sub-tag) crlf)
	(if (neq ?proof-id nil)
	   then
		(printout ?proof-file (start-tag "oid") crlf)
		(printout ?proof-file (start-tag "Ind" uri (str-cat "&" ?proof-namespace ";" ?proof-id))) 
		(printout ?proof-file ?proof-id)
		(printout ?proof-file (end-tag "Ind") crlf)
		(printout ?proof-file (end-tag "oid") crlf)
	)
	(printout ?proof-file (start-tag "Literal") crlf)
	(if (and (eq ?*compact-proofs* on) (neq ?uri nil))
	   then
		(if (eq ?negative-status yes)
		     then
		  	(bind ?resource-tag "neg_RDF_resource")
		     else
		   	(bind ?resource-tag "RDF_resource")
		)
		(printout ?proof-file (empty-element ?resource-tag uri ?uri) crlf)
		(register-namespace ?uri ?export-ns)
	   else
	   	(export-literal ?proof-file ?oid ?negative-status)
	)
	(printout ?proof-file (end-tag "Literal") crlf)
	(printout ?proof-file (start-tag ?proof-type) crlf)
	(if (eq ?proof-type "Definite_Proof")
	   then
		(printout ?proof-file (start-tag "strict_clause") crlf)
		(bind ?class (class ?oid))
		(if (is_derived ?class)
		   then
		   	(if (eq ?negative-status no)
		   	   then
		   		(bind $?derivators (send ?oid get-positive-derivator))
		   	   else
		   	   	(bind $?derivators (send ?oid get-negative-derivator))
		   	)
		   	(bind ?derivator-rule (nth$ 1 $?derivators))
		   	(export-rule-ref ?proof-file ?derivator-rule ?rulebase ?export-ns)
		   else
		   	(printout ?proof-file (start-tag "Fact") crlf)
		   	(if (eq ?*compact-proofs* on)
		   	   then
		   		(printout ?proof-file (empty-element "RDF_resource" uri ?uri) crlf)
		   		(register-namespace ?uri ?export-ns)
		   	   else
		   	   	(export-literal ?proof-file ?oid no)
		   	)
		   	(printout ?proof-file (end-tag "Fact") crlf)
		)
		(printout ?proof-file (end-tag "strict_clause") crlf)
		(if (is_derived ?class)
		   then
		   	(bind $?derivator-objects (rest$ $?derivators))
		   	(export-body-grounds ?proof-file ?rulebase ?proof-namespace ?export-ns "definite_body_grounds" (create$ $?derivator-objects $$$ $?exported-classes))
		)
	   else
	   	(if (eq ?proof-type "Defeasible_Proof")
		   then
			(printout ?proof-file (start-tag "supportive_rule") crlf)
			(export-rule-ref ?proof-file ?derivator-rule ?rulebase ?export-ns)
			(printout ?proof-file (end-tag "supportive_rule") crlf)
			(bind $?derivator-objects (rest$ $?derivators))
			(export-body-grounds ?proof-file ?rulebase ?proof-namespace ?export-ns "defeasible_body_grounds" (create$ $?derivator-objects $$$ $?exported-classes))
			(printout ?proof-file (empty-element "not_strongly_attacked") crlf) ; needs further work - probably could not be handled!
			(export-blocked-attackers ?proof-file ?oid ?negative-status ?derivator-rule ?rulebase ?proof-namespace ?export-ns $?exported-classes)
		)
	   else
	   	(if (eq ?proof-type "Not_Defeasible_Proof")
	   	   then
	   		(while (> (length$ $?supporters) 0)
	   		   do
	   		   	(bind ?support-rule (nth$ 1 $?supporters))
	   		   	(bind $?support-objects (get-instances (rest$ $?supporters)))
	   		   	(bind $?supporters (subseq$ $?supporters (+ (length$ $?support-objects) 2) (length$ $?supporters)))
				(printout ?proof-file (start-tag "supportive_rule") crlf)
				(export-rule-ref ?proof-file ?support-rule ?rulebase ?export-ns)
				(printout ?proof-file (end-tag "supportive_rule") crlf)
				(export-body-grounds ?proof-file ?rulebase ?proof-namespace ?export-ns "defeasible_body_grounds" (create$ $?support-objects $$$ $?exported-classes))
				(printout ?proof-file (start-tag "defeasible_attackers_undefeated") crlf)
				(if (eq ?negative-status no)
				   then
					(bind $?undefeated-attackers (send ?oid get-negative-overruled))
				   else
				   	(bind $?undefeated-attackers (send ?oid get-positive-overruled))
				)
				(bind ?support-rule-overruled (sym-cat ?support-rule "-overruled"))
				(while (> (length$ $?undefeated-attackers) 0)
				   do
				   	(bind ?current-overruled-rule (nth$ 1 $?undefeated-attackers))
				   	(bind ?attacker (nth$ 2 $?undefeated-attackers))
				   	(bind $?body-objects (get-instances (rest$ (rest$ $?undefeated-attackers))))
				   	(bind $?undefeated-attackers (subseq$ $?undefeated-attackers (+ (length$ $?body-objects) 3) (length$ $?undefeated-attackers)))
				   	(if (eq ?current-overruled-rule ?support-rule-overruled)
				   	   then
				   	   	(printout ?proof-file (start-tag "Undefeated") crlf)
				   	   	(export-rule-ref ?proof-file ?attacker ?rulebase ?export-ns)
				   	   	(export-body-grounds ?proof-file ?rulebase ?proof-namespace ?export-ns "defeasible_body_grounds" (create$ $?body-objects $$$ $?exported-classes))
						(export-blocked-attackers ?proof-file ?oid (inverse-negation ?negative-status) ?attacker ?rulebase ?proof-namespace ?export-ns $?exported-classes)
				   	   	;(printout ?proof-file (start-tag "defeasible_attackers_blocked") crlf)
				   	   	;(printout ?proof-file (end-tag "defeasible_attackers_blocked") crlf)
				   	   	(printout ?proof-file (end-tag "Undefeated") crlf)
				   	)
				)
				(printout ?proof-file (end-tag "defeasible_attackers_undefeated") crlf)
			)
		)
	)
	(printout ?proof-file (end-tag ?proof-type) crlf)
	(if (eq ?proof-type "Not_Defeasible_Proof")
	   then
	   	(printout ?proof-file (empty-element "Not_Definite_Proof") crlf)
	)
	(printout ?proof-file (end-tag ?sub-tag) crlf)
)

; Normal export
(deffunction dr-device_export_rdf (?rulebase-address ?file ?proof-file $?initial-classes)   ; altered PROOF
	(verbose crlf "Extracting results...")
	(bind ?current-namespace (sub-string 1 (- (str-index ".rdf" ?file) 1) ?file))
	(if (neq ?proof-file nil)
	   then
	   	(bind ?proof-namespace (construct-proof-namespace ?current-namespace))   ; PROOF
		(if (neq (str-index ?*system-export-prefix* ?proof-file) FALSE)
			   then
	  		 	(bind ?out-proof-file (str-replace ?proof-file "C:\\Program Files\\Apache Group\\Apache2\\htdocs\\dr-device\\" ?*system-export-prefix*))
			   else
				(bind ?out-proof-file (str-cat (sym-cat ?proof-file)))
		)
		(open ?out-proof-file ppp "w")
		(export-proof-header ppp ?proof-file ?proof-namespace ?file ?current-namespace ?rulebase-address)
	)
	(bind ?entities (str-cat
		  	"     <!ENTITY rdf \"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">%n"
		  	"     <!ENTITY rdfs \"http://www.w3.org/2000/01/rdf-schema#\">%n"
    			"     <!ENTITY xsd \"http://www.w3.org/2001/XMLSchema#\">%n"
     			"     <!ENTITY defeasible \"http://lpis.csd.auth.gr/systems/dr-device/defeasible.rdfs#\">%n"
		  	"     <!ENTITY " ?current-namespace " \"" ?*system-export-prefix* "export/" ?file "#\"> %n"
		  	(if (eq ?proof-file nil)
		  	   then
		  	   	""
		  	   else
		  	   	(str-cat "     <!ENTITY " ?proof-namespace " \"" ?*system-export-prefix* "proof/" ?proof-file "#\"> %n")
		  	)
	))
	(bind ?namespaces (str-cat
		"     xmlns:rdf='&rdf;'%n"
		"     xmlns:rdfs='&rdfs;'%n" 
		"     xmlns:defeasible='&defeasible;'%n"
		"     xmlns:" ?current-namespace "='&" ?current-namespace ";'%n"
	))
	(bind $?exported-namespaces (create$ rdf rdfs dr-device))
	(bind $?classes-schema $?initial-classes)
	(bind $?examined-classes-schema (create$))
	(bind $?classes-instances $?initial-classes)
	;(bind ?class-text "<rdfs:Class rdf:about='&dr-device;DefeasibleObject'>%n</rdfs:Class>%n%n")
	;(bind $?properties-text (create$ "<rdf:Property rdf:about='&dr-device;truthStatus'>%n     <rdfs:domain rdf:resource='&dr-device;DefeasibleObject'/>%n     <rdfs:range  rdf:resource='&rdfs;Literal'/>%n</rdf:Property>%n"))
	(bind ?class-text "")
	(bind $?properties-text (create$))
	(while (> (length$ $?classes-schema) 0)
	   do
	   	(bind ?class (nth$ 1 $?classes-schema))
	   	(bind $?examined-classes-schema (create$ $?examined-classes-schema ?class))
	   	(bind $?classes-schema (rest$ $?classes-schema))
		(if (is_derived ?class)
		   then
		   	(bind ?namespace-text (str-cat "&" ?current-namespace ";"))
		   	(bind ?namespace (str-cat ?current-namespace ":"))
			(bind ?class-text (str-cat ?class-text "<rdfs:Class rdf:about='" ?namespace-text ?class "'>%n"))
			(bind ?class-instance (symbol-to-instance-name ?class))
			(if (instance-existp ?class-instance)
			   then
				(bind ?meta-class (class ?class-instance))
				(bind $?subclasses (send ?class-instance get-rdfs:subClassOf))
				(bind $?subclasses (delete-member$ $?subclasses [defeasible-class]))
				(bind $?class-properties (delete-member$ (user-slots ?meta-class) rdfs:subClassOf))
				(while (> (length$ $?class-properties) 0)
				   do
				   	(bind ?class-property (nth$ 1 $?class-properties))
				   	(bind $?values (funcall send ?class-instance (sym-cat get- ?class-property)))
				   	(if (eq ?class-property rdf:type)
				   	   then
				   	   	(bind $?values (delete-member$ $?values [rdfs:Class]))
				   	)
				   	(while (> (length$ $?values) 0)
				   	   do
				   	   	(bind ?class-text (str-cat ?class-text 
				   	   		"     <" ?class-property " rdf:resource='" (nth$ 1 $?values) "'/>%n"))
				   	   	(bind $?values (rest$ $?values))
				   	)
				   	(bind $?class-properties (rest$ $?class-properties))
				)
			   else
				(bind $?subclasses (delete-member$ (class-subclasses ?class) RDF-CLASS DERIVED-CLASS TYPED-CLASS))
			)
			(bind $?subclasses (create$ "&defeasible;DefeasibleObject" $?subclasses))
			(while (> (length$ $?subclasses) 0)
			   do
			   	(bind ?class-text (str-cat ?class-text "     <rdfs:subClassOf rdf:resource='" (namespace-to-entity (nth$ 1 $?subclasses)) "'/>%n"))
			   	(bind $?subclasses (rest$ $?subclasses))
			)
			(bind ?class-text (str-cat ?class-text "</rdfs:Class>%n%n"))
			(bind $?properties (user-slots ?class))
			(bind ?end (length$ $?properties))
			(loop-for-count (?n 1 ?end)
			   do
			   	(bind ?property (nth$ ?n $?properties))
			   	(bind ?property-instance (symbol-to-instance-name ?property))
				(bind ?property-text (str-cat 
					"<rdf:Property rdf:about='" ?namespace-text ?property "'>%n" 
					"     <rdfs:domain rdf:resource='" ?namespace-text ?class "'/>%n" ))
				(if (instance-existp ?property-instance)
				   then
			   		(bind $?ranges (send ?property-instance get-rdfs:range))
			   		(bind $?superproperties (send ?property-instance get-rdfs:subPropertyOf))
			   	   else
					(bind $?types (slot-types ?class ?property))
					(if (eq $?types (create$ INSTANCE-NAME))
					   then
					   	(bind ?referenced-class (get-type-of ?class ?property))
					   	(if (is-system-class ?referenced-class)
					   	   then
					   	   	(bind $?ranges (class-superclasses ?referenced-class))
					   	   else
					   		(bind $?ranges (create$ ?referenced-class))
					   	)
					   	(bind ?r-end (length$ $?ranges))
					   	(loop-for-count (?r 1 ?r-end)
					   	   do
					   	   	(bind ?r-class (nth$ ?r $?ranges))
					   		(if (not (member$ ?r-class $?examined-classes-schema))
					 	  	   then
					   			;(bind $?classes-instances (create$ $?classes-instances ?referenced-class))
					   			(if (is_derived ?r-class)
					  	 		   then
					   				(bind $?classes-schema (create$ $?classes-schema ?r-class))
					   			   else
					   			   	(bind ?ns (get-namespace ?r-class))
					   			   	(if (not (str-index ?ns ?entities))
					   			   	   then
					   			   		(bind ?uri (get-ns-uri ?ns))
					   					;(bind ?uri (sub-string 2 (- (str-length ?uri) 1) ?uri)) ; URI is a symbol!
					   			  		(bind ?entities (str-cat ?entities
			  								"     <!ENTITY " ?ns " \"" ?uri "\">%n"))
										(bind ?namespaces (str-cat ?namespaces
											"     xmlns:" ?ns "='&" ?ns ";'%n"))
									)
								)
							)
						)
					   else
					   	(if (same-set$ (create$ $?types $$$ SYMBOL STRING))
					   	   then
					   		(bind $?ranges (create$ rdfs:Literal))
					   	   else
					   	   	(bind $?ranges (create$))
					   	)
					)
					(bind $?superproperties (create$))
				)
				(while (> (length$ $?ranges) 0)
				   do
				   	(bind ?property-text (str-cat ?property-text 
				   	        "     <rdfs:range  rdf:resource='" (namespace-to-entity (nth$ 1 $?ranges)) "'/>%n" ))
				   	(bind $?ranges (rest$ $?ranges))
				)
				(while (> (length$ $?superproperties) 0)
				   do
				   	(bind ?property-text (str-cat ?property-text 
				   	        "     <rdfs:subPropertyOf  rdf:resource='" (namespace-to-entity (nth$ 1 $?superproperties)) "'/>%n" ))
				   	(bind $?superproperties (rest$ $?superproperties))
				)
				(bind ?property-text (str-cat ?property-text "</rdf:Property>%n"))
				(bind $?properties-text (create$ $?properties-text ?property-text))
				;(bind $?properties (rest$ $?properties))
			)
		   else
			(bind ?ns (get-namespace ?class))
		   	(if (and (neq ?ns FALSE) (not (member$ ?ns $?exported-namespaces)))
		   	   then
		   		(bind ?uri (get-ns-uri ?ns))
		   		;(bind ?uri (sub-string 2 (- (str-length ?uri) 1) ?uri)) ; URI is a symbol!
		   		(bind ?entities (str-cat ?entities
		   			"     <!ENTITY " ?ns " \"" ?uri "\">%n"))
		   		(bind ?namespaces (str-cat ?namespaces
		   			"     xmlns:" ?ns "='&" ?ns ";'%n"))
		   		(bind $?exported-namespaces (create$ $?exported-namespaces ?ns))
			)
		)
	)
;	(open (str-cat "C:\\Program Files\\Apache\\r-device\\export\\" ?file) ttt "w")
	(if (neq (str-index ?*system-export-prefix* ?file) FALSE)
	   then
	   	(bind ?out-file (str-replace ?file "C:\\Program Files\\Apache Group\\Apache2\\htdocs\\dr-device\\" ?*system-export-prefix*))
	   else
		(bind ?out-file (str-cat (sym-cat ?file)))
	)
	(bind ?file-status (open ?out-file ttt "w"))
	(printout ttt
		"<?xml version='1.0' encoding=\"UTF-8\"?>" crlf
		"<!DOCTYPE rdf:RDF [" crlf)
	(format ttt ?entities)
	(printout ttt 
		"]>" crlf crlf)
	(printout ttt 
		"<rdf:RDF" crlf)
	(format ttt ?namespaces)
	(printout ttt 
		">" crlf crlf)
	(format ttt ?class-text)
	(printout ttt crlf)
	(while (> (length$ $?properties-text) 0)
	   do
	   	(format ttt (nth$ 1 $?properties-text))
		(printout ttt crlf)
	   	(bind $?properties-text (rest$ $?properties-text))
	)
	; Add actual result objects
	(bind $?printed-instances (create$))
	(bind $?not-printed-instances (create$))
	(if (neq ?proof-file nil)
	   then
		(bind ?*proof-counter* 1)
	)
	(while (> (length$ $?classes-instances) 0)
	  do
	  	(bind ?class (nth$ 1 $?classes-instances))
	  	(bind $?classes-instances (rest$ $?classes-instances))
	  	(if (is_derived ?class)
		   then
		   	(bind ?namespace (str-cat ?current-namespace ":"))
		   else
		   	(bind ?namespace "")
		)
		(bind ?inst-counter 1)
		(bind $?properties (user-slots ?class))
		(bind ?end (length$ $?properties))
		(do-for-all-instances ((?x ?class))
			(or 	(eq ?*export-non-proved* on)
				(and (eq ?*export-non-proved* off) (or (> ?x:positive 0) (> ?x:negative 0))))
			(bind $?printed-instances (create$ $?printed-instances ?x))
			(if (is_derived ?class)
			   then
			   	(bind ?uri (str-cat ?namespace-text ?class ?inst-counter))
				(bind ?inst-counter (+ ?inst-counter 1))
				(printout ttt "<" ?namespace ?class " rdf:about='" ?uri "'>" crlf)
				(send ?x put-uri ?uri)
			   else
			   	; The following is to cater for classes as instances as well
			   	; It must be completed in the future.
			   	;(if (class-existp (instance-name-to-symbol ?x))
			   	;   then
			   	;   	(if (eq ?x:source rdf)
			   	;   	   then
			   	;   		(bind ?ns (get-namespace (instance-name-to-symbol ?x)))
			   	;   		(bind ?label (get-label (instance-name-to-symbol ?x)))
				;   		(bind ?uri (str-cat (get-ns-uri ?ns) ?label))
				;   	   else
				;	)
				;   	   	
				;   else
				; )
				(bind ?uri ?x:uri)
				;(bind ?uri (sub-string 2 (- (str-length ?uri) 1) ?uri)) ; URI is a symbol!
			   	(printout ttt "<rdf:Description about='" ?uri "'>" crlf)
			)
			(loop-for-count (?n 1 ?end)
			   do
			   	(bind ?property (nth$ ?n $?properties))
			   	(if (is-multislot ?class ?property)
			   	   then
			   		(bind $?values ?x:?property)
				   	(while (> (length$ $?values) 0)
				   	   do
				   		(printout ttt "     <" ?namespace ?property ">")
				   		(bind ?val (nth$ 1 $?values))
				   		(if (instancep ?val)
				   		   then
				   		   	(bind ?value (send ?val get-uri))
				   		   	;(bind ?value (sub-string 2 (- (str-length ?value) 1) ?value)) ; URI is a symbol!
				   		   	(if (not (member$ ?val $?printed-instances))
				   		   	   then
								(bind $?not-printed-instances (create$ $?not-printed-instances ?val))
							)
				   		   else
				   		   	(bind ?value ?val)
				   		)
				   		(printout ttt ?value)
				   		(printout ttt "</" ?namespace ?property ">" crlf)
				   		(bind $?values (rest$ $?values))
				   	)
				   else
				   	(bind ?val ?x:?property)
				   	(if (neq ?val nil)
				   	   then
				   	   	(printout ttt "     <" ?namespace ?property ">")
				   	   	(if (instancep ?val)
				   		   then
				   		   	(bind ?value (send ?val get-uri))
				   		   	;(bind ?value (sub-string 2 (- (str-length ?value) 1) ?value)) ; URI is a symbol!
				   		   	(if (not (member$ ?val $?printed-instances))
				   		   	   then
								(bind $?not-printed-instances (create$ $?not-printed-instances ?val))
							)
				   		   else
				   		   	(bind ?value ?val)
				   		)
				   		(printout ttt ?value)
				   	   	(printout ttt "</" ?namespace ?property ">" crlf)
				   	)
				)
			)
			
			;	(if (slot-existp ?class modality inherit)
			;	   then
			;		(printout ?proof-file (start-tag "Atom" modality (send ?oid get-modality)) crlf)
			;	   else
			;	   	(printout ?proof-file (start-tag "Atom") crlf)
			;	)
			(if (slot-existp (class ?x) modality inherit)
			   then
				(printout ttt "     <defeasible:modality>" ) ; MODALITIES
				(bind ?modality (get-modality ?x:modality))
				(printout ttt ?modality)
				(printout ttt "</defeasible:modality>" crlf)
			)
			(printout ttt "     <defeasible:truthStatus>" )
			(bind ?truth-status (get-truth-status ?x:positive ?x:negative))
			(printout ttt ?truth-status)
			(printout ttt "</defeasible:truthStatus>" crlf)
			; PROOF - begin
		  	(if (neq ?proof-file nil)
		  	   then
				(if (eq ?x:proof nil)
				   then
					(bind ?proof-id (sym-cat proof ?*proof-counter*))
					(bind ?*proof-counter* (+ ?*proof-counter* 1))
					(send ?x put-proof ?proof-id)
					;(printout ppp (start-tag "Proved") crlf)
					(export-proof-for-object ppp ?rulebase-address ?proof-namespace ?current-namespace ?x ?uri ?proof-id ?truth-status $?initial-classes)
					;(printout ppp (end-tag "Proved") crlf)
				   else
				   	(bind ?proof-id ?x:proof)
				)
				(printout ttt "     <defeasible:proof rdf:datatype='&xsd;anyURI'>")
				(printout ttt "&" ?proof-namespace ";" ?proof-id)
				(printout ttt "</defeasible:proof>" crlf)
			)
			; PROOF - end
			(if (is_derived ?class)
			   then
				(printout ttt "</" ?namespace ?class ">" crlf crlf)
			   else
				(printout ttt "</rdf:Description>" crlf crlf)
			)
		)
	)
	(bind ?inst-counter 1)
	(while (> (length$ $?not-printed-instances) 0)
	   do
	   	(bind ?x (nth$ 1 $?not-printed-instances))
	   	(bind $?not-printed-instances (rest$ $?not-printed-instances))
	   	(bind $?printed-instances (create$ $?printed-instances ?x))
	   	(bind ?class (class ?x))
		(bind $?properties (user-slots ?class))
		(bind ?end (length$ $?properties))
	  	(if (is_derived ?class)
		   then
		   	(bind ?namespace (str-cat ?current-namespace ":"))
		   	(bind ?uri (str-cat ?namespace-text ?class ?inst-counter))
			(bind ?inst-counter (+ ?inst-counter 1))
			(printout ttt "<" ?namespace ?class " rdf:about=\"" ?uri "\">" crlf)
		   else
		   	(bind ?namespace "")
		   	; The following must be completed in the future 
		   	; to cater for classes as instances as well
			(bind ?uri (send ?x get-uri))
			;(bind ?uri (sub-string 2 (- (str-length ?uri) 1) ?uri)) ; URI is a symbol!
		   	(printout ttt "<rdf:Description about=\"" ?uri "\">" crlf)
		)
		(loop-for-count (?n 1 ?end)
		   do
		   	(bind ?property (nth$ ?n $?properties))
		   	(if (is-multislot ?class ?property)
		   	   then
		   		(bind $?values (funcall send ?x (sym-cat get- ?property)))
			   	(while (> (length$ $?values) 0)
			   	   do
			   		(printout ttt "     <" ?namespace ?property ">")
			   		(bind ?val (nth$ 1 $?values))
			   		(if (instancep ?val)
			   		   then
			   		   	(bind ?value (send ?val get-uri))
			   		   	;(bind ?value (sub-string 2 (- (str-length ?value) 1) ?value)) ; URI is a symbol!
			   		   	(if (not (member$ ?val $?printed-instances))
			   		   	   then
							(bind $?not-printed-instances (create$ $?not-printed-instances ?val))
						)
			   		   else
			   		   	(bind ?value ?val)
			   		)
			   		(printout ttt ?value)
			   		(printout ttt "</" ?namespace ?property ">" crlf)
			   		(bind $?values (rest$ $?values))
			   	)
			   else
			   	(bind ?val (funcall send ?x (sym-cat get- ?property)))
			   	(if (neq ?val nil)
			   	   then
			   	   	(printout ttt "     <" ?namespace ?property ">")
			   	   	(if (instancep ?val)
			   		   then
			   		   	(bind ?value (send ?val get-uri))
			   		   	;(bind ?value (sub-string 2 (- (str-length ?value) 1) ?value)) ; URI is a symbol!
			   		   	(if (not (member$ ?val $?printed-instances))
			   		   	   then
							(bind $?not-printed-instances (create$ $?not-printed-instances ?val))
						)
			   		   else
			   		   	(bind ?value ?val)
			   		)
			   		(printout ttt ?value)
			   	   	(printout ttt "</" ?namespace ?property ">" crlf)
			   	)
			)
		)
		(if (is_derived ?class)
		   then
			(printout ttt "</" ?namespace ?class ">" crlf crlf)
		   else
			(printout ttt "</rdf:Description>" crlf crlf)
		)
	)
	(printout ttt "</rdf:RDF>" crlf)
	(close ttt)
	(if (neq ?proof-file nil)
	   then
		(export-proof-footer ppp)
		(close ppp)
	)
	; Handle RDF URI references in proof file that were not referenced
	(if (neq ?proof-file nil)
	   then
		;(replace-unexported-uris ?proof-file ?*unexported-uris*)
		; commented because of error when using superiority relation
	)
	(verbose " ok" crlf crlf)
	TRUE
)


; Export a rulebase to RuleML 0.91


(deffunction strip-var (?var)
	(bind ?var (str-cat ?var))
	(return (sub-string 2 (str-length ?var) ?var))
)

(deffunction transform-function (?function)
	(str-replace (str-replace ?function "&lt;" "<") "&gt;" ">")

)

(deffunction print-argument (?file ?tag $?argument)
)

(deffunction print-expression (?file $?argument)
   	(printout ?file "<Expr>" crlf)
   	(printout ?file "<Fun in=\"yes\">" (transform-function (nth$ 2 $?argument)) "</Fun>" crlf)
   	(bind $?arguments (subseq$ $?argument 3 (- (length$ $?argument) 1)))
   	(while (> (length$ $?arguments) 0)
   	   do
   		(if (eq (nth$ 1 $?arguments) "(")
   		   then
   		   	(bind ?p2 (get-token $?arguments))
   		   	(bind $?first-argument (subseq$ $?arguments 1 ?p2))
   		   	(bind $?arguments (subseq$ $?arguments (+ ?p2 1) (length$ $?arguments)))
   		   	(print-argument ?file ind $?first-argument)
   		   else
   			(if (is-var (nth$ 1 $?arguments))
		   	   then
		   	   	(printout ?file "<Var>" (strip-var (nth$ 1 $?arguments)) "</Var>" crlf)
		   	   else
		   	   	(printout ?file "<Ind>" (nth$ 1 $?arguments) "</Ind>" crlf)
		   	)
   		   	(bind $?arguments (subseq$ $?arguments 2 (length$ $?arguments)))
   		)
   	)
   	(printout ?file "</Expr>" crlf)
)


(deffunction print-complex-argument (?file ?operator $?argument)
	(while (> (length$ $?argument) 0)
	   do
		(bind ?pos (member$ ?operator $?argument))
		(if (eq ?pos FALSE)
		   then
		   	(print-argument ?file ind $?argument)
		   	(break)
		   else
		   	(bind $?first-argument (subseq$ $?argument 1 (- ?pos 1)))
		   	(print-argument ?file ind $?first-argument)
		   	(bind $?argument (subseq$ $?argument (+ ?pos 1) (length$ $?argument)))
		)
	)
)

(deffunction print-argument (?file ?tag $?argument)
	(if (= (length$ $?argument) 1)
	   then
	   	(if (is-var (nth$ 1 $?argument))
	   	   then
	   	   	(printout ?file "<Var>" (strip-var (nth$ 1 $?argument)) "</Var>" crlf)
	   	   else
	   	   	(if (eq ?tag data)
	   	   	   then
	   	   	   	(printout ?file "<Data xsi:type=\"xs:string\">" (nth$ 1 $?argument) "</Data>" crlf)
	   	   	   else
	   	   		(printout ?file "<Ind>" (nth$ 1 $?argument) "</Ind>" crlf)
	   	   	)
	   	)
	   else
   		(if (eq (nth$ 1 $?argument) "(")
   		   then
	   		(print-expression ?file $?argument)
	   	   else
	   	   	(if (and (eq (nth$ 1 $?argument) :) (eq (nth$ 2 $?argument) "("))
	   	   	   then
	   	   	   	(print-expression ?file (rest$ $?argument))
		   	   else
		   	   	(if (and (= (length$ $?argument) 2) (eq (nth$ 1 $?argument) "~"))
		   	   	   then
		   	   	   	;(printout ?file "<ComplexArg>" crlf)
		   	   	   	(printout ?file "<not_Arg>" crlf)
		   	   	   	(print-argument ?file ind (nth$ 2 $?argument))
		   	   	   	(printout ?file "</not_Arg>" crlf)
		   	   	   	;(printout ?file "</ComplexArg>" crlf)
		   	   	   else
		   	   	   	(if (member$ "|" $?argument)
		   	   	   	   then
		   	   	   	   	(printout ?file "<ComplexArg>" crlf)
		   	   	   	   	(printout ?file "<or_ComplexArg>" crlf)
		   	   	   	   	(print-complex-argument ?file "|" $?argument)
		   	   	   	   	(printout ?file "</or_ComplexArg>" crlf)
		   	   	   		(printout ?file "</ComplexArg>" crlf)
		   	   	   	   else
		   	   	   	   	(if (member$ "&" $?argument)
		   	   	   	   	   then
		   	   	   	   		(printout ?file "<ComplexArg>" crlf)
		   	   	   	   		(printout ?file "<and_ComplexArg>" crlf)
		   	   	   	   		(print-complex-argument ?file "&" $?argument)
		   	   	   	   		(printout ?file "</and_ComplexArg>" crlf)
		   	   	   			(printout ?file "</ComplexArg>" crlf)
		   	   	   		)
		   	   	   	)
		   	   	)
		   	)
	   	)
	)
)

(deffunction print-atoms (?file $?atoms)
)

(deffunction print-atom (?file $?atom)
	(if (eq (nth$ 2 $?atom) test)
	   then
	   	(printout ?file "<Equal>" crlf)
	   	(bind $?function (subseq$ $?atom 3 (- (length$ $?atom) 1)))
		(print-expression ?file $?function)
	   	(printout ?file "<Ind>true</Ind>" crlf)
	   	(printout ?file "</Equal>" crlf)
	   	(return)
;					<Equal>
;						<Expr>
;							<Fun in="yes">compatible-modality</Fun>
;							<Ind>deviant</Ind>
;							<Var>sy64</Var>
;							<Ind>bel</Ind>
;						</Expr>
;						<Ind>true</Ind>
;					</Equal>
	)
	(if (eq (nth$ 2 $?atom) naf)
	   then
	   	(bind ?naf yes)
	   	(bind $?atoms (subseq$ $?atom 3 (- (length$ $?atom) 1)))
	   	(printout ?file "<Naf>" crlf)
	   	(print-atoms ?file $?atoms)
	   	(printout ?file "</Naf>" crlf)
	   	(return)
	)
	(if (eq (nth$ 2 $?atom) not)
	   then
	   	(bind ?negative yes)
	   	(bind ?class (nth$ 4 $?atom))
	   	(bind $?slots (subseq$ $?atom 5 (- (length$ $?atom) 2)))
	   else
	   	(bind ?negative no)
		(bind ?class (nth$ 2 $?atom))
	   	(bind $?slots (subseq$ $?atom 3 (- (length$ $?atom) 1)))
	)
	(if (eq ?negative yes)
	   then
	   	(printout ?file "<Neg>" crlf)
	)
	(printout ?file "<Atom>" crlf)
	(printout ?file "<op>" crlf)
	(if (neq (str-index : ?class) FALSE)
	   then
	   	(printout ?file "<Rel uri=\"" ?class "\"/>" crlf)
	   else
		(printout ?file "<Rel>" ?class "</Rel>" crlf)
	)
	(printout ?file "</op>" crlf)
	(while (> (length$ $?slots) 0)
	   do
	   	(bind ?p2 (get-token $?slots))
	   	(bind $?slot (subseq$ $?slots 1 ?p2))
	   	(bind ?slot-name (nth$ 2 $?slot))
	   	(printout ?file "<slot>" crlf)
		(if (neq (str-index : ?slot-name) FALSE)
		   then
		   	(printout ?file "<Ind uri=\"" ?slot-name "\"/>" crlf)
		   else
			(printout ?file "<Ind>" ?slot-name "</Ind>" crlf)
		)
		(bind $?arg (subseq$ $?slot 3 (- (length$ $?slot) 1)))
		(bind $?datatypes (slot-types ?class ?slot-name))
		(if (or (eq $?datatypes (create$ SYMBOL STRING)) (eq $?datatypes (create$ STRING)))
		   then
		   	(bind ?tag data)
		   else
		   	(bind ?tag ind)
		)
		(print-argument ?file ?tag $?arg)
		;(printout ?file "<Var>" (strip-var (nth$ 3 $?slots)) "</Var>" crlf)
		(printout ?file "</slot>" crlf)
		(bind $?slots (subseq$ $?slots (+ ?p2 1) (length$ $?slots)))
	)
	(printout ?file "</Atom>" crlf)
	(if (eq ?negative yes)
	   then
	   	(printout ?file "</Neg>" crlf)
	)
)

(deffunction print-atoms (?file $?atoms)
	(bind ?print-and no)
	(if (eq (nth$ 2 $?atoms) and)
	   then
	   	(bind ?print-and yes)
	   	(bind $?atoms (subseq$ $?atoms 3 (- (length$ $?atoms) 1)))
	   else
		(bind ?atoms-length 0)
		(bind $?atoms-copy $?atoms)
		(while (> (length$ $?atoms-copy) 0)
		   do
		   	(bind ?p2 (get-token $?atoms-copy))
		   	(bind ?atoms-length (+ ?atoms-length 1))
		   	(bind $?atoms-copy (subseq$ $?atoms-copy (+ ?p2 1) (length$ $?atoms-copy)))
		)
		(if (> ?atoms-length 1)
		   then
		   	(bind ?print-and yes)
		)
	)
	(if (eq ?print-and yes)
	   then
	   	(printout ?file "<And>" crlf)
	)
	(while (> (length$ $?atoms) 0)
	   do
	   	(bind ?p2 (get-token $?atoms))
	   	(bind $?atom (subseq$ $?atoms 1 ?p2))
	   	(print-atom ?file $?atom)
	   	(bind $?atoms (subseq$ $?atoms (+ ?p2 1) (length$ $?atoms)))
	)
	(if (eq ?print-and yes)
	   then
	   	(printout ?file "</And>" crlf)
	)
)

(deffunction export-rule (?file ?operand ?tag $?construct)
	(bind ?rule-oid (nth$ 3 $?construct))
	(printout ?file "<" ?tag " ruletype=\"" ?operand "\">" crlf)
	(printout ?file "<oid>" crlf)
	(printout ?file "<Ind uri=\"" ?rule-oid "\">" ?rule-oid "</Ind>" crlf)
	(printout ?file "</oid>" crlf)
	(bind ?imp (member$ => $?construct))
	(bind $?body (subseq$ $?construct 4 (- ?imp 1)))
	(bind $?head (subseq$ $?construct (+ ?imp 1) (- (length$ $?construct) 1)))
	(if (eq (nth$ 2 $?body) declare)
	   then
	   	(bind ?p2 (get-token $?body))
	   	(bind $?inferior-rules (subseq$ $?body 5 (- ?p2 2)))
	   	(bind $?body (subseq$ $?body (+ ?p2 1) (length$ $?body)))
	   else
	   	(bind $?inferior-rules (create$))
	)
	(printout ?file "<head>" crlf)
	(if (eq (nth$ 2 $?head) calc)
	   then
	   	(bind ?p2 (get-token $?head))
	   	(bind $?equations (subseq$ $?head 3 (- ?p2 1)))
	   	(bind $?head (subseq$ $?head (+ ?p2 1) (length$ $?head)))
	   	(while (> (length$ $?equations) 0)
	   	   do
			(printout ?file "<Equal oriented=\"yes\">" crlf)
			(bind ?p2 (get-token $?equations))
			(bind $?equation (subseq$ $?equations 1 ?p2))
			(bind $?equations (subseq$ $?equations (+ ?p2 1) (length$ $?equations)))
			(printout ?file "<Var>" (strip-var (nth$ 3 $?equation)) "</Var>" crlf)
			(print-argument ?file ind (subseq$ $?equation 4 (- (length$ $?equation) 1)))
			(printout ?file "</Equal>" crlf)
		)
	)
	(print-atom ?file $?head)
	(printout ?file "</head>" crlf)
	(printout ?file "<body>" crlf)
	(print-atoms ?file $?body)
	(printout ?file "</body>" crlf)
	(while (> (length$ $?inferior-rules) 0)
	   do
		(printout ?file "<superior>" crlf)
		(printout ?file "<Ind uri=\"" (nth$ 1 $?inferior-rules) "\"/>" crlf)
		(printout ?file "</superior>" crlf)
		(bind $?inferior-rules (rest$ $?inferior-rules))
	)
	(printout ?file "</" ?tag  ">" crlf)
)

(deffunction export-rule-ref (?proof-file ?rule ?rulebase ?export-ns)
	(if (eq ?*compact-proofs* on)
	   then
		(bind ?rule-uri (get-rule-uri ?rule ?rulebase ?export-ns))
		(printout ?proof-file (empty-element "rule_ref" rule ?rule-uri) crlf)
	   else
	   	(bind ?rule-oid (symbol-to-instance-name (sym-cat ?rule)))
	   	(bind ?rule-type (sym-cat (str-del (class ?rule-oid) "-")))
		(bind $?rule-construct (create$ "(" ?rule-type (explode$ (send ?rule-oid get-original-rule)) ")"))
	   	(export-rule ?proof-file ?rule-type (get-rule-tag ?rule-type) $?rule-construct)
	)
)

(deffunction export-blocked-attackers (?proof-file ?oid ?negative-status ?rule ?rulebase ?proof-namespace ?export-ns $?exported-classes)
	(printout ?proof-file (start-tag "defeasible_attackers_blocked") crlf)
	(if (eq ?negative-status no)
	   then
		(bind $?defeated-attackers (send ?oid get-negative-defeated))
		(bind $?blocked-attackers (send ?oid get-negative-overruled))
		(bind $?attacker-supporters (send ?oid get-negative-support))
	   else
	   	(bind $?defeated-attackers (send ?oid get-positive-defeated))
		(bind $?blocked-attackers (send ?oid get-positive-overruled))
		(bind $?attacker-supporters (send ?oid get-positive-support))
	)
	(bind $?attacker-rules (create$))
	(while (> (length$ $?defeated-attackers) 0)
	   do
	   	(printout ?proof-file (start-tag "Blocked") crlf)
	   	(printout ?proof-file (start-tag "Blocked_Defeasible_rule") crlf)
	   	(bind ?attacker (nth$ 2 $?defeated-attackers))
	   	(bind $?attacker-rules (create$ $?attacker-rules ?attacker))
	   	(export-rule-ref ?proof-file ?attacker ?rulebase ?export-ns)
	   	(while (> (length$ $?attacker-supporters) 0)
	   	   do
	   	   	(bind ?current-attacker-rule (nth$ 1 $?attacker-supporters))
	   		(bind $?body-objects (get-instances (rest$ $?attacker-supporters)))
	   		(bind $?attacker-supporters (subseq$ $?attacker-supporters (+ (length$ $?body-objects) 2) (length$ $?attacker-supporters)))
	   		(if (eq ?current-attacker-rule ?attacker)
	   		   then
				(export-body-grounds ?proof-file ?rulebase ?proof-namespace ?export-ns "defeasible_body_grounds" (create$ $?body-objects $$$ $?exported-classes))
				(break)
			)
		)
	   	(printout ?proof-file (start-tag "Attacked_by_Superior") crlf)
	   	(bind ?superior-rule (nth$ 1 $?defeated-attackers))
	   	(bind ?superior-rule (sym-cat (str-del ?superior-rule "-defeated")))
	   	(export-rule-ref ?proof-file ?superior-rule ?rulebase ?export-ns)
	   	(if (eq ?negative-status no)
	   	   then
	   		(bind $?counter-attacker-supporters (send ?oid get-positive-support))
	   	   else
	   	   	(bind $?counter-attacker-supporters (send ?oid get-negative-support))
	   	)
	   	(while (> (length$ $?counter-attacker-supporters) 0)
	   	   do
	   	   	(bind ?current-counter-attacker-rule (nth$ 1 $?counter-attacker-supporters))
	   		(bind $?body-objects (get-instances (rest$ $?counter-attacker-supporters)))
	   		(bind $?counter-attacker-supporters (subseq$ $?counter-attacker-supporters (+ (length$ $?body-objects) 2) (length$ $?counter-attacker-supporters)))
	   		(if (eq ?current-counter-attacker-rule ?superior-rule)
	   		   then
				(export-body-grounds ?proof-file ?rulebase ?proof-namespace ?export-ns "defeasible_body_grounds" (create$ $?body-objects $$$ $?exported-classes))
				(break)
			)
		)
	   	(printout ?proof-file (end-tag "Attacked_by_Superior") crlf)
	   	(printout ?proof-file (end-tag "Blocked_Defeasible_rule") crlf)
	   	(printout ?proof-file (end-tag "Blocked") crlf)
	   	(bind $?defeated-attackers (rest$ (rest$ $?defeated-attackers)))
	)
	(bind ?rule-overruled (sym-cat ?rule "-overruled"))
	(while (> (length$ $?blocked-attackers) 0)
	   do
	   	(bind ?current-overruled-rule (nth$ 1 $?blocked-attackers))
	   	(bind ?attacker (nth$ 2 $?blocked-attackers))
	   	(bind $?body-objects (get-instances (rest$ (rest$ $?blocked-attackers))))
	   	(bind $?blocked-attackers (subseq$ $?blocked-attackers (+ (length$ $?body-objects) 3) (length$ $?blocked-attackers)))
	   	(if (and (eq ?current-overruled-rule ?rule-overruled) (not (member$ ?attacker $?attacker-rules)))
	   	   then
	   		(printout ?proof-file (start-tag "Blocked") crlf)
	   		(printout ?proof-file (start-tag "Blocked_Defeasible_rule") crlf)
	   		(export-rule-ref ?proof-file ?attacker ?rulebase ?export-ns)
	   		(export-body-grounds ?proof-file ?rulebase ?proof-namespace ?export-ns "defeasible_body_grounds" (create$ $?body-objects $$$ $?exported-classes))
	   		(printout ?proof-file (start-tag "Attacked_by_not_Inferior") crlf)
	   		(bind ?not-inferior-rule (str-del ?current-overruled-rule "-overruled"))
	   		(export-rule-ref ?proof-file ?not-inferior-rule ?rulebase ?export-ns)
   			(if (eq ?negative-status yes)
			   then
				(bind $?counter-attackers (send ?oid get-negative-overruled))
			   else
				(bind $?counter-attackers (send ?oid get-positive-overruled))
			)
			(bind ?attacker-rule-overruled (sym-cat ?attacker "-overruled"))
			(while (> (length$ $?counter-attackers) 0)
			   do
			   	(bind ?current-attacker-overruled-rule (nth$ 1 $?counter-attackers))
			   	(bind ?counter-attacker (nth$ 2 $?counter-attackers))
			   	(bind $?body-objects (get-instances (rest$ (rest$ $?counter-attackers))))
			   	(bind $?counter-attackers (subseq$ $?counter-attackers (+ (length$ $?body-objects) 3) (length$ $?counter-attackers)))
			   	(if (eq ?current-attacker-overruled-rule ?attacker-rule-overruled)
			   	   then
			   	   	(export-body-grounds ?proof-file ?rulebase ?proof-namespace ?export-ns "defeasible_body_grounds" (create$ $?body-objects $$$ $?exported-classes))
			   	)
			)
	   		(printout ?proof-file (end-tag "Attacked_by_not_Inferior") crlf)
	   		(printout ?proof-file (end-tag "Blocked_Defeasible_rule") crlf)
	   		(printout ?proof-file (end-tag "Blocked") crlf)
	   	)
	   	(bind $?blocked-attackers (rest$ (rest$ $?blocked-attackers)))
	)
	(printout ?proof-file (end-tag "defeasible_attackers_blocked") crlf)
)

(deffunction print-list (?file $?list)
;	(bind ?c 1)
	(printout ?file "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" crlf) ; XML header
	; Start RuleML (header) tag
	(printout ?file "<RuleML ")
	; import-rdf attribute start
	(bind ?p1 (member$ import-rdf $?list))
	(bind $?before (subseq$ $?list 1 (- ?p1 2)))
	(bind $?main (subseq$ $?list (- ?p1 1) (length$ $?list)))
	(bind ?p2 (get-token $?main))
	(bind $?import-files (subseq$ $?main 3 (- ?p2 1)))
	(bind $?main (subseq$ $?main (+ ?p2 1) (length$ $?main)))
	(printout ?file "rdf_import='" (implode$ $?import-files) "' ")
	(bind $?list (create$ $?before $?main))
	; import-rdf attribute end
	; export-rdf attribute start
	(bind ?p1 (member$ export-rdf $?list))
	(bind $?before (subseq$ $?list 1 (- ?p1 2)))
	(bind $?main (subseq$ $?list (- ?p1 1) (length$ $?list)))
	(bind ?p2 (get-token $?main))
	(bind ?export-file (nth$ 3 $?main))
	(bind $?export-classes (subseq$ $?main 4 (- ?p2 1)))
	(bind $?main (subseq$ $?main (+ ?p2 1) (length$ $?main)))
	(printout ?file "rdf_export='\"" ?export-file "\"' ")
	(printout ?file "rdf_export_classes=\"" (implode$ $?export-classes) "\" ")
	(bind $?list (create$ $?before $?main))
	; export-rdf attribute end
	(printout ?file "xmlns=\"http://www.ruleml.org/0.91/xsd\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xsi:schemaLocation=\"http://www.ruleml.org/0.91/xsd http://lpis.csd.auth.gr/systems/dr-device/dr-device-0.81.xsd\">" crlf)
	(printout ?file "<oid>" crlf)
	(printout ?file "<Ind type=\"defeasible\">" ?*rule-base-oid* "</Ind>" crlf)
	(printout ?file "</oid>" crlf)
	(printout ?file "<Assert>" crlf)
	(while (> (length$ $?list) 0)
	  do
	  	(bind ?p2 (get-token $?list))
	  	(bind $?construct (subseq$ $?list 1 ?p2))
	  	(bind $?list (subseq$ $?list (+ ?p2 1) (length$ $?list)))
	  	(bind ?operand (nth$ 2 $?construct))
	  	(if (or (eq ?operand strictrule) (eq ?operand defeasiblerule) (eq ?operand defeater))
	  	   then
	  	   	(export-rule ?file ?operand "Implies" $?construct)
	  	   else
	  	   	(printout ?file "<Competing_rules>" crlf)
			(printout ?file "<oid>" crlf)
			(printout ?file "<Ind uri=\"" (nth$ 3 $?construct) "\">" (nth$ 3 $?construct) "</Ind>" crlf)
			(printout ?file "</oid>" crlf)
			(bind ?pos (member$ _on_slots_ $?construct))
			(if (eq ?pos FALSE)
			   then
			   	(bind $?comp-rules (subseq$ $?construct 4 (- (length$ $?construct) 1)))
			   	(bind $?unique-slots (create$))
			   else
			   	(bind $?comp-rules (subseq$ $?construct 4 (- ?pos 1)))
			   	(bind $?unique-slots (subseq$ $?construct (+ ?pos 1) (- (length$ $?construct) 1)))
			)
			(while (> (length$ $?comp-rules) 0)
			   do
			   	(printout ?file "<competing_rule>" crlf)
				(printout ?file "<Ind uri=\"" (nth$ 1 $?comp-rules) "\"/>" crlf)
			   	(printout ?file "</competing_rule>" crlf)
			   	(bind $?comp-rules (rest$ $?comp-rules))
			)
			(while (> (length$ $?unique-slots) 0)
			   do
			   	(printout ?file "<unique_slot>" crlf)
				(printout ?file "<Ind>" (nth$ 1 $?unique-slots) "</Ind>" crlf)
			   	(printout ?file "</unique_slot>" crlf)
			   	(bind $?unique-slots (rest$ $?unique-slots))
			)
	  	   	(printout ?file "</Competing_rules>" crlf)
	  	)
	)
	(printout ?file "</Assert>" crlf)
	(printout ?file "</RuleML>" crlf)
)

(deffunction convert-to-ruleml (?file-in ?file-out)
	(bind ?*rule-base-oid* (sub-string 1 (- (str-index ".clp" ?file-in) 1) ?file-in))
	(bind $?file-list (create$))
	(open ?file-in clp "r")
	(bind ?line (readline clp))
	(while (neq ?line EOF)
	  do
	  	(bind $?file-list (create$ $?file-list (explode$ ?line)))
		(bind ?line (readline clp))
	)
	(close clp)
	(open ?file-out ruleml "w")
	(print-list ruleml $?file-list)
	(close ruleml)
)

(deffunction export-to-ruleml (?file-out)
	(bind ?*rule-base-oid* (sub-string 1 (- (str-index ".ruleml" ?file-out) 1) ?file-out))
	(bind $?constructs (create$
		"(" import-rdf ?*imported-rdf-files* ")"
		"(" export-rdf (str-cat "export-" ?*rule-base-oid* ".rdf")  ?*exported-derived-classes* ")"
		
	))
	(do-for-all-instances ((?x defeasible-logic-rule))
		(eq ?x:system no)
		(bind $?constructs (create$ $?constructs "(" (sym-cat (str-del (class ?x) "-")) (explode$ ?x:original-rule) ")"))
	)
	(do-for-all-instances ((?x competing-rules)) TRUE 
		(if (> (length$ ?x:unique-slots) 0)
		   then
		   	(bind $?unique-slots (create$ _on_slots_ ?x:unique-slots))
		   else
		   	(bind $?unique-slots (create$))
		)
		(bind $?constructs (create$ $?constructs 
			"(" competing_rules (instance-name-to-symbol ?x) (instances-to-symbols ?x:original-rules) $?unique-slots ")" ))
	)
	(open ?file-out ruleml "w")
	(print-list ruleml $?constructs)
	(close ruleml)
)

