import { useEffect, useState } from 'react';
import { GoogleMap, InfoWindow, Marker, useJsApiLoader } from '@react-google-maps/api';
import { Box, Container } from '@mui/material';
import axios from 'axios';

//import assests
import { useNavigate } from 'react-router-dom';
import { getAuth } from 'firebase/auth';
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

const containerStyle = {
    width: 'auto',
    height: '480px'
};

const markers = [
    {
        id: 1,
        name: 'Jeewantha Udeshika',
        position: { lat: 36.265095, lng: -115.236933 }
    },
    {
        id: 2,
        name: 'Ishan Maduranga',
        position: { lat: 36.265052, lng: -115.236364 }
    },
    {
        id: 3,
        name: 'Tharindu Chamod',
        position: { lat: 36.264941, lng: -115.236773 }
    },
    {
        id: 4,
        name: 'Lakshan Wijekoon',
        position: { lat: 36.265248, lng: -115.237256 }
    }
];
const mapControls = {
    panControl: false,
    mapTypeControl: false,
    streetViewControl: false,
    rotateControl: false,
    fullscreenControl: false
};

const Map = () => {
    // Navigator
    const navigate = useNavigate();

    const [activeMarker, setActiveMarker] = useState(null);

    const handleActiveMarker = (marker) => {
        if (marker === activeMarker) {
            return;
        }
        setActiveMarker(marker);
    };

    useEffect(() => {
        async function getData() {
            // Send the application data to the backend
            // const res = await axios({
            //     method: 'GET',
            //     url: 'https://dog.ceo/api/breeds/image/random'
            // });

            // console.log(res);
            firebase.initializeApp(firebaseConfig);
            const auth = getAuth();
            const user = auth.currentUser;

            if (user) {
                // console.log(user.uid);

                //if there is logged user already
                //navigate to dashboard
                navigate('/dashboard');
                // ...
            } else {
                // User is signed out
                // No user is signed in.
                // console.log('No User Signed In');

                //if there is no logged user go to login
                navigate('/login');
            }
        }

        getData();
    }, []);

    const handleOnLoad = (map) => {
        const bounds = new google.maps.LatLngBounds();
        markers.forEach(({ position }) => bounds.extend(position));
        map.fitBounds(bounds);
    };

    const { isLoaded } = useJsApiLoader({
        // mapId: process.env.MAP_ID,
        // googleMapsApiKey: process.env.MAPS_API_KEY // Add your API key
        mapId: '728e8bcdc7d02a3e',
        googleMapsApiKey: 'AIzaSyACvQ9R_hLNd41f-y3fdqWk-ph_-d5g44U' // Add your API key
    });

    return isLoaded ? (
        <>
            <Box
                component="main"
                sx={{
                    flexGrow: 1,
                    py: 8
                }}
            >
                <Container maxWidth="xl">
                    <GoogleMap mapContainerStyle={containerStyle} zoom={50} options={mapControls} onLoad={handleOnLoad}>
                        {/* {<Marker position={center} />} */}
                        {markers.map(({ id, name, position }) => (
                            <Marker key={id} position={position} onClick={() => handleActiveMarker(id)}>
                                {activeMarker === id ? (
                                    <InfoWindow onCloseClick={() => setActiveMarker(null)}>
                                        <div>{name}</div>
                                    </InfoWindow>
                                ) : null}
                            </Marker>
                        ))}
                    </GoogleMap>
                </Container>
            </Box>
        </>
    ) : (
        <></>
    );
};

export default Map;
