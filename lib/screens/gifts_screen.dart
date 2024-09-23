import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models//gift.dart';

class GifsScreen extends StatefulWidget {
  const GifsScreen({super.key});

  @override
  GifsScreenState createState() => GifsScreenState();
}

class GifsScreenState extends State<GifsScreen> {
  final List<Gif> _gifs = [];
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;
  final ScrollController _scrollController = ScrollController();
  final String _apiKey = '61iu719SrBMpJopEpyBNVjc6LLVW53Bz';

  @override
  void initState() {
    super.initState();
    _fetchGifs();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchGifs();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchGifs() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://api.giphy.com/v1/gifs/trending?api_key=$_apiKey&limit=$_limit&offset=${_page * _limit}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<Gif> fetchedGifs = (jsonResponse['data'] as List)
          .map((gif) => Gif.fromJson(gif))
          .toList();

      setState(() {
        _gifs.addAll(fetchedGifs);
        _page++;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load gifs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIFs'),
      ),
      body: _gifs.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _gifs.length + 1,
              itemBuilder: (context, index) {
                if (index == _gifs.length) {
                  return _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }

                return Image.network(
                  _gifs[index].url,
                  fit: BoxFit.cover,
                );
              },
            ),
    );
  }
}
