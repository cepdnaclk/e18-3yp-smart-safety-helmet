import { useEffect, useState } from 'react';
import { GoogleMap, InfoWindow, Marker, useJsApiLoader } from '@react-google-maps/api';
import { Box, Container } from '@mui/material';
// import axios from 'axios';

//import assests
import { useNavigate } from 'react-router-dom';
import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
import config from 'firebaseConfig';

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
            firebase.initializeApp(config);

            //checks whether a user is successfully logged in or not
            firebase.auth().onAuthStateChanged((user) => {
                if (user) {
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
            });
        }

        getData();
    }, []);

    const handleOnLoad = (map) => {
        const bounds = new google.maps.LatLngBounds();
        markers.forEach(({ position }) => bounds.extend(position));
        map.fitBounds(bounds);
    };

    const { isLoaded } = useJsApiLoader({
        mapId: process.env.REACT_APP_MAP_ID,
        googleMapsApiKey: process.env.REACT_APP_MAPS_API_KEY
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
