// Thanks to https://www.youtube.com/watch?time_continue=172&v=Aru-XvzzGjU&feature=emb_logo
document.addEventListener("turbolinks:load", function () {
  
  $(".sortable").sortable({
    items: "tr:not(.unmoveable)",
    update: function(e, ui) {
      if (this === ui.item.parent()[0]) { // This prevents the method from being called twice when moving between acts
        Rails.ajax({
          url: $(this).data("url")+"&move_perf="+e.toElement.id.substr(12),
          type: "PUT",
          data: $(this).sortable('serialize')
        });
      }
    },
    connectWith: $('.sortable')
  });
  
});
