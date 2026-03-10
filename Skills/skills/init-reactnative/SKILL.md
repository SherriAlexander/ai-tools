---
name: init-reactnative
description: Initialize React Native 0.76+ best practices
---

# Initialize React Native Best Practices

Add React Native 0.76+ best practices. **Follow `~/.copilot/skills/init-conventions/SKILL.md` for standard file handling.**

## Target File

`.github/instructions/reactnative.instructions.md`

## Path Pattern

`**/*.{tsx,jsx}`

## Content

<!-- RULES_START -->
---
applyTo: "**/*.{tsx,jsx}"
---

# React Native 0.76+ Rules

### New Architecture (Default in 0.76)
- **Fabric**: Synchronous layout via `useLayoutEffect`, cross-platform `boxShadow`/`filter`
- **TurboModules**: Lazy-loaded, type-safe. Use `TurboModuleRegistry.get<Spec>()` not `NativeModules`
- **JSI**: Direct native calls, no async bridge
- **Concurrent React**: Wrap expensive updates in `startTransition`, use Suspense boundaries

### List Performance (Critical)

```typescript
<FlashList  // Use for 100+ items
  data={data}
  renderItem={renderItem}  // Define outside component or useCallback
  estimatedItemSize={80}
  keyExtractor={(item) => item.id}  // NEVER use index
/>

// FlatList optimization
<FlatList
  getItemLayout={(_, i) => ({ length: HEIGHT, offset: HEIGHT * i, index: i })}
  windowSize={5}
  initialNumToRender={10}
  maxToRenderPerBatch={5}
  removeClippedSubviews={true}
/>
```

### Re-render Prevention

```typescript
// Wrap list items
const ListItem = React.memo(({ item, onPress }) => { });

// Stable callbacks
const handlePress = useCallback((id) => navigate('Detail', { id }), [navigate]);

// Memoize expensive computations
const filtered = useMemo(() => data.filter(pred), [data, pred]);
```

### Animations

**Animated API**: Always `useNativeDriver: true` (transform/opacity only)

**Reanimated 3** (gesture-driven, layout props, 120fps):
```typescript
const translateX = useSharedValue(0);
const style = useAnimatedStyle(() => ({ transform: [{ translateX: translateX.value }] }));

// Prefer withSpring over withTiming for natural feel
translateX.value = withSpring(0);
```

### Native Feel

**Platform-specific**:
```typescript
const styles = StyleSheet.create({
  shadow: Platform.select({
    ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.1 },
    android: { elevation: 4 },
  }),
});
// Or use file extensions: Button.ios.tsx / Button.android.tsx
```

**Touch targets**: 44pt (iOS), 48dp (Android)

**Navigation**: Use `\@react-navigation/native-stack` (native performance)

**Safe areas**: `useSafeAreaInsets()` hook, not SafeAreaView component

**Keyboard**: `behavior="padding"` (iOS), `behavior="height"` (Android)

**Gestures**:
```typescript
<GestureHandlerRootView style={{ flex: 1 }}>
  <App />
</GestureHandlerRootView>

const pan = Gesture.Pan()
  .onUpdate((e) => { translateX.value = e.translationX; })
  .onEnd(() => { translateX.value = withSpring(0); });
```

**Haptics**: `Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium)`

### State Management

| Use | For |
|-----|-----|
| TanStack Query | Server/API state |
| Zustand | Client state (3KB, simple) |
| MMKV | Persistence (fastest) |

```typescript
// Zustand with selectors (prevents re-renders)
const user = useAuthStore((state) => state.user);

// Never put API responses in Redux/Zustand — use TanStack Query
```

### Styling

- **Always `StyleSheet.create`** outside component
- **Memoize dynamic styles** with `useMemo`
- **`useWindowDimensions()`** not `Dimensions.get()`
- **Dark mode**: `useColorScheme()` returns `'light' | 'dark' | null`

### TypeScript

```typescript
// Navigation typing
export type RootStackParamList = { Home: undefined; Profile: { userId: string } };
declare global { namespace ReactNavigation { interface RootParamList extends RootStackParamList {} } }

// Screen props
type Props = NativeStackScreenProps<RootStackParamList, 'Profile'>;
```

### Memory & Startup

```typescript
// Always cleanup
useEffect(() => {
  const sub = source.subscribe(handler);
  return () => sub.unsubscribe();
}, []);

// AbortController for fetch
useEffect(() => {
  const controller = new AbortController();
  fetch(url, { signal: controller.signal });
  return () => controller.abort();
}, [url]);

// Defer heavy work
InteractionManager.runAfterInteractions(() => { /* expensive op */ });
```

**Metro config**: `transform: { inlineRequires: true }`

### Build Optimization

**Android**:
```groovy
minifyEnabled true
shrinkResources true
splits { abi { enable true; include 'armeabi-v7a', 'arm64-v8a' } }
```

**Bundle size**:
- Hermes enabled (default) — 30-70% faster TTI
- Cherry-pick: `import debounce from 'lodash/debounce'`
- Remove console: `babel-plugin-transform-remove-console`
- AAB format for Play Store (20-30% smaller)

**OTA**: `eas update --channel production`

### Testing

```typescript
// React Native Testing Library
fireEvent.press(screen.getByRole('button', { name: 'Submit' }));
await waitFor(() => expect(onSubmit).toHaveBeenCalled());

// Query priority: getByRole > getByText > getByTestId
// E2E: Detox
```

### Common Mistakes

- Never use array index as key — use stable unique ID
- Never use inline styles in lists — StyleSheet outside component
- Never skip useEffect cleanup — always return cleanup function
- Never block JS thread during animation — use `InteractionManager.runAfterInteractions`
- Never use `useNativeDriver: false` — use `true` for transform/opacity
- Never pass callbacks in nav params — use event emitters or state management
- Never use SafeAreaView component — use `useSafeAreaInsets()` hook
- Never use `Dimensions.get()` — use `useWindowDimensions()`
- Never put API data in Redux/Zustand — use TanStack Query for server state
- Never deep import between features — export only from `feature/index.ts`

### Quick Reference

| Need | Solution |
|------|----------|
| Long lists (100+) | FlashList |
| Fixed-height lists | `getItemLayout` |
| Gestures | Gesture Handler + Reanimated |
| Server state | TanStack Query |
| Client state | Zustand |
| Storage | MMKV |
| Navigation | native-stack + typed params |
| Animations | Reanimated 3 / Animated + useNativeDriver |
| Safe areas | `useSafeAreaInsets()` |
<!-- RULES_END -->
