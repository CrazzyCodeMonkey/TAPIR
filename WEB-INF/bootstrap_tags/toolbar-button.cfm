<cfsilent>
	<!--- $Id: toolbar-button.cfm 23309 2015-11-23 15:31:56Z mfernstrom $ --->
	<cfparam name="attributes.label" default="" />
	<cfparam name="attributes.id" default="" />
	<cfparam name="attributes.type" default="" />
</cfsilent>
<cfif ( thistag.executionmode == "start" ) >
	<span class="navbar-form navbar-left" style="margin-top:0px">
		<div class="form-group">
			<button class="btn btn-default btn-raised" id="<%=#attributes.id#%>" type="<%=#attributes.type#%>"><%=#attributes.label#%></button>
		</div>
	</span>
</cfif>