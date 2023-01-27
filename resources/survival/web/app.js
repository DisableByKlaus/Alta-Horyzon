$(function () {
  window.addEventListener('message', function (event) {
    var convertedMinutes = event.data.deathtimer
    var convertedSeconds = event.data.deathtimer

    convertedMinutes = Math.floor(event.data.deathtimer / 60)
    convertedSeconds = Math.floor(event.data.deathtimer % 60)

    var item = event.data;
 
    if (item.setDisplay) {
      $('.inventory').css('display', 'block');
      $('.textclock').html(`${convertedMinutes}:${convertedSeconds}`);
    } else {
      $('.inventory').css('display', 'none');
    }
  });
});