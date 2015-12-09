<cfcomponent output="false"><cfscript>
	this.class_path = "markup.builder";

	/**
		* @class markup.builder
		*
		*/

	this.sRender = "";
	this.oMarkUp = "";
	this.sSyntaxPath = "markup.syntax.";



	/**
	 * create the markup syntax
	 *
	 * @method init
	 * @public
	 * @param {string} _sMarkUp (required) the markup language to use
	 * 					this will reflect a cfc under ./syntax/
	 */
	public component function init(required string _sMarkUp) hint="create the markup syntax"{
		this.oMarkup = createObject(this.sSyntaxPath & _sMarkUp);
		var uMeta = getMetaData(this.oMarkup);

		this.clear();
	}



	/**
	 * render the item, and append it to the render string
	 *
	 * @method add
	 * @public
	 * @param {string} _sType (required) the element type to render/add
	 * 					ie: header1, paragraph, code, list, etc...
	 * @param {any} any _y1 specific data required to render the element, see the markup element function for clarification
	 * @param {any} any _y2 additional specific data required to render the element, see the markup element function for clarification
	 * @param {any} any _y3 additional specific data required to render the element, see the markup element function for clarification
	 * @return {component} this is returned to allow for chaining
	 */
	public component function add(required string _sType, any _y1, any _y2, any _y3) hint="render the item, and append it to the render string"{
		this.sRender &= this.noAdd(argumentCollection=arguments);
		return this;
	}



	/**
	 * render the item, and return it
	 *
	 * @method noAdd
	 * @public
	 * @param {string} _sType (required) the element type to render
	 * 					ie: header1, paragraph, code, list, etc...
	 * @param {any} any _y1 specific data required to render the element, see the markup element function for clarification
	 * @param {any} any _y2 additional specific data required to render the element, see the markup element function for clarification
	 * @param {any} any _y3 additional specific data required to render the element, see the markup element function for clarification
	 * @return {string}
	 */
	public string function noAdd(required string _sType, any _y1, any _y2, any _y3) hint="render the item, and return it"{
		var sRenderSection="";
		var uNewArgs = {};

		//make sure we are rendering an element the specified syntax supports
		if (structKeyExists(this.oMarkup, _sType) && isCustomFunction(this.oMarkup[_sType])){
			//prepare the arguments to pass on
			uNewArgs = structCopy(arguments);
			structDelete(uNewArgs,"_sType");
			//call to render the item
			sRenderSection = invoke(this.oMarkup, _sType, uNewArgs);
		} else {
			//unsupported item
			throw("Builder", "Markup type not found", "The markup type of #_sType# is not a valid elemenr for #this.oMarkup.getLanguage()#");
		}

		return sRenderSection;
	}



	/**
	 * get the rendered string
	 *
	 * @method get
	 * @public
	 * @return {string} the rendered string
	 */
	public string function get() hint="get the rendered string"{
		return this.sRender;
	}



	/**
	 * clear the rendered string
	 *
	 * @method clear
	 * @public
	 */
	public void function clear() hint="clear the rendered string"{
		this.sRender = "";
	}



</cfscript></cfcomponent>