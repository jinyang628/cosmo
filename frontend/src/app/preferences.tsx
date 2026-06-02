import { useMemo, useState } from 'react';
import { Pressable, ScrollView, View } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

import { PreferencePanel } from '@/components/preference-panel';
import RangeSlider from '@/components/range-slider';
import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { BUDGET_OPTIONS, DIET_OPTIONS, DISTANCE_MAX_METERS, DISTANCE_MIN_METERS } from '@/constants/preferences';
import { BottomTabInset, MaxContentWidth, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { clamp, distanceProgressToMeters, formatDistance } from '@/utils/slider';

export default function PreferencesScreen() {
  const safeAreaInsets = useSafeAreaInsets();
  const theme = useTheme();
  const [distanceProgress, setDistanceProgress] = useState(0.38);
  const [budgetLevel, setBudgetLevel] = useState(2);
  const [isSliding, setIsSliding] = useState(false);
  const [selectedDiets, setSelectedDiets] = useState<Set<string>>(() => new Set(['Spicy ok']));

  const distanceMeters = useMemo(
    () => distanceProgressToMeters(distanceProgress, DISTANCE_MIN_METERS, DISTANCE_MAX_METERS),
    [distanceProgress]
  );
  const budgetProgress = (budgetLevel - 1) / (BUDGET_OPTIONS.options.length - 1);

  function toggleDiet(option: string) {
    setSelectedDiets((current) => {
      const next = new Set(current);
      if (next.has(option)) {
        next.delete(option);
      } else {
        next.add(option);
      }
      return next;
    });
  }

  function updateBudget(progress: number) {
    const nextLevel = Math.round(clamp(progress) * (BUDGET_OPTIONS.options.length - 1)) + 1;
    setBudgetLevel(nextLevel);
  }

  return (
    <ThemedView className="flex-1">
      <ScrollView
        scrollEnabled={!isSliding}
        className="flex-1"
        contentInset={{ bottom: safeAreaInsets.bottom + BottomTabInset + Spacing.four }}
        contentContainerStyle={[
          { alignItems: 'center' },
          { paddingBottom: safeAreaInsets.bottom + BottomTabInset + Spacing.four },
        ]}>
        <SafeAreaView
          className="w-full gap-4 px-4 pt-2"
          style={{ maxWidth: MaxContentWidth }}>
          <View className="pt-2">
            <ThemedText type="subtitle" className="text-[34px] leading-10">
              Preferences
            </ThemedText>
          </View>

          <PreferencePanel
            label="Distance"
            value={formatDistance(distanceMeters)}
          >
            <RangeSlider
              value={distanceProgress}
              onChange={setDistanceProgress}
              onSlidingChange={setIsSliding}
            />
            <View className="flex-row justify-between">
              <ThemedText type="code" themeColor="textSecondary">
                100m
              </ThemedText>
              <ThemedText type="code" themeColor="textSecondary">
                1km
              </ThemedText>
              <ThemedText type="code" themeColor="textSecondary">
                10km
              </ThemedText>
              <ThemedText type="code" themeColor="textSecondary">
                50km
              </ThemedText>
            </View>
          </PreferencePanel>

          <PreferencePanel
            label="Budget"
            value={BUDGET_OPTIONS.options[budgetLevel - 1]}
           >
            <RangeSlider
              value={budgetProgress}
              onChange={updateBudget}
              onSlidingChange={setIsSliding}
              stepCount={4}
            />
            <View className="flex-row justify-between">
              {BUDGET_OPTIONS.options.map((option, index) => {
                const selected = budgetLevel === index + 1;
                return (
                  <ThemedText
                    key={option}
                    type="smallBold"
                    themeColor={selected ? 'text' : 'textSecondary'}>
                    {option}
                  </ThemedText>
                );
              })}
            </View>
          </PreferencePanel>

          <PreferencePanel label="Diet" value={`${selectedDiets.size} selected`}>
            <View className="flex-row flex-wrap gap-2">
              {DIET_OPTIONS.options.map((option) => {
                const selected = selectedDiets.has(option);
                return (
                  <Pressable
                    key={option}
                    onPress={() => toggleDiet(option)}
                    style={({ pressed }) => [
                      {
                        borderRadius: 18,
                        backgroundColor: selected ? theme.text : theme.backgroundSelected,
                        minHeight: 36,
                        paddingHorizontal: Spacing.three,
                        paddingVertical: Spacing.two,
                      },
                      pressed && { opacity: 0.72 },
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
          </PreferencePanel>
        </SafeAreaView>
      </ScrollView>
    </ThemedView>
  );
}
