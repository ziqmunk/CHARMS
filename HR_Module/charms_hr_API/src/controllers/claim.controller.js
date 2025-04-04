const Claim = require('../models/claim.model');

exports.createClaim = async (req, res) => {
    console.log('Received claim data:', req.body);
    try {
        const claimId = await Claim.create(req.body);
        console.log('Claim created with ID:', claimId);
        res.status(201).json({ message: 'Claim created successfully', claimId });
    } catch (err) {
        console.error('Error creating claim:', err);
        res.status(500).json({ message: 'Error creating claim', error: err });
    }
};

exports.getAllClaim = async (req, res) => {
    try {
        const results = await Claim.getAll();
        res.status(200).json(results);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching claim', error: err });
    }
};

exports.getClaimById = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await Claim.getById(id);
        if (!result) {
            return res.status(404).json({ message: 'Claim not found' });
        }
        res.status(200).json(result);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching claim by ID', error: err });
    }
};

exports.getClaimByStaffId = async (req, res) => {
    try {
        const { staffId } = req.params;
        const results = await Claim.getByStaffId(staffId);
        res.status(200).json(results);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching claims by staff ID', error: err });
    }
};


exports.updateClaim = async (req, res) => {
    try {
        const { id } = req.params;
        const updated = await Claim.update(id, req.body);
        if (!updated) {
            return res.status(404).json({ message: 'Claim not found' });
        }
        res.status(200).json({ message: 'Claim updated successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error updating claim', error: err });
    }
};

exports.deleteClaim = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await Claim.delete(id);
        if (!deleted) {
            return res.status(404).json({ message: 'Claim not found' });
        }
        res.status(204).json({ message: 'Claim deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error deleting claim', error: err });
    }
};
