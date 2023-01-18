import 'package:flutter/material.dart';
import 'package:mobile/src/profile/profile_view.dart' show ProfileView;
import 'package:mobile/src/sample_feature/sample_item_list_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  static const routeName = '/';

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int viewIndex = 0;
  List<Widget> views = const [ProfileView(), SampleItemListView()];
  PageController pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  changeView(int index) {
    setState(
      () {
        viewIndex = index;
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  changeIndex(int index) {
    setState(
      () {
        viewIndex = index;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        onPageChanged: (index) => changeIndex(index),
        itemCount: views.length,
        itemBuilder: (context, index) => views[index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viewIndex,
        onTap: (index) => changeView(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "Badges",
          ),
        ],
      ),
    );
  }
}
