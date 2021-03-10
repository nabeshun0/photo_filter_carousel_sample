import 'package:flutter/material.dart';

@immutable
class FilterSelector extends StatefulWidget {
  const FilterSelector({
    Key? key,
    required this.filters,
    required this.onFilterChanged,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
  }) : super(key: key);

  final List<Color> filters;
  final void Function(Color selectedColor) onFilterChanged;
  final EdgeInsets padding;

  @override
  _FilterSelectorState createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  static const _filtersPerScreen = 5;
  static const _viewportFractionPerItem = 1.0 / _filtersPerScreen;

  late final PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      viewportFraction: _viewportFractionPerItem,
    );
    _controller.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = (_controller.page ?? 0).round();
    widget.onFilterChanged(widget.filters[page]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemSize = constraints.maxWidth * _viewportFractionPerItem;

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _buildShadowGradient(itemSize),
            _buildCarousel(itemSize),
            _buildSelectionRing(itemSize),
          ],
        );
      },
    );
  }

  Widget _buildShadowGradient(double itemSize) {
    return SizedBox(
      height: itemSize * 2 + widget.padding.vertical,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black,
            ],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }

  Color itemColor(int index) => widget.filters[index % widget.filters.length];

  void _onFilterTapped(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.ease,
    );
  }

  Widget _buildCarousel(double itemSize) {
    return Container(
      height: itemSize,
      margin: widget.padding,
      child: PageView.builder(
          controller: _controller,
          itemCount: widget.filters.length,
          itemBuilder: (context, index) {
            return Center(
              child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    if (!_controller.hasClients ||
                        !_controller.position.hasContentDimensions) {
                      return SizedBox();
                    }

                    final selectedIndex = _controller.page!.roundToDouble();

                    final pageScrollAmount = _controller.page! - selectedIndex;

                    final maxScrollDistance = _filtersPerScreen / 2;

                    final pageDistanceFromSelected =
                        (selectedIndex - index + pageScrollAmount).abs();

                    final percentFromCenter =
                        1.0 - pageDistanceFromSelected / maxScrollDistance;

                    final itemScale = 0.5 + (percentFromCenter * 0.75);
                    final opacity = 0.25 + (percentFromCenter * 0.75);

                    return Transform.scale(
                      scale: itemScale,
                      child: Opacity(
                        opacity: opacity,
                        child: FilterItem(
                          color: itemColor(index),
                          onFilterSelected: () => _onFilterTapped,
                        ),
                      ),
                    );
                  }),
            );
          }),
    );
  }

  Widget _buildSelectionRing(double itemSize) {
    return IgnorePointer(
      child: Padding(
        padding: widget.padding,
        child: SizedBox(
          width: itemSize,
          height: itemSize,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(width: 6, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class FilterItem extends StatelessWidget {
  FilterItem({
    Key? key,
    required this.color,
    this.onFilterSelected,
  }) : super(key: key);

  final Color color;
  final VoidCallback? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFilterSelected,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Image.network(
              'https://flutter.dev/docs/cookbook/img-files'
              '/effects/instagram-buttons/millenial-texture.jpg',
              color: color.withOpacity(0.5),
              colorBlendMode: BlendMode.hardLight,
            ),
          ),
        ),
      ),
    );
  }
}
