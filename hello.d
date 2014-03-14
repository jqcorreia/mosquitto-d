
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


class MosquittoClient : Mosquitto
{
    this()
    {
        super("mqtt-demo");
        connect("5.9.153.213", 1883, 30);
    }

    override void onConnect(int rc)
    {
        
    }

/*     override void onMessage(int rc) */
/*     { */

/*     } */

/*     override void onSubscribe(int rc) */
/*     { */
        
/*     } */
}



int main()
{
    auto mqtt = new MosquittoClient();
    
    writeln("Exiting...");
    return 0;
}

