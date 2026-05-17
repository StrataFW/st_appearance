import React from "react";
import {
	Box, Group, Text, Slider, NumberInput, ActionIcon, Select,
	UnstyledButton, createStyles, ColorSwatch as MantineColorSwatch,
} from "@mantine/core";
import { TbEye, TbEyeOff, TbChevronUp, TbChevronDown, TbSettings, TbMinus, TbPlus } from "react-icons/tb";

const useSliderStyles = createStyles((theme) => ({
	root: {
		display: "flex",
		alignItems: "center",
		gap: "clamp(6px, 0.45vw, 10px)",
		padding: "clamp(5px, 0.4vw, 8px) 0",
		overflow: "visible",
		["@media (max-width: 430px)"]: {
			alignItems: "stretch",
			flexWrap: "wrap" as const,
			gap: 6,
		},
	},
	label: {
		fontSize: "clamp(11px, 0.55vw, 13px)",
		color: theme.colors.dark[1],
		width: "clamp(70px, 22%, 112px)",
		flexShrink: 0,
		whiteSpace: "nowrap" as const,
		overflow: "hidden",
		textOverflow: "ellipsis",
		["@media (max-width: 430px)"]: {
			width: "100%",
		},
	},
	slider: {
		flex: 1,
		minWidth: 120,
		overflow: "visible",
		"& .mantine-Slider-root": {
			overflow: "visible",
		},
		"& .mantine-Slider-label": {
			maxWidth: "none",
			whiteSpace: "nowrap" as const,
			zIndex: 30,
			pointerEvents: "none" as const,
		},
		["@media (max-width: 430px)"]: {
			flexBasis: "100%",
			minWidth: "100%",
		},
	},
	stepBtn: {
		flexShrink: 0,
		color: theme.colors.dark[1],
		"& svg": {
			width: "clamp(10px, 0.58vw, 14px)",
			height: "clamp(10px, 0.58vw, 14px)",
		},
		"&:hover": { color: theme.white, backgroundColor: theme.colors.dark[6] },
	},
	tail: {
		fontSize: "clamp(10px, 0.5vw, 12px)",
		color: theme.colors.dark[2],
		width: "clamp(34px, 8%, 52px)",
		flexShrink: 0,
		textAlign: "right" as const,
		whiteSpace: "nowrap" as const,
	},
}));

interface ValueSliderProps {
	label: string;
	value: number;
	onChange: (value: number) => void;
	min?: number;
	max?: number;
	step?: number;
	precision?: number;
}

export const ValueSlider: React.FC<ValueSliderProps> = ({
	label, value, onChange, min = -1, max = 1, step = 0.01, precision = 2,
}) => {
	const { classes } = useSliderStyles();
	return (
		<Box className={classes.root}>
			<Text className={classes.label}>{label}</Text>
			<Slider
				className={classes.slider}
				value={value}
				onChange={onChange}
				min={min}
				max={max}
				step={step}
				size="xs"
				label={(v) => v.toFixed(precision)}
			/>
			<ActionIcon size="xs" className={classes.stepBtn} onClick={() => onChange(Math.max(min, value - step))}>
				<TbMinus size={10} />
			</ActionIcon>
			<ActionIcon size="xs" className={classes.stepBtn} onClick={() => onChange(Math.min(max, value + step))}>
				<TbPlus size={10} />
			</ActionIcon>
			<NumberInput
				value={value}
				onChange={(v) => v !== undefined && onChange(Math.max(min, Math.min(max, v)))}
				min={min}
				max={max}
				step={step}
				precision={precision}
				size="xs"
				hideControls
				styles={{ input: { textAlign: "center", paddingLeft: 6, paddingRight: 6 } }}
				sx={{ width: "clamp(58px, 12%, 76px)", flexShrink: 0 }}
			/>
			<Box className={classes.tail} />
		</Box>
	);
};

interface IndexSelectorProps {
	label: string;
	value: number;
	onChange: (value: number) => void;
	max: number;
	min?: number;
}

export const IndexSelector: React.FC<IndexSelectorProps> = ({ label, value, onChange, max, min = 0 }) => {
	const { classes } = useSliderStyles();
	return (
		<Box className={classes.root}>
			<Text className={classes.label}>{label}</Text>
			<Slider
				className={classes.slider}
				value={value}
				onChange={(v) => onChange(Math.round(v))}
				min={min}
				max={max}
				step={1}
				size="xs"
				label={(v) => String(Math.round(v))}
			/>
			<ActionIcon size="xs" className={classes.stepBtn} onClick={() => onChange(Math.max(min, value - 1))}>
				<TbMinus size={10} />
			</ActionIcon>
			<ActionIcon size="xs" className={classes.stepBtn} onClick={() => onChange(Math.min(max, value + 1))}>
				<TbPlus size={10} />
			</ActionIcon>
			<NumberInput
				value={value}
				onChange={(v) => v !== undefined && onChange(Math.max(min, Math.min(max, v)))}
				min={min}
				max={max}
				step={1}
				size="xs"
				hideControls
				styles={{ input: { textAlign: "center", paddingLeft: 6, paddingRight: 6 } }}
				sx={{ width: "clamp(58px, 12%, 76px)", flexShrink: 0 }}
			/>
			<Text className={classes.tail}>/ {String(max).padStart(3, "0")}</Text>
		</Box>
	);
};

interface DropdownSelectorProps {
	label: string;
	value: string;
	onChange: (value: string) => void;
	data: { value: string; label: string }[];
}

export const DropdownSelector: React.FC<DropdownSelectorProps> = ({ label, value, onChange, data }) => (
	<Group spacing={8} noWrap sx={{ padding: "4px 0" }}>
		<Text 
			size="xs" 
			color="dimmed" 
			sx={{ 
				minWidth: 60,
				maxWidth: 70, 
				overflow: "hidden", 
				textOverflow: "ellipsis", 
				whiteSpace: "nowrap" 
			}}
		>
			{label}
		</Text>
		<Select
			size="xs"
			value={value}
			onChange={(v) => v && onChange(v)}
			data={data}
			searchable
			sx={{ flex: 1 }}
		/>
	</Group>
);

const useLayerStyles = createStyles((theme) => ({
	layer: {
		display: "flex",
		alignItems: "center",
		padding: "6px 10px",
		gap: 8,
		backgroundColor: theme.colors.dark[7],
		borderRadius: theme.radius.sm,
		cursor: "grab",
		"&:hover": { backgroundColor: theme.colors.dark[6] },
	},
	layerHidden: {
		opacity: 0.5,
	},
}));

interface LayerItemProps {
	label: string;
	visible: boolean;
	onToggleVisibility: () => void;
	onMoveUp: () => void;
	onMoveDown: () => void;
	onSettings: () => void;
	isFirst: boolean;
	isLast: boolean;
}

export const LayerItem: React.FC<LayerItemProps> = ({
	label, visible, onToggleVisibility, onMoveUp, onMoveDown, onSettings, isFirst, isLast,
}) => {
	const { classes, cx } = useLayerStyles();
	return (
		<Box className={cx(classes.layer, !visible && classes.layerHidden)}>
			<ActionIcon size="xs" variant="subtle" onClick={onToggleVisibility}>
				{visible ? <TbEye size={14} /> : <TbEyeOff size={14} />}
			</ActionIcon>
			<Text size="xs" sx={{ flex: 1 }}>{label}</Text>
			<ActionIcon size="xs" variant="subtle" onClick={onMoveUp} disabled={isFirst}>
				<TbChevronUp size={12} />
			</ActionIcon>
			<ActionIcon size="xs" variant="subtle" onClick={onMoveDown} disabled={isLast}>
				<TbChevronDown size={12} />
			</ActionIcon>
			<ActionIcon size="xs" variant="subtle" onClick={onSettings}>
				<TbSettings size={12} />
			</ActionIcon>
		</Box>
	);
};

const useSwatchStyles = createStyles((theme) => ({
	swatch: {
		cursor: "pointer",
		borderRadius: theme.radius.sm,
		border: `2px solid transparent`,
		transition: "border-color 150ms",
		"&:hover": { borderColor: theme.colors[theme.primaryColor][5] },
	},
	active: {
		borderColor: theme.colors[theme.primaryColor][5],
	},
}));

interface ColorSwatchBtnProps {
	color: string;
	active?: boolean;
	onClick: () => void;
	size?: number;
}

export const ColorSwatchBtn: React.FC<ColorSwatchBtnProps> = ({ color, active, onClick, size = 24 }) => {
	const { classes, cx } = useSwatchStyles();
	return (
		<UnstyledButton onClick={onClick} className={cx(classes.swatch, active && classes.active)}>
			<MantineColorSwatch color={color} size={size} />
		</UnstyledButton>
	);
};

export const SectionHeader: React.FC<{ children: React.ReactNode }> = ({ children }) => (
	<Text
		sx={(theme) => ({
			fontSize: "clamp(11px, 0.6vw, 13px)",
			color: theme.colors.dark[2],
			letterSpacing: "0.1em",
			textTransform: "uppercase",
			fontWeight: 700,
			paddingBottom: 6,
			borderBottom: `1px solid ${theme.colors.dark[5]}`,
			marginBottom: 4,
		})}
	>
		{children}
	</Text>
);

const usePanelStyles = createStyles((theme) => ({
	panel: {
		backgroundColor: theme.colors.dark[7],
		border: `1px solid ${theme.colors.dark[5]}`,
		borderRadius: theme.radius.sm,
		padding: "clamp(10px, 0.7vw, 14px) clamp(12px, 0.85vw, 16px)",
		overflow: "visible",
	},
}));

export const PanelCard: React.FC<{ children: React.ReactNode; sx?: any }> = ({ children, sx }) => {
	const { classes } = usePanelStyles();
	return <Box className={classes.panel} sx={sx}>{children}</Box>;
};

const usePageShellStyles = createStyles((theme) => ({
	shell: {
		flex: 1,
		minHeight: 0,
		display: "flex",
		flexDirection: "column",
		padding: "clamp(14px, 1.1vw, 22px) clamp(16px, 1.3vw, 26px)",
		gap: "clamp(10px, 0.7vw, 16px)",
	},
	header: {
		display: "flex",
		alignItems: "flex-start",
		justifyContent: "space-between",
		gap: "clamp(8px, 0.6vw, 14px)",
		paddingBottom: "clamp(8px, 0.55vw, 12px)",
		borderBottom: `1px solid ${theme.colors.dark[5]}`,
	},
	title: {
		fontSize: "clamp(15px, 0.95vw, 19px)",
		fontWeight: 700,
		letterSpacing: "0.02em",
		color: theme.white,
		lineHeight: 1.2,
	},
	subtitle: {
		fontSize: "clamp(11px, 0.6vw, 13px)",
		color: theme.colors.dark[2],
		marginTop: 2,
	},
	body: {
		flex: 1,
		minHeight: 0,
		overflowY: "auto" as const,
		paddingRight: 2,
		paddingBottom: "clamp(8px, 0.6vw, 14px)",
		display: "flex",
		flexDirection: "column",
		gap: "clamp(8px, 0.5vw, 12px)",
	},
}));

interface PageShellProps {
	title: React.ReactNode;
	subtitle?: React.ReactNode;

	actions?: React.ReactNode;
	children: React.ReactNode;
}

export const PageShell: React.FC<PageShellProps> = ({ title, subtitle, actions, children }) => {
	const { classes } = usePageShellStyles();
	return (
		<Box className={classes.shell}>
			<Box className={classes.header}>
				<Box sx={{ minWidth: 0 }}>
					<Text className={classes.title}>{title}</Text>
					{subtitle && <Text className={classes.subtitle}>{subtitle}</Text>}
				</Box>
				{actions && <Box sx={{ flexShrink: 0 }}>{actions}</Box>}
			</Box>
			<Box className={classes.body}>{children}</Box>
		</Box>
	);
};
