@echo off
@set xalan=.\xalan-j_2_6_0\bin
@set CLASSPATH=.;%xalan%\xalan.jar;%xalan%\xml-apis.jar;%xalan%\xercesImpl.jar;
@java org.apache.xalan.xslt.Process -in %1.ruleml -xsl ".\XSL\r-device.xsl" -out %1.clp
