var dbConn = require('../../config/db.config.js');

var Event = function (newprogram) {
    this.id = newprogram.id;
    this.title = newprogram.title;
    this.startdate = newprogram.startdate;
    this.enddate = newprogram.enddate;
    this.createdby = newprogram.createdby;
    this.approve1 = newprogram.approve1;
    this.approve2 = newprogram.approve2;
    this.eventtype = newprogram.eventtype;
    this.userid = newprogram.userid;
}

// create program
Event.createEvent = (eventReqData, result) => {
    dbConn.query('INSERT INTO event(title, startdate, enddate, createdby, eventtype) VALUES (?,?,?,?,?)', [eventReqData.title, eventReqData.startdate, eventReqData.enddate, eventReqData.createdby, eventReqData.eventtype], (err, res) => {
        if (err) {
            console.log('Error inserting data');
            result(null, err);
        } else {
            // console.log('New user created');
            result(null, { message: 'New event created' });

        }
    });
}

Event.fetchEventGeneral = (result) => {
    dbConn.query('SELECT * FROM event WHERE startdate > CURRENT_DATE OR startdate2 > CURRENT_DATE', (err, res) => {
        if (err) {
            console.log('Error while fetching events', err);
            result(null, err);
        } else {
            console.log('Events data acquired successfully');
            result(null, res);
        }
    });
};
Event.fetchEventAdmin = (result) => {
    dbConn.query('SELECT * FROM event', (err, res) => {
        if (err) {
            console.log('Error while fetching events', err);
            result(null, err);
        } else {
            console.log('Events data acquired successfully');
            result(null, res);
        }
    });
};

Event.fetchEventVolCount = (eventid, result) => {
    dbConn.query('SELECT SUM(pax) AS slotcount FROM bookingdata WHERE eventid = ?', eventid, (err, res) => {
        if (err) {
            console.log('Error while fetching events', err);
            result(null, err);
        } else {
            console.log('Events data acquired successfully');
            result(null, res);
        }
    });
};

module.exports = Event;