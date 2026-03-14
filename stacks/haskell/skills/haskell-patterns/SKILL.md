# Haskell Patterns

## Algebraic Data Types and Pattern Matching

Define domain models with sum and product types. Use pattern matching exhaustively.

```haskell
data Shape
  = Circle Double
  | Rectangle Double Double
  | Triangle Double Double Double
  deriving (Show, Eq)

area :: Shape -> Double
area (Circle r)        = pi * r * r
area (Rectangle w h)   = w * h
area (Triangle a b c)  = let s = (a + b + c) / 2
                          in sqrt (s * (s-a) * (s-b) * (s-c))

-- Newtype wrappers for type safety
newtype UserId = UserId Int deriving (Show, Eq, Ord)
newtype Email  = Email Text deriving (Show, Eq)
```

## Type Classes

Define interfaces with type classes; provide default implementations where useful.

```haskell
class Describable a where
  describe :: a -> Text
  shortDesc :: a -> Text
  shortDesc = T.take 50 . describe  -- default impl

instance Describable Shape where
  describe (Circle r)      = "Circle with radius " <> T.pack (show r)
  describe (Rectangle w h) = "Rectangle " <> T.pack (show w) <> "x" <> T.pack (show h)

-- Deriving via for mechanical instances
newtype Dollars = Dollars Double
  deriving newtype (Num, Show, Eq, Ord)
```

## Monads: IO, Maybe, Either, Reader, State

```haskell
-- Maybe for optional values — never use fromJust
lookupUser :: UserId -> Map UserId User -> Maybe User
lookupUser uid db = Map.lookup uid db >>= \u ->
  if isActive u then Just u else Nothing

-- Either for error handling with context
data AppError = NotFound Text | ParseError Text | Unauthorized
  deriving (Show)

validateAge :: Int -> Either AppError Int
validateAge n
  | n < 0     = Left (ParseError "Age cannot be negative")
  | n > 150   = Left (ParseError "Unrealistic age")
  | otherwise  = Right n

-- Reader for dependency injection
type App = ReaderT Config IO

getDbUrl :: App String
getDbUrl = asks configDbUrl

runApp :: Config -> App a -> IO a
runApp cfg app = runReaderT app cfg

-- State for threaded mutable state
type Counter = State Int

increment :: Counter ()
increment = modify' (+1)

runCounter :: Counter a -> Int -> (a, Int)
runCounter = runState
```

## Lens and Optics

```haskell
{-# LANGUAGE TemplateHaskell #-}
import Control.Lens

data Address = Address
  { _street :: Text
  , _city   :: Text
  , _zip    :: Text
  } deriving (Show)
makeLenses ''Address

data Person = Person
  { _name    :: Text
  , _age     :: Int
  , _address :: Address
  } deriving (Show)
makeLenses ''Person

-- Compose lenses to reach nested fields
updateCity :: Text -> Person -> Person
updateCity newCity = address . city .~ newCity

-- Traverse over collections
allCities :: [Person] -> [Text]
allCities = toListOf (each . address . city)
```

## Concurrency: STM, Async, ForkIO

```haskell
import Control.Concurrent.STM
import Control.Concurrent.Async

-- STM for composable atomic transactions
transfer :: TVar Int -> TVar Int -> Int -> STM ()
transfer from to amount = do
  bal <- readTVar from
  when (bal < amount) retry  -- blocks until sufficient
  modifyTVar' from (subtract amount)
  modifyTVar' to   (+ amount)

-- Async for structured concurrency
fetchBoth :: IO (Response, Response)
fetchBoth = concurrently (httpGet urlA) (httpGet urlB)

-- Race returns first to complete, cancels the other
withTimeout :: Int -> IO a -> IO (Maybe a)
withTimeout us action = do
  result <- race (threadDelay us) action
  pure $ case result of
    Left _  -> Nothing
    Right a -> Just a
```

## Performance: Strictness and Bang Patterns

```haskell
{-# LANGUAGE BangPatterns #-}

-- Strict accumulator to avoid space leaks
sumStrict :: [Int] -> Int
sumStrict = go 0
  where
    go !acc []     = acc
    go !acc (x:xs) = go (acc + x) xs

-- Use strict fields in data types
data Stats = Stats
  { count :: !Int
  , total :: !Double
  , mean  :: !Double
  } deriving (Show)

-- Prefer strict containers
import qualified Data.Map.Strict as Map
import qualified Data.HashMap.Strict as HMap

-- Use Text and ByteString, never String for performance
import qualified Data.Text as T
import qualified Data.ByteString as BS
```

## Error Handling Patterns

```haskell
-- Chain operations that may fail with do-notation
processOrder :: OrderId -> App (Either AppError Receipt)
processOrder oid = runExceptT $ do
  order   <- ExceptT $ findOrder oid
  user    <- ExceptT $ findUser (orderUserId order)
  payment <- ExceptT $ chargeUser user (orderTotal order)
  pure (Receipt order payment)

-- Convert between Maybe and Either
requireField :: Text -> Maybe a -> Either AppError a
requireField name = maybe (Left (NotFound name)) Right
```

## Testing with HSpec and QuickCheck

```haskell
spec :: Spec
spec = do
  describe "validateAge" $ do
    it "rejects negative ages" $
      validateAge (-1) `shouldBe` Left (ParseError "Age cannot be negative")
    it "accepts valid ages" $
      validateAge 25 `shouldBe` Right 25

  describe "area" $ do
    it "satisfies circle area property" $ property $ \(Positive r) ->
      area (Circle r) `shouldBe` pi * r * r
    it "rectangle area is always positive" $ property $ \(Positive w) (Positive h) ->
      area (Rectangle w h) > 0
```
