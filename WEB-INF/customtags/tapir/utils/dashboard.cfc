<cfcomponent output="false"><cfscript>


this.warningTime = 48*60;



public query function distillReviews(required array _reviews){
	var nowZ = new tapir.utils.dateTimeZone().displayFormat(now(),true);
	var sRev = "";
	var qReviews = queryNew(structKeyList(getNewRowStruct()));

	for (sRev in _reviews){
		var uData = getNewRowStruct();

		var uCurrReview = Application.dgw.invokeByRestOutStruct( "tapir.review.get_meta", Application.appkey, {sReviewId: sRev} );

		uData.status = uCurrReview.status;
		uData.author = listFirst(uCurrReview.author,"@");
		uData.reviewId = sRev;
		uData.ticket = uCurrReview.ticket;
		uData.revisions = arrayLen(uCurrReview.revisions);
		uData.fileCount = uCurrReview.filesToReview.newFiles + uCurrReview.filesToReview.updatedFiles;
		uData.filesReviewed = uCurrReview.filesReviewed;

		if (structKeyExists(uCurrReview,"previous_review")){
			uData.parentReview = uCurrReview.previous_review;
		}

		if (uCurrReview.status == "NEW"){
			uData.processTime = dateDiff("n", uCurrReview.dt_create, nowZ);
			if (uData.processTime > this.warningTime){
				uData.status = "WARNING";
			}
		} else {
			uData.timeToComplete = dateDiff("n", uCurrReview.dt_create, uCurrReview.dt_complete);
			uData.starColor = this.getStarColor(uData.timeToComplete);
		}
		queryAddRow(query=qReviews,data=uData);
	}

	processChildReferences(qReviews);

	return qReviews;

}



public struct function gatherStats(required query _qReviews){
	var uRow = {};
	var uStats = {
		nTotalCount: _qReviews.recordCount,
		nAvgClosedTime:0,
		nLargestRevisions:0,
		nLargestFilesReviewed:0,
		nLargestFilesToReview:0,
		cnt:{},
		percent:{}
	};

	var qStatus = QueryOfQueryRun("SELECt status, count(1) as cnt FROM _qReviews GROUP BY status");

	for (uRow in qStatus){
		uStats.cnt["n" & uRow.status] = uRow.cnt;
		uStats.percent["n" & uRow.status] = uStats.cnt["n" & uRow.status] / uStats.nTotalCount;
	}

	var qClosedTime = QueryOfQueryRun("SELECT avg(timeToComplete) as avgTime FROM _qReviews WHERE status='COMPLETE'");
	if (qClosedTime.recordCount == 1){
		uStats.nAvgClosedTime = round(qClosedTime.avgTime[1]);
	}

	var qLargestRevs = queryOfQueryRun("SELECT max(revisions) as maxRevs FROM _qReviews");
	if (qLargestRevs.recordCount == 1){
		uStats.nLargestRevisions = qLargestRevs.maxRevs[1];
	}

	var qMostFiles = queryOfQueryRun("SELECT max(fileCount) as maxFiles FROM _qReviews");
	if (qMostFiles.recordCount == 1){
		uStats.nLargestFilesToReview = qMostFiles.maxFiles[1];
	}

	var qMostReviewed = queryOfQueryRun("SELECT max(filesReviewed) as maxFiles FROM _qReviews");
	if (qMostReviewed.recordCount == 1){
		uStats.nLargestFilesReviewed = qMostReviewed.maxFiles[1];
	}

	return uStats;
}



public struct function gatherAdminStats(required query _qReviews){

	var uStats = gatherStats(_qReviews);
	var uRow={};

	uStats.uAuthors = {};
	uStats.top = {};

	var qAuthorStatus = QueryOfQueryRun("SELECT author, status, count(1) as cnt FROM _qReviews GROUP BY author, status");

	for (uRow in qAuthorStatus){
		if (!structKeyExists(uStats.uAuthors,uRow.author)){
			uStats.uAuthors[uRow.author] = {nComplete:0,nNew:0,nWarning:0};
		}
		uStats.uAuthors[uRow.author]["n" & uRow.status] = uRow.cnt;
	}

	var qAuthorStatusTop = QueryOfQueryRun("SELECT status, max(cnt) as top FROM qAuthorStatus GROUP BY status");

	for (uRow in qAuthorStatusTop){
		uStats.top["n" & uRow.status] = { count:uRow.top, authors:[]};
		qTopAuthors = queryOfQueryRun("SELECT author FROM qAuthorStatus WHERE status=? AND cnt=?",[{value:uRow.status},{value:uRow.top}]);
		for (uAuthor in qTopAuthors){
			arrayAppend(uStats.top["n" & uRow.status].authors, uAuthor.author);
		}

	}

	return uStats;

}



private void function processChildReferences(required query _qReviews){
	var qChildren = queryOfQueryRun("SELECT reviewId, parentReview FROM _qReviews WHERE parentReview<>''");
	for (var uChild in qChildren){
		setChildReference(_qReviews,uChild.reviewId,uChild.parentReview);
	}
}



private void function setChildReference(required query _qReviews, required string _child, required string _parent){
	for (var i=1;i<=_qReviews.recordCount;i++){
		if (_qReviews.reviewId[i]==_parent){
			querySetCell(_qReviews,"childReview",_child,i);
		}
	}
}



private struct function getNewRowStruct(){
	return {
		reviewId:"",
		ticket:0,
		status:"",
		revisions:0,
		fileCount:0,
		filesReviewed:0,
		processTime:-1,
		timeToComplete:-1,
		starColor:0,
		parentReview:"",
		childReview:""};
}



private numeric function getStarColor(required numeric _minutes){
	var sColor = 0;
	var nMinutesInDay = 24*60;

	if (_minutes < 5. * nMinutesInDay){
		sColor = 1;
	} else if (_minutes < 1 * nMinutesInDay){
		sColor = 2;
	} else if (_minutes < 1.5 * nMinutesInDay){
		sColor = 3;
	} else if (_minutes < 2 * nMinutesInDay){
		sColor = 4;
	} else if (_minutes < 3 * nMinutesInDay){
		sColor = 5;
	} else if (_minutes < 4 * nMinutesInDay){
		sColor = 6;
	} else {
		sColor = 7;
	}

	return sColor;
}




</cfscript></cfcomponent>