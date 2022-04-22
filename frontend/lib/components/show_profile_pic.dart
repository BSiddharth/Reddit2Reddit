import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShowProfilePicture extends StatelessWidget {
  const ShowProfilePicture({
    required this.url,
    this.dimension = 140,
    Key? key,
  }) : super(key: key);
  final String url;
  final double dimension;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 500),
      fadeOutDuration: const Duration(milliseconds: 500),
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          border: Border.all(
            color: Colors.redAccent,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        width: dimension,
        height: dimension,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
      ),
      errorWidget: (context, url, error) => Container(
          width: dimension,
          height: dimension,
          color: Colors.black,
          child: const Center(
              child: Icon(
            Icons.error,
            color: Colors.redAccent,
          ))),
    );
  }
}
