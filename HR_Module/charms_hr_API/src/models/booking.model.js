var dbConn = require('../../config/db.config.js');

var Booking = function (bookingdata) {
    this.id = bookingdata.id;
    this.userid = bookingdata.userid;
    this.pax = bookingdata.pax;
    this.eventid = bookingdata.eventid;
    this.isgroup = bookingdata.isgroup;
    this.name = bookingdata.name;
    this.idnum = bookingdata.idnum;
    this.email = bookingdata.email;
    this.confirmnum = bookingdata.confirmnum;
}

// create program
Booking.createBooking = (bookingReqData, result) => {
    dbConn.query('INSERT INTO bookingdata(userid, pax, eventid, confirmationno, isgroup) VALUES (?,?,?,?,?)', [bookingReqData.userid, bookingReqData.pax, bookingReqData.eventid, bookingReqData.confirmnum, bookingReqData.isgroup], (err, res) => {
        if (err) {
            console.log('Error inserting data');
            result(null, err);
        } else {
            // console.log('New user created');
            result(null, { message: 'New booking created' });

        }
    });
}
Booking.addGroupBooking = (bookingReqData, result) => {
    dbConn.query('INSERT INTO bookinggroup(name, idnum, email, confirmationno) VALUES (?,?,?,?)', [bookingReqData.name, bookingReqData.idnum, bookingReqData.email, bookingReqData.confirmnum], (err, res) => {
        if (err) {
            console.log('Error inserting data');
            result(null, err);
        } else {
            // console.log('New user created');
            result(null, { message: 'Group members added' });

        }
    });
}

Booking.fetchBooking = (result) => {
    dbConn.query('SELECT * FROM bookingdata', (err, res) => {
        if (err) {
            console.log('Error while fetching booking data', err);
            result(null, err);
        } else {
            console.log('Booking data acquired successfully');
            result(null, res);
        }
    });
};

Booking.fetchGroupBooking = (confirmnum, result) => {
    dbConn.query('SELECT * FROM bookinggroup WHERE confirmationno = ?', confirmnum, (err, res) => {
        if (err) {
            console.log('Error while fetching group booking', err);
            result(null, err);
        } else {
            console.log('Group booking data acquired successfully');
            result(null, res);
        }
    });
};


module.exports = Booking;