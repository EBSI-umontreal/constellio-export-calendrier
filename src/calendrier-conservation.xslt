<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Calendrier de conservation</title>
				<link rel="stylesheet" href="calendrier-conservation.css"/>
			</head>
			<body>
				<xsl:apply-templates select="ROWSET/ROW"/>
			</body>
		</html>
	</xsl:template>

	<!-- Traitement d'une règle de conservation -->
	<xsl:template match="ROW">
		<!-- Séparer chaque règle par une ligne séparatrice -->
		<hr/>
		
		<!-- 1ere ligne : Numéro et le titre de la règle -->
		<div class="row">
			<div class="column left">
				<b>
					<xsl:value-of select="NUMREGLE"/>
				</b>
			</div>
			<div class="column titre">
				<b>
					<xsl:value-of select="TITRESER"/>
				</b>
			</div>
		</div>
		
		<!-- 2e ligne : Description de la règle -->
		<p><xsl:apply-templates select="DESCSERIE"/></p>
		
		<!-- 3e ligne : Détenteurs, calendrier et remarques -->
		<div class="row ligne3">
			<div class="column left"><p>&#x20;</p></div>
			<div class="column middle">
				<b>Détenteurs principaux :</b><br/>
				<xsl:value-of select="NOMUNITE"/>
			</div>
			<div class="column right">
				<table class="tabreg">
					<tr>
						<th class="tabreg_exemplaire">Exemplaires</th>
						<th class="tabreg_support">Type de support</th>
						<th class="tabreg_a">Actif</th>
						<th class="tabreg_sa">Semi-actif</th>
						<th class="tabreg_i">Inactif</th>
					</tr>
					<!-- Afficher les règles de l'exemplaire principal -->
					<xsl:apply-templates select="DELAI/DELAI_ROW[TYPEDOSS = 'P']"/>
					<!-- Afficher les règles de l'exemplaire secondaires -->
					<xsl:apply-templates select="DELAI/DELAI_ROW[TYPEDOSS = 'S']"/>
				</table>
				<xsl:apply-templates select="REMARQDELA"/>
			</div>
		</div>
	</xsl:template>

	<!-- Traiter les différentes élément d'une règle pour les intégrer au tableau -->
	<xsl:template match="DELAI_ROW">
		<tr>
			<th class="tabreg_exemplaire">
				<!-- intitulé du statut de l'exemplaire -->
				<xsl:choose>
					<xsl:when test="TYPEDOSS = 'P'">Principal</xsl:when>
					<xsl:otherwise>Secondaire</xsl:otherwise>
				</xsl:choose>
			</th>
			<td>
				<!-- Supports -->
				<xsl:call-template name="uppercase">
					<xsl:with-param name="text" select="SUPPDOSS"/>
				</xsl:call-template>
				<xsl:apply-templates select="REM_SUPPDOSS"/>
			</td>
			<!-- périodes et ajout de liens vers les remarques (si elles existent) -->
			<td>
				<xsl:value-of select="PERIOACTIF"/>
				<xsl:apply-templates select="REM_PERIOACTIF"/>
			</td>
			<td>
				<xsl:value-of select="PERIOSMACT"/>
				<xsl:apply-templates select="REM_PERIOSMACT"/>
			</td>
			<td>
				<xsl:value-of select="ID_REF_DISPOSITION"/>
				<xsl:apply-templates select="REM_DISPOINACT"/>
			</td>
		</tr>
	</xsl:template>
	
	<!-- ajouter le lien vers une remarque sous la forme d'un exposant -->
	<xsl:template match="REM_SUPPDOSS|REM_PERIOACTIF|REM_PERIOSMACT|REM_DISPOINACT">
		<sup><xsl:value-of select="."/></sup>
	</xsl:template>
	
	<!-- Afficher les remarques d'application (si elles existent) -->
	<xsl:template match="REMARQDELA">
		<xsl:if test=". != ''">
			<p>
				<b>Remarques :</b><br/>
				<xsl:call-template name="replace-newline">
					<xsl:with-param name="text" select="."/>
				</xsl:call-template>
			</p>
		</xsl:if>
	</xsl:template>
	
	<!-- Afficher la description de la série (si elle existe) -->
	<xsl:template match="DESCSERIE">
		<xsl:if test=". != ''">
			<p>
				<xsl:call-template name="replace-newline">
					<xsl:with-param name="text" select="."/>
				</xsl:call-template>
			</p>
		</xsl:if>
	</xsl:template>
	
	
	<!-- Fonction permettant de transformer les retours à la ligne de la sortie XML en <br/> pour les champs textuels longs -->
	<xsl:template name="replace-newline">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text, '&#xA;')">
				<xsl:value-of select="substring-before($text, '&#xA;')"/>
				<br/>
				<xsl:call-template name="replace-newline">
					<xsl:with-param name="text" select="substring-after($text, '&#xA;')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- Fonction pour transformer une chaine de caractère en majuscules 
	     Source : https://stackoverflow.com/questions/586231/how-can-i-convert-a-string-to-upper-or-lower-case-with-xslt
	-->
	<xsl:template name="uppercase">
		<xsl:param name="text"/>
		<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
		<xsl:value-of select="translate($text, $lowercase, $uppercase)" />
	</xsl:template>


</xsl:stylesheet>
