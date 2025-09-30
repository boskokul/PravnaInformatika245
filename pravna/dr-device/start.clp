

(dribble-on "rulebase.log")
(batch* "bin\\dr-device.bat")
(set-verbose on)
(set-debug off)
(set-time-report off)
(set-compact-proofs on)
(set-export-non-proved off)
(load-ruleml-dr-device-local "rulebase" "rulebase.ruleml")
(dribble-off)
(exit)
(exit)