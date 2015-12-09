<cfsilent>
	<cfimport prefix="BOOTSTRAP" taglib="/WEB-INF/bootstrap_tags/" />
	<cfimport prefix="TAPIR" taglib="/WEB-INF/bootstrap_tags/tapir_tags/" />
	<cfparam name = "URL.reviewId" 		default="">

	<cfscript>
	aLogs															= [];
	oUtil															= new tapir.utils();
	jsTree														= [];

	if ( !request.tapir.isLoaded() ){
		location( "/tapir/?clear" );
	} else {
		aRevisions											= request.tapir.getRevisions();

		URL.reviewId										= request.tapir.getReviewID();
		URL.repo												= request.tapir.getRepo();
		if ( request.tapir.getTicket() != 0 ){
			URL.ticket										= "" & request.tapir.getTicket();
		} else {
			URL.revisions									= arrayToList(aRevisions);
		}
		URL.repoStart										= "" & request.tapir.getRevisionStart();

		aLogs														= oUtil.runUtilFn( "svn", "getRevisionLogs", { _repo : URL.repo, _aRevisions : aRevisions } );

		// Prep path data for JSTree consumption
		treeData												= oUtil.runUtilFn( "svn", "getLogFiles", { _repo : URL.repo, _aLogs : aLogs } );
		// Traces' black magic voodoo stuff below for preparing the data tree
		tree 														= oUtil.runUtilFn( "path", "filePathsToStruct", { _uPaths : treeData } );
		jsTree 													= oUtil.runUtilFn( "path", "getJsTreeFormat", { _data : tree } );
	}

	customStyles											= [
		"a/js/vendor/jstree/themes/default/style.min.css",
		"a/css/components/arrowbutton.css",
		"a/css/components/diff.css",
		"a/css/override.css",
		"a/js/vendor/paper-collapse/paper-collapse.css",
		"a/js/vendor/highlight.js/8.8.0/styles/default.min.css",
		"a/css/components/aniload.css",
		"a/css/components/slider.css",
		"a/css/utility.css"
	];

	customJS													= [
		"/a/js/vendor/ripples.min.js",
		"/a/js/vendor/material.min.js",
		"/a/js/components/bootstrap.js",
		"a/js/vendor/jstree/jstree.min.js",
		"a/js/vendor/paper-collapse/paper-collapse.js",
		"a/js/components/keybinder.js",
		"a/js/components/diffcomments.js",
		"a/js/components/diff.js",
		"a/js/eventmanager.js",
		"a/js/util.js",
		"a/js/vendor/highlight.js/8.8.0/highlight.min.js"
	];

	</cfscript>
</cfsilent>

<BOOTSTRAP:page title="T A P I R - Version 1" localCSS="#true#" customCSS="#customStyles#" customBodyId="reviewBody" localAppJS="true" customJS="#customJS#">

	<script type="text/javascript">
		window.jsonData									= <%=#SerializeJson( aLogs )#%>;
		window.urlParams								= <%=#serializeJSON( URL )#%>;
		window.jsTreeData								= <%=#serializeJSON( jsTree )#%>;
		window.reviewId 								= "<%=#URL.reviewId#%>";
		<!--- need to specifically render true or false because CFML will render to YES or NO instead of ture or false --->
		window.access										= <%=#(request.tapir.getAuthor() == SESSION.user.getEmail())?true:false#%>;
	</script>

	<TAPIR:navBar tapir="#request.tapir#">
	<div class="row" id="bodyContainer">

		<div class="col-md-3 panes mainPane mainPane-right" id="resizeableOppositeContainer">
			<div id="jstreeContainer" ></div>
		</div>

		<div class="col-md-9 panes mainPane mainPane-left" id="resizeableCommitSelectContainer"   >
			<div class="shadow-z-1" id="commitResize" style="background:white">
			</div>
			<div id="commitSelectContainer">
				<div>
				<cfloop array="#arrayReverse(aLogs)#" index="uLog">
					<TAPIR:commit revisionBy="#uLog.author#" revisionNumber="#uLog.revision#" fileList="#uLog.changed#" commitMessage="#uLog.logMessage#" commitDate="#uLog.date#" >
				</cfloop>
				</div>
			</div>
		</div>

	</div>

	<hr>

	<TAPIR:slider labelId="filename" contentId="diffContainer" slideDirection="right">

</BOOTSTRAP:page>

