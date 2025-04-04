const db = require('../../config/db.config.js'); // MySQL DB connection

class Leave {
    static create(data) {
        const query = `
            INSERT INTO \`leave\` (staff_id, leave_type, start_date, end_date, reason, proof_file_name, proof_file_type, proof_file, status) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;
        
        const values = [
            data.staff_id,
            data.leave_type,
            data.start_date,
            data.end_date,
            data.reason,
            data.proof_file_name,
            data.proof_file_type,
            data.proof_file,
            data.status
        ];

        return new Promise((resolve, reject) => {
            db.query(query, values, (err, result) => {
                if (err) reject(err);
                else resolve(result.insertId);
            });
        });
    }

    static getAll() {
        const query = "SELECT * FROM `leave`";  // Check if `leave` table name is correct
        return new Promise((resolve, reject) => {
            db.query(query, (err, results) => {
                if (err) {
                    console.error("DB Error in getAll:", err);
                    reject(err);
                } else {
                    console.log("DB Results:", results); // Debugging
                    resolve(results);
                }
            });
        });
    }
    static getById(id) {
        const query = 'SELECT * FROM `leave` WHERE leave_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [id], (err, result) => {
                if (err) reject(err);
                else resolve(result[0]);
            });
        });
    }

    static getByStaffId(staffId) {
        const query = 'SELECT * FROM `leave` WHERE staff_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [staffId], (err, results) => {
                if (err) reject(err);
                else resolve(results);
            });
        });
    }

    static update(id, data) {
        const query = 'UPDATE `leave` SET status = ? WHERE leave_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [data.status, id], (err, result) => {
                if (err) reject(err);
                else resolve(result.affectedRows > 0);
            });
        });
    }

    static delete(id) {
        const query = 'DELETE FROM `leave` WHERE leave_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [id], (err, result) => {
                if (err) reject(err);
                else resolve(result.affectedRows > 0);
            });
        });
    }
}

module.exports = Leave;
