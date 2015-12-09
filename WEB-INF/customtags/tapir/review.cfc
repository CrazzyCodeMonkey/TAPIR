<cfcomponent output="false"><cfscript>
	this.class_path = "tapir.review";

	/**
		* @class tapir.review
		*
		*/



	this.sReviewID = "";
	variables.bInit = false;
	variables.uMeta = {};




	/**
		* @method init
		* @public
		* @param {string} [_sReviewId = ""]
		* @return {component}
		*/
	public component function init(string _sReviewId=""){
		if (_sReviewId != ""){
			this.loadReview(arguments._sReviewId);
		}
		return this;
	}


	/**
		* @method reload
		* @public
		*/
	public string function reload(){
		this.loadReview(this.sReviewID);
	}



	/**
		* @method isLoaded
		* @public
		* @return {boolean} flag to indicate if a review has been loaded
		*/
	public boolean function isLoaded(){
		return variables.bInit;
	}



	/**
		* @method getReviewId
		* @public
		* @return {string}
		*/
	public string function getReviewId(){
		var sReviewId = "";

		if (this.isLoaded()){
			sReviewID = this.sReviewID;
		}

		return sReviewID;
	}



	/**
		* @method getRepo
		* @public
		* @return {string}
		*/
	public string function getRepo(){
		var sRepo = "";

		if (this.isLoaded()){
			sRepo = variables.uMeta.repository;
		}

		return sRepo;
	}



	/**
		* @method getRevisions
		* @public
		* @return {array}
		*/
	public array function getRevisions(){
		var aRevs = [];

		if (this.isLoaded()){
			return variables.uMeta.revisions;
		}

		return aRevs;
	}



	/**
		* @method getTicket
		* @public
		* @return {numeric}
		*/
	public numeric function getTicket(){
		var nTicket = 0;

		if (this.isLoaded()){
			nTicket = variables.uMeta.ticket;
		}

		return nTicket;
	}



	/**
		* @method getRevisionStart
		* @public
		* @return {numeric}
		*/
	public numeric function getRevisionStart(){
		var nRev = 0;

		if (this.isLoaded()){
			nRev = arrayMin(this.getRevisions());
		}

		return nRev;
	}



	/**
		* @method getStatus
		* @public
		* @return {string}
		*/
	public string function getStatus(){
		var sStatus = "";

		if (this.isLoaded()){
			sStatus = variables.uMeta.status;
		}

		return sStatus;
	}



	public string function getParentReview(){
		var sRet = "";

		if (structKeyExists(variables.uMeta,"previous_review")){
			sRet = variables.uMeta.previous_review;
		}

		return sRet;
	}



	public struct function getFilesToReview(){
		var uRet = {newFiles:0,updatedFiles:0,deletedFiles:0,noLongerExist:0};

		if (this.isLoaded()){
			uRet = variables.uMeta.filesToReview;
		}

		return uRet;

	}



	public string function getAuthor(){
		var sAuthor = "";

		if (this.isLoaded()){
			sAuthor = variables.uMeta.author;
		}

		return sAuthor;
	}



	/**
		* @method newReview
		* @public
		* @param {string} _sRepository (required)
		* @param {numeric} _nTicket (required)
		* @param {string} _nRevisions (required)
		* @param {numeric} _nRepoStart (required)
		* @param {string} [_sPrevReview = ""]
		*/
	public void function newReview(required string _sRepository, required numeric _nTicket, required string _nRevisions, required numeric _nRepoStart, string _sPrevReview=""){
		var uReview = {};
		var uStatusTrans = {A:"newFiles",D:"deletedFiles",M:"updatedFiles",X:"noLongerExist",R:"updatedFiles"};
		var uParams = {
			revision_head : SVNLatestRevision(_sRepository),
			ticket : fix(_nTicket),
			revisions: _nRevisions,
			author: SESSION.user.getEmail(),
			previous_review: _sPrevReview,
			repository: _sRepository,
			filesToReview:{
				newFiles:0,
				updatedFiles:0,
				deletedFiles:0,
				noLongerExist:0,
				unknown:0
			}
		};

		if (uParams.ticket != 0){
			var oUtil = createObject("tapir.utils");
			var nRepoStart = _nRepoStart;

			if (_sPrevReview != ""){
				var uParentReview = Application.dgw.invokeByRestOutStruct("tapir.review.get_meta",Application.appKey,{sReviewID:_sPrevReview});
				nRepoStart = uPArentReview.revision_head+1;
			}

			var aLogs = SVNLogView(name=uParams.repository,startRevision=nRepoStart,filter= "[##" & uParams.ticket & "]");

			if (arrayLen(aLogs)==0){
				throw("TAPIR",
							"No new revisions",
							"No checkins have been made to ticket <a href='https://www.YOUR_TICKET_SERVER.com/?/#uParams.ticket#'>#uParams.ticket#</a> since revision #nRepoStart#");
			}

			uParams.revisions = arrayToList(oUtil.runUtilFn("svn","getLogRevisions",{_aLogs:aLogs}));
			var uFiles = oUtil.runUtilFn("svn","getLogFiles",{_repo:uParams.repository, _aLogs:aLogs});
			for (var f in uFiles){
				if (structKeyExists(uStatusTrans,uFiles[f].status)){
					uParams.filesToReview[uStatusTrans[uFiles[f].status]]++;
				} else {
					uParams.filesToReview.unknown++;
				}
			}
			uParams.filesToReview = serializeJSON(uParams.filesToReview);
		} else {
			uParams.ticket = 0;
		}

		try {
			uReview = Application.dgw.invokeByRestOutStruct( "tapir.review.new", application.appkey, uParams);
		} catch ( any e ){
			uReview.sReviewId = "";
		} finally {
			this.init( uReview.sReviewId );
			this.sendTicketEmail();
			}
		}



	/**
		* @method getFiles
		* @public
		* @return {array}
		*/
	public array function getFiles(){
		var aFiles = [];
		var uParams = {sReviewID:this.sReviewId};

		if (this.isLoaded()){
			try {
				aFiles = application.dgw.invokeByRestOutStruct("tapir.review.files.get_all_names",application.appkey,uParams).files;
			} catch (any e){
				//nothing to do here
			}
		}

		return aFiles;
	}



	/**
		* @method loadReview
		* @private
		* @param {string} _sReviewId (required)
		*/
	private void function loadReview(required string _sReviewId){
		try {
			this.sReviewID = arguments._sReviewId;
			variables.uMeta = application.dgw.invokeByRestOutStruct("tapir.review.get",application.appkey,{sReviewID:arguments._sReviewId}).review;
			variables.bInit = true;
		} catch (any e){
			this.sReviewID = "";
			//nothing to do here
		}
	}



</cfscript>


<cffunction name="sendTicketEmail" access="private" returntype="void">
	<cfif (!this.isLoaded())>
		<cfthrow type="TAPIR" message="trying to send a review specific email without a review">
	<cfelseif this.getTicket() != 0>
		<cfmail to="TICKET_EMAIL@YOUR_DOMAIN.com"from="#this.getAuthor()#" subject="New TAPIR Review" type="html">
			<p>I have started a Code Review for this Ticket on <a href="#Application.domain#/tapir/review.cfm?reviewid#this.getReviewId()#" target="blank">TAPIR</a>.</p>
			<p>Please to do not make any futher checkins against this ticket, until this code review is completed</p>
		</cfmail>
	</cfif>
</cffunction>


</cfcomponent>