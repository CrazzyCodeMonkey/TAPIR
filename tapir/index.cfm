<cfsilent>
	<cfimport taglib="/WEB-INF/bootstrap_tags/" prefix="BOOTSTRAP" />
	<cfimport taglib="/WEB-INF/bootstrap_tags/tapir_tags/" prefix="TAPIR" />

	<cfset customJS = [
		"/a/js/components/bootstrap.js",
		"a/js/components/statemanager.js",
		"a/js/vendor/jstree/jstree.min.js",
		"a/js/util.js",
		"a/js/eventmanager.js"]>
	<cfscript>
		nowZ = new tapir.utils.dateTimeZone().displayFormat(now(),true);
		sQuery 	= serializeJSON( {"author": session.user.getEmail()} );
		allrevs 	= Application.dgw.invokeByRestOutStruct( "tapir.review.find", Application.appkey, {query: sQuery} );

		oUtil = createObject("tapir.utils").getUtil("dashboard");
		qReviews = oUtil.distillReviews(allRevs.reviews);

		qReviewsOpen = queryOfQueryRun("SELECt * FROM qReviews WHERE status IN('NEW','WARNING')");
		qReviewsClosed = queryOfQueryRun("SELECt * FROM qReviews WHERE status = 'COMPLETE'");
		uStats = oUtil.gatherStats(qReviews);

		customStyles											= [
			"a/js/vendor/jstree/themes/default/style.min.css",
			"a/css/components/arrowbutton.css",
			"a/css/components/diff.css",
			"a/css/override.css",
			"a/js/vendor/paper-collapse/paper-collapse.css",
			"a/css/components/aniload.css",
			"a/css/utility.css"
		];
	</cfscript>

</cfsilent>
<BOOTSTRAP:page title="User dashboard" localCSS="true" customCSS="#customStyles#" localAppJS="true" customJS="#customJS#">
	<style type="text/css">
		tr {
			background-color: white;
			border: 1px solid #999;
		}
		.glyphicon-star {
			color: gold;
		}
		.large {
			font-size: 2em;
		}
		.progress {
			height:20px;
			border-radius: 4px;
		}
	</style>
	<TAPIR:navBar>

	<div class="row text-center" id="dashboard">

		<div class="col-xs-12 col-sm-12 col-md-9 col-lg-9" id="myReviewsContainer">
			<h2 class="header">My Reviews</h2>

			<div class="row">
				<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<TAPIR:dashboardReviews reviews="#qReviewsOpen#" which="NEW" title="Currently Open Reviews" />
				</div>
			</div>

			<div class="row">
				<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<TAPIR:dashboardReviews reviews="#qReviewsClosed#" which="COMPLETED" title="Finalized Reviews"/>
				</div>
			</div>

		</div>

		<div class="col-xs-12 col-sm-12 col-md-3 col-lg-3" id="stats">
			<h2 class="header">My Stats</h2>
			<TAPIR:dashboardStats attributeCollection="#uStats#" />
		<div>

	</div>



</BOOTSTRAP:page>
