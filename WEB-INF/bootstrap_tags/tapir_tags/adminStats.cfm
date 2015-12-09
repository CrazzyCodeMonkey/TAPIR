<cfsilent>
	<cfimport taglib="/WEB-INF/bootstrap_tags/tapir_tags/" prefix="TAPIR" />
	<cfscript>
		aStatusOrder = ["nCOMPLETE","nNEW","nWARNING"];
		uStatusFriendly = {"nCOMPLETE":"Complete","nNEW":"New","nWARNING":"Overdue"};
		uStatusStyle = {"nCOMPLETE":"success","nNEW":"warning","nWARNING":"danger"};
</cfscript></cfsilent>
<cfif (ThisTag.executionmode == "start")>

	<TAPIR:dashboardStats attributeCollection="#attributes#">

	<hr>

	<cfloop array="#aStatusOrder#" index="sStatus"><cfoutput>
		<cfif structKeyExists(attributes.top, sStatus)>
			<p>
				<span class="large">
					<i class="glyphicon glyphicon-user"></i> #arrayToList(attributes.top[sStatus].authors)#
					<br/>
				</span>
				Users with the most #uStatusFriendly[sStatus]# reviews (#attributes.top[sStatus].count#).
			</p>
		</cfif>
	</cfoutput></cfloop>

</cfif>