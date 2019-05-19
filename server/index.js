const express = require('express');
const assert = require('assert');
const mongoUrl = "mongodb://localhost:27017/";
const MongoClient = require('mongodb').MongoClient

const client = new MongoClient(mongoUrl);

var app = express();

var bodyParser = require('body-parser')
var app = express()

var bodyParser = require('body-parser'); 
app.use(bodyParser.json()); 
app.use(bodyParser.urlencoded({ extended: true }));

client.connect(function(err) {
	
	assert.equal(null, err);
	console.log("Connected to mongo successfully");

	const db = client.db("qpp");


	app.get('/', function (req, res) {
   		res.send('Hello World from GCE!'); 
	});

	app.post('/add-path', function (req, res) {
	
		console.log(req.body);
	});

	app.listen(3000, function () {
   		console.log('Example app listening on port 3000!');
	});

	client.close();
})

