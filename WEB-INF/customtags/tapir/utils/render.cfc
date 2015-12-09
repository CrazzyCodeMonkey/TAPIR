<cfcomponent output="false"><cfscript>
	this.class_path = "tapir.utils.render";

	/**
		* @class tapir.utils.render
		*
		*/



	/**
		* @method renderForHTML
		* @public
		* @param {string} _html (required)
		* @param {string} _count (required)
		* @return {string}
		*/
	public string function renderForHTML(required string _html, required string _count, required string _actualCount, required string _tabSize){

		var sHTML = replace(arguments._html,"<","&lt;","ALL");
		sHTML 		= replace(sHTML, ">","&gt;","ALL");
		sHTML 		= replace(sHTML," ","<span class='wp'>&middot;</span>","ALL");
		sHTML 		= rereplace(sHTML,"\t","<span class='wp'>" & repeatString("&mdash;",fix(_tabSize)) & "&##8202</span>","ALL");
		return "<pre data-line='"&_count &"'' class='codePre actualLineAt-"& _actualCount &"' id='line-"& _count &"'><code class='javascript'>#sHTML#</code></pre>";
	}

</cfscript></cfcomponent>