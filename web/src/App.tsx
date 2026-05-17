import React, { useCallback, useMemo } from "react";
import { Box, Text, Tooltip, createStyles, Transition } from "@mantine/core";
import {
	TbX, TbUser, TbMoodSmile, TbBrush, TbWriting, TbPalette, TbWalk,
	TbDeviceWatch, TbShirt, TbSunglasses, TbHanger, TbDoorEnter,
	TbBookmark, TbCamera,
} from "react-icons/tb";
import { Routes, Route, Navigate, useNavigate, useLocation } from "react-router-dom";
import { useNuiEvent } from "./hooks/useNuiEvent";
import { useVisibility } from "./store/visibility";
import { useAppearance } from "./store/appearance";
import { usePresets } from "./store/presets";
import { useOutfits } from "./store/outfits";
import { useConfig, ConfigState } from "./store/config";
import { useLocale } from "./store/locale";
import { useMaxValues } from "./store/maxValues";
import { useCamera } from "./store/camera";
import { useExitListener } from "./hooks/useExitListener";
import { fetchNui } from "./utils/fetchNui";

import FloatingCategoryRail, { RailItem } from "./components/FloatingCategoryRail";
import ActionBar from "./components/ActionBar";
import Face from "./layouts/face";
import Hair from "./layouts/hair";
import Clothing from "./layouts/clothing";
import Props from "./layouts/props";
import Tattoos from "./layouts/tattoos";
import Colors from "./layouts/colors";
import Presets from "./layouts/presets";
import Outfits from "./layouts/outfits";
import Camera from "./layouts/camera";
import Animations from "./layouts/animations";
import Ped from "./layouts/ped";
import WalkStyle from "./layouts/walkstyle";
import Accessories from "./layouts/accessories";
import History from "./layouts/history";
import Wardrobe from "./layouts/wardrobe";

import type { AppearanceData, AppearancePreset } from "./types";
import type { Outfit } from "./types/outfit";

const useStyles = createStyles((theme) => ({
	container: {
		width: "100%",
		height: "100dvh",
		minHeight: "100vh",
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		padding: "clamp(24px, 5vh, 72px) clamp(16px, 1.6vw, 32px)",
		boxSizing: "border-box" as const,
		overflow: "hidden",
	},
	main: {
		position: "fixed",
		top: "clamp(24px, 5vh, 72px)",
		bottom: "clamp(24px, 5vh, 72px)",
		right: "clamp(16px, 1.6vw, 32px)",
		width: "clamp(390px, 27vw, 560px)",
		maxWidth: "calc(100vw - 32px)",
		backgroundColor: theme.colors.dark[8],
		display: "flex",
		overflow: "hidden",
		border: `1px solid ${theme.colors.dark[5]}`,
		borderRadius: theme.radius.md,
		boxShadow:
			"0 24px 60px rgba(0, 0, 0, 0.45), 0 2px 8px rgba(0, 0, 0, 0.25)",
		willChange: "transform, opacity",
		["@media (max-width: 420px)"]: {
			top: 0,
			bottom: 0,
			right: 0,
			width: "100vw",
			maxWidth: "100vw",
			borderRadius: 0,
		},
	},
	content: {
		flex: 1,
		minWidth: 0,
		overflow: "hidden",
		display: "flex",
		flexDirection: "column",
	},
	viewport: {
		flex: 1,
		height: "100%",
		cursor: "grab",
		"&:active": {
			cursor: "grabbing",
		},
	},
	topbar: {
		display: "flex",
		alignItems: "center",
		justifyContent: "space-between",
		gap: "clamp(8px, 0.7vw, 14px)",
		padding: "clamp(8px, 0.55vw, 12px) clamp(14px, 1vw, 20px)",
		borderBottom: `1px solid ${theme.colors.dark[5]}`,
		backgroundColor: theme.colors.dark[7],
		minWidth: 0,
	},
	topbarLeft: {
		display: "flex",
		alignItems: "center",
		gap: "clamp(8px, 0.7vw, 14px)",
		minWidth: 0,
		flex: 1,
	},
	crumb: {
		display: "inline-flex",
		alignItems: "center",
		gap: 6,
		padding: "clamp(3px, 0.25vw, 5px) clamp(8px, 0.55vw, 12px)",
		borderRadius: theme.radius.sm,
		backgroundColor: theme.colors.dark[6],
		border: `1px solid ${theme.colors.dark[5]}`,
		fontSize: "clamp(10px, 0.55vw, 12px)",
		fontWeight: 600,
		color: theme.colors.dark[1],
		letterSpacing: "0.04em",
		minWidth: 0,
		overflow: "hidden",
		whiteSpace: "nowrap" as const,
		textOverflow: "ellipsis",
	},
	iconBtn: {
		width: "clamp(22px, 1.3vw, 30px)",
		height: "clamp(22px, 1.3vw, 30px)",
		borderRadius: theme.radius.sm,
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		cursor: "pointer",
		color: theme.colors.dark[2],
		background: "transparent",
		border: "none",
		transition: "background-color 120ms, color 120ms",
		"&:hover": {
			backgroundColor: theme.colors.dark[6],
			color: theme.white,
		},
	},
}));

const tabRoutes: Record<string, string> = {
	ped: "/ped",
	face: "/face",
	hair: "/hair",
	clothing: "/clothing",
	props: "/props",
	tattoos: "/tattoos",
	colors: "/colors",
	presets: "/presets",
	outfits: "/outfits",
	camera: "/camera",
	animations: "/animations",
	walkstyle: "/walkstyle",
	accessories: "/accessories",
	history: "/history",
	wardrobe: "/wardrobe",
};

const DefaultRedirect: React.FC = () => {
	const allowedTabs = useConfig((s) => s.allowedTabs);
	const firstTab = allowedTabs?.[0];
	const target = firstTab ? (tabRoutes[firstTab] || "/ped") : "/ped";

	return <Navigate to={target} replace />;
};

const App: React.FC = () => {
	const { classes } = useStyles();

	const [visible, setVisible] = useVisibility((state) => [state.visible, state.setVisible]);

	const setOriginal = useAppearance((s) => s.setOriginal);
	const setAppearanceData = useAppearance((s) => s.setAppearance);
	const setPresets = usePresets((s) => s.setPresets);
	const setOutfits = useOutfits((s) => s.setOutfits);
	const setConfig = useConfig((s) => s.setConfig);
	const setAllowedTabs = useConfig((s) => s.setAllowedTabs);
	const setShopType = useConfig((s) => s.setShopType);
	const setPedMenuActive = useConfig((s) => s.setPedMenuActive);
	const setLocaleStrings = useLocale((s) => s.setStrings);
	const setLocaleName = useLocale((s) => s.setLocale);
	const setMaxValues = useMaxValues((s) => s.setMaxValues);
	const updateTextureMax = useMaxValues((s) => s.updateTextureMax);
	const setCameraPreset = useCamera((s) => s.setPreset);
	const setCameraLighting = useCamera((s) => s.setLighting);
	const setCameraFov = useCamera((s) => s.setFov);
	const setCameraZoom = useCamera((s) => s.setZoom);
	const setCameraRotation = useCamera((s) => s.setRotation);

	const navigate = useNavigate();

	useNuiEvent("setConfig", (data: Partial<ConfigState> & { localeStrings?: Record<string, string> }) => {
		if (data.localeStrings) {
			setLocaleStrings(data.localeStrings);
			delete data.localeStrings;
		}
		if (data.locale) {
			setLocaleName(data.locale);
		}
		if (data.cameraDefaults) {
			setCameraPreset(data.cameraDefaults.preset);
			setCameraLighting(data.cameraDefaults.lighting);
			setCameraFov(data.cameraDefaults.fov);
			setCameraZoom(data.cameraDefaults.zoom);
			setCameraRotation(data.cameraDefaults.rotation);
		}
		setConfig(data);
	});

	useNuiEvent("setVisible", (data?: { visible: boolean; route?: string }) => {
		if (data?.visible !== undefined) setVisible(data.visible);
		if (!data?.visible) {
			setAllowedTabs(null);
			setPedMenuActive(false);
		}
		if (data?.route) navigate(data.route);
	});

	useNuiEvent("setAppearance", (data: AppearanceData) => {
		setOriginal(data);
	});

	useNuiEvent("updateModelAppearance", (data: AppearanceData) => {
		setAppearanceData(data);
	});

	useNuiEvent("setPresets", (data: AppearancePreset[]) => {
		setPresets(data);
	});

	useNuiEvent("setOutfits", (data: Outfit[]) => {
		setOutfits(data);
	});

	useNuiEvent("setMaxValues", (data: any) => {
		setMaxValues(data);
	});

	useNuiEvent("updateTextureMax", (data: { type: "component" | "prop"; id: number; maxTexture: number }) => {
		updateTextureMax(data.type, data.id, data.maxTexture);
	});

	useNuiEvent("setShopType", (data: { shopType: string | null }) => {
		setShopType(data.shopType ?? null);
	});

	useNuiEvent("setPedMenuActive", (data?: { active?: boolean }) => {
		setPedMenuActive(data?.active === true);
	});

	useNuiEvent("setAllowedTabs", (data: { tabs: string[] }) => {
		setAllowedTabs(data.tabs);

		if (data.tabs && data.tabs.length > 0) {
			navigate(tabRoutes[data.tabs[0]] || "/ped");
		}
	});

	useExitListener(setVisible, () => { });

	const location = useLocation();
	const allowedTabs = useConfig((s) => s.allowedTabs);

	const { leftRail, rightRail } = useMemo(() => {
		const all: (RailItem & { rail: "left" | "right" })[] = [
			{ rail: "left",  tabKey: "ped",         label: "Ped",         path: "/ped",         icon: <TbUser /> },
			{ rail: "left",  tabKey: "face",        label: "Face",        path: "/face",        icon: <TbMoodSmile /> },
			{ rail: "left",  tabKey: "hair",        label: "Hair",        path: "/hair",        icon: <TbBrush /> },
			{ rail: "left",  tabKey: "tattoos",     label: "Tattoos",     path: "/tattoos",     icon: <TbWriting /> },
			{ rail: "left",  tabKey: "colors",      label: "Colors",      path: "/colors",      icon: <TbPalette /> },
			{ rail: "left",  tabKey: "walkstyle",   label: "Walk",        path: "/walkstyle",   icon: <TbWalk /> },
			{ rail: "left",  tabKey: "accessories", label: "Accessories", path: "/accessories", icon: <TbDeviceWatch /> },
			{ rail: "right", tabKey: "clothing",    label: "Clothing",    path: "/clothing",    icon: <TbShirt /> },
			{ rail: "right", tabKey: "props",       label: "Props",       path: "/props",       icon: <TbSunglasses /> },
			{ rail: "right", tabKey: "outfits",     label: "Outfits",     path: "/outfits",     icon: <TbHanger /> },
			{ rail: "right", tabKey: "wardrobe",    label: "Wardrobe",    path: "/wardrobe",    icon: <TbDoorEnter /> },
			{ rail: "right", tabKey: "presets",     label: "Presets",     path: "/presets",     icon: <TbBookmark /> },
			{ rail: "right", tabKey: "camera",      label: "Camera",      path: "/camera",      icon: <TbCamera /> },
		];
		const filtered = allowedTabs
			? all.filter((i) => allowedTabs.includes(i.tabKey))
			: all;
		return {
			leftRail:  filtered.filter((i) => i.rail === "left"),
			rightRail: filtered.filter((i) => i.rail === "right"),
		};
	}, [allowedTabs]);

	const onPickCategory = useCallback((path: string) => {
		navigate(path);
	}, [navigate]);

	return (
		<Box className={classes.container}>
			<Transition transition="fade" duration={180} mounted={visible}>
				{(style) => (
					<Box style={style}>

						<FloatingCategoryRail
							side="left"
							offset="calc(50vw - clamp(180px, 14vw, 260px))"
							items={leftRail}
							activePath={location.pathname}
							onPick={onPickCategory}
						/>
						<FloatingCategoryRail
							side="right"
							offset="calc(50vw - clamp(180px, 14vw, 260px))"
							items={rightRail}
							activePath={location.pathname}
							onPick={onPickCategory}
						/>
					</Box>
				)}
			</Transition>

			<Transition transition="slide-left" duration={260} mounted={visible}>
				{(style) => (
					<Box className={classes.main} style={style} id="appearance-panel">
						<Box className={classes.content}>
							<TopBar
								onClose={() => setVisible(false)}
								classes={classes}
							/>
							<Box sx={{ flex: 1, minHeight: 0, display: "flex", flexDirection: "column" }}>
								<Routes>
									<Route path="/ped" element={<Ped />} />
									<Route path="/face" element={<Face />} />
									<Route path="/hair" element={<Hair />} />
									<Route path="/clothing" element={<Clothing />} />
									<Route path="/props" element={<Props />} />
									<Route path="/tattoos" element={<Tattoos />} />
									<Route path="/colors" element={<Colors />} />
									<Route path="/presets" element={<Presets />} />
									<Route path="/outfits" element={<Outfits />} />
									<Route path="/camera" element={<Camera />} />
									<Route path="/animations" element={<Animations />} />
									<Route path="/walkstyle" element={<WalkStyle />} />
									<Route path="/accessories" element={<Accessories />} />
									<Route path="/history" element={<History />} />
									<Route path="/wardrobe" element={<Wardrobe />} />
									<Route path="/" element={<DefaultRedirect />} />
								</Routes>
							</Box>

							<ActionBar
								onSavePreset={() => navigate("/presets")}
								onSaveOutfit={() => navigate("/outfits")}
							/>
						</Box>
					</Box>
				)}
			</Transition>
		</Box>
	);
};

export default App;

const ROUTE_CRUMB: Record<string, string> = {
	"/ped":         "Appearance · Ped",
	"/face":        "Appearance · Face",
	"/hair":        "Appearance · Hair",
	"/clothing":    "Appearance · Clothing",
	"/props":       "Appearance · Props",
	"/tattoos":     "Appearance · Tattoos",
	"/colors":      "Appearance · Colors",
	"/presets":     "Appearance · Presets",
	"/outfits":     "Appearance · Outfits",
	"/camera":      "Appearance · Camera",
	"/animations":  "Appearance · Animations",
	"/walkstyle":   "Appearance · Walk style",
	"/accessories": "Appearance · Accessories",
	"/history":     "Appearance · History",
	"/wardrobe":    "Appearance · Wardrobe",
};

interface TopBarProps {
	classes: Record<"topbar" | "topbarLeft" | "crumb" | "iconBtn", string>;
	onClose: () => void;
}

const TopBar: React.FC<TopBarProps> = ({ classes, onClose }) => {
	const location = useLocation();
	const label = ROUTE_CRUMB[location.pathname] ?? "Appearance";
	return (
		<Box className={classes.topbar}>
			<Box className={classes.topbarLeft}>
				<Box className={classes.crumb} aria-label="Current section">
					{label}
				</Box>
			</Box>
			<Tooltip label="Close (Esc)" withinPortal position="bottom" transition="pop">
				<button className={classes.iconBtn} onClick={onClose} aria-label="Close">
					<TbX />
				</button>
			</Tooltip>
		</Box>
	);
};
