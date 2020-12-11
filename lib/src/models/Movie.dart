class Movie {
  Movie({this.title, this.year, this.genres, this.rating, this.coverImageUrl});

  Movie.fromJson(dynamic item)
      : title = item['title'],
        year = item['year'],
        genres = List<String>.from(item['genres']),
        rating = item['rating'].toDouble(),
        coverImageUrl = item['medium_cover_image'];

  final String title;
  final int year;
  final List<String> genres;
  final double rating;
  final String coverImageUrl;

  @override
  String toString() {
    return 'Movie{title: $title, year: $year, genres: $genres}';
  }
}
