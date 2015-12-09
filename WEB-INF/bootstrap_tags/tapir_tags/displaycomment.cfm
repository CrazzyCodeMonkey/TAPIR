<cfif IsDefined( "thisTag" ) && structKeyExists( thistag, 'executionmode' ) && ( thistag.executionmode == "start" ) >

	<cfparam name="attributes.usertag" 						default="" />
	<cfparam name="attributes.lineinfo" 					default="" />
	<cfparam name="attributes.comment" 						default="" />

	<div class="panel panel-info displayComment">
		<div class="panel-heading" >
			<h3 class="panel-title"></h3>
		</div>
		<div class="panel-body">
			<div class="list-group">
				<div class="list-group-item">
					<div class="row-action-primary">
						<i style="font-size:30px !important"><%= #attributes.usertag# %></i>
					</div>
					<div class="row-content">
						<h4 class="list-group-item-heading"><%= #attributes.lineinfo# %></h4>
						<pre class="commentPre">
							<p id="commentText" class="list-group-item-text"><%= #attributes.comment# %></p>
						</pre>
					</div>
				</div>
			</div>
		</div>
	</div>

</cfif>