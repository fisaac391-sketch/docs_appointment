import 'package:docs_appointment/service/app_state.dart';
import 'package:docs_appointment/widget/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;
  
  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  String? _selectedTimeSlot;
  AppointmentType _selectedType = AppointmentType.video;
  
  @override
  void iniState() {
    super.initState();
    // Default select first available  slot
    if (widget.doctor.availableTimeslots.isEmpty) {
      _selectedTimeSlot = widget.doctor.availableTimeslots[0];
    }
  }
  
  void _handleConfirmBooking() async {
    if (_selectedDay == null || _selectedTimeSlot == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("please select a date and time slot")),
      );
      return;
    }
    
    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.bookAppointment(
      widget.doctor,
      _selectedDay!,
      _selectedTimeSlot!,
      _selectedType,
    );
    
    if (success && mounted) {
      // Pop back twice to patient dashboard
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Consultation", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsetsGeometry.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(widget.doctor.imageUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(widget.doctor.specialty, style: const TextStyle(color: AppTheme.accent, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Select Date Section
            const Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Visual Calendar
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff0f172a) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              ),
              padding: const EdgeInsets.all(8),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days:30)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.twoWeeks,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.primary,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(color: AppTheme.accent,fontWeight: FontWeight.bold),
                  selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  defaultTextStyle: TextStyle(color: isDark ? Colors.white70 : AppTheme.primary),
                  weekendTextStyle: const TextStyle(color: Colors.redAccent),
                  outsideDaysVisible: false,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Time Slots Section
            const Text("Select Time Slot", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.doctor.availableTimeslots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return ChoiceChip(
                  label: Text(
                    slot,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppTheme.primary),
                    ),
                  ),
                  selected: isSelected,
                    onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedTimeSlot = slot);
                    }
                    },
                  selectedColor: AppTheme.accent,
                  backgroundColor: isDark ? const Color(0xff0f172a) : const Color(0xffe2e8f0).withOpacity(0.5),
                  checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black.withOpacity(0.5)),
                   ),
                    ),
                );
              }).toList(),
                
              ),
               const SizedBox(height: 24),
                // Consultation Mode Grid
                const Text("Consultation format", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    Row(
      children: [
        _buildFormatCard(AppointmentType.video, "Video Call", Icons.videocam_rounded, AppTheme.accent, isDark),
        const SizedBox(height: 8),
        _buildFormatCard(AppointmentType.voice, "Voice Call", Icons.phone_rounded, Colors.indigo, isDark),
        const SizedBox(width: 8),
        _buildFormatCard(AppointmentType.inPeson, "in-Clinic", Icons.location_on_rounded, Colors.black54, isDark),
      ],
            ),
            
            const SizedBox(height: 48),
            
            // Confirm Button 
            Consumer<AppState>(
              builder: (context, state, child) {
                return CustomButton(
                  text: "Confirm Schedule",
                  isLoading: state.isLoading,
                  onPressed: _handleConfirmBooking,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFormatCard(AppointmentType type,String title, IconData icon, Color activeColor, bool isDark) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withOpacity(0.12)
                : (isDark ? const Color(0xff0f172a): Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? activeColor : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? activeColor : (isDark ? Colors.white30 : Colors.black38), size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? activeColor : (isDark ? Colors.white70 : AppTheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}