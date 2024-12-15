import 'package:alert_info/src/utils/alerte_helper.dart';
import 'package:alert_info/src/widgets/alerte_info_animated.dart';
import 'package:alert_info/src/utils/holder_widget.dart';
import 'package:flutter/material.dart';

class AlerteInfoWidget extends StatefulWidget {
  final VoidCallback onDismissed;
  final AlerteHelper alerteHelper;

  const AlerteInfoWidget({
    super.key,
    required this.onDismissed,
    required this.alerteHelper,
  });

  @override
  State<AlerteInfoWidget> createState() => _AlerteInfoWidgetState();
}

class _AlerteInfoWidgetState extends State<AlerteInfoWidget>
    with TickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  final GlobalKey _textKey = GlobalKey();
  bool isInnited = false;
  late double finalHeight;
  late double finalWidth;
  late double textWidth;
  late double textHeight;
  bool _isDissmissed = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await _controller.forward();
      Future.delayed(Duration(seconds: widget.alerteHelper.duration)).then((_) {
        if (mounted && !_isDissmissed) {
          _controller.reverse();
        }
      });
    } on TickerCanceled {
      //Ticker canceled
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInnited) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        finalHeight = _globalKey.currentContext!.size!.height;
        finalWidth = _globalKey.currentContext!.size!.width;
        textWidth = _textKey.currentContext!.size!.width;
        textHeight = _textKey.currentContext!.size!.height;
        _playAnimation();
        setState(() {
          isInnited = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!isInnited)
          Positioned(
            top: -widget.alerteHelper.maxWidth,
            child: HolderWidget(
              globalKey: _globalKey,
              textKey: _textKey,
              alerteHelper: widget.alerteHelper,
            ),
          ),
        if (isInnited)
          AlerteInfoAnimated(
            alerteHelper: widget.alerteHelper,
            controller: _controller.view,
            finalWidth: finalWidth,
            finalHeight: finalHeight,
            textWidth: textWidth,
            textHeight: textHeight,
            onDismissed: () {
              _isDissmissed = true;
              _controller.stop();
              widget.onDismissed();
            },
          ),
      ],
    );
  }
}
