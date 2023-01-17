import PropTypes from 'prop-types';
import { useRef, useState, useEffect } from 'react';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

// material-ui
import { useTheme } from '@mui/material/styles';
import {
    Avatar,
    Box,
    ButtonBase,
    CardContent,
    ClickAwayListener,
    Grid,
    IconButton,
    Paper,
    Popper,
    Stack,
    Tab,
    Tabs,
    Typography
} from '@mui/material';

// project import
import MainCard from 'components/MainCard';
import Transitions from 'components/@extended/Transitions';
import ProfileTab from './ProfileTab';
import SettingTab from './SettingTab';

// assets
import avatar1 from 'assets/images/users/avatar-1.png';
import { LogoutOutlined, SettingOutlined, UserOutlined } from '@ant-design/icons';

import 'firebase/compat/auth';
import firebase from 'firebase/compat/app';
import config from 'firebaseConfig';

import { useNavigate } from 'react-router-dom';

// tab panel wrapper
function TabPanel({ children, value, index, ...other }) {
    return (
        <div role="tabpanel" hidden={value !== index} id={`profile-tabpanel-${index}`} aria-labelledby={`profile-tab-${index}`} {...other}>
            {value === index && children}
        </div>
    );
}

TabPanel.propTypes = {
    children: PropTypes.node,
    index: PropTypes.any.isRequired,
    value: PropTypes.any.isRequired
};

function a11yProps(index) {
    return {
        id: `profile-tab-${index}`,
        'aria-controls': `profile-tabpanel-${index}`
    };
}

// ==============================|| HEADER CONTENT - PROFILE ||============================== //

const Profile = () => {
    const navigate = useNavigate();

    const theme = useTheme();

    const handleLogout = async () => {
        // logout
        try {
            firebase.auth().signOut();
        } catch (err) {
            showError(err.message);
        }
    };

    const anchorRef = useRef(null);
    const [open, setOpen] = useState(false);
    const handleToggle = () => {
        setOpen((prevOpen) => !prevOpen);
    };

    const handleClose = (event) => {
        if (anchorRef.current && anchorRef.current.contains(event.target)) {
            return;
        }
        setOpen(false);
    };

    const [value, setValue] = useState(0);

    const handleChange = (event, newValue) => {
        setValue(newValue);
    };

    const showError = (err) => {
        toast.error(err, {
            position: 'top-center',
            autoClose: 5000,
            hideProgressBar: false,
            closeOnClick: true,
            pauseOnHover: true,
            draggable: true,
            progress: undefined,
            theme: 'light'
        });
    };

    const iconBackColorOpen = 'grey.300';

    useEffect(() => {
        async function getData() {
            // console.log(res);
            firebase.initializeApp(config);

            //checks whether a user is successfully logged in or not
            firebase.auth().onAuthStateChanged(async (user) => {
                if (user) {
                    //if there is logged user already
                    //navigate to dashboard
                    navigate('/dashboard');
                    console.log(user.uid);

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
        <Grid container justifyContent="flex-end">
            <Box sx={{ flexShrink: 0, ml: 0.75 }}>
                <ToastContainer />
                <ButtonBase
                    sx={{
                        p: 0.25,
                        bgcolor: open ? iconBackColorOpen : 'transparent',
                        borderRadius: 1,
                        '&:hover': { bgcolor: 'secondary.lighter' }
                    }}
                    aria-label="open profile"
                    ref={anchorRef}
                    aria-controls={open ? 'profile-grow' : undefined}
                    aria-haspopup="true"
                    onClick={handleToggle}
                >
                    <Stack direction="row" spacing={2} alignItems="center" sx={{ p: 0.5 }}>
                        <Avatar alt="profile user" src={avatar1} sx={{ width: 32, height: 32 }} />
                        <Typography variant="subtitle1">John Doe</Typography>
                    </Stack>
                </ButtonBase>
                <Popper
                    placement="bottom-end"
                    open={open}
                    anchorEl={anchorRef.current}
                    role={undefined}
                    transition
                    disablePortal
                    popperOptions={{
                        modifiers: [
                            {
                                name: 'offset',
                                options: {
                                    offset: [0, 9]
                                }
                            }
                        ]
                    }}
                >
                    {({ TransitionProps }) => (
                        <Transitions type="fade" in={open} {...TransitionProps}>
                            {open && (
                                <Paper
                                    sx={{
                                        boxShadow: theme.customShadows.z1,
                                        width: 290,
                                        minWidth: 240,
                                        maxWidth: 290,
                                        [theme.breakpoints.down('md')]: {
                                            maxWidth: 250
                                        }
                                    }}
                                >
                                    <ClickAwayListener onClickAway={handleClose}>
                                        <MainCard elevation={0} border={false} content={false}>
                                            <CardContent sx={{ px: 2.5, pt: 3 }}>
                                                <Grid container justifyContent="space-between" alignItems="center">
                                                    <Grid item>
                                                        <Stack direction="row" spacing={1.25} alignItems="center">
                                                            <Avatar alt="profile user" src={avatar1} sx={{ width: 32, height: 32 }} />
                                                            <Stack>
                                                                <Typography variant="h6">John Doe</Typography>
                                                                {/* <Typography variant="body2" color="textSecondary">
                                                                UI/UX Designer
                                                            </Typography> */}
                                                            </Stack>
                                                        </Stack>
                                                    </Grid>
                                                    <Grid item>
                                                        <IconButton size="large" color="secondary" onClick={handleLogout}>
                                                            <LogoutOutlined />
                                                        </IconButton>
                                                    </Grid>
                                                </Grid>
                                            </CardContent>
                                            {open && (
                                                <>
                                                    <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
                                                        <Tabs
                                                            variant="fullWidth"
                                                            value={value}
                                                            onChange={handleChange}
                                                            aria-label="profile tabs"
                                                        >
                                                            <Tab
                                                                sx={{
                                                                    display: 'flex',
                                                                    flexDirection: 'row',
                                                                    justifyContent: 'center',
                                                                    alignItems: 'center',
                                                                    textTransform: 'capitalize'
                                                                }}
                                                                icon={<UserOutlined style={{ marginBottom: 0, marginRight: '10px' }} />}
                                                                label="Profile"
                                                                {...a11yProps(0)}
                                                            />
                                                            <Tab
                                                                sx={{
                                                                    display: 'flex',
                                                                    flexDirection: 'row',
                                                                    justifyContent: 'center',
                                                                    alignItems: 'center',
                                                                    textTransform: 'capitalize'
                                                                }}
                                                                icon={<SettingOutlined style={{ marginBottom: 0, marginRight: '10px' }} />}
                                                                label="Setting"
                                                                {...a11yProps(1)}
                                                            />
                                                        </Tabs>
                                                    </Box>
                                                    <TabPanel value={value} index={0} dir={theme.direction}>
                                                        <ProfileTab handleLogout={handleLogout} />
                                                    </TabPanel>
                                                    <TabPanel value={value} index={1} dir={theme.direction}>
                                                        <SettingTab />
                                                    </TabPanel>
                                                </>
                                            )}
                                        </MainCard>
                                    </ClickAwayListener>
                                </Paper>
                            )}
                        </Transitions>
                    )}
                </Popper>
            </Box>
        </Grid>
    );
};

export default Profile;
