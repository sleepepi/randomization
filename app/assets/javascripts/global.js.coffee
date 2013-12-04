@ready = () ->
  contourReady()
  $(document).off("click", ".pagination a, .page a, .next a, .prev a")
  $(document).off("click", ".per_page a")
  window.$isDirty = false
  msg = "You haven't saved your changes."
  window.onbeforeunload = (el) -> return msg if window.$isDirty

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
