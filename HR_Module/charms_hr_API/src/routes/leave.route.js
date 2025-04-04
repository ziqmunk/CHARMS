const express = require('express');
const router = express.Router();
const leaveController = require('../controllers/leave.controller');

// Attendance Routes
router.post('/create', leaveController.createLeave);
router.get('/', leaveController.getAllLeave);
router.get('/staff/:staffId', leaveController.getLeavesByStaffId);
router.get('/:id', leaveController.getLeaveById);
router.put('/:id', leaveController.updateLeave);
router.delete('/:id', leaveController.deleteLeave);

module.exports = router;
