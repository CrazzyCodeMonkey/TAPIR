<cfcomponent output="false"><cfscript>
	this.class_path = "markup.syntax.markup";

	/**
		* @class markup.syntax.markup
		*
		*/



this.sMarkup = "UNDEFINED";


/**
 * get the syntax that we are rendering
 *
 * @method getLanguage
 * @public
 * @return {string}
 */
public string function getLanguage() hint="get the syntax that we are rendering"{
	return this.sMarkup;
}



</cfscript></cfcomponent>