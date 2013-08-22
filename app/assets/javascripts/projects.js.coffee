# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@calculate_block_size = () ->
  block_size = 0
  $("[name='project[treatment_arms][][allocation]']").each( () ->
    block_size += Math.abs(parseInt($(this).val()) || 1)
  )
  block_size

jQuery ->
  $(document)
    .on('click', '[data-object="add_treatment_arm"], [data-object="add_stratification_factor"], [data-object="add_option"]', () ->
      $.post(root_url + "projects/#{$(this).data('object')}", "position=#{$(this).data('position')}", null, "script")
      false
    )
    .on('click', '[data-object="generate_lists"]', () ->
      $.post(root_url + "projects/#{$(this).data('project-id')}/#{$(this).data('object')}", null, null, "script")
      false
    )
    .on('mouseover', '[data-object="show-actual-block-size"]', () ->
      $(this).data('original-html', $(this).html())
      block_size = calculate_block_size()
      $(this).html( "#{$(this).data('multiplier') * block_size}".lpad("0", 2) )
    )
    .on('mouseout', '[data-object="show-actual-block-size"]', () ->
      $(this).html( $(this).data('original-html') )
    )
