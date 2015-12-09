<cfsilent>
	<cfimport taglib="/WEB-INF/bootstrap_tags/" prefix="BOOTSTRAP" />

	<cfset bHaveReview = request.tapir.isLoaded() >

</cfsilent>
<cfif ThisTag.executionmode == "start">
	<BOOTSTRAP:navbar href="/tapir/" label="<i class='fa fa-qq'></i> T A P I R">
		<ul class="nav navbar-nav">
			<li class="dropdown">
				<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">TAPIR <span class="caret"></span></a>
				<ul class="dropdown-menu">
					<cfif (bHaveReview && CGI.SCRIPT_NAME != "/tapir/review.cfm")>
						<li><a href="/tapir/review.cfm?reviewId=<%=#request.tapir.getReviewId()#%>">Back to Review</a></li>
					</cfif>
					<li><a href="#" data-modal="/tapir/rpc/review.cfc?method=reviewModalNewTicket">New Ticket based Review</a></li>
					<!--- <li><a href="#" data-modal="/tapir/rpc/review.cfc?method=reviewModalNewRevisions">New Revision based Review</a></li> --->
					<li><a href="#" data-modal="/tapir/rpc/review.cfc?method=reviewModalLoad">Load Review</a></li>
					<cfif (bHaveReview)>
						<li role="separator" class="divider"></li>
						<cfif (len(request.tapir.getTicket()) > 0)>
							<li><a href="https://www.YOUR_TICKET_SERVER.com/?/<%=#request.tapir.getTicket()#%>" target="_blank">Goto ticket</a></li>
						</cfif>
						<cfif (request.tapir.getStatus() != "COMPLETE")>
							<li><a href="#" data-modal="/tapir/rpc/review.cfc?method=reviewFinishUp&reviewId=<%=#request.tapir.getReviewId()#%>">Finalize Review</a></li>
						<cfelseif (request.tapir.getStatus() == "COMPLETE")>
							<li><a href="#" data-modal="/tapir/rpc/review.cfc?method=reviewExport&reviewId=<%=#request.tapir.getReviewId()#%>">Export Review</a></li>
						</cfif>
					</cfif>
					<li role="separator" class="divider"></li>
					<li><a href="/tapir/">Dashboard</a></li>
				</ul>
			</li>
			<li class="dropdown">
				<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Help <span class="caret"></span></a>
				<ul class="dropdown-menu">
					<li><a href="/tapir/about/faq.cfm">FAQ</a></li>
					<li><a href="/tapir/about/using.cfm">Getting Started</a></li>
					<li role="separator" class="divider"></li>
					<li><a href="/tapir/about/about.cfm">About</a></li>
				</ul>
			</li>
			<cfif (bHaveReview)>
				<li class="lock">
					<cfif (request.tapir.getStatus() == "COMPLETE")>
						<i class="fa fa-lock fa-2x fa-fw" style="color:#777"></i>
					<cfelse>
						<i class="fa fa-unlock fa-2x fa-fw" style="color:#777"></i>
					</cfif>
					<%=Review id #request.tapir.getReviewId()#%>
					<cfif (request.tapir.getAuthor() != SESSION.user.getEmail())>
						<i class="fa fa-ban fa-2x fa-fw" style="color:red"></i>
						<li style="color:red"><a href="#"><%=#listFirst(request.tapir.getAuthor(),"@")#%> is the Author</a></li>
					</cfif>
				</li>
			</cfif>
		</ul>
		<BOOTSTRAP:userSidebar />
	</BOOTSTRAP:navbar>
</cfif>