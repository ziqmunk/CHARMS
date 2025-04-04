const express = require('express');
const router = express.Router();

const bookController = require('../controllers/booking.controller');

router.post('/create', bookController.createBooking);
router.post('/group', bookController.addGroupBooking);
router.get('/', bookController.fetchBooking);
router.get('/group/:confirmnum', bookController.fetchGroupBooking);
// router.get('/count/:eventid', bookController.fetchEventVolCount);
// router.post('/book', bookController.bookEvent);

module.exports = router;