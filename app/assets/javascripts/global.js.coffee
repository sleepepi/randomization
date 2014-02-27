@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

@ready = () ->
  contourReady()
  window.$isDirty = false
  msg = "You haven't saved your changes."
  window.onbeforeunload = (el) -> return msg if window.$isDirty
  setFocusToField("#search")

$(document).ready(ready)
$(document)
  .on('page:load', ready)
  .on('click', '[data-object~="settings-save"]', () ->
    window.$isDirty = false
    $($(this).data('target')).submit()
    false
  )
  .on('click', '[data-object~="remove"]', () ->
    $($(this).data('target')).remove()
    false
  )
  .on('change', ':input', () ->
    window.$isDirty = true if $("#isdirty").val() == '1'
  )
