const Schedule = require('../models/schedule.model.js');

// Get all schedules
exports.getAllSchedules = async (req, res) => {
    try {
        const results = await Schedule.getAll();
        res.status(200).json(results);
    } catch (err) {
        console.error("Error fetching schedules:", err); // Log the error details
        res.status(500).json({ message: "Error fetching schedules", error: err.message || err });
    }
};

// Get schedules by staff ID
exports.getScheduleByStaff = async (req, res) => {
    try {
        const { staff_id } = req.params;
        const results = await Schedule.getByStaffId(staff_id);
        if (!results.length) {
            return res.status(404).json({ message: "No schedule found for this staff" });
        }
        res.status(200).json(results);
    } catch (err) {
        res.status(500).json({ message: "Error fetching schedule", error: err });
    }
};

// Add a new schedule
exports.addSchedule = async (req, res) => {
    try {
        console.log('Received data:', req.body); // Add logging
        const schedules = Array.isArray(req.body) ? req.body : [req.body];

        const scheduleIds = await Promise.all(
            schedules.map(schedule => Schedule.create({
                staff_id: schedule.staff_id,
                work_date: schedule.work_date,
                work_location: schedule.work_location,
                staff_type: schedule.staff_type,
                intern_slot: schedule.intern_slot,
                work_start_time: schedule.work_start_time,
                work_end_time: schedule.work_end_time,
                break_start_time: schedule.break_start_time,
                break_end_time: schedule.break_end_time
            }))
        );

        res.status(201).json({
            message: "Schedules added successfully",
            scheduleIds
        });
    } catch (err) {
        console.error('Database error:', err); // Add error logging
        res.status(500).json({
            message: "Error adding schedules",
            error: err.message
        });
    }
};

// Add multiple new schedules
exports.addSchedules = async (req, res) => {
    try {
        const schedules = req.body; // Array of schedules
        const scheduleIds = await Promise.all(
            schedules.map(async (schedule) => {
                const scheduleId = await Schedule.create(schedule);
                return scheduleId;
            })
        );
        res.status(201).json({ message: 'Schedules added successfully', scheduleIds });
    } catch (err) {
        res.status(500).json({ message: 'Error adding schedules', error: err });
    }
};

// Update a schedule
exports.updateSchedule = async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;
        const updated = await Schedule.update(id, updates);
        if (!updated) {
            return res.status(404).json({ message: "Schedule not found" });
        }
        res.status(200).json({ message: "Schedule updated successfully" });
    } catch (err) {
        res.status(500).json({ message: "Error updating schedule", error: err });
    }
};

// Delete schedule by ID
exports.deleteSchedule = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await Schedule.delete(id);
        if (!deleted) {
            return res.status(404).json({ message: "Schedule not found" });
        }
        res.status(204).json({ message: "Schedule deleted successfully" });
    } catch (err) {
        res.status(500).json({ message: "Error deleting schedule", error: err });
    }
};
