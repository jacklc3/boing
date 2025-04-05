import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String headerText;
  final String descriptionText;
  const TaskCard({
    super.key,
    required this.headerText,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20.0).copyWith(
        left: 15,
      ),
      decoration: const BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headerText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 25),
              child: Text(
                descriptionText,
                style: const TextStyle(fontSize: 14),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}