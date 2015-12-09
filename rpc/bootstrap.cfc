<cfcomponent output="false">
	<cfset this.class_path = "rpc.bootstrap">



	<!---
		/**
			* @class rpc.bootstrap
			*/
	--->



	<!---
	/**
		* render a notification bar
		*
		* @remote
		* @method notification
		* @param {string} _labelText (required)
		* @param {string} {string} [_supportText = ""]
		* @param {string} {string} [_actionText = ""]
		* @returnformat {plain}
		* @return {String}
		*/
	--->
<cffunction name="notification" access="remote" returntype="String" returnformat="plain" hint="render a notification bar">
		<cfargument name="_labelText" required="true" type="string">
		<cfargument name="_supportText" required="false" type="string" default="">
		<cfargument name="_actionText" required="false" type="string" default="">

		<cfset var sMarkup = "">

		<cfsavecontent variable="sMarkup" trim="true">
			<div class="panel panel-info hq-notification new-notification hq-notification_awaiting-translation-into-view">
				<div class="lightning"></div>
				<div class="notification-container">
					<div class="hq-notification-message">
						<h2><%=#_labelText#%></h2>
						<cfif (len(_supportText)>0)><small><%=#_supportText#%></small></cfif>
					</div>
					<div class="hq-notification-button-group">
						<button class="btn btn-fab notification-dismiss btn-raised dismiss-notification shadow-z-1 "><i class="fa fa-close"></i></button>
						<cfif (len(_actionText)>0)><button class="notification-action"><%=#_actionText#%></button></cfif>
					</div>
				</div>
			</div>
		</cfsavecontent>

		<cfreturn sMarkup>
	</cffunction>



</cfcomponent>