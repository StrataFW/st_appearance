
import { Box, Text, createStyles } from "@mantine/core";

interface Props {

	wordmark?: boolean;

	size?: "sm" | "md";

	tagline?: string;
}

const LOGO_SRC = "./logo/logo.png";

const useStyles = createStyles((theme, { size }: { size: "sm" | "md" }) => ({
	root: {
		display: "inline-flex",
		alignItems: "center",
		gap: size === "sm" ? 8 : "clamp(8px, 0.6vw, 11px)",
		minWidth: 0,
		flexShrink: 0,
	},
	mark: {
		width: size === "sm" ? "clamp(20px, 1.3vw, 28px)" : "clamp(28px, 1.8vw, 38px)",
		height: size === "sm" ? "clamp(20px, 1.3vw, 28px)" : "clamp(28px, 1.8vw, 38px)",
		objectFit: "contain" as const,
		flexShrink: 0,
		filter: `drop-shadow(0 0 6px ${theme.fn.rgba(theme.colors[theme.primaryColor][6], 0.35)})`,
	},
	wordmark: {
		fontSize: size === "sm" ? "clamp(12px, 0.7vw, 14px)" : "clamp(14px, 0.85vw, 17px)",
		fontWeight: 800,
		letterSpacing: "0.18em",
		color: theme.white,
		lineHeight: 1.1,
		textTransform: "uppercase" as const,
	},
	tagline: {
		fontSize: size === "sm" ? "clamp(8px, 0.45vw, 10px)" : "clamp(9px, 0.5vw, 11px)",
		color: theme.colors.dark[3],
		letterSpacing: "0.22em",
		textTransform: "uppercase" as const,
		fontWeight: 700,
		marginTop: 2,
	},
}));

export default function Logo({ wordmark = false, size = "sm", tagline }: Props) {
	const { classes } = useStyles({ size });
	return (
		<Box className={classes.root}>
			<img src={LOGO_SRC} alt="Strata" className={classes.mark} />
			{wordmark && (
				<Box sx={{ minWidth: 0 }}>
					<Text className={classes.wordmark}>Strata</Text>
					{tagline && <Text className={classes.tagline}>{tagline}</Text>}
				</Box>
			)}
		</Box>
	);
}
