import 'package:flutter/material.dart';

class BatchManagementPortalPage extends StatelessWidget {
  const BatchManagementPortalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Batch Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: const Text('A', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Operational Overview
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('OPERATIONAL OVERVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('24 Active Batches', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    const SizedBox(width: 12),
                    const Row(
                      children: [
                        Icon(Icons.trending_up, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text('+3 this semester', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Managing core academic records across 6 major engineering and science departments for the 2024 academic cycle.', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Total Students
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF172548),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.groups, color: Colors.white70, size: 32),
                const SizedBox(height: 16),
                const Text('TOTAL STUDENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white70)),
                const SizedBox(height: 8),
                const Text('4,280', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: 0.8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 8),
                const Text('80% CAPACITY UTILIZED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white70)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by batch name...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
                child: IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: () {}),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildBatchCard('2024 Computer Science', 'DEPT: CS & INFO', '4', '180', Icons.computer, const Color(0xFFDAE2FF), theme),
          const SizedBox(height: 16),
          _buildBatchCard('2023 Electrical Engineering', 'DEPT: ELECTRICAL', '3', '124', Icons.bolt, const Color(0xFFDFE0E0), theme),
          const SizedBox(height: 16),
          _buildBatchCard('2022 Mechanical Eng.', 'DEPT: MECHANICAL', '6', '240', Icons.precision_manufacturing, const Color(0xFFFFDCBC), theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Batch', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBatchCard(String title, String subtitle, String sections, String students, IconData icon, Color iconBg, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: theme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF5F3F6), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SECTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                      const SizedBox(height: 4),
                      RichText(text: TextSpan(children: [
                        TextSpan(text: sections, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                        const TextSpan(text: ' Units', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ])),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF5F3F6), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('STUDENTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                      const SizedBox(height: 4),
                      RichText(text: TextSpan(children: [
                        TextSpan(text: students, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                        const TextSpan(text: ' Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ])),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Manage', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              IconButton(icon: const Icon(Icons.archive, color: Colors.grey), onPressed: () {}),
            ],
          )
        ],
      ),
    );
  }
}
