# Product Catalog — Flutter Take-Home Assignment

A small Flutter product catalog built against the free [DummyJSON Products API](https://dummyjson.com/docs/products). The implementation is intentionally scoped like a 2–3 hour take-home: clear architecture, complete required flows, a few focused UX bonuses, and no unnecessary framework overhead.

## Features

- Product list with **thumbnail, title, and price**
- Infinite-scroll **pagination** using `limit=20` and `skip`
- Product detail screen loaded from `GET /products/{id}`
- Detail content: **images, full description, price, and rating**
- Explicit **loading, error + retry, empty, and success** states
- **Debounced search (450 ms)** using the DummyJSON search endpoint
- **Pull-to-refresh** for the active list/search query
- Image loading progress and broken-image fallback
- Pagination error handling that keeps already-loaded products visible
- Stale-request protection so an older search response cannot replace a newer search
- Hero image transition from list to detail loading preview
- Unit tests for model parsing and catalog pagination/search logic

## Search approach

I chose **server-side search**:

```text
GET https://dummyjson.com/products/search?q=<query>&limit=20&skip=<skip>
```

Client-side filtering would only search products that had already been fetched by pagination. Server-side search covers the complete catalog and keeps the same paginated list behavior as the normal product endpoint.

The search field is debounced by **450 ms** to avoid sending a request for every keystroke. Pressing the keyboard search action submits immediately.

## Architecture

The code is split into two main layers, with models/controllers separated further for readability:

```text
lib/
├── data/
│   ├── models/
│   │   ├── product.dart
│   │   └── product_page.dart
│   ├── product_api_service.dart
│   └── product_repository.dart
└── presentation/
    ├── controllers/
    │   ├── product_catalog_controller.dart
    │   ├── product_detail_controller.dart
    │   └── view_status.dart
    ├── screens/
    │   ├── product_list_screen.dart
    │   └── product_detail_screen.dart
    └── widgets/
        ├── product_card.dart
        ├── product_image.dart
        └── state_views.dart
```

### Data layer

`ProductApiService` handles HTTP, URI construction, timeouts, response validation, and user-readable API errors. `ProductRepository` is the boundary consumed by presentation code, while `ApiProductRepository` maps raw API JSON into typed models.

### Presentation layer

The screens do not call HTTP directly. `ProductCatalogController` owns list, search, refresh, pagination, and request state. `ProductDetailController` owns the detail request. Both use `ChangeNotifier`, which keeps the assignment lightweight without adding a state-management dependency solely for a small project.

## API endpoints

```text
GET https://dummyjson.com/products?limit=20&skip=0
GET https://dummyjson.com/products/search?q=phone&limit=20&skip=0
GET https://dummyjson.com/products/{id}
```

Prices are displayed with `$` because DummyJSON product prices are represented as generic USD-style values in the API examples; the app does not perform currency conversion.

## Run locally

### Requirements

- Flutter stable with Dart 3.3+
- Android Studio / Android SDK, Xcode, or another Flutter-supported target

Install dependencies:

```bash
flutter pub get
```

If this source archive does not yet contain generated host-platform folders, create them once with your installed Flutter version:

```bash
flutter create . --project-name product_catalog --platforms=android,ios
flutter pub get
```

Then run:

```bash
flutter run
```

## Validation

```bash
flutter analyze
flutter test
```

The tests cover:

- `Product` JSON parsing and safe defaults
- `ProductPage` pagination metadata
- Initial catalog loading
- Appending a second page with the correct `skip`
- Empty search results

## State handling

### Initial loading

The list/detail area shows a progress indicator and loading label.

### Error

A dedicated error view displays the failure message and a **Retry** button. A pagination failure is handled separately at the bottom of the list so existing products remain usable.

### Empty

An empty catalog and a search with zero matches use a dedicated empty-state illustration/message. Pull-to-refresh remains available.

### Success

Products remain interactive while additional pages load. The pagination spinner only appears at the bottom rather than replacing the list.

## UX details / bonuses

A few small details I would mention in the walkthrough video:

1. **Search race protection** — every first-page request receives a serial number. If an older response finishes after a newer search, it is ignored.
2. **Non-destructive pagination errors** — failure to fetch page 2+ does not turn the whole screen into an error state.
3. **Pull-to-refresh respects search** — refreshing while searching reloads the current query instead of silently returning to the full catalog.
4. **Image resilience** — network images have progress and error states.
5. **Hero loading preview** — the tapped product thumbnail remains visible while the detail endpoint is loading.

## Trade-offs / TODOs

If this were moving beyond the assignment time box, I would consider:

- Add local caching/offline support.
- Add widget/integration tests for scrolling, retry, and search debounce behavior.
- Add dependency injection if the app grows beyond a few repositories/controllers.
- Add accessibility-specific testing and localized strings.
- Add richer product metadata such as category, stock, discount, and reviews.
- Generate and commit host-platform folders using the team’s chosen Flutter version before final store/CI setup.

## Notes

No API key, authentication, or backend setup is required.

## Flutter bootstrap note

The repository includes its own `test/widget_test.dart`. If an older copy of the project was bootstrapped with `flutter create .` before this test was included, Flutter may have generated its stock counter-app test referencing `MyApp`. Replace that generated test with the repository version before running `flutter analyze` or `flutter test`.
