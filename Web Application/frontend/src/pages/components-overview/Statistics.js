import { Box, Container, Grid } from '@mui/material';
import { statistics } from '../../__mocks__/statistics';
import { StatCard } from '../../components/statistics/stat-card';

const Page = () => (
    <>
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
    </>
);

export default Page;
