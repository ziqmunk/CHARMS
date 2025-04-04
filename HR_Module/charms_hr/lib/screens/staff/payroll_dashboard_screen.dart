import 'package:charms_hr/models/payment.dart';
import 'package:charms_hr/models/staff.dart';
import 'package:charms_hr/providers/auth.dart';
import 'package:charms_hr/providers/payments.dart';
import 'package:charms_hr/providers/staffs.dart';
import 'package:charms_hr/screens/admin/payroll_details_screen.dart';
import 'package:charms_hr/screens/auth_screen.dart';
import 'package:charms_hr/screens/staff/claim_dashboard.dart';
import 'package:charms_hr/screens/staff/leave_dashboard_screen.dart';
import 'package:charms_hr/screens/staff/staff_dashboard_screen.dart';
import 'package:charms_hr/screens/staff/staff_myself_screen.dart';
import 'package:charms_hr/screens/staff/staff_payroll_details_screen.dart';
import 'package:charms_hr/widgets/custom_drawer.dart';
import 'package:charms_hr/widgets/staff/bottom_nav_staff.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class PayrollDashboardScreen extends StatefulWidget {
  final String username;
  
  const PayrollDashboardScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  _PayrollScreenState createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollDashboardScreen> {
  int selectedYear = DateTime.now().year;
  bool _isLoading = true;
  List<Payment> _monthlyPayments = [];
  Staff? _currentStaff;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  int _selectedIndex = 2;

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _loadPayrollData();
  }

  Future<void> _loadPayrollData() async {
    try {
      final staffsProvider = Provider.of<Staffs>(context, listen: false);
      await staffsProvider.fetchStaff('http://10.0.2.2:5002/cms/api/v1');
      
      _currentStaff = staffsProvider.staffList.firstWhere(
        (staff) => staff.username == widget.username,
        orElse: () => throw Exception('Staff not found'),
      );

      await _fetchPaymentsForYear();
    } catch (error) {
      print('Error loading payroll data: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchPaymentsForYear() async {
  final paymentsProvider = Provider.of<Payments>(context, listen: false);
  
  try {
    await paymentsProvider.fetchPaymentsByMonth(selectedYear, 1); // We only need to fetch once
    
    if (mounted) {
      setState(() {
        _monthlyPayments = paymentsProvider.payments
            .where((payment) => 
                payment.staffId == _currentStaff?.staffId && 
                payment.workDate.year == selectedYear)
            .toList();
      });
    }
    print('Found ${_monthlyPayments.length} payments for staff ${_currentStaff?.staffId}');
  } catch (error) {
    print('Error fetching payments: $error');
  }
}

  // In PayrollDashboardScreen
Future<void> _fetchPaymentsByStaffId() async {
  final paymentsProvider = Provider.of<Payments>(context, listen: false);
  await paymentsProvider.fetchPaymentsByMonth(selectedYear, DateTime.now().month);
  _monthlyPayments = paymentsProvider.payments
      .where((p) => p.staffId == _currentStaff?.staffId)
      .toList();
}

  void _viewPayslip(String month) {
    final monthIndex = months.indexOf(month) + 1;
    final payment = _monthlyPayments.firstWhere(
      (p) => p.workDate.month == monthIndex,
      orElse: () => throw Exception('Payment not found'),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffPayrollDetailsScreen(
          month: month,
          year: selectedYear,
          staffId: _currentStaff?.staffId.toString() ?? '',
          staffName: '${_currentStaff?.firstname} ${_currentStaff?.lastname}',
          workingDays: '22',
          basicPay: payment.basicPay,
          totalBonus: payment.totalBonus,
          totalDeduction: payment.totalDeduction,
          totalSalary: payment.totalSalary,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await Provider.of<Auth>(context, listen: false).logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    
    final routes = [
      () => StaffDashboardScreen(username: widget.username),
      () => LeaveDashboardScreen(username: widget.username, staffId: _currentStaff!.staffId,),
      () => PayrollDashboardScreen(username: widget.username),
      () => ClaimDashboardScreen(username: widget.username, staffId: _currentStaff!.staffId),
      () => StaffMySelfScreen(),
    ];

    if (index < routes.length) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => routes[index]()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHARMS STAFF', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
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
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Payroll: ', 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(width: 160),
                      const Text('Year: ', style: TextStyle(fontSize: 16)),
                      DropdownButton<int>(
                        value: selectedYear,
                        items: List.generate(5, (index) => DateTime.now().year - index)
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ))
                            .toList(),
                        onChanged: (year) async {
                          setState(() => selectedYear = year!);
                          await _fetchPaymentsForYear();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final month = months[index];
                      final monthIndex = index + 1;
                      final hasPayslip = _monthlyPayments.any(
                        (p) => p.workDate.month == monthIndex && 
                              p.workDate.year == selectedYear
                      );

                      return Card(
                        elevation: 3,
                        child: InkWell(
                          onTap: hasPayslip ? () => _viewPayslip(month) : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  month,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  hasPayslip ? 'View Payslip' : 'No Payslip Available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: hasPayslip ? Colors.blue : Colors.grey,
                                  ),
                                ),
                                Icon(
                                  hasPayslip ? Icons.description : Icons.block,
                                  color: hasPayslip ? Colors.blue : Colors.grey,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavStaff(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
