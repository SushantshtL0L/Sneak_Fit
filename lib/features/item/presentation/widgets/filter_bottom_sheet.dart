import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  String? selectedBrand;
  String? selectedSize;
  RangeValues? priceRange;

  @override
  void initState() {
    super.initState();
    final state = ref.read(itemViewModelProvider);
    selectedBrand = state.selectedBrand ?? 'All';
    selectedSize = state.selectedSize ?? 'All';
    
    // Find highest price in items to set max range, default to 50000
    double maxItemPrice = 50000;
    if (state.items.isNotEmpty) {
      final highest = state.items.map((e) => e.price).reduce((a, b) => a > b ? a : b);
      if (highest > maxItemPrice) {
        maxItemPrice = ((highest / 5000).ceil() * 5000).toDouble(); // Round up to nearest 5k
      }
    }

    priceRange = RangeValues(
      state.minPrice ?? 0,
      state.maxPrice ?? maxItemPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemViewModelProvider);
    final isDark = ref.watch(themeViewModelProvider).isDarkMode;
    
    // Extract unique brands and sizes from items, filtering out null or empty values
    final brands = ['All', ...itemState.items
        .map((e) => e.brand)
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toSet()];
    final sizes = ['All', ...itemState.items
        .map((e) => e.size)
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toSet()];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filters",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(itemViewModelProvider.notifier).resetFilters();
                  Navigator.pop(context);
                },
                child: const Text("Reset"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Text("Brand", style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black,
          )),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: brands.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final brand = brands[index];
                final isSelected = selectedBrand == brand;
                return ChoiceChip(
                  label: Text(brand),
                  selected: isSelected,
                  onSelected: (val) => setState(() => selectedBrand = brand),
                  selectedColor: isDark ? Colors.tealAccent : Colors.black,
                  labelStyle: TextStyle(color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white : Colors.black)),
                  backgroundColor: isDark ? Colors.grey[900] : Colors.grey[200],
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          Text("Size (US)", style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black,
          )),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sizes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final size = sizes[index];
                final isSelected = selectedSize == size;
                return ChoiceChip(
                  label: Text(size),
                  selected: isSelected,
                  onSelected: (val) => setState(() => selectedSize = size),
                  selectedColor: isDark ? Colors.tealAccent : Colors.black,
                  labelStyle: TextStyle(color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white : Colors.black)),
                  backgroundColor: isDark ? Colors.grey[900] : Colors.grey[200],
                );
              },
            ),
          ),
 
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Price Range", style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black,
              )),
              Text(
                "Rs ${priceRange!.start.toInt()} - ${priceRange!.end.toInt()}",
                style: TextStyle(color: isDark ? Colors.tealAccent : Colors.black87),
              ),
            ],
          ),
          RangeSlider(
            values: priceRange!,
            min: 0,
            max: (priceRange!.end > 50000) ? priceRange!.end : 50000,
            divisions: 50,
            activeColor: isDark ? Colors.tealAccent : Colors.black,
            inactiveColor: isDark ? Colors.grey[800] : Colors.grey.shade300,
            onChanged: (values) => setState(() => priceRange = values),
          ),
          
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ref.read(itemViewModelProvider.notifier).filterItems(
                  brand: selectedBrand,
                  size: selectedSize,
                  minPrice: priceRange!.start,
                  maxPrice: priceRange!.end,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.tealAccent : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Apply Filters"),
            ),
          ),
        ],
      ),
    );
  }
}
