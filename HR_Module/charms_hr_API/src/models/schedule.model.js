const db = require('../../config/db.config.js');

class Schedule {
    static async create(data) {
        const query = `INSERT INTO schedule 
            (staff_id, work_date, work_location, staff_type, intern_slot, 
            work_start_time, work_end_time, break_start_time, break_end_time) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`;

        return new Promise((resolve, reject) => {
            db.query(query, [
                data.staff_id,
                data.work_date,
                data.work_location,
                data.staff_type,
                data.intern_slot,
                data.work_start_time,
                data.work_end_time,
                data.break_start_time,
                data.break_end_time
            ], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(result.insertId);
                }
            });
        });
    }

    static async getAll() {
        const query = `SELECT * FROM schedule`;
        return new Promise((resolve, reject) => {
            db.query(query, (error, results) => {
                if (error) {
                    reject(error);
                }
                resolve(results);
            });
        });
    }

    static async getByStaffId(staffId) {
        const query = `SELECT * FROM schedule WHERE staff_id = ?`;
        return new Promise((resolve, reject) => {
            db.query(query, [staffId], (error, results) => {
                if (error) {
                    reject(error);
                }
                resolve(results);
            });
        });
    }

    static async update(id, data) {
        const query = `UPDATE schedule SET ? WHERE sched_id = ?`;
        return new Promise((resolve, reject) => {
            db.query(query, [data, id], (error, result) => {
                if (error) {
                    reject(error);
                }
                resolve(result.affectedRows > 0);
            });
        });
    }

    static async delete(id) {
        const query = `DELETE FROM schedule WHERE sched_id = ?`;
        return new Promise((resolve, reject) => {
            db.query(query, [id], (error, result) => {
                if (error) {
                    reject(error);
                }
                resolve(result.affectedRows > 0);
            });
        });
    }
}

module.exports = Schedule;