import { MantineThemeOverride } from "@mantine/core";

export const customTheme: MantineThemeOverride = {
	colorScheme: "dark",
	fontFamily: "Montserrat, ui-sans-serif, system-ui, sans-serif",
	fontFamilyMonospace: "Montserrat, ui-sans-serif, system-ui, sans-serif",
	fontSizes: { xs: 12, sm: 14, md: 16, lg: 20, xl: 24 },
	headings: {
		fontFamily: "Montserrat, ui-sans-serif, system-ui, sans-serif",
		fontWeight: 700,
	},
	defaultRadius: "sm",
	components: {
		Badge: {
			defaultProps: { variant: "light" },
			styles: { root: { textTransform: "uppercase" as const } },
		},
		Button: {
			defaultProps: { variant: "light" },
			styles: {
				root: {
					textTransform: "uppercase" as const,
					minHeight: "clamp(24px, 1.35vw, 32px)",
					paddingLeft: "clamp(10px, 0.7vw, 15px)",
					paddingRight: "clamp(10px, 0.7vw, 15px)",
					fontSize: "clamp(11px, 0.55vw, 13px)",
					letterSpacing: "0.04em",
				},
			},
		},
		ActionIcon: {
			styles: {
				root: {
					width: "clamp(20px, 1.2vw, 30px)",
					height: "clamp(20px, 1.2vw, 30px)",
					minWidth: "clamp(20px, 1.2vw, 30px)",
				},
			},
		},
		Input: {
			styles: {
				input: {
					minHeight: "clamp(26px, 1.45vw, 34px)",
					fontSize: "clamp(11px, 0.55vw, 13px)",
				},
			},
		},
		Select: {
			styles: {
				input: {
					minHeight: "clamp(26px, 1.45vw, 34px)",
					fontSize: "clamp(11px, 0.55vw, 13px)",
				},
				item: {
					fontSize: "clamp(11px, 0.55vw, 13px)",
				},
			},
		},
		NumberInput: {
			styles: {
				input: {
					minHeight: "clamp(26px, 1.45vw, 34px)",
					fontSize: "clamp(11px, 0.55vw, 13px)",
				},
			},
		},
		Textarea: {
			styles: {
				input: {
					fontSize: "clamp(11px, 0.55vw, 13px)",
					lineHeight: 1.5,
				},
			},
		},
		SegmentedControl: {
			styles: (theme: any) => ({
				root: { backgroundColor: theme.colors.dark[8] },
				label: {
					fontSize: "clamp(10px, 0.55vw, 12px)",
					fontWeight: 600,
					letterSpacing: "0.02em",
					padding: "clamp(4px, 0.3vw, 7px) clamp(6px, 0.45vw, 10px)",
				},
				active: { backgroundColor: theme.colors.dark[6] },
			}),
		},
		Switch: {
			styles: (theme: any) => ({
				track: { borderColor: theme.colors.dark[5] },
				label: {
					fontSize: "clamp(11px, 0.6vw, 13px)",
					fontWeight: 600,
				},
			}),
		},
		Slider: {
			styles: (theme: any) => ({
				root: { overflow: "visible" as const },
				track: {
					backgroundColor: theme.colors.dark[6],
					height: "clamp(4px, 0.25vw, 6px)",
				},
				thumb: {
					width: "clamp(12px, 0.7vw, 16px)",
					height: "clamp(12px, 0.7vw, 16px)",
				},
				label: {
					maxWidth: "none",
					whiteSpace: "nowrap" as const,
					zIndex: 40,
				},
				markLabel: {
					fontSize: "clamp(9px, 0.5vw, 11px)",
					color: theme.colors.dark[3],
				},
			}),
		},
		Tabs: {
			styles: (theme: any) => ({
				tab: {
					fontSize: "clamp(11px, 0.6vw, 13px)",
					fontWeight: 600,
					"&[data-active]": {
						borderColor: theme.colors[theme.primaryColor][6],
					},
				},
			}),
		},
		Tooltip: {
			defaultProps: { transition: "pop", withinPortal: true },
			styles: (theme: any) => ({
				tooltip: {
					fontSize: "clamp(10px, 0.55vw, 12px)",
					backgroundColor: theme.colors.dark[5],
				},
			}),
		},
		Modal: {
			defaultProps: {
				withinPortal: false,
			},
			styles: (theme: any) => ({
				root: {
					position: "absolute" as const,
					overflow: "visible" as const,
				},
				overlay: {
					position: "absolute" as const,
					borderRadius: theme.radius.sm,
				},
				inner: {
					position: "absolute" as const,
					padding: "clamp(10px, 1.1vw, 22px)",
					overflow: "visible" as const,
				},
				modal: {
					width: "min(100%, clamp(360px, 34vw, 540px))",
					maxWidth: "calc(100vw - 32px)",
					overflow: "visible" as const,
					backgroundColor: theme.colors.dark[8],
					border: `1px solid ${theme.colors.dark[5]}`,
				},
				body: {
					maxHeight: "calc(100dvh - 120px)",
					overflowY: "auto" as const,
					overflowX: "visible" as const,
					paddingTop: 6,
				},
				content: {
					maxHeight: "calc(100dvh - 80px)",
					overflow: "visible" as const,
				},
				title: {
					fontWeight: 700,
					fontSize: "clamp(13px, 0.7vw, 15px)",
					color: theme.white,
				},
			}),
		},
	},
};
