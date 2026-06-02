import { SymbolView } from 'expo-symbols';
import { useMemo, useState } from 'react';
import { Pressable, ScrollView, View } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import {
  foodMoods,
  recommendations,
  type FoodMood,
  type Recommendation,
} from '@/constants/recommendations';
import { BottomTabInset, MaxContentWidth, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

export default function HomeScreen() {
  const theme = useTheme();
  const safeAreaInsets = useSafeAreaInsets();
  const [selectedMood, setSelectedMood] = useState<FoodMood>('fast');

  const visibleRecommendations = useMemo(() => {
    const selected = recommendations.filter((item) => item.mood === selectedMood);
    return selected.length > 0 ? selected : recommendations;
  }, [selectedMood]);

  const featuredRecommendation = visibleRecommendations[0] ?? recommendations[0];

  return (
    <ThemedView className="flex-1">
      <ScrollView
        className="flex-1"
        contentInset={{ bottom: safeAreaInsets.bottom + BottomTabInset + Spacing.four }}
        contentContainerStyle={[
          { alignItems: 'center' },
          { paddingBottom: safeAreaInsets.bottom + BottomTabInset + Spacing.four },
        ]}>
        <SafeAreaView
          className="w-full gap-4 px-4 pt-2"
          style={{ maxWidth: MaxContentWidth }}>
          <View className="flex-row items-center justify-between gap-4">
            <View>
              <View className="mb-1 flex-row items-center gap-1">
                <SymbolView
                  tintColor={theme.textSecondary}
                  name={{ ios: 'location.fill', android: 'map', web: 'map' }}
                  size={14}
                />
                <ThemedText type="small" themeColor="textSecondary">
                  Nearby
                </ThemedText>
              </View>
              <ThemedText type="subtitle" className="text-[34px] leading-10">
                What sounds good?
              </ThemedText>
            </View>
            <Pressable
              accessibilityLabel="Refresh recommendations"
              style={({ pressed }) => [
                {
                  alignItems: 'center',
                  backgroundColor: theme.backgroundElement,
                  borderRadius: 22,
                  height: 44,
                  justifyContent: 'center',
                  width: 44,
                },
                pressed && { opacity: 0.72 },
              ]}>
              <SymbolView
                tintColor={theme.text}
                name={{ ios: 'arrow.clockwise', android: 'refresh', web: 'refresh' }}
                size={18}
              />
            </Pressable>
          </View>

          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ gap: Spacing.two, paddingRight: Spacing.three }}>
            {foodMoods.map((mood) => {
              const selected = selectedMood === mood.id;
              return (
                <Pressable
                  key={mood.id}
                  onPress={() => setSelectedMood(mood.id)}
                  style={({ pressed }) => [
                    {
                      backgroundColor: selected ? theme.text : theme.backgroundElement,
                      borderRadius: 18,
                      borderColor: selected ? theme.text : theme.backgroundSelected,
                      borderWidth: 1,
                      minHeight: 36,
                      paddingHorizontal: Spacing.three,
                      paddingVertical: Spacing.two,
                    },
                    pressed && { opacity: 0.72 },
                  ]}>
                  <ThemedText
                    type="smallBold"
                    style={{ color: selected ? theme.background : theme.text }}>
                    {mood.label}
                  </ThemedText>
                </Pressable>
              );
            })}
          </ScrollView>

          <FeaturedCard recommendation={featuredRecommendation} />

          <View className="w-full flex-row items-center justify-between">
            <ThemedText type="smallBold" themeColor="textSecondary">
              SHORTLIST
            </ThemedText>
            <ThemedText type="small" themeColor="textSecondary">
              {visibleRecommendations.length} pick
              {visibleRecommendations.length === 1 ? '' : 's'}
            </ThemedText>
          </View>

          <View className="w-full gap-2">
            {recommendations.map((recommendation) => (
              <RecommendationRow key={recommendation.id} recommendation={recommendation} />
            ))}
          </View>
        </SafeAreaView>
      </ScrollView>
    </ThemedView>
  );
}

function FeaturedCard({ recommendation }: { recommendation: Recommendation }) {
  const theme = useTheme();

  return (
    <View
      style={[
        {
          borderRadius: Spacing.three,
          elevation: 4,
          gap: Spacing.five,
          minHeight: 280,
          padding: Spacing.three,
          shadowOffset: { width: 0, height: 16 },
          shadowOpacity: 0.16,
          shadowRadius: 24,
          width: '100%',
        },
        {
          backgroundColor: recommendation.accentColor,
          shadowColor: theme.text,
        },
      ]}>
      <View className="flex-row justify-between">
        <ThemedText type="smallBold" className="uppercase" style={{ color: '#24140F' }}>
          Top match
        </ThemedText>
        <ThemedText type="smallBold" className="uppercase" style={{ color: '#24140F' }}>
          {recommendation.etaMinutes} min
        </ThemedText>
      </View>

      <View className="gap-2">
        <ThemedText type="title" className="text-[42px] leading-[46px]" style={{ color: '#24140F' }}>
          {recommendation.dish}
        </ThemedText>
        <ThemedText type="default" style={{ color: '#3E2A1E', maxWidth: 340 }}>
          {recommendation.reason}
        </ThemedText>
      </View>

      <View className="flex-row items-end justify-between gap-4">
        <View>
          <ThemedText type="smallBold" style={{ color: '#24140F' }}>
            {recommendation.name}
          </ThemedText>
          <ThemedText type="small" style={{ color: '#3E2A1E' }}>
            {recommendation.cuisine} - {recommendation.distance} - {recommendation.price}
          </ThemedText>
        </View>
        <View
          className="min-h-[34px] flex-row items-center gap-1 rounded-[18px] px-2"
          style={{ backgroundColor: 'rgba(255, 255, 255, 0.42)' }}>
          <SymbolView
            tintColor="#24140F"
            name={{ ios: 'star.fill', android: 'star', web: 'star' }}
            size={12}
          />
          <ThemedText type="smallBold" style={{ color: '#24140F' }}>
            {recommendation.rating}
          </ThemedText>
        </View>
      </View>
    </View>
  );
}

function RecommendationRow({ recommendation }: { recommendation: Recommendation }) {
  const theme = useTheme();

  return (
    <Pressable style={({ pressed }) => pressed && { opacity: 0.72 }}>
      <ThemedView
        type="backgroundElement"
        style={[
          {
            alignItems: 'center',
            borderRadius: Spacing.three,
            borderWidth: 1,
            flexDirection: 'row',
            gap: Spacing.three,
            minHeight: 104,
            padding: Spacing.three,
          },
          { borderColor: theme.backgroundSelected },
        ]}>
        <View
          className="h-11 w-11 items-center justify-center rounded-[22px]"
          style={{ backgroundColor: recommendation.accentColor }}>
          <ThemedText type="smallBold" style={{ color: '#24140F' }}>
            {recommendation.name.slice(0, 1)}
          </ThemedText>
        </View>
        <View className="min-w-0 flex-1 gap-1">
          <ThemedText type="smallBold">{recommendation.name}</ThemedText>
          <ThemedText type="small" themeColor="textSecondary" numberOfLines={1}>
            {recommendation.dish}
          </ThemedText>
          <View className="flex-row flex-wrap gap-1">
            {recommendation.tags.slice(0, 2).map((tag) => (
              <ThemedView key={tag} type="backgroundSelected" className="rounded-[10px] px-2 py-0.5">
                <ThemedText type="code" themeColor="textSecondary">
                  {tag}
                </ThemedText>
              </ThemedView>
            ))}
          </View>
        </View>
        <View className="items-end gap-1">
          <ThemedText type="smallBold">{recommendation.etaMinutes}m</ThemedText>
          <ThemedText type="small" themeColor="textSecondary">
            {recommendation.distance}
          </ThemedText>
        </View>
      </ThemedView>
    </Pressable>
  );
}
