# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready( ->
        $(document).tooltip();
);


$(document).ready ->
  $("#master_question_language_id").change ->
    i = 1
    $("#master_question_concept_id option").remove()
    $("#master_question_subconcept_id option").remove()
    $.getJSON "/master_question/concepts_for_question",
      language: $("#master_question_language_id").val()
    , (data) ->
      if data is null
        window.console and console.log("null :(")
        return
      options = $("#master_question_concept_id")
      options.append $("<option />").val(-1).text("Selecciona un Concepto")
      $.each data, (item) ->
        options.append $("<option />").val(data[item].id).text(data[item].name)
      $("#master_question_concept_id").prop "selectedIndex", 0
      $("#master_question_subconcept_id").append $("<option />").val(-1).text("Selecciona un Subconcepto")
      $("#master_question_subconcept_id").prop "selectedIndex", 0


$(document).ready ->
  $("#master_question_concept_id").change ->
    $("#master_question_subconcept_id option").remove()
    $.getJSON "/master_question/subconcepts_for_question",
      language: $("#master_question_language_id").val()
      concept: $("#master_question_concept_id").val()
    , (data) ->
      if data is null
        window.console and console.log("null :(")
        return
      options = $("#master_question_subconcept_id")
      options.append $("<option />").val(-1).text("Selecciona un Subconcepto")
      $.each data, (item) ->
        options.append $("<option />").val(data[item].id).text(data[item].name)
        $("#master_question_subconcept_id").prop "selectedIndex", 0