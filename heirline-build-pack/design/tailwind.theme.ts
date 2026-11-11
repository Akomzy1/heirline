// Tailwind theme extension. Maps ONLY to the CSS variables in tokens.css (the prototype's tokens).
// Never put a literal colour, size or duration here. If a token is missing, add it to tokens.css's owner (design) first.
import type { Config } from 'tailwindcss';

const v = (name: string) => `var(--${name})`;

export const heirlineTheme: Partial<Config['theme']> = {
  colors: {
    transparent: 'transparent',
    current: 'currentColor',
    // semantic (preferred in components)
    page: v('bg-page'), raised: v('bg-raised'), sunken: v('bg-sunken'), field: v('bg-field'), inverse: v('bg-inverse'),
    scrim: v('bg-scrim'), hover: v('bg-hover'), selected: v('bg-selected'),
    primary: v('text-primary'), secondary: v('text-secondary'), tertiary: v('text-tertiary'), disabled: v('text-disabled'),
    'on-inverse': v('text-inverse'),
    hairline: v('border-hairline'), strong: v('border-strong'), control: v('border-control'), emphasis: v('border-emphasis'),
    significance: v('accent-significance'), 'significance-text': v('accent-significance-text'), 'significance-soft': v('accent-significance-soft'),
    ceremonial: v('ceremonial-bg'), 'ceremonial-text': v('ceremonial-text'),
    action: v('action-primary-bg'), 'action-text': v('action-primary-text'),
    focus: v('focus-ring'),
    verified: v('status-verified'), attention: v('status-attention'), 'high-risk': v('status-high-risk'), unscored: v('status-unscored'), info: v('status-info'),
    // primitives (available, not preferred)
    ink: { 950: v('ink-950'), 900: v('ink-900'), 800: v('ink-800'), 700: v('ink-700'), 600: v('ink-600'), 400: v('ink-400'), 300: v('ink-300'), 200: v('ink-200') },
    ivory: { 50: v('ivory-50') },
    parchment: { 100: v('parchment-100'), 200: v('parchment-200'), 300: v('parchment-300') },
    brass: { 300: v('brass-300'), 500: v('brass-500'), 600: v('brass-600'), 700: v('brass-700'), 800: v('brass-800') },
    slate: { 300: v('slate-300'), 500: v('slate-500'), 600: v('slate-600'), 700: v('slate-700') },
  },
  fontFamily: { display: [v('font-display')], heading: [v('font-heading')], text: [v('font-text')], sans: [v('font-sans')], mono: [v('font-mono')] },
  fontSize: {
    'display-xl': v('type-display-xl'), 'display-l': v('type-display-l'), 'display-m': v('type-display-m'),
    'heading-l': v('type-heading-l'), 'heading-m': v('type-heading-m'), 'heading-s': v('type-heading-s'),
    'body-l': v('type-body-l'), 'body-m': v('type-body-m'), 'body-s': v('type-body-s'),
    label: v('type-label'), 'label-l': v('type-label-l'), mono: v('type-mono'),
  },
  spacing: {
    1: v('space-4'), 2: v('space-8'), 3: v('space-12'), 4: v('space-16'), 6: v('space-24'), 8: v('space-32'),
    12: v('space-48'), 16: v('space-64'), 24: v('space-96'), 32: v('space-128'),
  },
  borderRadius: { none: '0', control: v('radius-control'), card: v('radius-card'), sheet: v('radius-sheet'), full: v('radius-round') },
  boxShadow: { none: 'none', overlay: v('shadow-overlay') },
  transitionDuration: { fast: v('duration-fast'), base: v('duration-base'), slow: v('duration-slow'), ceremony: v('duration-ceremony') },
  transitionTimingFunction: { out: v('ease-out'), ceremony: v('ease-ceremony') },
  maxWidth: { grid: v('grid-max'), measure: v('measure') },
  // NOTE: the spacing keys above follow Tailwind's 4px scale names (1=4px … 32=128px). Verify against tokens.css before relying on them.
};
