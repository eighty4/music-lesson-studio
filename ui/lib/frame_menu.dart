import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app_styles.dart';
import 'editor_data.dart';

typedef FrameMenuOptionCallback<T extends Enum> = void Function(T);

typedef FrameMenuOpenPredicate = bool Function(EditorInteraction);

class FrameMenuOption<T> {
  final String label;
  final T value;

  FrameMenuOption(this.label, this.value);
}

class FrameMenu<T extends Enum> extends StatefulWidget {
  final FrameMenuOptionCallback<T> callback;
  final List<T> disabled;
  final List<FrameMenuOption<T>> options;
  final FrameMenuOpenPredicate predicate;
  final Widget child;

  const FrameMenu(
      {super.key,
      required this.child,
      required this.callback,
      required this.disabled,
      required this.options,
      required this.predicate});

  @override
  State<FrameMenu<T>> createState() => _FrameMenuState<T>();
}

class _FrameMenuState<T extends Enum> extends State<FrameMenu<T>> {
  Offset cursorPosition = Offset.zero;
  Offset menuPosition = Offset.zero;
  final OverlayPortalController menuController = OverlayPortalController();
  late final StreamSubscription editorInteractionSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub =
        EditorData.interactionState.listen((editorInteraction) {
      if (editorInteraction != null && widget.predicate(editorInteraction)) {
        setState(() => menuPosition = cursorPosition);
        menuController.show();
      } else {
        menuController.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() => cursorPosition = event.position),
      child: OverlayPortal(
        controller: menuController,
        overlayChildBuilder: buildMenu,
        child: widget.child,
      ),
    );
  }

  Widget buildMenu(BuildContext context) {
    return Positioned(
      left: menuPosition.dx,
      top: menuPosition.dy,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppStyles.frameMenuBorderColor),
            borderRadius: BorderRadius.circular(5),
            color: AppStyles.frameMenuBackgroundColor),
        // padding: const EdgeInsets.all(15),
        child: FrameMenuOptionList(
          callback: widget.callback,
          disabled: widget.disabled,
          options: widget.options,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
  }
}

class FrameMenuOptionList<T extends Enum> extends StatelessWidget {
  final FrameMenuOptionCallback<T> callback;
  final List<T> disabled;
  final List<FrameMenuOption<T>> options;

  const FrameMenuOptionList(
      {super.key,
      required this.callback,
      required this.disabled,
      required this.options});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: this.options.map(buildItem).toList(),
    );
  }

  Widget buildItem(FrameMenuOption<T> option) {
    return FrameMenuOptionListItem(
        callback: () => onMenuOption(option.value),
        disabled: disabled.contains(option.value),
        label: option.label);
  }

  onMenuOption(T option) {
    EditorData.closeOpenMenu();
    callback(option);
  }
}

class FrameMenuOptionListItem extends StatefulWidget {
  final VoidCallback callback;
  final bool disabled;
  final String label;

  const FrameMenuOptionListItem(
      {super.key,
      required this.callback,
      required this.disabled,
      required this.label});

  @override
  State<FrameMenuOptionListItem> createState() =>
      _FrameMenuOptionListItemState();
}

class _FrameMenuOptionListItemState extends State<FrameMenuOptionListItem> {
  bool mouseHovering = false;

  @override
  Widget build(BuildContext context) {
    final Widget content = buildContent();
    if (widget.disabled) {
      return content;
    } else {
      return GestureDetector(
        onTap: widget.callback,
        child: MouseRegion(
          onEnter: (e) => setState(() => mouseHovering = true),
          onExit: (e) => setState(() => mouseHovering = false),
          cursor: SystemMouseCursors.click,
          child: content,
        ),
      );
    }
  }

  Widget buildContent() {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: mouseHovering
          ? AppStyles.frameMenuOptionHoverColor
          : AppStyles.transparentColor,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.label,
                style: widget.disabled
                    ? AppStyles.frameMenuOptionDisabledTextStyle
                    : null)
          ]),
    );
  }
}
