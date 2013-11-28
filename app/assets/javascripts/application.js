// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ujs
//
// Required by Blacklight
//= require blacklight/blacklight
// we're just using core and droppable from jquery-ui
//= require jquery-ui
//= require jquery.scrollTo-min.js
//= require bootstrap
//= require angular
//= require angular-bootstrap
//=# require angular-route
//= require angular-resource
//= require angular-sanitize
//= require ng-grid
//= require jquery.tokeninput
//= require_tree .

Number.prototype.leftZeroPad = function(numZeros) {
        var n = Math.abs(this);
        var zeros = Math.max(0, numZeros - Math.floor(n).toString().length );
        var zeroString = Math.pow(10,zeros).toString().substr(1);
        if( this < 0 ) {
                zeroString = '-' + zeroString;
        }

        return zeroString+n;
}