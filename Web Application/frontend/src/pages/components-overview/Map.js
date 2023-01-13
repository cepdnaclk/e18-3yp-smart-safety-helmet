import { useEffect, useState } from 'react';
import { GoogleMap, InfoWindowF, MarkerF, useJsApiLoader, Circle, GroundOverlay } from '@react-google-maps/api';
import { Box, Container } from '@mui/material';
import axios from 'axios';

//import assests
// import { v4 as uuid } from 'uuid';
import { useNavigate } from 'react-router-dom';
import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
import config from 'firebaseConfig';

const containerStyle = {
    width: 'auto',
    height: '480px'
};

// const markers = [
//     {
//         id: 1,
//         Name: 'Jeewantha Udeshika',
//         Tempurature: '29',
//         position: { lat: 6.928939, lng: 79.834294 }
//     },
//     {
//         id: 2,
//         name: 'Ishan Maduranga',
//         temperature: '32',
//         position: { lat: 6.928896, lng: 79.833564 }
//     },
//     {
//         id: 3,
//         name: 'Tharindu Chamod',
//         temperature: '24',
//         position: { lat: 6.929621, lng: 79.830603 }
//     }
// ];

//Map controls
const mapControls = {
    panControl: false,
    mapTypeControl: false,
    streetViewControl: false,
    rotateControl: false,
    fullscreenControl: false,
    zoomControl: false,
    scrollWheel: false
};

const CircleOptions = {
    strokeColor: '#FFFFFF',
    strokeOpacity: 0.3,
    strokeWeight: 2,
    fillColor: '#FF0000',
    fillOpacity: 0.1,
    clickable: false,
    draggable: false,
    editable: false,
    visible: true,
    radius: 10,
    zIndex: 1
};

const bounds = {
    north: 6.941293,
    south: 6.925233,
    west: 79.822749,
    east: 79.841718
};

const Map = () => {
    // Navigator
    const navigate = useNavigate();

    const [activeMarker, setActiveMarker] = useState(null);

    const [isMounted, setIsMounted] = useState(false);

    //get the markers
    const [state, setState] = useState({
        result: []
    });

    const handleActiveMarker = (marker) => {
        if (marker === activeMarker) {
            return;
        }
        setActiveMarker(marker);
    };

    const [time, setTime] = useState({
        response: 1
    });

    //delay function
    const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

    useEffect(() => {
        async function getData() {
            // console.log(res);
            firebase.initializeApp(config);

            //checks whether a user is successfully logged in or not
            firebase.auth().onAuthStateChanged(async (user) => {
                if (user) {
                    //if there is logged user already
                    //navigate to dashboard
                    setIsMounted(true);
                    navigate('/dashboard');
                    try {
                        const res = await axios({
                            method: 'GET',
                            url: `${process.env.REACT_APP_API_URL}/getSensors`
                        });

                        console.log(res.data);
                        setState({ ...state, result: res.data });

                        // console.log(state.result);
                    } catch (err) {
                        console.log(err.response);
                    }

                    // ...
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

            // console.log('Map loaded');
        }

        getData();
    }, []);

    const handleOnLoad = (map) => {
        const bounds = new google.maps.LatLngBounds();
        state.result.forEach(({ Position }) => {
            bounds.extend(Position);
            // map.setCenter(Position);
            // map.setZoom(3);
        });
        // map.fitBounds(bounds);
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
                    <GoogleMap
                        mapContainerStyle={containerStyle}
                        zoom={17}
                        options={mapControls}
                        onLoad={handleOnLoad}
                        center={{ lat: 6.933966, lng: 79.832577 }}
                    >
                        {/* {<Marker position={center} />} */}
                        {state.result.map((marker) => (
                            // <Marker key={id} position={position} onClick={() => handleActiveMarker(id)}>
                            //     {activeMarker === id ? (
                            //         <InfoWindow onCloseClick={() => setActiveMarker(null)}>
                            //             <div>{name}</div>
                            //         </InfoWindow>
                            //     ) : null}
                            // </Marker>
                            <>
                                <Circle
                                    // key={uuid()}
                                    center={marker.Position}
                                    options={CircleOptions}
                                    visible={marker.Tempurature * 1 > 28 ? true : false}
                                ></Circle>
                                {isMounted && (
                                    <MarkerF
                                        key={marker.id != undefined ? marker.id : marker.Name}
                                        position={marker.Position}
                                        animation={marker.Tempurature * 1 > 28 ? window.google.maps.Animation.BOUNCE : null}
                                        onMouseOver={() => handleActiveMarker(marker.id != undefined ? marker.id : marker.Name)}
                                        onMouseOut={() => setActiveMarker(null)}
                                    >
                                        {activeMarker === (marker.id != undefined ? marker.id : marker.Name) ? (
                                            <InfoWindowF>
                                                <div>{marker.Name}</div>
                                            </InfoWindowF>
                                        ) : null}
                                    </MarkerF>
                                )}
                                <GroundOverlay key={'url'} url="https://i.imgur.com/T7nHzB8.jpeg" bounds={bounds} />
                            </>
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
