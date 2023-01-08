import React from 'react';
import { Link as RouterLink } from 'react-router-dom';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { useNavigate } from 'react-router-dom';

// material-ui
import {
    Button,
    Checkbox,
    Divider,
    FormControlLabel,
    FormHelperText,
    Grid,
    Link,
    IconButton,
    InputAdornment,
    InputLabel,
    OutlinedInput,
    Stack,
    Typography
} from '@mui/material';

// third party
import * as Yup from 'yup';
import { Formik } from 'formik';

// project import
import AnimateButton from 'components/@extended/AnimateButton';

// assets
import { EyeOutlined, EyeInvisibleOutlined } from '@ant-design/icons';
import axios from 'axios';
import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
// import config from 'firebaseConfig';

// ============================|| FIREBASE - LOGIN ||============================ //

const AuthLogin = () => {
    // Navigator
    const navigate = useNavigate();

    const [checked, setChecked] = React.useState(false);

    const [showPassword, setShowPassword] = React.useState(false);
    const handleClickShowPassword = () => {
        setShowPassword(!showPassword);
    };

    const handleMouseDownPassword = (event) => {
        event.preventDefault();
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

    return (
        <>
            <Formik
                initialValues={{
                    email: 'admin@uop.lk',
                    password: '123456',
                    submit: null
                }}
                validationSchema={Yup.object().shape({
                    email: Yup.string().email('Must be a valid email').max(255).required('Email is required'),
                    password: Yup.string().max(255).required('Password is required')
                })}
                onSubmit={async (values, { setErrors, setStatus, setSubmitting }) => {
                    // try {
                    //     setStatus({ success: false });
                    //     setSubmitting(false);
                    // } catch (err) {
                    //     setStatus({ success: false });
                    //     setErrors({ submit: err.message });
                    //     setSubmitting(false);
                    // }

                    //initialize the application
                    firebase.initializeApp(firebaseConfig);

                    //sign in with email and pssw
                    firebase
                        .auth()
                        .signInWithEmailAndPassword(values.email, values.password)
                        .then(function (response) {
                            // sign in successful
                            firebase
                                .auth()
                                .currentUser.getIdToken()
                                .then(function (idToken) {
                                    // send the ID token to the backend
                                    axios
                                        .post('https://us-central1-smart-helmet-74616.cloudfunctions.net/appFunc/verifyToken', { idToken })
                                        .then(function (response) {
                                            // ID token was verified by the backend
                                            console.log(response.data);

                                            //goto dashboard page
                                            navigate('/dashboard');
                                        })
                                        .catch(function (error) {
                                            // an error occurred
                                            console.log(error.message);
                                            showError(error.message);
                                        });
                                    // print the token
                                    // console.log(idToken);
                                });
                        })
                        .catch((error) => {
                            // an error occurred
                            console.log(error.message);
                            showError(error.message);
                        });
                }}
            >
                {({ errors, handleBlur, handleChange, handleSubmit, isSubmitting, touched, values }) => (
                    <form noValidate onSubmit={handleSubmit}>
                        <ToastContainer />
                        <Grid container spacing={3}>
                            <Grid item xs={12}>
                                <Stack spacing={1}>
                                    <InputLabel htmlFor="email-login">Email Address</InputLabel>
                                    <OutlinedInput
                                        id="email-login"
                                        type="email"
                                        value={values.email}
                                        name="email"
                                        onBlur={handleBlur}
                                        onChange={handleChange}
                                        placeholder="Enter email address"
                                        fullWidth
                                        error={Boolean(touched.email && errors.email)}
                                    />
                                    {touched.email && errors.email && (
                                        <FormHelperText error id="standard-weight-helper-text-email-login">
                                            {errors.email}
                                        </FormHelperText>
                                    )}
                                </Stack>
                            </Grid>
                            <Grid item xs={12}>
                                <Stack spacing={1}>
                                    <InputLabel htmlFor="password-login">Password</InputLabel>
                                    <OutlinedInput
                                        fullWidth
                                        error={Boolean(touched.password && errors.password)}
                                        id="-password-login"
                                        type={showPassword ? 'text' : 'password'}
                                        value={values.password}
                                        name="password"
                                        onBlur={handleBlur}
                                        onChange={handleChange}
                                        endAdornment={
                                            <InputAdornment position="end">
                                                <IconButton
                                                    aria-label="toggle password visibility"
                                                    onClick={handleClickShowPassword}
                                                    onMouseDown={handleMouseDownPassword}
                                                    edge="end"
                                                    size="large"
                                                >
                                                    {showPassword ? <EyeOutlined /> : <EyeInvisibleOutlined />}
                                                </IconButton>
                                            </InputAdornment>
                                        }
                                        placeholder="Enter password"
                                    />
                                    {touched.password && errors.password && (
                                        <FormHelperText error id="standard-weight-helper-text-password-login">
                                            {errors.password}
                                        </FormHelperText>
                                    )}
                                </Stack>
                            </Grid>

                            <Grid item xs={12} sx={{ mt: -1 }}>
                                <Stack direction="row" justifyContent="space-between" alignItems="center" spacing={2}>
                                    <FormControlLabel
                                        control={
                                            <Checkbox
                                                checked={checked}
                                                onChange={(event) => setChecked(event.target.checked)}
                                                name="checked"
                                                color="primary"
                                                size="small"
                                            />
                                        }
                                        label={<Typography variant="h6">Keep me sign in</Typography>}
                                    />
                                    <Link variant="h6" component={RouterLink} to="" color="text.primary">
                                        Forgot Password?
                                    </Link>
                                </Stack>
                            </Grid>
                            {errors.submit && (
                                <Grid item xs={12}>
                                    <FormHelperText error>{errors.submit}</FormHelperText>
                                </Grid>
                            )}
                            <Grid item xs={12}>
                                <AnimateButton>
                                    <Button
                                        disableElevation
                                        disabled={isSubmitting}
                                        fullWidth
                                        size="large"
                                        type="submit"
                                        variant="contained"
                                        color="primary"
                                    >
                                        Login
                                    </Button>
                                </AnimateButton>
                            </Grid>
                            {/* <Grid item xs={12}>
                                <Divider>
                                    <Typography variant="caption"> Login with</Typography>
                                </Divider>
                            </Grid>
                            <Grid item xs={12}>
                                <FirebaseSocial />
                            </Grid> */}
                        </Grid>
                    </form>
                )}
            </Formik>
        </>
    );
};

export default AuthLogin;
