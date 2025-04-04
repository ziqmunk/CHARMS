const db = require('../../config/db.config.js');

class Payment {
    static create(data) {
        const query = `
            INSERT INTO payment (
                staff_id, work_date, basic_pay, total_bonus,
                total_deduction, total_salary, pdf_path
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
        `;
        const values = [
            data.staff_id,
            data.work_date,
            data.basic_pay,
            data.total_bonus,
            data.total_deduction,
            data.total_salary,
            data.pdf_path
        ];

        return new Promise((resolve, reject) => {
            db.query(query, values, (err, result) => {
                if (err) reject(err);
                else resolve(result.insertId);
            });
        });
    }

    static getAll() {
        const query = 'SELECT * FROM payment';
        return new Promise((resolve, reject) => {
            db.query(query, (err, results) => {
                if (err) reject(err);
                else resolve(results);
            });
        });
    }

    static getAllByMonth(year, month) {
        const query = 'SELECT * FROM payment WHERE YEAR(work_date) = ? AND MONTH(work_date) = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [year, month], (err, results) => {
                if (err) reject(err);
                else resolve(results);
            });
        });
    }
    
    static getById(id) {
        const query = 'SELECT * FROM payment WHERE payment_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [id], (err, result) => {
                if (err) reject(err);
                else resolve(result[0]);
            });
        });
    }

    static update(id, data) {
        const query = 'UPDATE payment SET ? WHERE payment_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [data, id], (err, result) => {
                if (err) reject(err);
                else resolve(result.affectedRows > 0);
            });
        });
    }

    static delete(id) {
        const query = 'DELETE FROM payment WHERE payment_id = ?';
        return new Promise((resolve, reject) => {
            db.query(query, [id], (err, result) => {
                if (err) reject(err);
                else resolve(result.affectedRows > 0);
            });
        });
    }
}

module.exports = Payment;