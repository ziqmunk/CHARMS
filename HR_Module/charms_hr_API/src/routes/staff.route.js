const express = require('express');
const router = express.Router();

const staffController = require('../controllers/staff.controller');

// Staff routes
router.get('/', staffController.fetchAllStaff);
router.get('/:id', staffController.fetchStaffById);
router.put('/:id', staffController.updateStaff);
router.delete('/:id', staffController.deleteStaff);

module.exports = router;