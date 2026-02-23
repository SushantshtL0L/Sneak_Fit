import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/utils/my_snack_bar.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final ItemEntity? item;
  const AddItemScreen({super.key, this.item});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  File? _image;
  final _picker = ImagePicker();
  String _condition = 'New';

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _brandController;
  late final TextEditingController _sizeController;
  late final TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.itemName ?? '');
    _priceController = TextEditingController(text: widget.item?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _brandController = TextEditingController(text: widget.item?.brand ?? '');
    _sizeController = TextEditingController(text: widget.item?.size ?? '');
    _colorController = TextEditingController(text: widget.item?.color ?? '');
    
    if (widget.item != null) {
      _condition = widget.item!.condition == ItemCondition.newCondition ? 'New' : 'Thrift';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Image Source",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final granted = await PermissionService.requestCameraPermission();
      if (!granted) {
        if (mounted) {
          showMySnackBar(
            context: context,
            message: "Camera permission denied",
            type: SnackBarType.error,
          );
        }
        return;
      }
    }

    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final brand = _brandController.text.trim();
    final priceStr = _priceController.text.trim();

    if ((_image == null && widget.item?.media == null) || name.isEmpty || description.isEmpty || brand.isEmpty || priceStr.isEmpty) {
      showMySnackBar(
        context: context,
        message: "Please fill all fields and select an image",
        type: SnackBarType.warning,
      );
      return;
    }

    final price = double.tryParse(priceStr);
    if (price == null) {
      showMySnackBar(
        context: context,
        message: "Please enter a valid price",
        type: SnackBarType.error,
      );
      return;
    }

    if (widget.item != null) {
      // Edit mode
      await ref.read(itemViewModelProvider.notifier).updateProduct(
            widget.item!.itemId,
            name,
            description,
            _condition.toLowerCase(),
            _image?.path ?? widget.item?.media,
            price,
            brand,
            _sizeController.text.trim(),
            _colorController.text.trim(),
          );
    } else {
      // Add mode
      await ref.read(itemViewModelProvider.notifier).createProduct(
            name,
            description,
            _condition.toLowerCase(),
            _image!.path,
            price,
            brand,
            _sizeController.text.trim(),
            _colorController.text.trim(),
          );
    }

    if (mounted) {
      final state = ref.read(itemViewModelProvider);
      if (state.status == ItemStatus.created || state.status == ItemStatus.updated) {
        showMySnackBar(
          context: context,
          message: widget.item != null ? "Product updated successfully!" : "Product posted successfully!",
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      } else if (state.status == ItemStatus.error) {
        showMySnackBar(
          context: context,
          message: "Failed: ${state.errorMessage}",
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemViewModelProvider);
    final bool isLoading = itemState.status == ItemStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.item != null ? "Edit Sneaks" : "Sell Your Sneaks",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker Section
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : (widget.item?.media != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                "${ApiEndpoints.baseImageUrl}${widget.item!.media}",
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    size: 50, color: Colors.grey[400]),
                                const SizedBox(height: 10),
                                Text(widget.item != null ? "Change Image" : "Add Product Image",
                                    style: TextStyle(color: Colors.grey[600])),
                              ],
                            )),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Product Name
            const Text("Product Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "e.g. Nike Air Jordan 1",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Brand field
            const Text("Brand",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _brandController,
              decoration: InputDecoration(
                hintText: "e.g. Nike, Adidas, Puma",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Size",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _sizeController,
                        decoration: InputDecoration(
                          hintText: "e.g. 42",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Color",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _colorController,
                        decoration: InputDecoration(
                          hintText: "e.g. Black",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description field
            const Text("Description",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Tell us more about the sneakers...",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Condition Selector (Thrift vs New)
            const Text("Condition",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _condition = 'New'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: _condition == 'New' ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          "New",
                          style: TextStyle(
                            color: _condition == 'New' ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _condition = 'Thrift'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: _condition == 'Thrift' ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          "Thrift",
                          style: TextStyle(
                            color: _condition == 'Thrift' ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price
            const Text("Price (Rs.)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter amount",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.item != null ? "Update Listing" : "Post Listing",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

