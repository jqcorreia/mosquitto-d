import std.stdio;
import std.string;
import std.range;
import std.conv;
import std.json;
import core.thread;

import std.exception;

import mosquitto;

extern(C) void connect_callback(mosquitto *mosqCallback, void *userdata, int result) {
    writeln("Connected !");
    
}

extern(C) void message_callback(mosquitto *mosqCallback, void *userdata, const  mosquitto_message *message) {
    string foo =  to!string(cast(char*)message.payload);
    writeln(foo);
    JSONValue val = parseJSON(foo);    
}

void parse(string msg) {
    parseJSON(msg);
}

void main()
{
    auto j = parseJSON(`{ "id": "0C:82:68:F8:F3:F2", "ts": 1394725092, "data": [ { "m": "c:82:68:f9:1a:dc", "c": 2, "r": [ 54, 55 ] }, { "m": "c:82:68:f8:f5:7c", "c": 2, "r": [ 59, 60 ] }, { "m": "b4:62:93:d:bc:10", "c": 2, "r": [ 85, 84 ] }, { "m": "c:82:68:f8:f2:40", "c": 2, "r": [ 43, 42 ] }, { "m": "c:82:68:f8:f6:8e", "c": 2, "r": [ 55, 55 ] }, { "m": "c:82:68:f8:f2:46", "c": 2, "r": [ 63, 62 ] }, { "m": "c:82:68:f8:f4:9e", "c": 2, "r": [ 55, 56 ] } ] }`);

    writeln(j);
    mosquitto_lib_init();

    mosquitto *mosq = mosquitto_new("foo", true, null);
    mosquitto_username_pw_set(mosq, "mqttauth", "1234");

    mosquitto_connect_callback_set(mosq, &connect_callback);
    mosquitto_message_callback_set(mosq, &message_callback);

    if(mosquitto_connect(mosq, "5.9.153.213", 1883, 30) != mosq_err_t.MOSQ_ERR_SUCCESS) {
	writeln("error");
    }
    
    mosquitto_subscribe(mosq, null, "tri_data/szmaia/+".toStringz, 1);
    mosquitto_loop_start(mosq);
    
    while(true) {
	Thread.sleep(dur!("msecs")(500));
    }
}
