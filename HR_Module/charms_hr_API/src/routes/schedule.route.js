const express = require('express');
const router = express.Router();
const scheduleController = require('../controllers/schedule.controller');

// Routes for Schedule
router.post('/create', scheduleController.addSchedule); // Create a new schedule
router.get('/', scheduleController.getAllSchedules); // Get all schedules
router.get('/:staff_id', scheduleController.getScheduleByStaff); // Get schedules by staff ID
router.put('/:id', scheduleController.updateSchedule); // Update schedule by ID
router.delete('/:id', scheduleController.deleteSchedule); // Delete schedule by ID

module.exports = router;