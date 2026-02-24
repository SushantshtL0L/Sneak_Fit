import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';

import '../view_model/notification_view_model.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authViewModelProvider);
              final role = authState.authEntity?.role?.toLowerCase();
              final bool canCreate = role == 'admin' || role == 'seller';

              if (!canCreate) return const SizedBox.shrink();

              return IconButton(
                onPressed: () => _showCreateNotificationDialog(context, ref),
                icon: const Icon(Icons.add_alert_outlined),
                tooltip: "Create Notification",
              );
            },
          ),
          IconButton(
            onPressed: () => ref.read(notificationViewModelProvider.notifier).fetchNotifications(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : state.error != null
              ? Center(child: Text("Error: ${state.error}"))
              : state.notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No notifications yet", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.notifications.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return Card(
                          elevation: 0,
                          color: Colors.grey[50],
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: notification.type == 'offer' 
                                  ? Colors.orange[100] 
                                  : (notification.type == 'order' 
                                      ? Colors.green[100] 
                                      : Colors.blue[100]),
                              child: Icon(
                                notification.type == 'offer' 
                                    ? Icons.local_offer_outlined 
                                    : (notification.type == 'order' 
                                        ? Icons.shopping_bag_outlined 
                                        : Icons.announcement_outlined),
                                color: notification.type == 'offer' 
                                    ? Colors.orange[800] 
                                    : (notification.type == 'order' 
                                        ? Colors.green[800] 
                                        : Colors.blue[800]),
                              ),
                            ),
                            title: Text(
                              notification.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  notification.message,
                                  style: TextStyle(
                                    color: notification.isRead ? Colors.grey[600] : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('MMM d, h:mm a').format(notification.createdAt),
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: Consumer(
                              builder: (context, ref, child) {
                                final authState = ref.watch(authViewModelProvider);
                                final role = authState.authEntity?.role?.toLowerCase();
                                final bool canDelete = role == 'admin' || role == 'seller';

                                if (!canDelete) return const SizedBox.shrink();

                                return IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    _confirmDelete(context, ref, notification.id);
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Notification"),
        content: const Text("Are you sure you want to delete this notification?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(notificationViewModelProvider.notifier).deleteNotification(id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreateNotificationDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'general';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Send Notification"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title", hintText: "e.g., Flash Sale!"),
                ),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: "Message", hintText: "Enter notification text..."),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: "Type"),
                  items: ['general', 'offer', 'announcement', 'order']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase())))
                      .toList(),
                  onChanged: (val) => setState(() => selectedType = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              onPressed: () {
                if (titleController.text.isNotEmpty && messageController.text.isNotEmpty) {
                  ref.read(notificationViewModelProvider.notifier).createNotification(
                        titleController.text.trim(),
                        messageController.text.trim(),
                        selectedType,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text("Send Broadcast"),
            ),
          ],
        ),
      ),
    );
  }
}
