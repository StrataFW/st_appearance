import React, { useCallback, useState } from "react";
import { Box, createStyles, Portal, UnstyledButton } from "@mantine/core";

const useStyles = createStyles((theme, { side, offset }: { side: "left" | "right"; offset: string }) => ({
	rail: {
		position: "fixed",
		top: "50%",
		transform: "translateY(-50%)",
		[side]: offset,
		display: "flex",
		flexDirection: "column",
		gap: "clamp(6px, 0.45vw, 10px)",
		zIndex: 50,
		pointerEvents: "auto",
		animation: "fade-up 0.32s ease-out both",
	},
	btn: {
		width: "clamp(36px, 2.1vw, 46px)",
		height: "clamp(36px, 2.1vw, 46px)",
		borderRadius: "50%",
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		color: theme.colors.dark[1],
		backgroundColor: theme.fn.rgba(theme.colors.dark[8], 0.85),
		border: `1px solid ${theme.fn.rgba(theme.colors.dark[4], 0.7)}`,
		boxShadow: "0 4px 14px rgba(0, 0, 0, 0.45)",
		transition: "background-color 140ms ease, color 140ms ease, transform 140ms ease, border-color 140ms ease",
		"& svg": {
			width: "clamp(16px, 0.95vw, 20px)",
			height: "clamp(16px, 0.95vw, 20px)",
		},
		"&:hover": {
			color: theme.white,
			backgroundColor: theme.fn.rgba(theme.colors.dark[7], 0.95),
			borderColor: theme.colors.dark[3],
			transform: "scale(1.05)",
		},
	},
	btnActive: {
		color: theme.white,
		backgroundColor: theme.fn.rgba(theme.colors[theme.primaryColor][7], 0.85),
		borderColor: theme.colors[theme.primaryColor][5],
		boxShadow: `0 0 0 1px ${theme.fn.rgba(theme.colors[theme.primaryColor][5], 0.4)}, 0 6px 18px rgba(0, 0, 0, 0.55)`,
		"&:hover": {
			backgroundColor: theme.fn.rgba(theme.colors[theme.primaryColor][6], 0.95),
			borderColor: theme.colors[theme.primaryColor][4],
		},
	},
	tooltip: {
		position: "fixed" as const,
		pointerEvents: "none" as const,
		padding: "clamp(4px, 0.3vw, 6px) clamp(8px, 0.55vw, 12px)",
		backgroundColor: theme.colors.dark[5],
		color: theme.white,
		fontSize: "clamp(11px, 0.55vw, 13px)",
		fontWeight: 600,
		letterSpacing: 0.4,
		textTransform: "uppercase" as const,
		borderRadius: theme.radius.sm,
		whiteSpace: "nowrap" as const,
		zIndex: 10000,
		boxShadow: "0 4px 14px rgba(0, 0, 0, 0.5)",
	},
}));

export interface RailItem {
	label: string;
	path: string;
	tabKey: string;
	icon: React.ReactNode;
}

interface Props {
	side: "left" | "right";
	offset: string;
	items: RailItem[];
	activePath: string;
	onPick: (path: string) => void;
}

const FloatingCategoryRail: React.FC<Props> = ({ side, offset, items, activePath, onPick }) => {
	const { classes, cx } = useStyles({ side, offset });
	const [tooltip, setTooltip] = useState<{ label: string; top: number; x: number } | null>(null);

	const show = useCallback((e: React.MouseEvent, label: string) => {
		const rect = (e.currentTarget as HTMLElement).getBoundingClientRect();
		setTooltip({
			label,
			top: rect.top + rect.height / 2,
			x: side === "left" ? rect.right + 10 : rect.left - 10,
		});
	}, [side]);

	const hide = useCallback(() => setTooltip(null), []);

	return (
		<Box className={classes.rail}>
			{items.map((item) => {
				const isActive = item.path === activePath;
				return (
					<UnstyledButton
						key={item.path}
						className={cx(classes.btn, isActive && classes.btnActive)}
						onClick={() => onPick(item.path)}
						onMouseEnter={(e) => show(e, item.label)}
						onMouseLeave={hide}
						aria-label={item.label}
					>
						{item.icon}
					</UnstyledButton>
				);
			})}

			{tooltip && (
				<Portal>
					<Box
						className={classes.tooltip}
						style={{
							top: tooltip.top,
							[side === "left" ? "left" : "right"]:
								side === "left" ? tooltip.x : window.innerWidth - tooltip.x,
							transform: "translateY(-50%)",
						}}
					>
						{tooltip.label}
					</Box>
				</Portal>
			)}
		</Box>
	);
};

export default FloatingCategoryRail;
