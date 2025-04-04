const express = require('express');
const router = express.Router();

const eventController = require('../controllers/event.controller');

router.post('/create', eventController.createEvent);
router.get('/', eventController.fetchEventGeneral);
router.get('/admin', eventController.fetchEventAdmin);
router.get('/count/:eventid', eventController.fetchEventVolCount);

module.exports = router;