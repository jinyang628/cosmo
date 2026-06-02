import { SymbolView } from 'expo-symbols';
import { useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';
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
              <View style={styles.locationRow}>
                <SymbolView
                  tintColor={theme.textSecondary}
                  name={{ ios: 'location.fill', android: 'map', web: 'map' }}
                  size={14}
                />
                <ThemedText type="small" themeColor="textSecondary">
                  Nearby
                </ThemedText>
              </View>
              <ThemedText type="subtitle" style={styles.title}>
                What sounds good?
              </ThemedText>
            </View>
            <Pressable
              accessibilityLabel="Refresh recommendations"
              style={({ pressed }) => [
                styles.iconButton,
                { backgroundColor: theme.backgroundElement },
                pressed && styles.pressed,
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
            contentContainerStyle={styles.moodScroller}>
            {foodMoods.map((mood) => {
              const selected = selectedMood === mood.id;
              return (
                <Pressable
                  key={mood.id}
                  onPress={() => setSelectedMood(mood.id)}
                  style={({ pressed }) => [
                    styles.moodChip,
                    {
                      backgroundColor: selected ? theme.text : theme.backgroundElement,
                      borderColor: selected ? theme.text : theme.backgroundSelected,
                    },
                    pressed && styles.pressed,
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

          <View style={styles.sectionHeading}>
            <ThemedText type="smallBold" style={styles.eyebrow} themeColor="textSecondary">
              SHORTLIST
            </ThemedText>
            <ThemedText type="small" themeColor="textSecondary">
              {visibleRecommendations.length} pick
              {visibleRecommendations.length === 1 ? '' : 's'}
            </ThemedText>
          </View>

          <View style={styles.list}>
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
        styles.featuredCard,
        {
          backgroundColor: recommendation.accentColor,
          shadowColor: theme.text,
        },
      ]}>
      <View style={styles.featuredTopRow}>
        <ThemedText type="smallBold" style={styles.featuredMeta}>
          Top match
        </ThemedText>
        <ThemedText type="smallBold" style={styles.featuredMeta}>
          {recommendation.etaMinutes} min
        </ThemedText>
      </View>

      <View style={styles.featuredBody}>
        <ThemedText type="title" style={styles.featuredDish}>
          {recommendation.dish}
        </ThemedText>
        <ThemedText type="default" style={styles.featuredReason}>
          {recommendation.reason}
        </ThemedText>
      </View>

      <View style={styles.featuredFooter}>
        <View>
          <ThemedText type="smallBold" style={styles.featuredName}>
            {recommendation.name}
          </ThemedText>
          <ThemedText type="small" style={styles.featuredDetails}>
            {recommendation.cuisine} - {recommendation.distance} - {recommendation.price}
          </ThemedText>
        </View>
        <View style={styles.ratingPill}>
          <SymbolView
            tintColor="#24140F"
            name={{ ios: 'star.fill', android: 'star', web: 'star' }}
            size={12}
          />
          <ThemedText type="smallBold" style={styles.ratingText}>
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
    <Pressable style={({ pressed }) => pressed && styles.pressed}>
      <ThemedView
        type="backgroundElement"
        style={[
          styles.recommendationRow,
          { borderColor: theme.backgroundSelected },
        ]}>
        <View style={[styles.restaurantMark, { backgroundColor: recommendation.accentColor }]}>
          <ThemedText type="smallBold" style={styles.restaurantInitial}>
            {recommendation.name.slice(0, 1)}
          </ThemedText>
        </View>
        <View style={styles.rowContent}>
          <ThemedText type="smallBold">{recommendation.name}</ThemedText>
          <ThemedText type="small" themeColor="textSecondary" numberOfLines={1}>
            {recommendation.dish}
          </ThemedText>
          <View style={styles.tagRow}>
            {recommendation.tags.slice(0, 2).map((tag) => (
              <ThemedView key={tag} type="backgroundSelected" style={styles.tag}>
                <ThemedText type="code" themeColor="textSecondary">
                  {tag}
                </ThemedText>
              </ThemedView>
            ))}
          </View>
        </View>
        <View style={styles.rowMeta}>
          <ThemedText type="smallBold">{recommendation.etaMinutes}m</ThemedText>
          <ThemedText type="small" themeColor="textSecondary">
            {recommendation.distance}
          </ThemedText>
        </View>
      </ThemedView>
    </Pressable>
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
  locationRow: {
    alignItems: 'center',
    flexDirection: 'row',
    gap: Spacing.one,
    marginBottom: Spacing.one,
  },
  title: {
    fontSize: 34,
    lineHeight: 40,
  },
  iconButton: {
    alignItems: 'center',
    borderRadius: 22,
    height: 44,
    justifyContent: 'center',
    width: 44,
  },
  pressed: {
    opacity: 0.72,
  },
  moodScroller: {
    gap: Spacing.two,
    paddingRight: Spacing.three,
  },
  moodChip: {
    borderRadius: 18,
    borderWidth: 1,
    minHeight: 36,
    paddingHorizontal: Spacing.three,
    paddingVertical: Spacing.two,
  },
  featuredCard: {
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
  featuredTopRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  featuredMeta: {
    color: '#24140F',
    textTransform: 'uppercase',
  },
  featuredBody: {
    gap: Spacing.two,
  },
  featuredDish: {
    color: '#24140F',
    fontSize: 42,
    lineHeight: 46,
  },
  featuredReason: {
    color: '#3E2A1E',
    maxWidth: 340,
  },
  featuredFooter: {
    alignItems: 'flex-end',
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: Spacing.three,
  },
  featuredName: {
    color: '#24140F',
  },
  featuredDetails: {
    color: '#3E2A1E',
  },
  ratingPill: {
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.42)',
    borderRadius: 18,
    flexDirection: 'row',
    gap: Spacing.one,
    minHeight: 34,
    paddingHorizontal: Spacing.two,
  },
  ratingText: {
    color: '#24140F',
  },
  sectionHeading: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '100%',
  },
  eyebrow: {
    letterSpacing: 0,
  },
  list: {
    gap: Spacing.two,
    width: '100%',
  },
  recommendationRow: {
    alignItems: 'center',
    borderRadius: Spacing.three,
    borderWidth: 1,
    flexDirection: 'row',
    gap: Spacing.three,
    minHeight: 104,
    padding: Spacing.three,
  },
  restaurantMark: {
    alignItems: 'center',
    borderRadius: 22,
    height: 44,
    justifyContent: 'center',
    width: 44,
  },
  restaurantInitial: {
    color: '#24140F',
  },
  rowContent: {
    flex: 1,
    gap: Spacing.one,
    minWidth: 0,
  },
  rowMeta: {
    alignItems: 'flex-end',
    gap: Spacing.one,
  },
  tagRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.one,
  },
  tag: {
    borderRadius: 10,
    paddingHorizontal: Spacing.two,
    paddingVertical: Spacing.half,
  },
});
