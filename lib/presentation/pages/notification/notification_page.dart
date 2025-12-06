import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../state/notification/notification_provider.dart';
import '../../widgets/common/main_layout.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return MainLayout(
      body: RefreshIndicator(
        onRefresh: () => context.read<NotificationProvider>().fetchNotifications(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '알림',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<NotificationProvider>().markAllNotificationsAsRead();
                    },
                    child: const Text('모두 읽음'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading && notifications.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : notifications.isEmpty
                      ? const Center(child: Text('새로운 알림이 없습니다.'))
                      : ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return ListTile(
                              tileColor: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
                              leading: const Icon(Icons.notifications),
                              title: Text(notification.message),
                              subtitle: Text(timeago.format(notification.createdAt, locale: 'ko')),
                              onTap: () {
                                if (!notification.isRead) {
                                  context.read<NotificationProvider>().markNotificationAsRead(notification.id);
                                }
                                // TODO: Navigate to the relevant page based on notification type
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
