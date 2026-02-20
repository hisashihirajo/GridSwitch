export interface Feature {
  icon: string;
  title: string;
  description: string;
}

export const features: Feature[] = [
  {
    icon: '⊞',
    title: 'Grid Layout',
    description: 'See all running apps in a clean grid view instead of a cramped horizontal strip. Find and switch to any app instantly.',
  },
  {
    icon: '⌘',
    title: 'Seamless Activation',
    description: 'Intercepts Cmd+Tab natively. No new shortcuts to learn — just press the same keys you already use.',
  },
  {
    icon: '#',
    title: 'Number Key Shortcuts',
    description: 'Press 1–9 to instantly jump to any app by its position. Switch apps without even looking at the grid.',
  },
  {
    icon: '◎',
    title: 'Fully Customizable',
    description: 'Adjust icon size, background color and opacity, grid columns, and even set a custom background image.',
  },
  {
    icon: '⌨',
    title: 'Multiple Input Methods',
    description: 'Navigate with Tab, Shift+Tab, arrow keys, or number keys. Press Q to quit the selected app on the spot.',
  },
  {
    icon: 'あ',
    title: 'Bilingual UI',
    description: 'Full support for both Japanese and English interfaces. Automatically adapts to your preferred language.',
  },
];
