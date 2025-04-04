const express = require('express');
const bodyParser = require('body-parser');
require('dotenv').config();

// create express app
const app = express();

// set the server port
const port = process.env.PORT || 5002;

// set limit for JSON payloads
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

// parse request data content type app/x-www-form-urlencoded
app.use(bodyParser.urlencoded({extended: false}));

// parse request data content type app/json
app.use(bodyParser.json());

// parse JSON from requests
app.use(express.json());

// define server routes
app.get('/', (req, res) =>{
    res.send('Greetings from the server!');
});

// user route
const userRoute = require('./src/routes/user.route');
app.use('/cms/api/v1/user', userRoute);

// Staff routes
const staffRoute = require('./src/routes/staff.route');
app.use('/cms/api/v1/staff', staffRoute);

// event route
const eventRoute = require('./src/routes/event.route');
app.use('/cms/api/v1/event', eventRoute);

// booking route
const bookingRoute = require('./src/routes/booking.route');
app.use('/cms/api/v1/booking', bookingRoute);

// indemnity route
const indemnityRoute = require('./src/routes/indemnity.route');
app.use('/cms/api/v1/indemnity', indemnityRoute);

// Schedule routes
const scheduleRoute = require('./src/routes/schedule.route');
app.use('/cms/api/v1/schedule', scheduleRoute);

// Attendance routes
const attendanceRoute = require('./src/routes/attendance.route')
app.use('/cms/api/v1/attendance', attendanceRoute);

// Leave routes
const leaveRoute = require('./src/routes/leave.route.js');
app.use('/cms/api/v1/leave', leaveRoute);

// Payment routes
const paymentRoute = require('./src/routes/payment.route');
app.use('/cms/api/v1/payment', paymentRoute);

// Claim routes
const claimRoute = require('./src/routes/claim.route');
app.use('/cms/api/v1/claim', claimRoute);

// listen to port
app.listen(port, ()=> {
    console.log(`Express server is running at port ${port}`);
});