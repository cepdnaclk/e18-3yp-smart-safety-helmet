import { Box } from '@mui/material';
// import { users } from '../../__mocks__/users';
import { UserListResults } from '../../components/users/user_list_results';
import { UserListToolBar } from '../../components/users/user-list-toolbar';
import ComponentSkeleton from './ComponentSkeleton';
import axios from 'axios';
import { useState, useEffect } from 'react';

const ComponentUsers = () => {
    const [state, setState] = useState({
        result: []
    });

    useEffect(() => {
        async function getData() {
            const res = await axios({
                method: 'GET',
                url: 'https://us-central1-smart-helmet-74616.cloudfunctions.net/appFunc/getSensors'
            });

            // console.log(res.data);
            setState({ ...state, result: res.data });

            // console.log(state.result);
        }

        getData();
    }, []);

    return (
        <ComponentSkeleton>
            <UserListToolBar />
            <Box sx={{ mt: 3 }}>
                <UserListResults customers={state.result} />
            </Box>
        </ComponentSkeleton>
    );
};

export default ComponentUsers;
