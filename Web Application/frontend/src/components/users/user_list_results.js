import { useState } from 'react';
import PerfectScrollbar from 'react-perfect-scrollbar';
import PropTypes from 'prop-types';
import { Avatar, Box, Card, Table, TableBody, TableCell, TableHead, TablePagination, TableRow, Typography } from '@mui/material';
import { getInitials } from '../../utils/get-initials';

export const UserListResults = ({ customers, ...rest }) => {
    const [selectedCustomerIds, setSelectedCustomerIds] = useState([]);
    const [limit, setLimit] = useState(10);
    const [page, setPage] = useState(0);

    const handleLimitChange = (event) => {
        setLimit(event.target.value);
    };

    const handlePageChange = (event, newPage) => {
        setPage(newPage);
    };

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
