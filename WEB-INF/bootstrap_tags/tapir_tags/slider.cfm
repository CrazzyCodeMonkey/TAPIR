<!--- $Id: slider.cfm 23501 2015-12-04 14:34:59Z llee $ --->
<cfparam name="attributes.slideDirection" default="right" />
<cfparam name="attributes.labelId" default="sliderLabelId" />
<cfparam name="attributes.contentId" default="sliderContentId" />

<div class="cd-panel from-<%=#attributes.slideDirection#%>">
	<div class="shadow-z-2 cd-panel-container cd-panel-container-header" >
		<div class="header shadow-z-2">
			<!--- Slider Expand Button --->
			<button class="btn btn-default btn-raised sliderHeaderButtons left" id="expandSlider">
				<i class="fa fa-chevron-left sliderIcon"></i>
			</button>
			<button class="btn btn-default btn-raised sliderHeaderButtons left tooltip-right tooltip-fix" data-tooltip="Open Filters Menu" id="diffSettings">
				<i class="fa fa-gears sliderIcon"></i>
			</button>


			<!--- Slider Close Button --->
			<button class="btn btn-raised btn-material-red sliderHeaderButtons right tooltip-left tooltip-fix" id="removeSlider">
				<i class="fa fa-close sliderIcon"></i>
			</button>
			<button class="btn btn-default btn-raised sliderHeaderButtons right activeButton" id="nextChangeButtonFixed">
				<i class="fa fa-arrow-right"></i>
			</button>
			<button class="btn btn-default btn-raised sliderHeaderButtons right" disabled id="previousChangeButtonFixed">
				<i class="fa fa-arrow-left sliderIcon"></i>
			</button>

			<button class="btn btn-default btn-raised sliderHeaderButtons right smallButtonToggleOff tooltip-left tooltip-fix" data-tooltip="Filter Deleted Lines" id="showDeletedButtonSmall">
				<span class="sliderIcon smallButtonToggleOff">D</span>
			</button>
			<button class="btn btn-default btn-raised sliderHeaderButtons right smallButtonToggleOff tooltip-left tooltip-fix" data-tooltip="Filter Pristine Lines" id="showPristineButtonSmall">
				<span class="sliderIcon smallButtonToggleOff">P</span>
			</button>
			<button class="btn btn-default btn-raised sliderHeaderButtons right smallButtonToggleOff tooltip-left tooltip-fix" data-tooltip="Filter mScan Comments" id="showmScanButtonSmall">
				<span class="sliderIcon smallButtonToggleOff">M</span>
			</button>
			<button class="btn btn-default btn-raised sliderHeaderButtons right smallButtonToggleOff tooltip-left tooltip-fix" data-tooltip="Show/Hide Indent and Space Symbols" data-tooltip="Show/Hide Indent" id="showIndentButtonSmall">
				<span class="sliderIcon smallButtonToggleOff">I</span>
			</button>
			<!--- Slider Header --->
			<div class="labelText sliderHeaderLabel">
				<span class="textLabel sliderIcon" ><i class="fa fa-cube"></i> <span id="<%=#attributes.labelId#%>">Loading...</span></span>
			</div>
		</div>
		<div class="cd-panel-controls-container">
			<div class="row" >
				<div class="col-md-12">
					<button class="btn btn-default btn-raised btn-material-grey" id="showIndentButton">Indent &nbsp<i class="fa fa-check-square-o"></i></button>
					<button class="btn btn-default btn-raised btn-material-grey" id="showmScanButton">mScan comments &nbsp<i class="fa fa-check-square-o"></i></button>
					<button class="btn btn-default btn-raised btn-material-grey" id="showPristineButton">Pristine &nbsp<i class="fa fa-check-square-o"></i></button>
					<button class="btn btn-default btn-raised btn-material-grey" id="showDeletedButton">Deleted &nbsp<i class="fa fa-check-square-o"></i></button>
				</div>
			</div>
			<div id="revControlDiff">

			</div>
		</div>
	</div>
	<div class=" shadow-z-2 cd-panel-container cd-panel-container-actual" >
		<div id="topContent" class="cd-panel-content"></div>
		<!--- The actual Content of the slider here --->
		<div class="contentContainer" >
		<div id="<%=#attributes.contentId#%>"></div>
		</div>
	</div>
</div>