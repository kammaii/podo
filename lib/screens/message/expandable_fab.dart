import 'dart:math';
import 'package:flutter/material.dart';
import 'package:podo/values/my_colors.dart';

const Duration _duration = Duration(milliseconds: 300);

class ExpandableFab extends StatefulWidget {
  final double distance;
  final List<Widget> children;

  const ExpandableFab({Key? key, required this.distance, required this.children}) : super(key: key);

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  //애니메이션을 사용할 때 도움을 주는 class
  bool _open = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: _duration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    super.initState();
  }

  @override
  void dispose() {
    //메모리 낭비 방지
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          _buildTabToCloseFab(),
          _buildTabToOpenFab(),
        ]..insertAll(0, _buildExpandableActionButton()), //리스트에 추가할 때 ..
      ),
    );
  }

  List<_ExpandableActionButton> _buildExpandableActionButton() {
    List<_ExpandableActionButton> animChildren = [];
    final int count = widget.children.length;
    final double gap = 70.0 / (count - 1);

    for (var i = 0, degree = 10.0; i < count; i++, degree += gap) {
      animChildren.add(_ExpandableActionButton(
        distance: widget.distance,
        progress: _expandAnimation,
        child: widget.children[i],
        degree: degree,
      ));
    }
    return animChildren;
  }

  AnimatedContainer _buildTabToOpenFab() {
    return AnimatedContainer(
      duration: _duration,
      transformAlignment: Alignment.center,
      child: AnimatedOpacity(
        duration: _duration,
        opacity: _open ? 0.0 : 1.0,
        child: FloatingActionButton(
          backgroundColor: MyColors.purple,
          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () {
            toggle();
          },
        ),
      ),
    );
  }

  AnimatedContainer _buildTabToCloseFab() {
    return AnimatedContainer(
        duration: _duration,
        transformAlignment: Alignment.center,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            toggle();
          },
          child: const Icon(
            Icons.send,
            color: MyColors.purple,
          ),
        ));
  }

  void toggle() {
    _open = !_open;
    setState(() {
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
}

class _ExpandableActionButton extends StatelessWidget {
  final double distance;
  final double degree;
  final Animation<double> progress;
  final Widget child;

  const _ExpandableActionButton(
      {Key? key, required this.distance, required this.degree, required this.progress, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (context, _) {
        final Offset offset = Offset.fromDirection(degree * (pi / 180), progress.value * distance);
        return Positioned(
          right: offset.dx + 4,
          bottom: offset.dy + 4,
          child: child,
        );
      },
    );
  }
}
