const EventModel = require('../models/event.model');


// create new user
exports.createEvent = (req, res)=> {
    // console.log('req data', req.body);
    const eventReqModel = new EventModel(req.body);
    console.log('eventReqModel', eventReqModel);
    // check null
    if(req.body.constructor === Object && Object(req.body).length === 0) {
        res.send(400).send({success: false, message: 'Please fill all fields'});
    } else {
        console.log('valid data');
        EventModel.createEvent(eventReqModel, (err, user)=>{
            if(err)
                res.send(err);
                res.json({status: true, message: 'Program created'});
            
        });
    }
}

exports.fetchEventGeneral = (req, res)=> {
    EventModel.fetchEventGeneral((err, event) => {
        console.log('We are here');
        if(err)
        res.send(err);
        console.log('Events', event);
        res.send(event);
    });
};
exports.fetchEventAdmin = (req, res)=> {
    EventModel.fetchEventAdmin((err, event) => {
        console.log('We are here');
        if(err)
        res.send(err);
    console.log('Events', event);
    res.send(event);
});
};
exports.fetchEventVolCount = (req, res)=> {
    EventModel.fetchEventVolCount(req.params.eventid, (err, event) => {
        console.log('We are here');
        if(err)
        res.send(err);
    console.log('Event count', event);
    res.send(event);
});
};
