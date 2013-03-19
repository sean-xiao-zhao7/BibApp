$jq(
  get_google_links()
)

function get_google_links() {
  $jq('span.google-book').each(function() {
    get_google_link(this)
  })

}

function get_google_link(span) {
  var isbn = span.attr('title');
  //lookup stuff
  var link_url = 'http://books.google.com/books?id=0JA_uAAACAAJ&dq=isbn:9780470189481&hl=&cd=1&source=gbs_api';
  var image_url = 'http://bks3.books.google.com/books?id=0JA_uAAACAAJ&printsec=frontcover&img=1&zoom=5&source=gbs_api';
  var image = document.createElement('img');
  image.attr('src', image_url);
  var link = document.createElement('a');
  link.attr('href', link_url);
  link.append(image);
  span.append(link);
}