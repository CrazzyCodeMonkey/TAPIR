/**
 * App Controller for Tapir *
 */
var app = ( function() {

	var app = this;

	app.boot = new component.bs();
	window.treeTriggerClick = true;



	/**
	 * Compare the 2 nodes
	 *
	 * @param {object} _apples 	Node 1
	 * @param {object} _bananas Node 2
	 * @return {integer} Comparison result
	 */
	var compareNode = function( _apples, _bananas ) {
		if ( typeof _apples.children !== 'undefined' && typeof _bananas.children === 'undefined' ) {
			return -1;
		}
		if ( typeof _apples.children === 'undefined' && typeof _bananas.children !== 'undefined' ) {
			return 1;
		}
		if ( typeof _apples.children === typeof _bananas.children ) {
			if ( _apples.text.toLowerCase() > _bananas.text.toLowerCase() ) {
				return 1;
			}
			if ( _apples.text.toLowerCase() < _bananas.text.toLowerCase() ) {
				return -1;
			}
			return 0;
		}
		return 0;
	};



	/**
	 * Sorts the tree recursively
	 * @param  {Array} _workingArray Array that is being sorted
	 * @return {Array}              Sorted Array
	 */
	function sortTree( _workingArray ) {
		_workingArray.sort( compareNode );
		_workingArray.forEach( function( _child ) {
			if ( typeof _child.children !== 'undefined' ) {
				_child.children = sortTree( _child.children );
			}
		} );
		return _workingArray;
	}



	/**
	 * Kicks off the JSTree plugin and creates a jsstree instance
	 *
	 * @method  initJSTree
	 */
	var initJSTree = function() {

		// Set the theme of JStree to not show dots
		$.jstree.defaults.core.themes.dots = false;

		if ( typeof window.jsTreeData !== 'undefined' ) {
			window.jsTreeData = sortTree( window.jsTreeData );
		}
		console.log( JSON.stringify( window.jsTreeData, null, 4 ) );
		// Init JSTree
		$( '#jstreeContainer' ).jstree( {
			'core': {
				'data': window.jsTreeData
			},
			// 'plugins': [ 'sort' ] //Disabled sorting plugin, using manual sorting method sortTree
		} ).bind( 'select_node.jstree', EventManager.bindTreeNodes );
	};



	/**
	 * Initialize data for the Commit Component
	 *
	 * @method initCommit
	 */
	function initCommit() {

		var ticket;
		var x;
		var i;

		if ( ( typeof StateManager.getKey( 'ticket' ) === 'string' ) && ( typeof StateManager.getKey( 'repo' ) === 'string' ) && ( typeof StateManager.getKey( 'repoStart' ) === 'string' ) && typeof window.jsonData !== 'undefined' ) {

			ticket = StateManager.getKey( 'ticket' );

			for ( x in window.jsonData ) {
				// Start with blank array for each commit
				theFileList = [];

				// Loop the change data and append thefileList array
				for ( i in window.jsonData[ x ].changed ) {
					theFileList.push( {
						name: window.jsonData[ x ].changed[ i ].path,
						comments: ''
					} );
				}
				// Set a shorter version, purely for readability
				lMessage = window.jsonData[ x ].logmessage;

				// Set to log message, but without the header data.
				logWithoutHeader = lMessage.substring( lMessage.indexOf( ticket ) + ticket.length + 1, lMessage.length );

				// And finally stringify the array
				theFileList = JSON.stringify( theFileList );

				$( '.collapse-card' ).paperCollapse();

			}
		}
	}



	/**
	 * Peforms action during state change
	 *
	 * @method  changeState
	 */
	var changeState = function() {

		var workingState = StateManager.getState();
		var selectedNode;
		var selectedDataNode;
		var parents;
		var path;

		if ( workingState.inspecting === true || workingState.inspecting === 'true' ) {

			util.scrollToTop();

			//Deselect all nodes
			$( '#jstreeContainer' ).jstree().deselect_all();

			//Select the node base on current state
			$( '#jstreeContainer' ).jstree( 'select_node', '#' + workingState.file );

			//Get the selected reference in jstree
			selectedNode = $( '#jstreeContainer' ).jstree( 'get_selected' );

			//Get the data from the selected node
			selectedDataNode = $( '#jstreeContainer' ).jstree().get_selected( true )[ 0 ];

			//Get parents path of the selected node in an array
			parents = $( '#jstreeContainer' ).jstree( 'get_path', selectedNode );

			//Join the parent array to form the actual path
			path = parents.join( '/' ).split( '<span></span>' )[ 0 ];

			//Change the filename on the header of the slider
			$( '#filename' ).html( path );

			//Add is-visible class to slide in the slider
			$( '.cd-panel' ).addClass( 'is-visible' );

			//Add Loading2 class to blur the content
			$( '.cd-panel-container-actual' ).css( 'overflow-y', 'hidden' );

			util.loading( '.contentContainer', false );
			$( '.cd-panel-container-actual' ).css( 'overflow-y', 'auto' );
			util.loading( '.contentContainer', null, false );

			//Load up the diff of the selected file
			component.Diff.set( '#diffContainer', StateManager.getKey( 'repo' ), path, selectedDataNode.data.revisions.join( ',' ) ).done( function( diff ) {

				//Update refeerence of the last diff loaded
				app.lastDiff = diff;

				//Clean up loading coomponents
				setTimeout( function() {

					util.loading( '.contentContainer', false );
					$( '.cd-panel-container-actual' ).css( 'overflow-y', 'auto' );
					expandSlider();
					returnToComment();

				}, 500 );

			} );
		}



		/**
		 * Returns the user to the last comment saved in the state if line state exists
		 *
		 * @method  returnToComment
		 */
		function returnToComment() {

			var element;

			var lineStart = parseInt( workingState.line );
			var lineEnd = $( '.actualLineAt-' + ( parseInt( $( '#lineExternal-' + workingState.line ).data( 'actualline' ) ) + ( parseInt( workingState.lineLength ) || 1 ) ) ).data( 'line' );
			var lineLength = parseInt( workingState.lineLength ) - 1;
			var lineComment = $( '#lineExternal-' + workingState.line + ' #commentText' ).html();

			if ( typeof workingState.line !== 'undefined' ) {

				//Goto selected Line if the line is not 0
				if ( workingState.line !== 0 ) {

					//Get the element of holding the line provide in the state
					element = document.getElementById( 'lineExternal-' + workingState.line );

					if ( element ) {

						//Scroll to last selected line
						element.scrollIntoView( {
							block: 'start',
							behavior: 'smooth'
						} );

						if ( workingState.lineLength === 'undefined' ) {
							workingState.lineLength = 1;
						}

						//Highlight the lines provided in the state
						util.highlightLines( lineStart, lineEnd, true, lineLength );

						$( '.highlight' ).addClass( 'marked' );

						if ( $( '#lineExternal-' + lineStart ).has( 'div.displayComment' ).length === 1 ) {
							//Add Comment to the file based on the selection in the state
							app.lastDiff.addComment( lineStart, lineEnd, null, lineComment, {
								edit: true
							} );
						} else if ( $( '#lineExternal-' + lineStart ).has( 'div.displaymScanComment' ).length === 1 ) {
							//Add Comment to the file based on the selection in the state
							app.lastDiff.addComment( lineStart, lineEnd, null, lineComment, {
								auto: true
							} );
						} else {
							app.lastDiff.addComment( lineStart, lineEnd, null );
						}

						//Clean up the state
						delete workingState.rowStartSelect;
						delete workingState.lineEndSelect;
						delete workingState.lineLength;
						delete workingState.line;

						//Update the url and state but not fire another state change
						StateManager.updateURLAndState( workingState );
					}
				} else {

					util.scrollToTop();

				}
			}

		}



		/**
		 * Expand or shrink the slider based on state
		 *
		 * @method expandSlider
		 */
		function expandSlider() {

			if ( workingState.expandSlider !== 'true' && workingState.expandSlider !== true && ( $( '.cd-panel-container' ).width() > $( window ).width * 0.2 ) ) {

				$( '#expandSlider > i ' ).removeClass( 'fa-chevron-right' );
				$( '.cd-panel-container' ).animate( {
					width: '75%'
				}, 300, function() {

					setTimeout( function() {
						$( '#expandSlider > i ' ).addClass( 'fa-chevron-left' );
						StateManager.setKey( 'sliderSize', $( '.cd-panel-container' ).width() );
					}, 100 );
				} );

			} else if ( workingState.expandSlider === 'true' || workingState.expandSlider === true && ( $( '.cd-panel-container' ).width() < $( window ).width * 0.9 ) ) {
				StateManager.setKey( 'expandSlider', true );
				$( '#expandSlider > i ' ).removeClass( 'fa-chevron-left' );
				$( '.cd-panel-container' ).animate( {
					width: '100%'
				}, 300, function() {
					setTimeout( function() {
						$( '#expandSlider > i ' ).addClass( 'fa-chevron-right' );
						StateManager.setKey( 'sliderSize', $( '.cd-panel-container' ).width() );

					}, 100 );
				} );

			}
		}

	};



	/**
	 * Dynamically resize the content based on the size of document and header
	 * @return {[type]} [description]
	 */
	function dynamicResize() {
		var headerHeight = 0;
		var windowHeight = $( window ).height();
		headerHeight = $( 'body > nav > div' ).height();
		$( 'body' ).css( 'padding-top', headerHeight );
		$( '.mainPane' ).css( 'height', windowHeight - ( headerHeight ) );
		$( '.cd-panel-container-header' ).css( 'margin-top', headerHeight + 10 );
		$( '.cd-panel-container-actual' ).css( 'margin-top', headerHeight + 60 );
		$( '.cd-panel-container-actual' ).css( 'height', windowHeight - headerHeight - 60 );
		$( '#dashboard' ).css( 'height', windowHeight - headerHeight + 10 );
	}



	/**
	 * Kick off app
	 *
	 * @method  init
	 */
	function init() {

		//Init the statemanager with the list of states to keep and the change state function
		StateManager.init( [ 'file', 'inspecting', 'expandSlider', 'line', 'reviewId', 'rowStartSelect', 'lineEndSelect', 'lineLength' ], changeState );

		initCommit();
		initJSTree();

		//Init actions for the material bootstrap
		$.material.init();

		window.onresize = function( event ) {
			dynamicResize();
		};

		setTimeout( function() {
			dynamicResize();
			changeState();
		}, 0 );

		BootStrap.resizeable( '#resizeableCommitSelectContainer', {
			resizeX: true,
			Xfrom: 'left',
			resizeY: false,
			Yfrom: 'down',
			resizeElement: '#commitResize',
			oppositeElement: '#resizeableOppositeContainer'
		} );
	}

	init();

	return app;

} )();