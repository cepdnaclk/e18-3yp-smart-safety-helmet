import { Box, Container, Typography } from '@mui/material';
import { SettingsPassword } from '../../components/settings/settings-password';

const Page = () => (
    <>
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
    </>
);

Page.getLayout = (page) => <DashboardLayout>{page}</DashboardLayout>;

export default Page;
