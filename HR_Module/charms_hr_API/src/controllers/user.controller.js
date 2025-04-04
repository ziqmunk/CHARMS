const UserModel = require('../models/user.model');

// Create new user and staff
exports.createNewUser = (req, res) => {
    const userReqData = new UserModel(req.body);
    console.log('userReqData', userReqData);

    // Check for empty request body
    if (req.body.constructor === Object && Object.keys(req.body).length === 0) {
        res.status(400).send({ success: false, message: 'Please fill all fields' });
    } else {
        UserModel.createNewUser(userReqData, (err, user) => {
            if (err) {
                res.send(err);
            } else {
                res.json({ status: true, message: 'User created successfully', data: user });
            }
        });
    }
};

// Login user
exports.loginUser = (req, res) => {
    UserModel.loginUser(req.body, (err, result) => {
        if (err) {
            res.send(err);
            res.json({ success: false, message: 'Login error!' });
        } else {
            if (result !== null) {
                res.json({ success: true, message: 'Login success!', data: result });
            } else {
                res.json({ success: false, message: 'Login failed!' });
            }
        }
    });
};

// Fetch all users
exports.fetchUsers = (req, res) => {
    UserModel.fetchUsers((err, userlist) => {
        if (err) res.send(err);
        res.json({ success: true, data: userlist });
    });
};

// Fetch user by ID
exports.fetchUserById = (req, res) => {
    UserModel.fetchUserById(req.params.id, (err, userlist) => {
        if (err) res.send(err);
        res.json({ success: true, data: userlist });
    });
};

// Fetch user by username
exports.fetchUserByUsername = (req, res) => {
    UserModel.fetchUserByUsername(req.params.username, (err, userdata) => {
        if (err) res.send(err);
        res.json({ success: true, data: userdata });
    });
};

// Save user identity
exports.saveId = (req, res) => {
    const userReqData = new UserModel(req.body);

    // Check for empty request body
    if (req.body.constructor === Object && Object.keys(req.body).length === 0) {
        res.status(400).send({ success: false, message: 'Please fill all fields' });
    } else {
        UserModel.saveId(userReqData, (err, user) => {
            if (err) res.send(err);
            res.json({ status: true, message: 'User identity saved successfully', data: user });
        });
    }
};

// Update user
exports.updateUser = (req, res) => {
    const userReqData = new UserModel(req.body);

    // Check for empty request body
    if (req.body.constructor === Object && Object.keys(req.body).length === 0) {
        res.status(400).send({ success: false, message: 'Please fill all fields' });
    } else {
        UserModel.updateUser(req.params.id, userReqData, (err, user) => {
            if (err) res.send(err);
            res.json({ status: true, message: 'User updated successfully', data: user });
        });
    }
};


