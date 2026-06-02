import { useCallback, useRef, useState, type ComponentRef } from 'react';
import { View, type GestureResponderEvent, type LayoutChangeEvent } from 'react-native';

import { ThemedView } from '@/components/themed-view';
import { useTheme } from '@/hooks/use-theme';
import { clamp } from '@/utils/slider';

export type RangeSliderProps = {
  onChange: (value: number) => void;
  onSlidingChange?: (isSliding: boolean) => void;
  stepCount?: number;
  value: number;
};

const ThumbSize = 28;
const TrackHorizontalInset = ThumbSize / 2;

export default function RangeSlider({
  onChange,
  onSlidingChange,
  stepCount,
  value,
}: RangeSliderProps) {
  const theme = useTheme();
  const trackRef = useRef<ComponentRef<typeof View>>(null);
  const trackMetricsRef = useRef({ x: 0, width: 0 });
  const [trackWidth, setTrackWidth] = useState(0);

  const updateFromPageX = useCallback(
    (pageX: number) => {
      const { width, x } = trackMetricsRef.current;
      if (width <= 0) {
        return;
      }

      const usableWidth = Math.max(width - TrackHorizontalInset * 2, 1);
      const nextValue = (pageX - x - TrackHorizontalInset) / usableWidth;

      if (stepCount && stepCount > 1) {
        onChange(Math.round(clamp(nextValue) * (stepCount - 1)) / (stepCount - 1));
        return;
      }

      onChange(clamp(nextValue));
    },
    [onChange, stepCount]
  );

  const measureTrack = useCallback((onMeasured?: () => void) => {
    trackRef.current?.measureInWindow((x: number, _y: number, width: number) => {
      trackMetricsRef.current = { x, width };
      setTrackWidth(width);
      onMeasured?.();
    });
  }, []);

  const updateFromEvent = useCallback(
    (event: GestureResponderEvent) => {
      updateFromPageX(event.nativeEvent.pageX);
    },
    [updateFromPageX]
  );

  const handleResponderGrant = useCallback(
    (event: GestureResponderEvent) => {
      const pageX = event.nativeEvent.pageX;
      onSlidingChange?.(true);
      measureTrack(() => updateFromPageX(pageX));
    },
    [measureTrack, onSlidingChange, updateFromPageX]
  );

  const handleResponderEnd = useCallback(() => {
    onSlidingChange?.(false);
  }, [onSlidingChange]);

  function handleTrackLayout(event: LayoutChangeEvent) {
    setTrackWidth(event.nativeEvent.layout.width);
    measureTrack();
  }

  const clampedValue = clamp(value);
  const usableTrackWidth = Math.max(trackWidth - TrackHorizontalInset * 2, 0);
  const thumbOffset = TrackHorizontalInset + usableTrackWidth * clampedValue;

  return (
    <View
      ref={trackRef}
      className="relative h-11 w-full justify-center"
      onLayout={handleTrackLayout}
      onMoveShouldSetResponder={() => true}
      onResponderGrant={handleResponderGrant}
      onResponderMove={updateFromEvent}
      onResponderRelease={handleResponderEnd}
      onResponderTerminate={handleResponderEnd}
      onResponderTerminationRequest={() => false}
      onStartShouldSetResponder={() => true}>
      <ThemedView
        type="backgroundSelected"
        className="relative h-2.5 overflow-hidden rounded-[5px]"
        style={{ marginHorizontal: TrackHorizontalInset }}>
        <ThemedView
          type="text"
          className="h-full rounded-[5px]"
          style={{ width: `${clampedValue * 100}%` }}
        />
      </ThemedView>

      {stepCount && stepCount > 1 ? (
        <View
          pointerEvents="none"
          className="absolute inset-y-0"
          style={{ left: TrackHorizontalInset, right: TrackHorizontalInset }}>
          {Array.from({ length: stepCount }).map((_, index) => (
            <ThemedView
              key={index}
              type="background"
              className="absolute top-1/2 h-1.5 w-1.5 rounded-[3px]"
              style={{
                left: `${(index / (stepCount - 1)) * 100}%`,
                marginLeft: -3,
                transform: [{ translateY: -3 }],
              }}
            />
          ))}
        </View>
      ) : null}

      <ThemedView
        type="background"
        className="absolute top-2 h-7 w-7 rounded-[14px] border-[3px]"
        style={{
          borderColor: theme.text,
          left: thumbOffset,
          marginLeft: -TrackHorizontalInset,
        }}
      />
    </View>
  );
}
