var markdown = {};
var dropins = {};

dropins.modal = ["sClass","sStyle","sId","sTitle","sMessage"];
markdown.modal = '<div class="{{sClass}}" {{sStyle}} {{sId}}>'+
		'<div class="modal-dialog">'+
			'<div class="modal-content">'+
				'<div class="modal-header">'+
					'<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>'+
					'<h4 class="modal-title">{{sTitle}}</h4>'+
				'</div>' +
				'<div class="modal-body">{{sMessage}}</div>'+
				'<div class="modal-footer">'+
					/* buttons need to go in here */
				'</div>'+
			'</div>'+
		'</div>'+
	'</div>';

