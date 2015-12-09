<cfcomponent output="false"><cfscript>
	this.class_path = "tapir.utils.commentsToMarkdown";

	/**
		* @class tapir.utils.svn
		*
		*/


	/**
		* @method getMarkdown
		* @public
		* @param {any} _reviewId (required) The review id to pull information about
		* @return {any}
		*/
	public function getMarkdown( required _reviewId, _includemScan = true ){
		var md													= new markup.builder("markdown");
		var review 											= application.dgw.invokeByRestOutStruct( "tapir.review.get", application.appkey, { sReviewId: request.tapir.getReviewId(arguments._reviewId) } );
		var ret 												= "";

		//only write the markdown export if the review is complete
		if( review._success && review.review.status == "COMPLETE" ){
			var rev 											= review.review;
			var author 										= rev.author;
			var revision 									= rev.revision_head;
			var reviewComments						= structKeyExists( rev, "comment" ) ? rev.comment : "";
			var timeStamp 								= rev.dt_create;

			//add the header: date, author, HEAD, and review comments
			md.add("header1",dateFormat(rev.dt_create, "YYYY.mm.dd") & " " & author & " " & revision);
			md.add("header2",reviewComments);

			//build the link to go back to the review
			var sTapirLink = md.noAdd("link",_reviewId,Application.domain & "/tapir/review.cfm?reviewId=" & _reviewId);

			//add the TAPIR-review link
			md.add("paragraph","TAPIR Review: "& sTapirLink);

			// Loop each file and append return variable
			for( file in rev.files ) {
				//change ~ back to . (hack due to mongo datastore)
				var path 										= replace(file,"~",".","ALL");
				var fileComments 						= [];
				var lineComments 						= [];
				var tBlock									= "";

				//add header or filename
				md.add("header3",path);

				//see how many comments we have
				if (structIsEmpty(rev.files[file].comments)){

					//no comments, the file is approved
					md.add("bulletList",["Approved"]);
				} else {

					//add the comments for the file

					//get the lines, and order them
					aLines = getLineOrder(rev.files[file].comments);
					//store the comments so they can be added in a list
					var aComments = [];

					for( line in aLines ) {
						// Removes target=_blank from links, and converts any links to markdown format.

						//remove black targets from link
						rev.files[file].comments["line" & line].comment = replace(rev.files[file].comments["line" & line].comment, ' target="_blank"', '');
						//add domain to links
						rev.files[file].comments["line" & line].comment = REReplaceNoCase(rev.files[file].comments["line" & line].comment, '<a[^>]* href="([^"]*)">(.*)<\/a>', "[\2](" & Application.domain & "/tapir/\1)", "all");

						//file level comments are stored as line -1, other line comments are stored on the needed line
						if (listLen(rev.files[file].comments["line" & line].comment, chr(10))>1){

							//if the comment was written over multiple lines, convert it to a list for better MarkDown rendering
							var aExtraLines = listToArray(rev.files[file].comments["line" & line].comment, chr(10) );

							//loop over the lines
							for (sLine in aExtraLines){
								//make sure we have content first
								if (len(trim(sLine))>0){
									//copy the line comment so we can do some processing on it
									var tmpComment = structCopy(rev.files[file].comments["line" & line]);
									tmpComment.comment = trim(sLine);

									//render and append the comment to our array for list add/rendering later
									arrayAppend(aComments, this.renderComment(md, tmpComment, line));
								}
							}
						} else {
							//render and append the file level comment to our array for list add/render later
							arrayAppend(aComments, this.renderComment(md, rev.files[file].comments["line" & line], line));
						}
					}

					//render the file comments (file leve, and line level) as a unordered list
					md.add("bulletList",aComments);
				}

			}// End for file

			//add a horizontil rule for seperation
			md.add("rule");
		}

		//return the rendered MarkDown
		return md.get();
	}



	/**
		* @method getLineOrder
		* @private
		* @param {struct} _uComments (required)
		* @return {array}
		*/
	private array function getLineOrder(required struct _uComments){
		//_uComments is a struct with all keys in the format of "lineX" where X is a number -1, or a number >0
		//get all the line numbers
		var aLines = listToArray(replace(structKeyList(_uComments),"line","","ALL"));

		//sort all the line numbers
		arraySort(aLines,"numeric");

		return aLines;
	}



	/**
		* @method renderComment
		* @private
		* @param {any} component _md (required)
		* @param {struct} _uComment (required)
		* @param {numeric} _nLine (required) -1 is a file level, >0 is a line level comment
		* @return {string}
		*/
	private string function renderComment(required component _md, required struct _uComment, required numeric _nLine){
		var sComment = "";

		//see if w have a file level comment or line level
		if (_nLine > 0){
			//add the content for marking a line comment
			sComment = "Line: " & _nLine;

			//see if we are working with a line comment over a span
			if (_uComment.length > 1){
				sComment &= "-" & (_nLine + _uComment.length);
			}

			sComment &= " ";
		}

		//do we have a manual or automated comment
		if (_uComment.source == "manual"){
			//bold manual comments so they stand out
			sComment &= _md.noAdd("bold",_uComment.comment);
		} else {
			//add the source at the end of th line so we know which automated source made the comment
			sComment &= _uComment.comment & " (" & _uComment.source & ")";
		}

		//do we have code to include
		if (structKeyExists(_uComment,"code")){
			//ad a new line for better rendering
			sComment &= _md.noAdd("newline");
			//add the code block
			sComment &= _md.noAdd("code",_uComment.code);
		}

		return sComment;
	}
</cfscript></cfcomponent>