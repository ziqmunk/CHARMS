const BookingModel = require('../models/booking.model');


// create new booking
exports.createBooking = (req, res)=> {
    // console.log('req data', req.body);
    const bookingReqData = new BookingModel(req.body);
    console.log('bookingReqData', bookingReqData);
    // check null
    if(req.body.constructor === Object && Object(req.body).length === 0) {
        res.send(400).send({success: false, message: 'Please fill all fields'});
    } else {
        console.log('valid data');
        BookingModel.createBooking(bookingReqData, (err, user)=>{
            if(err)
                res.send(err);
                res.json({status: true, message: 'Booking created'});
            
        });
    }
}
exports.addGroupBooking = (req, res)=> {
    // console.log('req data', req.body);
    const bookingReqData = new BookingModel(req.body);
    console.log('bookingReqData', bookingReqData);
    // check null
    if(req.body.constructor === Object && Object(req.body).length === 0) {
        res.send(400).send({success: false, message: 'Please fill all fields'});
    } else {
        console.log('valid data');
        BookingModel.addGroupBooking(bookingReqData, (err, user)=>{
            if(err)
                res.send(err);
                res.json({status: true, message: 'Group members added'});
            
        });
    }
}

exports.fetchBooking = (req, res)=> {
    BookingModel.fetchBooking((err, event) => {
        console.log('We are here');
        if(err)
        res.send(err);
        console.log('Events', event);
        res.send(event);
    });
};

exports.fetchGroupBooking = (req, res)=> {
    BookingModel.fetchGroupBooking(req.params.confirmnum, (err, event) => {
        console.log('We are here');
        if(err)
        res.send(err);
        console.log('Events', event);
        res.send(event);
    });
};