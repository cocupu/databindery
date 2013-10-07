// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//
// Required by Blacklight
//= require blacklight/blacklight
// we're just using core and droppable from jquery-ui
//= require jquery-ui-1.8.23.min 
//= require jquery.scrollTo-min.js
//=# require underscore
//=# require backbone
//= require bootstrap
// AJAX adapter for rails, that uses paramRoot to set up requests as rails expects 
// (see http://stackoverflow.com/questions/8016296/backbone-model-save)
//=# require backbone_rails_sync
//=# require backbone/cocupu
//= require dataTables/jquery.dataTables
//= require select2/select2
//= require angular
//= require angular-bootstrap
//= require angular-resource
//= require angular-sanitize
//= require angular-ui-select2
//= require ng-grid
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