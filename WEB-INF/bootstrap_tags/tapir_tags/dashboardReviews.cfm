<cfsilent>
	<cfparam name="attributes.reviews" default="#queryNew("")#" type="query">
	<cfparam name="attributes.which" default="" type="string">
	<cfparam name="attributes.title" default="" type="string">
	<cfset icon = {
		"COMPLETED":"glyphicon-eye-open",
		"NEW":"glyphicon-edit"
	}>

	<cfset warningTime = 60*24*2>
	<cfset warningScale = 60*24*5>

	<cfset color = ["Gold","Silver","Blue","DarkOrange","Yellow","Pink","Red"]>
</cfsilent>


<cfif (ThisTag.executionmode == "start" && attributes.which != "")>
	<table class="table shadow-z-2">
		<tr>
			<th colspan="8">
				<cfoutput>#attributes.title# (#attributes.reviews.recordCount#)</cfoutput>
			</th>
		</tr>
		<cfoutput query="attributes.reviews">
			<cfset rev = queryRowStruct(attributes.reviews,attributes.reviews.currentRow)>
			<tr id="#rev.reviewId#">

				<td>
					<a href="/tapir/review.cfm?reviewId=#rev.reviewId#">
						<span class="large"><i class="glyphicon #icon[attributes.which]#"></i></span><br/><small>Goto</small>
					</a>
				</td>

				<td>
					<cfif (rev.ticket!=0)>
						<span class="large"><cfoutput><a href="https://www.YOUR_TICKET_SERVER.com/?/#rev.ticket#" target="_blank">#rev.ticket#</a></cfoutput></span>
						<br />
						<small>Ticket</small>
					</cfif>
				</td>

				<td>
					<span class="large">#rev.filesReviewed# / #rev.filecount#</span>
					<br />
					<small>Reviewed&nbsp;&nbsp;/&nbsp;&nbsp;Files</small>
				</td>

				<td>
					<span class="large">
						#rev.revisions#
					</span>
					<br />
					<small>Revisions</small>
				</td>

				<td>
					<cfif attributes.which=="NEW">
						<span class="large">#int(rev.processTime/60*10)/10#</span>
						<cfif rev.status=="WARNING">
							<cfset fireScale = (rev.processTime-warningTime)/warningScale>
							<cfset fifeScale = (fireScale<1?fireScale:1)>
							<i class="glyphicon glyphicon-fire" style="color:rgb(#int(fireScale*256)#,0,0); font-size:#fireScale+1#em"></i>
						</cfif>
						<br /><small>hours in process</small>
					<cfelse>
						<span class="large">#int(rev.timetocomplete/60*10)/10#</span>
						<i class="glyphicon glyphicon-star" style="color:#color[rev.starcolor]#;"></i>
						<br /><small>hours to complete</small>
					</cfif>
				</td>

				<td>
					<span class="large">
						<cfif (rev.parentReview=="")>
							<i class="glyphicon glyphicon-minus"></i>
						<cfelse>
							<a href="##" data-parent="#rev.parentReview#"><i class="glyphicon glyphicon-chevron-down"></i></a>
						</cfif>
						/
						<cfif attributes.which=="COMPLETED">
							<cfif (rev.ticket!=0)>
								<cfif (rev.childreview!="")>
									<a href="##" class="submitInput" data-child="#rev.childreview#">
										<i class="glyphicon glyphicon-chevron-up"></i>
									</a>
								<cfelse>
									<a href="##" class="submitInput" data-location="/tapir/rpc/review.cfc?method=reviewAdd" data-data='{"_sPrevReview":"#rev.reviewId#"}'><i class="glyphicon glyphicon-plus"></i></a>
								</cfif>
							<cfelse>
								<i class="glyphicon glyphicon-minus"></i>
							</cfif>
						<cfelse>
							<i class="glyphicon glyphicon-minus"></i>
						</cfif>
					</span>
					<br />
					<small>Parent&nbsp;&nbsp;/&nbsp;&nbsp;Child
				</td>

			</tr>
		</cfoutput>
	</table>
</cfif>