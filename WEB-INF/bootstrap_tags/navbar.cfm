<cfsilent>
	<!--- $Id: navbar.cfm 23391 2015-12-01 15:26:12Z tsinclair $ --->
	<cfparam name="attributes.label" default="Royall Engineers" />
	<cfparam name="attributes.href" default="" />
	<cfparam name="attributes.fixed" default="true" />
</cfsilent>
<cfif thistag.executionmode == "start">
<nav class="navbar navbar-default	<cfif attributes.fixed>navbar-fixed-top</cfif>">
	<div class="container-fluid">
		<!-- Brand and toggle get grouped for better mobile display -->
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="<cfoutput>#attributes.href#</cfoutput>"><%= #attributes.label# %></a>
		</div>

		<!-- Collect the nav links, forms, and other content for toggling -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
<cfelse>
		</div> <!--- .collapse --->
	</div> <!--- .container-fluid --->
</nav> <!--- .navbar --->
</cfif>