import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/Models/Movie.dart';
import 'package:http/http.dart';
import 'package:movies/src/Validators/TextInputValidator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
        accentColor: Colors.orange[200],
        scaffoldBackgroundColor: const Color(0xFFF3F5F7),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Movie> _movies = <Movie>[];
  List<Movie> _filteredMovies = <Movie>[];

  bool _seeAll = false;
  bool _showFilters = false;
  bool _activeFilter = false;
  bool _existsPreviousFilter = false;

  String _ratingUserInput;
  String _yearUserInput;

  String _ratingErrorMessage;
  String _yearErrorMessage;

  final TextInputValidator _textInputValidator = TextInputValidator();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    setState(() {
      super.initState();
      getJsonData();
    });
  }

  int _setNumberOfMoviesToDisplay() {
    int numberOfMovies;

    if (_movies.isEmpty) {
      numberOfMovies = 0;
    }

    if (_movies.isNotEmpty && _seeAll) {
      numberOfMovies = _movies.length;
    }

    if (_movies.isNotEmpty && !_seeAll) {
      numberOfMovies = 5;
    }

    return numberOfMovies;
  }

  List<Movie> _filterMoviesByRating(double minRating) {
    return _movies.where((Movie movie) => movie.rating >= minRating).toList();
  }

  List<Movie> _filterMoviesByYear(int year) {
    return _movies.where((Movie movie) => movie.year == year).toList();
  }

  List<Movie> _filterMoviesByRatingAndYear(double rating, int year) {
    return _movies.where((Movie movie) => movie.rating >= rating && movie.year == year).toList();
  }

  List<Movie> _filterMovies(String rating, String year) {
    if (_textInputValidator.isValidRating(rating) && !_textInputValidator.isValidYear(year)) {
      return _filterMoviesByRating(double.tryParse(rating));
    }

    if (_textInputValidator.isValidYear(year) && !_textInputValidator.isValidRating(rating)) {
      return _filterMoviesByYear(int.tryParse(year));
    }

    if (_textInputValidator.isValidRating(rating) && _textInputValidator.isValidYear(year)) {
      return _filterMoviesByRatingAndYear(double.tryParse(rating), int.tryParse(year));
    }

    return _movies;
  }

  bool _isFieldEmpty(String input) {
    return input == null || input.isEmpty;
  }

  bool _verifyFields() {
    if (_isFieldEmpty(_ratingUserInput) && _isFieldEmpty(_yearUserInput)) {
      _ratingErrorMessage = _textInputValidator.setRatingErrorMessage(_ratingUserInput);
      _yearErrorMessage = _textInputValidator.setYearErrorMessage(_yearUserInput);
      return false;
    }

    if (!_isFieldEmpty(_ratingUserInput) && !_isFieldEmpty(_yearUserInput)) {
      if (!_textInputValidator.isValidRating(_ratingUserInput)) {
        _ratingErrorMessage = _textInputValidator.setRatingErrorMessage(_ratingUserInput);
        return false;
      }

      if (!_textInputValidator.isValidYear(_yearUserInput)) {
        _yearErrorMessage = _textInputValidator.setYearErrorMessage(_yearUserInput);
        return false;
      }
    }

    if (!_isFieldEmpty(_ratingUserInput) && _isFieldEmpty(_yearUserInput)) {
      if (!_textInputValidator.isValidRating(_ratingUserInput)) {
        _ratingErrorMessage = _textInputValidator.setRatingErrorMessage(_ratingUserInput);
        _yearErrorMessage = null;
        return false;
      }
    }

    if (!_isFieldEmpty(_yearUserInput) && _isFieldEmpty(_ratingUserInput)) {
      if (!_textInputValidator.isValidYear(_yearUserInput)) {
        _yearErrorMessage = _textInputValidator.setYearErrorMessage(_yearUserInput);
        _ratingErrorMessage = null;
        return false;
      }
    }

    return true;
  }

  void _clearFields() {
    _ratingController.clear();
    _yearController.clear();
    _ratingErrorMessage = null;
    _yearErrorMessage = null;
    _ratingUserInput = null;
    _yearUserInput = null;
  }

  Future<void> getJsonData() async {
    final Response response = await get('https://yts.mx/api/v2/list_movies.json');

    final Map<String, dynamic> jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final List<dynamic> jsonMovies = jsonData['data']['movies'];

    setState(() {
      _movies = jsonMovies.map((dynamic item) => Movie.fromJson(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('yts.mx movies'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Movies',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeFilter = false;
                      _showFilters = !_showFilters;
                    });
                  },
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (_showFilters) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _ratingController,
                    decoration: InputDecoration(
                      hintText: 'Minimum Rating',
                      errorText: _ratingErrorMessage,
                    ),
                    onChanged: (String value) {
                      setState(() {
                        _ratingUserInput = value;
                      });
                    },
                  ),
                  const SizedBox(height: 5.0),
                  TextField(
                    controller: _yearController,
                    decoration: InputDecoration(
                      hintText: 'Year',
                      errorText: _yearErrorMessage,
                    ),
                    onChanged: (String value) {
                      setState(() {
                        _yearUserInput = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!_verifyFields()) {
                            return;
                          }

                          _filteredMovies = _filterMovies(_ratingUserInput, _yearUserInput);

                          _activeFilter = true;
                          _existsPreviousFilter = true;
                          _showFilters = false;

                          _clearFields();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Apply Filter',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_activeFilter && _filteredMovies.isEmpty) ...<Widget>[
            const Expanded(
              child: Center(
                child: Text(
                  'There are no movies',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ] else
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount:
                    _existsPreviousFilter && _activeFilter ? _filteredMovies.length : _setNumberOfMoviesToDisplay(),
                padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                itemBuilder: (BuildContext context, int index) {
                  final Movie currentMovie =
                      _existsPreviousFilter && _activeFilter ? _filteredMovies[index] : _movies[index];
                  return Stack(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.fromLTRB(40.0, 5.0, 20.0, 5.0),
                        height: 200.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(100.0, 20.0, 20.0, 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 120.0,
                                    child: Text(
                                      currentMovie.title,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        '${currentMovie.rating}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Text('rating')
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                '${currentMovie.year}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10.0),
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: currentMovie.genres.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Text(
                                      '${currentMovie.genres[index]} ',
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20.0,
                        top: 15.0,
                        bottom: 15.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image(
                            width: 110.0,
                            image: NetworkImage(currentMovie.coverImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 96.0),
            child: RaisedButton(
              onPressed: () {
                setState(() {
                  _seeAll = true;
                  _activeFilter = false;
                  _showFilters = false;
                });
              },
              color: Theme.of(context).primaryColor,
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
