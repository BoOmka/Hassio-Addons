# Snips.ai Base(Hass.io Addon)
![armhf image pulls](https://img.shields.io/docker/pulls/poeschl/hassio-snipsai-armhf?label=docker%20pulls%20%28armhf%29)
![armv7 image pulls](https://img.shields.io/docker/pulls/poeschl/hassio-snipsai-armv7?label=docker%20pulls%20%28armv7%29)
![aarch64 image pulls](https://img.shields.io/docker/pulls/poeschl/hassio-snipsai-aarch64?label=docker%20pulls%20%28aarch64%29)
![amd64 image pulls](https://img.shields.io/docker/pulls/poeschl/hassio-snipsai-amd64?label=docker%20pulls%20%28amd64%29)

A own version of the Snips.ai Voice Control platform addon. Its intended to act only as base station without a mic and gets the input via satelites.

## Requirements

To use this Addon a MQTT Broker is required. The easy solution for that is the [Mosquitto broker addon](https://www.home-assistant.io/addons/mosquitto/).

## Configuration

```
{
    "mqtt": {
        "host": "localhost",
        "port": 1883
        "user": "user",
        "pass": "password",
    },
    "assistant": "mySnipsAssistant.zip"
}
```

### Skill configurations

The `config.ini` files of your skills can be found in the `/share/snips-skills` folder.
They will be copied there after building and will be copied back on restart.

### Satelite setup

To make the setup of satelites a little easier a setup script for an Raspberry 2/3/Zero with a ReSpeaker 2-Mic PiHat is included in the repository.
It gives a little kick-start on execution.
