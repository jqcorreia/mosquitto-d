
import std.stdio;
import std.string;
import std.range;
import std.conv;
import std.json;
import core.thread;
import core.sys.posix.signal;
import std.exception;
import std.c.stdlib;

import mosquitto;


extern(C)
void onConnect(mosquitto *mosq, void *userdata, int result)
{
    writeln("- Connected.");
}

extern(C)
void onMessage(mosquitto *mosq, void *userdata, const(mosquitto_message*) message)
{
    processMessage(to!string(cast(char*)message.payload));
}


void processMessage(string message)
{
    JSONValue value = parseJSON(message);
    writeln(value);
}


extern(C) void mybye(int value){
    writeln("oh... Bye then!");
    exit(0);    
}


void main()
{
    int status;
    
    status = mosquitto_lib_init();
    enforce(status == mosq_err_t.MOSQ_ERR_SUCCESS);

    mosquitto *mosq = mosquitto_new("foo", true, null);
    enforce(mosq !is null);

    status = mosquitto_username_pw_set(mosq, "mqttauth", "1234");
    enforce(status == mosq_err_t.MOSQ_ERR_SUCCESS);

    mosquitto_connect_callback_set(mosq, &onConnect);
    mosquitto_message_callback_set(mosq, &onMessage);

    status = mosquitto_connect(mosq, "5.9.153.213", 1883, 30);
    enforce(status == mosq_err_t.MOSQ_ERR_SUCCESS);
    
    mosquitto_subscribe(mosq, null, "tri_data/szmaia/+".toStringz, 1);


    sigset(SIGINT, &mybye);

    int shouldRun = true;
    while(shouldRun)
    {
        status = mosquitto_loop(mosq, 1, 50);
        if (shouldRun && status)
        {
            writeln("- Reconnecting...");
            Thread.sleep(dur!("seconds")(5));
            mosquitto_reconnect(mosq);
        }	
    }
    mosquitto_destroy(mosq);
    mosquitto_lib_cleanup();
}

