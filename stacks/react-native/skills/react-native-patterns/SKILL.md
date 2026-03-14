# React Native Patterns

## Component Design

### Platform-Specific Code

Use platform-specific file extensions for divergent implementations:

```
components/
  Button.tsx            # shared logic
  Button.ios.tsx        # iOS-specific rendering
  Button.android.tsx    # Android-specific rendering
```

For small differences, use `Platform.select`:

```tsx
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  shadow: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 4,
    },
    android: {
      elevation: 4,
    },
  }),
  container: {
    paddingTop: Platform.OS === 'ios' ? 44 : 0,
  },
});
```

### Responsive Design

```tsx
import { useWindowDimensions } from 'react-native';

function useResponsive() {
  const { width, height } = useWindowDimensions();

  return {
    isSmall: width < 375,
    isMedium: width >= 375 && width < 768,
    isLarge: width >= 768,
    isLandscape: width > height,
    width,
    height,
  };
}

function ProductGrid() {
  const { isLarge } = useResponsive();
  const numColumns = isLarge ? 3 : 2;

  return (
    <FlatList
      data={products}
      numColumns={numColumns}
      key={numColumns} // force re-render when columns change
      renderItem={({ item }) => <ProductCard product={item} />}
      keyExtractor={(item) => item.id}
    />
  );
}
```

## Navigation (React Navigation)

### Typed Navigation

```tsx
// navigation/types.ts
export type RootStackParamList = {
  Home: undefined;
  Profile: { userId: string };
  Settings: undefined;
  PostDetail: { postId: string; title: string };
};

export type TabParamList = {
  Feed: undefined;
  Search: undefined;
  Notifications: undefined;
};

// Use declaration merging for global type safety
declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}
```

```tsx
// navigation/RootNavigator.tsx
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import type { RootStackParamList } from './types';

const Stack = createNativeStackNavigator<RootStackParamList>();

function RootNavigator() {
  const { user } = useAuth();

  return (
    <Stack.Navigator>
      {user ? (
        <>
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen
            name="Profile"
            component={ProfileScreen}
            options={({ route }) => ({ title: route.params.userId })}
          />
        </>
      ) : (
        <Stack.Screen
          name="Login"
          component={LoginScreen}
          options={{ headerShown: false }}
        />
      )}
    </Stack.Navigator>
  );
}
```

```tsx
// Type-safe navigation in components
import { useNavigation, useRoute } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '@/navigation/types';

type ProfileScreenRouteProp = RouteProp<RootStackParamList, 'Profile'>;

function ProfileScreen() {
  const route = useRoute<ProfileScreenRouteProp>();
  const navigation = useNavigation();
  const { userId } = route.params;

  return (
    <Button
      title="Edit"
      onPress={() => navigation.navigate('Settings')}
    />
  );
}
```

### Deep Linking

```tsx
const linking: LinkingOptions<RootStackParamList> = {
  prefixes: ['myapp://', 'https://myapp.com'],
  config: {
    screens: {
      Home: '',
      Profile: 'user/:userId',
      PostDetail: 'post/:postId',
    },
  },
};

function App() {
  return (
    <NavigationContainer linking={linking} fallback={<SplashScreen />}>
      <RootNavigator />
    </NavigationContainer>
  );
}
```

## Performance

### FlatList Optimization

```tsx
function OptimizedList({ data }: { data: Item[] }) {
  const renderItem = useCallback(
    ({ item }: { item: Item }) => <ListItem item={item} />,
    [],
  );

  const keyExtractor = useCallback((item: Item) => item.id, []);

  return (
    <FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      // Performance props
      removeClippedSubviews={true}      // unmount off-screen items (Android)
      maxToRenderPerBatch={10}           // items per render batch
      windowSize={5}                     // render window multiplier
      initialNumToRender={10}            // items rendered on first paint
      getItemLayout={(_, index) => ({    // skip measurement if height is fixed
        length: ITEM_HEIGHT,
        offset: ITEM_HEIGHT * index,
        index,
      })}
      // Or use FlashList for better performance out of the box
    />
  );
}

// Memoize list items to prevent re-renders when parent updates
const ListItem = React.memo(function ListItem({ item }: { item: Item }) {
  return (
    <View style={styles.row}>
      <Text>{item.title}</Text>
      <Text>{item.subtitle}</Text>
    </View>
  );
});
```

### Reanimated for 60fps Animations

```tsx
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  interpolate,
} from 'react-native-reanimated';

function SwipeableCard({ onDismiss }: { onDismiss: () => void }) {
  const translateX = useSharedValue(0);

  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = event.translationX;
    })
    .onEnd((event) => {
      if (Math.abs(event.translationX) > 150) {
        translateX.value = withTiming(
          Math.sign(event.translationX) * 500,
          {},
          () => runOnJS(onDismiss)(),
        );
      } else {
        translateX.value = withSpring(0);
      }
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
    opacity: interpolate(
      Math.abs(translateX.value),
      [0, 150],
      [1, 0.5],
    ),
  }));

  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={[styles.card, animatedStyle]}>
        <CardContent />
      </Animated.View>
    </GestureDetector>
  );
}
```

### Hermes Engine

Hermes is enabled by default in React Native 0.70+. Benefits:
- Faster startup via bytecode precompilation
- Lower memory usage
- Improved garbage collection

Verify Hermes is active:
```tsx
const isHermes = () => !!(global as any).HermesInternal;
```

## New Architecture (Fabric + TurboModules)

### TurboModules

TurboModules replace the old bridge with synchronous, lazy-loaded native module access:

```typescript
// specs/NativeCalculator.ts
import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  add(a: number, b: number): number; // synchronous
  fetchData(url: string): Promise<string>; // async
}

export default TurboModuleRegistry.getEnforcing<Spec>('Calculator');
```

### Fabric Components

Fabric is the new rendering system. It enables synchronous layout and concurrent features:

```typescript
// specs/NativeMapView.ts
import type { ViewProps } from 'react-native';
import type { HostComponent } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';

interface NativeMapViewProps extends ViewProps {
  latitude: number;
  longitude: number;
  zoomLevel: number;
  onRegionChange?: (event: { nativeEvent: Region }) => void;
}

export default codegenNativeComponent<NativeMapViewProps>(
  'MapView',
) as HostComponent<NativeMapViewProps>;
```

## Native Module Bridging

For custom native functionality not covered by existing libraries:

```tsx
// Bridge pattern with type-safe wrapper
import { NativeModules, NativeEventEmitter } from 'react-native';

interface BiometricModule {
  isAvailable(): Promise<boolean>;
  authenticate(reason: string): Promise<{ success: boolean }>;
}

const { BiometricAuth } = NativeModules as { BiometricAuth: BiometricModule };

export function useBiometric() {
  const [available, setAvailable] = useState(false);

  useEffect(() => {
    BiometricAuth.isAvailable().then(setAvailable);
  }, []);

  const authenticate = useCallback(async () => {
    if (!available) return false;
    try {
      const result = await BiometricAuth.authenticate('Verify identity');
      return result.success;
    } catch {
      return false;
    }
  }, [available]);

  return { available, authenticate };
}
```

## Testing

### React Native Testing Library

```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react-native';

test('login form submits credentials', async () => {
  const onLogin = jest.fn();
  render(<LoginScreen onLogin={onLogin} />);

  fireEvent.changeText(screen.getByPlaceholderText('Email'), 'user@test.com');
  fireEvent.changeText(screen.getByPlaceholderText('Password'), 'secret');
  fireEvent.press(screen.getByText('Sign In'));

  await waitFor(() => {
    expect(onLogin).toHaveBeenCalledWith('user@test.com', 'secret');
  });
});

test('displays error on failed login', async () => {
  const onLogin = jest.fn().mockRejectedValue(new Error('Invalid'));
  render(<LoginScreen onLogin={onLogin} />);

  fireEvent.changeText(screen.getByPlaceholderText('Email'), 'bad@test.com');
  fireEvent.changeText(screen.getByPlaceholderText('Password'), 'wrong');
  fireEvent.press(screen.getByText('Sign In'));

  await waitFor(() => {
    expect(screen.getByText('Invalid credentials')).toBeTruthy();
  });
});
```

### Detox E2E Tests

```typescript
describe('Onboarding Flow', () => {
  beforeAll(async () => {
    await device.launchApp({ newInstance: true });
  });

  it('completes onboarding and reaches home', async () => {
    await expect(element(by.text('Welcome'))).toBeVisible();
    await element(by.text('Next')).tap();

    await expect(element(by.text('Set up your profile'))).toBeVisible();
    await element(by.id('name-input')).typeText('Alice');
    await element(by.text('Continue')).tap();

    await expect(element(by.text('Home'))).toBeVisible();
  });

  it('persists onboarding completion', async () => {
    await device.launchApp({ newInstance: false });
    await expect(element(by.text('Home'))).toBeVisible();
    await expect(element(by.text('Welcome'))).not.toBeVisible();
  });
});
```

## State Management

Use the same patterns as React web, with mobile-specific persistence:

```tsx
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

const useSettingsStore = create(
  persist<SettingsState>(
    (set) => ({
      theme: 'system',
      notifications: true,
      setTheme: (theme) => set({ theme }),
      toggleNotifications: () =>
        set((s) => ({ notifications: !s.notifications })),
    }),
    {
      name: 'settings',
      storage: createJSONStorage(() => AsyncStorage),
    },
  ),
);
```
