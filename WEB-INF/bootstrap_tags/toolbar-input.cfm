<cfsilent>
	<!--- $Id: toolbar-input.cfm 23309 2015-11-23 15:31:56Z mfernstrom $ --->
	<cfparam name="attributes.label" default="Input" />
	<cfparam name="attributes.type" default="text" />
	<cfparam name="attributes.id" default="" />
	<cfparam name="attributes.name" default="" />
	<cfparam name="attributes.value" default="" />
</cfsilent>
<cfif ( thistag.executionmode == "start" ) >
	<span class="navbar-form navbar-left" <cfif structKeyExists( attributes, "hidden") >style="display:none"</cfif>>
		<div class="form-group">
			<input name="<%=#attributes.name#%>" value="<%=#attributes.value#%>" type="<%=#attributes.type#%>" class="form-control" id="<%=#attributes.id#%>" placeholder="<%=#attributes.label#%>" />
		</div>
	</span>
</cfif>