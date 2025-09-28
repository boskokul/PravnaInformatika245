<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.ruleml.org/0.91/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:n="http://www.ruleml.org/0.91/xsd" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text"/>
	<xsl:template match="/">
		<xsl:apply-templates select="n:RuleML"/>
	</xsl:template>
	<xsl:template match="n:RuleML">
		<xsl:if test="@rdf_import">(import-rdf <xsl:value-of select="@rdf_import"/>)</xsl:if>
		<xsl:text>
		</xsl:text>
		<xsl:if test="@rdf_export">(export-rdf <xsl:value-of select="@rdf_export"/>
			<xsl:text>  </xsl:text>
			<xsl:value-of select="@rdf_export_classes"/>)</xsl:if>
		<xsl:text>
		</xsl:text>
		<xsl:if test="@proof">(export-proof <xsl:value-of select="@proof"/>)</xsl:if>
		<xsl:text>
		</xsl:text>
		<xsl:apply-templates select="n:Assert"/>
	</xsl:template>
	<xsl:template match="n:Assert">
		<xsl:apply-templates select="n:Implies"/>
		<xsl:apply-templates select="n:Competing_rules"/>
	</xsl:template>
	<xsl:template match="n:Competing_rules">
(competing_rules <xsl:apply-templates select="n:oid/n:Ind"/>
		<!-- <xsl:value-of select="/@uri"/> -->
		<xsl:text> </xsl:text>
		<!--		<xsl:value-of select="@c_rules"/> -->
		<xsl:apply-templates select="n:competing_rule"/>
		<xsl:if test="n:unique_slot">
			<xsl:text> _on_slots_ </xsl:text>
			<xsl:apply-templates select="n:unique_slot"/>
		</xsl:if>
		<!-- <xsl:if test="_slots"><xsl:text> _on_slots_</xsl:text><xsl:apply-templates select="_slots"/></xsl:if> -->
)
	</xsl:template>
	<xsl:template match="n:competing_rule">
		<xsl:value-of select="n:Ind/@uri"/>
		<xsl:text> </xsl:text>
	</xsl:template>
	<xsl:template match="n:unique_slot">
		<xsl:apply-templates select="n:Ind"/>
		<!-- <xsl:value-of select="n:Ind/@uri"/> -->
		<xsl:text> </xsl:text>
	</xsl:template>
	<!-- <xsl:template match="_slots"><xsl:apply-templates select="slotname"/></xsl:template>
	<xsl:template match="slotname"><xsl:text> </xsl:text><xsl:value-of select="."/></xsl:template>-->
	<xsl:template match="n:Implies">
(<xsl:value-of select="@ruletype"/>
		<xsl:apply-templates select="n:oid"/>
		<xsl:if test="n:superior">
			<xsl:text>(declare (superior </xsl:text>
			<xsl:apply-templates select="n:superior"/>
			<xsl:text>))</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="n:body"/>
  => 
	<xsl:apply-templates select="n:head"/>
) 
	</xsl:template>
	<xsl:template match="n:superior">
		<xsl:value-of select="n:Ind/@uri"/>
		<xsl:text> </xsl:text>
	</xsl:template>
	<xsl:template match="n:oid">
		<xsl:text> </xsl:text>
		<xsl:value-of select="n:Ind/@uri"/>
		<xsl:text>
		</xsl:text>
	</xsl:template>
	<xsl:template match="n:body">
		<xsl:apply-templates select="n:Atom|n:Neg|n:And|n:Equal" mode="b"/>
		<!-- 		<xsl:if test="n:And/n:Equal/n:Expr">
			(test <xsl:apply-templates select="n:And/n:Equal/n:Expr"/>)
		</xsl:if>-->
	</xsl:template>
	<xsl:template match="n:And" mode="b">
		<xsl:apply-templates select="n:Atom|n:Neg|n:Naf|n:Equal" mode="b"/>
	</xsl:template>
	<xsl:template match="n:Equal" mode="b">
		(test <xsl:apply-templates select="n:Expr"/>)
	</xsl:template>
	<xsl:template match="n:Neg" mode="b">
		(not <xsl:apply-templates select="n:Atom" mode="b"/>)
	</xsl:template>
	<xsl:template match="n:head">
		<xsl:if test="n:Equal">(calc <xsl:apply-templates select="n:Equal" mode="h"/>)</xsl:if>
		<xsl:apply-templates select="n:Atom|n:Neg" mode="h"/>
	</xsl:template>
	<xsl:template match="n:Equal" mode="h">
		(bind <xsl:apply-templates select="n:Var"/>
		<xsl:apply-templates select="n:Expr"/>)
	</xsl:template>
	<xsl:template match="n:Neg" mode="h">
		(not <xsl:apply-templates select="n:Atom" mode="h"/>)
	</xsl:template>
	<xsl:template match="n:Naf" mode="b">
		(naf <xsl:if test="n:And">(and </xsl:if>
		<xsl:apply-templates select="n:Atom|n:And" mode="b"/>
		<xsl:if test="n:And">)</xsl:if>)
	</xsl:template>
	<xsl:template match="n:Atom" mode="b"> 
	(<xsl:if test="string-length(normalize-space(n:op/n:rel))=0">
			<xsl:value-of select="n:op/n:Rel/@uri"/>
		</xsl:if>
		<xsl:if test="string-length(normalize-space(n:op/n:Rel))>0">
			<xsl:value-of select="n:op/n:Rel"/>
		</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="n:slot"/>) </xsl:template>
	<xsl:template match="n:Atom" mode="h"> 
	(<xsl:if test="string-length(normalize-space(n:op/n:rel))=0">
			<xsl:value-of select="n:op/n:Rel/@uri"/>
		</xsl:if>
		<xsl:if test="string-length(normalize-space(n:op/n:Rel))>0">
			<xsl:value-of select="n:op/n:Rel"/>
		</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="n:slot"/>) </xsl:template>
	<xsl:template match="n:slot">
		(<!-- <xsl:value-of select="n:Ind"/> -->
		<xsl:apply-templates select="n:Ind[1]"/>
		<!--<xsl:apply-templates select="n:Var|n:Ind|n:not_ComplexArg|n:and_ComplexArg|n:or_ComplexArg"/>)-->
		<xsl:apply-templates select="n:Var|n:Ind[2]|n:Data|n:ComplexArg"/>)
	</xsl:template>
	<xsl:template match="n:ComplexArg">
		<xsl:apply-templates select="n:not_ComplexArg|n:and_ComplexArg|n:or_ComplexArg"/>
	</xsl:template>
	<xsl:template match="n:Var">
		<xsl:text> ?</xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>
	<xsl:template match="n:Ind">
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="@uri">
				<xsl:value-of select="@uri"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
		<!--		<xsl:if test="string-length(normalize-space(n:op/n:Rel))>0">
			<xsl:value-of select="n:op/n:Rel"/>
		</xsl:if>-->
	</xsl:template>
	<xsl:template match="n:Data">
		<xsl:text> </xsl:text>
		<xsl:variable name="datatype" select="./@xsi:type"/>
		<xsl:choose>
			<xsl:when test="$datatype=&quot;xs:string&quot;">
				<xsl:text>&quot;</xsl:text>
				<xsl:value-of select="."/>
				<xsl:text>&quot;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
		<!-- Must take care of data type in constants -->
	</xsl:template>
	<xsl:template match="n:Expr">
		(<xsl:value-of select="n:Fun"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="n:Ind|n:Var|n:Expr"/>
		)
	</xsl:template>
	<xsl:template match="n:not_ComplexArg">
		<xsl:text> ~</xsl:text>
		<xsl:apply-templates select="n:Var|n:Ind"/>
	</xsl:template>
	<xsl:template match="n:and_ComplexArg">
		<xsl:text> </xsl:text>
		<xsl:for-each select="n:Var|n:Ind|n:not_ComplexArg|n:Expr">
			<xsl:choose>
				<xsl:when test="name(.)=&quot;Var&quot;">
					<xsl:text> ?</xsl:text>
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="name(.)=&quot;Ind&quot;">
					<xsl:text> </xsl:text>
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="name(.)=&quot;Expr&quot;">
					<xsl:text> :</xsl:text>
					<xsl:variable name="func_pos" select="position()"/>
					<xsl:apply-templates select="../*[position()=$func_pos]"/>
				</xsl:when>
				<xsl:when test="name(.)=&quot;not_ComplexArg&quot;">
					<xsl:text> ~</xsl:text>
					<xsl:apply-templates select="n:Var|n:Ind"/>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="not (position()=last())">
				<xsl:text> &amp; </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
