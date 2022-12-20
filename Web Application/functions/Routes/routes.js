import express from 'express';
import { addUser, getUser } from '../Controller/control.js';

const router = express.Router();

router.get("/", (req, res)=>{
    res.send({message: "Hi Bosa"});
});

router.get('/user', getUser);

router.post('/addUser', addUser);

export default router;