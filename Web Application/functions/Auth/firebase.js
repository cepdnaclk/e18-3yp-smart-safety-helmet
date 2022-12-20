import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

import serviceAcc from './cert.json' assert {type: 'json'};


const firebaseConfig = {
    credential: cert(serviceAcc)
  };

const initApp = initializeApp(firebaseConfig);

export const db= getFirestore();