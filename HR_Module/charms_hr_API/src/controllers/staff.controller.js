const StaffModel = require('../models/staff.model');

// Fetch all staff
exports.fetchAllStaff = (req, res) => {
  StaffModel.fetchAllStaff((err, staffList) => {
      if (err) {
          console.log('Error in fetchAllStaff:', err);
          res.status(500).send({ success: false, message: 'Error fetching staff data' });
      } else {
          console.log('Staff list from model:', staffList); // Log the staff list
          res.json({ success: true, data: staffList });
      }
  });
};

// Fetch staff by ID
exports.fetchStaffById = (req, res) => {
  StaffModel.fetchStaffById(req.params.id, (err, staff) => {
      if (err) res.send(err);
      res.json({ success: true, data: staff });
  });
};

// Update staff
exports.updateStaff = (req, res) => {
  const staffId = req.params.id;
  const { staff_data, user_data, user_login } = req.body;

  StaffModel.updateStaffAndUserData(
    staffId, 
    staff_data, 
    user_data, 
    user_login, 
    (err, result) => {
      if (err) {
        console.error('Error updating staff:', err);
        res.status(500).send({ 
          success: false, 
          message: 'Error updating staff', 
          error: err 
        });
        return;
      }
      res.json({ 
        success: true, 
        message: 'Staff updated successfully', 
        data: result 
      });
    }
  );
};

// Delete staff
exports.deleteStaff = (req, res) => {
  const staffId = req.params.id;
  StaffModel.deleteStaff(staffId, (err, result) => {
    if (err) {
      res.status(500).json({ success: false, message: 'Error deleting staff' });
    } else {
      res.json({ success: true, message: 'Staff deleted successfully' });
    }
  });
};