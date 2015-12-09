<cfsilent>
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
<BOOTSTRAP:page title="Using TAPIR" localCSS="false" localAppJS="true" customJS="#customJS#">
	<TAPIR:navBar>
	<style type="text/css">
		strong {
			color: blue;
		}

		img {
			margin: 20px;
			-webkit-box-shadow: 0px 0px 4px 0px #000; /* Android 2.3+, iOS 4.0.2-4.2, Safari 3-4 */
			box-shadow: 0px 0px 4px 0px #000;
		}

		.content {
			background-color: #ffffff;
			-webkit-box-shadow: 2px 2px 4px 0px #000; /* Android 2.3+, iOS 4.0.2-4.2, Safari 3-4 */
			box-shadow: 2px 2px 4px 0px #000;
			padding: 5px;
		}
	</style>

	<div class="col-md-7 panes">
		<div class="content">
			<h4>Using TAPIR</h4>
			<p>
				TAPIR main panel<br>
				<img src="/tapir/a/img/tapirIndex.png">
			</p>
			<hr>
			<p>
				TAPIR is designed to let you perform code reviews easier, quicker, and with more accuracy.
			</p>
			<p>
				TAPIR is language agnostic, though the automated tests are tailored for the CFML world, it's easy to add new tests for other files and languages.
			</p>
			<hr>
			<p>
				<u>Using TAPIR</u>
			</p>
			<p>
				To start using TAPIR, click the <strong>TAPIR dropdown</strong> in the menu and click <strong>"New Ticket based Review"</strong>, then simply fill in the data.<br>
				<img src="/tapir/a/img/tapirMenuTapir.png">
			</p>
			<p>
				Select which <strong>repository</strong> to use, and the <strong>ticket id</strong> (As found in Tick'd), and if the checkins for the ticket are not very fresh, you may need to adjust the <strong>Revision Search Start</strong> value by clicking on the <strong>Older Content</strong> button.<br>
				<img src="/tapir/a/img/tapirNewReview.png">
			</p>
			<p>
				By default, TAPIR only looks up to 500 revisions back, if your revisions are older, simply adjust the value here to one lower than your earliest revision.
			</p>
			<p>
				When you hit Submit, TAPIR will look up the ticket and checkin information from SVN.
			</p>
			<p>
				If someone else is already reviewing the ticket, you will get the option to <strong>send them an email reminder</strong>.<br>
				<img src="/tapir/a/img/tapirSendReminder.png">
			</p>
			<p>
				If you have already started a review for the ticket, you get the option of loading that review and continuing.<br>
				<img src="/tapir/a/img/tapirLoadReview.png">
			</p>
			<p>
				Otherwise, you get the option of <strong>starting a new review</strong>.<br>
				<img src="/tapir/a/img/tapirNewReviewModal.png">
			</p>
			<p>
				On the left-hand side is a file tree containing only the files touched in the checkins related to the ticket.<br>
				<img src="/tapir/a/img/tapirFileTree.png">
			</p>
			<p>
				On the right-hand side is a list of the checkins made, if you click one it will show you what files were checked in, along with the checkin message.<br>
				<img src="/tapir/a/img/tapirCheckins.png">
			</p>
			<p>
				The files are clickable, and will highlight the file in the tree-view.
			</p>
			<p>
				To see the file, <strong>click the filename in the tree-view</strong>, the first time a file is opened this also triggers the <strong>automated</strong> mScan tests to run, the results are shown in the file-view.<br>
				<img src="/tapir/a/img/tapirFileView.png">
			</p>
			<p>
				The automated tests run against HEAD, so line numbers may not be exact in the copy you're viewing.
			</p>
			<p>
				In the file-view, you can make and change comments by <strong>marking one or more lines, hide and show mScan comments and turn on/off the indent-symbols</strong>.<br>
				<img src="/tapir/a/img/tapirMarkedLines.png">
			</p>
			<p>
				When you're done with your code review, you need to <strong>finalize it by clicking on the Finalize option under the Tapir dropdown</strong>.<br>
				<img src="/tapir/a/img/tapirFinalize.png">
			</p>
			<p>
				After that you can <strong>Export the comments</strong> which gives you a ready-to-use block of Markdown text for <strong>pasting into Tick'd</strong>.<br>
				<img src="/tapir/a/img/tapirExport.png">
			</p>
			<p>
				Example:<br>
				<video controls="controls">
					<source src="/tapir/a/video/TapirExampleTest.mp4" type="video/mp4">
				</video>
			</p>

		</div>
	</div>


</BOOTSTRAP:page>