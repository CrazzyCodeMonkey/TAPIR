/**
 * Event Manager for providing event handlers to the app
 *
 * @class  EventManager
 */
var EventManager = ( function() {

	var lastNode = '';
	var index = 0;



	/**
	 * Bind Actions onto the tree, whhen clicking on a tail node that has a file
	 *
	 * @method  bindTreeNodes
	 *
	 * @param  {Object} e    Event Object
	 * @param  {Object} data Data Object form the tree node
	 */
	function bindTreeNodes( e, data ) {

		var path;
		var state;

		//Check if there is 0 child nodes preform procceding
		if ( data.node.children.length === 0 ) {
			//Checks if a new node is chlicked
			if ( data.node.id.toString() !== StateManager.getKey( 'file' ) || ( ( data.node.id.toString() === StateManager.getKey( 'file' ) ) && StateManager.getKey( 'inspecting' ) === false ) ) {

				path = data.instance.get_path( data.node, '/' );
				lastNode = StateManager.getKey( 'file' );
				state = StateManager.getState();
				state.file = data.node.id.toString();
				delete state.rowStartSelect;
				delete state.lineEndSelect;
				delete state.lineLength;
				state.line = 0;
				state.inspecting = true;
				StateManager.setState( state );

			}
		}
	}



	/**
	 * Bind Event to the Search Button
	 *
	 * @method  bindSearch
	 */
	function bindSearch() {



		/**
		 * Test if a number is a an positive integer with no leading zeros
		 * @param  {string}  str String that is tested
		 * @return {Boolean}     Result fo the test
		 */
		function isPosInt( str ) {
			return /^\+?(0|[1-9]\d*)$/.test( str );
		}

		$( 'nav' ).on( 'click', '[data-modal]', function( e ) {
			e.preventDefault();
			var uData = {};
			if ( $( this ).is( '[data-data]' ) ) {
				uData = JSON.parse( $( this ).attr( 'data-data' ) );
			}
			app.boot.modalLoad( $( this ).attr( 'data-modal' ), uData );
		} );

		$( 'body' ).on( 'click', '#dynamicModal #submitInput', function( e ) {
			var uData = {};
			var sAction = '';
			var bError = false;
			util.loading( '.modal-content' );
			if ( $( this ).is( '[data-data]' ) ) {
				uData = JSON.parse( $( this ).attr( 'data-data' ) );
			} else {
				$( '#dynamicModal form :input' ).each( function() {

					//Define Required Validation
					if ( $( this ).is( '[data-required="true"' ) && $( this ).val() === '' ) {
						util.loading( '.modal-content', false );
						BootStrap.customAlert( $( '.modal-footer' ), {
							title: 'Required field',
							body: '<strong>' + $( this ).closest( '.form-group' ).find( 'label' ).text() + '</strong> is a required field'
						} );
						bError = true;
					}
					uData[ this.name ] = $( this ).val();

					//Define Numeric Validation
					if ( $( this ).data( 'validation' ) === 'numeric' && !isPosInt( $( this ).val() ) ) {
						util.loading( '.modal-content', false );
						BootStrap.customAlert( $( '.modal-footer' ), {
							title: 'Invalid Type',
							body: '<strong>' + $( this ).closest( '.form-group' ).find( 'label' ).text() + '</strong> is not a position integer'
						} );
						bError = true;
					}

					//Define String Length Validation
					if ( typeof $( this ).data( 'length' ) !== 'undefined' && ( $( this ).data( 'length' ) !== $( this ).val().length ) ) {
						util.loading( '.modal-content', false );
						BootStrap.customAlert( $( '.modal-footer' ), {
							title: 'Invalid Length',
							body: '<strong>' + $( this ).closest( '.form-group' ).find( 'label' ).text() + '</strong> has to be of length ' + $( this ).data( 'length' )
						} );
						bError = true;
					}
				} );
			}
			if ( !bError ) {

				if ( $( this ).is( '[data-modal]' ) ) {

					sAction = $( this ).attr( 'data-modal' );
					if ( sAction == 'true' ) {
						sAction = $( '#dynamicModal form' ).attr( 'action' );
					}
					app.boot.modalLoad( sAction, uData );
				} else if ( $( this ).is( '[data-reload]' ) ) {
					sAction = $( this ).attr( 'data-reload' );
					if ( sAction == 'true' ) {
						sAction = $( '#dynamicModal form' ).attr( 'action' );
					}

					BootStrap.rpcCall( sAction, uData ).done( function( _response ) {

						if ( _response._success ) {
							location.reload();
						} else {
							util.loading( '.modal-content', false );
							BootStrap.customAlert( $( '.modal-footer' ), {
								title: 'Something went Seriously Wrong!',
								body: ( ( typeof _response._message === 'string' ) ? _response._message : JSON.stringify( _response ) )
							} );
						}
					} );
				} else if ( $( this ).is( '[data-location]' ) ) {
					sAction = $( this ).attr( 'data-location' );
					if ( sAction == 'true' ) {
						sAction = $( '#dynamicModal form' ).attr( 'action' );
					}
					BootStrap.rpcCall( sAction, uData ).done( function( _response ) {
						if ( _response._success ) {
							location = _response.location;
						} else {
							util.loading( '.modal-content', false );
							BootStrap.customAlert( $( '.modal-footer' ), {
								title: 'Something went Seriously wrong!',
								body: ( ( typeof _response._message === 'string' ) ? _response._message : JSON.stringify( _response ) )
							} );
						}
					} );
				}
			}

		} ).on( 'click', '#dynamicModal [data-togglediv]', function( e ) {
			$( $( this ).attr( 'data-togglediv' ) ).toggle();
			$( this ).toggle();
		} ).on( 'change', '#dynamicModal #repo', function() {
			$( '#repoStart' ).val( $( 'option:selected', $( this ) ).attr( 'data-head' ) ).trigger( 'change' );
		} ).on( 'click', '[data-copy]', function() {
			var sMessage = 'ERROR';
			var sType = 'danger';
			if ( util.copyToClipboard( $( $( this ).attr( 'data-copy' ) ) ) ) {
				sMessage = 'Review copied to clipboard';
				sType = 'success';
			} else {
				sType = 'warning';
				sMessage = 'Unable to copy content<br />Please use manual copy process.';
			}
			if ( $( this ).is( '[data-confirm]' ) && $( $( this ).attr( 'data-confirm' ) ).length > 0 ) {
				$( '.modal-footer' ).append( '<div class="alert alert-' + sType + '" role="alert">' + sMessage + '</div>' );
				setTimeout( function() {
					$( '.alert' ).slideUp( 300, function() {
						$( this ).detach();
					} );
				}, 1500 );
			}
		} );
	}


	/**
	 * bind events for the dashboard
	 */

	function bindDashboard() {
		$( '#dashboard' ).on( 'click', '.submitInput', function( e ) {
			var uData = {};
			var sAction = '';

			if ( $( this ).is( '[data-data]' ) ) {
				uData = JSON.parse( $( this ).attr( 'data-data' ) );
			} else {
				$( '#dynamicModal form :input' ).each( function() {
					uData[ this.name ] = $( this ).val();
				} );
			}

			if ( $( this ).is( '[data-modal]' ) ) {
				sAction = $( this ).attr( 'data-modal' );
				if ( sAction == 'true' ) {
					sAction = $( '#dynamicModal form' ).attr( 'action' );
				}
				app.boot.modalLoad( sAction, uData );
			} else if ( $( this ).is( '[data-reload]' ) ) {
				sAction = $( this ).attr( 'data-reload' );
				if ( sAction == 'true' ) {
					sAction = $( '#dynamicModal form' ).attr( 'action' );
				}
				BootStrap.rpcCall( sAction, uData ).done( function( _response ) {

					if ( _response._success ) {
						location.reload();
					} else {
						alert( _response._message );
					}
				} );
			} else if ( $( this ).is( '[data-location]' ) ) {
				sAction = $( this ).attr( 'data-location' );
				if ( sAction == 'true' ) {
					sAction = $( '#dynamicModal form' ).attr( 'action' );
				}
				BootStrap.rpcCall( sAction, uData ).done( function( _response ) {

					if ( _response._success ) {
						location = _response.location;

					} else {
						alert( _response._message );
					}
				} );
			}

		} ).on( 'click', '[data-parent]', function( e ) {
			e.preventDefault();
			var oColor = ( index <= 5 ? index * 51 : 256 );
			index++;
			var $row = $( '#' + $( this ).attr( 'data-parent' ) + ' td' );
			$row.css( {
				'background': 'rgba(' + oColor + ',256,' + oColor + ',.5)'
			} );
			$( '[data-parent]', $row ).trigger( 'click' );
			setTimeout( function() {
				index = 0;
				$row.css( {
					'background': '#fff'
				} );
			}, 2000 );
		} ).on( 'click', '[data-child]', function( e ) {
			e.preventDefault();
			var oColor = ( index <= 5 ? index * 51 : 256 );
			index++;
			var $row = $( '#' + $( this ).attr( 'data-child' ) + ' td' );
			$row.css( {
				'background': 'rgba(' + oColor + ',256,' + oColor + ',.5)'
			} );
			$( '[data-child]', $row ).trigger( 'click' );
			setTimeout( function() {
				index = 0;
				$row.css( {
					'background': '#fff'
				} );
			}, 2000 );
		} );
	}



	/**
	 * Bind Events to the slider panel
	 *
	 * @method  bindSlinder
	 */
	function bindSlider() {
		var state = StateManager.getState();
		$( '#expandSlider' ).on( 'mousedown', function() {
			var time = new Date();
			//Expands the slider and swap out the resize buttons
			$( window ).off( 'mouseup' );
			$( window ).on( 'mouseup', function() {
				var diff = new Date() - time;
				if ( diff < 150 ) {
					if ( state.expandSlider !== true ) {
						StateManager.setKey( 'sliderSize', $( '.cd-panel-container' ).width() );
						//Update state but doesnt change state
						state.inspecting = true;
						state.expandSlider = true;
						StateManager.updateURLAndState( state );
						$( '#expandSlider > i ' ).removeClass( 'fa-chevron-left' );


						$( '.cd-panel-container' ).animate( {
							width: '100%'
						}, 300, function() {
							setTimeout( function() {
								$( '#expandSlider > i ' ).addClass( 'fa-chevron-right' );

							}, 0 );
						} );


						//Shrinks the slider and swap out the resize buttons
					} else {
						if ( ( $( '.cd-panel-container' ).width() < ( $( window ).width() * 0.75 ) - 1 ) ) {

							removeSlider();
						} else {
							StateManager.setKey( 'sliderSize', $( '.cd-panel-container' ).width() );
							//Update state but doesnt change state
							state.inspecting = true;
							state.expandSlider = false;
							StateManager.updateURLAndState( state );
							$( '#expandSlider > i ' ).removeClass( 'fa-chevron-right' );
							$( '.cd-panel-container' ).animate( {
								width: '75%'
							}, 300, function() {
								setTimeout( function() {
									$( '#expandSlider > i ' ).addClass( 'fa-chevron-left' );

								}, 0 );
							} );
						}

					}
				}
			} );
		} );



		//Removes the slider
		$( '#removeSlider' ).on( 'click', function() {
			removeSlider();
		} );

		function removeSlider() {
			if ( typeof state.file !== 'undefined' ) {
				StateManager.setKey( 'sliderSize', $( '.cd-panel-container' ).width() );
				$( '.cd-panel' ).removeClass( 'is-visible' );
				setTimeout( function() {
					$( '.cd-panel-container' ).css( 'width', ( typeof StateManager.getKey( 'sliderSize' ) !== 'undefined' ) ? StateManager.getKey( 'sliderSize' ) + 'px' : '75%' );
					$( '#expandSlider > i ' ).addClass( 'fa-chevron-left' );
					$( '#expandSlider > i ' ).removeClass( 'fa-chevron-right' );
				}, 500 );

				//Update state but doesnt change state
				state.inspecting = false;
				state.expandSlider = false;
				StateManager.updateURLAndState( state );
			}
		}
	}



	/**
	 * Expose the last tree node loaded accessed
	 *
	 * @method  getLastTreeNode
	 * @return {String} The value of the last node's id
	 */
	function getLastTreeNode() {
		return lastNode;
	}



	/**
	 * Clears the last note reference
	 *
	 * @method  clearLastTreeNode
	 */
	function clearLastTreeNode() {
		lastNode = '';
	}



	/**
	 * Kick off eventManager
	 *
	 * @method  init
	 */

	function init() {
		bindSearch();
		bindSlider();
		bindDashboard();
	}

	init();

	return {
		bindTreeNodes: bindTreeNodes,
		getLastTreeNode: getLastTreeNode,
		clearLastTreeNode: clearLastTreeNode
	};

} )();