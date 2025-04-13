import 'package:flutter/material.dart';

class FriendCard extends StatelessWidget {
  static const String defaultPhoto = 
    "https://www.clipartmax.com/png/middle/214-2143742_individuals-whatsapp-profile-picture-icon.png";

  final String? name;
  final String? home;
  final String? photo;

  const FriendCard({
    super.key,
    required this.name,
    required this.home,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 75,
          width: 75,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(photo ?? defaultPhoto),
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? "",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 25),
                    child: Text(
                      home ?? "",
                      style: const TextStyle(fontSize: 14),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
      ],
    );
  }
}