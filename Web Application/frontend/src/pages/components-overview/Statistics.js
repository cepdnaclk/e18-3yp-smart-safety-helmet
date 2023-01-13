import { Box, Container, Grid } from '@mui/material';
import { statistics } from '../../__mocks__/statistics';
import { StatCard } from '../../components/statistics/stat-card';
import { useEffect } from 'react';

//import assests
import { useNavigate } from 'react-router-dom';
import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
import config from 'firebaseConfig';

const Page = () => {
    // Navigator
    const navigate = useNavigate();

    useEffect(() => {
        async function getData() {
            //initialize the App
            firebase.initializeApp(config);

            //checks whether a user is successfully logged in or not
            firebase.auth().onAuthStateChanged((user) => {
                if (user) {
                    //if there is logged user already
                    //navigate to dashboard
                    navigate('/statistics');
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
            <Container maxWidth={false}>
                {/* <StatListToolbar /> */}
                <Box sx={{ pt: 3 }}>
                    <Grid container spacing={3}>
                        {statistics.map((stat) => (
                            <Grid item key={stat.id} lg={4} md={6} xs={12}>
                                <StatCard stat={stat} />
                            </Grid>
                        ))}
                    </Grid>
                </Box>
                {/* <Box
          sx={{
            display: "flex",
            justifyContent: "center",
            pt: 3,
          }}
        >
          <Pagination color="primary" count={3} size="small" />
        </Box> */}
            </Container>
        </Box>
    );
};

export default Page;
