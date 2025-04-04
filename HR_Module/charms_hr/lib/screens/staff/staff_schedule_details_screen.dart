import 'package:charms_hr/providers/attendances.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class StaffScheduleDetailsScreen extends StatefulWidget {
  final String location;
  final DateTime workDate;
  final List<String> assignedStaff;
  final String startTime;
  final String endTime;
  final String startBreak;
  final String endBreak;
  final String status;
  final int scheduleId;
  final int staffId;

  StaffScheduleDetailsScreen({
    required this.location,
    required this.workDate,
    required this.assignedStaff,
    required this.startTime,
    required this.endTime,
    required this.startBreak,
    required this.endBreak,
    required this.status,
    required this.scheduleId,
    required this.staffId,
  });

  @override
  _StaffScheduleDetailsScreenState createState() => _StaffScheduleDetailsScreenState();
}

class _StaffScheduleDetailsScreenState extends State<StaffScheduleDetailsScreen> {
  bool isClockIn = false;
  bool _isLoading = false;
  bool _isCheckingAttendance = true;

  @override
  void initState() {
    super.initState();
    _checkExistingAttendance();
  }

  Future<void> _checkExistingAttendance() async {
    try {
      final attendanceProvider = Provider.of<Attendances>(context, listen: false);
      final hasAttendance = await attendanceProvider.checkAttendance(
        staffId: widget.staffId,
        scheduleId: widget.scheduleId,
      );
      if (mounted) {
        setState(() {
          isClockIn = hasAttendance;
          _isCheckingAttendance = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isCheckingAttendance = false);
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isCheckingAttendance = true);
    await _checkExistingAttendance();
  }

  Future<String> _compressAndEncodeImage(File imageFile) async {
  try {
    // Read the file
    final List<int> imageBytes = await imageFile.readAsBytes();
    
    // Decode the image
    final img.Image? originalImage = img.decodeImage(Uint8List.fromList(imageBytes));
    
    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }
    
    // Resize the image to a smaller size
    final int targetWidth = 800;
    final double aspectRatio = originalImage.width / originalImage.height;
    final int targetHeight = (targetWidth / aspectRatio).round();
    
    final img.Image resizedImage = img.copyResize(
      originalImage,
      width: targetWidth,
      height: targetHeight,
    );
    
    // Encode to JPEG with quality 70
    final List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 70);
    
    // Convert to base64
    return base64Encode(compressedBytes);
  } catch (e) {
    print('Error compressing image: $e');
    // Fallback to original image with lower quality
    final List<int> imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(Uint8List.fromList(imageBytes));
    if (originalImage != null) {
      final List<int> compressedBytes = img.encodeJpg(originalImage, quality: 50);
      return base64Encode(compressedBytes);
    }
    
    // If all else fails, read the file directly but with warning
    print('Warning: Using uncompressed image');
    return base64Encode(await imageFile.readAsBytes());
  }
}

// Then modify your _handleClockIn method
Future<void> _handleClockIn() async {
  setState(() => _isLoading = true);
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );

    if (image != null) {
      // Create a File from XFile
      final File imageFile = File(image.path);
      
      // Show a loading message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing image...'), duration: Duration(seconds: 1)),
      );
      
      // Compress and encode the image
      final base64Image = await _compressAndEncodeImage(imageFile);
      
      // Show another loading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploading...'), duration: Duration(seconds: 1)),
        );
      }

      final attendanceProvider = Provider.of<Attendances>(context, listen: false);
      final success = await attendanceProvider.recordAttendance(
        staffId: widget.staffId,
        scheduleId: widget.scheduleId,
        imageBase64: base64Image,
        clockInTime: DateTime.now().toIso8601String(),
      );

      if (success && mounted) {
        setState(() => isClockIn = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully clocked in!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please capture an image to clock in')),
      );
    }
  } catch (error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clock in: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAttendance) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Schedule Details', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      DetailsRow(label: 'Location', value: widget.location),
                      DetailsRow(
                        label: 'Date',
                        value: DateFormat('dd MMM yyyy').format(widget.workDate),
                      ),
                      DetailsRow(label: 'Start Time', value: widget.startTime),
                      DetailsRow(label: 'End Time', value: widget.endTime),
                      DetailsRow(label: 'Break Start', value: widget.startBreak),
                      DetailsRow(label: 'Break End', value: widget.endBreak),
                      DetailsRow(
                        label: 'Status',
                        value: isClockIn ? 'Clocked In' : widget.status,
                        valueColor: isClockIn ? Colors.green : 
                                 widget.status.toLowerCase() == 'active' ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned Staff',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.assignedStaff.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  widget.assignedStaff[index][0],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                widget.assignedStaff[index],
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                '${widget.startTime} - ${widget.endTime}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (!isClockIn)
                ElevatedButton.icon(
                  onPressed: _showAttendanceDialog,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Clock In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clock In'),
          content: Container(
            height: 300,
            width: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: _isLoading 
                      ? CircularProgressIndicator() 
                      : Text('Camera Preview'),
                  ),
                ),
                CustomPaint(
                  painter: FaceOverlayPainter(),
                  child: Container(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                Navigator.pop(context);
                _handleClockIn();
              },
              child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Clock In'),
            ),
          ],
        );
      },
    );
  }
}

class DetailsRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  DetailsRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.8,
        height: size.height * 0.8,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
