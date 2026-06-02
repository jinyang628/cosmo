import { useCallback, useRef, useState, type ComponentRef } from 'react';
import { View, type GestureResponderEvent, type LayoutChangeEvent } from 'react-native';

import { useTheme } from '@/hooks/use-theme';
import { clamp } from '@/utils/slider';

export type RangeSliderProps = {
  onChange: (value: number) => void;
  onSlidingChange?: (isSliding: boolean) => void;
  stepCount?: number;
  value: number;
};

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

      const nextValue = (pageX - x) / width;
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
  const thumbOffset = trackWidth * clampedValue;

  return (
    <View
      ref={trackRef}
      style={{
        height: 44,
        justifyContent: 'center',
        position: 'relative',
        width: '100%',
      }}
      onLayout={handleTrackLayout}
      onMoveShouldSetResponder={() => true}
      onResponderGrant={handleResponderGrant}
      onResponderMove={updateFromEvent}
      onResponderRelease={handleResponderEnd}
      onResponderTerminate={handleResponderEnd}
      onResponderTerminationRequest={() => false}
      onStartShouldSetResponder={() => true}>
      <View
        style={{
          backgroundColor: theme.backgroundSelected,
          borderRadius: 5,
          height: 10,
          overflow: 'hidden',
          width: '100%',
        }}>
        <View
          style={{
            backgroundColor: theme.text,
            borderRadius: 5,
            height: '100%',
            width: `${clampedValue * 100}%`,
          }}
        />
      </View>

      {stepCount ? (
        <View
          style={{
            bottom: 0,
            left: 0,
            position: 'absolute',
            right: 0,
            top: 0,
          }}>
          {Array.from({ length: stepCount }).map((_, index) => (
            <View
              key={index}
              style={{
                backgroundColor: theme.background,
                borderRadius: 3,
                height: 6,
                left: `${(index / (stepCount - 1)) * 100}%`,
                marginLeft: -3,
                position: 'absolute',
                top: 19,
                width: 6,
              }}
            />
          ))}
        </View>
      ) : null}

      <View
        style={{
          backgroundColor: theme.background,
          borderColor: theme.text,
          borderRadius: 14,
          borderWidth: 3,
          height: 28,
          left: thumbOffset,
          marginLeft: -14,
          position: 'absolute',
          top: 8,
          width: 28,
        }}
      />
    </View>
  );
}
