# Scala Patterns

## Type Classes

```scala
// Define a type class
trait JsonEncoder[A]:
  extension (a: A) def toJson: String

// Provide instances
given JsonEncoder[String] with
  extension (s: String) def toJson: String = s"\"$s\""

given JsonEncoder[Int] with
  extension (n: Int) def toJson: String = n.toString

given [A: JsonEncoder]: JsonEncoder[List[A]] with
  extension (xs: List[A]) def toJson: String =
    xs.map(_.toJson).mkString("[", ",", "]")

// Use with context bounds
def serialize[A: JsonEncoder](value: A): String = value.toJson

serialize(List(1, 2, 3))  // "[1,2,3]"
```

## Higher-Kinded Types

```scala
// Functor for any container type F[_]
trait Functor[F[_]]:
  extension [A](fa: F[A])
    def map[B](f: A => B): F[B]

given Functor[Option] with
  extension [A](fa: Option[A])
    def map[B](f: A => B): Option[B] = fa match
      case Some(a) => Some(f(a))
      case None    => None

given Functor[List] with
  extension [A](fa: List[A])
    def map[B](f: A => B): List[B] = fa.map(f)

// Generic function that works with any Functor
def double[F[_]: Functor](fa: F[Int]): F[Int] = fa.map(_ * 2)

double(Some(5))     // Some(10)
double(List(1,2,3)) // List(2,4,6)
```

## Phantom Types for Type-Safe State

```scala
sealed trait DoorState
sealed trait Open extends DoorState
sealed trait Closed extends DoorState

case class Door[S <: DoorState] private (name: String):
  def open(using S =:= Closed): Door[Open] = Door(name)
  def close(using S =:= Open): Door[Closed] = Door(name)

object Door:
  def closed(name: String): Door[Closed] = Door(name)

val door = Door.closed("front")
val opened = door.open       // Door[Open]
val closed = opened.close    // Door[Closed]
// opened.open  // Compile error: cannot open an already-open door
```

## Pattern Matching

```scala
// Exhaustive matching with sealed hierarchies
enum Shape:
  case Circle(radius: Double)
  case Rectangle(width: Double, height: Double)
  case Triangle(base: Double, height: Double)

def area(shape: Shape): Double = shape match
  case Shape.Circle(r)         => math.Pi * r * r
  case Shape.Rectangle(w, h)   => w * h
  case Shape.Triangle(b, h)    => 0.5 * b * h

// Guard clauses and nested extraction
def classify(value: Any): String = value match
  case n: Int if n > 0        => "positive int"
  case s: String if s.nonEmpty => s"string: $s"
  case (a, b)                  => s"tuple: ($a, $b)"
  case list: List[?] if list.length > 3 => "long list"
  case _                       => "unknown"

// Extractor objects
object Email:
  def unapply(s: String): Option[(String, String)] =
    s.split("@") match
      case Array(user, domain) => Some((user, domain))
      case _ => None

"user@example.com" match
  case Email(user, domain) => s"User: $user, Domain: $domain"
```

## For-Comprehensions

```scala
// Chaining Option, Either, Future — anything with flatMap/map
def findUser(id: Int): Option[User] = ???
def findAddress(user: User): Option[Address] = ???
def findCity(address: Address): Option[String] = ???

val city: Option[String] = for
  user    <- findUser(42)
  address <- findAddress(user)
  city    <- findCity(address)
yield city

// With Either for error tracking
type Result[A] = Either[String, A]

def validateAge(age: Int): Result[Int] =
  if age >= 0 && age <= 150 then Right(age) else Left("Invalid age")

def validateName(name: String): Result[String] =
  if name.nonEmpty then Right(name) else Left("Name required")

val validated: Result[(String, Int)] = for
  name <- validateName("Alice")
  age  <- validateAge(30)
yield (name, age)
```

## Concurrency with Futures

```scala
import scala.concurrent.Future
import scala.concurrent.ExecutionContext.Implicits.global

// Sequential via for-comprehension
val userOrders: Future[List[Order]] = for
  user   <- Future { db.findUser(42) }
  orders <- Future { db.findOrders(user.id) }
yield orders

// Parallel — start futures before combining
val userF = Future { db.findUser(42) }
val ordersF = Future { db.findOrders(42) }
val both = for (u <- userF; o <- ordersF) yield (u, o)
```

## ZIO / Cats Effect Patterns

```scala
import zio.*

// ZIO — typed errors, dependency injection via environment
def fetchUser(id: Int): ZIO[Database, NotFoundError, User] =
  ZIO.serviceWithZIO[Database](_.find(id))

def sendEmail(user: User): ZIO[EmailService, SendError, Unit] =
  ZIO.serviceWithZIO[EmailService](_.send(user.email, "Welcome!"))

val program: ZIO[Database & EmailService, NotFoundError | SendError, Unit] = for
  user <- fetchUser(42)
  _    <- sendEmail(user)
yield ()

// Provide dependencies at the edge
val runnable = program.provide(
  DatabaseLive.layer,
  EmailServiceLive.layer
)
```

## Performance

- **Tail recursion**: annotate with `@tailrec` to guarantee optimization
- **Lazy evaluation**: use `lazy val` for expensive computations deferred until first access
- **Collection performance**: prefer `Vector` for random access, `List` for prepend-heavy, `ArrayBuffer` for mutable sequential
- Use `.view` for lazy intermediate collections in chained operations
- Avoid implicit conversions in hot paths — they create allocations

```scala
import scala.annotation.tailrec

@tailrec
def factorial(n: Long, acc: Long = 1): Long =
  if n <= 1 then acc else factorial(n - 1, n * acc)

lazy val expensiveConfig: Config = loadFromDisk()
```

## Testing

### ScalaTest

```scala
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

class MoneySpec extends AnyFlatSpec with Matchers:
  "Money" should "add same currencies" in {
    val a = Money(100, "USD")
    val b = Money(50, "USD")
    (a + b).amount shouldBe 150
  }

  it should "reject different currencies" in {
    val a = Money(100, "USD")
    val b = Money(50, "EUR")
    an[CurrencyMismatchException] should be thrownBy (a + b)
  }
```

### ScalaCheck (Property-Based Testing)

```scala
import org.scalacheck.Properties
import org.scalacheck.Prop.forAll

object MoneyProperties extends Properties("Money"):
  property("addition is commutative") = forAll { (a: Int, b: Int) =>
    Money(a, "USD") + Money(b, "USD") == Money(b, "USD") + Money(a, "USD")
  }

  property("addition is associative") = forAll { (a: Int, b: Int, c: Int) =>
    val x = Money(a, "USD")
    val y = Money(b, "USD")
    val z = Money(c, "USD")
    (x + y) + z == x + (y + z)
  }
```

## SBT Patterns

```scala
// build.sbt
ThisBuild / scalaVersion := "3.4.0"

lazy val root = project.in(file("."))
  .settings(
    name := "my-app",
    libraryDependencies ++= Seq(
      "dev.zio"       %% "zio"        % "2.0.21",
      "org.scalatest" %% "scalatest"  % "3.2.18" % Test,
    ),
    scalacOptions ++= Seq("-Werror", "-Wunused:all"),
  )
```
