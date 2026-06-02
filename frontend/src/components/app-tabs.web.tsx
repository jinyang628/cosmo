import {
  TabList,
  TabListProps,
  Tabs,
  TabSlot,
  TabTrigger,
  TabTriggerSlotProps,
} from 'expo-router/ui';
import { SymbolView } from 'expo-symbols';
import type { ComponentProps } from 'react';
import { Pressable, useColorScheme, View } from 'react-native';

import { ThemedText } from './themed-text';
import { ThemedView } from './themed-view';

import { Colors } from '@/constants/theme';

export default function AppTabs() {
  return (
    <Tabs>
      <TabSlot style={{ height: '100%' }} />
      <TabList asChild>
        <CustomTabList>
          <TabTrigger name="home" href="/" asChild>
            <TabButton icon={{ ios: 'fork.knife', android: 'restaurant', web: 'restaurant' }}>
              Eat
            </TabButton>
          </TabTrigger>
          <TabTrigger name="preferences" href="/preferences" asChild>
            <TabButton icon={{ ios: 'slider.horizontal.3', android: 'tune', web: 'tune' }}>
              Preferences
            </TabButton>
          </TabTrigger>
        </CustomTabList>
      </TabList>
    </Tabs>
  );
}

type TabButtonProps = TabTriggerSlotProps & {
  icon: ComponentProps<typeof SymbolView>['name'];
};

export function TabButton({ children, icon, isFocused, ...props }: TabButtonProps) {
  const scheme = useColorScheme();
  const colors = Colors[scheme === 'unspecified' ? 'light' : scheme];
  const tintColor = isFocused ? colors.text : colors.textSecondary;

  return (
    <Pressable
      {...props}
      style={({ pressed }) => [
        { flex: 1 },
        pressed && { opacity: 0.7 },
      ]}>
      <ThemedView
        type={isFocused ? 'backgroundSelected' : 'backgroundElement'}
        className="min-h-14 items-center justify-center gap-1 rounded-2xl px-2 py-2">
        <SymbolView tintColor={tintColor} name={icon} size={20} />
        <ThemedText type="smallBold" themeColor={isFocused ? 'text' : 'textSecondary'}>
          {children}
        </ThemedText>
      </ThemedView>
    </Pressable>
  );
}

export function CustomTabList(props: TabListProps) {
  const scheme = useColorScheme();
  const colors = Colors[scheme === 'unspecified' ? 'light' : scheme];

  return (
    <View
      {...props}
      className="absolute bottom-0 w-full flex-row items-center justify-center px-4 pb-4 pt-2">
      <ThemedView
        type="backgroundElement"
        className="max-w-[420px] flex-grow flex-row items-center justify-between gap-2 rounded-2xl border p-2"
        style={{
          borderColor: colors.backgroundSelected,
          elevation: 8,
          shadowColor: colors.text,
          shadowOffset: { width: 0, height: 12 },
          shadowOpacity: 0.16,
          shadowRadius: 24,
        }}>
        {props.children}
      </ThemedView>
    </View>
  );
}
