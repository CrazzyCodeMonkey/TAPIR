<cfsilent>
	<!--- $Id: userSidebar.cfm 23591 2015-12-08 14:34:39Z llee $ --->
	<cfimport taglib="/WEB-INF/bootstrap_tags/" prefix="BOOTSTRAP" />
</cfsilent>
<cfif ThisTag.executionmode == "start">
	<BOOTSTRAP:navbar-container>
		<cfif SESSION.user.isUserValid()>
			<BOOTSTRAP:toolbar-tworowlabel label="Welcome back" id="user" value='#SESSION.user.getDisplayName()#' />
		</cfif>
		<cfif CGI.SCRIPT_NAME != "/index.cfm">
			<BOOTSTRAP:toolbar-link icon="glyphicon glyphicon-home" tooltipWidth="150" href="/" title="BootStrap" label="BootStrap" tooltip="Go Back to BootStrap" tooltip_direction="left" class="tooltip-menu-leftfix"/>
		</cfif>
		<cfif CGI.SCRIPT_NAME == "/index.cfm" && !SESSION.user.isUserValid()>
			<BOOTSTRAP:toolbar-link label="Login to Access More BootStrap Apps">
		</cfif>

		<cfif SESSION.user.isUserValid()>
			<BOOTSTRAP:toolbar-link icon="glyphicon glyphicon-log-out" tooltipDirection="left" tooltip="Logout of BootStrap" label="Logout" onclick="BootStrap.logout();" title="Logout" />
		<cfelse>
			<BOOTSTRAP:toolbar-link icon="glyphicon glyphicon-log-in" tooltipDirection="left" tooltip="Login to BootStrap" label="Login" href="/login/" title="Login" />
		</cfif>
	</BOOTSTRAP:navbar-container>
</cfif>