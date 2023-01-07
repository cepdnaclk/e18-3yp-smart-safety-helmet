import { useState, useEffect } from 'react';
import PerfectScrollbar from 'react-perfect-scrollbar';
import PropTypes from 'prop-types';
import { Avatar, Box, Card, Table, TableBody, TableCell, TableHead, TablePagination, TableRow, Typography } from '@mui/material';
import { getInitials } from '../../utils/get-initials';

//import assests
import { useNavigate } from 'react-router-dom';
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

export const UserListResults = ({ customers, ...rest }) => {
    // Navigator
    const navigate = useNavigate();

    const [selectedCustomerIds, setSelectedCustomerIds] = useState([]);
    const [limit, setLimit] = useState(10);
    const [page, setPage] = useState(0);

    const handleLimitChange = (event) => {
        setLimit(event.target.value);
    };

    const handlePageChange = (event, newPage) => {
        setPage(newPage);
    };

    useEffect(() => {
        async function getData() {
            //initialize the App
            firebase.initializeApp(firebaseConfig);

            //checks whether a user is successfully logged in or not
            firebase.auth().onAuthStateChanged((user) => {
                if (user) {
                    //if there is logged user already
                    //navigate to dashboard
                    navigate('/users');
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
        <Card {...rest}>
            <PerfectScrollbar>
                <Box sx={{ minWidth: 1050 }}>
                    <Table>
                        <TableHead>
                            <TableRow>
                                {/* <TableCell padding="checkbox">
                                    <Checkbox
                                        checked={selectedCustomerIds.length === customers.length}
                                        color="primary"
                                        indeterminate={selectedCustomerIds.length > 0 && selectedCustomerIds.length < customers.length}
                                        onChange={handleSelectAll}
                                    />
                                </TableCell> */}
                                <TableCell>Name</TableCell>
                                <TableCell>Working Time</TableCell>
                                <TableCell>Temperature</TableCell>
                                <TableCell>Noise</TableCell>
                                <TableCell>Vibration</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {customers.slice(0, limit).map((customer) => (
                                <TableRow hover key={customer.id} selected={selectedCustomerIds.indexOf(customer.id) !== -1}>
                                    {/* <TableCell padding="checkbox">
                                        <Checkbox
                                            checked={selectedCustomerIds.indexOf(customer.id) !== -1}
                                            onChange={(event) => handleSelectOne(event, customer.id)}
                                            value="true"
                                        />
                                    </TableCell> */}
                                    <TableCell>
                                        <Box
                                            sx={{
                                                alignItems: 'center',
                                                display: 'flex'
                                            }}
                                        >
                                            <Avatar src={customer.avatarUrl} sx={{ mr: 2 }}>
                                                {getInitials(customer.name)}
                                            </Avatar>
                                            <Typography color="textPrimary" variant="body1">
                                                {customer.name}
                                            </Typography>
                                        </Box>
                                    </TableCell>
                                    <TableCell>{customer.email}</TableCell>
                                    <TableCell>{customer.temperature}</TableCell>
                                    <TableCell>{customer.noise}</TableCell>
                                    <TableCell>{customer.vibration}</TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </Box>
            </PerfectScrollbar>
            <TablePagination
                component="div"
                count={customers.length}
                onPageChange={handlePageChange}
                onRowsPerPageChange={handleLimitChange}
                page={page}
                rowsPerPage={limit}
                rowsPerPageOptions={[5, 10, 25]}
            />
        </Card>
    );
};

UserListResults.propTypes = {
    customers: PropTypes.array.isRequired
};
