var express = require('express');
var app = express();
var imageRoot = process.argv[2];

app.use(express.static(imageRoot));

app.get('/', function (req, res) {
  	var inum = Math.floor((Math.random() * 50) + 1);
  	res.redirect('/out' + inum + '.png');
});

var server = app.listen(10800, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app listening at http://%s:%s', host, port);
});
