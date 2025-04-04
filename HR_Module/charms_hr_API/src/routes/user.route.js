const express = require('express');
const router = express.Router();

const userController = require('../controllers/user.controller');

// User routes
router.post('/create', userController.createNewUser);
router.post('/auth', userController.loginUser);
router.get('/data/:username', userController.fetchUserByUsername);
router.get('/', userController.fetchUsers);
router.get('/:id', userController.fetchUserById);
router.put('/identity', userController.saveId);
router.put('/:id', userController.updateUser);

module.exports = router;
