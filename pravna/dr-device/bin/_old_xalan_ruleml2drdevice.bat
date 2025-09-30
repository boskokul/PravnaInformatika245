@echo off
@set xalan=.\xalan-j_2_6_0\bin
@set CLASSPATH=.;%xalan%\xalan.jar;%xalan%\xml-apis.jar;%xalan%\xercesImpl.jar;
@echo LegalRuleML -> RuleML
@java org.apache.xalan.xslt.Process -in %1.lrml -xsl ".\XSL\lrml2ruleml.xsl" -out %1.ruleml
@echo RuleML -> Clips
@java org.apache.xalan.xslt.Process -in %1.ruleml -xsl ".\XSL\dr-device.xsl" -out %1.clp
