// import { users } from '../../__mocks__/users';
import { UserListResults } from '../../components/users/user_list_results';
// import { UserListToolBar } from '../../components/users/user-list-toolbar';
import ComponentSkeleton from './ComponentSkeleton';
import axios from 'axios';
import { useState, useEffect } from 'react';
import { Box, Button, Card, CardContent, TextField, InputAdornment, SvgIcon, Typography } from '@mui/material';
import { useNavigate } from 'react-router-dom';

import { Search as SearchIcon } from '../../assets/icons/search';

const ComponentUsers = () => {
    const navigate = useNavigate();

    const [state, setState] = useState({
        result: []
    });
    const handleClick = (e) => {
        navigate('/adduser');
    };
    useEffect(() => {
        async function getData() {
            try {
                const res = await axios({
                    method: 'GET',
                    url: 'https://us-central1-smart-helmet-74616.cloudfunctions.net/appFunc/getSensors'
                });

                // console.log(res.data);
                setState({ ...state, result: res.data });

                // console.log(state.result);
            } catch (err) {
                console.log(err.response);
            }
        }

        getData();
    }, []);

    return (
        <ComponentSkeleton>
            {/* <UserListToolBar /> */}
            <Box
                sx={{
                    alignItems: 'center',
                    display: 'flex',
                    justifyContent: 'space-between',
                    flexWrap: 'wrap',
                    m: -1
                }}
            >
                {/* <Typography sx={{ m: 1 }} variant="h4">
                Users
            </Typography> */}
                <Box sx={{ m: 1 }}>
                    <Button color="primary" variant="contained" onClick={handleClick}>
                        Add Users
                    </Button>
                </Box>
            </Box>
            <Box sx={{ mt: 3 }}>
                <Card>
                    <CardContent>
                        <Box sx={{ maxWidth: 500 }}>
                            <TextField
                                fullWidth
                                InputProps={{
                                    startAdornment: (
                                        <InputAdornment position="start">
                                            <SvgIcon color="action" fontSize="small">
                                                <SearchIcon />
                                            </SvgIcon>
                                        </InputAdornment>
                                    )
                                }}
                                placeholder="Search User"
                                variant="outlined"
                            />
                        </Box>
                    </CardContent>
                </Card>
            </Box>
            <Box sx={{ mt: 3 }}>
                <UserListResults customers={state.result} />
            </Box>
        </ComponentSkeleton>
    );
};

export default ComponentUsers;
