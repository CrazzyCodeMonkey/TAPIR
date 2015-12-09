<cfcomponent output="false"><cfscript>
	this.class_path = "tapir.utils.link";

	/**
		* @class tapir.utils.link
		*
		*/


	/**
		* @method ticket
		* @public
		* @param {numeric} _ticketId (required)
		* @return {string}
		*/
	public string function ticket(required numeric _ticketId){
		return '<a href="https://www.YOUR_TICKET_SERVER.com/?/#_ticketId#">#_ticketId#</a>';
	}


	/**
		* @method tapir
		* @public
		* @param {numeric} _reviewId (required)
		* @return {string}
		*/
	public string function tapir(required numeric _reviewId){
		return '<a href="#Application.domain#/tapir/?reviewId=#_reviewId#">#_reviewId#</a>';
	}

</cfscript></cfcomponent>