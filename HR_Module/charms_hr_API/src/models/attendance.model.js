const db = require('../../config/db.config.js'); // MySQL DB connection

class Attendance {
    static create(data) {
        const query = 'INSERT INTO attendance SET ?';
        return new Promise((resolve, reject) => {
            db.query(query, data, (err, result) => {
                if (err) reject(err);
                else resolve(result.insertId);
            });
        });
    }

    static getAll() {
        const query = 'SELECT * FROM attendance';
        return new Promise((resolve, reject) => {
            db.query(query, (err, results) => {
                if (err) reject(err);
                else resolve(results);
            });
        });
    }

    static getById(id) {
        const query = 'SELECT * FROM attendance WHERE attendance_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [id], (err, result) => {
                if (err) reject(err);
                else resolve(result[0]);
            });
        });
    }

    static update(id, data) {
        const query = 'UPDATE attendance SET ? WHERE attendance_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [data, id], (err, result) => {
                if (err) reject(err);
                else resolve(result.affectedRows > 0);
            });
        });
    }

    static delete(id) {
        const query = 'DELETE FROM attendance WHERE attendance_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [id], (err, result) => {
                if (err) reject(err);
                else resolve(result.affectedRows > 0);
            });
        });
    }

    static checkAttendance(staffId, scheduleId) {
        const query = `
            SELECT * FROM attendance 
            WHERE staff_id = ? 
            AND schedule_id = ?
        `;
        return new Promise((resolve, reject) => {
            db.query(query, [staffId, scheduleId], (err, result) => {
                if (err) reject(err);
                else resolve(result[0]);
            });
        });
    }
}

module.exports = Attendance;
