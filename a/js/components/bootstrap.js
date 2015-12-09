/**
	* Bootstrap component *
	*/

var component = component || {};

component.bs = function() {

	var bootStrap = this;

	function modalLoad( _sUrl, _uData, _fnCallBack ) {
		var $modal = null;
		var oModal = null;
		var oTicker = null;

		function fnLoadModal( _response ) {
			$( "#dynamicModal" ).append( _response );

			var $modal = $( ".modal" );
			var oModal = $modal.modal( {
				keyboard: true,
				show: true,
				backdrop: true
			} );

			$modal.on( "click", "[data-dismiss]", function( e ) {
				$( this ).closest( ".modal" ).remove();
				$( ".modal-backdrop" ).remove();
			} );

			if ( typeof _fnCallBack === "function" ) {
				_fnCallBack();
			}

			return oModal;

		}

		function fnError( _jqXHR, _text, _error ) {
			clearInterval( oTicker );
			alert( _error );
		}

		function fnfriendlyReminder() {
			oTicker = setTimeout( function() {
				alert( "Please be patient, we are trying to load stuff" );
				fnfriendlyReminder();
			}, 5000 );
		}

		function fnDone() {
			clearInterval( oTicker );
		}

		if ( $( "#dynamicModal" ).length == 0 ) {
			$( "body" ).append( $( "<div id='dynamicModal'></div>" ) )
		} else if ( $( "#dynamicModal .modal" ).length > 0 ) {
			$( "#dynamicModal .modal .close" ).trigger( "click" );
		}

		BootStrap.rpcCall( _sUrl, _uData, fnfriendlyReminder, fnLoadModal, fnError, fnDone, "html" );

		return $( "#dynamicModal" )

	};

	function alertCreate( _sMessage, _sType, _bClose, _$ref, _sWhere, _fnCallBack ) {
		_$ref = _$ref || $( "body" );
		var oAlert = null;
		var $alert = $( "<div></div>" ).addClass( "alert" )
			.addClass( "alert-" + _sType )
			.attr( "role", "alert" );
		if ( _bClose ) {
			$alert.append( $( '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>' ) );
		}

		$alert.append( _sMessage );

		if ( _sWhere == "after" ) {
			_$ref.after( $alert );
		} else if ( _sWhere == "before" ) {
			_$rev.before( $alert )
		} else if ( _sWhere == "append" || !_sWhere ) {
			_$ref.append( $alert );
		}

		return $alert.alert();
	}

	function alertDismiss( _$alert ) {
		_$alert.detach();
	}

	return {
		modalLoad: modalLoad,
		alertCreate: alertCreate,
		alertDismiss: alertDismiss
	};

}