import React from "react";

import { Box, Button, Group, UnstyledButton, Text, Tooltip, createStyles } from "@mantine/core";
import { TbCheck, TbArrowBack, TbBookmark, TbHanger } from "react-icons/tb";
import { useAppearance } from "../store/appearance";
import { useConfig } from "../store/config";
import { useHistory } from "../store/history";
import { useLocale } from "../store/locale";
import { fetchNui } from "../utils/fetchNui";

import CostTracker from "./CostTracker";

const useStyles = createStyles((theme) => ({
	bar: {
		borderTop: `1px solid ${theme.colors.dark[5]}`,
		padding: "clamp(8px, 0.5vw, 12px)",
		display: "flex",
		flexDirection: "column",
		gap: "clamp(8px, 0.5vw, 12px)",
	},
	quickSlots: {
		display: "flex",
		gap: "clamp(4px, 0.3vw, 7px)",
	},
	slot: {
		flex: 1,
		padding: "clamp(6px, 0.4vw, 9px) 4px",
		backgroundColor: theme.colors.dark[7],
		borderRadius: theme.radius.sm,
		textAlign: "center",
		fontSize: "clamp(10px, 0.5vw, 12px)",
		color: theme.colors.dark[1],
		transition: "background-color 150ms",
		"&:hover": {
			backgroundColor: theme.colors.dark[6],
			color: theme.white,
		},
	},
	actions: {
		display: "flex",
		gap: "clamp(4px, 0.3vw, 7px)",
	},
	actionBtn: {
		flex: 1,
		minWidth: 90,
		fontWeight: 600,
		maxWidth: '100%',
	},
}));

interface ActionBarProps {
	onSavePreset: () => void;
	onSaveOutfit?: () => void;
}

const ActionBar: React.FC<ActionBarProps> = ({ onSavePreset, onSaveOutfit }) => {
	const { classes } = useStyles();

	const t = useLocale((s) => s.t);

	const quickSlots = useConfig((s) => s.quickSlots);
	const allowedTabs = useConfig((s) => s.allowedTabs);
	const dirty = useAppearance((s) => s.dirty);
	const revert = useAppearance((s) => s.revert);
	const apply = useAppearance((s) => s.apply);
	const current = useAppearance((s) => s.current);
	const pushEntry = useHistory((s) => s.pushEntry);

	const handleApply = () => {
		pushEntry("Apply changes", current);
		apply();
		fetchNui("appearance:apply", current);
	};

	const handleRevert = () => {
		revert();
		fetchNui("appearance:revert", {});
	};

	const canSavePreset = !allowedTabs || allowedTabs.includes("presets");
	const canSaveOutfit = !allowedTabs || allowedTabs.includes("outfits");
	const showSave = canSavePreset || canSaveOutfit;

	const handleSave = () => {
		if (canSavePreset) {
			onSavePreset();
		} else if (canSaveOutfit && onSaveOutfit) {
			onSaveOutfit();
		}
	};

	return (
		<Box className={classes.bar}>
			<CostTracker />
			<Box className={classes.quickSlots}>
				{quickSlots.map((slot) => (
					<Tooltip key={slot.label} label={t("ui.actions.quick_edit", slot.label)} position="top" transition="pop">
						<UnstyledButton
							className={classes.slot}
							onClick={() => {
								fetchNui("appearance:quickEdit", { type: slot.type, id: slot.type === "prop" ? slot.prop : slot.component });
							}}
						>
							<Text size={10} weight={600} transform="uppercase">{slot.label}</Text>
						</UnstyledButton>
					</Tooltip>
				))}
			</Box>
			<Group className={classes.actions} grow>
				<Button
					size="xs"
					variant="light"
					leftIcon={<TbCheck size={14} />}
					onClick={handleApply}
					disabled={!dirty}
					className={classes.actionBtn}
				>
					{t("ui.actions.apply")}
				</Button>
				<Button
					size="xs"
					variant="subtle"
					className={classes.actionBtn}
					color="gray"
					leftIcon={<TbArrowBack size={14} />}
					onClick={handleRevert}
					disabled={!dirty}
				>
					{t("ui.actions.revert")}
				</Button>
				<Button
					size="xs"
					variant="light"
					color="violet"
					leftIcon={canSavePreset ? <TbBookmark size={14} /> : <TbHanger size={14} />}
					onClick={handleSave}
					className={classes.actionBtn}
					sx={{ display: showSave ? undefined : "none" }}
				>
					{t("ui.actions.save")}
				</Button>
			</Group>
		</Box>
	);
};

export default ActionBar;
