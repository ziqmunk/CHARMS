const mysql = require('mysql');

// mysql connection
const dbConn = mysql.createConnection({
    port: process.env.DB_PORT,
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.MYSQL_DB,
    dateStrings: true
});

dbConn.connect(function(error){
    if(error) throw error;
    console.log('Database Connection success');
});

module.exports = dbConn;