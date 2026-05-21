import { common } from './common';
import { landing } from './landing';
import { manual } from './manual';

export type Lang = 'en' | 'ja';

export const t = {
  en: {
    ...common.en,
    ...landing.en,
    ...manual.en,
  },
  ja: {
    ...common.ja,
    ...landing.ja,
    ...manual.ja,
  },
} as const;
