import { Avatar, Box, Container, Grid, Card, CardContent, Typography } from '@mui/material';
import { useEffect, useState } from 'react';
import { v4 as uuid } from 'uuid';

//import assests
import { useNavigate, useLocation } from 'react-router-dom';
import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
import config from 'firebaseConfig';
import axios from '../../../node_modules/axios/index';

const Page = () => {
    // get the username
    const { state } = useLocation();

    const navigate = useNavigate();

    const [time, setTime] = useState({
        response: 1
    });

    const [stats, setStats] = useState({
        result: []
    });

    //function to select the color
    const colorPicker = (stat) => {
        if (stat.Title === 'Temperature') {
            return '#0000FF';
        } else {
            if (stat.value === 'safe') {
                return '#00FF00';
            } else {
                return '#FF0000';
            }
        }
    };

    const [name, setName] = useState({
        name: ''
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
                    navigate('/userstats');
                    // console.log(state);
                    const res = await axios({
                        method: 'GET',
                        url: `${process.env.REACT_APP_API_URL}/user/${state}`
                    });

                    console.log(res.data);
                    // console.log(res.data.slice(-1));

                    //remove the last element from the object array
                    // const original = res.data;
                    // original.splice(-1);
                    // console.log(res.data);
                    setStats({ ...stats, result: res.data });

                    // console.log(stats.result);
                    //get the Name
                    setName({ ...name, name: res.data.pop() });
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
            // console.log('Stats loaded');
        }

        getData();
    }, [time]);

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
                <Typography
                    key={uuid()}
                    align="center"
                    color="textPrimary"
                    variant="h3"
                    fontSize={20}
                    fontStyle="italic"
                    sx={{ color: '#0000FF', visibility: name.name.value === undefined ? 'hidden' : 'visible' }}
                >
                    {name.name.value}
                </Typography>
                <Box sx={{ pt: 3 }}>
                    <Grid container spacing={3}>
                        {stats.result.map((stat) => (
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
                                            sx={{ color: colorPicker(stat) }}
                                        >
                                            {stat.Title !== 'Temperature' ? `${stat.value}` : `${stat.value} \u00b0C`}
                                        </Typography>
                                    </CardContent>
                                </Card>
                            </Grid>
                        ))}
                    </Grid>
                </Box>
            </Container>
        </Box>
    );
};

export default Page;
