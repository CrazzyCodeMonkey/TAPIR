/**
 * $Id: keybinder.js 22748 2015-10-27 18:51:42Z llee $
 */

/**
 * Components
 *
 * @module component
 */
var component = component || {};



/**
 * Keybinder component, adds keybind to apps
 *
 * @class  Keybinder
 *
 * @param {Array} _keybinds Bind mutliple/single keybind(s)
 * @example
 *
 * 	1) Bind multiple keybinds with a Array keycombo at init
 *  var keybinds =  new component.Keybinder( [ { keysCombo: [ "ctrl+s"], activateAction: action } ] );
 *
 * 	2) Bind multiple keybinds with a string keycombo at init
 * 	var keybinds =  new component.Keybinder( [ { keysCombo: "ctrl+s", activateAction: action } ] );
 *
 * 	3) Bind a single keybind with a Array keycombo at init
 * 	var keybinds =  new component.Keybinder( ["ctrl","s"], action  );
 *
 * @param {String} _keybinds Bind Single Key bind
 * @example
 *
 *  1) Bind a single keybind with a string keycombo at init
 * 	var keybinds = new component.Keybinder( "ctrl+s", action );
 *
 * @param {Function} _action Single action to take for the corresponding keybind
 */
component.Keybinder = function( _keybinds, _action ) {

	/**
	 * A reference to the instance
	 *
	 * @property keyBinder
	 *
	 * @type {Object}
	 */
	var keyBinder = this;

	/**
	 * Dictionary of keys codes, map to human readable names
	 *
	 * @property keyDictionary
	 *
	 * @type {Object}
	 */
	keyBinder.keyDictionary = {
		'strg': 17,
		'ctrl': 17,
		'ctrlright': 18,
		'ctrlr': 18,
		'shift': 16,
		'return': 13,
		'enter': 13,
		'backspace': 8,
		'bcksp': 8,
		'alt': 18,
		'altr': 17,
		'altright': 17,
		'space': 32,
		'win': 91,
		'mac': 91,
		'fn': null,
		'up': 38,
		'down': 40,
		'left': 37,
		'right': 39,
		'esc': 27,
		'del': 46,
		'f1': 112,
		'f2': 113,
		'f3': 114,
		'f4': 115,
		'f5': 116,
		'f6': 117,
		'f7': 118,
		'f8': 119,
		'f9': 120,
		'f10': 121,
		'f11': 122,
		'f12': 123,
		'tab': 9,
		'pause_break': 19,
		'caps_lock': 20,
		'escape': 27,
		'page_up': 33,
		'page down': 34,
		'end': 35,
		'home': 36,
		'left_arrow': 37,
		'up_arrow': 38,
		'right_arrow': 39,
		'down_arrow': 40,
		'insert': 45,
		'delete': 46,
		'0': 48,
		'1': 49,
		'2': 50,
		'3': 51,
		'4': 52,
		'5': 53,
		'6': 54,
		'7': 55,
		'8': 56,
		'9': 57,
		'a': 65,
		'b': 66,
		'c': 67,
		'd': 68,
		'e': 69,
		'f': 70,
		'g': 71,
		'h': 72,
		'i': 73,
		'j': 74,
		'k': 75,
		'l': 76,
		'm': 77,
		'n': 78,
		'o': 79,
		'p': 80,
		'q': 81,
		'r': 82,
		's': 83,
		't': 84,
		'u': 85,
		'v': 86,
		'w': 87,
		'x': 88,
		'y': 89,
		'z': 90,
		'left_window_key': 91,
		'right_window_key': 92,
		'select_key': 93,
		'numpad 0': 96,
		'numpad 1': 97,
		'numpad 2': 98,
		'numpad 3': 99,
		'numpad 4': 100,
		'numpad 5': 101,
		'numpad 6': 102,
		'numpad 7': 103,
		'numpad 8': 104,
		'numpad 9': 105,
		'multiply': 106,
		'add': 107,
		'plus': 107,
		'subtract': 109,
		'decimal_point': 110,
		'divide': 111,
		'/': 111,
		'num_lock': 144,
		'scroll_lock': 145,
		'semi_colon': 186,
		':': 186,
		'equal_sign': 187,
		'=': 187,
		'comma': 188,
		'dash': 189,
		'period': 190,
		'forward_slash': 191,
		'grave_accent': 192,
		'open_bracket': 219,
		'backslash': 220,
		'closebracket': 221,
		'single_quote': 222
	};

	/**
	 * Object containing map used to check active key combination
	 *
	 * @property map
	 *
	 * @default  {}
	 * @type {Object}
	 */
	keyBinder.map = {};

	/**
	 * Array of current keybind that is being used, used as a reference
	 *
	 * @property activeKeyBinds
	 *
	 * @default  []
	 * @type {Array}
	 */
	keyBinder.activeKeyBinds = [];



	/**
	 * Initialize Keybinder
	 * @private
	 *
	 * @method  init
	 */
	keyBinder.init = function() {

		// if a key bind is provide during init, bind those keys right away.
		if ( typeof _keybinds !== "undefined" ) {

			// if a single keybind is passed in the format of key, action OR keybind is passed in the default format
			if ( typeof _keybinds === "string" && typeof _action !== "undefined" ) {

				var actualKeys = keyBinder.convertKeysToMap( _keybinds );
				keyBinder.activeKeyBinds.push( {
					keysCombo: actualKeys,
					activateAction: _action
				} );

			} else {

				keyBinder.activeKeyBinds = _keybinds;
				for ( var i = 0; i < keyBinder.activeKeyBinds.length; i++ ) {
					keyBinder.activeKeyBinds[ i ].keysCombo = keyBinder.convertKeysToMap( keyBinder.activeKeyBinds[ i ].keysCombo );
				}

			}

			keyBinder.buildMapList();
			keyBinder.bindKey();

		}
	};



	/**
	 * Converts a list of keys in a array or in a string seperated by , or + or & into keymappings
	 *
	 * @method  convertKeysToMap
	 * @private
	 *
	 * @param  {array or string} _keys Key Combos in array of string format
	 * @return {array} Returns the converted keys
	 */
	keyBinder.convertKeysToMap = function( _keys ) {

		var actualKeys = [];

		var i;

		if ( typeof _keys === "string" ) {
			_keys = _keys.split( /\,|\+|\&|and|\-|\|/ );
			for ( var j = 0; j < _keys.length; j++ ) {
				_keys[ j ] = _keys[ j ].trim();
			}

		}

		for ( i = 0; i < _keys.length; i++ ) {
			actualKeys.push( keyBinder.keyDictionary[ _keys[ i ].toLowerCase() ] );
		}

		return actualKeys;
	};



	/**
	 * Build the keyBinder.map object based on the activeKeybind, constructs the map
	 *
	 * @method buildMapList
	 * @private
	 */
	keyBinder.buildMapList = function() {

		var i, j;
		for ( i = 0; i < keyBinder.activeKeyBinds.length; i++ ) {
			for ( j = 0; j < keyBinder.activeKeyBinds[ i ].keysCombo.length; j++ ) {
				if ( typeof keyBinder.map[ keyBinder.activeKeyBinds[ i ].keysCombo[ j ] ] === "undefined" ) {
					keyBinder.map[ keyBinder.activeKeyBinds[ i ].keysCombo[ j ] ] = false;
				}
			}
		}

	};



	/**
	 * Test if the key combos are active and fires off the action
	 *
	 * @method  testKeyCombos
	 * @private
	 *
	 * @param  {Object} e Event Object
	 */
	keyBinder.testKeyCombos = function( e ) {

		var keyComboMatch;
		var i;
		var j;

		if ( e.keyCode in keyBinder.map ) {
			keyBinder.map[ e.keyCode ] = true;

			for ( i = 0; i < keyBinder.activeKeyBinds.length; i++ ) {

				keyComboMatch = true;

				for ( j = 0; j < keyBinder.activeKeyBinds[ i ].keysCombo.length; j++ ) {

					//if any of the key in the combaination is false, set the keyComboMatch to false
					if ( keyBinder.map[ keyBinder.activeKeyBinds[ i ].keysCombo[ j ] ] === false ) {
						keyComboMatch = false;
					}
				}

				if ( keyComboMatch === true ) {
					e.preventDefault();
					keyBinder.activeKeyBinds[ i ].activateAction();
					keyBinder.resetMap();
					break;
				}
			}
		}
	};



	/**
	 * Release the key combo in the key map
	 *
	 * @method  releaseKeyCombos
	 * @private
	 *
	 * @param  {Object} e Event Object
	 */
	keyBinder.releaseKeyCombos = function( e ) {
		if ( e.keyCode in keyBinder.map ) {
			keyBinder.map[ e.keyCode ] = false;
		}
	};



	/**
	 * Clean out the keyBinder.mapping object for reuse
	 *
	 * @method  resetMap
	 * @private
	 */
	keyBinder.resetMap = function() {

		var key;

		for ( key in keyBinder.map ) {
			keyBinder.map[ key ] = false;
		}

	};



	/**
	 * Binds the key based on keyBinder.activeKeyBinds
	 *
	 * @method  bindKey
	 * @private
	 */
	keyBinder.bindKey = function() {

		$( document ).off( 'keydown', keyBinder.testKeyCombos );
		$( document ).off( 'keyup', keyBinder.releaseKeyCombos );
		$( document ).keydown( keyBinder.testKeyCombos ).keyup( keyBinder.releaseKeyCombos );

	};



	/**
	 * Adds single Key Bind by passing keys + _callback or add a set of key binds by passing a array of keybinds
	 *
	 * @method _keys
	 *
	 * @param {Array} _keys mutliple/single keybind(s)
	 * @param {_action} _action Single action to take for the corresponding keybind
	 */
	keyBinder.bindEvent = function( _keys, _action ) {

		keyBinder.clearBoundEvents();

		var i;
		var keysCombo;
		var actualKeys;

		if ( _keys.constructor === Array ) {
			for ( i = 0, keyLength = _keys.length; i < keyLength; i++ ) {
				keysCombo = keyBinder.convertKeysToMap( _keys[ i ].keysCombo );
				keyBinder.activeKeyBinds.push( {
					keysCombo: keysCombo,
					activateAction: _keys[ i ].activateAction
				} );
			}
		} else {
			actualKeys = keyBinder.convertKeysToMap( _keys );
			keyBinder.activeKeyBinds.push( {
				keysCombo: actualKeys,
				activateAction: _action
			} );
		}

		keyBinder.buildMapList();
		keyBinder.bindKey();
	};



	/**
	 * Clear all events
	 *
	 * @method  clearBoundEvents
	 */
	keyBinder.clearBoundEvents = function() {

		$( document ).off( 'keydown', keyBinder.testKeyCombos );
		$( document ).off( 'keyup', keyBinder.releaseKeyCombos );
		keyBinder.activeKeyBinds = [];
		keyBinder.map = {};
	};

	keyBinder.init();

	return {
		bindEvent: keyBinder.bindEvent,
		clearBoundEvents: keyBinder.clearBoundEvents
	};

};