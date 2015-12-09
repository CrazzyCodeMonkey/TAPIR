<cfcomponent output="false"><cfscript>
	this.class_path = "tapir.utils";

	/**
		* @class tapir.utils
		*
		*/



	/**
		* @method getUtil
		* @public
		* @param {string} _utilName (required)
		* @return {component}
		*/
	public component function getUtil(required string _utilName){
		return createObject("tapir.utils." & arguments._utilName);
	}



	/**
		* @method runUtilFn
		* @public
		* @param {string} _utilName (required)
		* @param {string} _fnName (required)
		* @param {struct} _fnParams (required)
		* @return {any}
		*/
	public any function runUtilFn(required string _utilName, required string _fnName, required struct _fnParams){
		try {
			return invoke(this.getUtil(_utilName), _fnName, _fnParams);
		} catch (any e){
			return "ERROR";
		}
	}



</cfscript></cfcomponent>