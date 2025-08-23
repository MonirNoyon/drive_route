import 'package:car_routing_application/features/home/domain/entities/place_suggestions.dart';
import 'package:flutter/material.dart';

class SuggestionList extends StatelessWidget {
  const SuggestionList({
    required this.items,
    required this.onSelect,
  });

  final List<PlaceSuggestion> items;
  final ValueChanged<PlaceSuggestion> onSelect;


  @override
  Widget build(BuildContext context) {

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      primary: false,
      physics: const ClampingScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final PlaceSuggestion placeSuggestion = items[index];
        return ListTile(
          title: Text(placeSuggestion.description),
          onTap: () => onSelect(placeSuggestion),
        );
      },
    );
  }
}