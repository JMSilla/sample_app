$(document).ready(function() {
  $("#counter").html(140 - $("#micropost_content").val().length);
  actualizarColorContador();
  $("#micropost_content").keyup(function(event) {
    // alert($(this).val().length);
    $("#counter").html(140 - $(this).val().length);
    actualizarColorContador();
  });

  $("#micropost_content").keypress(function(event) {
    // alert($(this).val().length);
    if (event.which == 13 )
      return false;
  });

  function actualizarColorContador(){
    if ($("#micropost_content").val().length > 140)
      $("#counter").css('color', 'red');
    else
      $("#counter").css('color', 'blue'); 
  }
});	