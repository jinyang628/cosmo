import { NativeTabs } from 'expo-router/unstable-native-tabs';
import { useColorScheme } from 'react-native';

import { Colors } from '@/constants/theme';

export default function AppTabs() {
  const scheme = useColorScheme();
  const colors = Colors[scheme === 'unspecified' ? 'light' : scheme];

  return (
    <NativeTabs
      backgroundColor={colors.background}
      indicatorColor={colors.backgroundElement}
      labelStyle={{ selected: { color: colors.text } }}>
      <NativeTabs.Trigger name="index">
        <NativeTabs.Trigger.Label>Eat</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon
          sf="fork.knife"
          md="restaurant"
        />
      </NativeTabs.Trigger>

      <NativeTabs.Trigger name="explore">
        <NativeTabs.Trigger.Label>Preferences</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon
          sf="slider.horizontal.3"
          md="tune"
        />
      </NativeTabs.Trigger>
    </NativeTabs>
  );
}
