import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charms_hr/models/staff.dart';
import 'package:charms_hr/providers/staffs.dart';
import 'package:charms_hr/screens/admin/edit_staff_screen.dart';

class StaffDetailsScreen extends StatelessWidget {
  final Staff staff;

  StaffDetailsScreen({required this.staff});

  @override
  Widget build(BuildContext context) {
    String gender = staff.emergencyGender == 1 ? 'Male' : 'Female';
    String maritalStatus = staff.maritalStatus == 1 ? 'Single' : 'Married';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Staff Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://example.com/staff_image.jpg'),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Personal Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            DetailsRow(label: "Staff ID", value: "${staff.staffId}"),
            DetailsRow(label: "Name", value: "${staff.firstname} ${staff.lastname}"),
            DetailsRow(label: "IC Number", value: staff.idNum),
            DetailsRow(label: "Date of Birth", value: staff.dob),
            DetailsRow(label: "Nationality", value: staff.nationality),
            DetailsRow(label: "Religion", value: staff.religion),
            DetailsRow(label: "Gender", value: gender),
            DetailsRow(label: "Marital Status", value: maritalStatus),
            SizedBox(height: 20),
            Text(
              "Address Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            DetailsRow(label: "Address", value: "${staff.address1}, ${staff.address2}"),
            DetailsRow(label: "City", value: staff.city),
            DetailsRow(label: "State", value: staff.state),
            DetailsRow(label: "Country", value: staff.country),
            DetailsRow(label: "Phone", value: staff.phone),
            DetailsRow(label: "Office Phone", value: staff.officePhone ?? 'N/A'),
            DetailsRow(label: "Email", value: staff.email),
            DetailsRow(label: "Occupation", value: staff.occupation),
            SizedBox(height: 20),
            Text(
              "Emergency Contact Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            DetailsRow(label: "Emergency Name", value: staff.emergencyName),
            DetailsRow(label: "Emergency IC", value: staff.emergencyIc),
            DetailsRow(label: "Emergency Relation", value: staff.emergencyRelation),
            DetailsRow(label: "Emergency Gender", value: gender),
            DetailsRow(label: "Emergency Phone", value: staff.emergencyPhone),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditStaffScreen(staff: staff),
                      ),
                    );
                  },
                  child: Text('Edit Staff Details', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                  child: Text('Delete Staff', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this staff member?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteStaff(context); // Proceed with deletion
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Function to delete staff
  Future<void> _deleteStaff(BuildContext context) async {
    final staffProvider = Provider.of<Staffs>(context, listen: false);
    try {
      await staffProvider.deleteStaff(staff.userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Staff deleted successfully!')),
      );
      Navigator.pop(context); // Go back to the previous screen
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete staff: $error')),
      );
    }
  }
}

class DetailsRow extends StatelessWidget {
  final String label;
  final String value;

  DetailsRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}