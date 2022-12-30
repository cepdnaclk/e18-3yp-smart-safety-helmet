import PropTypes from "prop-types";
import { Avatar, Box, Card, CardContent, Divider, Grid, Typography } from "@mui/material";
import { Clock as ClockIcon } from "../../icons/clock";
import { Download as DownloadIcon } from "../../icons/download";

export const ProductCard = ({ product, ...rest }) => (
  <Card
    sx={{
      display: "flex",
      flexDirection: "column",
      height: "100%",
    }}
    {...rest}
  >
    <CardContent>
      <Box
        sx={{
          display: "flex",
          justifyContent: "center",
          pb: 3,
        }}
      >
        <Avatar alt="Product" src={product.media} variant="square" />
      </Box>

      <Typography align="center" color="textPrimary" gutterBottom variant="h5" fontSize={25}>
        {product.title}
      </Typography>
      <Typography
        align="center"
        color="textPrimary"
        variant="h3"
        fontSize={20}
        fontStyle="italic"
        sx={{ color: "#00adb5" }}
      >
        {product.description}
      </Typography>
    </CardContent>
  </Card>
);

ProductCard.propTypes = {
  product: PropTypes.object.isRequired,
};
