const mqtt = require('mqtt')
const fs = require("fs");

const client  = mqtt.connect('mqtt://localhost');

client.on('connect', () => {
  client.subscribe('test/test1');
});
 
client.on('message', (topic, payload) => {
  fs.writeFileSync("test.jpg", payload.toString(), {encoding: 'base64'});
  client.end();
})