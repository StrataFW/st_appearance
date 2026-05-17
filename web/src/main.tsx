import React, { useMemo, useEffect } from "react";
import ReactDOM from "react-dom";

import { debugData } from "./utils/debugData";
import { MantineProvider } from "@mantine/core";
import { customTheme } from "./theme";
import { isEnvBrowser } from "./utils/misc";
import { fetchNui } from "./utils/fetchNui";
import { HashRouter } from "react-router-dom";
import { ModalsProvider } from "@mantine/modals";
import { useConfig } from "./store/config";
import { useLocale } from "./store/locale";
import { resolveAccentColor } from "./utils/accentColor";

import enLocale from "../../locales/en.json";

import App from "./App";
import "./index.css";

const flattenLocale = (
  tbl: Record<string, unknown>,
  prefix = "",
  out: Record<string, string> = {}
): Record<string, string> => {
  for (const [k, v] of Object.entries(tbl)) {
    const key = prefix ? `${prefix}.${k}` : k;
    if (v && typeof v === "object" && !Array.isArray(v)) {
      flattenLocale(v as Record<string, unknown>, key, out);
    } else if (typeof v === "string") {
      out[key] = v;
    }
  }
  return out;
};

debugData([
  {
    action: "setVisible",
    data: { visible: true },
  },
]);

if (isEnvBrowser()) {
  const root = document.getElementById("root");
  root!.style.backgroundImage = "url('https://i.imgur.com/3pzRj9n.png')";
  root!.style.backgroundSize = "cover";
  root!.style.backgroundRepeat = "no-repeat";
  root!.style.backgroundPosition = "center";
} else {
  fetchNui("ready", {});
}

const DevLocaleLoader: React.FC = () => {
  const setLocaleStrings = useLocale((s) => s.setStrings);

  useEffect(() => {
    setLocaleStrings(flattenLocale(enLocale as Record<string, unknown>));
  }, [setLocaleStrings]);

  return null;
};

const Root: React.FC = () => {
  const accentColor = useConfig((s) => s.accentColor);

  const theme = useMemo(() => {
    const { primaryColor, colors } = resolveAccentColor(accentColor);
    return {
      ...customTheme,
      primaryColor,
      ...(colors ? { colors: { ...customTheme.colors, ...colors } } : {}),
    };
  }, [accentColor]);

  return (
    <MantineProvider withNormalizeCSS theme={theme}>
      <ModalsProvider modalProps={{ transition: "slide-up", withinPortal: false }}>
        <HashRouter>
          <App />
          {isEnvBrowser() && <DevLocaleLoader />}
        </HashRouter>
      </ModalsProvider>
    </MantineProvider>
  );
};

ReactDOM.render(
  <React.StrictMode>
    <Root />
  </React.StrictMode>,
  document.getElementById("root")
);
