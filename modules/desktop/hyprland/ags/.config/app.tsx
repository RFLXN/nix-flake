import app from "ags/gtk4/app";
import css from "./style.css";
import Layout from "./layout";

app.start({
  css,
  requestHandler(args, response) {
    const [target, action = "toggle"] = args;
    const closeLauncherConfirm = () => {
      const launcherConfirm = app.get_window("launcher-confirm");
      if (!launcherConfirm) return;
      launcherConfirm.visible = false;
    };

    if (target !== "launcher") {
      response(`unknown request target: ${target ?? "none"}`);
      return;
    }

    const launcher = app.get_window("launcher");
    if (!launcher) {
      response("launcher window is not ready");
      return;
    }

    if (action === "toggle") {
      closeLauncherConfirm();
      launcher.visible = !launcher.visible;
      response(launcher.visible ? "launcher:open" : "launcher:close");
      return;
    }

    if (action === "open") {
      closeLauncherConfirm();
      launcher.visible = true;
      response("launcher:open");
      return;
    }

    if (action === "close") {
      launcher.visible = false;
      closeLauncherConfirm();
      response("launcher:close");
      return;
    }

    response(`unknown launcher action: ${action}`);
  },
  main: Layout,
});
