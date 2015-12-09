<cfsilent>
	<!--- $Id: modal.cfm 23273 2015-11-20 19:03:51Z tsinclair $ --->
	<cfparam name="attributes.title" default="Missing Title">
	<cfparam name="attributes.message" default="<p>Missing Message</p>">
	<cfparam name="attributes.hide" default="true">
	<cfparam name="attributes.modalId" default="">
</cfsilent>
<cfif ( thistag.executionmode == "start" ) >
	<div class="modal fade <cfif (!attributes.hide)>in</cfif>" <cfif (!attributes.hide)>style="display:block;"</cfif> <cfif (attributes.modalID != "")>id="<%=#attributes.modalId#%>"</cfif>>
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
					<h4 class="modal-title"><%=#attributes.title#%></h4>
				</div>
				<div class="modal-body">
					<%=#attributes.message#%>
				</div>
				<div class="modal-footer">
<cfelseif (thistag.executionmode == "end" )>
				</div>
			</div>
		</div>
	</div>
</cfif>