function fading() {
  
  var maskHeight = $(document).height();
  var maskWidth = $(window).width();
  
  $('#mask').css({'width':maskWidth,'height':maskHeight});
  
  $('#mask').fadeTo("fast",0.6);
  
  
  var winH = $(window).height();
  var winW = $(window).width();
  
  $('#searching').css('top',  winH/2-$('#searching').height()/2);
  $('#searching').css('left', winW/2-$('#searching').width()/2);
  $('#searching').fadeIn(2000)
}

function unfading() {
  $('#searching').hide();
  $('#mask').hide();
}

function select() {
  //var hide = false;
  var min_price = +$('#select_price_min').attr("value");
  var max_price = +$('#select_price_max').attr("value");
  var min_changes = +$('#select_changes_min').attr("value");
  var max_changes = +$('#select_changes_max').attr("value");
  var min_total_time = +$('#select_days_min').attr("value")*60*60*24 + +$('#select_hours_min').attr("value")*60*60;
  var max_total_time = +$('#select_days_max').attr("value")*60*60*24 + +$('#select_hours_max').attr("value")*60*60;
  var min_pending_time = +$('#select_pend_days_min').attr("value")*60*60*24 + +$('#select_pend_hours_min').attr("value")*60*60;
  var max_pending_time = +$('#select_pend_days_max').attr("value")*60*60*24 + +$('#select_pend_hours_max').attr("value")*60*60;
  
 // alert("max_price= "+max_price+ "  min_price= "+ min_price);
  $('.full_fly').each( function (i) {
//    alert("max_price= "+max_price+ "  min_price= "+ min_price + " цена= "+$(this).find("#price").html() + "цена > max_price =  " + ($(this).find("#price").html() > max_price)+ "цена < min_price =  " + ($(this).find("#price").html() < min_price));
//  alert("max_changes= "+max_changes+ "  track_count-1= "+ $(this).find("#track_count").html() + "     tr_count-1 > max_changes = " + (+$(this).find("#track_count").html() > max_changes));
    if (  +$(this).find("#price").html() < min_price ||
          +$(this).find("#price").html() > max_price ||
          +$(this).find("#track_count").html() < min_changes ||
          +$(this).find("#track_count").html() > max_changes ||
          +$(this).find("#total_time").html() < min_total_time ||
          +$(this).find("#total_time").html() > max_total_time ||
          +$(this).find("#total_pending_time").html() < min_pending_time ||
          +$(this).find("#total_pending_time").html() > max_pending_time) {
      this.style.display="none";
    } else {
      this.style.display="";
    }
  });  
}