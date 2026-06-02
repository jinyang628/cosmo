import { Platform, Text, type TextProps } from 'react-native';

import { Fonts, ThemeColor } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

export type ThemedTextProps = TextProps & {
  className?: string;
  type?: 'default' | 'title' | 'small' | 'smallBold' | 'subtitle' | 'link' | 'linkPrimary' | 'code';
  themeColor?: ThemeColor;
};

const textClassNames = {
  default: 'text-base leading-6 font-medium',
  title: 'text-5xl leading-[52px] font-semibold',
  small: 'text-sm leading-5 font-medium',
  smallBold: 'text-sm leading-5 font-bold',
  subtitle: 'text-[32px] leading-[44px] font-semibold',
  link: 'text-sm leading-[30px]',
  linkPrimary: 'text-sm leading-[30px]',
  code: 'text-xs font-medium',
} as const;

export function ThemedText({
  className,
  style,
  type = 'default',
  themeColor,
  ...rest
}: ThemedTextProps) {
  const theme = useTheme();
  const linkPrimaryColor = type === 'linkPrimary' ? '#3c87f7' : undefined;
  const codeStyle = type === 'code'
    ? { fontFamily: Fonts.mono, fontWeight: Platform.select({ android: 700 }) ?? 500 }
    : undefined;

  return (
    <Text
      className={`${textClassNames[type]}${className ? ` ${className}` : ''}`}
      style={[
        { color: linkPrimaryColor ?? theme[themeColor ?? 'text'] },
        codeStyle,
        style,
      ]}
      {...rest}
    />
  );
}
