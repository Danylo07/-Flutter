# shop_provider_app

Практична робота 6.2 «Provider State Management» — **Варіант 1: Інтернет-магазин**.
Пакет стану: `provider ^6.1.5`, інших пакетів керування станом немає.

## Запуск

```bash
flutter create . --org com.example --project-name shop_provider_app --platforms=android,ios,web  # один раз
flutter pub get
flutter run
flutter analyze
flutter test
```

## Архітектура

```
lib/
├── main.dart            # MultiProvider над MaterialApp
├── data/                # FakeApi (затримка + випадкова помилка), demoProducts
├── models/              # незмінні класи: Product, CartLine
├── state/               # ChangeNotifier: CatalogModel, CartModel, OrderModel
├── screens/             # CatalogScreen, ProductScreen, CartScreen
├── widgets/             # невеликі віджети з вузькими підписками
└── utils/               # formatMoney, readableError
```

**MultiProvider** стоїть над `MaterialApp`, тож моделі бачать і екрани, відкриті через `Navigator.push`.
Усі об'єкти створюються через `create` (без `.value`); `FakeApi` надається як звичайний `Provider`
і через `context.read` передається в конструктори `CatalogModel` та `OrderModel`.
Бізнес-логіка (фільтр, кошик, оформлення) — у моделях; віджети лише показують стан і викликають методи.

### Три стани завантаження

`CatalogModel.status`: `loading` → індикатор, `error` → повідомлення + кнопка **«Повторити»**
(`load()` повторно), `data` → список. `FakeApi.fetchProducts` падає приблизно в кожному 5-му запиті,
тож стан помилки відтворюється кількома перезапусками/«Повторити».
Оформлення замовлення: `OrderModel.checkout` — після успіху `CartModel.clear()`, після помилки кошик
лишається без змін; кнопка неактивна, поки кошик порожній або триває запит.

## Де що використано

| API | Де | Навіщо |
|---|---|---|
| `context.watch` | `CatalogBody`, `CategoryFilter`, `ProductCard`, `AddToCartControl`, `CartScreen` — **лише в базовій версії** (тег `before-selector`) | підписка на всю модель: проста, але перебудовує більше, ніж треба |
| `context.read` | колбеки: `onAdd`, `onRetry`, `selectCategory`, `startCheckout`, кнопки `CartLineTile` | дістати модель без підписки; у `build` не використовується |
| `context.select` | `ProductCard`, `AddToCartControl`, `CategoryFilter`, `CatalogBody`, `ProductList`, `CartTotal`, `CheckoutButton`, `CartScreen` (фінальна версія) | підписка на одне поле моделі |
| `Consumer` | `CartBadge` (база), `CartLines` (фінал) | підписка, обмежена піддеревом builder-а; у `CartLines` потрібен увесь список позицій |
| `Selector` | `CartBadge` (фінал, `lineCount`) | як `select`, але у вигляді віджета з builder-ом |

## Звіт про перебудови

Лічильник — `debugPrint('build: <Віджет>')` у ключових віджетах. Дві версії зафіксовано окремими комітами/тегами:
`before-selector` (watch/Consumer) і `after-selector` (select/Selector).
`N` — кількість карток на екрані (у демо — 8 товарів), `L` — позицій у кошику (у прикладі 3), `M` — карток після фільтра (Електроніка: 3).

| Дія | Перебудов до | Перебудов після | Що перебудовується після |
|---|---|---|---|
| «До кошика» на одному товарі (кошик був порожній) | N + 1 = 9 | 2 | `ProductCard(id)`, `CartBadge` |
| «+» на вже доданому товарі | N + 1 = 9 | 1 | лише `ProductCard(id)` — `lineCount` не змінився, бейдж не чіпається |
| Вибір категорії «Електроніка» | M + 2 = 5 | M + 2 = 5 | `CategoryFilter`, `ProductList`, M карток — **однаково**: перелік має змінитись |
| «Оформити» (перехід у стан `placing`), на екрані кошика | L + 3 = 6 | 1 | лише `CheckoutButton` |

Висновок: `select`/`Selector` дають найбільший виграш там, де віджетів багато, а змінюється одне значення
(картки каталогу, кнопка оформлення). Де перебудова неминуча (зміна переліку), різниці немає.

## Ефемерний стан

У цьому варіанті немає форм і полів введення, тож `setState` не потрібен. Фільтр категорії навмисно живе в `CatalogModel`:
від нього залежить, які товари видає модель (бізнес-логіка), а не лише вигляд одного віджета.

## Скриншоти

_Додайте: каталог, екран товару, кошик, **стан помилки з кнопкою «Повторити»**, SnackBar після оформлення._
