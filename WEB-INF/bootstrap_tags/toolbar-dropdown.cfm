<cfsilent>
	<!--- $Id: toolbar-dropdown.cfm 23446 2015-12-02 22:07:15Z llee $ --->
	<cfparam name="attributes.label" default="Dropdown">
	<cfparam name="attributes.data" default="#[]#">
	<cfparam name="attributes.id" default="dropdown">
	<cfparam name="attributes.align" default="left">

	<cfset dropdownArray = attributes.data>
</cfsilent>
<cfif thistag.executionmode == "start">
	<ul class="nav navbar-nav pull-<%=#attributes.align#%>">
	<li class="dropdown">
		<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" id="<%=#attributes.id#%>"><span class="nav-dropdown-label"><%= #attributes.label# %><span class="caret"></span></span></a>
		<ul class="dropdown-menu">
			<cfloop array="#dropdownArray#" item="menuGroup" index="menuGroupIndex">
				<cfloop array="#menuGroup#" item="menuGroupItem" index="menuGroupItemIndex">
					<cfif structKeyExists( menuGroupItem, "href" )>
						<cfset currentHref = "#menuGroupItem.href#">
					<cfelse>
						<cfset currentHref = "">
					</cfif>
					<li><a href="<%=#currentHref#%>" <cfif structKeyExists( menuGroupItem, "data" )>data-data="<%=#menuGroupItem.data#%>"</cfif> <cfif structKeyExists( menuGroupItem, "value" )> data-value="<%=#menuGroupItem.value#%>"</cfif>> <%=#menuGroupItem.label#%></a></li>
				</cfloop>
				<cfif menuGroupIndex != ArrayLen(dropdownArray) >
					<li role="separator" class="divider"></li>
				</cfif>
			</cfloop>
		</ul>
	</li>
	</ul>
</cfif>

