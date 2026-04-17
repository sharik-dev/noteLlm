# Project Documentation: noteLlm

## Table of Contents
1. [Introduction](#1-introduction)
2. [Project Structure](#2-project-structure)
3. [Key Components](#3-key-components)
    - [Application Entry Point](#31-application-entry-point)
    - [Views](#32-views)
    - [View Models](#33-view-models)
    - [Models](#34-models)
    - [Services](#35-services)
    - [App State](#36-app-state)
4. [Getting Started](#4-getting-started)
5. [Testing](#5-testing)

---

## 1. Introduction

`noteLlm` is an iOS application developed using Swift and SwiftUI. It appears to be a note-taking application with integrated Large Language Model (LLM) capabilities, suggested by the presence of `LLMServiceProtocol.swift` and `AIViewModel.swift`.

## 2. Project Structure

The project follows a modular structure, common in SwiftUI applications, organizing code into logical groups such as Views, ViewModels, Models, and Services.

```
noteLlm/
├───ContentView.swift
├───noteLlmApp.swift
├───App/
│   └───AppState.swift
├───Assets.xcassets/
├───Models/
│   └───Note.swift
├───Preview Content/
├───Services/
│   ├───LLMServiceProtocol.swift
│   ├───LocalLLMService.swift
│   ├───NoteService.swift
│   └───PromptBuilder.swift
├───ViewModels/
│   ├───AIViewModel.swift
│   └───NoteViewModel.swift
└───Views/
    ├───AIPanelView.swift
    ├───HistoryView.swift
    ├───ModelDownloadView.swift
    ├───NoteEditorView.swift
    └───SettingsView.swift
```

## 3. Key Components

### 3.1. Application Entry Point

- **`noteLlmApp.swift`**: This is the main entry point of the SwiftUI application, conforming to the `App` protocol.

### 3.2. Views

Located in the `noteLlm/Views/` directory, these SwiftUI views are responsible for the user interface.

- **`ContentView.swift`**: Likely the initial view displayed to the user, potentially acting as a container or main layout.
- **`AIPanelView.swift`**: A view dedicated to interacting with or displaying AI-generated content.
- **`HistoryView.swift`**: Displays a history of notes or AI interactions.
- **`ModelDownloadView.swift`**: Manages the UI for downloading LLM models.
- **`NoteEditorView.swift`**: The primary view for creating or editing notes.
- **`SettingsView.swift`**: Provides user settings and configurations.

### 3.3. View Models

Located in the `noteLlm/ViewModels/` directory, these classes manage the presentation logic and state for their corresponding views.

- **`AIViewModel.swift`**: Manages the logic and data related to AI functionalities, interacting with `LLMServiceProtocol`.
- **`NoteViewModel.swift`**: Handles the logic and data for note management, interacting with `NoteService`.

### 3.4. Models

Located in the `noteLlm/Models/` directory, these Swift structures or classes define the data structures used throughout the application.

- **`Note.swift`**: Defines the data structure for a note object.

### 3.5. Services

Located in the `noteLlm/Services/` directory, these classes provide specific functionalities and abstract away data fetching or external interactions.

- **`LLMServiceProtocol.swift`**: Defines the interface for Large Language Model (LLM) services, allowing for different implementations.
- **`LocalLLMService.swift`**: An implementation of `LLMServiceProtocol` for a locally running LLM.
- **`NoteService.swift`**: Handles operations related to notes, such as saving, loading, and deleting.
- **`PromptBuilder.swift`**: Responsible for constructing prompts to be sent to the LLM.

### 3.6. App State

- **`App/AppState.swift`**: Likely a central object managing the overall application state, potentially using `@EnvironmentObject` or similar SwiftUI mechanisms.

## 4. Getting Started

### Prerequisites
- Xcode 15+
- iOS 17.0+

### Launching the Project
1. Open `noteLlm.xcodeproj` in Xcode.
2. Select a target device or simulator.
3. Build and run the project.

## 5. Testing

- **`noteLlmTests/noteLlmTests.swift`**: Contains unit tests for the application's logic.
- **`noteLlmUITests/noteLlmUITests.swift`**: Contains UI tests for verifying the user interface and user flows.
