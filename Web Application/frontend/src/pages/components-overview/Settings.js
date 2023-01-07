import { Box, Container, Typography } from '@mui/material';
import { SettingsPassword } from '../../components/settings/settings-password';
import { useEffect } from 'react';

//import assests
import { useNavigate } from 'react-router-dom';
import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';

// firebase app configuration
const firebaseConfig = {
    apiKey: 'AIzaSyBK0t0b6M_dS7Jin7D7dgGCeKbZq_dq5FQ',
    authDomain: 'smart-helmet-74616.firebaseapp.com',
    databaseURL: 'https://smart-helmet-74616-default-rtdb.firebaseio.com',
    projectId: 'smart-helmet-74616',
    storageBucket: 'smart-helmet-74616.appspot.com',
    messagingSenderId: '20313702925',
    appId: '1:20313702925:web:e293f804b8bbaaa6018b44'
};

const Page = () => {
    // Navigator
    const navigate = useNavigate();

    useEffect(() => {
        async function getData() {
            //initialize the App
            firebase.initializeApp(firebaseConfig);

            //checks whether a user is successfully logged in or not
            firebase.auth().onAuthStateChanged((user) => {
                if (user) {
                    //if there is logged user already
                    //navigate to dashboard
                    navigate('/settings');
                    // ...
                } else {
                    // User is signed out
                    // No user is signed in.
                    // console.log('No User Signed In');

                    //if there is no logged user go to login
                    navigate('/login');
                }
            });
        }

        getData();
    }, []);

    return (
        <Box
            component="main"
            sx={{
                flexGrow: 1,
                py: 8
            }}
        >
            <Container maxWidth="lg">
                <Typography sx={{ mb: 3 }} variant="h4">
                    Settings
                </Typography>
                <Box sx={{ pt: 3 }}>
                    <SettingsPassword />
                </Box>
            </Container>
        </Box>
    );
};

Page.getLayout = (page) => <DashboardLayout>{page}</DashboardLayout>;

export default Page;
