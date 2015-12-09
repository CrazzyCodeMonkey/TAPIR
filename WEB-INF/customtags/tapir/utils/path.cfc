<cfcomponent output="false"><cfscript>
	this.class_path = "tapir.utils.path";

	/**
		* @class tapir.utils.path
		* @static
		*/


	/**
		* @method filePathsToStruct
		* @public
		* @param {struct} _uPaths (required)
		* @return {struct}
		*/
	public struct function filePathsToStruct(required struct _uPaths){
		var uTree = {};
		var sPath = "";
		var pntr = uTree;
		var key = "";
		var i=0;

		for( sPath in _uPaths ){
			pntr = uTree;
			key = "";

			//NOTE svn Paths will use UNIX file separators, instead of the local system
			for( i=1; i<=listLen(sPath,"/"); i++ ){
				key = listGetAt( sPath,i,"/" );
				if( !structKeyExists(pntr,key) ){
					pntr[key] = {};
				}

				if (i==listLen(sPath,"/") && listLen(key,".")>1 ){
				pntr[key] = { type:"file",
					revisions:_uPaths[sPath].revision,
					status:_uPaths[sPath].status};
				} else {
					pntr = pntr[key];
				}

			}
		}

		return uTree;
	}


	/**
		* @method getJsTreeFormat
		* @public
		* @param {struct} _data (required)
		* @param {any} [_currPath = '' ]
		* @return {array}
		*/
	public array function getJsTreeFormat( required struct _data, _currPath = '' ){
		// Var all the things, making sure each recursive run gets its own private variables
		var ret 	= [];
		var cArr 	= [];
		var commentIconArray = [];
		var state = {};
		var item 	= '';
		var icon = '';
		var commentIcon = '';
		var manualCount = 0;
		var mScanCount = 0;
		var fileInfo;
		var bSeen = false;

		console( serializeJSON(_data));
		// Loop the items in _data
		for( item in arguments._data ){
			if( !StructKeyExists(arguments._data[item], "type") ){
				state = { opened : true };

				// Append the data to cArr
				arrayAppend( ret, { state : state, icon: 'glyphicon glyphicon-folder-open light-folder', text: item, children: getJsTreeFormat(arguments._data[item], _currPath & '/' & item) } );
			} else {

				var tmp = structCopy(_data[item]);
				var currFile = reReplace(_currPath & item, '[^a-zA-Z0-9]', '', 'ALL');
				var hasComment = 'hidden';

				fileInfo = Application.dgw.invokeByRestOutStruct( 'tapir.review.files.get',
					Application.appkey,
					{
						sReviewId : request.tapir.getReviewId(),
						filePath: Right(_currPath, len(_currPath)-1) & '/' & item
					}
				);

				manualCount = 0;
				mScanCount = 0;
				commentIcon = '';
				bSeen = false;

				if ( StructKeyExists(fileInfo, 'file') && StructKeyExists( fileInfo.file, 'comments' )){
					bSeen = true;
					for ( line in fileInfo.file.comments ){
						if ( StructKeyExists( fileInfo.file.comments[ line ], 'source' )){
							if ( fileInfo.file.comments[ line ].source == 'manual'){
								manualCount++;
								hasComment = '';
							} else if ( fileInfo.file.comments[ line ].source == 'mScan' ){
								mScanCount++;
								hasComment = '';
							}
						}
					}
				}

				structDelete(tmp,'type');

				commentIconArray = [
				'<span id="comment-' & currFile & '" style="width:70px!important" class="' & hasComment & ' tree-icon editorFlagIcons tooltip-left" data-tooltip="' & manualCount & ' Manual & ' & mScanCount & ' Auto Comments"><span class="manualCount" id="manualCountIcon-' & currFile & '">',
				'<i class="fa fa-comment"></i>',
				'<span id="manualcount-'& currFile & '">',
				manualCount,
				'</span></span>&nbsp<span class="automatedCount" id="autoCountIcon-' & currFile & '">',
				'<i class="fa fa-comment"></i>',
				'<span id="autocount-'& currFile & '">',
				mScanCount,
				'</span></span></span>'];

				commentIcon= ArrayToList( commentIconArray, "");

				switch ( tmp.status ){
					case "M":
						icon = '<button class="tree-icon btn btn-fab btn-material-blue editorFlagIcons tooltip-left" data-tooltip="This File was Modified">M</button>';
						break;
					case "D":
						icon = '<button class="tree-icon btn btn-fab btn-material-red editorFlagIcons tooltip-left" data-tooltip="This File was Deleted">D</button>';
						break;
					case "X":
						icon = '<button class="tree-icon btn btn-fab btn-material-orange editorFlagIcons tooltip-left" data-tooltip="Deleted Outside Current Scope">X</button>';
						break;
					case "A":
						icon = '<button class="tree-icon btn btn-fab btn-material-green editorFlagIcons tooltip-left" data-tooltip="This File was Added">A</button>';
						break;

				}

				arrayAppend( ret, { icon: 'glyphicon glyphicon-file', text: item &'<span></span>' & '&nbsp' & icon & '&nbsp&nbsp' & commentIcon, data: tmp, id: currFile } );
			}
		}
		return ret;
	}

</cfscript></cfcomponent>