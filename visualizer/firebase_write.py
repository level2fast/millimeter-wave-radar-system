# Import Firebase REST API library
import firebase

# Firebase configuration
config = {
   "apiKey": "apiKey",
   "authDomain": "projectId.firebaseapp.com",
   "databaseURL": "https://radarvision-default-rtdb.firebaseio.com/",
   "projectId": "projectId",
   "storageBucket": "projectId.appspot.com",
   "messagingSenderId": "messagingSenderId",
   "appId": "appId"
}

# Instantiates a Firebase app
app = firebase.initialize_app(config)


# # Firebase Authentication
# auth = app.auth()

# # Create new user and sign in
# auth.create_user_with_email_and_password(email, password)
# user = auth.sign_in_with_email_and_password(email, password)

import sys
# Firebase Realtime Database
db = app.database()
x = sys.argv[1]
y = sys.argv[2]
z = sys.argv[3]
# Data to save in database
data = {"x": x, "y": y, "z": z}

def init():
  # Store data to Firebase Database
  db.set("SensorData/")
  db.child("SensorData").set("x")
  db.child("SensorData").set("y")
  db.child("SensorData").set("z")

def set_sensor_values():
  db.child("SensorData").child("x").set(x)
  db.child("SensorData").child("y").set(y)
  db.child("SensorData").child("z").set(z)

if __name__ == "__main__":
    # init()
    set_sensor_values()





