const express = require('express');
const router = express.Router();
const attendanceController = require('../controllers/attendance.controller');

// Attendance Routes
router.get('/check', attendanceController.checkAttendance);
router.post('/create', attendanceController.createAttendance);
router.get('/', attendanceController.getAllAttendance);
router.get('/:id', attendanceController.getAttendanceById);
router.put('/:id', attendanceController.updateAttendance);
router.delete('/:id', attendanceController.deleteAttendance);

module.exports = router;
