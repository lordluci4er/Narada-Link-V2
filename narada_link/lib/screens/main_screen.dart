import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../widgets/custom_bottom_nav.dart';

import 'home_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String jwt;

  const MainScreen({
    super.key,
    required this.jwt,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  String? myId;

  bool loading = true;
  bool hasError = false;

  DateTime? lastBackPressed;

  late final List<Widget?> screens;

  @override
  void initState() {
    super.initState();

    screens = List.generate(3, (_) => null);

    initUser();
  }

  // --------------------------------------------------
  // INIT USER
  // --------------------------------------------------

  Future<void> initUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      currentIndex = prefs.getInt("last_tab") ?? 0;

      final user = await ApiService.getMe(widget.jwt);

      if (user == null || user['_id'] == null) {
        hasError = true;
      } else {
        myId = user['_id'].toString();

        _initScreen(currentIndex);
      }
    } catch (_) {
      hasError = true;
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  // --------------------------------------------------
  // LAZY TAB INIT
  // --------------------------------------------------

  void _initScreen(int index) {
    if (screens[index] != null) return;

    switch (index) {
      case 0:
        screens[index] = HomeScreen(
          jwt: widget.jwt,
          myId: myId!,
        );
        break;

      case 1:
        screens[index] = SearchScreen(
          jwt: widget.jwt,
          myId: myId!,
        );
        break;

      case 2:
        screens[index] = ProfileScreen(
          jwt: widget.jwt,
        );
        break;
    }
  }

  // --------------------------------------------------
  // CHANGE TAB
  // --------------------------------------------------

  Future<void> _changeTab(int index) async {
    HapticFeedback.lightImpact();

    _initScreen(index);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("last_tab", index);

    setState(() {
      currentIndex = index;
    });
  }

  // --------------------------------------------------
  // DOUBLE BACK TO EXIT
  // --------------------------------------------------

  Future<bool> _onWillPop() async {
    if (currentIndex != 0) {
      _changeTab(0);
      return false;
    }

    final now = DateTime.now();

    if (lastBackPressed == null ||
        now.difference(lastBackPressed!) >
            const Duration(seconds: 2)) {
      lastBackPressed = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Press back again to exit",
          ),
          duration: Duration(seconds: 2),
        ),
      );

      return false;
    }

    return true;
  }

  // --------------------------------------------------
  // LOADING SCREEN
  // --------------------------------------------------

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ERROR SCREEN
  // --------------------------------------------------

  Widget _buildError() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 70,
              ),

              const SizedBox(height: 16),

              const Text(
                "Unable to load profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    loading = true;
                    hasError = false;
                  });

                  initUser();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // MAIN UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _buildLoading();
    }

    if (hasError) {
      return _buildError();
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff121212),
              Color(0xff1B1B1B),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,

          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: IndexedStack(
              key: ValueKey(currentIndex),
              index: currentIndex,
              children: [
                screens[0] ?? const SizedBox(),
                screens[1] ?? const SizedBox(),
                screens[2] ?? const SizedBox(),
              ],
            ),
          ),

          bottomNavigationBar: CustomBottomNav(
            currentIndex: currentIndex,
            onTap: _changeTab,
          ),
        ),
      ),
    );
  }
}