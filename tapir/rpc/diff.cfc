<cfcomponent output="false">
	<cfimport taglib="/WEB-INF/bootstrap_tags/tapir_tags/" prefix="TAPIR" />
	<cfset this.class_path = "tapir.rpc.diff">



	<!---
	/**
		* @class tapir.rpc.diff
		* @static
		*
		*/
	--->



	<!---
	/**
		* do everthing needed to render the diff pane
		*
		* @remote
		* @method diffRender
		* @param {string} _repo (required) the repository
		* @param {string} _file (required) the file path
		* @param {string} _revisions (required) the file revision
		* @returnformat {JSON}
		*/
	--->
<cffunction name="diffRender" access="remote" returntype="struct" returnformat="JSON" hint="do everthing needed to render the diff pane">
		<cfargument name="_repo" type="string" required="true" hint="the repository">
		<cfargument name="_file" type="string" required="true" hint="the file path">
		<cfargument name="_revisions" type="string" required="true" hint="the file revision">

		<cfscript>
			//get the SVN status of the file
			var sStatus										= SVNGetStatus(_repo, _file, -1);
			var sRet											= "";
			var uRevLog										= {};
			var aComment									= [];
			server.logger.logMessage("INFO","TAPIR:loading diff page for ",{args:arguments,vars:VARIABLES,status:sStatus},"tapir.diff");

			if (!request.tapir.isLoaded()){
				//something odd happened and we don't have a tapir object...
				sRet												= "<h1 style='text-align:center'>SVN DIFF SETUP ERROR</h1>request.tapir not found, please reload the page";
			} else if (sStatus == "file"){

				//we have a file, do the stuff
				try {
					var aRevs									= listToArray(_revisions);
					var rev										= "";
					var aPrevComment					= [];
					var diff									= {};
					var sDiff									= "";
					var files									= application.dgw.invokeByRestOutStruct( "tapir.review.files.get_all_names", application.appkey, {sReviewId : request.tapir.getReviewId()} );
					var currItem							= Application.dgw.invokeByRestOutStruct( "tapir.review.get_meta", Application.appkey, {sReviewId: request.tapir.getReviewId()} );

					//see if we need to run the automated review
					if ( arrayFind(files.files, _file) == 0 && currItem.status != "COMPLETE" ){
						var HEAD								= SVNGetRevision(_repo,_file,"HEAD");
						Application.dgw.invokeByRestOutStruct("tapir.review.files.add",Application.appkey,{sReviewId: request.tapir.getReviewId(), filePath : _file, revision_head:HEAD});
						//mScan integration recomended point
					}


					if ( len(request.tapir.getParentReview()) > 0 ){
						aPrevComment						= Application.dgw.invokeByRestOutStruct( "tapir.review.files.get",Application.appkey,{sReviewId : request.tapir.getParentReview(), filePath : _file});
					}

					diff = getSVNDiff(_repo, _file, fix(listLast(_revisions)), fix(listFirst(_revisions)));

					//get the author of all the revisions included in this diff
					for (rev in diff.revisions){
						uRevLog[rev]						= SVNLogView(_repo,rev,rev)[1];
						uRevLog[rev].author			= uCase(uRevLog[rev].author);
					}

					//get the comments for this file
					aComment									= Application.dgw.invokeByRestOutStruct( "tapir.review.files.get", Application.appkey, {sReviewId : request.tapir.getReviewId(), filePath : _file});

					//if we didn't have any comments, set up the base structure
					if( !aComment._success ) {
						if( currItem.status == "COMPLETE" ) {
							aComment.file					= { comments: {} };
						}
					}

					//render the Diff view
					sRet 											= renderDiff({
						repo											: _repo,
						file											: _file,
						rev												: _revisions,
						comments									: aComment,
						prevComments							: aPrevComment,
						diff											: diff.diff,
						revisions									: diff.revisions,
						revLogs										: uRevLog});
				} catch (DIFFError e){
					sRet												= "<h1 style='text-align:center'>SVN DIFF ERROR</h1>";
					sRet												&= "<div style='text-align:center'>"& e.message & "<br />Below is the diff for your viewing.  Comments will need to be made manually</div>";
					sRet												&= "<hr />";
					sRet												&= e.detail;
					server.logger.logMessage("SEVERE","TAPIR: Diff Compile error",{args:arguments,error:e,vars:VARIABLES},"tapir.diff");
				} catch (DIFFBinary e){
					sRet												= "<h1 style='text-align:center'>SVN DIFF ERROR</h1>";
					sRet												&= "<div style='text-align:center'>"& e.message & "</div>";
				} catch (any e){
					//render an error message along with the HTML diff version
					sRet 												= "<h1 style='text-align:center'>SVN DIFF ERROR</h1>";
					sRet 												&= "<div style='text-align:center'>"& e.message & "<br />" & e.detail & "</div>";
					server.logger.logMessage("SEVERE","TAPIR: Error loading diff panel",{args:arguments,error:e,vars:VARIABLES},"tapir.diff");
				}

			} else {

				//this file doesn't exist anymore, so we can't show the diff, report back to the user
				nHead												= SVNLatestRevision(_repo);
				sRet												= "<h1 style='text-align:center'>SVN Missing File</h1>"&
																			"<strong>#listLast(_file,"/")#</strong> no longer exists at revision <strong>#nHead#</strong>";
			}

			return { html: sRet, comments: aComment };
		</cfscript>
	</cffunction>



	<!---
	/**
		* save a comment
		*
		* @remote
		* @method saveComment
		* @param {string} _path (required) the file path
		* @param {string} _comment (required) the comment
		* @param {string} _line (required) the line the comment starts one
		* @param {string} _length (required) the number of lines the comment applies to
		* @param {string} {string} [_code = false" hint="flag to include the code] flag to include the code
		* @param {string} {string} [_source = manual" hint="the source of the comment [mScan|manual]] the source of the comment [mScan|manual]
		* @returnformat {JSON}
		*/
	--->
<cffunction name="saveComment" access="remote" returntype="struct" returnformat="JSON" hint="save a comment">
		<cfargument name="_path" 		type="string" required="true" 	hint="the file path">
		<cfargument name="_comment" type="string" required="true" 	hint="the comment">
		<cfargument name="_line" 		type="string" required="true" 	hint="the line the comment starts one">
		<cfargument name="_length" 	type="string" required="true" 	hint="the number of lines the comment applies to">
		<cfargument name="_code" 		type="string" required="false" 	hint="flag to include the code" 								default="false">
		<cfargument name="_source" 	type="string" required="false" 	hint="the source of the comment [mScan|manual]" default="manual">
		<cfscript>
			// Check if the comment is empty or not, and return error if it is.
			if( len(arguments._comment) == 0 ) {
				return { _success: false, _message: "The comment can not be empty" };
			}

			var sCode											= "";

			//only the review owner can make comments
			if (SESSION.user.getEmail() != request.tapir.getAuthor()){
				//you can't make comments
				return {
					_success									: false,
					_message									: "Only the author can make comments on this review"};
			}

			//see if we need to include the code
			if (_code){
				sCode 											= this.getFileLines(_path,request.tapir.getReviewId(), _line);
			}

			//save the comment
			var gateletResult							= Application.dgw.invokeByRestOutStruct( "tapir.review.files.add_file_comment",
				Application.appkey,
				{
					sReviewId										: request.tapir.getReviewId(),
					filePath										: arguments._path,
					comment											: arguments._comment,
					line												: arguments._line,
					length											: fix(arguments._length),
					code												: sCode,
					source											: arguments._source});

			return gateletResult;

		</cfscript>
	</cffunction>



	<!---
	/**
		* get the comments for a file
		*
		* @remote
		* @method getComment
		* @returnformat {JSON}
		*/
	--->
<cffunction name="getComment" access="remote" returntype="struct" returnformat="JSON" hint="get the comments for a file">
		<cfscript>
				var gateletResult					= Application.dgw.invokeByRestOutStruct(		"tapir.review.files.get",
					Application.appkey,
					{
						sReviewId								: request.tapir.getReviewId(),
						filePath								: arguments._path});

			return gateletResult;

		</cfscript>
	</cffunction>



	<!---
	/**
		* render the comment form
		*
		* @remote
		* @method createComment
		* @param {string} _lineInfo (required) 	Header info displaying the numerical range of the selected line
		* @param {string} _comment (required) 	The Content of the comment
		* @param {string} _delete (required) 		Flag to specify if the delete button should be render
		* @returnformat {plain}
		* @return {string}
		*/
	--->
<cffunction name="createComment" access="remote" returntype="string" returnformat="plain" hint="render the comment form">
		<cfargument name="_lineInfo" type="string" required="true" hint="">
		<cfargument name="_comment" type="string" required="true" hint="">
		<cfargument name="_delete" type="string" required="true" hint="">

		<cfset var export="">

		<!--- render a comment form --->
		<cfsavecontent variable="export">
			<TAPIR:commitcomment lineInfo="#_lineinfo#" comment="#_comment#" delete="#_delete#">
		</cfsavecontent>

		<cfreturn export>
	</cffunction>



	<!---
	/**
		* render the comment static display
		*
		* @remote
		* @method displayComment
		* @param {string} _lineInfo (required) 	Header info displaying the numerical range of the selected line
		* @param {string} _comment (required) 	The Content of the comment
		* @param {string} _usertag (required) 	The tag used inside the user logo
		* @returnformat {plain}
		* @return {string}
		*/
	--->
<cffunction name="displayComment" access="remote" returntype="string" returnformat="plain" hint="render the comment static display">
		<cfargument name="_lineInfo" type="string" required="true" hint="">
		<cfargument name="_comment" type="string" required="true" hint="">
		<cfargument name="_usertag" type="string" required="true" hint="">

		<cfset var export="">

		<!--- render a static comment --->
		<cfsavecontent variable="export">
			<TAPIR:displaycomment lineInfo="#_lineinfo#" comment="#_comment#" usertag="#_usertag#">
		</cfsavecontent>

		<cfreturn export>
	</cffunction>



	<!---
	/**
		* remove the comment
		*
		* @remote
		* @method removeComment
		* @param {string} _path (required) the file path
		* @param {string} _line (required) the line the comment starts on
		* @returnformat {JSON}
		*/
	--->
<cffunction name="removeComment" access="remote" returntype="struct" returnformat="JSON" hint="remove the comment">
		<cfargument name="_path" type="string" required="true" hint="the file path">
		<cfargument name="_line" type="string" required="true" hint="the line the comment starts on">

		<cfscript>
			//only the owner of the review and remove comments
			if (SESSION.user.getEmail() != request.tapir.getAuthor()){
				//you can't remove this comment
				return {_success:false,_message:"Only the author can make comments on this review"};
			}

			//remove the comment
			var gateletResult = application.dgw.invokeByRestOutStruct("tapir.review.files.remove_comment",application.appkey,{sReviewId: request.tapir.getReviewId(),
				filePath: arguments._path,
				line: arguments._line
			});

			return gateletResult;

		</cfscript>

	</cffunction>



	<!---
	/**
		* get the lines of the file
		*
		* @private
		* @method getFileLines
		* @param {string} _file (required)  the file path
		* @param {string} _sReviewID (required)  the review id
		*/
	--->
<cffunction name="getFileLines" access="private" returntype="String" hint="get the lines of the file">
		<cfargument name="_file" 			required="true" type="string" hint="the file path">
		<cfargument name="_sReviewID" required="true" type="string" hint="the review id">
		<cfargument name="_line" 			required="true" type="string">
		<cfscript>
			//build a temp file that is reusable so we don't have to keep redownloading the file
			var tmpPath										= "/var/tmp/24hr/";
			var tmpFile										= replace(replace(_path,".","","ALL"),"/","","ALL") & ".tmp";
			var i													= 0;
			var sCode											= "";
			var lf												= chr(13) & chr(10);

			//see if the temp file exists
			if (!fileExists(tmpPath & tmpFile)){
				//get the meta information of the review, so we know what repository to go to
				var uReview									= Application.dgw.invokeByRestOutStruct("tapir.review.get_meta",application.appkey,{sReviewId:_sReviewID});
				//download the file from SVN ad HEAD
				svnGetFile( uReview.repository, _path, tmpPath & tmpFile, -1, false );
			}

			try {
				//open the file
				var oFile										= fileOpen(tmpPath & tmpFile);

				//traverse the file to the line before where we need to get code at
				for ( i = 1; i <= _line-1; i++ ){
					fileReadLine(oFile);
				}

				//read the code over the length that is specified
				for ( i = 1; i <= _length; i++ ){
					sCode											= listAppend(sCode,fileReadLine(oFile),lf);
				}
			} catch (any e){
				//something went wrong
				sCode												= "ERROR during code retrieval";
			} finally {
				//clean up and close the file
				fileClose(oFile);
			}

			return sCode;
		</cfscript>
	</cffunction>



	<!---
	/**
		* render the diff panel
		*
		* @private
		* @method renderDiff
		* @param {struct} _uAttributes (required)  attributes needed to render the diff panel
		* @return {String}
		*/
	--->
	<cffunction name="renderDiff" access="private" returntype="String" hint="render the diff panel">
		<cfargument name="_uAttributes" required="true" type="struct" hint="attributes needed to render the diff panel">

		<cfset var sRet = "">

		<!--- render the diff panel --->
		<cftry >
			<cfsavecontent variable="sRet" trim="true">
				<TAPIR:diff attributecollection="#_uAttributes#" />
			</cfsavecontent>
			<cfcatch type="any">
				<!--- something broke, render the message --->
				<cfsavecontent variable="sRet"><cfdump var="#CFCATCH#"></cfsavecontent>
			</cfcatch>
		</cftry>

		<cfreturn sRet>
	</cffunction>



	<!---
		/**
			* get the diff struct of the requested file
			*
			* @method getSVNDiff
			* @param {string} _repo (required) the SVN repository
			* @param {string} _file (required) the SVN path
			* @param {numeric} _revNewest (required) the most recent revision to include on the diff
			* @param {numeric} _revOldest (required) the oldest revision to include on the diff
			* @throws DIFFBinary
			* @throws DIFFError
			*						details will contain the html formatted diff
	--->
	<cffunction name="getSVNDiff" access="private" returntype="Struct" hint="get the diff struct of the requested file">
		<cfargument name="_repo" type="string" required="true" hint="the SVN repository">
		<cfargument name="_file" type="string" required="true" hint="the SVN path">
		<cfargument name="_revNewest" type="numeric" required="true" hint="the most recent revision to include on the diff">
		<cfargument name="_revOldest" type="numeric" required="true" hint="the oldest revision to include on the diff">
		<cfscript>
			var diff = {};
			var uDiffParams 								= {
				name													: _repo,
				svnPath 											: _file,
				listInfo 											: "overlay",
				revisionNewest 								: _revNewest,
				revisionOldest								: _revOldest,
				splitRevision 								: true};

			try {
					//try to get the diff
					var diff											= SVNDiff(argumentCollection=uDiffParams);
					Server.logger.logMessage("INFO","TAPIR:SVNDiff",{args:uDiffParams},"tapir.diff");

				} catch (any e){
					//log the error
					Server.logger.logMessage("INFO","TAPIR-ERROR:SVNDiff",{args:uDiffParams,error:e},"tapir.diff");
					try {
						//try to get re review, without the revision split
						uDiffParams.splitRevision = false;
						diff								= SVNDiff(argumentCollection=uDiffParams);
						Server.logger.logMessage("INFO","TAPIR:SVNDiff",{args:uDiffParams},"tapir.diff");

					} catch (any e2){
						//log the new error
						Server.logger.logMessage("INFO","TAPIR-ERROR:SVNDiff",{args:uDiffParams,error:e},"tapir.diff");
						uDiffParams.splitRevision = true;
						uDiffParams.listInfo = "html";

						//at least get something to display, get the HTML version of the diff to display
						var sDiff						= SVNDiff(argumentCollection = uDiffParams);
						Server.logger.logMessage("INFO","TAPIR:SVNDiff-TEXT",{args:uDiffParams},"tapir.diff");

						if (find("Cannot display: file marked as a binary type.",sDiff)>0){
							//no recovery, can't display diff on a binary file
							throw("DIFFBinary", "Cannot render DIFF display of Binary files");
						} else {
							//we still ran into an error, and need to handle it differently as we can't continue with normal execution
							throw("DIFFError","There wan an unknown error rendering the DIFF for the file", sDiff);
						}
					}
				}

			return diff;
		</cfscript>
	</cffunction>

</cfcomponent>