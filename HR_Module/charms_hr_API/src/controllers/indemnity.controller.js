const IndemnityModel = require('../models/indemnity.model');


// create new indemnity
exports.createIndemnity = (req, res)=> {
    // console.log('req data', req.body);
    const indemnityReqData = new IndemnityModel(req.body);
    console.log('indemnityReqData', indemnityReqData);
    // check null
    if(req.body.constructor === Object && Object(req.body).length === 0) {
        res.send(400).send({success: false, message: 'Please fill all fields'});
    } else {
        console.log('valid data');
        IndemnityModel.createIndemnity(indemnityReqData, (err, indemnity)=>{
            if(err)
                res.send(err);
                res.json({status: true, message: 'Program created'});
            
        });
    }
};

exports.fetchIndemnitybyStatus = (req, res)=> {
    IndemnityModel.fetchIndemnitybyStatus(req.params.status, (err, indemnitylist) => {
        console.log('We are here');
        if(err)
        res.send(err);
        console.log('indemnity', indemnitylist);
        res.send(indemnitylist);
    });
};
exports.fetchIndemnitybyType = (req, res)=> {
    IndemnityModel.fetchIndemnitybyType(req.params.type, (err, indemnitylist) => {
        console.log('We are here');
        if(err)
        res.send(err);
        console.log('indemnity', indemnitylist);
        res.send(indemnitylist);
    });
};