import { db } from "../Auth/firebase.js";

// Create the collection
const userDB = db.collection('users');

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
            telNo: req.body.telNo
        }
        console.log(user);
        const response = await userDB.doc(id).set(user);
        res.send(response);
    }
    catch(err){
        res.send(err);
    }
}