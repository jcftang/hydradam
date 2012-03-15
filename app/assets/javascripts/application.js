// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require 'blacklight_advanced_search'


//= require jquery_ujs
// Required by Hydra
//= require 'jquery.ui.datepicker.js'      

//
// Required by Blacklight
//= require jquery-ui
//= require blacklight/blacklight
//= require 'twitter_bootstrap/bootstrap-tooltip.js'
//= require_tree .
//
$(function() {
  $(".alert").append('<a class="close" data-dismiss="alert" href="#">&times;</a>').alert();

  $(".q").attr('placeholder', 'Search');
});
