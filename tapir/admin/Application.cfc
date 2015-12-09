<cfcomponent extends="app.app_tapir" output="false"><cfscript>

	/**
		* @class tapir.admin.application
		* @extends app.app_tapir
		*/

	this.name 											= "application";
	this.class_path									= "tapir.admin.application";
	this.version										= "0.0.1";


	/**
		* Fires once when the Request begins
		*
		* @method onRequestStart
		* @public
		* @param {string} _pageUri (required) the url of the requested page
		* @return {void} the request will be started
		*/
	function onRequestStart(_requestURI) {
		SUPER.onRequestStart(_requestURI);

		if( !RCanUserReadZone(argumentCollection = { user_id = session.user.user.user_id, zone_name = 'TapirAdminZone' }) ) {
			location( '/tapir/index.cfm' );
		}
	}
</cfscript></cfcomponent>