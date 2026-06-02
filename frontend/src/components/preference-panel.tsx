import type { ReactNode } from 'react';
import { View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';

export type PreferencePanelProps = {
  children: ReactNode;
  detail?: string;
  label: string;
  value: string;
};

export function PreferencePanel({ children, detail, label, value }: PreferencePanelProps) {
  return (
    <ThemedView type="backgroundElement" className="w-full gap-4 rounded-2xl p-4">
      <View className="flex-row items-center justify-between gap-4">
        <View>
          <ThemedText type="smallBold">{label}</ThemedText>
          {detail ? (
            <ThemedText type="code" themeColor="textSecondary">
              {detail}
            </ThemedText>
          ) : null}
        </View>
        <ThemedText type="smallBold">{value}</ThemedText>
      </View>
      {children}
    </ThemedView>
  );
}
