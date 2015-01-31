var fs      = require('fs');
var gui     = require('nw.gui');
var $       = require('jquery');
var fileUrl = require('file-url');

$(function() {
    var file = gui.App.argv[0];
    fs.exists(file, function (exists) {
        if (exists) {
            var url = fileUrl(file);
            $('#viewer').append('<img src="' + url + '" />');
        } else {
            $('#viewer').append('<p>File does not exist</p>');
        }
    });
});
