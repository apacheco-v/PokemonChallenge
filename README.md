# Pokémon Challenge

Assessment técnico — PokéAPI en SwiftUI con Clean Architecture, MVVM y soporte offline.

---

## Descripción General

Aplicación iOS nativa que consume la [PokéAPI](https://pokeapi.co/) para mostrar un listado paginado de Pokémon y su detalle completo (tipos, habilidades, estadísticas, peso, altura y experiencia base). Construida íntegramente con tecnologías nativas de Apple — SwiftUI, SwiftData, URLSession y async/await — **sin ninguna dependencia externa**.

<h2 align="center">📱 App Evidence & UI States</h2>

<p align="center">
  <img src="https://github.com/user-attachments/assets/3b04b155-8fef-4798-877d-71c1636c6207" width="220" alt="Splash Screen" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/a51dbdd7-42e6-43a2-953b-0bb5a5fff250" width="220" alt="Pokémon List Loading" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/e0d62668-309c-406f-ac22-b0c6315268e8" width="220" alt="Pokémon List Loaded" style="margin: 5px;"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/ea776db2-7acb-4353-9116-133f2c2b646d" width="220" alt="Search Filtering" style="margin: 5px;"/>
  <img src="https://github.com/user-attachments/assets/8c8075a5-fa26-461c-ae57-decf7936b2c7" width="220" alt="Pokémon Detail Spanish" style="margin: 5px;"/>
</p>

### Requisitos cumplidos

| Requisito | Estado |
|---|---|
| Lista paginada (20 en 20) con scroll infinito | ✅ |
| Detalle con tipos, habilidades, estadísticas, peso, altura, experiencia base | ✅ |
| Soporte offline parcial (caché de páginas ya visitadas) | ✅ |
| Skeleton shimmer loading nativo (sin librerías) | ✅ |
| Pull to refresh | ✅ |
| Navegación tipo Stack (NavigationStack + NavigationPath) | ✅ |
| Accesibilidad (VoiceOver + Dynamic Type) | ✅ |
| Caché de imágenes con URLCache | ✅ |
| Clean Architecture + MVVM + SOLID | ✅ |
| Unit Tests (AAA + Mocks configurables) | ✅ |
| 0 dependencias externas | ✅ |

---

## Arquitectura y Modularización Visual

### Clean Architecture + MVVM

El proyecto sigue una arquitectura en capas con dependencia unidireccional: **Presentation → Domain ← Data ← Infrastructure**. La capa Domain es el centro puro de negocio, sin importar UIKit, SwiftUI, SwiftData ni URLSession.

```
┌─────────────────────────────────────────────────┐
│                   Presentation                   │
│  (SwiftUI Views, ViewModels, ViewState<T>)       │
│  Depende de: Domain                              │
├─────────────────────────────────────────────────┤
│                     Domain                        │
│  (Entities, RepositoryProtocols, UseCases)       │
│  0 imports de UI / Red / Persistencia            │
├──────────────────────┬──────────────────────────┤
│         Data         │      Infrastructure       │
│  (DTOs, Mappers,    │   (Networking, DI,        │
│   RepositoryImpl)   │    PersistenceClient)      │
│  Depende de: Domain │   Depende de: Foundation   │
└──────────────────────┴──────────────────────────┘
```

### Principios SOLID aplicados

| Principio | Implementación |
|---|---|
| **S** — Single Responsibility | Cada archivo tiene una única razón de cambio: `PokemonRepositoryImpl` solo orquesta red+caché; `PokemonDetailMapper` solo transforma DTOs. |
| **O** — Open/Closed | Los protocolos (`PokemonRepositoryProtocol`, `NetworkClientProtocol`, `PersistenceClientProtocol`) permiten extender comportamientos sin modificar código existente. |
| **L** — Liskov Substitution | `DefaultNetworkClient` y cualquier futura implementación de `NetworkClientProtocol` son intercambiables sin alterar el consumidor. |
| **I** — Interface Segregation | `PersistenceClientProtocol` expone solo 4 métodos mínimos (`cache`, `loadCached`, `clearCache`, `isCached`); ningún cliente se ve forzado a depender de métodos que no usa. |
| **D** — Dependency Inversion | `PokemonRepositoryImpl` depende de los protocolos `NetworkClientProtocol` y `PersistenceClientProtocol`, no de `DefaultNetworkClient` ni `SwiftDataPersistenceClient`. Domain jamás importa infraestructura. |

### Árbol de carpetas final

```
PokemonChallenge/
├── Infrastructure/
│   ├── DI/
│   │   └── DIContainer.swift              ← Registry de dependencias (sin singletons)
│   ├── Networking/
│   │   ├── NetworkClientProtocol.swift    ← Protocolo abstracto de red
│   │   ├── DefaultNetworkClient.swift     ← URLSession + async/await
│   │   ├── NetworkError.swift             ← Enum de errores tipados
│   │   ├── HTTPMethod.swift               ← GET, POST, PUT, DELETE, PATCH
│   │   └── Endpoint.swift                 ← Protocolo para modelar requests
│   └── Persistence/
│       ├── PersistenceClientProtocol.swift ← Protocolo abstracto de caché
│       ├── CachedEntry.swift               ← @Model de SwiftData
│       └── SwiftDataPersistenceClient.swift ← Implementación con JSON serializado
│
├── Domain/
│   ├── Entities/
│   │   ├── Pokemon.swift                  ← id, name (Identifiable, Hashable)
│   │   ├── PokemonDetail.swift            ← Datos completos del Pokémon
│   │   ├── PokemonType.swift              ← Value object (name)
│   │   ├── PokemonAbility.swift           ← Value object (name, isHidden)
│   │   └── PokemonStat.swift              ← Value object (name, baseStat)
│   ├── RepositoryProtocols/
│   │   └── PokemonRepositoryProtocol.swift ← Contrato del repositorio
│   └── UseCases/
│       ├── GetPokemonListUseCase.swift     ← Struct inmutable, solo delega
│       └── GetPokemonDetailUseCase.swift   ← Struct inmutable, solo delega
│
├── Data/
│   ├── DTOs/
│   │   ├── NamedAPIResourceDTO.swift      ← { name, url } + id inferido
│   │   ├── PokemonListResponseDTO.swift   ← /pokemon?limit=20
│   │   └── PokemonDetailDTO.swift         ← /pokemon/{id} (aplanado)
│   ├── Mappers/
│   │   ├── PokemonListResponseMapper.swift ← DTO → [Pokemon]
│   │   └── PokemonDetailMapper.swift       ← DTO → PokemonDetail (elimina slot, name extraído)
│   └── Repositories/
│       ├── PokemonEndpoint.swift          ← Enum Endpoint para PokéAPI
│       └── PokemonRepositoryImpl.swift    ← Orquesta NetworkClient + PersistenceClient
│
├── Presentation/
│   ├── App/
│   │   └── PokemonChallengeApp.swift      ← @main, DIContainer, NavigationStack
│   ├── Common/
│   │   ├── ViewState.swift                ← loading / loaded(T) / empty / error(String)
│   │   ├── PokemonRoute.swift             ← Navigation enum Hashable
│   │   ├── ShimmerModifier.swift          ← ViewModifier .shimmer()
│   │   └── CachedPokemonImage.swift       ← AsyncImage + URLCache
│   └── Scenes/
│       ├── PokemonList/
│       │   ├── PokemonListViewModel.swift  ← Paginación + anti-duplicados
│       │   ├── PokemonListView.swift       ← SwiftUI principal
│       │   └── Cell/
│       │       └── PokemonRowView.swift    ← Card reutilizable
│       └── PokemonDetail/
│           ├── PokemonDetailViewModel.swift ← Carga individual por id
│           └── PokemonDetailView.swift     ← Sprites, stats, tipos, abilities
│
└── PokemonChallengeTests/
    ├── Mocks/
    │   └── MockPokemonRepository.swift     ← Closures configurables + callCount
    ├── ViewModels/
    │   └── PokemonListViewModelTests.swift ← 7 tests (AAA)
    └── UseCases/
        └── GetPokemonListUseCaseTests.swift ← 3 tests
```

---

## Estrategia de Persistencia Local (SwiftData)

### Decisión técnica: SwiftData sobre CoreData

| Aspecto | SwiftData | CoreData |
|---|---|---|
| Boilerplate | Mínimo (`@Model`, `@Query`) | Alto (`NSManagedObject`, `.xcdatamodeld`) |
| Integración SwiftUI | Nativa (`@Query`, `@Model`) | Vía `@FetchRequest` |
| Concurrencia | `ModelActor`, `@ModelContext` nativo async | `NSManagedObjectContext` con `perform` |
| Control fino de migraciones | Limitado | Maduro (`NSMappingModel`) |
| iOS mínimo requerido | 17+ | 13+ |

**SwiftData** fue elegido porque:

1. **Madurez suficiente en 2026** — SwiftData lleva 3 versiones desde iOS 17 y es el storage oficial de Apple para SwiftUI.
2. **Minimiza boilerplate** — `@Model` + `@Attribute(.unique)` eliminan la necesidad de archivos `.xcdatamodeld` y `NSManagedObject` subclases.
3. **Encapsulación total** — SwiftData está completamente aislado dentro de `Infrastructure/Persistence/`. Domain, Data y Presentation **nunca importan** `SwiftData`.

### Implementación: Persistencia genérica Key-Value sobre JSON

En lugar de modelar Pokémon como entidades de SwiftData (lo que acoplaría el storage al framework), se implementó un sistema de **caché clave-valor**:

```
PersistenceClientProtocol (abstracto)
  ├── cache(value: Encodable, forKey: String)
  ├── loadCached(type: Decodable.Type, forKey: String) -> T?
  ├── clearCache()
  └── isCached(forKey: String) -> Bool

SwiftDataPersistenceClient (concreto)
  └── CachedEntry @Model
        ├── key: String (@Attribute(.unique))
        ├── jsonData: Data
        └── createdAt: Date
```

Cada respuesta de la API se serializa a JSON y se almacena bajo una clave única:
- Lista: `"pokemon_list_\(offset)_\(limit)"`
- Detalle: `"pokemon_detail_\(id)"`

Si el framework de persistencia cambia en el futuro (ej: a CoreData o a un archivo plano), solo se reemplaza `SwiftDataPersistenceClient` sin tocar el resto del proyecto.

---

## Networking y Caché de Imágenes

### Cliente de red nativo

`DefaultNetworkClient` implementa `NetworkClientProtocol` usando **URLSession + async/await**, sin Alamofire ni Moya.

```
NetworkClientProtocol
  └── DefaultNetworkClient
        ├── request<T: Decodable>(_: Endpoint) -> T    ← Genérico con inferencia
        └── request(_: Endpoint) -> Data               ← Raw data
```

**Manejo de errores tipado:**

```swift
enum NetworkError: Error {
    case invalidURL
    case noInternet                  ← URLError.notConnectedToInternet
    case timeout                     ← URLError.timedOut
    case httpError(statusCode: Int, data: Data?)  ← 4xx/5xx
    case parsing(Error)              ← JSONDecoder falla
    case unknown(Error)
}
```

`Endpoint` abstrae la construcción de requests mediante un protocolo con defaults:

```swift
protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }          ← default nil
    var queryParameters: [String: String]? { get }   ← default nil
    var body: Encodable? { get }                     ← default nil
}
```

### Caché de imágenes con URLCache

Las imágenes de los sprites se cargan mediante `AsyncImage`, que utiliza la `URLCache` compartida de `URLSession.shared`. Para optimizar scrolls extensos sin dependencias externas (SDWebImage, Kingfisher), se configuró `URLCache` con capacidades ampliadas:

| Capacidad | Tamaño |
|---|---|
| Memoria | 50 MB |
| Disco | 100 MB |

Esto permite que `AsyncImage` sirva las imágenes desde caché en milisegundos al hacer scroll hacia atrás, sin necesidad de un `ImageLoader` personalizado. El componente `CachedPokemonImage` envuelve `AsyncImage` con placeholder shimmer y fallback en caso de error de red.

---

## UX Avanzada y Accesibilidad

### Skeleton Loader (Shimmer nativo)

`ShimmerModifier` es un `ViewModifier` que aplica un gradiente lineal animado sobre cualquier vista:

- Gradiente de 3 colores: `clear → white(35%) → clear`
- **Duración:** 1.4s por ciclo
- **Repetición:** `repeatForever(autoreverses: false)`
- **Efecto:** barra deslizante de 50% del ancho con blur de 24pt

Se aplica con `.shimmer()` y se usa tanto en las celdas placeholder del listado como en los skeletons de la pantalla de detalle.

### Pull to Refresh

El modificador nativo `.refreshable` ejecuta `await viewModel.refresh()`. El ViewModel expone un método `async` que:
1. Cancela la tarea de carga en curso
2. Resetea offset y acumuladores
3. Inicia una nueva carga desde la página 0
4. Espera a que finalice (gracias a `await loadTask?.value`)

### Paginación incremental anti-duplicados

`PokemonListViewModel` orquesta la paginación con las siguientes protecciones:

- **Flag `isLoadingMore`**: previene llamadas concurrentes. Si el flag está en `true`, `loadNextPage()` retorna inmediatamente.
- **Flag `hasMorePages`**: se desactiva cuando la API devuelve menos items que el límite solicitado (`page.count < pageSize`) o cero items.
- **Acumulador `allPokemons`**: crece de 20 en 20. El `ViewState` pasa a `.loaded(allPokemons)` después de cada página exitosa.
- **Cancelación de tareas**: `refresh()` cancela la tarea anterior mediante `loadTask?.cancel()`, evitando carreras de datos.

### Accesibilidad

| Elemento | Implementación |
|---|---|
| **Dynamic Type** | Todos los textos usan estilos semánticos (`body`, `subheadline`, `caption`, `headline`) en lugar de tamaños fijos. |
| **VoiceOver celdas** | `accessibilityElement(children: .combine)` + `accessibilityLabel("Bulbasaur, Pokémon")` + `accessibilityAddTraits(.isButton)` |
| **VoiceOver detalle** | `accessibilityLabel("Ataque: 55 de 255")` en cada barra de estadística |
| **VoiceOver tipos** | `accessibilityLabel("Types: Grass, Poison")` |
| **VoiceOver habilidades** | `accessibilityLabel("Overgrow")` / `accessibilityLabel("Chlorophyll, hidden ability")` |
| **Contraste** | Fondos con `regularMaterial` se adaptan automáticamente a Light/Dark Mode |

### Estilo visual

- Celdas en formato **card** con `regularMaterial`, esquinas redondeadas de 12pt, sombra sutil (opacidad 0.04, radio 4, y 2).
- Espaciados consistentes en múltiplos de 8 (8, 12, 16, 24, 32pt).
- `LazyVGrid` de 3 columnas para peso/altura/XP con fondos materiales individuales.
- Indicadores de tipo con colores oficiales de Pokémon (`grass: #78C850`, `fire: #F08030`, etc.) en formato `Capsule`.
- Barras de estadísticas con `ProgressView` coloreado por rango (rojo < 50, naranja 50-90, amarillo 90-130, verde ≥ 130) y animación `easeOut(duration: 0.6)`.

---

## Suite de Pruebas (Testing)

### Enfoque

Todas las pruebas usan el framework **Testing** (iOS 18+) con el patrón **AAA** (Arrange-Act-Assert).

### Mocks configurables

`MockPokemonRepository` conforma `PokemonRepositoryProtocol` y expone handlers como closures, permitiendo configurar escenarios sin herencia:

```swift
let mock = MockPokemonRepository()
mock.fetchPokemonListHandler = { _, _ in
    [Pokemon(id: 1, name: "bulbasaur")]    // ← éxito
    // throw NetworkError.noInternet        // ← error
    // return []                            // ← vacío
}
```

Cada handler tiene un contador `callCount` para verificar el número de invocaciones (esencial para el test anti-duplicados).

### Tests implementados

| Suite | Test | Escenario |
|---|---|---|
| `GetPokemonListUseCaseTests` | `execute_callsRepositoryWithCorrectParameters` | Verifica que el Use Case delega offset/limit correctamente |
| | `execute_propagatesRepositoryError` | El error del repositorio se propaga sin modificación |
| | `execute_returnsRepositoryResults` | Los datos del repositorio se retornan íntegros |
| `PokemonListViewModelTests` | `loadNextPage_success_transitionsToLoaded` | 2 Pokémon → `.loaded` con count=2 |
| | `loadNextPage_error_setsErrorState` | Error de red → `.error` |
| | `loadNextPage_emptyList_setsEmptyState` | Lista vacía → `.empty` |
| | `pagination_accumulatesPokemonsAcrossPages` | 2 páginas de 20 → 40 acumulados |
| | `loadNextPage_preventsConcurrentCalls` | Doble llamada → mock llamado 1 vez |
| | `refresh_resetsStateAndLoadsFreshData` | Refresh reemplaza datos anteriores |
| | `errorOnEmptyList_showsError` | `.loading` → `.error` (no crash) |

---

## Trade-offs y Mejoras Futuras

### Decisiones conscientes

| Trade-off | Motivo |
|---|---|
| **URLCache vs. ImageLoader personalizado** | `URLCache` compartido con `AsyncImage` requiere 0 código de gestión de caché. No permite precarga ni cancelación selectiva, pero para el volumen de sprites de Pokémon (menos de 200 imágenes en sesión típica) es más que suficiente. |
| **SwiftData vs. CoreData** | SwiftData simplifica drásticamente el boilerplate. Si el proyecto requiriera migraciones complejas con transformación de datos, CoreData ofrecería más control. La abstracción por protocolo permite el reemplazo. |
| **ScrollView + LazyVStack vs. List** | `List` tenía problemas de inferencia de tipos con `NavigationStack(path:)`. `ScrollView` + `LazyVStack` da control total sobre la paginación y evita los `List` bugs de SwiftUI. |
| **Testing (Swift Testing) vs. XCTest** | El proyecto usa Swift Testing porque es el framework moderno de Apple (Xcode 16+). Ofrece `@Test`, `#expect`, y mejor integración con Swift concurrency. |
| **DIContainer sin EnvironmentObject** | Preferimos inyección explícita por init sobre `@EnvironmentObject` para mantener la trazabilidad de dependencias y facilitar los tests unitarios. |

### Mejoras futuras

1. **CI/CD con GitHub Actions**
   - Workflow que ejecute `xcodebuild test` en cada PR
   - Reporte de cobertura con `xcrun xccov`
   - Linting con SwiftLint

2. **Snapshot Testing para UI**
   - Usar `swift-snapshot-testing` (Point-Free) para verificar visualmente que las vistas no regresionan
   - Capturar estados: `.loading`, `.loaded`, `.empty`, `.error`

3. **Modularización con SPM**
   - Dividir en paquetes: `PokemonDomain`, `PokemonData`, `PokemonInfrastructure`, `PokemonPresentation`
   - Cada paquete con su propia suite de tests
   - Compilación paralela y aislamiento total de dependencias

4. **Cache con staleness (TTL)**
   - Agregar timestamp de expiración a `CachedEntry`
   - Mostrar indicador "offline data from N minutes ago" en las vistas

5. **Búsqueda local y remota**
   - Endpoint `/pokemon?limit=100000` + búsqueda local con `NSPredicate` en SwiftData
   - O usar el endpoint `/pokemon/{name}` para búsqueda remota exacta

6. **Widget y WatchOS**
   - Compartir el `DIContainer` y `PokemonRepositoryProtocol` con un widget de "Pokémon del día"
   - WatchOS app para ver detalle rápido

---

## Ejecución

```bash
# Abrir el proyecto (Xcode 16+)
open PokemonChallenge.xcodeproj

# Compilar y ejecutar en simulador
xcodebuild -project PokemonChallenge.xcodeproj \
           -scheme PokemonChallenge \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           build

# Ejecutar tests unitarios
xcodebuild -project PokemonChallenge.xcodeproj \
           -scheme PokemonChallenge \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           test
```

**iOS mínimo:** 18.0  
**Swift:** 5  
**Xcode:** 16+

---

## Autor

**Alexis Pacheco** — Julio 2026.
https://teams.microsoft.com/meet/26982093806630?p=5LEsSsypMjOTZgEWjc
