import { db } from "../Auth/firebase.js";
import admin from "firebase-admin";

let authorized = false;      /**@ToDo make this from firebase */


// Create the collection
const userDB = db.collection('users');

// Function to get given user details
export const getUser = async (req, res) => {
    try{
        const response = await userDB.doc('userDetails').get();
        res.send(response.data());
    }
    catch(err){
        res.send(err);
    }
    
}

export const addUser = async (req, res) => {
    try{
        console.log(req.body)
        const id = req.body.name;
        const user = {
            post: req.body.post,
            email: req.body.email,
            telNo: req.body.telNo,
            bloodGroup: req.body.bloodGroup
        }
        console.log(user);
        const response = await userDB.doc(id).set(user);
        res.send(response);
    }
    catch(err){
        res.send(err);
    }
}

// Function to get sensor data of one user
/**@ToDo 
 * Way to retrieve user id from logged cookie
 * Way to give user id to every user
*/
export const getSensorData = (req, res) => {

}

// Function to get maximum sensor data
/**@ToDo 
 * Get max data from the all the fields in firebase
*/
export const getMaxSensor = (req, res) => {

}

// Function to verify the autheniticated user
export const verifyToken = (req, res) => {
    // Getting id token
    const idToken = req.body.idToken;

    // Verifying the token
    admin.auth().verifyIdToken(idToken).then(decordedTocken => {
        const userId = decordedTocken.uid;
        console.log(userId);
        authorized = true;
        res.send("Successfully Logged");

    }).catch(err => {
        res.status(404).send("Login Faild");
        authorized = false;
    })

}

// Function to check authorization status of the web app
export const checkAuth = (req, res, next) => {
    if(authorized){
        return next();
    }
    else{
        res.status(403).send('Unauthorzed');
        return;
    }
}


// function to check real time updates of database
/* const doc = userDB.doc('Jeewantha');

const observer = doc.onSnapshot(docSnapshot => {
  console.log(`Received doc snapshot: ${docSnapshot}`);
  return docSnapshot.email;
  // ...
}, err => {
  console.log(`Encountered error: ${err}`);
}); */