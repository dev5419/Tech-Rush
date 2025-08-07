import 'package:flutter/material.dart';
import 'package:vaxtrack/models.dart';
import 'package:vaxtrack/storage_service.dart';
import 'package:vaxtrack/profile_screen.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Clinic? selectedClinic;
  
  const BookingScreen({super.key, this.selectedClinic});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0;
  UserProfile? _selectedProfile;
  String? _selectedVaccine;
  Clinic? _selectedClinic;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  
  List<UserProfile> _profiles = [];
  List<Clinic> _clinics = [];
  
  final List<String> _availableVaccines = [
    'COVID-19 (Covishield)',
    'COVID-19 (Covaxin)',
    'Hepatitis B',
    'HPV Vaccine',
    'Influenza',
    'MMR',
    'Pneumococcal',
    'Tetanus',
    'Typhoid',
    'Varicella',
  ];
  
  final List<String> _timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedClinic = widget.selectedClinic;
    _loadData();
  }

  Future<void> _loadData() async {
    final profiles = await StorageService.getProfiles();
    final clinics = await StorageService.getClinics();
    setState(() {
      _profiles = profiles;
      _clinics = clinics;
    });
  }

  bool get _canProceedToNextStep {
    switch (_currentStep) {
      case 0:
        return _selectedProfile != null;
      case 1:
        return _selectedVaccine != null;
      case 2:
        return _selectedClinic != null;
      case 3:
        return _selectedDate != null && _selectedTimeSlot != null;
      default:
        return false;
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedProfile == null ||
        _selectedVaccine == null ||
        _selectedClinic == null ||
        _selectedDate == null ||
        _selectedTimeSlot == null) {
      return;
    }

    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      profileId: _selectedProfile!.id,
      clinicId: _selectedClinic!.id,
      clinicName: _selectedClinic!.name,
      vaccineName: _selectedVaccine!,
      appointmentDate: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      status: 'Scheduled',
      createdAt: DateTime.now(),
    );

    await StorageService.saveAppointment(appointment);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 48,
          ),
          title: const Text('Appointment Booked!'),
          content: SingleChildScrollView( // Added SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your appointment has been successfully scheduled.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Details:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Patient: ${_selectedProfile!.name}'),
                      Text('Vaccine: $_selectedVaccine'),
                      Text('Clinic: ${_selectedClinic!.name}'),
                      Text('Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'),
                      Text('Time: $_selectedTimeSlot'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index <= _currentStep;
                final isCompleted = index < _currentStep;
                
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 18,
                              )
                            : Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      if (index < 3)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: index < _currentStep
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: _buildStepContent(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _canProceedToNextStep
                    ? () {
                        if (_currentStep < 3) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          _bookAppointment();
                        }
                      }
                    : null,
                child: Text(_currentStep == 3 ? 'Book Appointment' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildProfileSelection();
      case 1:
        return _buildVaccineSelection();
      case 2:
        return _buildClinicSelection();
      case 3:
        return _buildDateTimeSelection();
      default:
        return Container();
    }
  }

  Widget _buildProfileSelection() {
    if (_profiles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'No Profiles Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please create a profile first before booking an appointment.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                  // Refresh profile data when returning from profile screen
                  await _loadData();
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Create Profile'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose who the appointment is for',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _profiles.length,
            itemBuilder: (context, index) {
              final profile = _profiles[index];
              final isSelected = _selectedProfile?.id == profile.id;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedProfile = profile;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              profile.name.isNotEmpty ? profile.name.substring(0, 1).toUpperCase() : '?',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${profile.relation} • ${profile.gender}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  'Age: ${DateTime.now().year - profile.dateOfBirth.year}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVaccineSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Vaccine',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the vaccine you want to book',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _availableVaccines.length,
            itemBuilder: (context, index) {
              final vaccine = _availableVaccines[index];
              final isSelected = _selectedVaccine == vaccine;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedVaccine = vaccine;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.vaccines,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              vaccine,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClinicSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Clinic',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a nearby vaccination center',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _clinics.length,
            itemBuilder: (context, index) {
              final clinic = _clinics[index];
              final isSelected = _selectedClinic?.id == clinic.id;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedClinic = clinic;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              clinic.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.local_hospital,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clinic.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1, // Added maxLines
                                  overflow: TextOverflow.ellipsis, // Added overflow
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  clinic.address,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      clinic.rating,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible( // Added Flexible around the open hours text
                                      child: Text(
                                        '• ${clinic.openHours}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelection() {
    final now = DateTime.now();
    final availableDates = List.generate(14, (index) => now.add(Duration(days: index + 1)));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date & Time',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your preferred appointment slot',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Select Date',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: availableDates.length,
                    itemBuilder: (context, index) {
                      final date = availableDates[index];
                      final isSelected = _selectedDate?.day == date.day &&
                          _selectedDate?.month == date.month &&
                          _selectedDate?.year == date.year;
                      
                      return Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 12),
                        child: Material(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedDate = date;
                                _selectedTimeSlot = null; // Reset time slot
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('EEE').format(date),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.onPrimary
                                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd').format(date),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.onPrimary
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM').format(date),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.onPrimary
                                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Time Slot Selection
                if (_selectedDate != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Select Time Slot',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap( // Changed GridView.builder to Wrap
                      spacing: 12.0, // Horizontal spacing between items
                      runSpacing: 12.0, // Vertical spacing between lines
                      children: _timeSlots.map((timeSlot) {
                        final isSelected = _selectedTimeSlot == timeSlot;
                        return SizedBox( // Added SizedBox to constrain width for a 2-column like layout
                          width: (MediaQuery.of(context).size.width - 32 - 12) / 2, // (Screenwidth - padding - spacing) / 2
                          child: Material(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  _selectedTimeSlot = timeSlot;
                                });
                              },
                              child: Container(
                                height: 50, // Give a fixed height or use aspect ratio with SizedBox
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    timeSlot,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.onPrimary
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                
                const SizedBox(height: 100), // Bottom padding for navigation bar
              ],
            ),
          ),
        ),
      ],
    );
  }
}
