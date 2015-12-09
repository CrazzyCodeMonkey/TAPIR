<cfsilent>
	<!--- $Id: toolbar-link.cfm 23612 2015-12-08 19:28:36Z llee $ --->
	<cfparam name="attributes.icon" default="Link" />
	<cfparam name="attributes.href" default="" />
	<cfparam name="attributes.title" default="" />
	<cfparam name="attributes.tooltip" default="" />
	<cfparam name="attributes.tooltipDirection" default="left" />
	<cfparam name="attributes.class" default="" />
	<cfparam name="attributes.label" default="" />
	<cfparam name="attributes.onclick" default="" />
	<cfparam name="attributes.tooltipWidth" default="100%" />
	<cfparam name="attributes.align" default="left" />
	<cfparam name="attributes.id" default="id" />
	<cfscript>
		onClickMarkup = "";
		toolTipWidthMarkup = "";
		hrefMarkup = "";
		tooltipMarkup = "";
		titleMarkup = "";
		labelMarkup = "";

		if ( attributes.id != "" ){
			idMarkup = "id=""" & attributes.id & """";
		}
		if ( attributes.onclick != "" ){
			onClickMarkup = "onclick=""" & attributes.onclick & """";
		}
		if ( attributes.tooltipWidth != "100%" ){
			toolTipWidthMarkup = "data-tooltip-width=""" & attributes.tooltipWidth & "px""";
		}
		if ( attributes.href != "" ){
			hrefMarkup = "href=""" & attributes.href & """";
		}
		if ( attributes.tooltip != "" ){
			tooltipMarkup = "data-tooltip=""" & attributes.tooltip & """";
		}
		if ( len( attributes.title ) > 0 ){
			titleMarkup = "title=""" & attributes.title & """";
		}
		if ( attributes.label != "" ){
			labelMarkup = "&nbsp&nbsp" & attributes.label;
		}
	</cfscript>
</cfsilent>
<cfif ( thistag.executionmode == "start" ) >
	<ul class="nav navbar-nav pull-<%=#attributes.align#%>">
	<li>
		<cfoutput><a #idMarkup# class="tooltip-#attributes.tooltipDirection#  tooltip-menu-#attributes.tooltipDirection#fix #attributes.class#" #onClickMarkup# #toolTipWidthMarkup# #hrefMarkup# #tooltipMarkup# #titleMarkup#><i class='#attributes.icon#'></i>#labelMarkup#</a></cfoutput>
	</li>
	</ul>
</cfif>
