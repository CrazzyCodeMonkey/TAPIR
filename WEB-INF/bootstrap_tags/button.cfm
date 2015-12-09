<cfsilent>
	<!--- $Id: button.cfm 23317 2015-11-23 22:00:20Z mfernstrom $ --->
	<cfparam name="attributes.id" 		default="">
	<cfparam name="attributes.type" 	default="default">
	<cfparam name="attributes.size" 	default="default">
	<cfparam name="attributes.active" default=false>
	<cfparam name="attributes.extras" default="#{}#">

	<cfset classList 		= "btn">
	<cfset extraParams 	= "">

	<cfset typeClass = {
		"default" : "btn-default",
		primary 	: "btn-primary",
		success 	: "btn-success",
		info 			: "btn-info",
		warning 	: "btn-warning",
		danger 		: "btn-danger",
		link 			: "btn-link"}>

	<cfset sizeClass = {
		"default" : "",
		large 		: "btn-lg",
		small 		: "btn-sm",
		xsmall 		: "btn-xs"}>

	<cfset validConfig = true>
	<cfif structKeyExists(typeClass,attributes.type)>
		<cfset classList = listAppend(classList,typeClass[attributes.type]," ")>
	</cfif>

	<cfif structKeyExists(sizeClass,attributes.size)>
		<cfset classList = listAppend(classList,sizeClass[attributes.size]," ")>
	</cfif>

	<cfif attributes.active>
		<cfset classList = listAppend(classList,"active"," ")>
	</cfif>

	<cfloop collection="#attributes.extras#" item="extra">
		<cfset extraParams = listAppend(extraParams,"#extra#='#attributes.extras[extra]#'"," ")>
	</cfloop>

</cfsilent>
<cfif (ThisTag.executionMode=="start")>
	<cfoutput><button type="button" <cfif (len(attributes.id)>0)>id="#attributes.id#"</cfif> class="#ClassList#" #extraParams#></cfoutput>
<cfelseif (ThisTag.executionMode=="end")>
	</button>
</cfif>

