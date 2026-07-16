import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/notice_board_card.dart';
import '../providers/notice_provider.dart';

class StudentNoticeBoardPage extends ConsumerStatefulWidget {
  const StudentNoticeBoardPage({super.key});

  @override
  ConsumerState<StudentNoticeBoardPage> createState() => _StudentNoticeBoardPageState();
}

class _StudentNoticeBoardPageState extends ConsumerState<StudentNoticeBoardPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Academic', 'Events', 'Urgent'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false, // In a bottom nav, we usually don't have back buttons on root pages
        title: Text(
          'Notice Board',
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 18, color: theme.primaryColor),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            color: Colors.white.withValues(alpha: 0.9),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedFilter = filter);
                      },
                      selectedColor: theme.primaryColor,
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Main Content Canvas
          Expanded(
            child: ref.watch(noticesStreamProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (notices) {
                final filteredNotices = _selectedFilter == 'All' 
                    ? notices 
                    : notices.where((n) => n.tag == _selectedFilter).toList();
                
                if (filteredNotices.isEmpty) {
                  return const Center(child: Text('No notices found.'));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredNotices.length,
                  itemBuilder: (context, index) {
                    final notice = filteredNotices[index];
                    // Very simple date formatting
                    final diff = DateTime.now().difference(notice.createdAt);
                    String dateStr = '${diff.inDays} days ago';
                    if (diff.inDays == 0) {
                      dateStr = diff.inHours > 0 ? '${diff.inHours} hours ago' : '${diff.inMinutes} mins ago';
                    }
                    
                    return NoticeBoardCard(
                      title: notice.title,
                      description: notice.description,
                      tag: notice.tag,
                      date: dateStr,
                      sender: notice.senderName,
                      senderIcon: Icons.person,
                      isUrgent: notice.tag == 'Urgent',
                      onTap: () {},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
