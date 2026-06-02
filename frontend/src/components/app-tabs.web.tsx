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
import { Pressable, StyleSheet, useColorScheme, View } from 'react-native';

import { ThemedText } from './themed-text';
import { ThemedView } from './themed-view';

import { Colors, Spacing } from '@/constants/theme';

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
        styles.tabPressable,
        pressed && styles.pressed,
      ]}>
      <ThemedView
        type={isFocused ? 'backgroundSelected' : 'backgroundElement'}
        style={styles.tabButtonView}>
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
    <View {...props} style={styles.tabListContainer}>
      <ThemedView
        type="backgroundElement"
        style={[
          styles.innerContainer,
          {
            borderColor: colors.backgroundSelected,
            shadowColor: colors.text,
          },
        ]}>
        {props.children}
      </ThemedView>
    </View>
  );
}

const styles = StyleSheet.create({
  tabListContainer: {
    bottom: 0,
    position: 'absolute',
    width: '100%',
    paddingBottom: Spacing.three,
    paddingHorizontal: Spacing.three,
    paddingTop: Spacing.two,
    justifyContent: 'center',
    alignItems: 'center',
    flexDirection: 'row',
  },
  innerContainer: {
    borderRadius: Spacing.three,
    borderWidth: 1,
    elevation: 8,
    flexDirection: 'row',
    alignItems: 'center',
    flexGrow: 1,
    gap: Spacing.two,
    justifyContent: 'space-between',
    maxWidth: 420,
    padding: Spacing.two,
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.16,
    shadowRadius: 24,
  },
  pressed: {
    opacity: 0.7,
  },
  tabPressable: {
    flex: 1,
  },
  tabButtonView: {
    alignItems: 'center',
    borderRadius: Spacing.three,
    gap: Spacing.one,
    minHeight: 56,
    justifyContent: 'center',
    paddingHorizontal: Spacing.two,
    paddingVertical: Spacing.two,
  },
});
