import 'package:flutter/material.dart';

class Piece extends StatefulWidget {
  final int? posX, posY, size;
  final Color? color;
  final bool? isAnimated;
  const Piece({Key? key, this.color, this.posX, this.posY, this.size,this.isAnimated=false})
      : super(key: key);

  @override
  State<Piece> createState() => _PieceState();
}

class _PieceState extends State<Piece> with SingleTickerProviderStateMixin {
 late AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      lowerBound: 0.25,
      upperBound: 1.0,
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.posY!.toDouble(),
      left: widget.posX!.toDouble(),
      child: Opacity(
        opacity:  widget.isAnimated! ? _animationController.value : 1,
        child: Container(
          height: widget.size!.toDouble(),
          width: widget.size!.toDouble(),
          decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(width: 2.0, color: Colors.white)),
        ),
      ),
    );
  }
}
