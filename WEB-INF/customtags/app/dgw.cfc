<cfcomponent output="false"><cfscript>

public struct function invokeByRestOutStruct(required _sEndPoint, required _sKey, required _uParams){
	this.key = _sKey;
	return runEndPoint(_sEndPoint, _uParams);
}


private any function runEndPoint(required string _sEndPoint, struct _uParams){
	var sFnEndPoint = replace(_sEndPoint, ".", "_", "ALL");
	if (structKeyExists(this, sFnEndPoint)){
		var uParams = structCopy(_uParams);
		uParams.key = this.sKey;

		return invoke(this, sFnEndPoint, uParams);

	} else {
		throw ("DGW", "no such endpoint [#_sEndPoint#]");
	}
}


private struct function tapir_getds(required string _key){
	var dsName = "mongoTAPIR";

	if ( !mongoIsValid( dsName ) ){
		var dbName = "127.0.0.1"; //SERVER name
		var dbPort = 27017; //SERVER Port
		var dbCollection = "tapir"; //collection name
		var dbUser = ""; //Collection username
		var dbPass = ""; //Collection password

		try {
			if (!mongoRegister( dsName, dbName, dbPort, dbCollection, dbUser, dbPass )){
				dsName = "";
			};
		} catch (any e){
			dsName = "";
		}

	}

	return dsName;
}



private struct function tapir_review_finalize(required string _key, required string sReviewId, required string comment){
	/**
		* add_file add a comment to a file
		*
		* @param {string} sReviewId review id
		* @param {string} comment closing comment (ie: don't need to see this back)
		* @return {struct} _success indicates success of retrieval
		* 									_message any error message encountered
		*/

	//return variable setup
	var uRet = {
		_success : false
	};

	try {
		arguments.oReviewId = mongoObjectId(arguments.sReviewId);
	} catch (any e) {
		uRet._error = e;
	}

	//check all the variables
	if ( !structKeyExists(arguments,"oReviewId") ||
				len( arguments.comment ) == 0 ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else {
		//get the datasource
		var sDataSource = runGatelet(gatelet="tapir.getds");
		//see what files already have records
		var sCollection = "review";

		//set up the query
		var uQuery = {
			_id : arguments.oReviewId
		};

		//set up the closing update statement
		var uUpdate = {
			"$set": {
				status : "COMPLETE",
				dt_complete : now(),
				comment : arguments.comment
			}
		};

		//try to insert the comment
		try {
			uMongoResult = mongoCollectionFindAndModify(
				datasource : sDataSource,
				collection : sCollection,
				query : uQuery,
				update : uUpdate,
				upsert : true,
				returnnew : true
			);
		} catch (any e){
			//oops, something went wrong
			uRet._error = e;
			uRet._message = e.details;
			uRet._arguments = arguments;
		} finally {
			//set the success flag
			uRet._success = (	structKeyExists( uMongoResult, "status" ) && uMongoResult.status == "COMPLETE");
		}

	}

	return uRet;
}



private struct function tapir_review_find(required string _key, required string query){
	/**
		* get a review by its id
		*
		* @param {string} sReviewId review id
		* @param {string} filePath file path
		* @return {struct} _success indicates success of retrieval
		* 									_message any error message encountered
		* 									file the file that was reviewed
		*/

	//return variable setup
	var id = "";
	var rawData = [];
	var uRet = {
		_success : false
	};

	try {
		arguments.uQuery = deserializeJSON(arguments.query);
	} catch (any e){
		arguments.uQuery = {};
	}

	//check all the variables
	if ( structIsEmpty(arguments.uQuery) ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else {
		//get the datasource
		var sDataSource = runGatelet(gatelet="tapir.getds");
		var sCollection = "review";

		//set up the return fields
		var uFields = {
			_id:1
		};

		//set up the sort fields
		var uSort = {
			dt_create:-1
		};

		uMongoParams = {
			datasource:sDataSource,
			collection:sCollection,
			query:arguments.uQuery,
			fields:uFields,
			sort:uSort};

		try {

			rawData = mongoCollectionFind(argumentCollection=uMongoParams);
			uRet.reviews = [];
			for (id in rawData){
				arrayAppend(uRet.reviews,id._id.toString());
			}
		} catch (any e) {
			uRet._message == "Unable to find matching records";
			uRet._error = e;
			uRet._arguments = arguments;
		} finally  {
			uRet._success = (structKeyExists(uRet,"reviews") && arrayLen(uRet.reviews) > 0);
		}

	}

	return uRet;
}



private struct function tapir_review_get(required string _key, required string sReviewId){
	/**
		* get a review by its id
		*
		* @param {string} sReviewId review id
		* @return {struct} _success indicates success of retrieval
		* 									_message any error message encountered
		* 									review the review struct
		*/

	//return variable setup
	var uRet = {
		_success : false
	};

	try {
		arguments.oReviewId = mongoObjectId(arguments.sReviewId);
	} catch (any e) {
		uRet._error = e;
	}

	//check all the variables
	if ( !structKeyExists(arguments,"oReviewId") ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else {
		//get the datasource
		var sDataSource = runGatelet(gatelet="tapir.getds");
		var sCollection = "review";

		//set up the query
		var uQuery = {
			_id : arguments.oReviewId
		};

		//set up the return fields
		var uFields = {
			_id:0
		};

		//try to get the review from mongo
		try {

			var aResult = mongoCollectionFind(sDataSource, sCollection, uQuery, uFields);
			if (arrayLen(aResult)==1){
				uRet.review = aResult[1];
			}
		} catch (any e){
			//oops something went wrong
			uRet.review = {};
			uRet._message = e.details;
			uRet._error = e;
			uRet._arguments = arguments;
		} finally {
			//see if we have a review to return
			uRet._success = ( structKeyExists( uRet, "review" ) && !structIsEmpty( uRet.review ) );
		}
	}

	return uRet;
}



private struct function tapir_review_get_meta(required string _key, required string sReviewId){
	/**
		* add_file add a comment to a file
		*
		* @param {string} sReviewId review id
		* @return {struct} _success indicates success of retrieval
		* 									_message any error message encountered
		*/

	//return variable setup
	var uRet = {
		_success : false
	};

	try {
		arguments.oReviewId = mongoObjectId(arguments.sReviewId);
	} catch (any e) {
		uRet._error = e;
	}

	//check all the variables
	if ( !structKeyExists(arguments,"oReviewId") ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else {
		//get the datasource
		var sDataSource = runGatelet(gatelet="tapir.getds");
		//see what files already have records
		var sCollection = "review";

		//set up the query
		var uQuery = {
			_id : arguments.oReviewId
		};

		//set up the closing update statement
		var uFields = {
			_id:0
		};

		//try to insert the comment
		try {
			var aResult = mongoCollectionFind(sDataSource, sCollection, uQuery, uFields);

			if (arrayLen(aResult)==1){
				structAppend(uRet, aResult[1]);
			}
			uRet.filesReviewed = structCount(uRet.files);
			structDelete(uRet,"files");
		} catch (any e){
			//oops something went wrong
			uRet._message = e.details;
			uRet._error = e;
			uRet._arguments = arguments;
		} finally {
			//see if we have a review to return
			uRet._success = ( structKeyExists( uRet, "status" ) );
		}

	}

	return uRet;
}



private struct function tapir_review_new(required string _key, required string revision_head, required string ticket, required string revisions, required string author, required string previous_review, required string repository, required string filesToReview){
	/**
		* create a review record with a NEW status, and current dt stamp
		*
		* @param {string->numeric} revision_head SVN Revision HEAD
		* @param {string->numeric} tickiet Ticket ID
		* @param {string->list} list of SVN revisions included
		* @param {string} author name of person that started the review
		* @param {string} (previsou_review="") id of previous review
		* @param {string} repository SVN repository name
		* @param {string->struct} filesToReview JSON struct of files counts
		* @return {struct} _success indicated success of insert
		* 									_sReviewId the review id
		* 									_message any error message encountered
		*/

	//return variable setup
	var uRet = {
		_success : false
	};

	try {
		arguments.uFilesToReview = deserializeJSON(arguments.filesToReview);
	} catch (any e) {
		//nothing to do here
	}

	//check all the variables
	if ( len( arguments.revision_head ) == 0 || !isNumeric( arguments.revision_head ) ||
				len( arguments.ticket )==0 || !isNumeric( arguments.ticket ) ||
				len( arguments.revisions )==0 || len( arguments.author )==0 ||
				len( arguments.repository) == 0 ||
				!structKeyExists(arguments,"uFilesToReview") || !isStruct(arguments.uFilesToReview)){
		//not all expected arguments had values expected
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;

	} else {
		//have all the values we need

		//get the datasource
		var sDataSource = runGatelet(gatelet="tapir.getds");
		var sCollection = "review";
		var i=0;

		//set up the review data
		var uData = {
			revision_head 							: fix(arguments.revision_head),
			ticket 											: fix(ticket),
			revisions 									: [],
			files 											: {},
			dt_create 									: now(),
			status 											: "NEW",
			author 											: arguments.author,
			repository									: arguments.repository,
			filesToReview								: arguments.uFilesToReview
		};

		//convert the list of revisions to an array of numbers
		for (i = 1; i <= listLen(arguments.revisions); i++ ) {
			arrayAppend(uData.revisions,fix(listGetAt(arguments.revisions,i)));
		}

		//see if we have a previous_review
		if ( len( trim( arguments.previous_review ) ) > 0 ){
			//we have a previous_review, add it to the review data
			uData.previous_review = arguments.previous_review;
		}

		//try to insert the review data into mongo
		try {
			uRet.sReviewId = mongoCollectionInsert( sDataSource, sCollection, uData );
		} catch (any e){
			//oops something broke
			uRet.sReviewId = "";
			uRet._message = e.details;
			uRet._arguments = arguments;
			uRet._error = e;
		} finally {
			//test to make sure we have a review id
			uRet._success = ( structKeyExists( uRet, "sReviewId" ) && len( uRet.sReviewId ) > 0 );
		}
	}

	return uRet;
}



private struct function tapir_review_reassign(required string _key, required string sReviewId, required string newAuthor){
	/**
		* add_file add a comment to a file
		*
		* @param {string} sReviewId review id
		* @param {string} newAuthor email address for the new author
		* @return {struct} _success indicates success of reassignment
		* 									_message any error message encountered
		*/

	//return variable setup
	var uRet = {
		_success : false
	};

	try {
		arguments.oReviewId = mongoObjectId(arguments.sReviewId);
	} catch (any e) {
		uRet._error = e;
	}

	//check all the variables
	if ( !structKeyExists(arguments,"oReviewId") ||
				len( arguments.newAuthor ) == 0 || !isValid("email", arguments.newAuthor) ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else {
		//get the datasource
		var sDataSource = runGatelet(gatelet="tapir.getds");
		//see what files already have records
		var sCollection = "review";

		//set up the query
		var uQuery = {
			_id : arguments.oReviewId
		};

		//set up the closing update statement
		var uUpdate = {
			"$set": {
				author:arguments.newAuthor
			}
		};

		//try to insert the comment
		try {
			uMongoResult = mongoCollectionFindAndModify(
				datasource : sDataSource,
				collection : sCollection,
				query : uQuery,
				update : uUpdate,
				upsert : true,
				returnnew : true
			);
		} catch (any e){
			//oops, something went wrong
			uRet._error = e;
			uRet._message = e.details;
			uRet._arguments = arguments;
		} finally {
			//set the success flag
			uRet._success = (	structKeyExists( uMongoResult, "author" ) && uMongoResult.author == arguments.newAuthor);
		}

	}

	return uRet;
}



private struct function tapir_review_reopen(required string _key, required string sReviewId){
	/**
		* add_file add a comment to a file
		*
		* @param {string} sReviewId review id
		* @return {struct} _success indicates success of retrieval
		* 									_message any error message encountered
		*/

	//return variable setup
	var uRet = {
		_success : false
	};

	try {
		arguments.oReviewId = mongoObjectId(arguments.sReviewId);
	} catch (any e) {
		uRet._error = e;
	}

	//check all the variables
	if ( !structKeyExists(arguments,"oReviewId") ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else {
		//get the datasource
		var sDataSource = runGatelet(gatelet="tapir.getds");
		//see what files already have records
		var sCollection = "review";

		//set up the query
		var uQuery = {
			_id : arguments.oReviewId,
			status:"COMPLETE"
		};

		//set up the closing update statement
		var uUpdate = {
			"$unset":{
				dt_complete:"",
				comment:""
				},
			"$set": {
				status : "NEW"
			}
		};

		var uMongoResult = {};

		//try to insert the comment
		try {
			uMongoResult = mongoCollectionFindAndModify(
				datasource : sDataSource,
				collection : sCollection,
				query : uQuery,
				update : uUpdate,
				upsert : true,
				returnnew : true
			);
		} catch (any e){
			//oops, something went wrong
			uRet._error = e;
			uRet._message = e.detail;
			uRet._arguments = arguments;
		} finally {
			//set the success flag
			uRet._success = (	structKeyExists( uMongoResult, "status" ) && uMongoResult.status == "NEW");
		}

	}

	return uRet;
}



private struct function tapir_review_files_add(required string _key, required string sReviewId, required string filePath, required string revision_head){
	/**
		* add_file add a comment to a file
		*
		* @param {string} sReviewId review id
		* @param {string} filePath path to file
		* @param {string->numeric} revision_head head revsion of the file
		* @return {struct} _success indicates success of retrieval
		* 									_message any error message encountered
		*/

	//return variable setup
	var uReview = {};
	var uRet = {
		_success : false
	};

	try {
		arguments.oReviewId = mongoObjectId(arguments.sReviewId);
		uReview = runGatelet(gatelet="tapir.review.get_meta",sReviewId=arguments.sReviewId);
		arguments.reviewStatus = uReview.status;
	} catch (any e) {
		uRet._error = e;
	}

	//check all the variables
	if ( !structKeyExists(arguments,"oReviewId") ||
				len( arguments.filePath ) == 0 ||
				len( arguments.revision_head ) == 0 || !isNumeric( arguments.revision_head ) ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else if (arguments.reviewStatus == "COMPLETE"){
		uRet._message = "This review has already been finalized";
	} else {
		//get the datasource
		var sDataSource = runGatelet(gatelet="tapir.getds");
		//see what files already have records
		var uFiles = runGatelet(gatelet="tapir.review.files.get_all_names", sReviewId=arguments.sReviewId);
		var sCollection = "review";
		var uUpdate = {};
		var uMongoResult = {};

		//trim the extension off the filePath
		var filePathReplace = replace(arguments.filePath,".","~","ALL");

		//set up the query
		var uQuery = {
			_id : arguments.oReviewId
		};

		//if the file has not been created, create the file document

		if ( !uFiles._success || arrayFind( uFiles.files, arguments.filePath) == 0 ) {
			//set up the file insert statement
			uUpdate = {
				"$set" : {
					"files.#filePathReplace#" : {
						extension : listLast( arguments.filePath, "." ),
						comments : {},
						revision_head : fix( arguments.revision_head )
					}
				}
			};


			//add the file document to the review recod
			try {
				uMongoResult = mongoCollectionFindAndModify(
					datasource : sDataSource,
					collection : sCollection,
					query : uQuery,
					update : uUpdate,
					returnnew : true
				);
			} catch ( any e ){
				//oops something went wrong
				uRet._error = e;
				uRet._message = e.details;
				uRet._arguments = arguments;
			} finally {
				uRet._success = (!structIsEmpty(uMongoResult) && structKeyExists(uMongoResult.files,filePathReplace));
			}
		} else {
			uRet._success = true;
			uRet._message = "file already exists.";
		}

	}

	return uRet;
}



private struct function tapir_review_files_add_file_comment(required string _key, required string sReviewId, required string filePath, required string comment, required string line, required string length, required string code, required string source){
	/**
	* add_file add a comment to a file
	*
	* @param {string} sReviewId review id
	* @param {string} filePath path to file
	* @param {string} comment comment to save
	* @param {string->numeric} line the comment applies to, -1 applies to the file
	* @param {string->numeric} length the number of lines the comment applies to
	* @param {string} code the code to go with the comment (optional)
	* @param {string} source indicator for the source of the comment
	* @return {struct} _success indicates success of retrieval
	* 									_message any error message encountered
	*/

	//return variable setup
	var uReview = {};
	var uRet = {
		_success : false
	};

	try {
		arguments.oReviewId = mongoObjectId(arguments.sReviewId);
		uReview = runGatelet(gatelet="tapir.review.get_meta",sReviewId=arguments.sReviewId);
		arguments.reviewStatus = uReview.status;
	} catch (any e) {
		uRet._error = e;
	}

	//check all the variables
	if ( !structKeyExists(arguments,"oReviewId") ||
				len( arguments.filePath ) == 0 ||
				len( arguments.comment ) == 0 ||
				len( arguments.source ) == 0 ||
				len( arguments.line ) == 0 || !isNumeric( arguments.line ) ||
				len( arguments.length ) == 0 || !isNumeric( arguments.length ) ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else if (arguments.reviewStatus == "COMPLETE"){
		uRet._message = "This review has already been finalized";
	} else {
		//get the datasource
		var sDataSource = runGatelet(gatelet="tapir.getds");
		//see what files already have records
		var uFiles = runGatelet(gatelet="tapir.review.files.get_all_names", sReviewId=arguments.sReviewId);
		var sCollection = "review";
		var uUpdate = {};
		var uMongoResult = {};

		//trim the extension off the filePath
		var filePathReplace = replace(arguments.filePath,".","~","ALL");

		//set up the query
		var uQuery = {
			_id : arguments.oReviewId
		};

		//if the file has not been created, create the file document

		if ( !uFiles._success || arrayFind( uFiles.files, arguments.filePath) == 0 ) {
			uRet._success = false;
			uRet._error = "File does not exist";
		}

		if ( !structKeyExists( uRet, "_error" ) ) {
			//set up the comment insert statement
			uUpdate = {
				"$set": {
					"files.#filePathReplace#.comments.line#arguments.line#" : {
						comment : arguments.comment,
						line : fix( arguments.line ),
						length : fix( arguments.length ),
						source : arguments.source
					}
				}
			};

			//check and see if we need to add the code
			if ( len( arguments.code ) > 0 ){
				uUpdate[ "$set" ][ "files.#filePathReplace#.comments.line#arguments.line#" ].code = arguments.code;
			}

			//try to insert the comment
			try {
				uMongoResult = mongoCollectionFindAndModify(
					datasource : sDataSource,
					collection : sCollection,
					query : uQuery,
					update : uUpdate,
					upsert : true,
					returnnew : true
				);
			} catch (any e){
				//oops, something went wrong
				uRet._error = e;
				uRet._message = e.details;
				uRet._arguments = arguments;
			} finally {
				//set the success flag
				uRet._success = (	!structIsEmpty( uMongoResult ) &&
													structKeyExists( uMongoResult.files, filePathReplace ) &&
													structKeyExists( uMongoResult.files[ filePathReplace ], "comments" ) &&
													structKeyExists( uMongoResult.files[ filePathReplace ].comments, "line#arguments.line#" ) &&
													!structIsEmpty( uMongoResult.files[ filePathReplace ].comments[ "line#arguments.line#" ] ) );
			}
		}

	}

	return uRet;
}



private struct function tapir_review_files_get(required string _key, required string sReviewId, required string filePath){
	/**
		* get a review by its id
		*
		* @param {string} sReviewId review id
		* @param {string} filePath file path
		* @return {struct} _success indicates success of retrieval
		* 									_message any error message encountered
		* 									file the file that was reviewed
		*/

	//return variable setup
	var i = 0;
	var uRet = {
		_success : false
	};

	//check all the variables
	if ( len( arguments.sReviewId ) == 0 || len(arguments.filePath) == 0 ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else {
		//get the review
		var uReview = runGatelet(gatelet = "tapir.review.get", sReviewId = arguments.sReviewId );
		//trim the extension off the filePath
		var filePathReplace = replace(arguments.filePath,".","~","ALL");

		if ( structKeyExists( uReview, "_success" ) && uReview._success &&
					structKeyExists( uReview.review, "files" ) && isStruct( uReview.review.files ) &&
					structKeyExists( uReview.review.files, filePathReplace ) ){
			uRet.file = uReview.review.files[ filePathReplace ];

		}
	}

	uRet._success = structKeyExists( uRet, "file" );

	return uRet;
}



private struct function tapir_review_files_get_all_names(required string _key, required string sReviewId){
	/**
		* get a review by its id
		*
		* @param {string} sReviewId review id
		* @return {struct} _success indicates success of retrieval
		* 									_message any error message encountered
		* 									review the review struct
		*/

	//return variable setup
	var f = 0;

	var uRet = {
		_success : false
	};

	//check all the variables
	if ( len( arguments.sReviewId ) == 0 ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else {
		//get the review
		var uReview = runGatelet(gatelet = "tapir.review.get", sReviewId = arguments.sReviewId );

		if ( structKeyExists( uReview, "_success" ) && uReview._success &&
					structKeyExists(uReview.review,"files") && isStruct(uReview.review.files)){

			uRet.files = [];

			for (f in uReview.review.files){
				if (right(f,len(uReview.review.files[f].extension)+1) != "~" & uReview.review.files[f].extension){
					arrayAppend(uRet.files, f & "." & uReview.review.files[f].extension);
				} else {
					arrayAppend(uRet.files, replace(f,"~",".","ALL"));
				}
			}

		}
	}

	uRet._success = structKeyExists( uRet, "files" );

	return uRet;
}



private struct function tapir_review_files_remove_comment(required string _key, required string sReviewId, required string filePath, required string line){
	/**
		* remove a comment from a file
		*
		* @param {string} sReviewId review id
		* @param {string} filePath path to file
		* @param {string->numeric} line the comment applies to, -1 applies to the file
		* @return {struct} _success indicates success of retrieval
		* 									_message any error message encountered
		*/

	//return variable setup
	var uReview = {};
	var uRet = {
		_success : false
	};

	try {
		arguments.oReviewId = mongoObjectId(arguments.sReviewId);
		uReview = runGatelet(gatelet="tapir.review.get_meta",sReviewId=arguments.sReviewId);
		arguments.reviewStatus = uReview.status;
	} catch (any e) {
		uRet._error = e;
	}

	//check all the variables
	if ( !structKeyExists(arguments,"oReviewId") ||
				len( arguments.filePath ) == 0 ||
				len( arguments.line ) == 0 || !isNumeric( arguments.line ) ) {
		uRet._message = "Invalid Parameter collection";
		uRet._arguments = arguments;
	} else if (arguments.reviewStatus == "COMPLETE"){
		uRet._message = "This review has already been finalized";
	} else {
		//get the datasource
		var sDataSource = runGatelet(gatelet="tapir.getds");
		//see what files already have records
		var uFiles = runGatelet(gatelet="tapir.review.files.get_all_names", sReviewId=arguments.sReviewId);
		var sCollection = "review";
		var uUpdate = {};
		var uMongoResult = {};

		//trim the extension off the filePath
		var filePathReplace = replace(arguments.filePath,".","~","ALL");

		//set up the query
		var uQuery = {
			_id : arguments.oReviewId
		};

		if ( !structKeyExists( uRet, "_error" ) ) {
			//set up the comment insert statement
			uUpdate = {
				"$unset": {
					"files.#filePathReplace#.comments.line#arguments.line#" : 1
				}
			};

			//try to insert the comment
			try {
				uMongoResult = mongoCollectionFindAndModify(
					datasource : sDataSource,
					collection : sCollection,
					query : uQuery,
					update : uUpdate,
					upsert : true,
					returnnew : true
				);
			} catch (any e){
				//oops, something went wrong
				uRet._error = e;
				uRet._message = e.details;
				uRet._arguments = arguments;
			} finally {
				//set the success flag
				uRet._success = (	!structIsEmpty( uMongoResult ) &&
													structKeyExists( uMongoResult.files, filePathReplace ) &&
													structKeyExists( uMongoResult.files[ filePathReplace ], "comments" ) &&
													!structKeyExists( uMongoResult.files[ filePathReplace ].comments, "line#arguments.line#" ) );
			}
		}

	}

	return uRet;
}



</cfscript></cfcomponent>