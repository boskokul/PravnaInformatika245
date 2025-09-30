@echo off
@set saxon=.\saxon-he-11-4
@echo LegalRuleML -> RuleML
@java -jar %saxon%\saxon-he-11.4.jar -s:%1.lrml -xsl:.\XSL\lrml2ruleml.xsl -o:%1.ruleml
@echo RuleML -> Clips
@java -jar %saxon%\saxon-he-11.4.jar -s:%1.ruleml -xsl:.\XSL\dr-device.xsl -o:%1.clp
