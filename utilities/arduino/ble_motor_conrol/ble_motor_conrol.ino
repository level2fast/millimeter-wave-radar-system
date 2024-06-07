/*
  BLE Stepper Motor control

  This example creates a Bluetooth® Low Energy peripheral with service that contains a
  characteristic to control an LED and a stepper motor

  The circuit:
  - Arduino MKR WiFi 1010, Arduino Uno WiFi Rev2 board, Arduino Nano 33 IoT,
    Arduino Nano 33 BLE, or Arduino Nano 33 BLE Sense board.
  - Button connected to pin 4
  - HIGH output connected to pin 2 that controls direction of motor 
  - HIGH output connected to pin 3 that controls pull of motor

  You can use a generic Bluetooth® Low Energy central app, like LightBlue (iOS and Android) or
  nRF Connect (Android), to interact with the services and characteristics
  created in this sketch.
*/

#include <ArduinoBLE.h>

const int ledPin = LED_BUILTIN; // set ledPin to on-board LED
#define directionPin 2
#define stepPin 3
#define stepsPerRevolution 800

BLEService motorControlService("19B10010-E8F2-537E-4F6C-D104768A1214"); // create service

// create switch characteristic and allow remote device to read and write
BLEByteCharacteristic motorCharacteristic("19B10011-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);
BLEShortCharacteristic motorSpeedCharacteristic("19B10011-E8F2-537E-4F6C-D104768A1213", BLERead | BLEWrite);



void setup() {
  Serial.begin(9600);
  while (!Serial);

  pinMode(ledPin, OUTPUT); // use the LED as an output
  // put your setup code here, to run once:
  pinMode(directionPin, OUTPUT);
  pinMode(stepPin, OUTPUT);
 
  Serial.println("Pin setup complete...");
  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting Bluetooth® Low Energy module failed!");

    while (1);
  }

  // set the local name peripheral advertises
  BLE.setLocalName("MotorControl");
  // set the UUID for the service this peripheral advertises:
  BLE.setAdvertisedService(motorControlService);

  // add the characteristics to the service
  motorControlService.addCharacteristic(motorCharacteristic);
  motorControlService.addCharacteristic(motorSpeedCharacteristic);
  
  // add the service
  BLE.addService(motorControlService);

  motorCharacteristic.writeValue(0);
  motorSpeedCharacteristic.writeValue(80);

  // start advertising
  BLE.advertise();

  Serial.println("Bluetooth® device active, waiting for connections...");
}

static unsigned short motor_speed = 5000;
static bool forward = true;
void motor_on()
{
    // put your main code here, to run repeatedly:
  for (int i =0 ; i < stepsPerRevolution; i++)
  {
    if(forward)
    {
      digitalWrite(directionPin, HIGH);
    }
    else // rotate backwards
    {
      digitalWrite(directionPin, LOW);
    }
    digitalWrite(stepPin,HIGH);
    // use delay to control the speed of the motor
    delayMicroseconds(motor_speed);
    digitalWrite(stepPin, LOW);
    // use delay to control the speed of the motor
    delayMicroseconds(motor_speed);
  }
  //Serial.println("updated speed:"+ String(motor_speed));
}
static bool turn_motor = false;
void loop() 
{
  // poll for Bluetooth® Low Energy events
  BLE.poll();

  if(motorSpeedCharacteristic.written())
  {
    short speed_characteristic = motorSpeedCharacteristic.value();

    forward = speed_characteristic > 0;

    motor_speed = speed_characteristic < 0 ? -speed_characteristic : speed_characteristic;
  }

  if (motorCharacteristic.written() || turn_motor == true) 
  {
    // update LED, either central has written to characteristic or button state has changed
    if (motorCharacteristic.value()) {
      //Serial.println("motor on");
      digitalWrite(ledPin, HIGH);
      // our pin is activated by the rising edge so we have to set 
      // it to low and then back to high to create a step
      motor_on();
      turn_motor = true;
    } else {
      //Serial.println("motor off");
      digitalWrite(ledPin, LOW);
      turn_motor = false;
    }
  }
}
