import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sneak_fit/features/order/domain/entities/order_entity.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Order #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0).toUpperCase()}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            const Text(
              "Order Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => _buildItemCard(item)),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: "Shipping Address",
              icon: Icons.location_on_rounded,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.shippingAddress?.fullName ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${order.shippingAddress?.address}, ${order.shippingAddress?.city}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    "Phone: ${order.shippingAddress?.phone}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: "Payment Information",
              icon: Icons.payment_rounded,
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getPaymentIcon(), size: 20, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    order.paymentMethod.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Spacer(),
                  const Text(
                    "Paid",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildPriceBreakdown(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Order Status",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(order.createdAt),
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusStepper(),
        ],
      ),
    );
  }

  Widget _buildStatusStepper() {
    final status = order.status.toLowerCase();
    int currentStep = 0;
    if (status == 'pending') currentStep = 1;
    if (status == 'processing') currentStep = 2;
    if (status == 'shipped') currentStep = 3;
    if (status == 'delivered') currentStep = 4;
    if (status == 'cancelled') currentStep = -1;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stepIcon(Icons.assignment_turned_in_rounded, currentStep >= 1, "Placed"),
            _stepLine(currentStep >= 2),
            _stepIcon(Icons.inventory_2_rounded, currentStep >= 2, "Packed"),
            _stepLine(currentStep >= 3),
            _stepIcon(Icons.local_shipping_rounded, currentStep >= 3, "Shipped"),
            _stepLine(currentStep >= 4),
            _stepIcon(Icons.verified_rounded, currentStep >= 4, "Delivered"),
          ],
        ),
        if (currentStep == -1) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel_outlined, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Text(
                  "Order Cancelled",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _stepIcon(IconData icon, bool isCompleted, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF23D19D) : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isCompleted ? Colors.white : Colors.grey[400], size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isCompleted ? Colors.black : Colors.grey[400],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isCompleted) {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? const Color(0xFF23D19D) : Colors.grey[200],
    );
  }

  Widget _buildItemCard(OrderItemEntity item) {
    final imageUrl = item.image.startsWith('http')
        ? item.image
        : '${ApiEndpoints.baseImageUrl}${item.image}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  "Size: ${item.size} • Qty: ${item.quantity}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rs ${item.price.toStringAsFixed(0)}",
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF23D19D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({required String title, required IconData icon, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    double subtotal = 0;
    for (var item in order.items) {
      subtotal += item.price * item.quantity;
    }
    double deliveryFee = 150; // Mock delivery fee

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _priceRow("Subtotal", "Rs ${subtotal.toStringAsFixed(0)}", Colors.white70),
          const SizedBox(height: 12),
          _priceRow("Delivery Fee", "Rs ${deliveryFee.toStringAsFixed(0)}", Colors.white70),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          _priceRow("Grand Total", "Rs ${order.totalAmount.toStringAsFixed(0)}", Colors.white, isTotal: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, Color color, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: isTotal ? 22 : 14, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  IconData _getPaymentIcon() {
    switch (order.paymentMethod.toLowerCase()) {
      case 'khalti': return Icons.account_balance_wallet_rounded;
      case 'esewa': return Icons.account_balance_wallet_outlined;
      case 'cod': return Icons.delivery_dining_rounded;
      default: return Icons.credit_card_rounded;
    }
  }
}
