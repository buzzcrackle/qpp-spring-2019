const express = require('express');
const assert = require('assert');
const mongo = require('mongodb').MongoClient;
const url = 'mongodb://localhost:27017';

const client = new MongoClient(mongoUrl);

var app = express();

var bodyParser = require('body-parser')
var app = express()

var bodyParser = require('body-parser'); 
app.use(bodyParser.json()); 
app.use(bodyParser.urlencoded({ extended: true }));

mongo.connect(url, (err, client) => {
	if (err) {
		console.error(err);
		return;
	}

	const db = client.db('qpp');

	const collection = db.collection('paths');

	var botAvailable = true;
	var currentPath = [];
	app.get('/', function (req, res) {
		res.send('Hello World from GCE!');
	});
	app.get('/bot-free', function (req, res) {
		res.json({ free: botAvailable });
		res.status(200);
		res.end();
	});
	app.get('/bot-instructions', function (req, res) {
		res.json({path: currentPath});
		res.end();
	});
	app.get('/bot-called', function (req, res) {
		res.json({isCalled: !botAvailable});
		res.end();
	});
	app.get('/bot-finished', function (req, res) {
		botAvailable = true;
	});
	app.post('/bot-instructions', function (req, res) {
		var name = "";
		var path = [];
		try {
			name = req.body.name;
			path = req.body.path;
			res.sendStatus(200);
			currentPath = path;
			botAvailable = false;
			console.log(req.body);
		} catch (e) {
			res.sendStatus(400);
		}
	});
	app.get('/get-all', function (req, res) {
		console.log("get-all");
		collection.find({}).toArray((err, arr) => {
			if (err) throw err;
			res.json({paths: allPaths});
			res.end();
		});
	});
	app.post('/edit-path', function (req, res) {
		var name = "";
		var path = [];
		try {
			name = req.body.name;
			path = req.body.path;
			res.sendStatus(200);
			var myquery = {name: name};
			var myobj = {$set: {name: name, path: path}};
			collection.updateOne(myquery, myobj, (err, item) => {
				if (err) throw err;
			});
		} catch (e) {
			res.sendStatus(400);
		}
		console.log(req.body);
	});
	app.post('/add-path', function (req, res) {
		var name = "";
		var path = [];
		try {
			name = req.body.name;
			path = req.body.path;
			res.sendStatus(200);
			var myobj = {name: name, path: path};
			collection.insertOne(myobj, (err, result) => {
				if (err) throw err;
			});
		} catch (e) {
			res.sendStatus(400);
		}
		console.log(req.body);
	});
	app.listen(3000, function () {
		console.log('Example app listening on port 3000!');
	});

	client.close();

});
