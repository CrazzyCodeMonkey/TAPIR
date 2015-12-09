var util = ( function() {

	var util = this;

	/**
	 * Scroll to top function for tapir Diff
	 */
	function scrollToTop() {
		element = document.getElementById( 'topContent' );
		element.scrollIntoView( {
			block: 'start',
			behavior: 'smooth'
		} );
	}



	/**
	 * Hide Modal
	 * @param  {Object} _$modal Modal Object
	 */
	function hideModal( _$modal ) {
		_$modal.detach();
	}



	/**
	 * Hide and Show message Modal
	 * @param	{Object} 	_$Wrapper					Dom Object of the container
	 * @param	{Object} 	_$Controller			Dom Object of the control
	 * @param	{String} 	_messId						Message Id
	 * @param	{String} 	_mess            	Message
	 * @param	{Function}	_callBackRestore Callback Function
	 */
	function hideShowMessage( _$Wrapper, _$Controller, _messId, _mess, _callBackRestore ) {
		$( _$Wrapper ).slideUp( 300, function() {
			if ( $( '#' + _messId ).length === 0 ) {
				_$Wrapper.after( '<a id="" + _messId + "">' + _mess + '</a>' );

				$( '#' + _messId ).on( 'click', function() {
					_$Controller.val( '' ).trigger( 'change' );
					$( _$Wrapper ).slideDown( 300, function() {
						$( ':input:first', $( this ) ).focus();
					} );
					$( '#' + _messId ).slideUp( 300, function() {
						$( this ).detach();
					} );
					if ( typeof _callBackRestore === 'function' ) {
						_callBackRestore();
					}
				} );
			}
		} );
	}



	/**
	 * Copy To Clipboard
	 * @param  {Object} _$elem Dom Element
	 * @return {Boolean}        Success or fail
	 */
	function copyToClipboard( _$elem ) {
		var $focus = $( ':focus' );
		var bSuccess = false;
		_$elem.select();

		try {
			bSuccess = document.execCommand( 'copy' );
		} catch ( err ) {
			//nothing to do
		}

		//reset the focus
		$focus.focus();
		_$elem.scrollTop( 0 );
		return bSuccess;
	}



	/**
	 * Invokes API call
	 *
	 * @param  {String} _url URL of the api call
	 * @param  {Object} _package  Params packaged into an object
	 * @return {object} promise object
	 */
	function rpcCall( _url, _package ) {

		var d = $.Deferred();

		$.ajax( {
			type: 'POST',
			url: _url,
			data: _package,
			dataType: 'application/json',
			cache: false,
			success: responseHandler,
			error: responseHandler

		} );

		function responseHandler( _response ) {
			var result;
			try {
				result = JSON.parse( _response.responseText );
				if ( typeof result._success === 'boolean' ) {
					d.resolve( result );
				} else {
					d.resolve( responseUnknown( result ) );
				}

			} catch ( _error ) {
				d.resolve( responseUnknown( _response.responseText ) );
			}
		}


		function responseUnknown( _dump ) {
			return {
				_success: false,
				_message: '500 The server responded with an invalid response:' + '<div class="row"><div class="col-md-12">' + _dump + '</div></div>'

			}
		}

		return d.promise();
	}



	/**
	 * add or remove highligh class and mini class to comments
	 *
	 * @method  highlightLines
	 *
	 * @param  {number} _start      Start line that requires highlighting
	 * @param  {number} _end        Last line that requires highlighting
	 * @param  {boolean} _addFlag   Specify if this call was to add or remove highlights
	 * @param  {number} _length     Overrids _end to specify how many lines to highligh
	 * @param  {boolean} _mscanFlag Specify if this is for highlighting mScan
	 */
	function highlightLines( _start, _end, _addFlag, _length, _mscanFlag ) {
		var end = ( _length ) ? _start + ( ( _length === -1 ) ? 0 : _length ) : _end;
		for ( i = _start; i <= end; i++ ) {
			if ( $( '#lineExternal-' + i ).hasClass( 'Removed' ) ) {
				end = end + 1
			}
			//Add Highlights
			if ( typeof _addFlag === 'boolean' && _addFlag === true ) {
				$( '#lineExternal-' + i ).addClass( 'highlighted' );
				//For shrinking highlighted comments
				if ( i > _start ) {
					$( '#lineExternal-' + i + ' div.panel.panel-info.displayComment' ).addClass( 'mini' );
					$( '#lineExternal-' + i + ' div.panel.panel-info.displaymScanComment' ).addClass( 'mini' );
				}
				//Remove Highlights
			} else {
				$( '#lineExternal-' + i ).removeClass( 'highlighted' );
				//For restoring highlighted comments
				if ( i > _start && !$( '#lineExternal-' + i ).hasClass( 'marked' ) ) {
					$( '#lineExternal-' + i + ' div.panel.panel-info.displaymScanComment' ).removeClass( 'mini' );
					$( '#lineExternal-' + i + ' div.panel.panel-info.displayComment' ).removeClass( 'mini' );
				}
			}
		}
	}



	/**
	 * Adds overlay to the darken the body, blurs only the target
	 *
	 * @method  loading
	 * @example util.loading( 'body' );
	 * @param  {String} 	_container      Indentifier for the target container
	 * @param  {Boolean}	_removeFlag   	Flag to remove loading, set to false to remove
	 * @param  {Boolean} 	_siblingsFlag 	Flag to set if the sibling should also be blurred with the target
	 */
	function loading( _container, _removeFlag, _siblingsFlag ) {

		var loadingHTML = '<div class="overlay" >' +
			'<div class="innerContainer">' +
			'<div class="circles-loader">' +
			'</div>' +
			'</div>' +
			'</div>';

		if ( typeof _removeFlag === 'boolean' && _removeFlag === false ) {

			$( '.loading' ).hide();
			$( '.overlay' ).remove();
			$( _container ).removeClass( 'blurred' );
			$( _container ).siblings().removeClass( 'blurred' );
		} else {
			$( _container ).after( loadingHTML );
			$( '.loading' ).show();
			$( _container ).addClass( 'blurred' );
		}
	}



	/**
	 * Generates random guid for used as ids
	 *
	 * @method guid
	 * @return {String} Generated GUID
	 */
	function guid() {



		/**
		 * Generated 4 digit tokens
		 * @return {[type]} [description]
		 */
		function g4() {
			return Math.floor( ( 1 + Math.random() ) * 0x10000 )
				.toString( 16 )
				.substring( 1 );
		}

		return g4() + g4() + '-' + g4() + '-' + g4() + '-' +
			g4() + '-' + g4() + g4() + g4();
	}



	/**
	 * openTreePath
	 *
	 * @param  {String} _path Path of the node to open
	 */
	openTreePath = function( _path ) {

		window.treeTriggerClick = false;

		$( '#jstreeContainer' ).jstree( 'select_node', '#' + _path );

		window.treeTriggerClick = true;
	};



	function showOlderRev( _line ) {
		if ( $( '#updateRevHead-' + _line ).data( 'show' ) !== false ) {
			$( '#updateRevHead-' + _line ).data( 'show', false );
			$( '.updateRev-' + _line ).addClass( 'hidden' );
		} else {
			$( '#updateRevHead-' + _line ).data( 'show', true );
			$( '.updateRev-' + _line ).removeClass( 'hidden' );
		}
	}

	return {
		showOlderRev: showOlderRev,
		loading: loading,
		openTreePath: openTreePath,
		rpcCall: rpcCall,
		highlightLines: highlightLines,
		hideModal: hideModal,
		hideShowMessage: hideShowMessage,
		copyToClipboard: copyToClipboard,
		scrollToTop: scrollToTop
	};

} )();