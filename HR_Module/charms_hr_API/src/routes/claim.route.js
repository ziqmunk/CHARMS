const express = require('express');
const router = express.Router();
const claimController = require('../controllers/claim.controller');

// Attendance Routes
router.post('/create', claimController.createClaim);
router.get('/', claimController.getAllClaim);
router.get('/staff/:staffId', claimController.getClaimByStaffId);
router.get('/:id', claimController.getClaimById);
router.put('/:id', claimController.updateClaim);
router.delete('/:id', claimController.deleteClaim);

module.exports = router;
