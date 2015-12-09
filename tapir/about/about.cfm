<cfsilent>
	<cfparam name="URL.reviewId" default="">
	<cfimport taglib="/WEB-INF/bootstrap_tags/" prefix="BOOTSTRAP" />
	<cfimport taglib="/WEB-INF/bootstrap_tags/tapir_tags/" prefix="TAPIR" />
	<cfset customJS													= [
		"/a/js/vendor/material.min.js",
		"/a/js/components/bootstrap.js",
		"../a/js/vendor/jstree/jstree.min.js",
		"../a/js/components/statemanager.js",
		"../a/js/eventmanager.js",
		"../a/js/util.js",
		"../a/js/vendor/highlight.js/8.8.0/highlight.min.js"
	]>
</cfsilent>
<BOOTSTRAP:page title="T A P I R - Version 1" localCSS="#true#" localAppJS="true" customJS="#customJS#">
	<TAPIR:navBar tapir="#URL.reviewId#">

	<div class="container">

		<div class="starter-template">
			<h1>T<small>ool</small> A<small>ssisted</small> P<small>eer</small> I<small>ntelligence</small> R<small>eview</small></h1>
			<p class="small">Version: <%=#Application.version#%></p>
			<p>TAPIR was built facilitate easier and faster code reviews</p>
			<p>These are the currently supported Royall SVN Repositories</p>
			<ul>
				<cfloop collection="#application.repos#" item="repo">
					<cfoutput><li>
						#application.repos[repo].name#
						<blockquote>#application.repos[repo].description#</blockquote>
					</li></cfoutput>
				</cfloop>
			</ul>
		</div>

</div>
</BOOTSTRAP:page>
