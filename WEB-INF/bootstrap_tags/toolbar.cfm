<cfsilent>
	<!--- $Id: toolbar.cfm 23273 2015-11-20 19:03:51Z tsinclair $ --->
	<cfparam name="attributes.label" default="Royall Engineers" />
	<cfparam name="attributes.href" default="" />
</cfsilent>
<cfif thistag.executionmode == "start">
	<nav class="navbar navbar-default <cfif structKeyExists( attributes, 'fixedToTop')>navbar-fixed-top</cfif>">
		<div class="container-fluid">
			<!-- Brand and toggle get grouped for better mobile display -->
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse-1" aria-expanded="false">
					<span class="sr-only">Toggle navigation</span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</button>
				<cfoutput>
				<a class="navbar-brand" href="#attributes.href#">#attributes.label#</a>
				</cfoutput>
			</div>
			<!-- Collect the nav links, forms, and other content for toggling -->
			<div class="collapse navbar-collapse" id="navbar-collapse-1">
<cfelseif thistag.executionmode == "end">
			</div><!-- /.navbar-collapse -->
		</div><!-- /.container-fluid -->
	</nav>
</cfif>

