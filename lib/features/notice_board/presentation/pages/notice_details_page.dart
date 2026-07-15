import 'package:flutter/material.dart';

class NoticeDetailsPage extends StatelessWidget {
  const NoticeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Notice Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    Icon(Icons.error, size: 14, color: Colors.red),
                    SizedBox(width: 4),
                    Text('URGENT', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Text('ACADEMIC', style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Mid-term Exam Schedule Released',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.black54),
              SizedBox(width: 4),
              Text('Published on Oct 25, 2024', style: TextStyle(color: Colors.black54)),
              SizedBox(width: 16),
              Icon(Icons.schedule, size: 18, color: Colors.black54),
              SizedBox(width: 4),
              Text('2 hours ago', style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1541339907198-e08756dedf3f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFDAE2FF), borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.account_balance, color: Color(0xFF0B1A3C)),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chairman Office', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Department of Computer Science', style: TextStyle(color: Colors.black54, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'All students are hereby informed that the mid-term examinations for the Spring 2024 semester are scheduled to commence from November 15, 2024.\n\n'
            'The examinations will be conducted in two shifts: Morning (09:00 AM - 11:00 AM) and Afternoon (02:00 PM - 04:00 PM). Detailed room assignments are provided in the attached PDF document below.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: Color(0xFF010F32), width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Important Instructions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor)),
                const SizedBox(height: 12),
                const Text('• Strict adherence to the seating plan is mandatory.\n• Students must carry their valid digital admit cards and University IDs.\n• No electronic gadgets (smartwatches, mobile phones) are allowed inside the venue.\n• Late arrival (beyond 15 minutes) will lead to disqualification from the session.', style: TextStyle(height: 1.5, color: Colors.black87)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ensure your profile is updated on the DCMS portal to avoid discrepancies in your attendance and grade reporting.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          
          const SizedBox(height: 32),
          Text('Attachments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.primaryColor)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mid-term_Schedule_Spring_2024.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('2.4 MB • PDF Document', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: theme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {},
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info, color: Color(0xFF172548)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Have questions?', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF010F32))),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black54, height: 1.5, fontFamily: 'Inter'),
                          children: [
                            TextSpan(text: 'For any queries regarding the schedule or venue assignments, please contact the Academic Coordinator\'s office between 10:00 AM and 04:00 PM or email '),
                            TextSpan(text: 'exams@university.edu', style: TextStyle(color: Color(0xFF010F32), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                            TextSpan(text: '.'),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
