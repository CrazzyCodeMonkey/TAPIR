<!--- $Id: diff.cfm 23404 2015-12-01 18:17:56Z llee $ --->
<cfif ( thistag.executionmode == "start" ) >

	<!--- When being created from a tag --->
	<cfparam name="attributes.diff" 			default = [] />
	<cfparam name="attributes.revisions" 	default = [] />
	<cfparam name="attributes.comments" 	default = {} />
	<cfparam name="attributes.revLogs" 		default = {} />
	<cfparam name="attributes.repo" 			default = "royall2" />
	<cfparam name="attributes.split" 			default = "true" />
	<cfparam name="attributes.file" 			default = "" />
	<cfparam name="attributes.rev" 				default = "" />
	<cfparam name="attributes.tabSize" 		default = "2" />

	<cfscript>
		fileLevelComment 	= "";
		fileLevelSource		= "";
		actualLineCount 	= 0;
		nonDeletedCount 	= 0;
		count 						= 1;
		z 								= -1;
		oUtils 						= createObject("tapir.utils");
		aRevs 						= arrayReverse(attributes.revisions);
		status 						= {	U: "Updated",
													D: "Removed",
													A: "Added",
													P: "Pristine" };


		try {
			for ( i=1; i<=arrayLen(attributes.diff); i++ ){
				if (attributes.diff[i].status != 'D'){
					nonDeletedCount=nonDeletedCount+1;
				}

				if ( structKeyExists(attributes.comments, 'file') && structKeyExists(attributes.comments.file, 'comments')){
					for ( key in attributes.comments.file.comments ){
						checkWord = 'line' & nonDeletedCount;

						if ( key == checkWord ){
							attributes.diff[i].comments = attributes.comments.file.comments[key];
						}
					}
				}
			}
			if ( structKeyExists(attributes.comments, 'file') && structKeyExists(attributes.comments.file, 'comments') && structKeyExists(attributes.comments.file.comments, "line-1")){

				fileLevelComment = attributes.comments.file.comments["line-1"].comment;
				fileLevelSource = attributes.comments.file.comments["line-1"].source;


			}

		} catch( any e ) {
			console( e );
		}
	</cfscript>
	<script type = "text/javascript">
		window.user = "<%=#Ucase(Left(request.tapir.getAuthor(), 2))#%>";
	</script>
	<div id="revControl" class="hidden">
		<cfloop array="#aRevs#" index="r">
			<%=<button class="btn btn-arrows btn-raised btn-arrow-right" data-checked="true" id="#r#" value="#r#">#r#</button>%>
		</cfloop>
	</div>
	<div class="panel panel-info <cfif fileLevelSource == "mScan">displaymScanComment</cfif> displayComment displayFileComment">
		<cfif fileLevelComment NEQ "">

			<div class="panel-heading">
				<h3 class="panel-title"></h3>
			</div>
			<div class="panel-body">
				<div class="list-group">
					<div class="list-group-item">
						<div class="row-action-primary">
							<i style="font-size:30px !important" class="glyphicon glyphicon-barcode"></i>
						</div>
						<div class="row-content">
							<h4 class="list-group-item-heading"><cfif fileLevelSource == "mScan">Automated file level comment<cfelse>File level comment</cfif></h4>
							<pre class="commentPre"><p class="list-group-item-text" id="fileComment"><%=#fileLevelComment#%></p></pre>
						</div>
					</div>
				</div>
			</div>
		</cfif>
	</div>
	<!--- <button class="btn btn-default btn-raised btn-material-grey" id="nextChangeButton">Next change &nbsp<i class="fa fa-arrow-right"></i></button>
	<button class="btn btn-default btn-raised btn-material-grey" id="previousChangeButtonFixed" style="display:none;"><i class="fa fa-arrow-left"></i>&nbsp Previous change</button>
	<button class="btn btn-default btn-raised btn-material-grey" id="nextChangeButtonFixed" style="display:none;">Next change &nbsp<i class="fa fa-arrow-right"></i></button> --->
	<ul class="sourceCode">
	<cfloop array="#attributes.diff#" index="line"><cfoutput>

		<li class="externalLine #status[line.status]#" id="lineExternal-#count#" data-line="#count#" data-actualline="#actualLineCount#">
			<cfif structKeyExists( line, "comments") && structKeyExists(line.revision,aRevs[arrayLen(aRevs)])>
				<cfif line.comments.source == "mScan">
					<cfset commentMscanFlag = ", true">
				<cfelse>
					<cfset commentMscanFlag = "">
				</cfif>
				<cfset commentMouseOverFunction = "util.highlightLines(" & count & ", (" & count + line.comments.length - 1 & "), true, " & line.comments.length - 1& commentMscanFlag & ")"  />
				<cfset commentMouseOutFunction = "util.highlightLines(" & count & ", (" & count + line.comments.length & "), false, " & line.comments.length & commentMscanFlag & ")" />
				<cfset rowEndActual = count + line.comments.length - 1 />
				<cfset lineLength = line.comments.length - 1 />
				<cfset lineEndSelect = actualLineCount + line.comments.length />
				<cfset commentText = replace(line.comments.comment,'"','\"','all') />
				<div class="panel panel-info <cfif line.comments.source == "mScan">displaymScanComment</cfif> displayComment" data-line="#count#" data-length="#line.comments.length-1#" data-actualline="#actualLineCount#"  onmouseover="#commentMouseOverFunction#" onmouseout="#commentMouseOutFunction#" data-rowstartactual="#count#" data-rowendactual="#rowEndActual#" data-linelength="#lineLength#" data-rowstartselect="#count#" data-lineendselect="#lineEndSelect#" data-comment='#commentText#'>
					<div class="panel-heading">
						<h3 class="panel-title"></h3>
					</div>
					<div class="panel-body">
						<div class="list-group">
							<div class="list-group-item">
								<div class="row-action-primary">
									<i style="font-size:30px !important"<cfif line.comments.source == "mScan"> class="glyphicon glyphicon-barcode"><cfelse>>#Ucase(Left(request.tapir.getAuthor(), 2))#</cfif></i>
								</div>
								<div class="row-content">
									<h4 class="list-group-item-heading">Line #line.revision[aRevs[arrayLen(aRevs)]].line#<cfif (line.comments.length-1 > 1) > - #(line.revision[aRevs[arrayLen(aRevs)]].line+line.comments.length-1)#</cfif>: <cfif (StructKeyExists( line.comments, 'code'))><span class="small">( <i class="fa fa-code"></i> Include Code )</span></cfif></h4>
									<input id="input-#count#" class="hidden" type="checkbox" id="includeCode" value="<cfif (StructKeyExists( line.comments, 'code'))>true" checked<cfelse>false" </cfif> >
									<pre class="commentPre"><p id="commentText" class="list-group-item-text"><%=#line.comments.comment#%></p></pre>
								</div>
							</div>
						</div>
					</div>
				</div>
			</cfif>

			<cfif structKeyExists( line.revision, aRevs[arrayLen(aRevs)] )>
				<cfset actualLineCount = line.revision[aRevs[arrayLen(aRevs)]].line>
				<cfif ( line.status == "A" )>
					<cfloop from="1" to="#arrayLen(aRevs)#" index="i">
						<cfif (structKeyExists(line.revision,aRevs[i]) && line.revision[aRevs[i]].status != "P")>
							<div class="line">#line.revision[aRevs[arrayLen(aRevs)]].line#
								<button class="#aRevs[i]# Added btn btn-fab btn-raised btn-material-green editorFlagIcons tooltip-right" data-tooltip="#attributes.revLogs[aRevs[i]].author# Added this line in Revision #aRevs[i]#">A</button>
							</div>
							#oUtils.getUtil( "render" ).renderForHTML( line.revision[aRevs[i]].source, count, actualLineCount, attributes.tabSize )#
						</cfif>
					</cfloop>
				<cfelseif ( line.status == "U" )>
					<cfloop from="#arrayLen(aRevs)#" to="1" index="i" step="-1">
						<cfif ( structKeyExists(line.revision,aRevs[i]) && (i+1)<=arrayLen(aRevs) && !structKeyExists(line.revision,aRevs[i+1]) || structKeyExists(line.revision,aRevs[i]) && i==arrayLen(aRevs) )>
							<div class="line updateRev" id="updateRevHead-#actualLineCount#" data-show="false">
								<span class="hand" onClick="util.showOlderRev( '#actualLineCount#' );">#line.revision[aRevs[arrayLen(aRevs)]].line#
									<i class="fa fa-caret-down" id="updateRevHeadArrow-#actualLineCount#"></i>
								</span>
								<button class="#aRevs[i]# Head btn btn-fab btn-raised btn-material-blue editorFlagIcons tooltip-right" data-tooltip="#attributes.revLogs[aRevs[i]].author# Updated this line in Revision #aRevs[i]#">U</button>
							</div>
							#oUtils.getUtil( "render" ).renderForHTML( line.revision[aRevs[i]].source, count, actualLineCount, attributes.tabSize )#
						<cfelseif (structKeyExists(line.revision,aRevs[i]) && (line.status=="U")) >
							<span class="olderUpdates updateRev-#actualLineCount# hidden">
								<div class="line">
									<i>#aRevs[i]#</i>
									<button class="#aRevs[i]# Updated btn btn-fab btn-raised btn-material-blue editorFlagIcons tooltip-right" data-tooltip="#attributes.revLogs[aRevs[i]].author# Updated this line in Revision #aRevs[i]#">U</button>
								</div>
								#oUtils.getUtil( "render" ).renderForHTML( line.revision[aRevs[i]].source, count, actualLineCount, attributes.tabSize )#
							</span>
						</cfif>
					</cfloop>
				</cfif>
			<cfelseif ( line.status == "D" )>
				<cfloop from="1" to="#arrayLen(aRevs)#" index="i">
					<cfif ( structKeyExists(line.revision,aRevs[i]) && (i+1)<=arrayLen(aRevs) && !structKeyExists(line.revision,aRevs[i+1]) || structKeyExists(line.revision,aRevs[i]) && i==arrayLen(aRevs) )>
						<div class="line">
							<i class="olderUpdates">#aRevs[i]#</i>
							<button class="#aRevs[i]# Removed btn btn-fab btn-raised btn-material-red editorFlagIcons tooltip-right" data-tooltip="#attributes.revLogs[aRevs[i]].author# Removed this line in Revision #aRevs[i]#">D</button>
						</div>
						#oUtils.getUtil( "render" ).renderForHTML( line.revision[aRevs[i]].source, count, actualLineCount, attributes.tabSize )#
					</cfif>
				</cfloop>
			</cfif>
			<cfif (line.status=="P")>
				<div class="line">#line.revision[aRevs[arrayLen(aRevs)]].line#</div>
				#oUtils.getUtil( "render" ).renderForHTML( line.source, count, actualLineCount, attributes.tabSize )#
			</cfif>
		</li>
		<cfset count++>
		</cfoutput></cfloop>
	</ul>
</cfif>