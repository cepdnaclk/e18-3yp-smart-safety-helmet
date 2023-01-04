// assets
import {
    AppstoreAddOutlined,
    AntDesignOutlined,
    BarcodeOutlined,
    BgColorsOutlined,
    FontSizeOutlined,
    LoadingOutlined,
    UserSwitchOutlined,
    StarOutlined,
    SettingOutlined
} from '@ant-design/icons';

// icons
const icons = {
    FontSizeOutlined,
    BgColorsOutlined,
    BarcodeOutlined,
    AntDesignOutlined,
    LoadingOutlined,
    AppstoreAddOutlined,
    UserSwitchOutlined,
    StarOutlined,
    SettingOutlined
};

// ==============================|| MENU ITEMS - UTILITIES ||============================== //

const utilities = {
    id: 'utilities',
    title: 'Utilities',
    type: 'group',
    children: [
        // {
        //     id: 'util-typography',
        //     title: 'Typography',
        //     type: 'item',
        //     url: '/typography',
        //     icon: icons.FontSizeOutlined
        // },
        // {
        //     id: 'util-color',
        //     title: 'Color',
        //     type: 'item',
        //     url: '/color',
        //     icon: icons.BgColorsOutlined
        // },
        // {
        //     id: 'util-shadow',
        //     title: 'Shadow',
        //     type: 'item',
        //     url: '/shadow',
        //     icon: icons.BarcodeOutlined
        // },
        // {
        //     id: 'ant-icons',
        //     title: 'Ant Icons',
        //     type: 'item',
        //     url: '/icons/ant',
        //     icon: icons.AntDesignOutlined,
        //     breadcrumbs: false
        // }
        {
            id: 'util-users',
            title: 'Users',
            type: 'item',
            url: '/users',
            icon: icons.UserSwitchOutlined
        },
        {
            id: 'util-statistics',
            title: 'Statistics',
            type: 'item',
            url: '/typography',
            icon: icons.StarOutlined
        },
        {
            id: 'util-settings',
            title: 'Settings',
            type: 'item',
            url: '/typography',
            icon: icons.SettingOutlined
        }
    ]
};

export default utilities;
