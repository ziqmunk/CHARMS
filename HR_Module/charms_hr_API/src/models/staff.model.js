const dbConn = require('../../config/db.config.js');

// Staff model constructor
const StaffModel = function (newstaff) {
    this.id = newstaff.id || null;
    this.user_id = newstaff.user_id;
    this.category = newstaff.category || 1; // Default category if not provided
    this.nationality = newstaff.nationality || 'Unknown';
    this.religion = newstaff.religion || 'None';
    this.marital_status = newstaff.marital_status || 1; // Default marital status
    this.office_phone = newstaff.office_phone || 'N/A';
    this.emergency_name = newstaff.emergency_name || 'N/A';
    this.emergency_ic = newstaff.emergency_ic || 'N/A';
    this.emergency_relation = newstaff.emergency_relation || 'N/A';
    this.emergency_gender = newstaff.emergency_gender || 1; // Default gender
    this.emergency_phone = newstaff.emergency_phone || 'N/A';
};

// Fetch all staff
StaffModel.fetchAllStaff = (result) => {
    const query = `
        SELECT 
            s.id,
            ul.userid,
            ul.username,
            ul.email,
            ul.usertype,
            u.firstname,
            u.lastname,
            u.occupation,
            u.phone,
            u.idnum,
            u.dob,
            u.address1,
            u.address2,
            u.city,
            u.postcode,
            u.state,
            u.country,
            s.category,
            s.nationality,
            s.religion,
            s.marital_status,
            s.office_phone,
            s.emergency_name,
            s.emergency_ic,
            s.emergency_relation,
            s.emergency_gender,
            s.emergency_phone
        FROM staff s
        INNER JOIN userdata u ON s.user_id = u.id
        INNER JOIN userlogin ul ON s.user_id = ul.userid
        WHERE ul.usertype IN ('6', '7', '8', '9', '10')
    `;

    console.log('Executing staff query:', query);

    dbConn.query(query, (err, res) => {
        if (err) {
            console.log('Error fetching staff:', err);
            result(err, null);
        } else {
            console.log('Query result:', res); // Log the query result
            console.log('Found staff members:', res.length);
            result(null, res);
        }
    });
};

// Fetch staff by ID
StaffModel.fetchStaffById = (id, result) => {
    const query = `
        SELECT u.*, s.*
        FROM userdata u
        INNER JOIN staff s ON u.id = s.user_id
        WHERE u.id = ?
    `;
    dbConn.query(query, [id], (err, res) => {
        if (err) {
            console.log('Error fetching staff:', err);
            result(err, null);
        } else {
            result(null, res);
        }
    });
};

// Update staff
StaffModel.updateStaff = (id, staffData, result) => {
    const query = `
        UPDATE staff
        SET 
            category = ?,
            nationality = ?,
            religion = ?,
            marital_status = ?,
            office_phone = ?,
            emergency_name = ?,
            emergency_ic = ?,
            emergency_relation = ?,
            emergency_gender = ?,
            emergency_phone = ?
        WHERE user_id = ?
    `;
    dbConn.query(query, [
        staffData.category,
        staffData.nationality,
        staffData.religion,
        staffData.marital_status,
        staffData.office_phone,
        staffData.emergency_name,
        staffData.emergency_ic,
        staffData.emergency_relation,
        staffData.emergency_gender,
        staffData.emergency_phone,
        id,
    ], (err, res) => {
        if (err) {
            console.log('Error updating staff:', err);
            result(err, null);
        } else {
            result(null, res);
        }
    });
};

StaffModel.updateStaffAndUserData = (staffId, staffData, userData, userLogin, result) => {
    dbConn.beginTransaction(err => {
      if (err) {
        return result(err, null);
      }
  
      // Update staff table
      const staffQuery = 'UPDATE staff SET ? WHERE id = ?';
      dbConn.query(staffQuery, [staffData, staffId], (err, staffRes) => {
        if (err) {
          return dbConn.rollback(() => result(err, null));
        }
  
        // Update userdata table
        const userQuery = 'UPDATE userdata SET ? WHERE id = (SELECT user_id FROM staff WHERE id = ?)';
        dbConn.query(userQuery, [userData, staffId], (err, userRes) => {
          if (err) {
            return dbConn.rollback(() => result(err, null));
          }
  
          // Update userlogin table
          const loginQuery = 'UPDATE userlogin SET ? WHERE userid = (SELECT user_id FROM staff WHERE id = ?)';
          dbConn.query(loginQuery, [userLogin, staffId], (err, loginRes) => {
            if (err) {
              return dbConn.rollback(() => result(err, null));
            }
  
            dbConn.commit(err => {
              if (err) {
                return dbConn.rollback(() => result(err, null));
              }
              result(null, { 
                staffUpdate: staffRes, 
                userUpdate: userRes,
                loginUpdate: loginRes 
              });
            });
          });
        });
      });
    });
  };

// Delete staff
StaffModel.deleteStaff = (id, result) => {
    const query = `
        DELETE FROM staff WHERE user_id = ?
    `;
    dbConn.query(query, [id], (err, res) => {
        if (err) {
            console.log('Error deleting staff:', err);
            result(err, null);
        } else {
            result(null, res);
        }
    });
};

module.exports = StaffModel;