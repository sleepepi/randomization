# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document)
    .on('click', '[data-object="add_treatment_arm"], [data-object="add_stratification_factor"], [data-object="add_option"]', () ->
      $.post(root_url + "projects/#{$(this).data('object')}", "position=#{$(this).data('position')}", null, "script")
      false
    )
