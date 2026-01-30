import { apiInitializer } from "discourse/lib/api";
import UserColorPaletteSelector from "../components/user-color-palette-selector";

export default apiInitializer((api) => {
  api.renderInOutlet("sidebar-footer-actions", UserColorPaletteSelector);
});
