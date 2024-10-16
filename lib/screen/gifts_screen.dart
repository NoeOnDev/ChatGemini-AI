import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/gift.dart';

class GiftsScreen extends StatefulWidget {
  const GiftsScreen({super.key});

  @override
  GiftsScreenState createState() => GiftsScreenState();
}

class GiftsScreenState extends State<GiftsScreen> {
  final List<Gif> _gifts = [];
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;
  final ScrollController _scrollController = ScrollController();
  final String _apiKey = '61iu719SrBMpJopEpyBNVjc6LLVW53Bz';

  @override
  void initState() {
    super.initState();
    _fetchGifts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchGifts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchGifts() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://api.giphy.com/v1/gifs/trending?api_key=$_apiKey&limit=$_limit&offset=${_page * _limit}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<Gif> fetchedGifts = (jsonResponse['data'] as List)
          .map((gif) => Gif.fromJson(gif))
          .toList();

      setState(() {
        _gifts.addAll(fetchedGifts);
        _page++;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load gifts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIFs'),
      ),
      body: _gifts.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _gifts.length + 1,
              itemBuilder: (context, index) {
                if (index == _gifts.length) {
                  return _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }

                return Image.network(
                  _gifts[index].url,
                  fit: BoxFit.cover,
                );
              },
            ),
    );
  }
}
