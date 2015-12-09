<cfsilent><cfscript>
	aStatusOrder = ["nCOMPLETE","nNEW","nWARNING"];
	uStatusFriendly = {"nCOMPLETE":"Complete","nNEW":"New","nWARNING":"Overdue"};
	uStatusStyle = {"nCOMPLETE":"success","nNEW":"warning","nWARNING":"danger"};
</cfscript></cfsilent>
<cfif (ThisTag.executionmode == "start")>

	<div class="shadow-z-1 progress" style="margin-top:20px">

		<cfloop array="#aStatusOrder#" index="sStatus"><cfoutput>
			<cfif structKeyExists(attributes.percent, sStatus)>
				<div class="progress-bar progress-bar-#uStatusStyle[sStatus]#" style="width: #round(attributes.percent[sStatus]*100)#%">
					<span class="sr-only">#round(attributes.percent[sStatus]*100)#% Completed</span>
				</div>
			</cfif>
		</cfoutput></cfloop>

	</div>
	<p style="margin-top:-10px">Total Reviews</p>
	<p>
		<span class="large">
			<i class="glyphicon glyphicon-time"></i> <%=#attributes.nAvgClosedTime#%>
		</span>
		<br />
		Average minute to complete a review
	</p>

	<p>
		<span class="large">
			<i class="glyphicon glyphicon-file"></i> <%=#attributes.nLargestFilesToReview#%>
		</span>
		<br />
		Largest number of files in a review
	</p>

	<p>
		<span class="large">
			<i class="glyphicon glyphicon-file"></i> <%=#attributes.nLargestFilesReviewed#%>
		</span>
		<br />
		Largest number of files reviewed
	</p>

	<p>
		<span class="large">
			<i class="glyphicon glyphicon-file"></i> <%=#attributes.nLargestRevisions#%>
		</span>
		<br />
		Largest number of revisions in a review
	</p>
</cfif>