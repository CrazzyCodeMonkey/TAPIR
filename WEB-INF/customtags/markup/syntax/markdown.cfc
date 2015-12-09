<cfcomponent output="false" extends="markup" implements="iMarkup"><cfscript>
	this.class_path = "markup.syntax.markdown";

	/**
		* @class markup.syntax.markdown
		*
		*/


this.sMarkup = "MarkDown";
this.sNewLine = chr(13) & chr(10);



/**
 * reader a header level 1 item
 *
 * @method header1
 * @public
 * @param {string} _y1 (required) the header text
 * @return {string}
 */
public string function header1(required string _y1) hint="reader a header level 1 item" {
	return this.hN(1) & " " & _y1  & " " & this.hN(1) & this.newLine();
}



/**
 * reader a header level 2 item
 *
 * @method header2
 * @public
 * @param {string} _y1 (required) the header text
 * @return {string}
 */
public string function header2(required string _y1) hint="reader a header level 2 item" {
	return this.hN(2) & " " & _y1 & " " & this.hN(2) & this.newLine();
}



/**
 * reader a header level 3 item
 *
 * @method header3
 * @public
 * @param {string} _y1 (required) the header text
 * @return {string}
 */
public string function header3(required string _y1) hint="reader a header level 3 item" {
	return this.hN(3) & " " & _y1 & " " & this.hN(3) & this.newLine();
}



/**
 * reader a header level 4 item
 *
 * @method header4
 * @public
 * @param {string} _y1 (required) the header text
 * @return {string}
 */
public string function header4(required string _y1) hint="reader a header level 4 item" {
	return this.hN(4) & " " & _y1 & " " & this.hN(4) & this.newLine();
}



/**
 * reader a header level 5 item
 *
 * @method header5
 * @public
 * @param {string} _y1 (required) the header text
 * @return {string}
 */
public string function header5(required string _y1) hint="reader a header level 5 item" {
	return this.hN(5) & " " & _y1 & " " & this.hN(5) & this.newLine();
}



/**
 * reader a header level 6 item
 *
 * @method header6
 * @public
 * @param {string} _y1 (required) the header text
 * @return {string}
 */
public string function header6(required string _y1) hint="reader a header level 6 item" {
	return this.hN(6) & " " & _y1 & " " & this.hN(6) & this.newLine();
}



/**
 * render a paragraph item
 *
 * @method paragraph
 * @public
 * @param {string} _y1 (required) the paragraph text
 * @return {string}
 */
public string function paragraph(required string _y1) hint="render a paragraph item" {
	return _y1 & this.newLine(2);
}



/**
 * render a blockquote item
 *
 * @method blockquote
 * @public
 * @param {string} _y1 (required) the blockquote text
 * @return {string}
 */
public string function blockquote(required string _y1) hint="render a blockquote item" {
	var aLines = listToArray(_y1, this.sNewLine,true);
	var sLine ="";
	var sQuote="";

	for (sLine in aLines){
		sQuote &= "> " & sLine & this.newLine();
	}

	sQuote &= this.newLine();

	return sQuote;
}


/**
 * render an item in bold
 *
 * @method bold
 * @public
 * @param {string} _y1 (required) the text to bold
 * @return {string}
 */
public string function bold(required string _y1) hint="render an item in bold" {
	return "**" & _y1 & "**";
}



/**
 * render an item in italics
 *
 * @method italic
 * @public
 * @param {string} _y1 (required) the text to italicize
 * @return {string}
 */
public string function italic(required string _y1) hint="render an item in italics" {
	return "_" & _y1 & "_";
}



/**
 * render an item as code
 *
 * @method code
 * @public
 * @param {string} _y1 (required) the code to render
 * @param {string} [_y2 = ""] the language to render in (if multiline)
 * @return {string}
 */
public string function code(required string _y1, string _y2="") hint="render an item as code" {
	var sCode = "";
	if (listLen(_y1,this.newLine())==1){
		sCode = "`" & _y1 & "`";
	} else {
		sCode = this.newLine(2) & "```" & _y2 & this.newLine() & _y1 & this.newLine() & "```" & this.newLine(2);
	}

	return sCode;
}



/**
 * render a link
 *
 * @method link
 * @public
 * @param {string} _y1 (required) the source of the link
 * @param {string} _y2 (required) the text to display for the link
 * @return {string}
 */
public string function link(required string _y1, required string _y2) hint="render a link" {
	return "[" & _y2 & "](" & _y1 & ")";
}



/**
 * render a horizontil rule
 *
 * @method rule
 * @public
 * @return {string}
 */
public string function rule() hint="render a horizontil rule" {
	return this.newLine(2) & "---" & this.newLine();
}

/**
 * render a list or a specific type
 *
 * @method list
 * @public
 * @param {string} _y1 (required) the type of list (bullet/number)
 * @param {array} _y2 (required) an array of list items
 * @param {numeric} [_y3 = 0] the indent level of the list
 * @return {string}
 */
public string function list(required string _y1, required array _y2, numeric _y3=0) hint="render a list or a specific type" {
	var sList = "";

	if (_y1=="bullet"){
		sList = this.bulletList(_y2, _y3);
	} else if (_y1=="number"){
		sList = this.numberList(_y2, _y3);
	}

	return sList;
}

/**
 * render an unordered list
 *
 * @method bulletList
 * @public
 * @param {array} _y1 (required) an array of list items
 * @param {numeric} [_y2 = 0] the indent level of the list
 * @return {string}
 */
public string function bulletList(required array _y1, numeric _y2=0) hint="render an unordered list" {
	var sList = "";
	var yItem="";

	for (yItem in _y1){
		var sLine = "";
		if (isArray(yItem)){
			sLine = this.bulletList(yItem,_y2+1);
		} else {
			sLine = repeatString("  ", _y2) & "* " & yItem & this.newLine();
		}

		sList &= sLine;
	}

	if (_y2==0){
		sList &= this.newLine();
	}

	return sList;
}



/**
 * render an ordered list
 *
 * @method numberList
 * @public
 * @param {array} _y1 (required) an array of list items
 * @param {numeric} [_y2 = 0] the indent leve of the list
 * @return {string}
 */
public string function numberList(required array _y1, numeric _y2=0) hint="render an ordered list" {
	var sList = "";
	var yItem="";
	var count=1;

	for (yItem in _y1){
		var sLine = "";
		if (isArray(yItem)){
			sLine = this.numberList(yItem,_y2+1);
		} else {
			sLine = repeatString("  ", _y2) & count & ". " & yItem & this.newLine();
			count++;
		}

		sList &= sLine;
	}

	if (_y2==0){
		sList &= this.newLine();
	}

	return sList;
}



/**
 * render an image
 *
 * @method image
 * @public
 * @param {string} _y1 (required) the alt text for the image
 * @param {string} _y2 (required) the source for the image
 * @return {string}
 */
public string function image(required string _y1, required string _y2) hint="render an image" {
	return "![" & _y1 & "](" & _y2 & ")";
}



/**
 * render a new line
 *
 * @method newLine
 * @public
 * @param {numeric} [_nTimes = 1] the number of newlines to render
 * @return {string}
 */
public string function newLine(numeric _nTimes=1) hint="render a new line" {
	return repeatString(this.sNewLine, _nTimes);
}



/**
 * help to render header items
 *
 * @method hN
 * @private
 * @param {numeric} _nLevel (required)
 * @return {string}
 */
private string function hN(required numeric _nLevel) hint="help to render header items" {
	return repeatString("##", _nLevel);
}


</cfscript></cfcomponent>