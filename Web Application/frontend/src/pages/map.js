import React, { useEffect, useState } from "react";
import { GoogleMap, InfoWindow, Marker, useJsApiLoader } from "@react-google-maps/api";
import { DashboardLayout } from "../components/dashboard-layout";
import { Box, Container, Grid, Button, Typography } from "@mui/material";
import { Google as GoogleIcon } from "../icons/google";
import axios from "axios";

const containerStyle = {
  width: "auto",
  height: "480px",
};

const markers = [
  {
    id: 1,
    name: "Chicago, Illinois",
    position: { lat: 41.881832, lng: -87.623177 },
  },
  {
    id: 2,
    name: "Denver, Colorado",
    position: { lat: 39.739235, lng: -104.99025 },
  },
  {
    id: 3,
    name: "Los Angeles, California",
    position: { lat: 34.052235, lng: -118.243683 },
  },
  {
    id: 4,
    name: "New York, New York",
    position: { lat: 40.712776, lng: -74.005974 },
  },
];
const mapControls = {
  panControl: false,
  mapTypeControl: false,
  streetViewControl: false,
  rotateControl: false,
  fullscreenControl: false,
};

function Map() {
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
      const res = await axios({
        method: "GET",
        url: "https://dog.ceo/api/breeds/image/random",
      });

      console.log(res);
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
    // googleMapsApiKey: process.env.MAPS_API_KEY, // Add your API key
    mapId: "728e8bcdc7d02a3e",
    googleMapsApiKey: "AIzaSyACvQ9R_hLNd41f-y3fdqWk-ph_-d5g44U", // Add your API key
  });

  return isLoaded ? (
    <>
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          py: 8,
        }}
      >
        <Container maxWidth="xl">
          <GoogleMap
            mapContainerStyle={containerStyle}
            zoom={100}
            options={mapControls}
            onLoad={handleOnLoad}
          >
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

      {/* <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <Button
            color="error"
            fullWidth
            // onClick={handleClick}
            size="large"
            startIcon={<GoogleIcon />}
            variant="contained"
          >
            Login with Google
          </Button>
        </Grid>
      </Grid> */}
    </>
  ) : (
    <></>
  );
}

Map.getLayout = (page) => <DashboardLayout>{page}</DashboardLayout>;

export default Map;
