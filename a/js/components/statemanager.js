	/**
	 * State Manager
	 *
	 * @class  StateManager
	 *
	 */
	var StateManager = ( function() {

		//Array of states for used as a stack, it's like a time machine! except it isn't because its not working right now
		var timeMachine = [];
		var state = window.urlParams || {};
		var urlString = window.location.href;
		var urlStringArray = urlString.split( '?' );

		var stackDifference = 0;

		//Restrict the list state properties shown in the url,
		var displayParams;
		var changeState;
		var label;



		/**
		 * Set the state and fire off events depend on the flag
		 *
		 * @method setState
		 * @param {Object} 	_state               State Object
		 * @param {Boolean} _noPushToTimeMachine Prevents pushing state to the time machine
		 * @param {Boolean} _noUpdateURL         Prevents replacing the url
		 * @param {Boolean} _noUpdateState       Prevente updating the state Object
		 * @param {Boolean} _noChangeState       Prevents kicking off change state function
		 */
		function setState( _state, _noPushToTimeMachine, _noUpdateURL, _noUpdateState, _noChangeState ) {

			var hrefArray = [];



			/**
			 * Matches the state _key with the label, if they match push it to the hrefArray
			 *
			 * @method  matchStateToDisplayName
			 * @param  {String} _key Key of the state to be matched
			 */
			function matchStateToDisplayName( _key ) {
				if ( _key === label ) {
					hrefArray.push( label + '=' + _state[ label ] );
				}
			}

			//Update the state Object
			if ( typeof _noUpdateState === 'undefined' || ( typeof _noUpdateState !== 'undefined' && _noUpdateState !== true ) ) {
				state = _state;
			}

			//update the url array if they match the list of displayParams
			for ( label in _state ) {
				displayParams.forEach( matchStateToDisplayName );
			}

			if ( typeof _fromBackNavigation === 'undefined' || ( typeof _fromBackNavigation !== 'undefined' && _fromBackNavigation !== true ) ) {
				timeMachine.push( $.extend( true, {}, _state ) );
			} else {
				if ( stackDifference < 0 ) {
					stackDifference++;
				}
			}

			if ( typeof _noUpdateURL === 'undefined' || ( typeof _noUpdateURL !== 'undefined' && _noUpdateURL !== true ) ) {
				window.history.replaceState( {}, document.title, '?' + hrefArray.join( '&' ) );
			}

			if ( typeof _noChangeState === 'undefined' || ( typeof _noChangeState !== 'undefined' && _noChangeState !== true ) ) {
				changeState();
			}
			// window.location.href = _state.urlAddress + '?' + hrefArray.join( '&' );
		}



		/**
		 * Alias function for setting flags to only update URL, easier to read
		 *
		 * @method  updateURL
		 * @param  {Object} _state State Object
		 */
		function updateURL( _state ) {
			setState( _state, true, false, true, true );
		}



		/**
		 * Alias function for updating the URL and State
		 *
		 * @method  updateURLAndState
		 * @param  {Object} _state State Object
		 */
		function updateURLAndState( _state ) {
			setState( _state, true, false, false, true );
		}



		/**
		 * Back functionality for go back to previous State (Not Ready)
		 *
		 * @method  goBack
		 */
		function goBack() {
			if ( timeMachine.length > 1 ) {
				var lastState;
				if ( stackDifference === 0 ) {
					timeMachine.pop();
					lastState = timeMachine.pop();
					timeMachine.push( $.extend( true, {}, lastState ) );
					stackDifference = stackDifference - 1;
				} else {
					lastState = timeMachine.pop();
				}

				setState( lastState, true );
			}

		}



		/**
		 * Retrieves a value from the state based on key
		 *
		 * @method  getKey
		 * @param  {String} _itemName Key Name
		 * @return {String}           Value of the Key
		 */
		function getKey( _itemName ) {
			return state[ _itemName ];
		}



		/**
		 * Returns the state object
		 *
		 * /method getState
		 * @return {Object} State Object
		 */
		function getState() {
			return state;
		}



		/**
		 * Set a key in the state
		 * @param {String} _itemName  Key Name
		 * @param {String} _itemValue Value of the key specified
		 */
		function setKey( _itemName, _itemValue ) {
			state[ _itemName ] = _itemValue;
		}



		/**
		 * Kick off
		 * @param  {Array} _displayParams Array of string, containing a list of param to direct which key to use in the state
		 * @param  {Function} _stateChange   State Change function activate on setState
		 */
		function init( _displayParams, _stateChange ) {

			var urlArray;

			//Store a reference to the app state change
			changeState = _stateChange;
			displayParams = _displayParams;

			//Get new state variables from the URL string
			if ( typeof urlStringArray[ 1 ] !== 'undefined' ) {
				urlArray = urlStringArray[ 1 ].split( '&' );
				state.urlAddress = urlStringArray[ 0 ];

				urlArray.forEach( function( item ) {
					itemArray = item.split( '=' );
					state[ itemArray[ 0 ] ] = itemArray[ 1 ] || '';
				} );
			}
		}

		return {
			updateURLAndState: updateURLAndState,
			updateURL: updateURL,
			init: init,
			getKey: getKey,
			getState: getState,
			setKey: setKey,
			changeState: changeState,
			setState: setState,
			goBack: goBack
		};
	} )();