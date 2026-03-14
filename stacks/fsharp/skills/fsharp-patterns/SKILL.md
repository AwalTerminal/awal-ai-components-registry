# F# Patterns

## Discriminated Unions and Pattern Matching

```fsharp
// Model domain states exhaustively
type OrderStatus =
    | Pending
    | Confirmed of confirmedAt: DateTimeOffset
    | Shipped of trackingNumber: string
    | Delivered of deliveredAt: DateTimeOffset
    | Cancelled of reason: string

let describeStatus = function
    | Pending -> "Awaiting confirmation"
    | Confirmed c -> $"Confirmed at {c}"
    | Shipped t -> $"Shipped, tracking: {t}"
    | Delivered d -> $"Delivered at {d}"
    | Cancelled r -> $"Cancelled: {r}"

// Single-case DU for type-safe wrappers
type EmailAddress = EmailAddress of string
type UserId = UserId of int

let sendEmail (EmailAddress addr) subject =
    printfn $"Sending '{subject}' to {addr}"
```

## Computation Expressions

```fsharp
// Result computation expression for railway-oriented programming
type ResultBuilder() =
    member _.Bind(x, f) = Result.bind f x
    member _.Return(x) = Ok x
    member _.ReturnFrom(x) = x

let result = ResultBuilder()

let validateOrder input =
    result {
        let! name = validateName input.Name
        let! email = validateEmail input.Email
        let! qty = validateQuantity input.Qty
        return { Name = name; Email = email; Qty = qty }
    }

// Async computation expression
let fetchUserData userId = async {
    let! profile = httpGetAsync $"/users/{userId}"
    let! orders = httpGetAsync $"/users/{userId}/orders"
    return { Profile = profile; Orders = orders }
}

// Task computation expression (.NET 6+)
let fetchDataTask url = task {
    use client = new HttpClient()
    let! response = client.GetStringAsync(url)
    return JsonSerializer.Deserialize<Data>(response)
}
```

## Active Patterns

```fsharp
// Partial active pattern for validation
let (|ValidEmail|_|) (s: string) =
    if s.Contains("@") && s.Contains(".") then Some s else None

let (|ParsedInt|_|) (s: string) =
    match Int32.TryParse(s) with
    | true, n -> Some n
    | _ -> None

// Use in pattern matching
let processInput = function
    | ValidEmail e -> $"Email: {e}"
    | ParsedInt n -> $"Number: {n}"
    | s -> $"Unknown: {s}"

// Parameterized active pattern
let (|DivisibleBy|_|) d n = if n % d = 0 then Some() else None

let classify = function
    | DivisibleBy 15 -> "FizzBuzz"
    | DivisibleBy 3 -> "Fizz"
    | DivisibleBy 5 -> "Buzz"
    | n -> string n
```

## Type Providers

```fsharp
// JSON type provider — generates types from sample data
open FSharp.Data

type Weather = JsonProvider<""" {"temp": 20.5, "city": "London"} """>

let parseWeather json =
    let w = Weather.Parse(json)
    printfn $"Temperature in {w.City}: {w.Temp}°C"

// CSV type provider
type Sales = CsvProvider<"sample.csv">

let totalRevenue () =
    Sales.Load("sales.csv").Rows
    |> Seq.sumBy (fun row -> row.Price * decimal row.Quantity)
```

## Railway-Oriented Programming

```fsharp
// Composable validation with Result
type ValidationError = { Field: string; Message: string }

let validate pred field msg value =
    if pred value then Ok value
    else Error { Field = field; Message = msg }

let validateAge =
    validate (fun a -> a >= 0 && a <= 150) "age" "Must be between 0 and 150"

let validateName =
    validate (fun n -> String.length n >= 2) "name" "Must be at least 2 chars"

// Collect all errors instead of failing fast
let validateAll validators input =
    validators
    |> List.map (fun v -> v input)
    |> List.choose (function Error e -> Some e | _ -> None)
    |> function
        | [] -> Ok input
        | errors -> Error errors
```

## Concurrency: Async, MailboxProcessor

```fsharp
// MailboxProcessor for actor-style concurrency
type CounterMsg = Increment | Decrement | Get of AsyncReplyChannel<int>

let counter = MailboxProcessor.Start(fun inbox ->
    let rec loop count = async {
        let! msg = inbox.Receive()
        match msg with
        | Increment -> return! loop (count + 1)
        | Decrement -> return! loop (count - 1)
        | Get ch -> ch.Reply(count); return! loop count
    }
    loop 0)

counter.Post(Increment)
counter.Post(Increment)
let count = counter.PostAndReply(Get) // 2

// Parallel async operations
let fetchAll urls = async {
    let! results =
        urls
        |> List.map httpGetAsync
        |> Async.Parallel
    return results
}
```

## .NET Interop

```fsharp
// Using .NET classes idiomatically
open System.Collections.Generic

let cache = Dictionary<string, int>()
cache["key"] <- 42

// IDisposable with use binding
let readFile path =
    use reader = new StreamReader(path)
    reader.ReadToEnd()

// Object expressions for quick interface implementation
let comparer =
    { new IComparer<string> with
        member _.Compare(a, b) = String.Compare(a, b, StringComparison.OrdinalIgnoreCase) }
```

## Testing with Expecto and FsCheck

```fsharp
open Expecto
open FsCheck

let tests = testList "validation" [
    test "valid email passes" {
        let result = validateEmail "user@example.com"
        Expect.isOk result "Should accept valid email"
    }
    test "invalid email fails" {
        let result = validateEmail "invalid"
        Expect.isError result "Should reject invalid email"
    }
    testProperty "roundtrip serialization" <| fun (x: int) ->
        x |> serialize |> deserialize = x
]

[<EntryPoint>]
let main args = runTestsWithCLIArgs [] args tests
```
