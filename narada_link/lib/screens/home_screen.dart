import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../controllers/home_controller.dart';

// widgets
import '../widgets/chat_list_widget.dart';
import '../widgets/empty_state_widget.dart';

class HomeScreen extends StatefulWidget {
  final String jwt;
  final String myId;

  const HomeScreen({
    super.key,
    required this.jwt,
    required this.myId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController controller;

  @override
  void initState() {
    super.initState();

    /// ✅ INIT CONTROLLER
    controller = HomeController(
      jwt: widget.jwt,
      myId: widget.myId,
    );

    controller.init();
  }

  @override
  void dispose() {
    controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,

          body: SafeArea(
            child: controller.loading
                ? const Center(child: CircularProgressIndicator())

                /// 🔥 EMPTY STATE
                : controller.chats.isEmpty
                    ? EmptyStateWidget(
                        jwt: widget.jwt,
                        myId: widget.myId,
                        onRefresh: controller.loadChats,
                      )

                    /// 🔥 CHAT LIST ✅ FIXED
                    : ChatListWidget(
                        chats: controller.chats,
                        myId: widget.myId,
                        jwt: widget.jwt,
                        formatTime: controller.formatChatTime,
                        getStatusText: controller.getStatusText,
                        onRefresh: controller.loadChats,
                      ),
          ),
        );
      },
    );
  }
}