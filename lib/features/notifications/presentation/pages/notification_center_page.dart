import 'package:flutter/material.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Complaint Forwarded',
      'time': '2 hours ago',
      'body': 'The complaint #CMP-4029 regarding Department Laboratory ventilation has been forwarded to the Facility Management team for immediate inspection.',
      'category': 'Complaints',
      'icon': Icons.assignment_late,
      'color': const Color(0xFF6366F1),
      'isRead': false,
    },
    {
      'title': 'New Departmental Notice',
      'time': '4 hours ago',
      'body': 'Final Semester project submissions have been extended until Friday, Oct 27th. Please ensure all documentation is uploaded to the portal.',
      'category': 'Notices',
      'icon': Icons.campaign,
      'color': const Color(0xFFF59E0B),
      'isRead': false,
    },
    {
      'title': 'Security Alert: New Login',
      'time': 'Yesterday',
      'body': 'A new login was detected from a Chrome browser on Windows 11. If this wasn\'t you, please reset your password.',
      'category': 'System',
      'icon': Icons.security,
      'color': Colors.grey,
      'isRead': true,
    },
    {
      'title': 'Complaint Resolved',
      'time': '2 days ago',
      'body': 'Your request #CMP-3812 regarding ID card replacement has been processed. You can collect your new card from the Office of Registrar.',
      'category': 'Complaints',
      'icon': Icons.check_circle,
      'color': const Color(0xFF10B981),
      'isRead': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final filteredNotifications = _selectedCategory == 'All' 
        ? _notifications 
        : _notifications.where((n) => n['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Notices', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['isRead'] = true;
                }
              });
            },
            icon: const Icon(Icons.done_all, size: 20),
            label: const Text('Mark all as read'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: ['All', 'Complaints', 'Notices', 'System'].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = category);
                    },
                    selectedColor: theme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSelected ? theme.primaryColor : Colors.grey.shade300),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No alerts here', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                        const SizedBox(height: 8),
                        const Text('We couldn\'t find any notifications in this category.', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notif = filteredNotifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  color: notif['color'],
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: (notif['color'] as Color).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(notif['icon'], color: notif['color']),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(child: Text(notif['title'], style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 16))),
                                                Row(
                                                  children: [
                                                    Text(notif['time'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                                    if (!notif['isRead']) ...[
                                                      const SizedBox(width: 8),
                                                      Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle)),
                                                    ]
                                                  ],
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(notif['body'], style: const TextStyle(color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
