var fs      = require('fs');
var gui     = require('nw.gui');
var $       = require('jquery');
var fileUrl = require('file-url');

// This is kind of a visual convenience, just consider other
// files should interpret this one as "the app's namespace".
var dojikko = exports;

// Modes are 'fitdown', 'fit' and 'zoom'.
dojikko.viewerMode = 'fitdown';

function showNotFound() {
    $('#viewer').append('<p>File does not exist</p>');
}

function showFile(file) {
    var url = fileUrl(file);
    $('#viewer').data('mode', dojikko.viewerMode);
    $('#viewer').append('<img src="' + url + '" />');
}

$(function() {
    var file = gui.App.argv[0];
    fs.exists(file, function (exists) {
        if (exists) {
            showFile(file);
        } else {
            showNotFound();
        }
    });
});
