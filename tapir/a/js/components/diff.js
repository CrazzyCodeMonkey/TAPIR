/**
 * $Id: diff.js 23289 2015-11-20 21:47:25Z llee $
 */
var component = component || {};

/**
 * Diff Component
 *
 * @class  Diff
 *
 */
component.Diff = ( function() {


	var diffComments;
	var resizeDiff;


	/**
	 * Binds action for the diff component
	 *
	 * @method  bindDiffAction
	 */
	function bindDiffActions() {

		var bindSourceFilter = {
			trueAction: function( _filter ) {
				$( '#show' + _filter.displayLabel + 'Button' ).html( _filter.displayLabel + ' &nbsp<i class="fa fa-square-o"></i>' );
				$( 'li.' + _filter.cssLabel ).css( 'display', 'none' );
			},
			falseAction: function( _filter ) {
				$( '#show' + _filter.displayLabel + 'Button' ).html( _filter.displayLabel + ' &nbsp<i class="fa fa-check-square-o"></i>' );
				$( 'li.' + _filter.cssLabel ).css( 'display', 'inherit' );
			}
		};


		var bindmScanAction = {
			trueAction: function( _filter ) {
				$( '.displaymScanComment' ).addClass( 'mini' );
				$( '#show' + _filter.displayLabel + 'Button' ).html( 'mScan comments &nbsp<i class="fa fa-square-o"></i>' );
			},
			falseAction: function( _filter ) {
				$( '.displaymScanComment' ).removeClass( 'mini' );
				$( '#show' + _filter.displayLabel + 'Button' ).html( 'mScan comments  &nbsp<i class="fa fa-check-square-o"></i>' );
			}
		};


		var bindIndentAction = {
			trueAction: function( _filter ) {
				$( '#show' + _filter.displayLabel + 'Button' ).html( 'Indent &nbsp<i class="fa fa-square-o"></i>' );
				$( '.wp' ).css( 'visibility', 'hidden' );
			},
			falseAction: function( _filter ) {
				$( '#show' + _filter.displayLabel + 'Button' ).html( 'Indent &nbsp<i class="fa fa-check-square-o"></i>' );
				$( '.wp' ).css( 'visibility', 'inherit' );
			}
		};
		var filterArray = [ {
			cssLabel: 'Updated',
			displayLabel: 'Updated',
			actions: bindSourceFilter
		}, {
			cssLabel: 'Removed',
			displayLabel: 'Deleted',
			actions: bindSourceFilter
		}, {
			cssLabel: 'Added',
			displayLabel: 'Added',
			actions: bindSourceFilter
		}, {
			cssLabel: 'Pristine',
			displayLabel: 'Pristine',
			actions: bindSourceFilter
		}, {
			cssLabel: 'mScan',
			displayLabel: 'mScan',
			actions: bindmScanAction
		}, {
			cssLabel: 'Indent',
			displayLabel: 'Indent',
			actions: bindIndentAction
		} ];



		// Handler for the previous-button
		$( '#previousChangeButtonFixed' ).unbind( 'click' );
		$( '#previousChangeButtonFixed' ).on( 'click', function() {
			previousComment();
		} );



		// Handler for the floating next-button
		$( '#nextChangeButtonFixed' ).unbind( 'click' );
		$( '#nextChangeButtonFixed' ).on( 'click', function() {
			nextComment();
		} );

		StateManager.setKey( 'showDiffSetting', false );
		$( '.cd-panel-container-header' ).animate( {
			height: '50px'
		}, 200 );
		$( '#diffSettings' ).off( 'click' );

		$( '#diffSettings' ).on( 'click', function() {
			if ( StateManager.getKey( 'showDiffSetting' ) !== true ) {
				StateManager.setKey( 'showDiffSetting', true );
				$( '.cd-panel-container-header' ).animate( {
					height: parseInt( $( '.cd-panel-controls-container' ).height() ) + 70
				}, 200 );
			} else {
				StateManager.setKey( 'showDiffSetting', false );
				$( '.cd-panel-container-header' ).animate( {
					height: '50px'
				}, 200 );
			}

		} );

		/**
		 * Common UI Changes for all buttons
		 * @param  {[type]} _filter [description]
		 * @return {[type]}         [description]
		 */
		function bindButton( _filter ) {
			if ( StateManager.getKey( 'show' + _filter.displayLabel ) !== true ) {
				$( '#show' + _filter.displayLabel + 'ButtonSmall' ).removeClass( 'smallButtonToggleOff' );
				$( '#show' + _filter.displayLabel + 'ButtonSmall .sliderIcon' ).removeClass( 'smallButtonToggleOff' );
				$( '#show' + _filter.displayLabel + 'Button' ).removeClass( 'btn-material-grey' );
				$( '#show' + _filter.displayLabel + 'Button' ).removeClass( 'smallButtonToggleOff' );
				$( '#show' + _filter.displayLabel + 'Button' ).addClass( 'toggleButton' );

				StateManager.setKey( 'show' + _filter.displayLabel, true );
				_filter.actions.trueAction( _filter );
			} else {
				$( '#show' + _filter.displayLabel + 'ButtonSmall' ).addClass( 'smallButtonToggleOff' );
				$( '#show' + _filter.displayLabel + 'ButtonSmall .sliderIcon' ).addClass( 'smallButtonToggleOff' );
				$( '#show' + _filter.displayLabel + 'Button' ).addClass( 'btn-material-grey' );
				$( '#show' + _filter.displayLabel + 'Button' ).addClass( 'smallButtonToggleOff' );
				$( '#show' + _filter.displayLabel + 'Button' ).removeClass( 'toggleButton' );
				StateManager.setKey( 'show' + _filter.displayLabel, false );
				_filter.actions.falseAction( _filter );
			}
		}

		filterArray.forEach( function( _filter ) {

			StateManager.setKey( 'show' + _filter.displayLabel, false );
			//Show Updated Toggle
			$( '#show' + _filter.displayLabel + 'Button' ).removeClass( 'toggleButton' );
			$( '#show' + _filter.displayLabel + 'Button' ).addClass( 'smallButtonToggleOff' );
			$( '#show' + _filter.displayLabel + 'Button' ).off( 'click' );
			$( '#show' + _filter.displayLabel + 'Button' ).on( 'click', function() {
				bindButton( _filter );
			} );
			$( '#show' + _filter.displayLabel + 'ButtonSmall' ).addClass( 'smallButtonToggleOff' );
			$( '#show' + _filter.displayLabel + 'ButtonSmall .sliderIcon' ).addClass( 'smallButtonToggleOff' );
			$( '#show' + _filter.displayLabel + 'ButtonSmall' ).off( 'click' );
			$( '#show' + _filter.displayLabel + 'ButtonSmall' ).on( 'click', function() {
				bindButton( _filter );
			} );
		} );


		$( '#revControlDiff' ).html( $( '#revControl' ).html() );
		//Revision Number button actions
		$( '#revControlDiff button' ).off( 'click' );
		$( '#revControlDiff button' ).on( 'click', function() {
			if ( $( this ).data( 'checked' ) === true ) {
				$( this ).addClass( 'pressed' );
				$( this ).data( 'checked', false );
				$( '.' + $( this ).val() + '.Removed' ).closest( 'li' ).addClass( 'hidden' );
				$( '.' + $( this ).val() + '.Added' ).closest( 'li' ).addClass( 'noStyle' );
				$( '.' + $( this ).val() + '.Added' ).closest( 'button' ).addClass( 'notVisible' );
				$( '.' + $( this ).val() + '.Head' ).closest( 'li' ).addClass( 'noStyle' );
				$( '.' + $( this ).val() + '.Head' ).closest( 'button' ).addClass( 'notVisible' );
				$( '.' + $( this ).val() + '.Updated' ).closest( '.olderUpdates' ).addClass( 'notVisible' );


			} else {
				$( this ).removeClass( 'pressed' );
				$( this ).data( 'checked', true );
				$( '.' + $( this ).val() + '.Removed' ).closest( 'li' ).removeClass( 'hidden' );
				$( '.' + $( this ).val() + '.Added' ).closest( 'li' ).removeClass( 'noStyle' );
				$( '.' + $( this ).val() + '.Added' ).closest( 'button' ).removeClass( 'notVisible' );
				$( '.' + $( this ).val() + '.Head' ).closest( 'li' ).removeClass( 'noStyle' );
				$( '.' + $( this ).val() + '.Head' ).closest( 'button' ).removeClass( 'notVisible' );
				$( '.' + $( this ).val() + '.Updated' ).closest( '.olderUpdates' ).removeClass( 'notVisible' );
			}
		} );
	}



	function setupCommentArray() {
		$( '.cd-panel-container-actual' ).scrollTop( 0 );
		// Set up the comments array
		window.allCommentLines = [];
		var theThings = $( '.sourceCode' ).find( '.editorFlagIcons' );

		for ( i = 0; i < theThings.length; ++i ) {
			window.allCommentLines.push( theThings[ i ] );
		}
		window.currentCommentLine = -1;
	}

	// Scroll handler for the previous/next-buttons
	$( '.cd-panel-container-actual' ).scroll( function() {
		var scrollPos = $( '.cd-panel-container-actual' ).scrollTop();

		if ( window.currentCommentLine > 0 ) {
			$( '#previousChangeButtonFixed' ).addClass( 'activeButton' );
			$( '#previousChangeButtonFixed > i' ).removeClass( 'sliderIcon' );
			$( '#previousChangeButtonFixed' ).prop( 'disabled', false );
		} else {
			$( '#previousChangeButtonFixed' ).removeClass( 'activeButton' );
			$( '#previousChangeButtonFixed > i' ).addClass( 'sliderIcon' );
			$( '#previousChangeButtonFixed' ).prop( 'disabled', true );
		}

		if ( window.currentCommentLine + 1 < window.allCommentLines.length ) {
			$( '#nextChangeButtonFixed' ).addClass( 'activeButton' );
			$( '#nextChangeButtonFixed > i' ).removeClass( 'sliderIcon' );
			$( '#nextChangeButtonFixed' ).prop( 'disabled', false );

		} else {
			$( '#nextChangeButtonFixed' ).removeClass( 'activeButton' );
			$( '#nextChangeButtonFixed > i' ).addClass( 'sliderIcon' );
			$( '#nextChangeButtonFixed' ).prop( 'disabled', true );
		}

		if ( scrollPos === 0 ) {
			window.currentCommentLine = -1;
		}
	} );



	/**
	 * Handler for going to the previous comment
	 */
	function previousComment() {
		var foundOne = false;

		while ( foundOne === false && window.currentCommentLine > 0 ) {
			window.currentCommentLine--;
			var itm = $( window.allCommentLines[ window.currentCommentLine ] ).parent().parent();
			if ( !itm.hasClass( 'hidden' ) && itm.css( 'display' ) != 'none' ) {
				foundOne = true;
			}
		}

		currScroll = $( '.cd-panel-container-actual' ).scrollTop();
		$( '.cd-panel-container-actual' ).scrollTop( ( $( window.allCommentLines[ window.currentCommentLine ] ).offset().top + currScroll ) - 121 );
	}



	/**
	 * Handler for going to the next comment
	 */
	function nextComment() {
		var foundOne = false;

		while ( foundOne === false && window.currentCommentLine < window.allCommentLines.length - 1 ) {
			window.currentCommentLine++;
			var itm = $( window.allCommentLines[ window.currentCommentLine ] ).parent().parent();
			if ( !itm.hasClass( 'hidden' ) && itm.css( 'display' ) != 'none' ) {
				foundOne = true;
			}
		}

		currScroll = $( '.cd-panel-container-actual' ).scrollTop();
		$( '.cd-panel-container-actual' ).scrollTop( ( $( window.allCommentLines[ window.currentCommentLine ] ).offset().top + currScroll ) - 121 );
	}



	/**
	 * Bind events to all diff comment generated from cfml (First Load)
	 *
	 * @method bindContents
	 */
	function bindContents( _commentInstance ) {

		var length;

		$( '#fileComment > a' ).on( 'click', function( e ) {
			e.stopPropagation();
		} );
		$( '.list-group-item-text > a' ).on( 'click', function( e ) {
			$( ".sourceCode li" ).removeClass( "marked" );
			//Remove the blur effect from the rest of content
			$( ".sourceCode li" ).removeClass( 'blurred' );

			//Remove highlights
			$( ".sourceCode li" ).removeClass( "highlighted" );
			$( ".sourceCode li" ).removeClass( "mlighted" );

			e.stopPropagation();
		} );


		$( '.displaymScanComment' ).on( 'click', function() {
			if ( $( this ).data( 'length' ) > 1 ) {
				length = $( this ).data( 'length' ) + 1;
			} else {
				length = 1;
			}

			if ( !$( '#lineExternal-' + $( this ).data( 'line' ) ).hasClass( 'blurred' ) ) {
				_commentInstance.addComment( $( this ).data( 'line' ), $( this ).data( 'actualline' ) + length, length, $( this ).data( 'comment' ), {
					auto: true,
					edit: true
				} );
			}
		} );

		$( '.displayFileComment' ).on( 'click', function() {
			_commentInstance.addComment( -1 );
		} );

		$( '.displayComment:not([class*="displayFileComment"])' ).on( 'click', function() {
			if ( $( this ).data( 'length' ) > 1 ) {
				length = $( this ).data( 'length' ) + 1;
			} else {
				length = 1;
			}

			if ( !$( '#lineExternal-' + $( this ).data( 'line' ) ).hasClass( 'blurred' ) ) {
				_commentInstance.addComment( $( this ).data( 'line' ), $( this ).data( 'actualline' ) + length, length, $( this ).data( 'comment' ) );

			}

		} );
	}

	setTimeout( function() {
		BootStrap.resizeable( '.cd-panel-container', {
			resizeX: true,
			Xfrom: 'left',
			resizeY: true,
			Yfrom: 'down',
			resizeElement: '#expandSlider',
			onResize: function( _newSize ) {
				StateManager.setKey( 'sliderSize', _newSize );
			}
		} );
	}, 1000 )


	/**
	 * Set the diff that is shown in view
	 * @param {String} _location Location of the dom element to set the dff at
	 * @param {String} _repo     The Repo containing the diff
	 * @param {String} _file     The file name for the diff
	 * @param {String} _rev      List of revisions to show
	 *
	 * @method  set
	 */
	function set( _location, _repo, _file, _rev ) {

		var d = $.Deferred();
		var uParams = {
			_repo: _repo,
			_file: _file,
			_revisions: _rev
		};

		$.post( '/tapir/rpc/diff.cfc?method=diffRender&reviewId=' + window.reviewId, uParams,
			function( response ) {
				var filenameId;
				var result = JSON.parse( response );
				var manualCount = 0;
				var autoCount = 0;
				if ( typeof result.comments.file !== 'undefined' && typeof result.comments.file.comments !== 'undefined' ) {
					for ( var comment in result.comments.file.comments ) {
						if ( typeof result.comments.file.comments[ comment ].source !== 'undefined' && result.comments.file.comments[ comment ].source === 'manual' ) {
							manualCount++;
						} else {
							autoCount++;
						}
					}
				}

				// Renders diff into the the page
				$( _location ).html( result.html );

				filenameId = $( '#filename' ).text().replace( /[^a-zA-Z0-9]/g, '' );
				if ( ( manualCount + autoCount ) > 0 ) {
					$( '#comment-' + filenameId ).removeClass( 'hidden' );
				}
				$( '#manualcount-' + filenameId ).text( manualCount );
				$( '#autocount-' + filenameId ).text( autoCount );

				var newValue = $( '#manualcount-' + filenameId ).text() + ' Manual & ' + $( '#autocount-' + filenameId ).text() + ' Auto Comments';

				$( '#comment-' + filenameId ).attr( 'data-tooltip', newValue );
				// Bind Actions for the Diff after the dom has updated
				bindDiffActions();

				// Binds a new Diff Selector
				diffComments = new component.DiffComments();

				if ( typeof window.access === 'boolean' && window.access === true ) {
					bindContents( diffComments );
				}

				// Applies code highlighter
				$( 'pre code' ).each( function( i, block ) {
					hljs.highlightBlock( block );
				} );

				d.resolve( diffComments );
				setupCommentArray();

				$( '#previousChangeButtonFixed' ).removeClass( 'activeButton' );
				$( '#previousChangeButtonFixed > i' ).addClass( 'sliderIcon' );
				$( '#previousChangeButtonFixed' ).prop( 'disabled', true );

				$( '#nextChangeButtonFixed' ).addClass( 'activeButton' );
				$( '#nextChangeButtonFixed > i' ).removeClass( 'sliderIcon' );
				$( '#nextChangeButtonFixed' ).prop( 'disabled', false );
			} );

		return d.promise();

	}

	return {
		diffComments: diffComments,
		set: set
	};

} )();