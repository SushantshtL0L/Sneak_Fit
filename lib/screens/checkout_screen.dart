import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:sneak_fit/features/order/presentation/view_model/orders_view_model.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/core/api/api_client.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/core/utils/my_snack_bar.dart';
import 'package:dio/dio.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Shipping details
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  
  String _selectedPaymentMethod = 'COD'; // COD, Khalti, Card

  @override
  void initState() {
    super.initState();
    // Pre-fill user data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authViewModelProvider);
      if (authState.authEntity != null) {
        _nameController.text = authState.authEntity!.name ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _placeOrder() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF23D19D)),
      ),
    );

    try {
      final cartState = ref.read(cartViewModelProvider);
      final apiClient = ref.read(apiClientProvider);

      // Prepare order data
      final orderData = {
        'items': cartState.cartItems.map((item) => {
          'product': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'size': item.size,
          'image': item.image,
        }).toList(),
        'shippingAddress': {
          'fullName': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
        },
        'paymentMethod': _selectedPaymentMethod.toLowerCase(),
        'totalAmount': cartState.totalPrice,
      };

      // Real API Call
      await apiClient.post(ApiEndpoints.orders, data: orderData);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      // Clear cart
      ref.read(cartViewModelProvider.notifier).clearCart();
      
      // Proactively fetch orders in the background so they are ready when the user navigates to the screen
      ref.read(ordersViewModelProvider.notifier).fetchOrders();
      
      // Navigate to success screen
      Navigator.pushReplacementNamed(context, '/order-success');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      String errorMsg = "Failed to place order. Please try again.";
      if (e is DioException) {
        errorMsg = e.response?.data?['message'] ?? errorMsg;
      }
      
      showMySnackBar(
        context: context,
        message: errorMsg,
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: _previousStep,
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: _buildCurrentStepView(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 0: return "Shipping Address";
      case 1: return "Payment Method";
      case 2: return "Order Summary";
      default: return "Checkout";
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Row(
        children: [
          _indicatorCircle(0, "1"),
          _indicatorLine(0),
          _indicatorCircle(1, "2"),
          _indicatorLine(1),
          _indicatorCircle(2, "3"),
        ],
      ),
    );
  }

  Widget _indicatorCircle(int step, String label) {
    bool isActive = _currentStep >= step;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF23D19D) : Colors.grey.shade300,
        shape: BoxShape.circle,
        boxShadow: isActive ? [
          BoxShadow(
            color: const Color(0xFF23D19D).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ] : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _indicatorLine(int afterStep) {
    bool isActive = _currentStep > afterStep;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFF23D19D) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0: return _buildShippingForm();
      case 1: return _buildPaymentSelection();
      case 2: return _buildOrderReview();
      default: return const SizedBox();
    }
  }

  Widget _buildShippingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Where should we send your sneakers?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField("Full Name", _nameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField("Phone Number", _phoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField("Address", _addressController, Icons.location_on_outlined),
            const SizedBox(height: 16),
            _buildTextField("City", _cityController, Icons.location_city_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF23D19D)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            hintText: "Enter $label",
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          validator: (value) => value == null || value.isEmpty ? "Required" : null,
        ),
      ],
    );
  }

  Widget _buildPaymentSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Payment Method",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _paymentOption("Cash on Delivery", "COD", Icons.money),
          const SizedBox(height: 16),
          _paymentOption("Khalti Wallet", "Khalti", Icons.wallet),
          const SizedBox(height: 16),
          _paymentOption("Credit / Debit Card", "Card", Icons.credit_card),
        ],
      ),
    );
  }

  Widget _paymentOption(String title, String value, IconData icon) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: const Color(0xFF23D19D), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF23D19D).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF23D19D)),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF23D19D))
            else
              const Icon(Icons.circle_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderReview() {
    final cartState = ref.watch(cartViewModelProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          "Review Your Order",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Address Summary
        _summaryCard("Shipping To", "${_nameController.text}\n${_addressController.text}, ${_cityController.text}\n${_phoneController.text}", Icons.local_shipping_outlined),
        const SizedBox(height: 16),
        // Payment Summary
        _summaryCard("Payment Via", _selectedPaymentMethod == 'COD' ? "Cash on Delivery" : _selectedPaymentMethod, Icons.payment_outlined),
        const SizedBox(height: 24),
        const Text(
          "Items",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...cartState.cartItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text("${item.quantity}x ", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF23D19D))),
              Expanded(child: Text(item.name)),
              Text("Rs ${item.price.toStringAsFixed(0)}"),
            ],
          ),
        )),
      ],
    );
  }

  Widget _summaryCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _currentStep = (title == "Shipping To" ? 0 : 1)),
            icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF23D19D)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final cartState = ref.watch(cartViewModelProvider);
    bool isLastStep = _currentStep == 2;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(
                  "Rs ${cartState.totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLastStep ? _placeOrder : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23D19D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: const Color(0xFF23D19D).withValues(alpha: 0.5),
                ),
                child: Text(
                  isLastStep ? "PLACE ORDER" : "CONTINUE",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
