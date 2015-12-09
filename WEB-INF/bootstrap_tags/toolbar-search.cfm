<cfsilent>
	<!--- $Id: toolbar-search.cfm 23446 2015-12-02 22:07:15Z llee $ --->
	<cfparam name="attributes.label" default="Link" />
	<cfparam name="attributes.id" default="search" />
	<cfparam name="attributes.icon" default="fa fa-search" />
	<cfparam name="attributes.align" default="left" />
</cfsilent>
<cfif ( thistag.executionmode == "start" ) >
	<div class="navbar-form navbar-<%=#attributes.align#%>">
	<div class="form-group">
		<i class="<%=#attributes.icon#%>"></i>
		<input id="<%=#attributes.id#%>" type="text" class="form-control" placeholder="Search">
	</div>
	</div>
</cfif>