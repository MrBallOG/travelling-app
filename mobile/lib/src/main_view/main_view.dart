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
  late int viewIndex;
  late List<Widget> views;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    viewIndex = 0;
    views = const [
      ProfileView(),
      SampleItemListView(),
    ];
    pageController = PageController(initialPage: viewIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  changeView(int index) {
    setState(
      () {
        viewIndex = index;
        pageController.jumpToPage(index);
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
        type: BottomNavigationBarType.fixed,
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
