const Leave = require('../models/leave.model');

exports.createLeave = async (req, res) => {
    try {
        console.log('Received data:', req.body);
        
        // Parse and validate data
        const leaveData = {
            staff_id: Number(req.body.staff_id),
            leave_type: String(req.body.leave_type).trim(),
            start_date: new Date(req.body.start_date),
            end_date: new Date(req.body.end_date),
            reason: String(req.body.reason).trim(),
            status: String(req.body.status).trim(),
            proof_file_name: req.body.proof_file_name || null,
            proof_file_type: String(req.body.proof_file_type).trim(),
            proof_file: req.body.proof_file || null
        };

        // Enhanced validation
        const requiredFields = ['staff_id', 'leave_type', 'start_date', 'end_date', 'reason', 'status'];
        const missingFields = requiredFields.filter(field => !leaveData[field]);

        if (missingFields.length > 0) {
            return res.status(400).json({ 
                message: 'Missing required fields', 
                fields: missingFields 
            });
        }

        const result = await Leave.create(leaveData);
        res.status(201).json({
            message: 'Leave created successfully',
            leaveId: result
        });
    } catch (error) {
        console.error('Create leave error:', error);
        res.status(500).json({ message: 'Error creating leave', error });
    }
};

exports.getAllLeave = async (req, res) => {
    try {
        const results = await Leave.getAll();
        console.log("Leave records fetched:", results); // Debugging
        res.status(200).json(results);
    } catch (err) {
        console.error("Error fetching leave data:", err);
        res.status(500).json({ message: "Error fetching leave", error: err });
    }
};

exports.getLeaveById = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await Leave.getById(id);
        if (!result) {
            return res.status(404).json({ message: 'Leave not found' });
        }
        res.status(200).json(result);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching leave by ID', error: err });
    }
};

exports.getLeavesByStaffId = async (req, res) => {
    try {
        const { staffId } = req.params;
        console.log("Fetching leaves for staff ID:", staffId); // Debugging
        const results = await Leave.getByStaffId(staffId);
        console.log("Results for staff ID:", results); // Debugging
        res.status(200).json({ leaves: results });
    } catch (err) {
        console.error("Error fetching leaves:", err);
        res.status(500).json({ message: "Error fetching leaves", error: err });
    }
};

exports.updateLeave = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        
        // Validate status value
        const validStatuses = ['Pending', 'Approved', 'Rejected'];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({ 
                message: 'Invalid status value' 
            });
        }

        const updated = await Leave.update(id, { status });
        
        if (!updated) {
            return res.status(404).json({ message: 'Leave not found' });
        }

        res.status(200).json({ 
            message: 'Leave status updated successfully',
            status: status 
        });
    } catch (err) {
        console.error('Update error:', err);
        res.status(500).json({ message: 'Error updating leave', error: err });
    }
};

exports.deleteLeave = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await Attendance.delete(id);
        if (!deleted) {
            return res.status(404).json({ message: 'Leave not found' });
        }
        res.status(204).json({ message: 'Leave deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error deleting leave', error: err });
    }
};
