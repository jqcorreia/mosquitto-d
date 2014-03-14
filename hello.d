

import std.stdio;
import mosquitto;


class MosquittoClient: Mosquitto
{
    override void onConnect(int rc)
    {
        writefln("[override] rc = %d", rc);
    }
}


void main()
{
    auto mqtt = new MosquittoClient();
    mqtt.start();
}

