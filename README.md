# Pinata UI Swift Example App

This small example project demonstrates the usage of the Piñata iOS SDK
([pinata-ui-swift](https://github.com/pinata-ai/pinata-ui-swift)). It shows how to integrate
Piñata's marketplace components into a native iOS app, including the authentication flow and
the navigation driven by the components' events.

> ⚠️ **Security Warning**: For the ease of this example, company secrets are read from
> `Config.xcconfig`. In a production app, the company client ID, key or secret must never ship in
> the app. These credentials should be kept secure and only used in a secure backend service.

## Features

- Integration with the Piñata marketplace components: Wallet, Preview and Full Shopping
- Authentication flow with company and user tokens
- Wallet and Preview open Full Shopping on the clicked item through `MarketplaceOpenEvent`

## Prerequisites

- Xcode 16 or newer and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- An iOS simulator or device (iOS 16 or higher)

## Installation

1. Clone the repository:

```bash
git clone https://github.com/pinata-ai/pinata-ui-swift-example-app.git
cd pinata-ui-swift-example-app
```

2. Copy `Config.example.xcconfig` to `Config.xcconfig` (the file is not committed) and add your
sandbox values:

```
PINATA_CLIENT_ID = your_client_id
PINATA_CLIENT_KEY = your_client_key
PINATA_CLIENT_SECRET = your_client_secret
PINATA_USER_EMAIL = your_email@example.com
```

### Values

- `PINATA_CLIENT_ID`: Your Piñata client ID
- `PINATA_CLIENT_KEY`: Your Piñata client key
- `PINATA_CLIENT_SECRET`: Your Piñata client secret
- `PINATA_USER_EMAIL`: Default user email for login

They only prefill the login form; you can also type the values in the app. The Partner API base
URL is `https://sandbox.pinata.ai/partners/api/v1/` (see `PinataService.swift`), and the
components run against the sandbox environment.

## Running the App

Generate the Xcode project, open it, pick a simulator and run:

```bash
xcodegen generate
open PinataUIExampleApp.xcodeproj
```

## How it works

- **Login** (`LoginView`, `PinataService`): gets a company token from `auth/retrieve-token/`
  (signed with the client secret), then the user's token from `auth/retrieve-user-token/`. The
  user token is the `userToken` of every component.
- **Screens** (`MainView`): one screen per component, picked from the menu. Wallet and Preview
  send a `MarketplaceOpenEvent` when the renter wants the marketplace, and the app opens Full
  Shopping, on the clicked item when the event carries one. Back returns to the previous screen.

The SDK comes through Swift Package Manager; see `project.yml` and the
[SDK README](https://github.com/pinata-ai/pinata-ui-swift#installation).
