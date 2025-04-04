const Payment = require('../models/payment.model');

exports.createPayment = async (req, res) => {
    try {
        const paymentId = await Payment.create(req.body);
        res.status(201).json({ message: 'Payment created successfully', paymentId });
    } catch (err) {
        res.status(500).json({ message: 'Error creating payment', error: err });
    }
};

exports.getAllPayment = async (req, res) => {
    try {
        const results = await Payment.getAll();
        res.status(200).json(results);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching payment', error: err });
    }
};

exports.getPaymentById = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await Payment.getById(id);
        if (!result) {
            return res.status(404).json({ message: 'Payment not found' });
        }
        res.status(200).json(result);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching payment by ID', error: err });
    }
};

exports.updatePayment = async (req, res) => {
    try {
        const { id } = req.params;
        const updated = await Payment.update(id, req.body);
        if (!updated) {
            return res.status(404).json({ message: 'Payment not found' });
        }
        res.status(200).json({ message: 'Payment updated successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error updating payment', error: err });
    }
};

exports.deletePayment = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await Payment.delete(id);
        if (!deleted) {
            return res.status(404).json({ message: 'Payment not found' });
        }
        res.status(204).json({ message: 'Payment deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error deleting payment', error: err });
    }
};

exports.getPaymentsByMonth = async (req, res) => {
    try {
        const { year, month } = req.query;
        const results = await Payment.getAllByMonth(year, month);
        res.status(200).json(results);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching payments by month', error: err });
    }
};
