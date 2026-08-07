# ShopEase — Flutter E-Commerce App

A fully functional e-commerce mobile app built with Flutter, powered by the
[Fake Store API](https://fakestoreapi.com).

## Features

- **Authentication** — Login against Fake Store API's `/auth/login`, plus a
  registration screen (`POST /users`). Session persisted locally with
  `shared_preferences` so the user stays logged in across app restarts.
- **Product Browsing** — Home screen with category chips, featured/top-rated
  products, and a responsive product grid.
- **Product Details** — Full detail page with image, rating, description,
  quantity selector, and related products from the same category.
- **Search & Filters** — Live search by title, category filter, price range
  slider, and sort by price/rating.
- **Cart** — Add/remove/update quantities, persisted locally, with a live
  order summary (subtotal, tax, shipping, total).
- **Checkout** — Shipping address form, payment method selection, order
  confirmation flow.
- **Wishlist/Favorites** — Heart any product to save it; persisted locally.
- **Profile** — Account overview, cart/wishlist stats, logout.

## Architecture

- **State management:** `provider` (ChangeNotifier-based)
- **Networking:** `http` package, wrapped in `ApiService`
- **Local persistence:** `shared_preferences`, wrapped in `StorageService`
  (auth session, cart, favorites)
- **Structure:**
  ```
  lib/
    models/       # Product, CartItem, AppUser
    services/     # ApiService (network), StorageService (local persistence)
    providers/    # AuthProvider, ProductProvider, CartProvider, FavoritesProvider
    screens/      # One folder per feature area
    widgets/      # Shared reusable widgets
    utils/        # Theme, constants
  ```
## Important Fake Store API Notes

- **Login only works with the API's fixed demo accounts** — it does not
  validate real user/password pairs. The login screen is pre-filled with a
  working demo account (`mor_2314` / `83r5^_`). See
  https://fakestoreapi.com/docs for the full list of test users.
- **Registration (`POST /users`) does not create a real, persistent account**
  — Fake Store API is a mock backend, so newly "registered" users can't
  subsequently log in with their own credentials. The app surfaces this to
  the user after registering and directs them back to the demo login.
- **Checkout does not process real payments or hit `/carts` for order
  creation** — Fake Store API's cart endpoints don't represent a real order
  pipeline, so checkout is simulated locally (form validation + a short
  delay + success screen) while still using the live product/price data
  from the API.

