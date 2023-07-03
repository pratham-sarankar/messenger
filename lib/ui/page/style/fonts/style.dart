import 'package:flutter/material.dart';

import '/themes.dart';

class FontStyleView extends StatelessWidget {
  const FontStyleView({super.key});

  @override
  Widget build(BuildContext context) {
    final (style, fonts) = Theme.of(context).styles;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          _FontWidget(label: 'displayLarge', style: fonts.displayLarge!),
          _FontWidget(label: 'displayMedium', style: fonts.displayMedium!),
          _FontWidget(label: 'displaySmall', style: fonts.displaySmall!),
          _FontWidget(label: 'headlineLarge', style: fonts.headlineLarge!),
          _FontWidget(label: 'headlineMedium', style: fonts.headlineMedium!),
          _FontWidget(label: 'headlineSmall', style: fonts.headlineSmall!),
          _FontWidget(label: 'titleLarge', style: fonts.titleLarge!),
          _FontWidget(label: 'titleMedium', style: fonts.titleMedium!),
          _FontWidget(label: 'titleSmall', style: fonts.titleSmall!),
          _FontWidget(label: 'labelLarge', style: fonts.labelLarge!),
          _FontWidget(label: 'labelMedium', style: fonts.labelMedium!),
          _FontWidget(label: 'labelSmall', style: fonts.labelSmall!),
          _FontWidget(label: 'bodyLarge', style: fonts.bodyLarge!),
          _FontWidget(label: 'bodyMedium', style: fonts.bodyMedium!),
          _FontWidget(label: 'bodySmall', style: fonts.bodySmall!),
          _FontWidget(
            label: 'linkStyle',
            style: style.linkStyle,
            color: 'Blue',
          ),
        ],
      ),
    );
  }
}

class _FontWidget extends StatelessWidget {
  const _FontWidget({
    required this.label,
    required this.style,
    this.color = 'Black',
  });

  final String label;

  final String color;

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final (styles, fonts) = Theme.of(context).styles;

    return Container(
      height: 270,
      width: 290,
      decoration: BoxDecoration(
        color: styles.colors.onPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Center(child: Text(label, style: style)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DefaultTextStyle(
                  style: fonts.bodySmall!.copyWith(
                    color: styles.colors.secondary,
                  ),
                  child: const SizedBox(
                    height: 130,
                    width: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text('Size'),
                            Expanded(child: Divider(indent: 10, endIndent: 10)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text('Weight'),
                            Expanded(child: Divider(indent: 10, endIndent: 10)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text('Style'),
                            Expanded(child: Divider(indent: 10, endIndent: 10)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text('Color'),
                            Expanded(child: Divider(indent: 10, endIndent: 10)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text('Letter spacing'),
                            Expanded(child: Divider(indent: 10, endIndent: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                DefaultTextStyle(
                  style: fonts.bodyMedium!,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(style.fontSize.toString()),
                        const SizedBox(height: 8),
                        Text(style.fontWeight!.value.toString()),
                        const SizedBox(height: 8),
                        Text(_getFontWeightStyle(style.fontWeight)),
                        const SizedBox(height: 8),
                        Text(color),
                        const SizedBox(height: 8),
                        style.letterSpacing == null
                            ? const Text('0 %')
                            : Text('${style.letterSpacing} %'),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getFontWeightStyle(FontWeight? fontWeight) {
    String fontWeightStyle = '';

    switch (fontWeight) {
      case FontWeight.w100:
        fontWeightStyle = 'Thin';
        break;
      case FontWeight.w200:
        fontWeightStyle = 'Extra-light';
        break;
      case FontWeight.w300:
        fontWeightStyle = 'Light';
        break;
      case FontWeight.w400:
        fontWeightStyle = 'Regular';
        break;
      case FontWeight.w500:
        fontWeightStyle = 'Medium';
        break;
      case FontWeight.w600:
        fontWeightStyle = 'Semi-bold';
        break;
      case FontWeight.w700:
        fontWeightStyle = 'Bold';
        break;
      case FontWeight.w800:
        fontWeightStyle = 'Extra-bold';
        break;
      case FontWeight.w900:
        fontWeightStyle = 'Black';
        break;
      default:
        fontWeightStyle = 'Regular';
        break;
    }

    return fontWeightStyle;
  }
}
