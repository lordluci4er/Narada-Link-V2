import 'package:flutter/material.dart';

import '../controllers/home_controller.dart';
import '../utils/colors.dart';

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
  late final HomeController controller;

  @override
  void initState() {
    super.initState();

    controller = HomeController(
      jwt: widget.jwt,
      myId: widget.myId,
    )..init();
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
          appBar: _buildAppBar(),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.loadChats();
              },
              child: _buildBody(),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // APP BAR
  // --------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.background,
      title: const Text(
        "Chats",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO Search
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    );
  }

  // --------------------------------------------------
  // BODY
  // --------------------------------------------------

  Widget _buildBody() {
    if (controller.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.chats.isEmpty) {
      return EmptyStateWidget(
        jwt: widget.jwt,
        myId: widget.myId,
        onRefresh: controller.loadChats,
      );
    }

    return ChatListWidget(
      chats: controller.chats,
      myId: widget.myId,
      jwt: widget.jwt,
      formatTime: controller.formatChatTime,
      getStatusText: controller.getStatusText,
      onRefresh: controller.loadChats,
    );
  }
}