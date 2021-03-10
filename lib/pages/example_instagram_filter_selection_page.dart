import 'package:flutter/material.dart';
import 'package:photo_filter_carousel_sample/widgets/filter_selector.dart';

class ExampleInstagramFilterSelectionPage extends StatefulWidget {
  const ExampleInstagramFilterSelectionPage({
    Key? key,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ExampleInstagramFilterSelectionPage> {
  final _filters = [
    Colors.white,
    ...List.generate(Colors.primaries.length,
        (index) => Colors.primaries[(index * 4) % Colors.primaries.length])
  ];

  final _filterColor = ValueNotifier<Color>(Colors.white);

  void _onFilterChanged(Color value) {
    _filterColor.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: _buildPhotoWithFilter(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFilterSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWithFilter() {
    return ValueListenableBuilder(
      valueListenable: _filterColor,
      builder: (context, value, child) {
        final color = value as Color;
        return Image.network(
          'https://flutter.dev/docs/cookbook/img-files/effects/instagram-buttons/millenial-dude.jpg',
          color: color.withOpacity(0.5),
          colorBlendMode: BlendMode.color,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildFilterSelector() {
    return FilterSelector(
      filters: _filters,
      onFilterChanged: _onFilterChanged,
    );
  }
}
