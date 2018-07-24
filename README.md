# Smart Gardening Team 2 (pflanzen2)
## Massimo Krause, Lukas Römer, Dorian Grosch

Präsentation: https://userpage.fu-berlin.de/doriangrosch/Pr%C3%A4si.pdf

Präsentation Release Candidate: https://userpage.fu-berlin.de/doriangrosch/Pr%C3%A4sentation_Release_Candidate.pdf

Abschlusspräsentation: http://doriangrosch.userpage.fu-berlin.de/Abschlusspr%C3%A4sentation.pdf

### Hardware

* **4 x** Atmel SAM R21 Xplained Pro 
* **8 x** Feuchtigkeitssensor
* **4 x** Temperatursensor
* **1 x** Raspberry Pi als Gateway
* **1 x** 802.15.4-Dongle für RasPi

Optional: 

* **4 x** pH-Wert-Sensor
* **4 x** Helligkeitssensor
* **4 x** Batterie-Modul

### Interne Kooperation

Github: https://github.com/fu-ilab-swp18/pflanzen2

Trello: https://trello.com/b/Fg7hORTF/pflanzen2

ShareLatex: https://de.sharelatex.com/9872211863bkkbstwzxffy

### OpenSenseMap

OpenSenseMap Link: https://opensensemap.org/explore/5b14eda64cd32e00195ec2c8

Test MQTT Server: broker.hivemq.com:1883
Topic(s): SWP_IK_PFL2/data/[boxID1,boxID2]/[sensorID1,sensorID2,..]
Message Example: [{"sensor":"5b14eda64cd32e00195ec2cc","value":"45.0"}]

### DHT Sensor Setup

Den folgenden Befehl ausführen im Ordner atmel-code/ ausführen:

```cp ../RIOT/drivers/dht/include/dht_params.h ../RIOT/drivers/include/```

Sonst kompiliert es nicht.

### 802.15.4 6LoWPAN communication protocol proposal

- YAML as markup language with the following structure:
    ```yaml
        boxID:  sepp
        data:
            -   type:   1
                value:  54.3
            -   type:   2
                value:  36
            -   type:   3
                value:  23.4
    ```

## Wiring

### DFR ground humidity sensor:
* Gold      -> GND
* Schwarz   -> VCC
* Weiß      -> PA06

### DHT11 temperature & air humidity sensor:
* Data      -> PA07

![wiring](doc/wiring.jpg)

## Sensors IDs

| Sensor | ID |
| --- | --- |
| Temp | 1 |
| Air hum | 2 |
| Ground hum | 3 |

## IP Adresses

| Device | Adddress |
| --- | --- |
| RasPi | fe80::1ac0:ffee:1ac0:ffee |
