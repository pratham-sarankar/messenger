import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/themes.dart';
import 'package:messenger/ui/page/home/page/chat/message_field/controller.dart';
import 'package:messenger/ui/page/home/widget/animated_button.dart';
import 'package:messenger/ui/page/home/widget/gallery_popup.dart';
import 'package:messenger/ui/widget/svg/svg.dart';
import 'package:messenger/ui/widget/widget_button.dart';
import 'package:messenger/util/platform_utils.dart';

import 'buttons.dart';

class MessageFieldMore extends StatelessWidget {
  const MessageFieldMore(this.c, {super.key});

  final MessageFieldController c;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return LayoutBuilder(builder: (context, constraints) {
      final Rect? rect = c.globalKey.globalPaintBounds;

      final double left = rect?.left ?? 0;
      final double right =
          rect == null ? 0 : (constraints.maxWidth - rect.right);
      final double bottom = rect == null
          ? 0
          : (constraints.maxHeight - rect.bottom + rect.height);

      final List<Widget> widgets = [];
      for (int i = 0; i < c.panel.length; ++i) {
        final e = c.panel.elementAt(i);

        widgets.add(
          Obx(() {
            final bool contains = c.buttons.contains(e);

            return _MenuButton(
              e,
              pinned: contains,
              onPinned: contains || c.canPin.value
                  ? () {
                      if (c.buttons.contains(e)) {
                        c.buttons.remove(e);
                      } else {
                        c.buttons.add(e);
                      }
                    }
                  : null,
              onPressed: () {
                c.removeEntries<MessageFieldMore>();
              },
            );
          }),
        );

        // if (i != c.panel.length - 1) {
        //   widgets.add(
        //     Container(
        //       height: 0.5,
        //       width: double.infinity,
        //       color: style.colors.onBackgroundOpacity7,
        //     ),
        //   );
        // }
      }

      final Widget actions = Column(
        mainAxisSize: MainAxisSize.min,
        children: widgets,
      );

      print('${rect?.width}');

      return Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Listener(
              onPointerDown: (_) {
                c.removeEntries<MessageFieldMore>();
              },
              child: Container(
                width: rect?.left ?? constraints.maxWidth,
                height: constraints.maxHeight,
                color: Colors.transparent,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Listener(
              onPointerDown: (_) {
                c.removeEntries<MessageFieldMore>();
              },
              child: Container(
                margin: EdgeInsets.only(
                  left: (rect?.left ?? constraints.maxWidth) + 50,
                ),
                // width: constraints.maxWidth - (rect?.right ?? 0) - 10,
                width: constraints.maxWidth -
                    (rect?.left ?? constraints.maxWidth) -
                    50,
                height: constraints.maxHeight,
                color: Colors.transparent,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Listener(
              onPointerDown: (_) {
                c.removeEntries<MessageFieldMore>();
              },
              child: Container(
                margin:
                    EdgeInsets.only(left: (rect?.left ?? constraints.maxWidth)),
                // width: constraints.maxWidth - (rect?.right ?? 0) - 10,
                width: 50,
                height: rect?.top ?? 0,
                color: Colors.transparent,
              ),
            ),
          ),
          // Align(
          //   alignment: Alignment.topLeft,
          //   child: Listener(
          //     onPointerDown: (_) {
          //       c.removeEntries<MessageFieldMore>();
          //     },
          //     child: Container(
          //       margin: EdgeInsets.only(
          //         left: (rect?.left ?? constraints.maxWidth),
          //         top: rect?.top ?? 0,
          //       ),
          //       // width: constraints.maxWidth - (rect?.right ?? 0) - 10,
          //       width: 50,
          //       height: (rect?.height ?? 0) + 5,
          //       color: Colors.transparent,
          //     ),
          //   ),
          // ),
          Positioned(
            left: left,
            right: context.isNarrow ? right : null,
            bottom: bottom + 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: style.cardRadius,
                boxShadow: [
                  CustomBoxShadow(
                    blurRadius: 8,
                    color: style.colors.onBackgroundOpacity13,
                  ),
                ],
              ),
              child:
                  context.isNarrow ? actions : IntrinsicWidth(child: actions),
            ),
          ),
        ],
      );
    });
  }
}

class _MenuButton extends StatefulWidget {
  const _MenuButton(
    this.button, {
    this.onPressed,
    this.onPinned,
    this.pinned = false,
  });

  final ChatButton button;
  final void Function()? onPressed;
  final void Function()? onPinned;
  final bool pinned;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      opaque: false,
      child: WidgetButton(
        onDown: (_) => setState(() => _pressed = true),
        onUp: (_) => setState(() => _pressed = false),
        onPressed: () {
          widget.button.onPressed?.call(false);
          widget.onPressed?.call();
        },
        child: Container(
          width: double.infinity,
          color:
              _hovered || _pressed ? style.colors.onBackgroundOpacity2 : null,
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 16),
              SizedBox(
                width: 26,
                child: (widget.button.icon == null)
                    ? Transform.translate(
                        offset: widget.button.offsetMini,
                        child: SvgImage.asset(
                          'assets/icons/${widget.button.assetMini ?? widget.button.asset}.svg',
                          width: widget.button.assetMiniWidth ??
                              widget.button.assetWidth,
                          height: widget.button.assetMiniHeight ??
                              widget.button.assetHeight,
                        ),
                      )
                    : Icon(
                        widget.button.icon ?? Icons.attach_email,
                        size: 28,
                        color: style.colors.primary,
                      ),
              ),
              // SvgImage.asset(
              //   'assets/icons/${e.asset}.svg',
              //   width: 60,
              //   height: 60,
              // ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  widget.button.hint,
                  style: TextStyle(
                    fontSize: 17,
                    color: style.colors.primary,
                  ),
                ),
              ),
              const Spacer(),
              const SizedBox(width: 16),
              WidgetButton(
                onPressed: widget.onPinned ?? () {},
                child: SizedBox(
                  // color: Colors.red,
                  height: 40,
                  width: 40,
                  child: Center(
                    child: AnimatedButton(
                      child: AnimatedSwitcher(
                        duration: 100.milliseconds,
                        child: widget.pinned
                            ? SvgImage.asset(
                                'assets/icons/unpin4.svg',
                                key: const Key('Unpin'),
                                width: 15.5,
                                height: 17,
                              )
                            : Transform.translate(
                                offset: const Offset(0.5, 0),
                                child: SvgImage.asset(
                                  'assets/icons/pin2${widget.onPinned != null ? '' : '_disabled'}.svg',
                                  key: const Key('Pin'),
                                  width: 9.65,
                                  height: 17,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
