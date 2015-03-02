// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//(function(){
//    if (!window.console || !console.firebug) {
//        var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
//        "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];
//
//        window.console = {};
//        for (var i = 0; i < names.length; ++i)
//            window.console[names[i]] = function() {}
//    }
//})();

function new_row(table_id){

    $("#"+table_id+" tr:last").clone(true).insertAfter("#"+table_id+" tr:last");

    $("#"+table_id+" tr:last input").attr("value","");
    $("#"+table_id+" tr:last input").removeAttr("checked");
}

function load_filter_content(model,action,search, destiny, next){
    next = next || function(){};
    $(destiny).load("/"+model+"/"+action,{
        "filter": search
    }, next)
}

function create_and_append_content(model,action,search, destiny){
    $.post("/"+model+"/",{
        "filter": search
    },
    function(data){
        $(destiny).append(data);
    })
}

function bill_update_success(data){
    $('#bill_submit_'+data.bill.id).hide();
    $("#bill_submit_"+data.bill.id).parent().find("span.error").hide();
    $('#'+data.bill.id).show();

    var edit=""
    if(data.bill.charged)
        edit="disabled"
    
    $("#bill_cod_"+data.bill.id).attr("disabled",edit)
    load_filter_content("offers","render_comments",data.bill.offer_id, '#comments')
}

function bill_update_error(data,form){
    form.find("span.error img").show();
    form.find("span.error").show();    
}

function offer_update_feedback(data){
    $('#offer_submit').hide();
    if ($('#'+data.offer.id).attr("feedback") != "disable")
        $('#'+data.offer.id).show();
    else $('#'+data.offer.id).attr("feedback","enable")
}

function add_comment(model, action, obj_id){
    var offer_comment = {
        id: obj_id,
        text: $('#comment').val()
        }
    load_filter_content(model,action,offer_comment, '#comments')
    $('#comment').val('')
}

function highlight_rows($table, position){
    $("> tbody > tr", $table).removeClass(position);
    $("> tbody > tr:"+position, $table).addClass(position);
}