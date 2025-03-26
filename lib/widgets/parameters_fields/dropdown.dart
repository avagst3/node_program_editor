import 'package:flutter/material.dart';

class ButtonPart extends StatelessWidget {
  const ButtonPart(
      {super.key, this.height, this.width, this.onTap, this.child});

  final double? height;
  final double? width;

  final VoidCallback? onTap;

  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.black),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: child ?? const SizedBox(),
          ),
        ),
      ),
    );
  }
}

class MenuPart extends StatelessWidget {
  const MenuPart({
    super.key,
    this.width,
    required this.items,
    this.maxHeight,
    required this.onTap,
  });
  final double? width;
  final double? maxHeight;
  final List<ComboItem> items;
  final Function(ComboItem) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(),
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 32,
            offset: Offset(0, 20),
            spreadRadius: -8,
          ),
        ],
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SingleChildScrollView(
        child: Column(
          children: items.map((item) {
            return MenuTile(
              item: item,
              width: width ?? 200,
              onTap: onTap,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.width,
  });
  final double width;
  final ComboItem item;
  final Function(ComboItem) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: InkWell(
            onTap: () => onTap(item),
            child: Text(item.label),
          ),
        ),
      ),
    );
  }
}

class ComboItem {
  final String label;
  final String value;
  const ComboItem(this.label, this.value);
}

class DropDown extends StatefulWidget {
  const DropDown({
    super.key,
    required this.height,
    required this.width,
    required this.items,
    this.controller,
    this.menuMaxHeight,
  });
  final double height;
  final double width;
  final List<ComboItem> items;
  final TextEditingController? controller;
  final double? menuMaxHeight;
  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  final OverlayPortalController _portalController = OverlayPortalController();

  final _link = LayerLink();
  String _buttonLabel = "";
  @override
  void initState() {
    _buttonLabel = widget.items.first.label;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portalController,
        overlayChildBuilder: (BuildContext context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: MenuPart(
                width: widget.width,
                items: widget.items,
                maxHeight: widget.menuMaxHeight,
                onTap: (item) => onTapItem(item),
              ),
            ),
          );
        },
        child: ButtonPart(
          height: widget.height,
          width: widget.width,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_buttonLabel),
                Icon(Icons.arrow_drop_down_outlined)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onTap() {
    _portalController.toggle();
  }

  void onTapItem(ComboItem item) {
    widget.controller?.text = item.value;
    setState(() {
      _buttonLabel = item.label;
    });
    _portalController.hide();
  }
}
