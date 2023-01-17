import { lazy } from 'react';

// project import
import Loadable from 'components/Loadable';
import MainLayout from 'layout/MainLayout';

// render - dashboard
// const DashboardDefault = Loadable(lazy(() => import('pages/dashboard')));

// render - sample page
// const SamplePage = Loadable(lazy(() => import('pages/extra-pages/SamplePage')));

// render - utilities
// const Typography = Loadable(lazy(() => import('pages/components-overview/Typography')));
// const Color = Loadable(lazy(() => import('pages/components-overview/Color')));
// const Shadow = Loadable(lazy(() => import('pages/components-overview/Shadow')));
// const AntIcons = Loadable(lazy(() => import('pages/components-overview/AntIcons')));
const Users = Loadable(lazy(() => import('pages/components-overview/Users')));
const Map = Loadable(lazy(() => import('pages/components-overview/Map')));
const Statistics = Loadable(lazy(() => import('pages/components-overview/Statistics')));
const Settings = Loadable(lazy(() => import('pages/components-overview/Settings')));
const UserStats = Loadable(lazy(() => import('pages/components-overview/UserStats')));

// ==============================|| MAIN ROUTING ||============================== //

const MainRoutes = {
    path: '/',
    element: <MainLayout />,
    children: [
        {
            path: '/',
            element: <Map />
        },
        {
            path: '/',
            children: [
                {
                    path: 'dashboard/default',
                    element: <Map />
                }
            ]
        },
        {
            path: 'dashboard',
            element: <Map />
        },
        {
            path: 'statistics',
            element: <Statistics />
        },
        {
            path: 'users',
            element: <Users />
        },
        {
            path: 'settings',
            element: <Settings />
        },
        {
            path: 'userstats',
            element: <UserStats />
        }
    ]
};

export default MainRoutes;
