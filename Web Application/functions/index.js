import express from 'express';
import routes from './Routes/routes.js';
import bodyParser from 'body-parser';
import functions from 'firebase-functions'
import cors from 'cors'
// import { checkConnected } from './Controller/control.js';


const app = express();

app.use(cors());    // Sake of communicating with frontend
app.use(bodyParser.json()); // Make data encoding method to http body
app.use(bodyParser.urlencoded({ extended: true })); // Make data encoding method to http body

app.use("/", routes);

export const SupervisorHelmet = functions.https.onRequest(app);