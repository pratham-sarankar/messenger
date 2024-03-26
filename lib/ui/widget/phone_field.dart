import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:messenger/themes.dart';
import 'package:messenger/ui/widget/modal_popup.dart';
import 'package:messenger/ui/widget/widget_button.dart';
import 'package:messenger/util/platform_utils.dart';
import 'package:phone_form_field/phone_form_field.dart' hide CountrySelector;
import 'package:circle_flags/circle_flags.dart';

import 'country_selector2.dart';
import 'text_field.dart';

/// Reactive stylized [TextField] wrapper.
class ReactivePhoneField extends StatelessWidget {
  const ReactivePhoneField({
    super.key,
    required this.state,
    this.label,
  });

  /// Reactive state of this [ReactivePhoneField].
  final PhoneFieldState state;

  final String? label;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return ReactiveTextField(
      state: state,
      label: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      style: style.fonts.medium.regular.onBackground,
      formatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: () {
        state.isEmpty.value = state.controller.text.isEmpty;
      },
      prefixIcon: WidgetButton(
        onPressed: () async {
          final selected = await const _CountrySelectorNavigator()
              .navigate(context, state._flagCache);
          if (selected != null) {
            state.iso.value = selected.isoCode;
          }

          state.focus.requestFocus();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 1.6),
          child: Obx(() {
            return CountryCodeChip(
              key: const ValueKey('country-code-chip'),
              isoCode: state.iso.value,
              showFlag: true,
              showDialCode: true,
              textStyle: style.fonts.medium.regular.onBackground
                  .copyWith(fontSize: 17),
              flagSize: 16,
            );
          }),
        ),
      ),
    );
  }
}

/// Wrapper with all the necessary methods and fields to make a [TextField]
/// reactive to any changes and validations.
class PhoneFieldState extends ReactiveFieldState {
  PhoneFieldState({
    PhoneNumber? initial,
    this.onChanged,
    this.onSubmitted,
    RxStatus? status,
    FocusNode? focus,
    bool approvable = false,
    bool editable = true,
    bool submitted = true,
    bool revalidateOnUnfocus = false,
  }) : focus = focus ?? FocusNode() {
    controller = TextEditingController();
    controller2 = PhoneController(null);
    isEmpty = RxBool(initial == null);

    this.editable = RxBool(editable);
    this.approvable = approvable;
    this.status = Rx(status ?? RxStatus.empty());

    if (submitted) {
      _previousSubmit = initial;
    }

    changed.value = _previousSubmit != initial;

    controller.addListener(() {
      PlatformUtils.keepActive();
      changed.value = controller.text.trim() != (_previousSubmit ?? '');
      print('${changed.value}: ${controller.text} vs $_previousSubmit');
    });

    PhoneNumber? prevPhone = controller2.value;
    controller2.addListener(() {
      PlatformUtils.keepActive();

      if (controller2.value != prevPhone) {
        prevPhone = controller2.value;
        if (revalidateOnUnfocus) {
          error.value = null;
        }
      }
    });

    // if (onChanged != null) {
    //   controller2.addListener(() {
    //     changed.value = controller2.value != (_previousSubmit ?? '');
    //   });
    // }

    this.focus.addListener(() {
      isFocused.value = this.focus.hasFocus;

      controller2.value = PhoneNumber(isoCode: iso.value, nsn: controller.text);

      if (onChanged != null) {
        if (controller2.value != _previousText) {
          isEmpty.value = controller2.value?.nsn.isEmpty != false;
          if (!this.focus.hasFocus) {
            onChanged?.call(this);
            _previousText = controller2.value;
          }
        }
      }
    });
  }

  /// [Duration] to debounce the [onChanged] calls with.
  static const Duration debounce = Duration(seconds: 2);

  /// Callback, called when the [text] has finished changing.
  ///
  /// This callback is fired only when the [text] is changed on:
  /// - submit action of [TextEditingController] was emitted;
  /// - [focus] node changed its focus;
  /// - setter or [submit] was manually called.
  Function(PhoneFieldState)? onChanged;

  /// Callback, called when the [text] is submitted.
  ///
  /// This callback is fired only when the [text] value was not yet submitted:
  /// - submit action of [TextEditingController] was emitted;
  /// - [submit] was manually called.
  final Function(PhoneFieldState)? onSubmitted;

  @override
  final RxBool changed = RxBool(false);

  /// [TextEditingController] of this [TextFieldState].
  @override
  late final TextEditingController controller;

  late final PhoneController controller2;

  /// Reactive [RxStatus] of this [TextFieldState].
  @override
  late final Rx<RxStatus> status;

  /// Indicator whether this [TextFieldState] should be editable or not.
  @override
  late final RxBool editable;

  @override
  late final RxBool isEmpty;

  @override
  late final FocusNode focus;

  final Rx<IsoCode> iso = Rx(IsoCode.US);

  /// Previous [TextEditingController]'s text used to determine if the [text]
  /// was modified on any [focus] change.
  PhoneNumber? _previousText;

  String? _previous;

  /// Previous [TextEditingController]'s text used to determine if the [text]
  /// was modified since the last [submit] action.
  PhoneNumber? _previousSubmit;

  /// Returns the text of the [TextEditingController].
  PhoneNumber? get phone => controller2.value;

  /// Sets the text of [TextEditingController] to [value] and calls [onChanged].
  set phone(PhoneNumber? value) {
    controller2.value = value;
    _previousText = value;
    isEmpty.value = value?.nsn.isEmpty != false;
    changed.value = true;
    onChanged?.call(this);
  }

  final _flagCache = FlagCache();
  final Rx<PhoneNumber?> number = Rx(null);

  /// Sets the text of [TextEditingController] to [value] without calling
  /// [onChanged].
  set unchecked(PhoneNumber? value) {
    controller2.value = value;
    _previousText = value;
    _previousSubmit = value;
    changed.value = false;
    isEmpty.value = controller2.value?.nsn.isEmpty != false;
  }

  /// Indicates whether [onChanged] was called after the [focus] change and no
  /// more text editing was done since then.
  bool get isValidated => controller2.value == _previousText;

  /// Submits this [TextFieldState].
  @override
  void submit() {
    if (editable.value) {
      if (controller.text != _previous) {
        _previous = controller.text;
        controller2.value =
            PhoneNumber(isoCode: iso.value, nsn: controller.text);
      }

      if (controller2.value != _previousSubmit) {
        if (_previousText != controller2.value) {
          _previousText = controller2.value;
          onChanged?.call(this);
        }
        _previousSubmit = controller2.value;
        onSubmitted?.call(this);
        changed.value = false;
      }
    }
  }

  /// Clears the last submitted value.
  void unsubmit() {
    _previousSubmit = null;
    changed.value = false;
  }

  /// Clears the [TextEditingController]'s text without calling [onChanged].
  void clear() {
    isEmpty.value = true;
    controller2.value = null;
    controller.text = '';
    error.value = null;
    _previousText = null;
    _previousSubmit = null;
    changed.value = false;
  }

  @override
  final RxBool hasAllowance = RxBool(false);
}

class _CountrySelectorNavigator extends CountrySelectorNavigator {
  const _CountrySelectorNavigator()
      : super(
          searchAutofocus: false,
        );

  @override
  Future<Country?> navigate(BuildContext context, dynamic flagCache) {
    return ModalPopup.show(
      context: context,
      child: CountrySelector(
        countries: countries,
        onCountrySelected: (country) =>
            Navigator.of(context, rootNavigator: true).pop(country),
        flagCache: flagCache,
      ),
    );
  }
}
