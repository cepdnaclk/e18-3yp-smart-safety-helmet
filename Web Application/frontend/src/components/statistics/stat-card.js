import PropTypes from 'prop-types';
import { Avatar, Box, Card, CardContent, Typography } from '@mui/material';

export const StatCard = ({ stat, ...rest }) => (
    <Card
        sx={{
            display: 'flex',
            flexDirection: 'column',
            height: '100%'
        }}
        {...rest}
    >
        <CardContent>
            <Box
                sx={{
                    display: 'flex',
                    justifyContent: 'center',
                    pb: 3
                }}
            >
                <Avatar src={`/statistics/${stat.Title}.svg`} variant="square" />
            </Box>

            <Typography align="center" color="textPrimary" gutterBottom variant="h5" fontSize={25}>
                {stat.Title}
            </Typography>
            <Typography align="center" color="textPrimary" variant="h3" fontSize={20} fontStyle="italic" sx={{ color: '#0000FF' }}>
                {stat.value}
            </Typography>
        </CardContent>
    </Card>
);

StatCard.propTypes = {
    stat: PropTypes.object.isRequired
};
