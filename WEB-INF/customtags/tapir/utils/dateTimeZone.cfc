<cfcomponent output="false"><cfscript>
	/*
			Setting some common datetime functions and standards
			Adjusts to a defined timezone instead of relying on the local timezone on the server
	*/

	this.class_path = "WEB-INF.customtags.tapir.utils.dateTimeZone";

/**
	* @class WEB-INF.customtags.utils.dateTimeZone.cfc
	*/

	/**
		* Init object, set the default time zone to use
		* @method init
		* @param [ _time_zone = "US/Eastern" ] { string } timezone to use, really useful when the server is set to utc and not a local timezone
		* @return { object }
		*/
	function init( string _time_zone = "US/Eastern" ){

		//create an eastern time zone object
		this.timeZoneObj = createObject( "java", "java.util.TimeZone" ).getTimeZone( javaCast( "string", arguments._time_zone ) );

		return this;

	}


	/**
		* Get timezone offset in milliseconds between utc and time zone
		* @method getZone2UtcOffset
		* @param _local_datetime { date } date need b/c offset changes based on daylight savings time
		* @return { numeric } offset in milliseconds
		*/
	numeric function getZone2UtcOffset( required date _local_datetime ){

		//get the offset in milliseconds
		return this.timeZoneObj.getOffset( arguments._local_datetime );

	}


	/**
		* Applies timezone offset to local datetime
		* @method offsetDateTime
		* @param _local_datetime { date }
		* @return { date }
		*/
	date function offsetDateTime( required date _local_datetime ){

		//get the offset
		var zoneOffset = this.getZone2UtcOffset( arguments._local_datetime );

		//need to make sure the date is utc b/c some servers are already in utc and some are not
		var utcDateTime = dateConvert( 'local2utc', arguments._local_datetime );

		//return the offsetted datetime
		return DateAdd( 'l', zoneOffset, utcDateTime );

	}


	/**
		* Defines a string display standard for dates
		* @method displayFormat
		* @param _local_datetime { date }
		* @param [ _use_offset = true ] { boolean } flag to also convert the _local_datetime to the timezone
		* @return { string } display version of the date
		*/
	string function displayFormat( required date _local_datetime, boolean _use_offset = true ){

		var dateObj = arguments._local_datetime;

		if( arguments._use_offset ){
			dateObj = this.offsetDateTime( arguments._local_datetime );
		}

		return  DateTimeFormat( dateObj, "E MMM d, yyyy h:mm:ssa" );

	}

</cfscript></cfcomponent>