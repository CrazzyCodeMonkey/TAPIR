<cfcomponent output="false"><cfscript>

	/**
		* @class app.app_tapir
		*/

	this.name 											= "Tapir";
	this.class_path									= "app.app_tapir";
	this.version										= "1.0.0";

	this.applicationtimeout 				= createTimeSpan( 0, 1, 0, 0 );
	this.sessionManagement 					= true;
	this.sessionTimeout 						= createTimeSpan( 0, 1, 0, 0 );


	/**
		* Fires once when the Request begins
		*
		* @method onRequestStart
		* @public
		* @param {string} _pageUri (required) the url of the requested page
		* @return {void} the request will be started
		*/
	public void function onRequestStart(required string _pageUri) hint="Fires once when the Request begins"{
		request.tapir = new tapir.review();

		if (structKeyExists(URL,"reviewId")){
			try {
				request.tapir.init(URL.reviewId);
			} catch (any e){
				//nothing to do
			}
		}


	}




	/**
		* start or restart an application
		*
		* @method appInit
		* @private
		* @return {void} the application be setup
		*/
	public void function appInit(){
		Application.version = this.version;
		Application.domain = "127.0.0.1:80";

		var uSVNCredential							= {};
		var uTapirRole									= {};
		var uRepos											= {};
		var uCreds											= {};
		var uRepo												= {};
		var i														= 1;
		var sKey												= "";
		var sName												= "";
		var sRepo												= "";

		// Set up appkey, and dgw access at application level instead of SERVER
		//	 BootStrap will will only use gatelets as a stopgap
		//	   RoyallEnvironment functionality will only be available where it is needed
		if ( !structKeyExists( Application, "dgw" ) ) {
			//Appkey for TAPIR
			Application.appkey 						= "21AB1807582E0AF28A34CFD60618E844";
			Application.dgw								= new app.dgw();
		}

		//try to get the tapir config, contains repository information
		try {
			uTapirRole 										= this.configGet("tapir");
		} catch (any e){
			//oops, something broke, set up dummy role;
			uTapirRole 										= {
				repositories									: {},
				credentials										: {}};
		}

		//get the repo definitions, and credential definitions
		uRepos													= uTapirRole.repositories;
		uCreds													= uTapirRole.credentials;

		if (!structKeyExists(Application,"repos")){
			Application.repos = {};
		}

		//loop over all the repositories
		for (sRepo in uRepos){
			uRepo = uRepos[sRepo];
			//check to see what type of repo it is
			if ( structKeyExists( uCreds, uRepo.credentials ) && uCreds[uRepo.credentials].type == "SVN" ){
				//check to see if the repo is already registered
				if (!SVNIsValid(sRepo) || !structKeyExists(application.repos, sRepo)){
					//try to get the repo authentications keys
					try {
						//get the role
						uSVNCredential					= this.configGet(uCreds[uRepo.credentials].role);

						//loop through to get the right key
						for (i = 1; i <= listLen(uCreds[uRepo.credentials].path,"."); i++ ) {
							sKey 									= listGetAt( uCreds[ uRepo.credentials ].path, i, "." );
							uSVNCredential 				= uSVNCredential[sKey];
						}
					} catch (any e) {
						//oops, something went wrong
						uSVNCredential 					= {};
					}

					//make sure we have all the keys we need
					if (structKeyExists(uSVNCredential, "user") && structKeyExists(uSVNCredential, "temp_key_path") && structKeyExists(uSVNCredential, "key")){
						//register the repository
						sName 									= SVNRegisterRepository(
							name										=	sRepo,
							url											= uRepo.url,
							user										= uSVNCredential.user,
							key											= toString(toBinary(uSVNCredential.key)));
					}

					//make sure the repo was registed, and then add it to the Application repo list if needed
					if (SVNIsValid( sRepo ) && !structKeyExists( Application.repos, sRepo ) ) {
						Application.repos[ sRepo ] = {
							name 												: uRepo.name,
							description 								: uRepo.description
						};
					}
				}

			} else {
				// no support for other repository types at current
			}

		}
	}


	private void function configGet(required string _sRole){
		var uConfig = deserializeJSON(fileRead(expandPath("/WEB-INF/app.config")));

		if (structKeyExists(uConfig[_sRole])){
			return uCofig[_sRole];
		} else {
			return {};
		}
	}



</cfscript></cfcomponent>