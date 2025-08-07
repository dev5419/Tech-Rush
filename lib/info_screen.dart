import 'package:flutter/material.dart';
import 'package:vaxtrack/models.dart';
import 'package:vaxtrack/storage_service.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<VaccineInfo> vaccineInfoList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVaccineInfo();
  }

  void _loadVaccineInfo() {
    vaccineInfoList = StorageService.getVaccineInfo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Health Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () => _showSettings(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stay informed about vaccines and health recommendations',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Vaccines'),
                Tab(text: 'Reminders'),
                Tab(text: 'Settings'),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _VaccinesTab(vaccineInfoList: vaccineInfoList),
                  _RemindersTab(),
                  _SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    _tabController.animateTo(2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _VaccinesTab extends StatelessWidget {
  final List<VaccineInfo> vaccineInfoList;

  const _VaccinesTab({required this.vaccineInfoList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vaccineInfoList.length,
      itemBuilder: (context, index) {
        final vaccine = vaccineInfoList[index];
        return _VaccineInfoCard(
          vaccine: vaccine,
          onTap: () => _showVaccineDetails(context, vaccine),
        );
      },
    );
  }

  void _showVaccineDetails(BuildContext context, VaccineInfo vaccine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VaccineDetailsScreen(vaccine: vaccine),
      ),
    );
  }
}

class _RemindersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final upcomingReminders = [
      _ReminderItem(
        title: 'Annual Flu Shot Due',
        subtitle: 'Recommended for all family members',
        date: DateTime.now().add(const Duration(days: 30)),
        type: 'vaccination',
        priority: 'high',
      ),
      _ReminderItem(
        title: 'COVID-19 Booster Available',
        subtitle: 'New variant protection available',
        date: DateTime.now().add(const Duration(days: 14)),
        type: 'update',
        priority: 'medium',
      ),
      _ReminderItem(
        title: 'Emily\'s MMR Due',
        subtitle: 'Second dose recommended at age 4-6',
        date: DateTime.now().add(const Duration(days: 90)),
        type: 'vaccination',
        priority: 'medium',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingReminders.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ReminderSettings();
        }
        final reminder = upcomingReminders[index - 1];
        return _ReminderCard(reminder: reminder);
      },
    );
  }
}

class _SettingsTab extends StatefulWidget {
  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  bool _notificationsEnabled = true;
  bool _reminderEmails = true;
  bool _weeklyUpdates = false;
  bool _healthTips = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsSection(
          title: 'Notifications',
          children: [
            _SettingsTile(
              title: 'Push Notifications',
              subtitle: 'Receive appointment and reminder notifications',
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
            ),
            _SettingsTile(
              title: 'Email Reminders',
              subtitle: 'Get vaccination reminders via email',
              value: _reminderEmails,
              onChanged: (value) => setState(() => _reminderEmails = value),
            ),
            _SettingsTile(
              title: 'Weekly Health Updates',
              subtitle: 'Receive weekly health and vaccine news',
              value: _weeklyUpdates,
              onChanged: (value) => setState(() => _weeklyUpdates = value),
            ),
            _SettingsTile(
              title: 'Health Tips',
              subtitle: 'Get personalized health recommendations',
              value: _healthTips,
              onChanged: (value) => setState(() => _healthTips = value),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: 'Data & Privacy',
          children: [
            _ActionTile(
              title: 'Export Data',
              subtitle: 'Download your vaccination records',
              icon: Icons.download,
              onTap: () => _exportData(context),
            ),
            _ActionTile(
              title: 'Data Usage',
              subtitle: 'See how your data is used',
              icon: Icons.privacy_tip_outlined,
              onTap: () => _showDataUsage(context),
            ),
            _ActionTile(
              title: 'Delete Account',
              subtitle: 'Permanently remove all data',
              icon: Icons.delete_outline,
              onTap: () => _confirmDeleteAccount(context),
              isDestructive: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: 'Support & Legal',
          children: [
            _ActionTile(
              title: 'Help & Support',
              subtitle: 'Get help with using VaxTrack',
              icon: Icons.help_outline,
              onTap: () => _showHelp(context),
            ),
            _ActionTile(
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              icon: Icons.policy_outlined,
              onTap: () => _showPrivacyPolicy(context),
            ),
            _ActionTile(
              title: 'Terms of Service',
              subtitle: 'View terms and conditions',
              icon: Icons.description_outlined,
              onTap: () => _showTerms(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Text(
                'VaxTrack v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your trusted vaccination companion',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting vaccination data...')),
    );
  }

  void _showDataUsage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Usage'),
        content: const Text(
          'VaxTrack stores your vaccination records locally on your device for privacy and security. '
          'No personal data is shared with third parties without your explicit consent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This will permanently remove all your vaccination records and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested')),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HelpScreen()),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening privacy policy...')),
    );
  }

  void _showTerms(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening terms of service...')),
    );
  }
}

class _VaccineInfoCard extends StatelessWidget {
  final VaccineInfo vaccine;
  final VoidCallback onTap;

  const _VaccineInfoCard({required this.vaccine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.vaccines,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccine.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vaccine.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          vaccine.ageGroup,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Smart Reminders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ll remind you about upcoming vaccinations and important health updates based on your family\'s vaccination history.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.settings,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'Settings',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.add,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    'Add Reminder',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final _ReminderItem reminder;

  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final daysUntil = reminder.date.difference(DateTime.now()).inDays;
    final priorityColor = _getPriorityColor(context, reminder.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getReminderIcon(reminder.type),
            color: priorityColor,
            size: 20,
          ),
        ),
        title: Text(
          reminder.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reminder.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              daysUntil <= 0 ? 'Due now' : 'Due in $daysUntil days',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: priorityColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showReminderOptions(context),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Color _getPriorityColor(BuildContext context, String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getReminderIcon(String type) {
    switch (type) {
      case 'vaccination':
        return Icons.vaccines;
      case 'update':
        return Icons.info;
      case 'appointment':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  void _showReminderOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Mark as Done'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.snooze),
              title: const Text('Snooze'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Dismiss'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDestructive 
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class VaccineDetailsScreen extends StatelessWidget {
  final VaccineInfo vaccine;

  const VaccineDetailsScreen({super.key, required this.vaccine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vaccine.name),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.vaccines,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vaccine.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      vaccine.ageGroup,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _VaccineDetailSection(
              title: 'Description',
              content: vaccine.description,
              icon: Icons.info_outline,
            ),
            _VaccineDetailSection(
              title: 'Dosage & Administration',
              content: vaccine.dosage,
              icon: Icons.medication_outlined,
            ),
            _VaccineDetailSection(
              title: 'Schedule',
              content: vaccine.schedule,
              icon: Icons.schedule,
            ),
            _VaccineDetailSection(
              title: 'Common Side Effects',
              content: vaccine.sideEffects,
              icon: Icons.warning_outlined,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Finding clinics for ${vaccine.name}')),
                  );
                },
                icon: Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: Text(
                  'Find Nearby Clinics',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaccineDetailSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _VaccineDetailSection({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqItems = [
      _FAQItem(
        question: 'How do I add a family member?',
        answer: 'Go to the Profiles tab and tap the + button in the top right corner. Fill out the required information and save.',
      ),
      _FAQItem(
        question: 'Can I book appointments through the app?',
        answer: 'Currently, the app helps you find clinics and their contact information. You\'ll need to call the clinic directly to book an appointment.',
      ),
      _FAQItem(
        question: 'How do I download vaccination certificates?',
        answer: 'Go to the History tab, select the Certificates section, and tap on a family member\'s certificate to view and download it.',
      ),
      _FAQItem(
        question: 'Is my data secure?',
        answer: 'Yes, all your vaccination records are stored locally on your device and are not shared with third parties.',
      ),
      _FAQItem(
        question: 'How do I set up reminders?',
        answer: 'Visit the Info tab, go to Reminders, and customize your notification preferences.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqItems.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _HelpHeader();
          }
          final faq = faqItems[index - 1];
          return _FAQCard(faq: faq);
        },
      ),
    );
  }
}

class _HelpHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.help_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'How can we help you?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions below, or contact our support team.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.email),
            label: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}

class _FAQCard extends StatefulWidget {
  final _FAQItem faq;

  const _FAQCard({required this.faq});

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.faq.question,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.faq.answer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderItem {
  final String title;
  final String subtitle;
  final DateTime date;
  final String type;
  final String priority;

  _ReminderItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
    required this.priority,
  });
}

class _FAQItem {
  final String question;
  final String answer;

  _FAQItem({required this.question, required this.answer});
}