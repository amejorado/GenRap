# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  $(window).load ->
    $(".finish").css({"background-color": "rgba(13, 145, 233, 0.19)", "padding": "1px"})
    $(".bad").css({"color":"red"})