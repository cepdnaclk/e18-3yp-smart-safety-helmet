import { useEffect, useState } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import { useNavigate } from 'react-router-dom';

import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
import config from 'firebaseConfig';

// material-ui
import {
    Box,
    Button,
    Divider,
    FormControl,
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
// import FirebaseSocial from './FirebaseSocial';
import axios from 'axios';
import AnimateButton from 'components/@extended/AnimateButton';
import { strengthColor, strengthIndicator } from 'utils/password-strength';

// assets
import { EyeOutlined, EyeInvisibleOutlined } from '@ant-design/icons';

// ============================|| FIREBASE - REGISTER ||============================ //

const AuthRegister = () => {
    const navigate = useNavigate();
    const [level, setLevel] = useState();
    const [showPassword, setShowPassword] = useState(false);

    const handleClickShowPassword = () => {
        setShowPassword(!showPassword);
    };

    const handleMouseDownPassword = (event) => {
        event.preventDefault();
    };

    const changePassword = (value) => {
        const temp = strengthIndicator(value);
        setLevel(strengthColor(temp));
    };

    const showSuccess = (values) => {
        const msg = `Username : ${values.username} Password : ${values.password}`;

        toast.success(msg, {
            position: 'top-center',
            autoClose: false,
            hideProgressBar: false,
            closeOnClick: true,
            pauseOnHover: true,
            draggable: true,
            progress: undefined,
            theme: 'light'
        });
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
    //mobile number validation
    const phoneNoRegExp = /^((\\+[1-9]{1,4}[ \\-]*)|(\\([0-9]{2,3}\\)[ \\-]*)|([0-9]{2,4})[ \\-]*)*?[0-9]{3,4}?[ \\-]*[0-9]{3,4}?$/;
    const bloodGroupRegExp = /(A|B|AB|O)[+-]/;

    useEffect(() => {
        changePassword('');

        async function getData() {
            // console.log(res);
            firebase.initializeApp(config);

            //checks whether a user is successfully logged in or not
            firebase.auth().onAuthStateChanged((user) => {
                if (user) {
                    //if there is logged user already
                    //navigate to dashboard
                    navigate('/adduser');
                    // ...
                } else {
                    //if there is no logged user go to login
                    navigate('/login');
                }
            });
        }

        getData();
    }, []);

    return (
        <>
            <Formik
                initialValues={{
                    name: '',
                    post: '',
                    telNo: '',
                    email: '',
                    username: '',
                    bloodGroup: '',
                    password: '',
                    submit: null
                }}
                validationSchema={Yup.object().shape({
                    name: Yup.string().max(255).required('Name is required'),
                    username: Yup.string().max(255).required('Username is required'),
                    post: Yup.string().max(255).required('Post is required'),
                    telNo: Yup.string()
                        .matches(phoneNoRegExp, 'Please enter a valid Phone number')
                        .min(10, 'Too short')
                        .max(10, 'Too long')
                        .required('TelNo Number is required'),
                    bloodGroup: Yup.string()
                        .matches(bloodGroupRegExp, 'Please enter a valid Blood Group')
                        .min(2, 'Too short')
                        .max(3, 'Too long')
                        .required('Blood Group is required'),
                    email: Yup.string().email('Must be a valid email').max(255).required('Email is required'),
                    password: Yup.string().max(255).required('Password is required')
                })}
                onSubmit={async (values, { setErrors, setStatus, setSubmitting }) => {
                    try {
                        setStatus({ success: false });
                        setSubmitting(false);
                    } catch (err) {
                        console.error(err);
                        setStatus({ success: false });
                        setErrors({ submit: err.message });
                        setSubmitting(false);
                    }

                    // console.log(values);
                    try {
                        const res = await axios({
                            method: 'POST',
                            url: 'https://us-central1-smart-helmet-74616.cloudfunctions.net/appFunc/addUser',
                            data: values
                        });
                        console.log(res);
                        showSuccess(values);
                        navigate('/dashboard');
                    } catch (err) {
                        showError(err);
                    }
                }}
            >
                {({ errors, handleBlur, handleChange, handleSubmit, isSubmitting, touched, values }) => (
                    <form noValidate onSubmit={handleSubmit}>
                        <ToastContainer />
                        <Grid container spacing={3}>
                            <Grid item xs={12} md={12}>
                                <Stack spacing={1}>
                                    <InputLabel htmlFor="name-signup">Name*</InputLabel>
                                    <OutlinedInput
                                        id="name-login"
                                        type="name"
                                        value={values.name}
                                        name="name"
                                        onBlur={handleBlur}
                                        onChange={handleChange}
                                        placeholder="Ishan Maduranga"
                                        fullWidth
                                        error={Boolean(touched.name && errors.name)}
                                    />
                                    {touched.name && errors.name && (
                                        <FormHelperText error id="helper-text-name-signup">
                                            {errors.name}
                                        </FormHelperText>
                                    )}
                                </Stack>
                            </Grid>
                            {/* <Grid item xs={12} md={6}>
                                <Stack spacing={1}>
                                    <InputLabel htmlFor="lastname-signup">Last Name*</InputLabel>
                                    <OutlinedInput
                                        fullWidth
                                        error={Boolean(touched.lastname && errors.lastname)}
                                        id="lastname-signup"
                                        type="lastname"
                                        value={values.lastname}
                                        name="lastname"
                                        onBlur={handleBlur}
                                        onChange={handleChange}
                                        placeholder="Doe"
                                        inputProps={{}}
                                    />
                                    {touched.lastname && errors.lastname && (
                                        <FormHelperText error id="helper-text-lastname-signup">
                                            {errors.lastname}
                                        </FormHelperText>
                                    )}
                                </Stack>
                            </Grid> */}
                            <Grid item xs={12}>
                                <Stack spacing={1}>
                                    <InputLabel htmlFor="username-signup">Username*</InputLabel>
                                    <OutlinedInput
                                        fullWidth
                                        error={Boolean(touched.username && errors.username)}
                                        id="username-signup"
                                        value={values.username}
                                        name="username"
                                        onBlur={handleBlur}
                                        onChange={handleChange}
                                        placeholder="IshanMK"
                                        inputProps={{}}
                                    />
                                    {touched.username && errors.username && (
                                        <FormHelperText error id="helper-text-username-signup">
                                            {errors.username}
                                        </FormHelperText>
                                    )}
                                </Stack>
                            </Grid>
                            <Grid item xs={12}>
                                <Stack spacing={1}>
                                    <InputLabel htmlFor="email-signup">Email Address*</InputLabel>
                                    <OutlinedInput
                                        fullWidth
                                        error={Boolean(touched.email && errors.email)}
                                        id="email-login"
                                        type="email"
                                        value={values.email}
                                        name="email"
                                        onBlur={handleBlur}
                                        onChange={handleChange}
                                        placeholder="ishan@ishan.io"
                                        inputProps={{}}
                                    />
                                    {touched.email && errors.email && (
                                        <FormHelperText error id="helper-text-email-signup">
                                            {errors.email}
                                        </FormHelperText>
                                    )}
                                </Stack>
                            </Grid>
                            <Grid item xs={12}>
                                <Stack spacing={1}>
                                    <InputLabel htmlFor="post-signup">Post*</InputLabel>
                                    <OutlinedInput
                                        fullWidth
                                        error={Boolean(touched.post && errors.post)}
                                        id="post-login"
                                        type="post"
                                        value={values.post}
                                        name="post"
                                        onBlur={handleBlur}
                                        onChange={handleChange}
                                        placeholder="Labourer"
                                        inputProps={{}}
                                    />
                                    {touched.post && errors.post && (
                                        <FormHelperText error id="helper-text-post-signup">
                                            {errors.post}
                                        </FormHelperText>
                                    )}
                                </Stack>
                            </Grid>
                            <Grid item xs={12}>
                                <Stack spacing={1}>
                                    <InputLabel htmlFor="telNo-signup">Phone*</InputLabel>
                                    <OutlinedInput
                                        fullWidth
                                        error={Boolean(touched.telNo && errors.telNo)}
                                        id="telNo-login"
                                        type="telNo"
                                        value={values.telNo}
                                        name="telNo"
                                        onBlur={handleBlur}
                                        onChange={handleChange}
                                        placeholder="0767678678"
                                        inputProps={{}}
                                    />
                                    {touched.telNo && errors.telNo && (
                                        <FormHelperText error id="helper-text-telNo-signup">
                                            {errors.telNo}
                                        </FormHelperText>
                                    )}
                                </Stack>
                            </Grid>
                            <Grid item xs={12}>
                                <Stack spacing={1}>
                                    <InputLabel htmlFor="bloodGroup-signup">Blood Group*</InputLabel>
                                    <OutlinedInput
                                        fullWidth
                                        error={Boolean(touched.bloodGroup && errors.bloodGroup)}
                                        id="bloodGroup-login"
                                        type="bloodGroup"
                                        value={values.bloodGroup}
                                        name="bloodGroup"
                                        onBlur={handleBlur}
                                        onChange={handleChange}
                                        placeholder="A+"
                                        inputProps={{}}
                                    />
                                    {touched.bloodGroup && errors.bloodGroup && (
                                        <FormHelperText error id="helper-text-bloodGroup-signup">
                                            {errors.bloodGroup}
                                        </FormHelperText>
                                    )}
                                </Stack>
                            </Grid>
                            <Grid item xs={12}>
                                <Stack spacing={1}>
                                    <InputLabel htmlFor="password-signup">Password</InputLabel>
                                    <OutlinedInput
                                        fullWidth
                                        error={Boolean(touched.password && errors.password)}
                                        id="password-signup"
                                        type={showPassword ? 'text' : 'password'}
                                        value={values.password}
                                        name="password"
                                        onBlur={handleBlur}
                                        onChange={(e) => {
                                            handleChange(e);
                                            changePassword(e.target.value);
                                        }}
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
                                        placeholder="******"
                                        inputProps={{}}
                                    />
                                    {touched.password && errors.password && (
                                        <FormHelperText error id="helper-text-password-signup">
                                            {errors.password}
                                        </FormHelperText>
                                    )}
                                </Stack>
                                <FormControl fullWidth sx={{ mt: 2 }}>
                                    <Grid container spacing={2} alignItems="center">
                                        <Grid item>
                                            <Box sx={{ bgcolor: level?.color, width: 85, height: 8, borderRadius: '7px' }} />
                                        </Grid>
                                        <Grid item>
                                            <Typography variant="subtitle1" fontSize="0.75rem">
                                                {level?.label}
                                            </Typography>
                                        </Grid>
                                    </Grid>
                                </FormControl>
                            </Grid>

                            <Grid item xs={12}>
                                <Typography variant="body2">
                                    By Signing up, you agree to our &nbsp;
                                    <Link variant="subtitle2" component={RouterLink} to="#">
                                        Terms of Service
                                    </Link>
                                    &nbsp; and &nbsp;
                                    <Link variant="subtitle2" component={RouterLink} to="#">
                                        Privacy Policy
                                    </Link>
                                </Typography>
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
                                        Create Account
                                    </Button>
                                </AnimateButton>
                            </Grid>
                            {/* <Grid item xs={12}>
                                <Divider>
                                    <Typography variant="caption">Sign up with</Typography>
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

export default AuthRegister;
