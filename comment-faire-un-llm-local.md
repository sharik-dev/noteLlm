# Faire un LLM local comme dans ce projet

Ce projet ne lance pas un serveur LLM externe. Le modèle tourne directement sur l'appareil via **MLX** et une couche Swift appelée **LocalLLMClient**.

## Vue d'ensemble

Le flux est simple :

1. L'utilisateur choisit une taille de modèle dans [`noteLlm/App/AppState.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/App/AppState.swift).
2. L'app télécharge le modèle MLX depuis Hugging Face au premier lancement via [`noteLlm/Services/LocalLLMService.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/Services/LocalLLMService.swift).
3. Le modèle est chargé localement avec `AnyLLMClient(LocalLLMClient.mlx(url: ...))`.
4. Quand l'utilisateur écrit dans l'éditeur, [`noteLlm/ViewModels/NoteViewModel.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/ViewModels/NoteViewModel.swift) attend un petit délai d'inactivité.
5. Le texte de la note est transformé en prompt via [`noteLlm/Services/PromptBuilder.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/Services/PromptBuilder.swift).
6. Le LLM renvoie une réponse en streaming, token par token, affichée dans [`noteLlm/ViewModels/AIViewModel.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/ViewModels/AIViewModel.swift).

## Les briques à reproduire

Pour refaire la même architecture, il faut 5 blocs :

### 1. Un backend local Apple-friendly

Dans ce projet, le backend choisi est **MLX** :

- bien adapté aux appareils Apple
- intégration Swift native via `LocalLLMClientMLX`
- téléchargement direct d'un modèle MLX quantifié

Le service principal ressemble à ça :

```swift
import Foundation
import LocalLLMClient
import LocalLLMClientMLX

final class LocalLLMService: LLMServiceProtocol {
    private var client: AnyLLMClient?
    private(set) var isModelReady = false

    func loadModel(modelID: String, progressHandler: @escaping (Double) -> Void) async throws {
        let model = LLMSession.DownloadModel.mlx(id: modelID)

        if model.isDownloaded {
            progressHandler(1.0)
        } else {
            try await model.downloadModel { progress in
                progressHandler(progress)
            }
        }

        client = try await AnyLLMClient(LocalLLMClient.mlx(url: model.modelPath))
        isModelReady = true
    }
}
```

Ce qu'il faut retenir :

- `LLMSession.DownloadModel.mlx(id:)` décrit un modèle distant
- `downloadModel` récupère les fichiers localement
- `model.modelPath` pointe vers le dossier du modèle téléchargé
- `LocalLLMClient.mlx(url:)` crée le client d'inférence local

## 2. Une liste de modèles réaliste

Le projet propose 3 variantes dans [`noteLlm/App/AppState.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/App/AppState.swift) :

```swift
case tiny  = "mlx-community/Qwen2.5-0.5B-Instruct-4bit"
case small = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"
case medium = "mlx-community/Qwen2.5-3B-Instruct-4bit"
```

Pourquoi c'est une bonne approche :

- `0.5B` pour la vitesse
- `1.5B` pour un compromis correct
- `3B` pour une meilleure qualité
- les versions `4bit` réduisent la mémoire nécessaire

Pour un projet similaire, commence petit. Un modèle trop gros dégrade vite l'expérience mobile.

## 3. Un prompt contrôlé

Le projet ne balance pas juste le texte utilisateur au modèle. Il impose un rôle système dans [`noteLlm/Services/PromptBuilder.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/Services/PromptBuilder.swift) :

- ton précis
- format de sortie précis
- limite de longueur
- langue de réponse imposée

Exemple de structure :

```swift
let input = LLMInput.chat([
    .system(PromptBuilder.systemPrompt),
    .user(prompt)
])
```

Le point important : pour un LLM local, il faut **réduire l'ambiguïté**. Plus le modèle est petit, plus le prompt doit être strict.

## 4. Un déclenchement intelligent

Le projet n'appelle pas le modèle à chaque frappe. Il utilise un `debounce` dans [`noteLlm/ViewModels/NoteViewModel.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/ViewModels/NoteViewModel.swift) :

```swift
$noteText
    .dropFirst()
    .debounce(for: .seconds(delay), scheduler: DispatchQueue.main)
    .sink { [weak self] text in
        self?.handleTextChange(text)
    }
```

Pourquoi c'est indispensable :

- moins d'inférences inutiles
- meilleure autonomie
- UI plus stable
- moins de concurrence entre plusieurs générations

## 5. Un streaming progressif

Le rendu de la réponse se fait en flux continu dans [`noteLlm/Services/LocalLLMService.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/Services/LocalLLMService.swift) :

```swift
func stream(prompt: String) -> AsyncStream<String> {
    AsyncStream { continuation in
        guard let client else {
            continuation.finish()
            return
        }

        let input = LLMInput.chat([
            .system(PromptBuilder.systemPrompt),
            .user(prompt)
        ])

        Task {
            do {
                let tokenStream = try await client.textStream(from: input)
                for try await token in tokenStream {
                    continuation.yield(token)
                }
            } catch {
            }
            continuation.finish()
        }
    }
}
```

Puis [`noteLlm/ViewModels/AIViewModel.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/ViewModels/AIViewModel.swift) accumule les tokens :

```swift
var accumulated = ""
for await token in tokenStream {
    accumulated += token
    aiOutput = sanitizeModelOutput(accumulated)
}
```

Le streaming est important parce qu'un LLM local peut être plus lent qu'une API cloud. Sans streaming, l'app paraît bloquée.

## Étapes pour refaire la même chose

### Étape 1. Ajouter la dépendance LLM locale

Ce projet embarque `Vendor/LocalLLMClient`. Tu peux :

- soit garder le package en local
- soit l'ajouter comme dépendance Swift Package

Les modules utilisés ici sont :

- `LocalLLMClient`
- `LocalLLMClientMLX`

## Étape 2. Définir une abstraction de service

Le protocole est volontairement minimal dans [`noteLlm/Services/LLMServiceProtocol.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/Services/LLMServiceProtocol.swift) :

```swift
protocol LLMServiceProtocol: AnyObject {
    var isModelReady: Bool { get }
    func stream(prompt: String) -> AsyncStream<String>
    func loadModel(modelID: String, progressHandler: @escaping (Double) -> Void) async throws
}
```

C'est une bonne base, car elle sépare :

- le téléchargement / chargement
- la disponibilité du modèle
- la génération en streaming

## Étape 3. Gérer l'état global

Dans ce projet, [`noteLlm/App/AppState.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/App/AppState.swift) centralise :

- le modèle choisi
- l'état du téléchargement
- le délai avant déclenchement

Tu as besoin d'un équivalent, sinon l'UI et le moteur vont se mélanger.

## Étape 4. Bloquer l'app tant que le modèle n'est pas prêt

Le point d'entrée [`noteLlm/noteLlmApp.swift`](/Users/sharikmohamed/Documents/MyProject/noteLlm/noteLlm/noteLlmApp.swift) fait ça :

- écran de téléchargement si le modèle n'est pas encore disponible
- écran principal seulement après chargement

C'est le bon pattern pour éviter des appels LLM alors que le client n'existe pas encore.

## Étape 5. Relier la saisie utilisateur au LLM

Le cycle métier ici est :

1. l'utilisateur écrit dans `TextEditor`
2. `NoteViewModel` sauvegarde la note
3. après inactivité, `AIViewModel.generateSuggestions(...)` est appelé
4. le prompt est construit
5. le LLM stream la réponse
6. la vue affiche le texte généré et extrait les questions finales

## Pièges à éviter

### Modèle trop gros

Sur mobile, un gros modèle donne souvent :

- temps de chargement long
- mémoire excessive
- risque de crash
- UX médiocre

### Prompt trop vague

Avec un petit modèle local, un prompt flou produit vite :

- du hors-sujet
- un mauvais format
- des répétitions

### Appels trop fréquents

Sans `debounce` ni annulation, tu peux empiler plusieurs générations en parallèle. Ici, `AIViewModel` annule la précédente avec `streamTask?.cancel()`.

### Pas de post-traitement

Le projet nettoie la sortie du modèle dans `sanitizeModelOutput(_:)` pour enlever des préfixes parasites. C'est souvent nécessaire avec des petits modèles.

## Structure minimale à recopier

Si tu veux refaire ce projet rapidement, garde cette structure :

```text
AppState
LLMServiceProtocol
LocalLLMService
PromptBuilder
AIViewModel
NoteViewModel
ModelDownloadView
```

## Résumé

Pour faire un LLM local comme dans ce projet :

- utilise un backend local adapté à Apple, ici **MLX**
- télécharge un modèle quantifié depuis Hugging Face
- charge-le avec `LocalLLMClient`
- impose un prompt système strict
- déclenche l'inférence après un `debounce`
- affiche la réponse en streaming
- garde l'état du modèle séparé de l'UI

Si tu veux, je peux aussi te faire un deuxième fichier avec une version encore plus pratique : **un tutoriel pas-à-pas pour recréer exactement cette architecture dans un projet iOS vide**.
