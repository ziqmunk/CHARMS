const db = require('../../config/db.config.js'); // MySQL DB connection

class Claim {
    static create(data) {
        const query = 'INSERT INTO claim SET ?';
        return new Promise((resolve, reject) => {
            db.query(query, data, (err, result) => {
                if (err) reject(err);
                else resolve(result.insertId);
            });
        });
    }

    static getAll() {
        const query = 'SELECT * FROM claim';
        return new Promise((resolve, reject) => {
            db.query(query, (err, results) => {
                if (err) reject(err);
                else resolve(results);
            });
        });
    }

    static getById(id) {
        const query = 'SELECT * FROM claim WHERE claim_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [id], (err, result) => {
                if (err) reject(err);
                else resolve(result[0]);
            });
        });
    }

    static getByStaffId(staffId) {
        const query = 'SELECT * FROM claim WHERE staff_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [staffId], (err, results) => {
                if (err) reject(err);
                else resolve(results);
            });
        });
    }

    static update(id, data) {
        const query = 'UPDATE claim SET ? WHERE claim_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [data, id], (err, result) => {
                if (err) reject(err);
                else resolve(result.affectedRows > 0);
            });
        });
    }

    static delete(id) {
        const query = 'DELETE FROM claim WHERE claim_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [id], (err, result) => {
                if (err) reject(err);
                else resolve(result.affectedRows > 0);
            });
        });
    }
}

module.exports = Claim;
