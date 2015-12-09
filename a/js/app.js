/**
 * App Controller for BootStrap *
 */
var BootStrap = ( function() {
	var app = this;
	var config = {
		genericErrorHeader: 'BootStrap has Exploded!'
	}



	function ajaxCall( _url, _data, _before, _succes, _error, _after, _dataType ) {

		uParams = {
			url: _url,
			data: _data || {},
			method: 'POST',
			dataType: _dataType || 'json',
			beforeSend: _before || null,
			success: _succes,
			error: _error,
			complete: _after || null
		};
		$.ajax( uParams );
	}



	/**
	 * Invokes API call
	 *
	 * @param  {String} _url URL of the api call
	 * @param  {Object} _package  Params packaged into an object
	 * @return {object} promise object
	 */
	function rpcCall( _url, _package, _before, _success, _error, _after, _dataType ) {
		var d = $.Deferred();
		var uParams = {
			type: 'POST',
			url: _url,
			data: _package,
			dataType: 'json',
			complete: _after || null,
			beforeSend: _before || null,
			cache: false,
			success: function( _response ) {
				responseHandler( _response, _success )
			},
			error: function( _response ) {
				responseHandler( _response, _success )
			}
		};

		$.ajax( uParams );



		function responseHandler( _response, _callback ) {
			var responseModal;
			var result;
			if ( _dataType === 'html' ) {
				if ( typeof _response._success === 'boolean' ) {
					if ( _response._success === true && typeof _response.responseText !== 'undefined' ) {
						if ( _callback ) {
							_callback( _response.responseText );
						} else {
							d.resolve( _response.responseText );
						}
					} else {
						responseModal = modal( {
							title: '<i class="fa fa-warning"></i> ' + config.genericErrorHeader,
							body: 'Status: ' + ( _response.status || 500 ) + ',  The server responded with an invalid response:' + '<div class="row"><div class="col-md-12">' + ( _response._message || 'Unknown Server Error' ) + '</div></div>',
							error: true
						} );

						responseModal.confirm( function() {
							responseModal.remove();
						} );
					}
				} else if ( _response.status === 200 ) {
					if ( _callback ) {
						_callback( _response.responseText );
					} else {
						d.resolve( _response.responseText );
					}
				} else {
					responseModal = modal( {
						title: '<i class="fa fa-warning"></i> ' + config.genericErrorHeader,
						body: 'Status: ' + ( _response.status || 500 ) + ',  The server responded with an invalid response:' + '<div class="row"><div class="col-md-12">' + _response.responseText + '</div></div>',
						error: true
					} );

					responseModal.confirm( function() {
						responseModal.remove();
					} );
				}
			} else if ( _dataType === 'json' ) {
				try {
					result = JSON.parse( _response.responseText );
					if ( typeof result._success === 'boolean' ) {
						if ( _callback ) {
							_callback( result );
						} else {
							d.resolve( result );
						}
					} else {
						if ( _callback ) {
							_callback( responseUnknown( result ) );
						} else {
							d.resolve( responseUnknown( result ) );
						}
					}

				} catch ( _error ) {
					if ( _callback ) {
						_callback( responseUnknown( _response.responseText ) );
					} else {
						d.resolve( responseUnknown( _response.responseText ) );

					}
				}
			} else {
				if ( _callback ) {
					_callback( _response );
				} else {
					d.resolve( _response );
				}
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



	function logout() {
		var responseModal = modal( {
			title: '<i class="fa fa-warning"></i> Confirm Logout',
			body: 'Are you sure you want to Logout?',
			warning: true
		} );

		responseModal.confirm( function() {
			notify( {
				labelText: 'Logout',
				supportText: 'You have Logged out.',
				timer: 1000,
				done: function() {
					window.location.href = '?logout';
				}
			} );
			responseModal.remove();
		} );
	}

	/**
	 * Creates a simple modal using javascript
	 *
	 * @method  modal
	 * @example util.modal( { title : 'title', body : 'body', footer 'footer', warning: true } ); // Warning modals
	 * @param  {Object} _paramsObject Paramobject containing title, body, footer
	 * @return {Object} uuid for the id to this modal in the format 'modal-'+uuid, remove() to remove modal, confirm to add a function to event for the click button
	 */
	function modal( _paramsObject ) {
		var modal = {};
		var uuid = guid();
		var container;
		var title = 'title';
		var body = 'body';
		var footer = '';
		var warning = false;
		var error = false;
		var info = false;



		modal.confirm = function() {
			customAlert( '#modal-' + uuid + ' > div > div > div.modal-footer', {
				title: 'Developer Error',
				body: 'No Confirm Action Defined!'
			} );
		};



		modal.cancel = function() {
			$( '#modal-' + uuid ).modal( 'hide' );
		};

		if ( typeof _paramsObject !== 'undefined' ) {
			title = _paramsObject.title || title;
			body = _paramsObject.body || body;
			warning = _paramsObject.warning || warning;
			modal.confirm = _paramsObject.confirm || modal.confirm;
			modal.cancel = _paramsObject.cancel || modal.cancel;
			error = _paramsObject.error || error;
			info = _paramsObject.info || info;
		}

		var modalHTML = '<div class="modal fade utilModal" id="modal-' + uuid + '" data-toggle="modal" data-target="#myModal">' +
			'<div class="modal-dialog" >' +
			'<div class="modal-content" >' +
			'<div class="modal-header ' + ( ( warning === true || error === true ) ? 'customWarning' : '' ) + ' ' + ( ( info === true ) ? 'customInfo' : '' ) + '">' +

			'<button type="button" class="close" data-dismiss="modal" aria-label="Close">' +
			'<span aria-hidden = "true" >&times;</span>' +
			'</button>' +
			'<h3 class = "modal-title" >' + title + '</h3>' +
			'</div>' +
			'<div class = "modal-body">' +
			'<p>' + body + '</p>' +
			'</div>' +
			'<div class = "modal-footer" >' + footer + ( ( error === true ) ? '<button class="btn btn-raised" id="confirmAction-' + uuid + '">Ok</button>' : '' ) + ( ( warning === true ) ? '<button class="btn btn-default customWarning btn-raised" id="confirmAction-' + uuid + '">Confirm</button>' +
				'<button class="btn btn-raised" id="cancelAction-' + uuid + '">Cancel</button>' : '' ) + '</div>' +
			'</div>' +
			'</div>' +
			'</div>';

		container = $( 'body' );
		$( container ).append( modalHTML );
		$( '#modal-' + uuid ).modal( 'show' );
		$( '#modal-' + uuid ).on( 'hidden.bs.modal', function() {
			$( '#modal-' + uuid ).remove();
		} )

		if ( warning === true || error === true ) {
			$( '#confirmAction-' + uuid ).on( 'click', function() {
				modal.confirm();
			} );
		}

		if ( warning === true ) {
			$( '#cancelAction-' + uuid ).on( 'click', function() {
				modal.cancel();
			} );
		}



		function remove() {
			$( '#modal-' + uuid ).modal( 'hide' );
			setTimeout( function() {
				$( '#modal-' + uuid ).remove();
			}, 500 );

		}



		function setConfirm( _callback ) {
			modal.confirm = _callback;
		}
		return {
			uuid: uuid,
			remove: remove,
			confirm: setConfirm
		};
	};



	/**
	 * Adds a alert to after an element
	 *
	 * @method customAlert
	 *
	 * @method  customAlert
	 * @example BootStrap.customAlert( '.modal-footer', { title : 'title', body : 'body', footer 'footer' } );
	 * @param  {String} _container    Indentifier for the target container, the alert will go after the target
	 * @param  {Object} _paramsObject Paramobject containing title, body, footer
	 * @return {[type]}               [description]
	 */
	function customAlert( _container, _paramsObject ) {

		var uuid = guid();
		var title = 'title';
		var body = 'body';
		var footer = '';
		var alertHTML;

		if ( typeof _paramsObject !== 'undefined' ) {
			title = _paramsObject.title || title;
			body = _paramsObject.body || body;
			footer = _paramsObject.footer || footer;
		}

		alertHTML = [
			'<div style="margin-bottom:0;word-wrap:break-word" class="alert alert-danger alert-dismissible fade in" id="alert-' + uuid + '" role="alert">',
			'<button type="button" id="alertButton-' + uuid + '" class="close" data-dismiss="alert" aria-label="Close">',
			'<span aria-hidden="true">×</span></button>',
			'<h4>' + title + '</h4>',
			'<p>' + body + '</p>',
			'<p>' + footer + '</p>',
			'</div>'
		];

		$( _container ).after( alertHTML.join( '' ) );

		setTimeout( function() {
				$( '#alert-' + uuid ).animate( {
					opacity: 0.5,
				}, 1000, function() {
					$( '#alert-' + uuid ).remove();
				} );

			},
			2000 );
		$( '#alertButton-' + uuid ).on( 'click', function() {
			$( '#alert-' + uuid ).remove();
		} );
	}



	/**
	 * Notification object
	 *
	 * @param {[type]} _params_object [description]
	 */
	app.Notification = function( _params_object ) {

		this.$notification = {};

		var notification = this;
		var notification_height = 70;
		var $notificationAction = {};
		var $notificationDismiss = {};
		var supportText = '';
		var notificationDone;

		/* initialize notification */
		notification.init = function() {
			notification.done = _params_object.done || notification.removeNotification;
			notification.path = ( _params_object.path ? _params_object.path : '/rpc/bootstrap.cfc?method=notification&reviewId=' + window.reviewId );
			notification.compile();
		}



		/**
		 * generate notification
		 *
		 * @method compile
		 */
		notification.compile = function() {

			supportText = _params_object.supportText.length > 65 ? _params_object.supportText.substring( 0, 65 ) + '...' : _params_object.supportText;

			$.post( notification.path, {
				_labelText: _params_object.labelText,
				_supportText: supportText,
				_actionText: _params_object.actionText
			}, function( _response ) {
				notification.$notification = $( _response );
				$notificationAction = notification.$notification.find( '.notification-action' );
				$notificationDismiss = notification.$notification.find( '.notification-dismiss' );
				$( 'body' ).prepend( notification.$notification ); // TODO: disassociate hq-main
				notification.placeNotifications();

				setTimeout( function() { // TODO: way to avoid setTimeout? callback in placeNotifications?
					notification.$notification.removeClass( 'hq-notification_awaiting-translation-into-view' );
				}, 150 );

				$notificationAction.on( 'click', function() {
					if ( _params_object.action ) {
						_params_object.action();
					}
					notification.removeNotification();
					// TODO (later on if use case presents itself) provide call back for dismiss
				} );

				$notificationDismiss.on( 'click', function() {
					notification.removeNotification();
				} );

			} );
		}



		/**
		 * reposition notifications based on current stack
		 *
		 * @method placeNotifications
		 */
		notification.placeNotifications = function() {
			var notification_from_bottom = 5;
			$( '.hq-notification' ).each( function( index ) {
				$( this ).css( {
					'bottom': notification_from_bottom + 'px',
					'height': notification_height + 'px'
				} );
				notification_from_bottom += notification_height;
			} );
		}



		/**
		 * dismiss notification
		 *
		 * @method removeNotification
		 * @params {Object} _this_component: instance of notification
		 */
		notification.removeNotification = function() {
			notification.$notification.addClass( 'hq-notification_remove-notification' ).one( 'webkitTransitionEnd transitionend', function() {
				notification.done();
				notification.$notification.remove();
				notification.placeNotifications();
			} );
		}
		setTimeout( function() {
			notification.removeNotification();
		}, _params_object.timer || 3000 );
		notification.init();
	};



	/**
	 * create instance of notification
	 *
	 * @method notify
	 * @params {Object} _params_object: contains 'labelText', 'supportText', 'actionText' (optional IF NOTIFICATION HAS NO ACTION) and an 'action' callback
	 * @return {Object} instnace of notification
	 */
	function notify( _paramsObject ) {
		return new app.Notification( _paramsObject );
	};



	/**
	 * Allows drag resizing of an dome elemenet
	 *
	 * @param {String} _item   dom label for the elemenet
	 * @param {Object} _config Config JSON
	 */
	app.Resizer = function( _item, _config ) {

		var resizeItem = $( _item );
		var resizer = $( _config.resizeElement );
		var onResize = _config.onResize || function() {
			return false;
		};
		var originalWidth = resizeItem.width();
		var startX;
		var startY;
		var startWidth;
		var startHeight;
		var startXMargin = resizeItem.css( 'margin-left' );
		var oppositeElement = $( _config.oppositeElement );
		var startWidthO;
		var originalWidthO = oppositeElement.width();

		resizer.on( 'mousedown', initDrag );



		/**
		 * Fire off on initalize of a drag event
		 * @param  {Object} e Event Object
		 */
		function initDrag( e ) {
			startX = e.clientX;
			startY = e.clientY;
			startWidthO = oppositeElement.width();
			startWidth = resizeItem.width();
			startHeight = resizeItem.height();
			$( document ).on( 'mousemove', doDrag );
			$( document ).on( 'mouseup', stopDrag );
		}



		/**
		 * Action to take when the mouse is being dragged
		 * @param  {Object} e Event Object
		 */
		function doDrag( e ) {
			StateManager.setKey( 'dragging', true );
			if ( _config.resizeX === true ) {
				if ( _config.Xfrom.toLowerCase() === 'left' ) {
					resizeItem.css( 'width', ( startWidth - e.clientX + startX ) + 'px' );
					oppositeElement.css( 'width', ( startWidthO + e.clientX - startX - 1 ) + 'px' );
				} else if ( _config.Xfrom.toLowerCase() === 'right' ) {
					if ( ( startWidth - e.clientX + startX ) > originalWidth ) {
						resizeItem.css( 'width', ( startWidth + e.clientX + startX ) - 'px' );
					}
				} else {
					resizeItem.css( 'width', originalWidth );
				}
			}
			if ( _config.resizeY === true ) {
				if ( _config.Yfrom.toLowerCase() === 'up' ) {
					resizeItem.css( 'height', ( startHeight + e.clientY - startY ) + 'px' );
				} else if ( _config.Yfrom.toLowerCase() === 'down' ) {}
			}
		}



		/**
		 * Action to take when the mouse is up, after the drag event has completed
		 * @param  {Object} e Event Object
		 */
		function stopDrag( e ) {
			onResize( resizeItem.width() );
			if ( ( startWidth - e.clientX + startX ) > originalWidth - 1 ) {
				resizeItem.css( 'width', originalWidth );
				oppositeElement.css( 'width', originalWidthO - 1 );
			} else if ( ( startWidth - e.clientX + startX ) < ( originalWidth * .25 ) - 1 ) {
				resizeItem.css( 'width', originalWidth * .25 );
				oppositeElement.css( 'width', ( originalWidthO + originalWidth * .75 ) - 1 );
			}
			$( document ).off( 'mousemove', doDrag );
			$( document ).off( 'mouseup', stopDrag );
			setTimeout( function() {
				StateManager.setKey( 'dragging', false );
			}, 0 )
		}

	}



	/**
	 * Public function to construct a resizer component
	 *
	 * @param 	{String} _item   	dom label for the elemenet
	 * @param 	{Object} _config 	Config JSON
	 * @return 	{Object}					Instance of the resizer
	 */
	function resizeable( _id, _configObject ) {
		return new app.Resizer( _id, _configObject );
	};



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



	function init() {
		return {
			resizeable: resizeable,
			notify: notify,
			logout: logout,
			customAlert: customAlert,
			modal: modal,
			rpcCall: rpcCall,
			ajaxCall: ajaxCall
		};
	}

	return init();

} )()