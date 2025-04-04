const express = require('express');
const router = express.Router();

const indemnityController = require('../controllers/indemnity.controller');

router.post('/create', indemnityController.createIndemnity);
router.get('/:status', indemnityController.fetchIndemnitybyStatus);
router.get('/bytype/:type', indemnityController.fetchIndemnitybyType);

module.exports = router;