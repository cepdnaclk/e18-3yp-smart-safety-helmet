import { db } from "../Auth/firebase.js";
import admin from "firebase-admin";
import { v4 as uuid } from "uuid";

let authorized = false;

let connectionStat = false;

// Create the collection
const userDB = db.collection("workers");
const supervisorDB = db.collection("supervisors");

// Function to get given user details
export const getUser = async (req, res) => {
  try {
    const response = await userDB.doc().get();
    return res.send(response.data());
  } catch (err) {
    return res.send(err.message);
  }
};

// Function to get all the user details in the database
// export const getAllWorkers = async

export const addUser = async (req, res) => {
  try {
    console.log(req.body);

    let authID;

    console.log("before authentication process");

    // Creating user in user authentication
    admin
      .auth()
      .createUser({
        email: req.body.email,
        password: req.body.password,
      })
      .then(async (userRecord) => {
        authID = userRecord.uid;
        console.log(`Successfully created new user: ${userRecord.uid}`);
        // Creating user in fiirestore
        const id = req.body.username;
        const user = {
          name: req.body.name,
          post: req.body.post,
          email: req.body.email,
          telNo: req.body.telNo,
          bloodGroup: req.body.bloodGroup,
          UserID: authID,
        };
        console.log(user);

        const response = await userDB.doc(id).create(user);
        console.log("User Created in fb firestore", user);
        return res.status(200).send(response);
      })
      .catch((error) => {
        return res.status(400).send(`Error creating new user: ${error}`);
      });

    console.log("authentication process completed");
  } catch (err) {
    res.status(404).send(err.message);
  }
};

// Function to get sensor data of one user
/**@ToDo
 * Way to retrieve user id from logged cookie
 * Way to give user id to every user
 */
export const getSensorData = (req, res) => {
  const dataSet = [];

  userDB
    .get()
    .then((snapshot) => {
      if (snapshot.empty) {
        authorized = false;
        return res.status(404).send("There is no such user");
      } else {
        snapshot.forEach((doc) => {
          const name = doc.get("name");
          const tempurature = doc.get("Tempurature");
          const vibration = doc.get("Vibration_Level");
          const noise = doc.get("Noice_Level");
          const gas = doc.get("Gas_Level");
          const lat = doc.get("Latitude");
          const lng = doc.get("Longitude");

          const data = {
            id: uuid(),
            name: name,
            temperature: tempurature,
            vibration_level: vibration,
            noise_level: noise,
            gas_level: gas,
            position: {
              lat: lat,
              lng: lng,
            },
          };

          // console.log(data);

          dataSet.push(data);
        });
        console.log("Requested");
        return res.status(200).send(dataSet);
      }
    })
    .catch((err) => {
      return res.send("DataBase Error", err.message);
    });
};

// Function to get location data
export const getlocation = async (req, res) => {
  // Getting data from database
  const dataSet = [];

  userDB
    .get()
    .then((snapshot) => {
      if (snapshot.empty) {
        authorized = false;
        return res.status(404).send("There is no such user");
      } else {
        snapshot.forEach((doc) => {
          const name = doc.get("name");
          const logi = doc.get("Longitude");
          const lati = doc.get("Latitude");

          const data = {
            Name: name,
            Latitude: lati,
            Longitude: logi,
          };

          // console.log(data);

          dataSet.push(data);
        });
        console.log("Requested Location");
        return res.status(200).send(dataSet);
      }
    })
    .catch((err) => {
      return res.send("DataBase Error", err.message);
    });
};

// Function to get maximum sensor data
export const getMaxSensor = async (req, res) => {
  // Interating through the workers collection and gettig data
  let temps = [];
  let gasSafe = 0;
  let vibSafe = 0;
  let soundSafe = 0;
  let workerCount = 0;

  await userDB
    .get()
    .then((snapshot) => {
      snapshot.forEach((doc) => {
        const temp = doc.get("Tempurature");
        const gas = doc.get("Gas_Level");
        const vib = doc.get("Vibration_Level");
        const sound = doc.get("Noice_Level");

        // Adding tempurature to the array
        if (temp !== undefined) {
          temps.push(temp);
        }

        // Adding safe and unsafe count
        if (gas === "safe") {
          gasSafe++;
        }
        if (vib === "safe") {
          vibSafe++;
        }
        if (sound === "safe") {
          soundSafe++;
        }
        workerCount++;
      });

      console.log(temps);

      /* const data = {
            "MaxTemp": Math.max(...temps),
            "MinTemp": Math.min(...temps),
            "gasSafe": gasSafe,
            "vibSafe": vibSafe,
            "soundSafe": soundSafe,
            "wokerCount": workerCount
        } */

      const data = [
        {
          Title: "Maximum Temperature",
          value: Math.max(...temps),
        },
        {
          Title: "Minimum Temperature",
          value: Math.min(...temps),
        },
        {
          Title: "Harmful Gases",
          value: gasSafe,
        },
        {
          Title: "Harmful Vibrations",
          value: vibSafe,
        },
        {
          Title: "Harmful Noises",
          value: soundSafe,
        },
        {
          Title: "workerCount",
          value: workerCount,
        },
      ];

      return res.status(200).send(data);
    })
    .catch((err) => {
      return res.status(404).send(err.message);
    });
};

// Function to verify the autheniticated user
export const verifyToken = (req, res) => {
  // Getting id token
  const idToken = req.body.idToken;

  // Verifying the token
  admin
    .auth()
    .verifyIdToken(idToken)
    .then((decordedTocken) => {
      const userId = decordedTocken.uid;
      console.log(userId);

      supervisorDB
        .where("UserID", "==", userId)
        .get()
        .then((snapshot) => {
          if (snapshot.empty) {
            authorized = false;
            return res.send("Logging Failed");
          }
          authorized = true;
          res.send("Successfully Logged");
        })
        .catch((err) => {
          authorized = false;
          res.send("Login Failed", err.message);
        });
    })
    .catch((err) => {
      res.status(404).send("Login Faild");
      authorized = false;
    });
};

// Function to check authorization status of the web app
export const checkAuth = (req, res, next) => {
  if (authorized) {
    return next();
  } else {
    res.status(403).send("Unauthorzed");
    return;
  }
};

/* // function to check connection status
let prevData = {};

// Check that for every 6 seconds
setInterval(() => {
    userDB.get().then(snapshot => {
        snapshot.forEach(doc => {
            // const docId = doc.id;
            let connectedDate;
            
            // If there is no such a update time field
            if(doc.data().updatedAt === undefined){
                connectedDate = 0;
            }
            else{
                // If there is update time field, convert it to js time script and seconds
                connectedDate = doc.data().updatedAt.toDate().getTime()/1000;
            }

            // If the record is not updated for 6 seconds, make not connected
            if(connectedDate - prevData[doc.id] < 1){
                userDB.doc(doc.id).update({"connectionStatus":"Not_Connected"});
            }
            else{
                // Else update as connected
                userDB.doc(doc.id).update({"connectionStatus":"Connected"});
                prevData[doc.id] = connectedDate;
            }
        })
    }).catch(err => {
        console.log(err.message);
    })
}, 6000); */
// }
