const dbConn = require('../../config/db.config.js');
const bcrypt = require('bcryptjs');

var Users = function (newuser) {
    this.id = newuser.id;
    this.firstname = newuser.firstname;
    this.lastname = newuser.lastname;
    this.phone = newuser.phone;
    this.dob = newuser.dob;
    this.address1 = newuser.address1;
    this.address2 = newuser.address2;
    this.city = newuser.city;
    this.postcode = newuser.postcode;
    this.state = newuser.state;
    this.country = newuser.country;
    this.occupation = newuser.occupation;
    this.gender = newuser.gender;
    this.username = newuser.username;
    this.email = newuser.email;
    this.passkey = newuser.passkey;
    this.usertype = newuser.usertype;
    this.filepath = newuser.filepath;
    this.filename = newuser.filename;
    this.idnum = newuser.idnum;
    this.category = newuser.category;
    this.nationality = newuser.nationality;
    this.religion = newuser.religion;
    this.marital_status = newuser.marital_status;
    this.office_phone = newuser.office_phone;
    this.emergency_name = newuser.emergency_name;
    this.emergency_ic = newuser.emergency_ic;
    this.emergency_relation = newuser.emergency_relation;
    this.emergency_gender = newuser.emergency_gender;
    this.emergency_phone = newuser.emergency_phone;
};

// Create new user and staff
Users.createNewUser = (userReqData, result) => {
    const userdataQuery = `
        INSERT INTO userdata (firstname, lastname, phone, dob, address1, address2, city, postcode, state, country, occupation, gender, idnum, filename)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    dbConn.query(userdataQuery, [
        userReqData.firstname,
        userReqData.lastname,
        userReqData.phone,
        userReqData.dob,
        userReqData.address1,
        userReqData.address2,
        userReqData.city,
        userReqData.postcode,
        userReqData.state,
        userReqData.country,
        userReqData.occupation,
        userReqData.gender,
        userReqData.idnum,
        userReqData.filename,
    ], (err, res) => {
        if (err) {
            console.log('Error inserting into userdata:', err);
            result(err, null);
            return;
        }

        const userId = res.insertId;

        bcrypt.hash(userReqData.passkey, 10, (err, hash) => {
            if (err) {
                console.log('Error hashing password:', err);
                result(err, null);
                return;
            }

            const userloginQuery = `
                INSERT INTO userlogin (userid, username, email, passkey, usertype)
                VALUES (?, ?, ?, ?, ?)
            `;
            dbConn.query(userloginQuery, [
                userId,
                userReqData.username,
                userReqData.email,
                hash,
                userReqData.usertype,
            ], (err) => {
                if (err) {
                    console.log('Error inserting into userlogin:', err);
                    result(err, null);
                    return;
                }

                if (['6', '7', '8', '9', '10'].includes(userReqData.usertype)) {
                    const staffQuery = `
                        INSERT INTO staff (user_id, category, nationality, religion, marital_status, office_phone, emergency_name, emergency_ic, emergency_relation, emergency_gender, emergency_phone)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    `;
                    dbConn.query(staffQuery, [
                        userId,
                        userReqData.category || 1, // Ensure this line is correctly inserting the category
                        userReqData.nationality || 'Unknown',
                        userReqData.religion || 'None',
                        userReqData.marital_status || 1,
                        userReqData.office_phone || 'N/A',
                        userReqData.emergency_name || 'N/A',
                        userReqData.emergency_ic || 'N/A',
                        userReqData.emergency_relation || 'N/A',
                        userReqData.emergency_gender || 1,
                        userReqData.emergency_phone || 'N/A',
                    ], (err) => {
                        if (err) {
                            console.log('Error inserting into staff:', err);
                            result(err, null);
                            return;
                        }

                        result(null, { message: 'User and staff created successfully', userId });
                    });
                } else {
                    result(null, { message: 'User created successfully (no staff record required)', userId });
                }
            });
        });
    });
};


// Login user
Users.loginUser = (userReqData, result) => {
    dbConn.query('SELECT a.*, b.* FROM userlogin a INNER JOIN userdata b ON a.userid = b.id WHERE a.username = ?', userReqData.username, (err, response) => {
        if (err) {
            console.log('Login error');
            result(null, err);
        } else {
            bcrypt.compare(userReqData.passkey, response[0]['passkey'], function (err, res2) {
                if (res2 === true) {
                    console.log('Login Successful');
                    result(null, response);
                } else {
                    result(null, err);
                    console.log('Login failed');
                }
            });
        }
    });
};

// Fetch all users
Users.fetchUsers = (result) => {
    dbConn.query('SELECT a.*, b.* FROM userdata a INNER JOIN userlogin b ON a.id = b.userid', (err, res) => {
        if (err) {
            console.log('Error while fetching users', err);
            result(null, err);
        } else {
            console.log('Users data acquired successfully');
            result(null, res);
        }
    });
};

// Fetch user by ID
Users.fetchUserById = (id, result) => {
    dbConn.query('SELECT a.*, b.* FROM userdata a INNER JOIN userlogin b ON a.id = b.userid WHERE a.id = ?', id, (err, res) => {
        if (err) {
            console.log('Error while fetching users', err);
            result(null, err);
        } else {
            console.log('Users data acquired successfully');
            result(null, res);
        }
    });
};

// Fetch user by username
Users.fetchUserByUsername = (username, result) => {
    dbConn.query(
        'SELECT a.*, b.* FROM userdata a INNER JOIN userlogin b ON a.id = b.userid WHERE b.username = ?', 
        username, 
        (err, res) => {
            if (err) {
                console.log('Error while fetching user data', err);
                result(null, err);
            } else {
                console.log('User data acquired successfully');
                result(null, res);
            }
        }
    );
};

// Save ID
Users.saveId = (userReqData, result) => {
    dbConn.query('UPDATE userdata SET idnum = ?, filename = ? WHERE id = ?', [userReqData.idnum, userReqData.filename, userReqData.id], (err, res) => {
        if (err) {
            console.log('Error inserting data', err);
            result(null, err);
        } else {
            result(null, { message: 'ID saved' });
        }
    });
};

// Update user
Users.updateUser = (id, userReqData, result) => {
    const query = `
        UPDATE userdata 
        SET firstname = ?, 
            lastname = ?, 
            phone = ?, 
            dob = ?, 
            address1 = ?, 
            address2 = ?, 
            city = ?, 
            postcode = ?, 
            state = ?, 
            country = ?, 
            occupation = ?, 
            gender = ?
        WHERE id = ?`;

    dbConn.query(query, [
        userReqData.firstname,
        userReqData.lastname,
        userReqData.phone,
        userReqData.dob,
        userReqData.address1,
        userReqData.address2,
        userReqData.city,
        userReqData.postcode,
        userReqData.state,
        userReqData.country,
        userReqData.occupation,
        userReqData.gender,
        id
    ], (err, res) => {
        if (err) {
            result(err, null);
            return;
        }
        result(null, { message: 'User updated successfully', data: res });
    });
};

module.exports = Users;
