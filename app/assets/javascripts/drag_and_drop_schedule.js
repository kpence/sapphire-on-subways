// Thanks to https://www.youtube.com/watch?time_continue=172&v=Aru-XvzzGjU&feature=emb_logo
document.addEventListener("turbolinks:load", function () {
  
  $(".sortable").sortable({
    update: function(e, ui) {
      //console.log($(this).sortable('serialize'));
      Rails.ajax({
        url: $(this).data("url"),
        type: "PUT",
        data: $(this).sortable('serialize')
      });
    }
  });
  
});