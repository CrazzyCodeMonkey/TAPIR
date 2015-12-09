<cfsilent><cfscript>
		auQuestions = [
			{	sQuestion:"What is a that animal, Tapir",
				sAnswer:"A tapir is a large, herbivorous mammal, similar in shape to a pig, with a short, prehensile snout. <a href='https://en.wikipedia.org/wiki/Tapir' target='_blank'>Wikipedia</a>"},
			{	sQuestion:"What is TAPIR",
				sAnswer:"Tool Assisted Peer Intelligence Review.  TAPIR is a tool designed to help make code reviews easier, and remove the tediousness from the process."},
			{ sQuestion: "Who made TAPIR?",
				sAnswer: "TAPIR was made by Trace Sinclair, Marcus Fernström, and Lucas Lee."},
			{ sQuestion: "Who is it for?",
				sAnswer: "TAPIR is for anyone needing to do code reviews."},
			{ sQuestion: "Who is it not for?",
				sAnswer: "Penguins. And small marsupials."}
		];
	</cfscript>
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

<BOOTSTRAP:page title="T A P I R - FAQ" localCSS="false" localAppJS="true" customJS="#customJS#">
	<TAPIR:navBar>
	<div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">
		<cfloop array="#auQuestions#" index="uQuestion">
			<div class="panel panel-default">
				<div class="panel-heading" role="tab" id="headingOne">
					<h4 class="panel-title">
						<a role="button" data-toggle="collapse" data-parent="#accordion" href="#<cfoutput>#lCase( rereplace(uQuestion.sQuestion,'[^a-zA-Z]', '', 'ALL') )#</cfoutput>" aria-expanded="true" aria-controls="collapseOne">
							<%=#uQuestion.sQuestion#%>
						</a>
					</h4>
				</div>
				<div id="<cfoutput>#lCase( rereplace(uQuestion.sQuestion,'[^a-zA-Z]', '', 'ALL') )#</cfoutput>" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne">
					<div class="panel-body">
						<%=#uQuestion.sAnswer#%>
					</div>
				</div>
			</div>
		</cfloop>
	</div>
</BOOTSTRAP:page>