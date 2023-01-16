import express from 'express';
import { addUser, checkAuth, getlocation, getMaxSensor, getSensorData, getUser, verifyToken } from '../Controller/control.js';

const router = express.Router();

router.get("/", (req, res)=>{
    res.send({message: "Hi User"});
});

router.get('/user/:id', getUser);

router.post('/addUser', /* checkAuth, */ addUser);

router.post('/verifyToken', verifyToken);

router.get('/maxTemp', /* checkAuth, */ getMaxSensor);

router.get('/getSensors', getSensorData);

router.get('/getLocation', /*checkAuth, */ getlocation );

export default router;