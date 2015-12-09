<cfcomponent output="false"><cfscript>
	this.class_path = "tapir.utils.svn";

	/**
		* @class tapir.utils.svn
		* @static
		*
		*/



	/**
		* @method getRevisionLogs
		* @public
		* @param {array} _aRevisions (required)
		* @return {array}
		* @static
		*/
	public array function getRevisionLogs(required string _repo, required array _aRevisions){
		var aLog = [];
		var nRev = "";

		for (nRev in _aRevisions){
			aRev = SVNLogView(name=_repo, startRevision=nRev, endRevision=nRev);
			if (arrayLen(aRev)>0){
				arrayAppend(aLog, aRev[1]);
			}
		}

		return aLog;
	}



	/**
		* @method getLogRevisions
		* @public
		* @param {array} _aLogs (required)
		* @return {array}
		* @static
		*/
	public array function getLogRevisions(required array _aLogs){
		var aRevs = [];
		var uLog = {};

		for (uLog in _aLogs){
			arrayAppend(aRevs,uLog.revision);
		}

		return aRevs;
	}


	/**
		* @method getLogFiles
		* @public
		* @param {array} _aLogs (required)
		* @return {array}
		* @static
		*/
	public struct function getLogFiles(required string _repo, required array _aLogs){
		var uFiles = {};
		var uLog = {};
		var uChange = {};
		var file="";

		for (uLog in _aLogs){
			for( uChange in uLog.changed ){
				if ( !structKeyExists( uFiles, uChange.path ) ) {
					uFiles[uChange.path] = {revision:[],status:""};
				}
				arrayAppend( uFiles[uChange.path].revision, uLog.revision );
				uFiles[uChange.path].status = uChange.type;
			}
		}

		for (file in uFiles){

			thread name=file _repo=_repo _sStatus=uFiles[file].status{
				var sStatus = _sStatus;
				if (sStatus != "D" && SVNGetStatus(_repo, THREAD.name) == "none"){
					sStatus = "X";
				}
				return sStatus;
			}

		}

		thread action="join" name=structKeyList(uFiles) timeout=10000;

		for (file in uFiles){
			if (structKeyExists(CFTHREAD,file) && structKeyExists(CFTHREAD[file],"returnVariable")){
				uFiles[file].status = CFTHREAD[file].returnVariable;
			}
		}

		return uFiles;
	}




	/**
		* @method getReposAndRevisions
		* @public
		* @return {array}
		* @static
		*/
	public array function getReposAndRevisions(){
		var repos = [];

		for ( key in Application.repos ){
			repoHead = SVNLatestRevision( key );
			repoStart = ( repoHead > 500 ) ? (repoHead - 500) : 0;

			ArrayAppend( repos, {
				label : Application.repos[key].name,
				value : key,
				tooltip : Application.repos[key].description,
				data : repoStart });
		}

		return repos;
	}




</cfscript></cfcomponent>