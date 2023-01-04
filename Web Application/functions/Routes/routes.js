import express from 'express';
import { addUser, checkAuth, getUser, verifyToken } from '../Controller/control.js';

const router = express.Router();

router.get("/", (req, res)=>{
    res.send({message: "Hi User"});
});

router.get('/user', getUser);

router.post('/addUser', checkAuth, addUser);

router.post('/verifyToken', verifyToken);

export default router;