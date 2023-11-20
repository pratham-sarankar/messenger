import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:messenger/themes.dart';
import 'package:messenger/ui/widget/widget_button.dart';

class CustomSlidable extends StatelessWidget {
  const CustomSlidable({
    super.key,
    this.groupTag,
    this.actions = const [],
    required this.child,
  });

  final Object? groupTag;
  final List<CustomAction> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      groupTag: groupTag,
      endActionPane: ActionPane(
        extentRatio: 0.33,
        motion: const StretchMotion(),
        children: actions,
      ),
      child: Builder(builder: (context) {
        return child;
        // return AnimatedBuilder(
        //   animation: Slidable.of(context)!.animation,
        //   builder: (context, child) {
        //     if (Slidable.of(context)?.ratio != 0) {
        //       return GestureDetector(
        //         behavior: HitTestBehavior.translucent,
        //         onTap: () => Slidable.of(context)!.close(),
        //         child: IgnorePointer(child: child),
        //       );
        //     }

        //     return child!;
        //   },
        //   child: child,
        // );
      }),
    );
  }
}

class CustomAction extends StatelessWidget {
  const CustomAction({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
  });

  final Widget icon;
  final String text;

  final void Function(BuildContext context)? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return Expanded(
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 3, 3, 3),
          child: LayoutBuilder(builder: (context, constraints) {
            return OutlinedButton(
              onPressed: () {
                onPressed?.call(context);
                Slidable.of(context)?.close();
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: style.colors.danger,
                foregroundColor: style.colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: style.cardRadius),
                side: BorderSide.none,
              ),
              child: Opacity(
                opacity: constraints.maxWidth > 50
                    ? 1
                    : constraints.maxWidth > 25
                        ? (constraints.maxWidth - 25) / 25
                        : 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(height: 8),
                    Text(text, maxLines: 1),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
