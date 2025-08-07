import 'package:flutter/material.dart';
import 'package:vaxtrack/models.dart';
import 'package:vaxtrack/storage_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<VaccinationRecord> records = [];
  List<Appointment> appointments = [];
  List<UserProfile> profiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedRecords = await StorageService.getRecords();
    final loadedAppointments = await StorageService.getAppointments();
    final loadedProfiles = await StorageService.getProfiles();
    
    setState(() {
      records = loadedRecords;
      appointments = loadedAppointments;
      profiles = loadedProfiles;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                        'Health Records',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.download,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _downloadCertificate,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _addRecord,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your family\'s vaccination history and certificates',
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
                Tab(text: 'History'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Certificates'),
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
                  _HistoryTab(records: records, profiles: profiles),
                  _UpcomingTab(appointments: appointments, profiles: profiles),
                  _CertificatesTab(records: records, profiles: profiles),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadCertificate() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CertificateDownloadSheet(
        profiles: profiles,
        records: records,
      ),
    );
  }

  void _addRecord() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddRecordBottomSheet(
        profiles: profiles,
        onRecordAdded: (record) {
          setState(() {
            records.add(record);
          });
          StorageService.saveRecords(records);
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _HistoryTab extends StatelessWidget {
  final List<VaccinationRecord> records;
  final List<UserProfile> profiles;

  const _HistoryTab({required this.records, required this.profiles});

  @override
  Widget build(BuildContext context) {
    final sortedRecords = List<VaccinationRecord>.from(records)
      ..sort((a, b) => b.dateAdministered.compareTo(a.dateAdministered));

    if (sortedRecords.isEmpty) {
      return _EmptyState(
        icon: Icons.vaccines_outlined,
        title: 'No vaccination records',
        subtitle: 'Add your family\'s vaccination history to get started',
        actionLabel: 'Add Record',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        final profile = profiles.firstWhere(
          (p) => p.id == record.profileId,
          orElse: () => UserProfile(
            id: '',
            name: 'Unknown',
            phone: '',
            dateOfBirth: DateTime.now(),
            gender: '',
            relation: '',
          ),
        );
        
        return _VaccinationRecordCard(
          record: record,
          profile: profile,
          onTap: () => _showRecordDetails(context, record, profile),
        );
      },
    );
  }

  void _showRecordDetails(BuildContext context, VaccinationRecord record, UserProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VaccinationDetailsScreen(record: record, profile: profile),
      ),
    );
  }
}

class _UpcomingTab extends StatelessWidget {
  final List<Appointment> appointments;
  final List<UserProfile> profiles;

  const _UpcomingTab({required this.appointments, required this.profiles});

  @override
  Widget build(BuildContext context) {
    final upcomingAppointments = appointments.where((a) => 
      a.status == 'Scheduled' && a.appointmentDate.isAfter(DateTime.now())
    ).toList()..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    if (upcomingAppointments.isEmpty) {
      return _EmptyState(
        icon: Icons.event_outlined,
        title: 'No upcoming appointments',
        subtitle: 'Book an appointment to stay up to date with vaccinations',
        actionLabel: 'Book Appointment',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = upcomingAppointments[index];
        final profile = profiles.firstWhere(
          (p) => p.id == appointment.profileId,
          orElse: () => UserProfile(
            id: '',
            name: 'Unknown',
            phone: '',
            dateOfBirth: DateTime.now(),
            gender: '',
            relation: '',
          ),
        );
        
        return _AppointmentCard(
          appointment: appointment,
          profile: profile,
          onTap: () => _showAppointmentDetails(context, appointment, profile),
        );
      },
    );
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment, UserProfile profile) {
    // TODO: Show appointment details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appointment for ${profile.name}')),
    );
  }
}

class _CertificatesTab extends StatelessWidget {
  final List<VaccinationRecord> records;
  final List<UserProfile> profiles;

  const _CertificatesTab({required this.records, required this.profiles});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _EmptyState(
        icon: Icons.verified_outlined,
        title: 'No certificates available',
        subtitle: 'Certificates will be generated after completing vaccinations',
        actionLabel: 'View History',
        onAction: () {},
      );
    }

    final groupedByProfile = <String, List<VaccinationRecord>>{};
    for (final record in records) {
      groupedByProfile.putIfAbsent(record.profileId, () => []).add(record);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedByProfile.keys.length,
      itemBuilder: (context, index) {
        final profileId = groupedByProfile.keys.elementAt(index);
        final profileRecords = groupedByProfile[profileId]!;
        final profile = profiles.firstWhere(
          (p) => p.id == profileId,
          orElse: () => UserProfile(
            id: '',
            name: 'Unknown',
            phone: '',
            dateOfBirth: DateTime.now(),
            gender: '',
            relation: '',
          ),
        );
        
        return _CertificateCard(
          profile: profile,
          recordCount: profileRecords.length,
          lastUpdated: profileRecords.map((r) => r.dateAdministered).reduce(
            (a, b) => a.isAfter(b) ? a : b,
          ),
          onTap: () => _showCertificate(context, profile, profileRecords),
        );
      },
    );
  }

  void _showCertificate(BuildContext context, UserProfile profile, List<VaccinationRecord> records) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CertificateScreen(profile: profile, records: records),
      ),
    );
  }
}

class _VaccinationRecordCard extends StatelessWidget {
  final VaccinationRecord record;
  final UserProfile profile;
  final VoidCallback onTap;

  const _VaccinationRecordCard({
    required this.record,
    required this.profile,
    required this.onTap,
  });

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                            record.vaccineName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${profile.name} • ${record.vaccineType}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(context, record.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        record.status,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(context, record.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Given on ${DateFormat('MMM dd, yyyy').format(record.dateAdministered)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.clinicName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                if (record.nextDueDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next due: ${DateFormat('MMM dd, yyyy').format(record.nextDueDate!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final UserProfile profile;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = appointment.appointmentDate.isAfter(DateTime.now());
    final daysUntil = appointment.appointmentDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUpcoming 
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.vaccineName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${profile.name} • ${appointment.clinicName}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUpcoming && daysUntil <= 7)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          daysUntil == 0 ? 'Today' : '${daysUntil}d',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(appointment.appointmentDate)} at ${appointment.timeSlot}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final UserProfile profile;
  final int recordCount;
  final DateTime lastUpdated;
  final VoidCallback onTap;

  const _CertificateCard({
    required this.profile,
    required this.recordCount,
    required this.lastUpdated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.verified,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.name}\'s Certificate',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$recordCount vaccinations recorded',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated ${DateFormat('MMM dd, yyyy').format(lastUpdated)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateDownloadSheet extends StatelessWidget {
  final List<UserProfile> profiles;
  final List<VaccinationRecord> records;

  const _CertificateDownloadSheet({
    required this.profiles,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Download Certificate',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a family member to download their vaccination certificate',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...profiles.map((profile) => ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(profile.name),
            subtitle: Text('${profile.relation} • ${records.where((r) => r.profileId == profile.id).length} records'),
            trailing: const Icon(Icons.download),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading certificate for ${profile.name}')),
              );
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AddRecordBottomSheet extends StatefulWidget {
  final List<UserProfile> profiles;
  final Function(VaccinationRecord) onRecordAdded;

  const _AddRecordBottomSheet({
    required this.profiles,
    required this.onRecordAdded,
  });

  @override
  State<_AddRecordBottomSheet> createState() => _AddRecordBottomSheetState();
}

class _AddRecordBottomSheetState extends State<_AddRecordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineController = TextEditingController();
  final _typeController = TextEditingController();
  final _clinicController = TextEditingController();
  final _batchController = TextEditingController();
  DateTime? _dateAdministered;
  String? _selectedProfileId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Add Vaccination Record',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedProfileId,
                      decoration: InputDecoration(
                        labelText: 'Family Member',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: widget.profiles.map((profile) => DropdownMenuItem(
                        value: profile.id,
                        child: Text(profile.name),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedProfileId = value),
                      validator: (value) => value == null ? 'Please select a profile' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vaccineController,
                      decoration: InputDecoration(
                        labelText: 'Vaccine Name',
                        prefixIcon: const Icon(Icons.vaccines_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Vaccine name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _typeController,
                      decoration: InputDecoration(
                        labelText: 'Vaccine Type/Brand',
                        prefixIcon: const Icon(Icons.medical_services_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Vaccine type is required' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date Administered',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _dateAdministered == null 
                              ? 'Select date' 
                              : DateFormat('MMM dd, yyyy').format(_dateAdministered!),
                          style: _dateAdministered == null 
                              ? TextStyle(color: Theme.of(context).hintColor)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clinicController,
                      decoration: InputDecoration(
                        labelText: 'Clinic Name',
                        prefixIcon: const Icon(Icons.local_hospital_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Clinic name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _batchController,
                      decoration: InputDecoration(
                        labelText: 'Batch Number (Optional)',
                        prefixIcon: const Icon(Icons.qr_code_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Record',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dateAdministered = date);
    }
  }

  void _saveRecord() {
    if (_formKey.currentState?.validate() != true || 
        _dateAdministered == null || 
        _selectedProfileId == null) return;

    final record = VaccinationRecord(
      id: 'record_${DateTime.now().millisecondsSinceEpoch}',
      profileId: _selectedProfileId!,
      vaccineName: _vaccineController.text,
      vaccineType: _typeController.text,
      dateAdministered: _dateAdministered!,
      clinicName: _clinicController.text,
      batchNumber: _batchController.text.isEmpty ? 'N/A' : _batchController.text,
      status: 'Completed',
    );

    widget.onRecordAdded(record);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _vaccineController.dispose();
    _typeController.dispose();
    _clinicController.dispose();
    _batchController.dispose();
    super.dispose();
  }
}

class VaccinationDetailsScreen extends StatelessWidget {
  final VaccinationRecord record;
  final UserProfile profile;

  const VaccinationDetailsScreen({
    super.key,
    required this.record,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(record.vaccineName),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing vaccination record')),
              );
            },
          ),
        ],
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
                    Icons.verified,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    record.vaccineName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Administered to ${profile.name}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _DetailCard(
              title: 'Vaccination Details',
              items: [
                _DetailItem('Vaccine Name', record.vaccineName),
                _DetailItem('Vaccine Type', record.vaccineType),
                _DetailItem('Batch Number', record.batchNumber),
                _DetailItem('Status', record.status),
              ],
            ),
            const SizedBox(height: 16),
            _DetailCard(
              title: 'Administration Details',
              items: [
                _DetailItem('Date Given', DateFormat('MMMM dd, yyyy').format(record.dateAdministered)),
                _DetailItem('Clinic/Hospital', record.clinicName),
                if (record.nextDueDate != null)
                  _DetailItem('Next Due Date', DateFormat('MMMM dd, yyyy').format(record.nextDueDate!)),
              ],
            ),
            const SizedBox(height: 16),
            _DetailCard(
              title: 'Patient Information',
              items: [
                _DetailItem('Name', profile.name),
                _DetailItem('Date of Birth', DateFormat('MMMM dd, yyyy').format(profile.dateOfBirth)),
                _DetailItem('Gender', profile.gender),
                _DetailItem('Phone', profile.phone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CertificateScreen extends StatelessWidget {
  final UserProfile profile;
  final List<VaccinationRecord> records;

  const CertificateScreen({
    super.key,
    required this.profile,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${profile.name}\'s Certificate'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading certificate as PDF')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing vaccination certificate')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'VACCINATION CERTIFICATE',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This certifies that the following vaccinations have been administered',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _CertificateSection(
                  title: 'Patient Information',
                  items: [
                    'Name: ${profile.name}',
                    'Date of Birth: ${DateFormat('MMMM dd, yyyy').format(profile.dateOfBirth)}',
                    'Gender: ${profile.gender}',
                    'Phone: ${profile.phone}',
                  ],
                ),
                const SizedBox(height: 24),
                _CertificateSection(
                  title: 'Vaccination Records',
                  items: records.map((record) => 
                    '${record.vaccineName} (${record.vaccineType}) - ${DateFormat('MMM dd, yyyy').format(record.dateAdministered)} at ${record.clinicName}'
                  ).toList(),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Certificate ID: VT${profile.id.toUpperCase()}${DateTime.now().year}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generated on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<_DetailItem> items;

  const _DetailCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    item.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
}

class _CertificateSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _CertificateSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• $item',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}