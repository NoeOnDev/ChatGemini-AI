class Gif {
  final String id;
  final String url;

  Gif({required this.id, required this.url});

  factory Gif.fromJson(Map<String, dynamic> json) {
    return Gif(
      id: json['id'],
      url: json['images']['downsized']['url'],
    );
  }
}
