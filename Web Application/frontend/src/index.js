import Head from "next/head";
import { Box, Container, Grid, Button } from "@mui/material";
import { Budget } from "./components/dashboard/budget";
import { LatestOrders } from "./components/dashboard/latest-orders";
import { LatestProducts } from "./components/dashboard/latest-products";
import { Sales } from "./components/dashboard/sales";
import { TasksProgress } from "./components/dashboard/tasks-progress";
import { TotalCustomers } from "./components/dashboard/total-customers";
import { TotalProfit } from "./components/dashboard/total-profit";
import { TrafficByDevice } from "./components/dashboard/traffic-by-device";
import { DashboardLayout } from "./components/dashboard-layout";
import Map from "./pages/map";
import { Google as GoogleIcon } from "./icons/google";
import WarningIcon from "@mui/icons-material/Warning";
import CallIcon from "@mui/icons-material/Call";

const Page = () => (
  <>
    <Head>
      <title>Overview</title>
    </Head>
    {/* <Box>
      <Container>
        <Grid>
          <Grid item lg={3} sm={6} xl={3} xs={12}>
            <Budget />
          </Grid>
          <Grid item xl={3} lg={3} sm={6} xs={12}>
            <TotalCustomers />
          </Grid>
          <Grid item xl={3} lg={3} sm={6} xs={12}>
            <TasksProgress />
          </Grid>
          <Grid item xl={3} lg={3} sm={6} xs={12}>
            <TotalProfit sx={{ height: "100%" }} />
          </Grid>
          <Grid item lg={8} md={12} xl={9} xs={12}>
            <Sales />
          </Grid>
          <Grid item lg={4} md={6} xl={3} xs={12}>
            <TrafficByDevice sx={{ height: "100%" }} />
          </Grid>
          <Grid item lg={4} md={6} xl={3} xs={12}>
            <LatestProducts sx={{ height: "100%" }} />
          </Grid>
          <Grid item lg={8} md={12} xl={9} xs={12}>
            <LatestOrders />
          </Grid> 
          <Grid item lg={8} md={12} xl={9} xs={12}>
            <Map />
          </Grid>
        </Grid>
        <Map />
      </Container>
    </Box> */}

    <Grid>
      <Map />
    </Grid>
    <Box>
      <Grid container spacing={3}>
        <Grid item xs={6} md={6}>
          <Button
            color="warning"
            fullWidth
            // onClick={handleClick}
            size="large"
            startIcon={<WarningIcon />}
            variant="contained"
          >
            Warn All Workers
          </Button>
        </Grid>
        <Grid item xs={12} md={6}>
          <Button color="info" fullWidth size="large" startIcon={<CallIcon />} variant="contained">
            Recall All Workers
          </Button>
        </Grid>
      </Grid>
    </Box>
  </>
);

Page.getLayout = (page) => <DashboardLayout>{page}</DashboardLayout>;

export default Page;
