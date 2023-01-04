import { Box } from '@mui/material';
import { users } from '../../__mocks__/users';
import { UserListResults } from '../../components/users/user_list_results';
import { UserListToolBar } from '../../components/users/user-list-toolbar';
import ComponentSkeleton from './ComponentSkeleton';

const ComponentUsers = () => (
    <ComponentSkeleton>
        <UserListToolBar />
        <Box sx={{ mt: 3 }}>
            <UserListResults customers={users} />
        </Box>
    </ComponentSkeleton>
);

export default ComponentUsers;
