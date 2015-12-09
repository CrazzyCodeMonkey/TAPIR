
<cfsilent>
	<cfimport taglib="/WEB-INF/bootstrap_tags/" prefix="BOOTSTRAP" />
	<cfimport taglib="/WEB-INF/bootstrap_tags/tapir_tags/" prefix="TAPIR" />

	<cfset customJS = [
		"/a/js/components/bootstrap.js",
		"/a/js/vendor/material.min.js",
		"/tapir/a/js/components/statemanager.js",
		"/tapir/a/js/vendor/jstree/jstree.min.js",
		"/tapir/a/js/eventmanager.js",
		"/tapir/a/js/util.js",
		"/tapir/a/js/app.js"]>
	<cfscript>
		nowZ = new tapir.utils.dateTimeZone().displayFormat(now(),true);

		earliestDate = CreateDatetime(dateFormat(nowZ, "yyyy"),dateFormat(nowZ, "mm"),dateFormat(nowZ, "dd"),00,00,00);
		earliestDate = dateAdd("d", -30, earliestDate);
		earliestDate = ToString(earliestDate);

		sQuery 	= serializeJSON({dt_create: { '$gte': earliestDate}});
		allRevs 	= Application.dgw.invokeByRestOutStruct( "tapir.review.find", Application.appkey, {query: sQuery} );
		oUtil = createObject("tapir.utils").getUtil("dashboard");

		qReviews = oUtil.distillReviews(allRevs.reviews);

		qReviewsOpen = queryOfQueryRun("SELECt * FROM qReviews WHERE status IN('NEW','WARNING')");
		qReviewsClosed = queryOfQueryRun("SELECt * FROM qReviews WHERE status = 'COMPLETE'");
		uStats = oUtil.gatherAdminStats(qReviews);

	</cfscript>

</cfsilent>
<BOOTSTRAP:page title="T A P I R Admin" localCSS="true" localAppJS="false" customJS="#customJS#">
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

		<div class="col-xs-12 col-sm-12 col-md-9 col-lg-9">
			<h2 class="header">Review Admin</h2>

			<div class="row">
				<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<TAPIR:adminReviews reviews="#qReviewsOpen#" which="NEW" title="Currently Open Reviews" />
				</div>
			</div>

			<div class="row">
				<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<TAPIR:adminReviews reviews="#qReviewsClosed#" which="COMPLETED" title="Finalized Reviews" />
				</div>
			</div>

		</div>

		<div class="col-xs-12 col-sm-12 col-md-3 col-lg-3" id="stats">
			<h2 class="header">My Stats</h2>
			<TAPIR:adminStats attributeCollection="#uStats#" />
		<div>

	</div>



</BOOTSTRAP:page>
