<cfsilent><cfscript>
	/* $Id: navbar-container.cfm 23391 2015-12-01 15:26:12Z tsinclair $ */
	param name="attributes.side" default="right";
	param name="attributes.container" default="div";

	validation = {
		side : ["right","left"],
		container:["div","form"]
	};

	for (vTest in validation){
		if (!arrayContains(validation[vTest],attributes[vTest])){
			throw("BOOTSTRAP","Invalid #vTest#", "'#attributes[vTest]#' is not a valid #vTest#.  Valid values are: #listToArray(validation[vTest])#");
		}
	}
</cfscript></cfsilent>
<cfif thistag.executionmode == "start">
	<cfoutput><#attributes.container# class="nav navbar-nav navbar-#attributes.side#"></cfoutput>
<cfelseif thistag.executionmode == "end">
	</<%=#attributes.container#%>>
</cfif>