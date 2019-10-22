import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final int _startingTabCount = 4;

  List<Tab> _tabs = List<Tab>();
  List<Widget> _generalWidgets = List<Widget>();
  TabController _tabController;

  @override
  void initState() {
    _tabs = getTabs(_startingTabCount);
    _tabController = getTabController();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dynamic TBV"),
        bottom: TabBar(
          tabs: _tabs,
          controller: _tabController,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addIfCanAnotherTab,
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: _removeTab,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: getWidgets(),
            ),
          ),
          Row(
            children: <Widget>[
              if (!isFirstPage())
                Expanded(
                  child: RaisedButton(child: Text("Back"), onPressed: goToPreviousPage),
                ),
              Expanded(
                child: RaisedButton(child: Text(isLastPage() ? "Finish" : "Next"), onPressed: goToNextPage),
              )
            ],
          )
        ],
      ),
    );
  }

  TabController getTabController() {
    return TabController(length: _tabs.length, vsync: this)..addListener(_updatePage);
  }

  Tab getTab(int widgetNumber) {
    return Tab(
      text: "$widgetNumber",
    );
  }

  Widget getWidget(int widgetNumber) {
    return Center(
      child: Text("Widget nr: $widgetNumber"),
    );
  }

  List<Tab> getTabs(int count) {
    _tabs.clear();
    for (int i = 0; i < count; i++) {
      _tabs.add(getTab(i));
    }
    return _tabs;
  }

  List<Widget> getWidgets() {
    _generalWidgets.clear();
    for (int i = 0; i < _tabs.length; i++) {
      _generalWidgets.add(getWidget(i));
    }
    return _generalWidgets;
  }

  void _addIfCanAnotherTab() {
    if (_startingTabCount == _tabController.length) {
      showWarningTabAddDialog();
    } else {
      _addAnotherTab();
    }
  }

  void _addAnotherTab() {
    _tabs = getTabs(_tabs.length + 1);
    _tabController.index = 0;
    _tabController = getTabController();
    _updatePage();
  }

  void _removeTab() {
    _tabs = getTabs(_tabs.length - 1);
    _tabController.index = 0;
    _tabController = getTabController();
    _updatePage();
  }

  void _updatePage() {
    setState(() {});
  }

  //Tab helpers

  bool isFirstPage() {
    return _tabController.index == 0;
  }

  bool isLastPage() {
    return _tabController.index == _tabController.length - 1;
  }

  void goToPreviousPage() {
    _tabController.animateTo(_tabController.index - 1);
  }

  void goToNextPage() {
    isLastPage()
        ? showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(title: Text("End reached"), content: Text("Thank you for playing around!")))
        : _tabController.animateTo(_tabController.index + 1);
  }

  void showWarningTabAddDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Cannot add more tabs"),
              content: Text("Let's avoid crashing, shall we?"),
              actions: <Widget>[
                FlatButton(
                    child: Text("Crash it!"),
                    onPressed: () {
                      _addAnotherTab();
                      Navigator.pop(context);
                    }),
                FlatButton(child: Text("Ok"), onPressed: () => Navigator.pop(context))
              ],
            ));
  }
}
