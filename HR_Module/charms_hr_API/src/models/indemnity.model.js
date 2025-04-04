var dbConn = require('../../config/db.config.js');
const bcrypt = require('bcryptjs');

var Indemnity = function (indemnity) {
    this.id = indemnity.id;
    this.indemitem = indemnity.indemitem;
    this.type = indemnity.type;
    this.status = indemnity.status;
    this.createdby = indemnity.createdby;
}

// create indem
Indemnity.createIndemnity = (indemnityReqData, result) => {
    dbConn.query('INSERT INTO indemnity(indemitem, type, createdby) VALUES (?,?,?)', [indemnityReqData.indemitem, indemnityReqData.type, indemnityReqData.createdby], (err, res) => {
        if (err) {
            console.log('Error inserting data');
            result(null, err);
        } else {
            result(null, { message: 'New indemnity created' });

        }
    });
};

Indemnity.fetchIndemnitybyStatus = (status, result) => {
    dbConn.query('SELECT * FROM indemnity WHERE status=?', status, (err, res) => {
        if (err) {
            console.log('Error inserting data');
            result(null, err);
        } else {
            result(null, res);

        }
    });
}
Indemnity.fetchIndemnitybyType = (status, result) => {
    dbConn.query('SELECT * FROM indemnity WHERE type=? AND status = 1', status, (err, res) => {
        if (err) {
            console.log('Error inserting data');
            result(null, err);
        } else {
            result(null, res);

        }
    });
}

module.exports = Indemnity;