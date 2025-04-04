const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment.controller');

// Attendance Routes
router.post('/create', paymentController.createPayment);
router.get('/', paymentController.getAllPayment);
router.get('/by-month', paymentController.getPaymentsByMonth);
router.get('/:id', paymentController.getPaymentById);
router.put('/:id', paymentController.updatePayment);
router.delete('/:id', paymentController.deletePayment);

module.exports = router;
