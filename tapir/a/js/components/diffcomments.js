/**
 * Component for the Drag Selector for creating comments for the diff
 * $Id: diffcomments.js 23593 2015-12-08 15:52:43Z llee $
 *
 * @Class DiffComments
 */
component.DiffComments = function() {

	var config = {
		genericErrorHeader: 'Something Has Gone Terribly Wrong!',
		genericErrorBody: 'We\'ve encountered an unspecified AJAX error'
	};
	var keybinder = new component.Keybinder();

	// Used for events to check if the mouse is current helded down
	var isMouseDown = false;

	//The First Item that was selected, This is not the same as the start line, start line can be start Item or currently selected depending on the selection
	var rowStartSelect;

	//The Current Item that is selected (Mouse Over)
	var rowEndSelect;

	//The Current Item that is selected, actual row number(Mouse Over)
	var lineEndSelect;

	var mouseOverSpecial = false;

	var filenameId = $( '#filename' ).text().replace( /[^a-zA-Z0-9]/g, '' );



	/**
	 * Add Comments to the Source, If clicked on a empty row, no param is passed, if clicked on previous comment, all param must be passed
	 * @param	{Number} _rowStartActual		Start of the row, regardless of direction
	 * @param	{Number} _lineEndSelect		End of Selection, in lines
	 * @param	{Number} _lineLength				Number of lines of selection
	 * @param	{String} _comment					Comment Message
	 * @param	{String} _update						Flag to specify an update
	 */
	var addComment = function( _rowStartSelect, _lineEndSelect, _lineLength, _comment, _mode, _lastInput ) {

		//The line position of the where the comment begins
		var startLineActual;
		//Markup to display info about the line of the comment
		var lineInfo;
		//Input Value in the comment
		var inputValue;
		//Lenght of the comment
		var lineLength;
		//Start of the comment selection
		var lineStartSelect;

		var _mode = _mode || {};

		var mode = {
			//Edit mode is driven by params of a previous call
			edit: _mode.edit || false,
			//Update mode is driven by having a selection of a comment
			update: _mode.update || false,
			file: _mode.file || false,
			auto: _mode.auto || false
		};

		var lastCommentText;
		var state = StateManager.getState();
		var lastInput;
		var inputMarkup = '';
		var targetElement;
		var commentHTML = '';
		var commentHTMLText = '';

		lineEndSelect = _lineEndSelect || lineEndSelect + 1;

		//Resync rowEndSelect using lineEndSelect
		rowEndSelect = $( '.actualLineAt-' + lineEndSelect ).data( 'line' );

		//Select the start Item depending if the param exists
		rowStartSelect = _rowStartSelect || rowStartSelect;

		//Get the line number of start of the selection base on the row number
		lineStartSelect = $( '#lineExternal-' + rowStartSelect ).data( 'actualline' );
		//Remove existing comment, if params was passed, at the first line of the comment
		//Set the startLineActuyal depending if the selection was upwards or downwards
		rowStartActual = ( rowEndSelect < rowStartSelect ) ? rowEndSelect : rowStartSelect;

		$( '.sourceCode li:not([class*="highlighted"])' ).addClass( 'blurred' );

		//Marked Comments that is currently selected (This is a workaround to override the mouse over event that deselects highlighted cells)
		if ( $( '#lineExternal-' + rowStartActual ).has( 'div.displayComment' ).length === 1 ) {
			lastCommentText = $( '#lineExternal-' + rowStartActual ).find( '#commentText' ).html();
			mode.update = true;
		}
		if ( $( '#lineExternal-' + rowStartActual ).has( 'div.displaymScanComment' ).length === 1 || mode.auto === true ) {
			lastCommentText = $( '#lineExternal-' + rowStartActual ).find( '#commentText' ).html();
			mode.auto = true;
			mode.update = true;
		}
		if ( mode.edit === true ) {
			$( '#lineExternal-' + rowStartActual ).addClass( 'marked' );
			lastCommentText = _comment;
		}

		$( '.sourceCode li:not([class*="blurred"])' ).addClass( 'marked' );

		//Defined MOde
		if ( typeof _rowStartSelect === 'number' ) {
			if ( _rowStartSelect === -1 ) {
				mode.file = true;
			} else {
				mode.edit = true;
			}
		}

		targetElement = ( mode.auto === true ) ? 'displaymScanComment' : 'displayComment';

		//Reset all events sourceCode pre
		$( '.sourceCode pre' ).off( 'click' ).off( 'mouseover' ).off( 'mouseup' ).off( 'mousedown' );

		lastInput = _lastInput || $( '#input-' + rowStartActual ).val();

		if ( lastInput === 'true' ) {
			inputMarkup = 'value="true" checked';
		} else {
			inputMarkup = 'value="false"';
		}

		if ( mode.file === true ) {
			lineInfo = 'File level comment';
			_lineLength = 1;
		} else if ( lineStartSelect === ( lineEndSelect - 1 ) || _lineLength === 1 ) {
			_lineLength = 0;
			lineInfo = ' Line ' + ( lineStartSelect + 1 ) + ': ';
		} else if ( lineStartSelect < lineEndSelect - 1 ) {
			_lineLength = ( lineEndSelect ) - ( lineStartSelect + 1 ) + 1;
			lineInfo = ' Line ' + ( lineStartSelect + 1 ) + ' - ' + ( lineEndSelect ) + ': ';
		} else {
			_lineLength = ( lineStartSelect + 1 ) - lineEndSelect + 1;
			lineInfo = ' Line ' + lineEndSelect + ' - ' + ( lineStartSelect + 1 ) + ': ';
		}

		if ( mode.file === true ) {
			commentHTMLText = $( '#fileComment' ).html().replace( /\\\"/g, '"' );
		} else if ( mode.edit === true || mode.update === true ) {
			commentHTMLText = _comment || lastCommentText || '';
		}

		commentHTML = constructCommentHTML( lineInfo, inputMarkup, commentHTMLText, ( mode.edit === true || mode.update === true || mode.file ), mode.file );

		setTimeout( function() {

			if ( mode.file === true ) {
				$( '.displayFileComment' ).addClass( 'hidden' );
			} else {
				$( '#lineExternal-' + rowStartActual + ' .displayComment' ).addClass( 'hidden' );

			}
			if ( mode.edit === true ) {
				$( '#lineExternal-' + rowStartActual + ' div.displayComment' ).addClass( 'hidden' );
				lastCommentText = $( '#lineExternal-' + rowStartActual + ' div.displayComment' ).find( '#commentText' ).html();
			}
			$( '.commentContainer' ).remove();

			if ( mode.file === true ) {
				$( '.displayFileComment' ).after( commentHTML );
			} else {
				$( '#lineExternal-' + rowStartActual ).prepend( commentHTML );
			}

			$( '#commentTextArea' ).on( 'focus', function() {
				this.selectionStart = this.selectionEnd = this.value.length;
			} );
			$( '#commentTextArea' ).focus();

			$( '#commentTextArea' ).off( 'focus' );

			//Add the comment markup to the start line in the dom
			$( '#cancelSubmit' ).on( 'click', function() {
				cancelEvent( rowStartActual, lineEndSelect, _lineLength, rowStartSelect, lineInfo, mode, lastCommentText, inputMarkup, lastInput );
			} );

			$( '#commentSubmit' ).on( 'click', function() {
				submitEvent( rowStartActual, lineEndSelect, _lineLength, rowStartSelect, lineInfo, mode );
			} );

			if ( mode.edit === true || mode.update === true || mode.file ) {
				$( '#removeSubmit' ).on( 'click', function() {
					removeEvent( rowStartActual, _lineLength, mode );
				} );
			}

			//Bind keys while comments are open.
			keybinder.bindEvent( [ {
				keysCombo: 'esc',
				activateAction: function() {
					cancelEvent( rowStartActual, lineEndSelect, _lineLength, rowStartSelect, lineInfo, mode, lastCommentText, inputMarkup, lastInput );
				}
			}, {
				keysCombo: 'ctrl + s',
				activateAction: function() {
					submitEvent( rowStartActual, lineEndSelect, _lineLength, rowStartSelect, lineInfo, mode );
				}
			}, {
				keysCombo: 'ctrl + d',
				activateAction: function() {
					if ( mode.edit === true || mode.update === true || mode.file ) {
						removeEvent( rowStartActual, _lineLength, mode );
					}
				}
			} ] );

		}, 0 );

		state.line = rowStartActual;
		state.rowStartSelect = rowStartSelect;
		state.lineEndSelect = lineEndSelect;
		state.lineLength = _lineLength;
		StateManager.updateURL( state );

		$( '.sourceCode li:not([class*="highlighted"])' ).on( 'click', function() {
			cancelEvent( rowStartActual, lineEndSelect, _lineLength, rowStartSelect, lineInfo, mode, lastCommentText );
		} );
	};



	/**
	 * Construct html for the comment input
	 * @param  {String} _lineInfo						Display info for current selected lines
	 * @param  {String} _inputMarkup				Markup for the check code input
	 * @param  {String} _fileComment				Current comment text
	 * @param  {Boolean} _deleteButtonFlag	Flag to determine if the delete icon should be included
	 * @param  {Boolean} _includeCodeFlag		Flag to determine if the include code check box should be included
	 * @return {String}											HTML Markup for the comment input
	 */
	function constructCommentHTML( _lineInfo, _inputMarkup, _fileComment, _deleteButtonFlag, _includeCodeFlag ) {
		var deleteMarkup = ( _deleteButtonFlag === true ) ? '<button id="removeSubmit" class="pull-right btn btn-fab btn-raised btn-material-red"><i class="fa fa-trash-o"></i><div class="ripple-wrapper"></div></button>' : '';
		var includeCodeMarkup = ( _includeCodeFlag ) ? '' : '<div class="pull-right" style="margin-right:10px"><label>' +
			'<input class=" form-control" type="checkbox" id="includeCode" ' + _inputMarkup +
			'>Include Code</label></div></div>';

		var commentMarkup = '<div class="panel panel-info commentContainer">' +
			'<div class="panel-heading">' +
			'<h3 class="panel-title">' +
			'</h3>' +
			'</div>' +
			'<div style="padding-bottom:0" class="panel-body">' +
			'<div class="list-group">' +
			'<div class="list-group-item">' +
			'<div class="row-action-primary">' +
			'<i style="font-size:25px !important" class="fa fa-pencil">' + '</i>' +
			'</div>' +
			'<div class="row-content">' +
			'<div class="row">' +
			'<div class="col-md-7">' +
			'<h4 class="list-group-item-heading">' +
			_lineInfo +
			'</h4>' +
			'</div>' +
			'<div class="col-md-5">' +
			deleteMarkup +
			'<button id="cancelSubmit" class="pull-right btn btn-fab btn-raised"><i class="mdi-content-clear"></i><div class="ripple-wrapper"></div></button>' +
			'<button id="commentSubmit" class="pull-right btn btn-fab btn-raised btn-material-green"><i class="mdi-navigation-check"></i><div class="ripple-wrapper"></div></button>' +
			includeCodeMarkup +
			'</div>' +
			'<textarea id="commentTextArea" type="text" class="textInput form-control" rows="5" aria-label="...">' +
			_fileComment +
			'</textarea>' +
			'</div>' +
			'</div>' +
			'</div>' +
			'</div>' +
			'</div>';
		return commentMarkup;
	}

	/**
	 * Remove the comment from the dom
	 *
	 * @method  removeEvent
	 *
	 * @param  {number} _rowStartActual Where the comment is located
	 * @param  {number} _lineLength     How many rows the selected comment represent
	 */
	function removeEvent( _rowStartActual, _lineLength, _mode ) {
		var modal = BootStrap.modal( {
			title: '<i class="fa fa-warning"></i> Confirm Delete',
			body: '<p>Procced to delete Comment at line:' + ( ( _mode.file ) ? ' File Level Comment' : ( parseInt( $( '#lineExternal-' + _rowStartActual ).data( 'actualline' ) ) + 1 ) ) + '?</p>' +
				'<p>Warning: This cannot be undone!</p>',
			warning: true
		} );

		modal.confirm( function() {
			keybinder.clearBoundEvents();
			$( '.sourceCode li:not([class*="highlighted"])' ).off( 'click' );
			//Call rpc to save the comment
			util.rpcCall( 'rpc/diff.cfc?METHOD=removeComment&reviewId=' + window.reviewId, {
				_path: $( '#filename' ).html(),
				_line: ( _mode.file ) ? -1 : ( $( '#lineExternal-' + _rowStartActual ).data( 'actualline' ) + 1 ),
			} ).done( function( _response ) {
				if ( _response._success && _response._success === true ) {
					setTimeout( function() {
						BootStrap.notify( {
							labelText: 'Success!',
							supportText: 'Comment Removed.'
						} );
					}, 500 );
					$( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).remove();

					if ( _mode.file ) {
						$( '.displayFileComment' ).remove();
						if ( $( '.displayFileComment.displaymScanComment' ).length > 0 ) {
							$( '#autocount-' + filenameId ).text( parseInt( $( '#autocount-' + filenameId ).text() ) - 1 );
						} else {
							$( '#manualcount-' + filenameId ).text( parseInt( $( '#manualcount-' + filenameId ).text() ) - 1 );
						}
					} else if ( _mode.auto ) {
						$( '#autocount-' + filenameId ).text( parseInt( $( '#autocount-' + filenameId ).text() ) - 1 );
					} else {
						$( '#manualcount-' + filenameId ).text( parseInt( $( '#manualcount-' + filenameId ).text() ) - 1 );
					}
					updateTooltip();

					if ( ( parseInt( $( '#autocount-' + filenameId ).text() ) + parseInt( $( '#manualcount-' + filenameId ).text() ) ) < 1 ) {
						$( '#comment-' + filenameId ).addClass( 'hidden' );
					}

					$( '.commentContainer' ).remove();
					$( 'div.panel.panel-info.displayComment' ).removeClass( 'mini' );
					$( '.sourceCode li' ).removeClass( 'highlighted' );
					$( '.sourceCode li' ).removeClass( 'blurred' );
					$( '.sourceCode li' ).removeClass( 'marked' );

					bindEditorEvents();
					modal.remove();

				} else {
					modal = BootStrap.modal( {
						title: '<i class="fa fa-warning"></i> ' + config.genericErrorHeader,
						body: _response._message || config.genericErrorBody,
						error: true
					} );
				}
			} );
		} );
	}



	/**
	 * Cancel Comment Update
	 *
	 * @method  cancelEvent
	 * @param  {Number} _rowStartActual 	Start of the row, regardless of direction
	 * @param  {Number} _lineEndSelect  	End of Selection, in lines
	 * @param  {Number} _lineLength     	Number of lines of selection
	 * @param  {Number} _rowStartSelect 	Start of Selection, in lines
	 * @param  {String} _lineInfo       	Line Info
	 * @param  {Boolean} _editMode       	Specify if this comment is am edit rather than a display
	 * @param  {Boolean} _mode Mode     	Specify if this comment is updating a previous comment
	 * @param  {String} _comment        	Comment Message
	 */
	function cancelEvent( _rowStartActual, _lineEndSelect, _lineLength, _rowStartSelect, _lineInfo, _mode, _comment, _inputMarkup, _lastInput ) {

		var rowEndActual = ( $( '.externalLine' + '[data-actualline="' + ( parseInt( $( '#lineExternal-' + _rowStartActual ).data( 'actualline' ) ) + ( ( _lineLength ) ? ( _lineLength - 1 ) : 0 ) ) + '"]' ).data( 'line' ) ) + 1;
		var targetElement = ( _mode.auto === true ) ? 'displaymScanComment' : 'displayComment';
		var lastCommentCancel;
		var oldRowStartActual;
		var oldLineEndSelect;
		var oldLineLength;
		var oldRowEndActual;
		var oldRowStartSelect;

		if ( typeof _comment !== 'undefined' ) {
			lastCommentCancel = _comment;
		} else if ( _mode.file === true ) {
			lastCommentCancel = $( '#fileComment' ).html();
		} else {
			lastCommentCancel = $( '#lineExternal-' + _rowStartActual + ' div.displayComment' + ' > div.panel-body > div > div > div.row-content > p' ).html();
		}
		_rowStartActual = parseInt( _rowStartActual );
		_rowStartSelect = parseInt( _rowStartSelect );

		keybinder.clearBoundEvents();

		$( 'div.panel.panel-info' ).removeClass( 'mini' );
		$( ".sourceCode li:not([class*='highlighted'])" ).off( 'click' );

		//rebind the editor events
		bindEditorEvents();

		if ( _mode.file ) {
			$( '.displayFileComment' ).removeClass( 'hidden' );
			$( '.displayFileComment' ).on( 'click', function() {
				addComment( -1 );
			} );
		} else {
			$( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).removeClass( 'hidden' );
			oldRowStartActual = $( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).data( 'rowstartactual' );
			oldRowEndActual = $( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).data( 'rowendactual' );
			oldLineLength = $( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).data( 'linelength' );
			oldLineEndSelect = $( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).data( 'lineendselect' );
			oldRowStartSelect = $( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).data( 'rowstartselect' );

			//Bind actions to the new comment
			$( '#lineExternal-' + _rowStartActual + ' div.displayComment' )
				//Highlight Lines on mouse over
				.on( 'mouseover', function() {
					util.highlightLines( _rowStartActual, oldRowEndActual, true, oldLineLength - 1 );
					//Remove highlights on mouseout
				} ).on( 'mouseout', function() {
					util.highlightLines( _rowStartActual, oldRowEndActual, false, oldLineLength - 1 );
					//Recall addComment if the user click on the comment box to make changes
				} )
				.on( 'click', function() {
					if ( !$( '#lineExternal-' + _rowStartActual ).hasClass( 'blurred' ) ) {
						$( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).off( 'click' );
						$( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).off( 'mouseover' );
						$( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).off( 'mouseout' );
						addComment( oldRowStartSelect, oldLineEndSelect, oldLineLength, lastCommentCancel, {
							auto: _mode.auto || false,
							edit: true
						}, $( '#input-' + _rowStartActual ).val() );
					}
				} );
		}

		//Remove old comment input
		$( '.commentContainer' ).remove();

		$( '.sourceCode li' ).removeClass( 'marked' );

		//Remove highlights
		$( '.sourceCode li' ).removeClass( 'highlighted' );
		$( '.sourceCode li' ).removeClass( 'mlighted' );
		//Remove the blur effect from the rest of content
		$( '.sourceCode li' ).removeClass( 'blurred' );

	}



	/**
	 * Updates the tooltip based on the new comment counts
	 */
	function updateTooltip() {
		var newValue = $( '#manualcount-' + filenameId ).text() + ' Manual & ' + $( '#autocount-' + filenameId ).text() + ' Auto Comments';
		$( '#comment-' + filenameId ).attr( 'data-tooltip', newValue );
	}



	/**
	 * Submit Comment Update
	 *
	 * @method  cancelEvent
	 * @param  {Number} _rowStartActual		Start of the row, regardless of direction
	 * @param  {Number} _lineEndSelect		End of Selection, in lines
	 * @param  {Number} _lineLength				Number of lines of selection
	 * @param  {Number} _rowStartSelect		Start of Selection, in lines
	 * @param  {String} _lineInfo					Line Info
	 */
	function submitEvent( _rowStartActual, _lineEndSelect, _lineLength, _rowStartSelect, _lineInfo, _mode ) {
		var newCommentHTML = '';

		var rowEndActual = ( $( '.externalLine' + '[data-actualline="' + ( parseInt( $( '#lineExternal-' + _rowStartActual ).data( 'actualline' ) ) + ( ( _lineLength ) ? ( _lineLength - 1 ) : 0 ) ) + '"]' ).data( 'line' ) ) + 1;
		keybinder.clearBoundEvents();

		//Get the input value from the comment input
		var inputValue = $( '#commentTextArea' ).val();
		var checkedInput = $( '#includeCode' ).is( ':checked' );
		var deliveryObject;
		var inputMarkup;
		var targetElement = ( _mode.auto === true ) ? 'displaymScanComment' : 'displayComment';

		deliveryObject = {
			_path: $( '#filename' ).html(),
			_comment: inputValue,
			_line: ( _mode.file === true ) ? -1 : ( $( '#lineExternal-' + _rowStartActual ).data( 'actualline' ) + 1 ),
			_length: _lineLength || 1,
			_head: 0,
			_code: checkedInput,
		};

		$( '.sourceCode li:not([class*="highlighted"])' ).off( 'click' );

		//Call rpc to save the comment
		util.rpcCall( 'rpc/diff.cfc?METHOD=saveComment&reviewId=' + window.reviewId, deliveryObject ).done( function( _response ) {
			if ( _response._success && _response._success === true ) {
				BootStrap.notify( {
					labelText: 'Success!',
					supportText: 'Comment Saved.'
				} );
				//rebind the editor events
				bindEditorEvents();

				//Remove highlights
				$( '.sourceCode li' ).removeClass( 'highlighted' );

				newCommentHTML = getNewCommentMarkup( _rowStartActual, rowEndActual, _lineLength, _lineEndSelect, _rowStartSelect, _lineInfo, checkedInput, inputValue, _mode.file );

				if ( $( '#lineExternal-' + _rowStartActual ).has( 'div.displayComment' ).length === 0 && _mode.file !== true ) {
					$( '#comment-' + filenameId ).removeClass( 'hidden' );
					if ( _mode.auto === true ) {
						$( '#autocount-' + filenameId ).text( parseInt( $( '#autocount-' + filenameId ).text() ) + 1 );
						updateTooltip();
					} else {
						$( '#manualcount-' + filenameId ).text( parseInt( $( '#manualcount-' + filenameId ).text() ) + 1 );
						updateTooltip();
					}
				} else if ( ( $( '#lineExternal-' + _rowStartActual ).has( 'div.displayComment' ).length > 0 && _mode.auto === true ) || ( _mode.file === true && $( '.displayFileComment.displaymScanComment' ).length !== 0 ) ) {
					$( '#autocount-' + filenameId ).text( parseInt( $( '#autocount-' + filenameId ).text() ) - 1 );
					$( '#manualcount-' + filenameId ).text( parseInt( $( '#manualcount-' + filenameId ).text() ) + 1 );
					updateTooltip();
				}

				//Added the new comment in its place
				if ( _mode.file ) {
					$( '.displayFileComment' ).remove();
					$( '.commentContainer' ).after( newCommentHTML );
					$( '#fileComment > a' ).on( 'click', function( e ) {
						e.stopPropagation();
					} );

					$( '.displayFileComment' ).on( 'click', function() {
						addComment( -1 );
					} );
				} else {
					//Remove the Old comment, if it exists
					$( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).remove();
					$( '#lineExternal-' + _rowStartActual ).prepend( newCommentHTML );
					$( '#lineExternal-' + rowStartActual + ' div.displayComment' ).find( '#commentText > a' ).on( 'click', function( e ) {
						e.stopImmediatePropagation();
					} );
					rebindEvents( $( '#lineExternal-' + _rowStartActual + ' div.displayComment' ) );
				}

				//Remove old comment input
				$( '.commentContainer' ).remove();

				$( '.sourceCode li' ).removeClass( 'marked' );
				//Remove the blur effect from the rest of content
				$( '.sourceCode li' ).removeClass( 'blurred' );

				//Remove highlights
				$( '.sourceCode li' ).removeClass( 'highlighted' );
				$( '.sourceCode li' ).removeClass( 'mlighted' );

			} else {
				modal = BootStrap.modal( {
					title: '<i class="fa fa-warning"></i> ' + config.genericErrorHeader,
					body: _response._message,
					error: true
				} );

				modal.confirm( function() {
					modal.remove();
				} );
			}

		} );



		/**
		 * Rebinds event to the comment after it has been rerendered in the dom
		 * @method rebindEvents
		 * @param {Object} _displayComment The Dom object for displaying comment
		 */
		function rebindEvents( _displayComment ) {
			_rowStartActual = parseInt( _rowStartActual );

			_displayComment
			//Highlight Lines on mouse over
				.on( 'mouseover', function() {
					util.highlightLines( _rowStartActual, rowEndActual, true, _lineLength - 1 );
					//Remove highlights on mouseout
				} )
				.on( 'mouseout', function() {
					util.highlightLines( _rowStartActual, rowEndActual, false, _lineLength - 1 );
					//Recall addComment if the user click on the comment box to make changes
				} )
				.on( 'click', function( _event ) {
					if ( !$( '#lineExternal-' + _rowStartActual ).hasClass( 'blurred' ) ) {
						$( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).off( 'click' );
						$( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).off( 'mouseover' );
						$( '#lineExternal-' + _rowStartActual + ' div.displayComment' ).off( 'mouseout' );
						addComment( _rowStartSelect, _lineEndSelect, _lineLength, inputValue, {
							auto: false,
							edit: true
						}, ( checkedInput === true ) ? 'true' : 'false' );
					}
				} );
		}
	}



	/**
	 * Markup for rerendering the comment after API call
	 * @param		{Number}	_rowStartActual		First highlighted row non-directional
	 * @param		{Number}	_rowEndActual			Last highlighted row non-directional
	 * @param		{Number}	_lineLength				Number of highlighted lines
	 * @param		{Number}	_lineEndSelect		Last highlighted line
	 * @param		{Number}	_rowStartSelect		First hightlighted row directional
	 * @param		{String}	_lineInfo					Display info for the line output in the comment
	 * @param		{Boolean}	_checkInputFlag		Flag to specify if the Include code check box should be included
	 * @param		{String}	_inputValue				Comment Text
	 * @param		{Boolean} _fileModeFlag			Flag for file mode
	 * @return 	{String}										HTML Markup
	 */
	function getNewCommentMarkup( _rowStartActual, _rowEndActual, _lineLength, _lineEndSelect, _rowStartSelect, _lineInfo, _checkInputFlag, _inputValue, _fileModeFlag ) {
		var headerClass;
		var userIcon;
		var commentContainer;
		var includeCode = '';
		if ( _checkInputFlag === true ) {
			inputMarkup = 'value="true" checked';
			includeCode = '<span class="small">( <i class="fa fa-code"></i> Include Code )</span>';
		} else {
			inputMarkup = 'value="false"';
		}
		if ( _fileModeFlag === true ) {
			headerClass = '<div class="panel panel-info displayFileComment displayComment">';
			userIcon = '<i style="font-size:30px !important" class="glyphicon glyphicon-barcode">';
			commentContainer = '<pre class="commentPre"><p  id="fileComment" class="list-group-item-text">';
		} else {
			headerClass = '<div class="panel panel-info displayComment" data-rowStartActual="' + _rowStartActual + '" data-rowEndActual="' + _rowEndActual + '" data-lineLength="' + _lineLength + '" data-lineEndSelect="' + _lineEndSelect + '" data-rowStartSelect="' + _rowStartSelect + '">';
			userIcon = '<i style="font-size:30px !important">' + window.user;
			commentContainer = '<pre class="commentPre"><p  id="commentText" class="list-group-item-text">';
		}
		return headerClass +
			'<div class="panel-heading" >' +
			'<h3 class="panel-title"></h3>' +
			'</div>' +
			'<div class="panel-body">' +
			'<div class="list-group">' +
			'<div class="list-group-item">' +
			'<div class="row-action-primary">' +
			userIcon +
			'</i>' +
			'</div>' +
			'<div class="row-content">' +
			'<h4 class="list-group-item-heading">' +
			_lineInfo +
			includeCode +
			'</h4>' +
			commentContainer +
			_inputValue +
			'</p></pre>' +
			'<input id="input-' + _rowStartActual + '"class="hidden" type="checkbox" id="includeCode"' + inputMarkup + '>' +
			'</div>' +
			'</div>' +
			'</div>' +
			'</div>' +
			'</div>';
	}



	/**
	 * Bind editor events
	 *
	 * @method  bindEditorEvents
	 */
	function bindEditorEvents() {

		var rowEndSelectCurrent;
		var mouseOverSpecial;
		var i;
		var j;


		$( 'li.externalLine' ).on( 'mouseover', function() {

			if ( isMouseDown === true ) {
				rowEndSelectCurrent = $( this ).closest( '.externalLine' ).data( 'line' );
				if ( $( '#lineExternal-' + rowEndSelectCurrent ).hasClass( 'Removed' ) ) {
					mouseOverSpecial = true;
				} else {
					mouseOverSpecial = false;
				}

				lineEndSelect = $( '#lineExternal-' + rowEndSelectCurrent ).data( 'actualline' );
				$( '.sourceCode li' ).removeClass( 'highlighted' );
				$( '.sourceCode li' ).removeClass( 'marked' );
				$( 'div.panel.panel-info.displayComment' ).removeClass( 'mini' );
				$( 'div.panel.panel-info.displaymScanComment' ).removeClass( 'mini' );
				if ( rowEndSelectCurrent > rowStartSelect ) {
					for ( i = rowStartSelect; i <= rowEndSelectCurrent; i++ ) {

						$( '#lineExternal-' + i ).addClass( 'highlighted' );
						$( '#lineExternal-' + i ).addClass( 'marked' );
						$( '#lineExternal-' + i + ' div.panel.panel-info.displayComment' ).addClass( 'mini' );
						$( '#lineExternal-' + i + ' div.panel.panel-info.displaymScanComment' ).addClass( 'mini' );
					}
				} else if ( rowEndSelectCurrent < rowStartSelect ) {
					for ( j = rowEndSelectCurrent; j <= rowStartSelect; j++ ) {
						$( '#lineExternal-' + j ).addClass( 'highlighted' );
						$( '#lineExternal-' + j ).addClass( 'marked' );
						$( '#lineExternal-' + ( j + 1 ) + ' div.panel.panel-info.displayComment' ).addClass( 'mini' );
						$( '#lineExternal-' + ( j + 1 ) + ' div.panel.panel-info.displaymScanComment' ).addClass( 'mini' );

					}
				}
			}

		} );
		//
		//Remove all previous event listeners
		$( '.externalLine pre' ).off( 'click' ).off( 'mouseover' ).off( 'mouseup' ).off( 'mousedown' );

		$( '.sourceCode pre' )
			//Bind Mouse Down
			.on( 'mousedown', function() {
				rowEndSelectCurrent = $( this ).data( 'line' );
				if ( $( '#lineExternal-' + rowEndSelectCurrent ).hasClass( 'Removed' ) ) {
					isMouseDown = false;
					$( '.sourceCode li' ).removeClass( 'highlighted' );
					$( 'div.panel.panel-info.displayComment' ).removeClass( 'mini' );
				} else if ( isMouseDown === false ) {
					rowStartSelect = $( this ).data( 'line' );
					isMouseDown = true;
					$( this ).closest( 'li' ).addClass( 'highlighted' );
					lineEndSelect = $( '#lineExternal-' + $( this ).data( 'line' ) ).data( 'actualline' );
				}
				return false;
			} )
			//Override Select Start
			.bind( 'selectstart', function() {
				return false;
			} );

		//Bind Mouse Up
		$( document ).on( 'mouseup', function( _event ) {
			if ( isMouseDown === true && mouseOverSpecial !== true ) {

				if ( !$( '#lineExternal-' + rowEndSelectCurrent ).hasClass( 'blurred' ) ) {
					addComment();
				}
			} else if ( mouseOverSpecial === true ) {
				$( '.sourceCode li' ).removeClass( "highlighted" );
				$( '.sourceCode li' ).removeClass( "mini" );
				$( '.sourceCode li' ).removeClass( "marked" );
			}
			isMouseDown = false;
		} );
	}

	$( 'button' ).off( 'mouseup' );
	//Fix for focus issue with tooltip
	$( 'button' ).on( 'mouseup', function() {
		$( this ).blur();
	} );

	if ( typeof window.access === 'boolean' && window.access === true ) {
		bindEditorEvents();
	}

	return {
		addComment: addComment
	};
};