import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    priceRange = RangeValues(
      state.minPrice ?? 0,
      state.maxPrice ?? 50000, // Assuming 50k as max
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemViewModelProvider);
    
    // Extract unique brands and sizes from items
    final brands = ['All', ...itemState.items.map((e) => e.brand).whereType<String>().toSet()];
    final sizes = ['All', ...itemState.items.map((e) => e.size).whereType<String>().toSet()];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filters",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          
          const Text("Brand", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          const Text("Size (US)", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Price Range", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Rs ${priceRange!.start.toInt()} - ${priceRange!.end.toInt()}"),
            ],
          ),
          RangeSlider(
            values: priceRange!,
            min: 0,
            max: 50000,
            divisions: 50,
            activeColor: Colors.black,
            inactiveColor: Colors.grey.shade300,
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
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
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
