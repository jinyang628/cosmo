import { SymbolView } from 'expo-symbols';
import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { diningSignals } from '@/constants/recommendations';
import { BottomTabInset, MaxContentWidth, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

const preferenceOptions = ['Veg-friendly', 'Spicy ok', 'No queue', 'Open now', 'Under $15'];

const integrationRows = [
  {
    label: 'Places',
    value: 'Mock',
    icon: { ios: 'map.fill', android: 'map', web: 'map' },
  },
  {
    label: 'Menu',
    value: 'Local',
    icon: { ios: 'menucard.fill', android: 'list', web: 'list' },
  },
  {
    label: 'Profile',
    value: 'Draft',
    icon: { ios: 'person.crop.circle.fill', android: 'person', web: 'person.crop.circle.fill' },
  },
] as const;

export default function SignalsScreen() {
  const theme = useTheme();
  const safeAreaInsets = useSafeAreaInsets();
  const [selectedPreferences, setSelectedPreferences] = useState(() => new Set(['Open now']));

  function togglePreference(option: string) {
    setSelectedPreferences((current) => {
      const next = new Set(current);
      if (next.has(option)) {
        next.delete(option);
      } else {
        next.add(option);
      }
      return next;
    });
  }

  return (
    <ThemedView style={styles.screen}>
      <ScrollView
        style={styles.scrollView}
        contentInset={{ bottom: safeAreaInsets.bottom + BottomTabInset + Spacing.four }}
        contentContainerStyle={[
          styles.content,
          { paddingBottom: safeAreaInsets.bottom + BottomTabInset + Spacing.four },
        ]}>
        <SafeAreaView style={styles.safeArea}>
          <View style={styles.header}>
            <View>
              <ThemedText type="smallBold" style={styles.eyebrow} themeColor="textSecondary">
                TASTE PROFILE
              </ThemedText>
              <ThemedText type="subtitle" style={styles.title}>
                Signals
              </ThemedText>
            </View>
            <View style={[styles.scoreBadge, { backgroundColor: theme.backgroundElement }]}>
              <ThemedText type="smallBold">82%</ThemedText>
              <ThemedText type="code" themeColor="textSecondary">
                fit
              </ThemedText>
            </View>
          </View>

          <View style={styles.signalGrid}>
            {diningSignals.map((signal) => (
              <ThemedView key={signal.label} type="backgroundElement" style={styles.signalCard}>
                <ThemedText type="code" themeColor="textSecondary">
                  {signal.label}
                </ThemedText>
                <ThemedText type="smallBold">{signal.value}</ThemedText>
              </ThemedView>
            ))}
          </View>

          <ThemedView type="backgroundElement" style={styles.panel}>
            <View style={styles.panelHeader}>
              <View>
                <ThemedText type="smallBold">Preferences</ThemedText>
                <ThemedText type="small" themeColor="textSecondary">
                  {selectedPreferences.size} active
                </ThemedText>
              </View>
              <SymbolView
                tintColor={theme.textSecondary}
                name={{ ios: 'slider.horizontal.3', android: 'filter', web: 'filter' }}
                size={20}
              />
            </View>

            <View style={styles.preferenceGrid}>
              {preferenceOptions.map((option) => {
                const selected = selectedPreferences.has(option);
                return (
                  <Pressable
                    key={option}
                    onPress={() => togglePreference(option)}
                    style={({ pressed }) => [
                      styles.preferenceChip,
                      {
                        backgroundColor: selected ? theme.text : theme.backgroundSelected,
                      },
                      pressed && styles.pressed,
                    ]}>
                    <ThemedText
                      type="smallBold"
                      style={{ color: selected ? theme.background : theme.text }}>
                      {option}
                    </ThemedText>
                  </Pressable>
                );
              })}
            </View>
          </ThemedView>

          <ThemedView type="backgroundElement" style={styles.panel}>
            <View style={styles.panelHeader}>
              <ThemedText type="smallBold">Scoring</ThemedText>
              <ThemedText type="small" themeColor="textSecondary">
                Balanced
              </ThemedText>
            </View>
            <ScoreRow label="Craving" value={72} color="#F6C453" />
            <ScoreRow label="Convenience" value={64} color="#65B891" />
            <ScoreRow label="Novelty" value={42} color="#8EA7E9" />
          </ThemedView>

          <View style={styles.integrationList}>
            {integrationRows.map((row) => (
              <ThemedView key={row.label} type="backgroundElement" style={styles.integrationRow}>
                <View style={styles.integrationLeft}>
                  <View
                    style={[
                      styles.integrationIcon,
                      { backgroundColor: theme.backgroundSelected },
                    ]}>
                    <SymbolView tintColor={theme.text} name={row.icon} size={18} />
                  </View>
                  <ThemedText type="smallBold">{row.label}</ThemedText>
                </View>
                <ThemedText type="small" themeColor="textSecondary">
                  {row.value}
                </ThemedText>
              </ThemedView>
            ))}
          </View>
        </SafeAreaView>
      </ScrollView>
    </ThemedView>
  );
}

function ScoreRow({ label, value, color }: { label: string; value: number; color: string }) {
  const theme = useTheme();

  return (
    <View style={styles.scoreRow}>
      <View style={styles.scoreLabelRow}>
        <ThemedText type="small">{label}</ThemedText>
        <ThemedText type="code" themeColor="textSecondary">
          {value}
        </ThemedText>
      </View>
      <View style={[styles.scoreTrack, { backgroundColor: theme.backgroundSelected }]}>
        <View style={[styles.scoreFill, { backgroundColor: color, width: `${value}%` }]} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  content: {
    alignItems: 'center',
  },
  safeArea: {
    width: '100%',
    maxWidth: MaxContentWidth,
    paddingHorizontal: Spacing.three,
    paddingTop: Spacing.two,
    gap: Spacing.three,
  },
  header: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: Spacing.three,
  },
  eyebrow: {
    letterSpacing: 0,
  },
  title: {
    fontSize: 34,
    lineHeight: 40,
  },
  scoreBadge: {
    alignItems: 'center',
    borderRadius: 22,
    minHeight: 56,
    justifyContent: 'center',
    paddingHorizontal: Spacing.three,
  },
  signalGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.two,
  },
  signalCard: {
    borderRadius: Spacing.three,
    flexBasis: '48%',
    flexGrow: 1,
    gap: Spacing.one,
    minHeight: 84,
    padding: Spacing.three,
  },
  panel: {
    borderRadius: Spacing.three,
    gap: Spacing.three,
    padding: Spacing.three,
    width: '100%',
  },
  panelHeader: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: Spacing.three,
  },
  preferenceGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.two,
  },
  preferenceChip: {
    borderRadius: 18,
    minHeight: 36,
    paddingHorizontal: Spacing.three,
    paddingVertical: Spacing.two,
  },
  pressed: {
    opacity: 0.72,
  },
  scoreRow: {
    gap: Spacing.two,
  },
  scoreLabelRow: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  scoreTrack: {
    borderRadius: 6,
    height: 8,
    overflow: 'hidden',
  },
  scoreFill: {
    borderRadius: 6,
    height: '100%',
  },
  integrationList: {
    gap: Spacing.two,
    width: '100%',
  },
  integrationRow: {
    alignItems: 'center',
    borderRadius: Spacing.three,
    flexDirection: 'row',
    justifyContent: 'space-between',
    minHeight: 64,
    paddingHorizontal: Spacing.three,
  },
  integrationLeft: {
    alignItems: 'center',
    flexDirection: 'row',
    gap: Spacing.two,
  },
  integrationIcon: {
    alignItems: 'center',
    borderRadius: 18,
    height: 36,
    justifyContent: 'center',
    width: 36,
  },
});
