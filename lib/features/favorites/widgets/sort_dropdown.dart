import 'package:flutter/material.dart';
import '../bloc/favorites_bloc.dart';

class SortDropdown extends StatelessWidget {
  final SortOption currentOption;
  final Function(SortOption) onChanged;

  const SortDropdown({
    Key? key,
    required this.currentOption,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Sort by: '),
          const SizedBox(width: 8),
          DropdownButton<SortOption>(
            value: currentOption,
            underline: Container(
              height: 2,
              color: Theme.of(context).primaryColor,
            ),
            onChanged: (SortOption? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            items: [
              DropdownMenuItem<SortOption>(
                value: SortOption.name,
                child: const Text('Name'),
              ),
              DropdownMenuItem<SortOption>(
                value: SortOption.status,
                child: const Text('Status'),
              ),
              DropdownMenuItem<SortOption>(
                value: SortOption.species,
                child: const Text('Species'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
