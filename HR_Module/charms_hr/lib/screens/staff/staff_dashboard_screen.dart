import 'package:charms_hr/providers/attendances.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charms_hr/providers/auth.dart';
import 'package:charms_hr/providers/staffs.dart';
import 'package:charms_hr/providers/schedules.dart';
import 'package:charms_hr/models/staff.dart';
import 'package:charms_hr/models/schedule.dart';
import 'package:charms_hr/screens/auth_screen.dart';
import 'package:charms_hr/screens/staff/leave_dashboard_screen.dart';
import 'package:charms_hr/screens/staff/payroll_dashboard_screen.dart';
import 'package:charms_hr/screens/staff/claim_dashboard.dart';
import 'package:charms_hr/screens/staff/staff_myself_screen.dart';
import 'package:charms_hr/screens/staff/staff_schedule_details_screen.dart';
import 'package:charms_hr/widgets/custom_drawer.dart';
import 'package:charms_hr/widgets/staff/bottom_nav_staff.dart';

class StaffDashboardScreen extends StatefulWidget {
  final String username;

  const StaffDashboardScreen({Key? key, required this.username})
      : super(key: key);

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  int _selectedIndex = 0;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  List<Schedule> _staffSchedules = [];
  Staff? _currentStaff;
  bool _isLoading = true;
  String branch = '';
  int workLocation = 0;
  DateTime? lastLoginTime;
  bool _mounted = true;

  String getBranchName(int workLocation) {
    Map<int, String> branches = {
      1: 'Chagar Hutang',
      2: 'Turtle Lab',
      3: 'UMT',
    };
    return branches[workLocation] ?? 'N/A';
  }

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadStaffData() async {
    if (!_mounted) return;

    try {
      final staffsProvider = Provider.of<Staffs>(context, listen: false);
      final schedulesProvider = Provider.of<Schedules>(context, listen: false);
      final authProvider = Provider.of<Auth>(context, listen: false);

      await staffsProvider.fetchStaff('http://10.0.2.2:5002/cms/api/v1');
      if (!_mounted) return;

      final staffList = staffsProvider.staffList;
      _currentStaff = staffList.firstWhere(
        (staff) => staff.username == widget.username,
        orElse: () => throw Exception('Staff not found'),
      );

      if (_currentStaff != null && _mounted) {
        final schedules = await schedulesProvider
            .fetchSchedulesByStaffId(_currentStaff!.staffId);

        if (_mounted) {
          setState(() {
            _staffSchedules = schedules;
            if (_staffSchedules.isNotEmpty) {
              workLocation = _staffSchedules[0].workLocation;
              branch = getBranchName(workLocation);
            }
            lastLoginTime = authProvider.lastLoginTime ?? DateTime.now();
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      if (_mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    final routes = [
      () => StaffDashboardScreen(username: widget.username),
      () => LeaveDashboardScreen(username: widget.username, staffId: _currentStaff!.staffId,),
      () => PayrollDashboardScreen(username: widget.username,),
      () => ClaimDashboardScreen(username: widget.username, staffId: _currentStaff!.staffId,),
      () => StaffMySelfScreen(),
    ];

    if (index < routes.length) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => routes[index]()),
      );
    }
  }

  Future<void> _logout() async {
    await Provider.of<Auth>(context, listen: false).logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}, "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')} "
        "${dateTime.hour >= 12 ? 'PM' : 'AM'}";
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title:
            const Text('CHARMS STAFF', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      drawer: CustomDrawer(
        selectedLanguage: _selectedLanguage,
        languages: _languages,
        onLanguageChanged: (String? newValue) {
          setState(() => _selectedLanguage = newValue!);
        },
        onLogOut: _logout,
      ),
      body: _buildDashboardContent(),
      bottomNavigationBar: BottomNavStaff(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                "Welcome, ${_currentStaff?.firstname ?? widget.username}!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(lastLoginTime != null
                  ? "Last Login: ${formatDateTime(lastLoginTime!)}"
                  : "Last Login: Not available"),
              const SizedBox(height: 20),
              _buildSchedulesCards(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulesCards() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 800,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          const Text(
            "   Your Schedules:",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          _staffSchedules.isEmpty
              ? Center(
                  child: Text(
                    'No schedules found',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _staffSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _staffSchedules[index];
                      final currentBranch =
                          getBranchName(schedule.workLocation);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.all(5.0),
                        child: ListTile(
                          leading: const Icon(Icons.location_on_outlined,
                              size: 30, color: Colors.blue),
                          title: Text(
                            currentBranch,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              'Date: ${schedule.workDate.toString().split(' ')[0]}\n'
                              'Time: ${schedule.workStartTime} - ${schedule.workEndTime}'),
                          onTap: () async {
                            final attendanceProvider = Provider.of<Attendances>(
                                context,
                                listen: false);
                            final isClockIn =
                                await attendanceProvider.checkAttendance(
                              staffId: _currentStaff?.staffId ?? 0,
                              scheduleId: schedule.schedId,
                            );

                            print('Is Clock In: $isClockIn');

                            if (mounted) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      StaffScheduleDetailsScreen(
                                    location: currentBranch,
                                    workDate: schedule.workDate,
                                    assignedStaff: [
                                      _currentStaff?.firstname ?? ''
                                    ],
                                    startTime:
                                        schedule.workStartTime.toString(),
                                    endTime: schedule.workEndTime.toString(),
                                    startBreak:
                                        schedule.breakStartTime.toString(),
                                    endBreak: schedule.breakEndTime.toString(),
                                    status: isClockIn
                                        ? 'Clocked In'
                                        : 'Not clocked in',
                                    scheduleId: schedule.schedId,
                                    staffId: _currentStaff?.staffId ?? 0,
                                  ),
                                ),
                              );

                              if (result != null &&
                                  result['refreshDashboard']) {
                                await _loadStaffData();
                              }
                            }
                          },
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 30, color: Colors.blue),
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
