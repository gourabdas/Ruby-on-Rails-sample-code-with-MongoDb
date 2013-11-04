$(document).ready(function() {
    $("table#sortTableExample").tablesorter({
        sortList: [[1, 0]]
    });

    $('.track-plan-progress').click(function() {
        var sid = $(this).val();
        window.location.href = "/client/" + sid + "/track-staffing/new";
    });

    $('.track-progress').live("click", function() {
        var rid = $(this).attr('id'), track_for = $('#' + rid).val(), pid = $('#track-plan-id').val();
        window.location.href = "/client/track/" + track_for + "/progress/?plan_id=" + pid;
    });

    //track change functionality...

    $('.track-plan-change').live("click", function() {
        var pid = $(this).val();
        window.location.href = " /client/" + pid + "/change-order";
    });

    $('.track-change').live("click", function() {
        var rid = $(this).attr('id'), track_for = $('#' + rid).val(), tc_id = $('#track-change-id').val(), pid = $('#track-plan-id').val();
        window.location.href = "/client/" + pid + "/" + track_for + "/edit/?tc_id=" + tc_id;
    });

    $("#compare-benchmark-track").live("click", function() {
        var type = "Benchmark", val = "", action = "";
        var s_id = $("#staffing-plan-id").val(), tsid = $("#track-staffing-plan-id").val();
        switch ($("input:radio[class=benchmark-type]:checked").val()) {
            case "Hybrid":
                if (!$("#staffing_hybrid_hours_fte").val() || parseFloat($("#staffing_hybrid_hours_fte").val()) == 0) {
                    alert("Hybrid Hours/FTE should be a number greter than zero.");
                    $("#staffing_hybrid_hours_fte").focus();
                    return false;
                }
                type = "Hybrid";
                val = $("#staffing_hybrid_hours_fte").val();
                action = "/client/" + s_id + "/track-staffings/" + tsid + "/benchmark-compare/" + type + "/" + val;
                break;
            case "Benchmark":
                type = "Benchmark";
                action = "/client/" + s_id + "/track-staffings/" + tsid + "/benchmark-compare/" + type;
                break;
        }
        $(this).attr("href", action);
        return true;
    });

    $('#track-staffing-step-1-submit').click(function() {
        if ($('#start_date').val() == "" || $('#end_date').val() == "") {
            alert("Please Select 'Start' and 'End' Date both");
            return false;
        }
    });

    var yearRange = new Date().getFullYear();
    $("#start_date, #end_date").datepicker({
        yearRange: (yearRange - 50) + ':' + (yearRange + 50),
        changeMonth: true,
        changeYear: true,
        dateFormat: "yy-mm-dd",
        showAnim: "fadeIn",
        duration: 1,
        onSelect: function() {
            var startDate = new Date($('#start_date').val());
            var endDate = new Date($('#end_date').val());
            if (!startDate || !endDate)
                return;

            if ($('#start_date').val() && $('#end_date').val()) {
                var plan_start_date = $('#start_date_td').text();
                var plan_end_date = $('#end_date_td').text();
                if ((plan_start_date == startDate) && (plan_end_date == endDate)) {
                    $('#number_of_months_count').text('Completed')
                }
                else {
                    var diff = (endDate - startDate);
                    var days = (diff / 1000 / 60 / 60 / 24 / 30);
                    $('#number_of_months_count').text(parseFloat(days).toFixed(1))
                }
            }
            else {
                return false;
            }
        },
        beforeShow: function(input) {
            if (input.id == 'start_date') {
                return {
                    maxDate: $('#end_date').datepicker("getDate")
                };
            }
            else if (input.id == 'end_date') {
                return {
                    minDate: $('#start_date').datepicker("getDate")
                };
            }
        }
    });

    $("#track_start_date, #track_end_date").datepicker({
        yearRange: (yearRange - 50) + ':' + (yearRange + 50),
        changeMonth: true,
        changeYear: true,
        dateFormat: "yy-mm-dd",
        showAnim: "fadeIn",
        duration: 1,
        beforeShow: function(input) {
            if (input.id == 'track_start_date') {
                return {
                    maxDate: $('#track_end_date').datepicker("getDate")
                };
            }
            else if (input.id == 'track_end_date') {
                return {
                    minDate: $('#track_start_date').datepicker("getDate")
                };
            }
        }
    });



    if ($("#track-progress").length > 0) {
        if ($("#start_date").val() && $("#end_date").val()) {
            var startDate = new Date($('#start_date').val());
            var endDate = new Date($('#end_date').val());
            var plan_start_date = $('#start_date_td').text();
            var plan_end_date = $('#end_date_td').text();
            if ((plan_start_date == startDate) && (plan_end_date == endDate)) {
                $('#number_of_months_count').text('Completed')
            }
            else {
                var diff = (endDate - startDate);
                var days = (diff / 1000 / 60 / 60 / 24 / 30);
                $('#number_of_months_count').text(parseFloat(days).toFixed(1))
            }
        }
    }

    /*****************************Add Staff ***********************************/
    if ($(".staff-list-on-track").length > 0 && $("#track-staffing-id").length > 0 && $("#track-staffing-id").val()) {
        var tsId = $("#track-staffing-id").val();
        $(".container-fluid").mask("Loading...");
        $.ajax({
            type: "GET",
            url: "/client/" + tsId + "/track-staffings/staff-list",
            timeout: 15000,
            success: function(data) {
                $(".staff-list-on-track").append(data);
                $("#add-staff-submit-tag").removeAttr("disabled");
                $(".container-fluid").unmask();
                fte_calculation();
            },
            dataType: "html"
        });
    }

    $(".edit-track-staffing-details").live("click", function() {
        if (!$(this).hasClass('disabled')) {
            $(this).addClass('disabled');
            var id = $(this).attr("id");
            var index = id.split("_");
            index = index[index.length - 1];
            $("#staffing-details-staff-name_" + index).attr("readonly", false);
            $("#staffing-details-years-of-exp_" + index).attr("readonly", false);
            $("#staffing-details-client-hours_" + index).attr("readonly", false);
            $("#staffing_details_" + index).find("input.auto-numeric").each(function() {
                if (typeof $(this).data('autoNumeric') !== 'object') {
                    $(this).autoNumeric("init", {
                        vMax: '9999999999999.99',
                        aForm: true
                    });
                }
            });

            var planId = $("#staffing-plan-id").val();
            var marketId = $("#staffing-market-id").val();
            var asset = $("#staffing-details-asset-id_" + index).val();
            var category = $("#staffing-details-category_" + index).val();
            var discipline = $("#staffing-details-discipline-id_" + index).val();
            var department = $("#staffing-details-department-id_" + index).val();
            var job_title = $("#staffing-details-job-title-id_" + index).val();
            if (marketId && discipline && department) {
                $.ajax({
                    type: "POST",
                    url: "/client/track-staffings/get-dependent-list/" + index,
                    data: {
                        plan_id: planId,
                        asset: asset,
                        category: category,
                        department: department,
                        discipline: discipline,
                        job_title: job_title,
                        market_id: marketId
                    },
                    success: function(data) {
                        if (data.success) {
                            $("#staffing-asset_" + index).html(data.asset);
                            $("#staffing-category_" + index).html(data.category);
                            $("#staffing-discipline_" + index).html(data.disciplines);
                            $("#staffing-department_" + index).html(data.departments);
                            $("#staffing-job-title_" + index).html(data.job_titles);
                            $("#staffing-job-type_" + index).html(data.job_type);
                        }
                    },
                    dataType: "json"
                });
            }
        }
    });

    $(".track-staffing-details-asset").live("change", function() {
        var id = $(this).attr("id");
        var index = id.split("_");
        index = index[index.length - 1];
        var asset = $(this).val();
        var planId = $("#staffing-plan-id").val();
        if (asset) {
            $.ajax({
                type: "POST",
                url: "/client/track-staffing/priorities/" + index,
                data: {
                    asset: asset,
                    plan_id: planId
                },
                success: function(data) {
                    if (data.success) {
                        $("#staffing-details-category_" + index).html(data.priorities);
                    }
                    else {
                        $("#staffing-details-category_" + index).find("option").remove().end().append('<option value="">----- Select -----</option>').val("");
                    }
                },
                dataType: "json"
            });
        }
        else {
            $("#staffing-details-category_" + index).find("option").remove().end().append('<option value="">----- Select -----</option>').val("");
        }
    });

    $(".track-staffing-details-discipline").live("change", function() {
        var id = $(this).attr("id");
        var index = id.split("_");
        index = index[index.length - 1];
        var discipline = $(this).val();
        var marketId = $("#staffing-market-id").val();
        if (discipline) {
            $.ajax({
                type: "POST",
                url: "/client/track-staffing/department/" + index,
                data: {
                    discipline: discipline,
                    market_id: marketId
                },
                success: function(data) {
                    if (data.success) {
                        $("#staffing-department_" + index).html(data.departments);
                    }
                    else {
                        $("#staffing-details-department-id_" + index).find("option").remove().end().append('<option value="">----- Select -----</option>').val("");
                    }
                    $("#staffing-details-job-title-id_" + index).find("option").remove().end().append('<option value="">----- Select -----</option>').val("");
                },
                dataType: "json"
            });
        }
        else {
            $("#staffing-details-department-id_" + index).find("option").remove().end().append('<option value="">----- Select -----</option>').val("");
            $("#staffing-details-job-title-id_" + index).find("option").remove().end().append('<option value="">----- Select -----</option>').val("");
        }
    });

    $(".track-staffing-details-department").live("change", function() {
        var id = $(this).attr("id");
        var index = id.split("_");
        index = index[index.length - 1];
        var department = $(this).val();
        var discipline = $("#staffing-details-discipline-id_" + index).val();
        var marketId = $("#staffing-market-id").val();

        if (marketId && discipline && department) {
            $.ajax({
                type: "POST",
                url: "/client/track-staffing/job-title/" + index,
                data: {
                    department: department,
                    discipline: discipline,
                    market_id: marketId
                },
                success: function(data) {
                    if (data.success) {
                        $("#staffing-job-title_" + index).html(data.job_titles);
                    }
                    else {
                        $("#staffing-details-job-title-id_" + index).find("option").remove().end().append('<option value="">----- Select -----</option>').val("");
                    }
                },
                dataType: "json"
            });
        }
        else {
            $("#staffing-details-job-title-id_" + index).find("option").remove().end().append('<option value="">----- Select -----</option>').val("");
        }
    });

    $("#add-more-staff-on-track").click(function() {
        $(this).attr("disabled", "disabled");
        var index = parseInt($("#total-staffing-details").val());
        index = index + 1;
        var id = $("#staffing-plan-id").val()
        $.ajax({
            type: "GET",
            url: "/client/" + id + "/track-staffing-details/" + index,
            success: function(data) {
                $("#total-staffing-details").val(index);
                $(data).hide().appendTo(".staff-list-on-track").fadeIn(2000);
                $("#add-more-staff-on-track").removeAttr("disabled");
                $("#staffing_details_" + index).find("input.auto-numeric").each(function() {
                    if (typeof $(this).data('autoNumeric') !== 'object') {
                        $(this).autoNumeric("init", {
                            vMax: '9999999999999.99',
                            aForm: true
                        });
                    }
                });
                $("#staffing-details-discipline-id_" + index).focus();
            },
            dataType: "html"
        });
    });
    /**************************************************************************/

    $("#client-track-import-plan-form").live("submit", function() {
        var valid = true, msg;
        if (!$("#reason").val()) {
            valid = false;
            msg = "Please enter some reason for the change order.";
        }
        if (!$("#client-import-plan-attachment").val()) {
            valid = false;
            if (!msg) {
                msg = "Please choose excel file first.";
            }
        }
        if (!valid) {
            alert(msg);
        }
        return valid;
    });

    $("#update-progress-import-plan-form").live("submit", function() {
        var valid = true, msg;
        if (!$("#track_start_date").val() || !$("#track_end_date").val()) {
            valid = false;
            if (!msg) {
                msg = "Please enter start date and end date both.";
            }
        }
        if (!$("#client-import-plan-attachment").val()) {
            valid = false;
            if (!msg) {
                msg = "Please choose excel file first.";
            }
        }

        if (!valid) {
            alert(msg);
        }
        return valid;
    });

});