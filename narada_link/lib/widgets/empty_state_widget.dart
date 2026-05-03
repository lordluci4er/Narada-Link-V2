import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../screens/search_screen.dart';

class EmptyStateWidget extends StatelessWidget {
  final String jwt;
  final String myId;
  final VoidCallback onRefresh;

  const EmptyStateWidget({
    super.key,
    required this.jwt,
    required this.myId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),

          const Text(
            "No conversations yet",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchScreen(
                    jwt: jwt,
                    myId: myId,
                  ),
                ),
              ).then((_) => onRefresh());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Find People",
                style: TextStyle(
                  color: AppColors.background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}