<cfsilent>
	<!--- $Id: toolbar-tworowlabel.cfm 23273 2015-11-20 19:03:51Z tsinclair $ --->
	<cfparam name="attributes.label" default="" />
	<cfparam name="attributes.id" default="" />
	<cfparam name="attributes.value" default="" />
</cfsilent>
<cfif thistag.executionmode == "start">

	<span class="nav navbar-nav">
		<li><a href="#" id="pathContainer">
			<div class="row">
				<div class="col-md-12" style="font-size:10px; margin-top:-10px">
					<strong><%=#attributes.label#%></strong>
				</div>
			</div>
			<div class="row">
				<div id="<%=#attributes.id#%>" class="col-md-12" style="margin-bottom:-10px">
					<%=#attributes.value#%>
				</div>
			</div>
		</a></li>
	</span>
</cfif>