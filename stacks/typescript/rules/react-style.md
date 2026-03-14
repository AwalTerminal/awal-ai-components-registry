# React Style Rules (TypeScript Projects)

- Use functional components exclusively -- no class components in new code
- Name component files in `PascalCase.tsx` -- one exported component per file
- Name hooks `use<Name>.ts` -- custom hooks always start with `use`
- Use named exports for components -- default exports only for lazy-loaded route pages
- Prefer `interface` for component props: `interface ButtonProps { ... }`
- Destructure props in the function signature: `function Button({ label, onClick }: ButtonProps)`
- Use `React.memo` only when profiling proves a component re-renders unnecessarily with the same props
- Use `useCallback` and `useMemo` only when the value is passed to a memoized child or is a hook dependency
- Never use `useEffect` for derived state -- use direct computation or `useMemo` instead
- Keep components under 150 lines -- extract hooks and sub-components when they grow
- Use React Testing Library -- query by role, label, or text, never by CSS class or test ID unless unavoidable
- Avoid `index.tsx` barrel files in large projects -- they cause bundler issues and circular dependencies
- Use `eslint-plugin-react-hooks` with the `exhaustive-deps` rule enforced as error
- Use `Suspense` boundaries around lazy-loaded components and data fetching
- Keep state as local as possible -- lift only when multiple siblings need the same data
