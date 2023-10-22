import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrolleAble extends StatefulWidget {
  const ScrolleAble({Key? key}) : super(key: key);

  @override
  _ScrolleAbleState createState() => _ScrolleAbleState();
}

class _ScrolleAbleState extends State<ScrolleAble>
    with SingleTickerProviderStateMixin {
  bool showFab = true;
  late ScrollController _scrollController;
  late AnimationController _controller;
  late Animatable<Offset> _offsetTween;

  final _myListKey = GlobalKey<AnimatedListState>();

  List<String> items = List.generate(100, (index) => 'Item $index');

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _offsetTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      showFab = _scrollController.position.atEdge &&
          _scrollController.position.pixels != 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ScrollController"),
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.idle) {
            setState(() {
              showFab = _scrollController.offset <=
                  _scrollController.position.minScrollExtent;
            });
          }
          return true;
        },
        child: AnimatedList(
          controller: _scrollController,
          key: _myListKey,
          initialItemCount: items.length,
          itemBuilder:
              (BuildContext context, int index, Animation<double> animation) {
            final slideAnimation = _controller.drive(_offsetTween);

            return SlideTransition(
              position: slideAnimation,
              child: ListTile(
                title: Text(items[index]),
              ),
            );
          },
        ),
      ),
      floatingActionButton: showFab
          ? null
          : FloatingActionButton(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: showFab ? 50 : 150,
                height: 50,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_downward_outlined,
                  color: Colors.white,
                ),
              ),
              onPressed: () {},
            ),
    );
  }
}
