
module mosquitto;

import std.conv;
import std.stdio;
import std.string;
import core.thread;
import std.json;
import std.exception;


extern(C)
void onConnectWrapper(mosquitto *mosq, void *userdata, int rc)
{
    writeln("- Connected.");
    Mosquitto mqtt = cast(Mosquitto)userdata;
    mqtt.onConnect(rc);
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


class Mosquitto
{

    this()
    {
        
        status = mosquitto_lib_init();
        enforce(status == mosq_err_t.MOSQ_ERR_SUCCESS);

        mosq = mosquitto_new("foo", true, cast(void*)this);
        enforce(mosq !is null);

        status = mosquitto_username_pw_set(mosq, "mqttauth", "1234");
        enforce(status == mosq_err_t.MOSQ_ERR_SUCCESS);

        mosquitto_connect_callback_set(mosq, &onConnectWrapper);
        mosquitto_message_callback_set(mosq, &onMessage);

        status = mosquitto_connect(mosq, "5.9.153.213", 1883, 30);
        enforce(status == mosq_err_t.MOSQ_ERR_SUCCESS);
        
        mosquitto_subscribe(mosq, null, "tri_data/szmaia/+".toStringz, 1);

    }


    void start()
    {
        int shouldRun = true;
        while(shouldRun)
        {
            status = mosquitto_loop(mosq, 1, 50);
            if (shouldRun && status)
            {
                writeln("- Reconnecting...");
                Thread.sleep(dur!"seconds"(5));
                mosquitto_reconnect(mosq);
            }	
        }
    }


    void onConnect(int rc)
    {
        this._onConnect(rc);
    }

    void onConnect(ConnectCallbackT callback)
    {
        this._onConnect = callback;
    }


private:
    mosquitto *mosq;
    int status;

    alias void function(int) ConnectCallbackT;
    ConnectCallbackT _onConnect;

    /* alias void function(mosquitto*, void*, const(mosquitto_message*)) MessageCallbackT; */
    /* MessageCallbackT _onMessage; */
}



extern (C):

    enum mosq_err_t {
        MOSQ_ERR_CONN_PENDING = -1,
        MOSQ_ERR_SUCCESS = 0,
        MOSQ_ERR_NOMEM = 1,
        MOSQ_ERR_PROTOCOL = 2,
        MOSQ_ERR_INVAL = 3,
        MOSQ_ERR_NO_CONN = 4,
        MOSQ_ERR_CONN_REFUSED = 5,
        MOSQ_ERR_NOT_FOUND = 6,
        MOSQ_ERR_CONN_LOST = 7,
        MOSQ_ERR_TLS = 8,
        MOSQ_ERR_PAYLOAD_SIZE = 9,
        MOSQ_ERR_NOT_SUPPORTED = 10,
        MOSQ_ERR_AUTH = 11,
        MOSQ_ERR_ACL_DENIED = 12,
        MOSQ_ERR_UNKNOWN = 13,
        MOSQ_ERR_ERRNO = 14,
        MOSQ_ERR_EAI = 15
    };

struct mosquitto_message{
    int mid;
    char *topic;
    void *payload;
    int payloadlen;
    int qos;
    bool retain;
};

struct mosquitto;

alias psm = mosquitto*;
alias psmm = mosquitto_message*;
alias ppsmm = mosquitto_message**;

int mosquitto_lib_version(int *major, int *minor, int *revision);

int mosquitto_lib_init();

int mosquitto_lib_cleanup();

psm mosquitto_new(const char *id, bool clean_session, void *obj);

void mosquitto_destroy(psm);

int mosquitto_reinitialise(psm, const char *id, bool clean_session, void *obj);

int mosquitto_will_set(psm, const char *topic, int payloadlen, const void *payload, int qos, bool retain);

int mosquitto_will_clear(psm);

int mosquitto_username_pw_set(psm, const char *username, const char *password);

int mosquitto_connect(psm, const char *host, int port, int keepalive);

int mosquitto_connect_bind(psm, const char *host, int port, int keepalive, const char *bind_address);

int mosquitto_connect_async(psm, const char *host, int port, int keepalive);

int mosquitto_connect_bind_async(psm, const char *host, int port, int keepalive, const char *bind_address);

int mosquitto_reconnect(psm);

int mosquitto_reconnect_async(psm);

int mosquitto_disconnect(psm);

int mosquitto_publish(psm, int *mid, const char *topic, int payloadlen, const void *payload, int qos, bool retain);

int mosquitto_subscribe(psm, int *mid, const char *sub, int qos);

int mosquitto_unsubscribe(psm, int *mid, const char *sub);

int mosquitto_message_copy(psmm *dst, const psmm  *src);

void mosquitto_message_free(ppsmm **message);

int mosquitto_loop(psm, int timeout, int max_packets);

int mosquitto_loop_forever(psm, int timeout, int max_packets);

int mosquitto_loop_start(psm);

int mosquitto_loop_stop(psm, bool force);

int mosquitto_socket(psm);

int mosquitto_loop_read(psm, int max_packets);

int mosquitto_loop_write(psm, int max_packets);

int mosquitto_loop_misc(psm);

bool mosquitto_want_write(psm);

int mosquitto_tls_set(psm,
        const char *cafile, const char *capath,
        const char *certfile, const char *keyfile,
        int function (char *buf, int size, int rwflag, void *userdata) pw_callback);

int mosquitto_tls_insecure_set(psm, bool value);

int mosquitto_tls_opts_set(psm, int cert_reqs, const char *tls_version, const char *ciphers);

int mosquitto_tls_psk_set(psm, const char *psk, const char *identity, const char *ciphers);

void mosquitto_connect_callback_set(psm, void function(psm, void *, int) on_connect);

void mosquitto_disconnect_callback_set(psm, void function (psm, void *, int) on_disconnect);

void mosquitto_publish_callback_set(psm, void function (psm, void *, int) on_publish);

void mosquitto_message_callback_set(psm, void function (psm, void *, const psmm) on_message);

void mosquitto_subscribe_callback_set(psm, void function (psm, void *, int, int, const int *) on_subscribe);

void mosquitto_unsubscribe_callback_set(psm, void function (psm, void *, int) on_unsubscribe);

void mosquitto_log_callback_set(psm, void function (psm, void *, int, const char *) on_log);

int mosquitto_reconnect_delay_set(psm, uint reconnect_delay, uint reconnect_delay_max, bool reconnect_exponential_backoff);

int mosquitto_max_inflight_messages_set(psm, uint max_inflight_messages);

void mosquitto_message_retry_set(psm, uint message_retry);

void mosquitto_user_data_set(psm, void *obj);

const char *mosquitto_strerror(int mosq_errno);

const char *mosquitto_connack_string(int connack_code);

int mosquitto_sub_topic_tokenise(const char *subtopic, char ***topics, int *count);

int mosquitto_sub_topic_tokens_free(char ***topics, int count);
int mosquitto_topic_matches_sub(const char *sub, const char *topic, bool *result);



