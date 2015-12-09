<!--- $Id: commit.cfm 23326 2015-11-24 15:43:01Z mfernstrom $ --->
<cfif ( thistag.executionmode == "start" ) >
	<!--- When being created from a tag --->
	<cfparam name="attributes.revisionBy" 					default="" />
	<cfparam name="attributes.revisionNumber" 			default="" />
	<cfparam name="attributes.commitMessage" 				default="" />
	<cfparam name="attributes.commitDate" 					default="" />
	<cfparam name="attributes.fileList" 						default="#[]#" />

	<div style="margin-bottom:2px" class="shadow-z-1 collapse-card cardContainer">
		<div class="collapse-card__heading">
			<div class="collapse-card__title row">

				<div class="col-md-1">
					<div class="row">
					<i class="fa fa-user fa-4x fa-fw"></i>
					</div>
				</div>

				<div class="col-md-1">

					<div class="row">
						Revision By
					</div>
					<div class="row labelText">
					<strong class="cardTag">
						<%=#attributes.revisionBy#%>
					</strong>
					</div>
				</div>

				<div class="col-md-1">
					<div class="row">
						Revision Number
					</div>
					<div class="row labelText">
					<strong class="cardTag">
						<%=#attributes.revisionNumber#%>
					</strong>
					</div>
				</div>

				<div class="col-md-1">
					<div class="row">
						Files
					</div>
					<div class="row">
					<strong class="cardTag">
						<%=#arrayLen(attributes.fileList)#%>
					</strong>
					</div>
				</div>

				<div class="col-md-6">
					<div class="row">
						Commit Message
					</div>
					<div class="row labelText">
					<strong class="cardTag">
						<%=#HtmlEditformat(listRest(attributes.commitMessage,chr(10)))#%>
					</strong>
					</div>
				</div>

				<div class="col-md-1">
					<div class="row">
						Revision Date
					</div>
					<div class="row">
					<strong class="cardTag">
						<%=#attributes.commitDate#%>
					</strong>
					</div>
				</div>

			</div>
		</div>
		<div class="collapse-card__body">
			<div class="row">
				<div class="col-md-12">
					<strong class="innerCardTag">
						Commit Message
					</strong>
				</div>
			</div>
			<div class="row col-md-12">
				<pre class="commitPre"><%=#HtmlEditformat(attributes.commitMessage)#%></pre>
			</div>
				<hr/>
			<cfloop array="#attributes.fileList#" item="fileItem" index="fileIndex">
				<div class="row" >
					<div class="col-md-12 ">
						<button class="btn btn-raised commitFileButton" onclick="util.openTreePath('<%=#reReplace(fileItem.path, "[^a-zA-Z0-9]", "", "ALL")#%>');">
						<i class="glyphicon glyphicon-file"></i>
						<%=#fileItem.path#%>
						</button>
					</div>
				</div>
			</cfloop>
		</div>
	</div>

</cfif>