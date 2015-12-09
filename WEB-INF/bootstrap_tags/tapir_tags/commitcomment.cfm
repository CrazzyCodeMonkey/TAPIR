<cfif IsDefined( "thisTag" ) && structKeyExists( thistag, 'executionmode' ) && ( thistag.executionmode == "start" ) >

	<cfparam name="attributes.lineInfo" 					default="" />
	<cfparam name="attributes.comment" 						default="" />
	<cfparam name="attributes.delete" 						default="false" />

	<div class="panel panel-info commentContainer">
		<div class="panel-heading">
			<h3 class="panel-title">
			</h3>
		</div>
		<div style="padding-bottom:0" class="panel-body">
			<div class="list-group">
				<div class="list-group-item">
					<div class="row-action-primary">
						<i style="font-size:25px !important"class="fa fa-pencil"> </i>
					</div>
					<div class="row-content">
						<div class="row">
							<div class="col-md-7">
								<h4 class="list-group-item-heading">
									<cfoutput>#attributes.lineInfo#</cfoutput>
								</h4>
							</div>
							<div class="col-md-5">
								<cfif attributes.delete == "true" >
									<button id="removeSubmit" class="pull-right btn btn-fab btn-raised btn-material-red"><i class="fa fa-trash-o"></i><div class="ripple-wrapper"></div></button>
								</cfif>

								<button id="cancelSubmit" class="pull-right btn btn-fab btn-raised"><i class="mdi-content-clear"></i><div class="ripple-wrapper"></div></button>
								<button id="commentSubmit" class="pull-right btn btn-fab btn-raised btn-material-green"><i class="mdi-navigation-check"></i><div class="ripple-wrapper"></div></button>
								<label>
									<input type="checkbox" id="includeCode" checked=""> Include Code
								</label>
							</div>
						</div>
						<textarea id="commentTextArea" type="text" class="textInput form-control" rows="5" aria-label="..."><cfoutput>#attributes.comment#</cfoutput></textarea>
					</div>
				</div>
			</div>
		</div>
	</div>

</cfif>