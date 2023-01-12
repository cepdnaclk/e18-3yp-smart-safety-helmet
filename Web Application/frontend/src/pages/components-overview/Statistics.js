import { Avatar, Box, Container, Grid, Card, CardContent, Typography } from '@mui/material';
// import { statistics } from '../../__mocks__/statistics';
// import { StatCard } from '../../components/statistics/stat-card';
import { useEffect, useState } from 'react';
import { v4 as uuid } from 'uuid';

//import assests
import { useNavigate } from 'react-router-dom';
import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
import config from 'firebaseConfig';
import axios from '../../../node_modules/axios/index';

const Page = () => {
    // Navigator
    const navigate = useNavigate();

    const [time, setTime] = useState({
        response: 1
    });

    const [state, setState] = useState({
        result: []
    });

    const [workerCount, setWorkerCount] = useState({
        count: {}
    });

    //delay function
    const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

    useEffect(() => {
        async function getData() {
            //initialize the App
            firebase.initializeApp(config);

            //checks whether a user is successfully logged in or not
            firebase.auth().onAuthStateChanged(async (user) => {
                if (user) {
                    //if there is logged user already
                    //navigate to dashboard
                    navigate('/statistics');
                    const res = await axios({
                        method: 'GET',
                        url: 'https://us-central1-smart-helmet-74616.cloudfunctions.net/appFunc/maxTemp'
                    });

                    // console.log(res.data.slice(-1));

                    //remove the last element from the object array
                    // const original = res.data;
                    // original.splice(-1);

                    setState({ ...state, result: res.data });

                    //get the worker count
                    setWorkerCount({ ...workerCount, count: res.data.pop() });
                    // console.log(state.result);
                } else {
                    // User is signed out
                    // No user is signed in.
                    // console.log('No User Signed In');

                    //if there is no logged user go to login
                    navigate('/login');
                }
            });

            await delay(5000);
            setTime({ ...time, response: !time.response });
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
                        {state.result.map((stat) => (
                            <Grid item key={uuid()} lg={4} md={6} xs={12}>
                                {/* <StatCard stat={stat} /> */}
                                <Card
                                    sx={{
                                        display: 'flex',
                                        flexDirection: 'column',
                                        height: '100%'
                                    }}
                                >
                                    <CardContent>
                                        <Box
                                            sx={{
                                                display: 'flex',
                                                justifyContent: 'center',
                                                pb: 3
                                            }}
                                        >
                                            <Avatar src={`/statistics/${stat.Title}.svg`} variant="square" />
                                        </Box>

                                        <Typography align="center" color="textPrimary" gutterBottom variant="h5" fontSize={25}>
                                            {stat.Title}
                                        </Typography>
                                        <Typography
                                            align="center"
                                            color="textPrimary"
                                            variant="h3"
                                            fontSize={20}
                                            fontStyle="italic"
                                            sx={{ color: '#0000FF' }}
                                        >
                                            {stat.Title !== 'Maximum Temperature' && stat.Title !== 'Minimum Temperature'
                                                ? `safe : ${stat.value}`
                                                : `${stat.value} \u00b0C`}
                                        </Typography>
                                        <Typography
                                            align="center"
                                            color="textPrimary"
                                            variant="h3"
                                            fontSize={20}
                                            fontStyle="italic"
                                            sx={{ color: '#FF0000' }}
                                        >
                                            {stat.Title !== 'Maximum Temperature' && stat.Title !== 'Minimum Temperature'
                                                ? `unsafe : ${workerCount.count.value - stat.value}`
                                                : ''}
                                        </Typography>
                                    </CardContent>
                                </Card>
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
