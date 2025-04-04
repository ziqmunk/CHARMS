const Attendance = require('../models/attendance.model');

exports.createAttendance = async (req, res) => {
    try {
        const attendanceId = await Attendance.create(req.body);
        res.status(201).json({ message: 'Attendance created successfully', attendanceId });
    } catch (err) {
        res.status(500).json({ message: 'Error creating attendance', error: err });
    }
};

exports.getAllAttendance = async (req, res) => {
    try {
        const results = await Attendance.getAll();
        res.status(200).json(results);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching attendance', error: err });
    }
};

exports.getAttendanceById = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await Attendance.getById(id);
        if (!result) {
            return res.status(404).json({ message: 'Attendance not found' });
        }
        res.status(200).json(result);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching attendance by ID', error: err });
    }
};

exports.updateAttendance = async (req, res) => {
    try {
        const { id } = req.params;
        const updated = await Attendance.update(id, req.body);
        if (!updated) {
            return res.status(404).json({ message: 'Attendance not found' });
        }
        res.status(200).json({ message: 'Attendance updated successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error updating attendance', error: err });
    }
};

exports.deleteAttendance = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await Attendance.delete(id);
        if (!deleted) {
            return res.status(404).json({ message: 'Attendance not found' });
        }
        res.status(204).json({ message: 'Attendance deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error deleting attendance', error: err });
    }
};


exports.checkAttendance = async (req, res) => {
    const { staff_id, schedule_id } = req.query;
    try {
        const attendance = await Attendance.checkAttendance(staff_id, schedule_id);
        if (attendance) {
            res.json({
                exists: true,
                attendance_status: attendance.attendance_status,
                clock_in_time: attendance.clock_in_time
            });
        } else {
            res.json({
                exists: false,
                attendance_status: 1
            });
        }
    } catch (error) {
        res.status(500).json({ message: 'Error checking attendance' });
    }
};