
$(document).ready ->
 $(".track-add-sowa").live "click", ->
  link = $(this)
  link.attr "disabled", true
  sowId = $('#client-sow-id').val()
#var pId = $("#client-plan-id").val();
  t_sowId = $('#client-track-sow-id').val()
  no_sow_assets = @id.split("-")[1]
  aId = $("#scope_of_work_asset_id-" + no_sow_assets).val()
  nosow_assets = $("#total-sow-assets").val()
  $("#sow-step2-form").validationEngine "detach"
  $.ajax
    type: "POST"
    url: "/client/" +sowId + "/add-duplicate-sow-assets/" + t_sowId
    data:
      index: nosow_assets
      sowa: aId

    timeout: 15000
    success: (data) ->
      $(data).hide().insertAfter(link.parent().parent()).fadeIn 2000
      $("#total-sow-assets").val next_sow_asset
      link.removeAttr "disabled"
      $("#sow-step2-form").validationEngine "attach"
    error: (resp, status, error) -> 
      $("#sow-step2-form").validationEngine "attach"
      link.removeAttr "disabled"
      alert resp.responseText
    dataType: "html"


 