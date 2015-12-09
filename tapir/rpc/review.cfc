<cfcomponent output="false">
	<!---
		@Class tapir.rpc.review
	--->

	<!---
	/**
	  * @remote
	  * @method renderCommit
	  * @returnformat {plain}
	  * @return {String}
	  */
	--->
<cffunction name="renderCommit" access="remote" returntype="String" returnformat="plain">
		<cfparam name="_revisionBy" 					default="" />
		<cfparam name="_revisionNumber" 			default="" />
		<cfparam name="_files" 								default="" />
		<cfparam name="_commitMessage" 				default="" />
		<cfparam name="_commitDate" 					default="" />
		<cfparam name="_commitMessageContent" default="" />
		<cfparam name="_fileList" 						default="" />

		<cfset var sCommitBlock = "">
		<cfimport taglib="/WEB-INF/bootstrap_tags/tapir_tags/" prefix="BOOTSTRAP" />

		<cfsavecontent variable="sCommitBlock">
			<BOOTSTRAP:commit revisionBy="#_revisionBy#" revisionNumber="#_revisionNumber#" files="#_files#" commitMessage="#_commitMessage#" commitDate="#_commitDate#" commitMessageContent="#_commitMessageContent#" fileList="#deserializeJSON(_fileList)#">
		</cfsavecontent>

		<cfreturn sCommitBlock>

	</cffunction>





	<!---
	/**
	  * @remote
	  * @method reviewLoad
	  * @param {string} _reviewId (required)
	  * @returnformat {JSON}
	  */
	--->
<cffunction name="reviewLoad" access="remote" returntype="struct" returnformat="JSON">
		<cfargument name="_reviewId" type="string" required="true">
		<cfscript>
			var uRet = {_success: false};

			try {
				request.tapir = new tapir.review(arguments._reviewId);
			} catch (any e){
				uRet._error = e;
				uRet._message = "There was a error loading your reivew";
				uRet._arguments = arguments;
			} finally {
				uRet._success = request.tapir.isLoaded();
				if (uRet._success){
					uRet.files = request.tapir.getFiles();
					uRet.sReviewId = request.tapir.getReviewId();
					uRet.location = "/tapir/review.cfm?reviewId=" & uRet.sReviewId;
				} else {
					uRet._message = "Unable to find Review. Please check the ID and try again.";
				}
			}

			return uRet;
		</cfscript>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewNew
	  * @param {string} _sRepository (required)
	  * @param {string} _nTicket (required)
	  * @param {string} _sRevisions (required)
	  * @param {string} _nRepoStart (required)
	  * @returnformat {JSON}
	  */
	--->
<cffunction name="reviewNew" access="remote" returntype="struct" returnformat="JSON">
		<cfargument name="_sRepository" type="string" required="true">
		<cfargument name="_nTicket" 		type="string" required="true">
		<cfargument name="_sRevisions" 	type="string" required="true">
		<cfargument name="_nRepoStart" 	type="string" required="true">
		<cfscript>
			var uRet = {_success: false};

			if (!isNumeric(_nTicket)){
				_nTicket = 0;
			} else {
				_nTicket = fix(_nTicket);

			}


			if (listLen(_sRevisions)>0){
				_sRevisions = listSort(_sRevisions, "numeric", "asc");
				_nRepoStart = listFirst(_sRevisions);
			}

			try {
				request.tapir = new tapir.review();
				request.tapir.newReview(_sRepository, _nTicket, _sRevisions, fix(_nRepoStart));

			} catch (any e){
				uRet._error = e;
				uRet._message = "There was a error creating your new review";
				uRet._arguments = arguments;

			} finally {

				uRet._success = request.tapir.isLoaded();
				if (uRet._success){
					uRet.files = [];
					uRet.sReviewId = request.tapir.getReviewId();
					uRet.location = "/tapir/review.cfm?reviewId=" & uRet.sReviewId;
				}
			}

			return uRet;
		</cfscript>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewAdd
	  * @param {string} _sPrevReview (required)
	  * @returnformat {JSON}
	  */
	--->
<cffunction name="reviewAdd" access="remote" returntype="struct" returnformat="JSON">
		<cfargument name="_sPrevReview" type="string" required="true">
		<cfscript>
			var uRet = {_success: false};

			try {
				oPrev = new tapir.review(_sPrevReview);
				request.tapir = new tapir.review();
				request.tapir.newReview(oPRev.getRepo(), oPrev.getTicket(), "", arrayMax(oPrev.getRevisions()), oPrev.getReviewId());
			} catch(TAPIR e){
				if( e.detail contains "No checkins have been made to ticket" ) {
					uRet._message = ReReplace(e.detail, "<.*'>|</a>", "", "ALL");
				} else {
					uRet._message = e.detail;
				}
				uRet._arguments;
			} catch (any e){
				uRet._error = e;
				uRet._message = "There was a error creating your new reivew";
				uRet._arguments = arguments;
			} finally {
				uRet._success = request.tapir.isLoaded();
				if (uRet._success){
					uRet.files = [];
					uRet.sReviewId = request.tapir.getReviewId();
					uRet.location = "/tapir/review.cfm?reviewId=" & uRet.sReviewId;
				}
			}

			return uRet;
		</cfscript>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewFinalize
	  * @param {string} _sComment (required)
	  * @returnformat {JSON}
	  */
	--->
<cffunction name="reviewFinalize" access="remote" returntype="Struct" returnformat="JSON">
		<cfargument name="_sComment" required="true" type="string">
		<cfscript>
			// If the incoming comment is blank, return an error message.
			if( len(arguments._sComment) == 0 ) {
				return { 	_success: false,
									_message: "Finishing comment can not be blank." };
			}

			if( request.tapir.getAuthor() == SESSION.user.user.email ) {
				var uRet = application.dgw.invokeByRestOutStruct("tapir.review.finalize",Application.appkey,{sReviewId:request.tapir.getReviewId(), comment:_sComment});

				if (uRet._success){
					request.tapir.reload();
				}

			} else {
				uRet = { _success: false };

			}
			return uRet;
		</cfscript>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewFinishUp
	  * @returnformat {plain}
	  * @return {string}
	  */
	--->
<cffunction name="reviewFinishUp" access="remote" returntype="string" returnformat="plain">
		<cfset var sFinishModal = "">
		<cfset var sFinishForm 	= "">
		<cfset var uExtras 			= {"data-reload":"true"}>

		<cfimport taglib="/WEB-INF/bootstrap_tags/" prefix="BOOTSTRAP" />

		<cfsavecontent variable="sFinishForm" trim="true">
			<form action="/tapir/rpc/review.cfc?method=reviewFinalize&reviewId=<%=<%=#request.tapir.getReviewId()#%>%>">
				<div class="form-group">
					<label for="comments">Finishing comments</label>
					<input type="email" class="form-control" id="comments" name="_sComment" placeholder="Finishing comments to send back" value="Please fix these items and send back to <%=#listFirst(SESSION.user.getEmail(),"@")#%> for review">
				</div>
			</form>
		</cfsavecontent>

		<cfsavecontent variable="sFinishModal" trim="true">
			<BOOTSTRAP:modal title="TAPIR - Review: Finalize Review" message="#sFinishForm#" hide="#false#">
				<BOOTSTRAP:button extras='#{"data-dismiss"="modal"}#'>Close</BOOTSTRAP:button>
				<BOOTSTRAP:button type="success" id="submitInput" extras="#uExtras#">Finish Review</BOOTSTRAP:button>
			</BOOTSTRAP:modal>
		</cfsavecontent>

		<cfreturn sFinishModal>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewSearch
	  * @param {string} _sRepository
	  * @param {string} {string} [_nTicket = ""]
	  * @param {string} {string} [_sRevisions = ""]
	  * @returnformat {json}
	  * @return {struct}
	  */
	--->
<cffunction name="reviewSearch" access="remote" returntype="struct" returnformat="json">
		<cfargument name="_sRepository" type="string" required="false">
		<cfargument name="_nTicket" 		type="string" required="false" default="">
		<cfargument name="_sRevisions" 	type="string" required="false" default="">
		<cfscript>

			var sRet 			= "";
			var sMessage 	= "";
			var sReview 	= "";
			var sQuery 		= "";
			var errorMsg 	= "";
			var sTitle 		= "TAPIR Review";
			var bReminder = false;
			var bStart 		= false;
			var bLoad 		= false;
			var bAdd 			= false;
			var success 	= true;
			var oUtils 		= createObject("tapir.utils");
			var uQuery 		= {};


			if (len(trim(_sRevisions)) > 0){
				uQuery.revisions = {"$eq":listToArray( ARGUMENTS._sRevisions)};
			} else if (len(trim(_nTicket)) >0 ){
				if ( isNumeric( _nTicket ) ){
					uQuery.ticket = {"$eq":fix(_nTicket)};
				} else{
					success = false;
					errorMsg = 'Ticket provided is not numeric!';
				}
			}

			sQuery = serializeJSON(uQuery);

			var review = Application.dgw.invokeByRestOutStruct("tapir.review.find",Application.appkey,{query:sQuery});

			if (!review._success){
				sMessage = "<p>Do you wish to start a new review?</p> <p>Make sure ticket <a onclick=""window.open('https://www.YOUR_TICKET_SERVER.com/?/" & _nTicket & "')"">##" & _nTicket & "</a> is valid</P>";
				bStart = true;
			} else {
				sReview = arrayLast(review.reviews);
				var prevReview = Application.dgw.invokeByRestOutStruct("tapir.review.get_meta",application.appkey,{sReviewId:sReview});

				if (prevReview.status == "COMPLETE"){
					if (prevReview.author==SESSION.user.getEmail()){
						bLoad = true;
						if (prevReview.ticket != 0) {
							bAdd = true;
							sMessage = "This review has been finished, would you like to load it, or start a new review?<br />";

						} else {
							sMessage = "You have already started a review for revisions #_sRevisions#<br />" &
													"Please finish this review, before starting a new review";
						}
					} else {
						bReminder = true;
						if (prevReview.ticket != 0){
							sMessage = "#listfirst(prevReview.author,"@")# has already started a review for ticket #oUtils.getUtil("link").ticket(prevReview.ticket)#<br />" &
													"You may send them a reminder.";
						} else {
							sMessage = "#listfirst(prevReview.author,"@")# has already started a review for revisions #_sRevisions#<br />" &
													"You may send them a reminder.";
						}
					}
				} else {
					sMessage = "Would you like to add a new review?";
					bLoad = true;
					bAdd = true;
				}
			}

		</cfscript>

		<cfimport taglib="/WEB-INF/bootstrap_tags/" prefix="BOOTSTRAP" />
		<cfsavecontent variable="sRet" trim="true">
			<BOOTSTRAP:modal title="#sTitle#" message="#sMessage#" hide="#false#">
				<BOOTSTRAP:button extras='#{"data-dismiss"="modal"}#'>Close</BOOTSTRAP:button>
				<cfif bLoad>
					<cfset uExtras = {
						"data-reload":"/tapir/rpc/review.cfc?method=reviewLoad&reviewId=#request.tapir.getReviewId()#",
						"data-data" : serializeJSON({_reviewID:sReview})}>
					<BOOTSTRAP:button type="success" id="submitInput" extras='#uExtras#'>Load Review</BOOTSTRAP:button>
				</cfif>

				<cfif bAdd>
					<cfset uExtras = {
						"data-reload":"/tapir/rpc/review.cfc?method=reviewAdd&reviewId=#request.tapir.getReviewId()#",
						"data-data" : serializeJSON({_sPrevReview:sReview})}>
					<BOOTSTRAP:button type="primary" id="submitInput" extras='#uExtras#'>Add New Review</BOOTSTRAP:button>
				</cfif>

				<cfif bReminder>
					<cfset uExtras = {
						"data-reload":"/tapir/rpc/review.cfc?method=reviewReminder&reviewId=#request.tapir.getReviewId()#",
						"data-data" : serializeJSON({_reviewId:sReview})}>
					<BOOTSTRAP:button type="primary" id="submitInput" extras='#{"data-remind"=sReview}#'>Send Reminder</BOOTSTRAP:button>
				</cfif>

				<cfif bStart>
					<cfset uExtras = {
						"data-location":"/tapir/rpc/review.cfc?method=reviewNew&reviewId=#request.tapir.getReviewId()#",
						"data-data" : serializeJSON({
							_sRepository:_sRepository,
							_nTicket:_nTicket,
							_sRevisions:_sRevisions,
							_nRepoStart:_nRepoStart
								})}>
					<BOOTSTRAP:button type="primary" id="submitInput" extras='#uExtras#'>Start New Review</BOOTSTRAP:button>
				</cfif>

			</BOOTSTRAP:modal>
		</cfsavecontent>

		<cfreturn { _success: success, responseText: sRet, _message: errorMsg }>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewReminder
	  * @param {string} _reviewId (required)
	  * @returnformat {plain}
	  * @return {string}
	  */
	--->
<cffunction name="reviewReminder" access="remote" returntype="string" returnformat="plain">
		<cfargument name="_reviewId" required="true" type="string">

		<cfset var uReview 	= Application.dgw.invokeByRestOutStruct("tapir.review.get_meta",application.appkey,{sReviewId:_reviewId})>
		<cfset var sModal 	= "">

		<cfmail to="#uReview.author#" subject="TAPIR review reminder" from="TAPIR <noreply@royall.com>" type="html"><cfoutput>
			<html>
				<body>
					<p>
						#listFirst(SESSION.user.getemail(),"@")# is sending you a reminder about a review that you started on #uReview.dt_create#, and have not completed.
					</p>
					<p>
						You may use this Review ID to return to this review: <a href="/tapir/?reviewId=#_reviewId#">#_reviewId#</a>
					</p>
				</body>
			</html>
		</cfoutput></cfmail>

		<cfsavecontent variable="sModal">
			<BOOTSTRAP:modal title="TAPIR Review Reminder" message="A reminder email has been sent to #uReview.author#" hide="#false#">
				<BOOTSTRAP:button extras='#{"data-dismiss"="modal"}#'>Close</BOOTSTRAP:button>
			</BOOTSTRAP:modal>
		</cfsavecontent>

		<cfreturn sModal>
	</cffunction>


	<!---
	/**
	  * @remote
	  * @method reviewReassignPrompt
	  * @param {string} _reviewId (required)
	  * @returnformat {plain}
	  * @return {String}
	  */
	--->
<cffunction name="reviewReassignPrompt" access="remote" returntype="String" returnformat="plain">
		<cfargument name="_reviewId" required="true" type="string">

		<cfset var sModalForm = "">
		<cfset var sModal 		= "">
		<cfsavecontent variable="sModalForm">
			<form action="/tapir/rpc/review.cfc?method=reviewReassign&reviewId=<%=#request.tapir.getReviewId()#%>">
				<input type="hidden" name="_reviewId" value="<%=#_reviewId#%>">
				<div class="form-group">
					<label for="comments">Who do you want to reassign this review to (email):</label>
					<input type="email" class="form-control" id="reassignAuthor" name="_reassignAuthor" placeholder="User@royall.com" value="">

				</div>
			</form>
		</cfsavecontent>

		<cfsavecontent variable="sModal">
			<BOOTSTRAP:modal title="TAPIR Review Reassign" message="#sModalForm#" hide="#false#">
				<BOOTSTRAP:button extras='#{"data-dismiss"="modal"}#'>Close</BOOTSTRAP:button>
				<BOOTSTRAP:button type="success" id="submitInput" extras='#{"data-reload"="true"}#'>Reassign</BOOTSTRAP:button>
			</BOOTSTRAP:modal>
		</cfsavecontent>

		<cfreturn sModal>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewReassign
	  * @returnformat {JSON}
	  * @return {Struct}
	  */
	--->
<cffunction name="reviewReassign" access="remote" returntype="Struct" returnformat="JSON">
		<cfargument name = "_reassignAuthor" 	required="true" type="string">

		<cfset var uReassign = {_success:false}>

		<cfif isValid("email",_reassignAuthor)>
			<cfset uReassign = Application.dgw.invokeByRestOutStruct("tapir.review.reassign",application.appkey,{sReviewId:_reviewID,newAuthor:_reassignAuthor})>
		<cfelse>
			<cfset uReassign._message = "Invalid email address">
		</cfif>

		<cfreturn uReassign>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewReOpen
	  * @param {string} _reviewId (required)
	  * @returnformat {json}
	  * @return {struct}
	  */
	--->
<cffunction name="reviewReOpen" access="remote" returntype="struct" returnformat="json">
		<cfargument name="_reviewId" required="true" type="string">
		<cfset var uRete 		= {_success:false,location:"/tapir/admin/"}>
		<cfset var sModal 	= "">
		<cfset var uReview 	= Application.dgw.invokeByRestOutStruct("tapir.review.get_meta",application.appkey,{sReviewId:_reviewId})>

		<cfif uReview._success && uReview.status == "COMPLETE">
			<cfset var uReOpen = Application.dgw.invokeByRestOutStruct("tapir.review.reopen",application.appkey,{sReviewId:_reviewId})>

			<cfif uReOpen._success>

				<cfmail to="#uReview.author#" subject="TAPIR review reminder" from="TAPIR <noreply@royall.com>" type="html"><cfoutput>
					<html><body>
						<p>#listFirst(SESSION.user.getemail(),"@")# has reopen your review.</p>
						<p>You may use this Review ID to return to this review: <a href="/tapir/?reviewId=#_reviewId#">#_reviewId#</a></p>
					</body></html>
				</cfoutput></cfmail>
				<cfset uRet._success = true>

			<cfelse>
				<cfset uRet._message = "Unable to Reopen this review.">
			</cfif>

			<cfreturn uRet>
		</cfif>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewModalNewTicket
	  * @returnformat {plain}
	  * @return {String}
	  */
	--->
<cffunction name="reviewModalNewTicket" access="remote" returntype="String" returnformat="plain">
		<cfset var sModalForm 				= "">
		<cfset var sModal 						= "">
		<cfset var oUtil 							= createObject("tapir.utils")>
		<cfset var repoDropdownGroup 	= oUtil.runUtilFn("svn","getReposAndRevisions",{})>
		<cfset var uExtras 						= {"data-togglediv"="##customRev"}>
		<cfset var uExtrasSubmit 			= {"data-modal":"true"}>

		<cfsavecontent variable="sModalForm" trim="true">
			<form id="lookup" action="/tapir/rpc/review.cfc?method=reviewSearch&reviewId=<%=#request.tapir.getReviewId()#%>" method="POST">
				<div class="form-group">
					<label for="Repository">Select a Repository</label>
					<select class="form-control" id="repo" name="_sRepository" data-required="true" >
						<option value="">--</option>
						<cfloop array="#repoDropdownGroup#" index="repo">
							<cfoutput><option value="#repo.value#" data-head="#repo.data#">#repo.label#</option></cfoutput>
						</cfloop>
					</select>
				</div>

				<div class="form-group">
					<label for="ticket">Tick'd ID</label>
					<input type="text" class="form-control" name="_nTicket" id="ticket" placeholder="Tick'd Ticket ID" data-required="true" data-validation="numeric">
				</div>

				<BOOTSTRAP:button id="olderRevControler" type="warning" extras='#uExtras#'>Older Content</BOOTSTRAP:button>

				<div class="form-group" id="customRev" style="display:none;">
					<label for="repoStart">Revision Search start</label>
					<input type="text" class="form-control" name="_nRepoStart" id="repoStart" placeholder="Revision" title="You should not have to modify this, unless you are searching for older content." data-required="true">
				</div>

			</form>
		</cfsavecontent>

		<cfsavecontent variable="sModal" trim="true">
			<BOOTSTRAP:modal title="TAPIR Review: New" message="#sModalForm#" hide="false">
				<BOOTSTRAP:button extras='#{"data-dismiss"="modal"}#'>Close</BOOTSTRAP:button>
				<BOOTSTRAP:button type="primary" id="submitInput" extras="#uExtrasSubmit#">Submit</BOOTSTRAP:button>
			</BOOTSTRAP:modal>
		</cfsavecontent>

		<cfreturn sModal>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewModalNewRevisions
	  * @returnformat {plain}
	  * @return {String}
	  */
	--->
<cffunction name="reviewModalNewRevisions" access="remote" returntype="String" returnformat="plain">
		<cfset var sModalForm 				= "">
		<cfset var sModal 						= "">
		<cfset var oUtil 							= createObject("tapir.utils")>
		<cfset var repoDropdownGroup 	= oUtil.runUtilFn("svn","getReposAndRevisions",{})>
		<cfset var uExtrasSubmit 			= {"data-modal":"true"}>


		<cfsavecontent variable="sModalForm" trim="true">
			<form id="lookup" action="/tapir/rpc/review.cfc?method=reviewSearch&reviewId=<%=#request.tapir.getReviewId()#%>" method="POST">
				<div class="form-group">
					<label for="Repository">Select a Repository</label>
					<select class="form-control" id="repo" name="_sRepository">
						<option value="">--</option>
						<cfloop array="#repoDropdownGroup#" index="repo">
							<cfoutput><option value="#repo.value#" data-head="#repo.data#">#repo.label#</option></cfoutput>
						</cfloop>
					</select>
				</div>

				<div class="form-group">
					<label for="revisions">Revision List</label>
					<input type="text" class="form-control" id="revisions" name="_sRevisions" placeholder="List of SVN Revisions" >
				</div>

			</form>
		</cfsavecontent>

		<cfsavecontent variable="sModal" trim="true">
			<BOOTSTRAP:modal title="TAPIR Review: New" message="#sModalForm#" hide="false">
				<BOOTSTRAP:button extras='#{"data-dismiss"="modal"}#'>Close</BOOTSTRAP:button>
				<BOOTSTRAP:button type="primary" id="submitInput" extras="#uExtrasSubmit#">Submit</BOOTSTRAP:button>
			</BOOTSTRAP:modal>
		</cfsavecontent>

		<cfreturn sModal>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewModalLoad
	  * @returnformat {plain}
	  * @return {String}
	  */
	--->
<cffunction name="reviewModalLoad" access="remote" returntype="String" returnformat="plain">
		<cfset var sModalForm 				= "">
		<cfset var sModal 						= "">
		<cfset var oUtil 							= createObject("tapir.utils")>
		<cfset var repoDropdownGroup 	= oUtil.runUtilFn("svn","getReposAndRevisions",{})>
		<cfset var uExtrasSubmit 			= {"data-location":"true"}>

		<cfsavecontent variable="sModalForm" trim="true">
			<form id="lookup" action="/tapir/rpc/review.cfc?method=reviewLoad&reviewId=<%=#request.tapir.getReviewId()#%>" method="POST">
				<div class="form-group">
					<label for="reviewID">TAPIR Review ID</label>
					<input type="text" class="form-control" id="reviewID" name="_reviewID" data-required="true" data-length="24" placeholder="Review ID">
				</div>

			</form>
		</cfsavecontent>

		<cfsavecontent variable="sModal" trim="true">
			<BOOTSTRAP:modal title="TAPIR Review: Load" message="#sModalForm#" hide="false">
				<BOOTSTRAP:button extras='#{"data-dismiss"="modal"}#'>Close</BOOTSTRAP:button>
				<BOOTSTRAP:button type="primary" id="submitInput" extras="#uExtrasSubmit#">Submit</BOOTSTRAP:button>
			</BOOTSTRAP:modal>
		</cfsavecontent>

		<cfreturn sModal>
	</cffunction>



	<!---
	/**
	  * @remote
	  * @method reviewFindModal
	  * @returnformat {plain}
	  * @return {String}
	  */
	--->
<cffunction name="reviewFindModal" access="remote" returntype="String" returnformat="plain">
		<cfset var sReviewForm 				= "">
		<cfset var sReviewModal 			= "">
		<cfset var oUtil 							= createObject("tapir.utils")>
		<cfset var repoDropdownGroup 	= oUtil.runUtilFn("svn","getReposAndRevisions",{})>

		<cfsavecontent variable="sReviewForm" trim="true">
			<form id="lookup" action="/tapir/rpc/review.cfc?method=reviewSeach&reviewId=<%=#request.tapir.getReviewId()#%>" method="POST">
				<div id="startControl">
					<div class="form-group">
						<label for="Repository">Select a Repository</label>
						<select class="form-control" id="repo">
							<option value="">--</option>
							<cfloop array="#repoDropdownGroup#" index="repo">
								<cfoutput><option value="#repo.value#" data-head="#repo.data#">#repo.label#</option></cfoutput>
							</cfloop>
						</select>
					</div>
					<div id="ticketcontrol">
						<div class="form-group">
							<label for="repoStart">Revision Search start</label>
							<input type="text" class="form-control" id="repoStart" placeholder="Revision" title="You should not have to modify this, unless you are searching for older content.">
						</div>
						<div class="form-group">
							<label for="ticket">Tick'd ID</label>
							<input type="text" class="form-control" id="ticket" placeholder="Tick'd Ticket ID">
						</div>
					</div>
					<div	id="revisionscontrol">
						<div class="form-group">
							<label for="revisions">Revision List</label>
							<input type="text" class="form-control" id="revisions" placeholder="List of SVN Revisions">
						</div>
					</div>
				</div>

				<div style="text-align:center"><hr/>or<br />Search for an existing Review<hr/></div>

				<div id="searchControl">
					<div class="form-group">
						<label for="reviewID">Review ID</label>
						<input type="text" class="form-control" id="reviewID" placeholder="Review ID">
					</div>
				</div>

			</form>
		</cfsavecontent>

		<cfsavecontent variable="sReviewModal" trim="true">
			<BOOTSTRAP:modal title="TAPIR Review" message="#sReviewForm#" hide="#request.tapir.isLoaded()#">
				<BOOTSTRAP:button extras='#{"data-dismiss"="modal"}#'>Close</BOOTSTRAP:button>
				<BOOTSTRAP:button type="primary" id="submitInput" >Submit</BOOTSTRAP:button>
			</BOOTSTRAP:modal>
		</cfsavecontent>

		<cfreturn sReviewModal>
	</cffunction>


	<!---
	/**
	  * @remote
	  * @method reviewExport
	  * @param {any} [mScan = true]
	  * @returnformat {plain}
	  * @return {string}
	  */
	--->
<cffunction name="reviewExport" access="remote" returntype="string" returnformat="plain">
		<cfargument name="mScan" default="true">
		<cfset var sExportForm 	= "">
		<cfset var sExportModal = "">
		<cfset var oUtils 			= createObject("tapir.utils")>

		<cfsavecontent variable="sExportForm">
			<form>
				<div class="form-group">
					<textarea class="form-control" id="markdown" rows="10"><%=#oUtils.getUtil("commentsToMarkdown").getMarkdown(request.tapir.getReviewId(), arguments.mScan)#%></textarea>
				</div>
			</form>
		</cfsavecontent>

		<cfsavecontent variable="sExportModal">
			<BOOTSTRAP:modal title="TAPIR Review" message="#sExportForm#" hide="#false#">
				<BOOTSTRAP:button extras='#{"data-dismiss"="modal"}#'>Close</BOOTSTRAP:button>
				<BOOTSTRAP:button type="primary" id="copy" extras='#{"data-copy"="##markdown","data-confirm"=".modal-footer"}#'>Copy to Clipboard</BOOTSTRAP:button>
			</BOOTSTRAP:modal>
		</cfsavecontent>

		<cfreturn sExportModal>
	</cffunction>



	<!---
	/**
	  * @private
	  * @method getFileLines
	  * @param {string} _file (required)
	  * @param {string} _sReviewID (required)
	  */
	--->
<cffunction name="getFileLines" access="private" returntype="String">
		<cfargument name="_file" required="true" type="string">
		<cfargument name="_sReviewID" required="true" type="string">
		<cfscript>
			var tmpPath = "/var/tmp/24hr/";
			var tmpFile = replace(replace(_path,".","","ALL"),"/","","ALL") & ".tmp";
			var i 			= 0;
			var sCode 	= "";
			var lf 			= chr(13) & chr(10);

			if (!fileExists(tmpPath & tmpFile)){
				var uReview = Application.dgw.invokeByRestOutStruct("tapir.review.get_meta",application.appkey,{sReviewId:_sReviewID});
				svnGetFile( uReview.repository, _path, tmpPath & tmpFile, -1, false );
			}

			try {
				var oFile = fileOpen(tmpPath & tmpFile);

				for ( i = 1; i <= _line; i++ ){
					fileReadLine(oFile);
				}
				for ( i = 1; i <= _length; i++ ){
					sCode = listAppend(sCode,fileReadLine(oFile),lf);
				}
			} catch (any e){
				sCode = "ERROR during code retrieval";
			} finally {
				fileClose(oFile);
			}

			return sCode;
		</cfscript>
	</cffunction>



</cfcomponent>