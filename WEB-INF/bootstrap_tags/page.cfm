<cfsilent>
	<!--- $Id: page.cfm 23529 2015-12-04 22:42:16Z llee $ --->
	<cfparam name="attributes.title" default="Royall Engineers" />
	<cfparam name="attributes.description" default="Royall Engineers App - Made by Engineers, for Engineers (& Company)" />
	<cfparam name="attributes.author" default="Royall" />
	<cfparam name="attributes.localCSS" default="false" />
	<cfparam name="attributes.customCSS" default="#[]#" />
	<cfparam name="attributes.customBodyId" default="" />
	<cfparam name="attributes.customJS" default="#[]#">
	<cfparam name="attributes.localAppJS" default="false">
	<cfparam name="attributes.endOfPageJS" default="">

	<cfset appPath = "/" & listFirst( CGI.SCRIPT_NAME, "/" )>
</cfsilent>
<cfif ( thistag.executionmode == "start" ) >
	<!DOCTYPE html>
	<html lang="en">
		<head>
			<meta charset="utf-8">

			<title><%=#attributes.title#%></title>
			<meta name="description" content="<%=#attributes.description#%>">
			<meta name="author" content="<%=#attributes.author#%>">
			<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
			<meta http-equiv="Pragma" content="no-cache" />
			<meta http-equiv="Expires" content="0" />

			<!--- Compiled and minified Bootstrap CSS --->
			<link rel="stylesheet" href="/a/css/vendor/bootstrap.min.css">

			<!--- Font Awesome --->
			<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

			<link rel="stylesheet" href="/a/css/vendor/roboto.min.css">
			<link rel="stylesheet" href="/a/css/vendor/material.min.css">
			<link rel="stylesheet" href="/a/css/vendor/ripples.min.css">

			<link rel="stylesheet" href="/a/css/components/notification.css">
			<link rel="stylesheet" href="/a/css/vendor/tooltip.css">
			<!--- Custom Styles --->
			<link rel="stylesheet" href="/a/css/style.css">
			<cfif attributes.localCSS>
				<link rel="stylesheet" href="<%=#appPath#%>/a/css/style.css">
			</cfif>

			<cfloop array="#attributes.customCSS#" index="css">
				<link rel="stylesheet" href="<%=#css#%>" />
			</cfloop>

		</head>

		<body <cfif attributes.customBodyId != "">id="<%=#attributes.customBodyId#%>"</cfif>>
<cfelseif thistag.executionmode == "end">
			<!--- Compiled and minified JQuery JS --->
			<script type="text/javascript" src="/a/js/vendor/jquery-2.1.4.min.js"></script>

			<!--- Compiled and minified Bootstrap JS --->
			<script type="text/javascript" src="/a/js/vendor/bootstrap.js"></script>
			<script type="text/javascript" src="/a/js/vendor/tooltip.js"></script>

			<script type="text/javascript" src="/a/js/vendor/material.min.js"></script>
			<script type="text/javascript" src="/a/js/components/statemanager.js"></script>

			<cfloop array="#attributes.customJS#" index="js">
				<script type="text/javascript" src="<%=#js#%>"></script>
			</cfloop>

			<script type="text/javascript" src="/a/js/app.js"></script>

			<cfif attributes.localAppJS>
				<script type="text/javascript" src="<%=#appPath#%>/a/js/app.js"></script>
			</cfif>

			<cfif ( len( attributes.endOfPageJS ) > 0 )>
				<script type="text/javascript"><%=#attributes.endOfPageJS#%></script>
			</cfif>

		</body>
	</html>
</cfif>