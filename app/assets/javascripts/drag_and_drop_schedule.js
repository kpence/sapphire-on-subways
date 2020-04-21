// Thanks to https://www.youtube.com/watch?time_continue=172&v=Aru-XvzzGjU&feature=emb_logo
document.addEventListener("turbolinks:load", function () {
  var awaitingDroppable = false;
  
  $(".droppable").droppable({
    accept: ".sortable tr",
    hoverClass: "droppable-hover",
    drop: function(e, ui) {
      console.log("DROPPABLE", $(".sortable").sortable('serialize'), ui)
      awaitingDroppable = true;
      Rails.ajax({
			url: $(this).data("url")+"&move_perf="+ui.draggable[0].id.substr(12),
        type: "PUT",
        data: $(".sortable").sortable('serialize'),
      })
    }
  });

  $(".sortable").sortable({
    items: "tr:not(.unmoveable)",
    update: function(e, ui) {
      if (!awaitingDroppable && this === ui.item.parent()[0]) { // This prevents the method from being called twice when moving between acts
        Rails.ajax({
					url: $(this).data("url")+"&move_perf="+ui.item[0].id.substr(12),
          type: "PUT",
          data: $(this).sortable('serialize'),
        });
      }
    },
    connectWith: $('.sortable')
  });
  
});
