# Setup Java Action

[![Keyfactor](https://img.shields.io/badge/Keyfactor-orange?logo=github)](https://github.com/Keyfactor/actions)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

> Sets up Java JDK with Maven/Gradle caching and optional custom Maven settings.

| Branding | |
|----------|---|
| Icon | `coffee` |
| Color | `orange` |

## Usage

```yaml
- uses: Keyfactor/actions/.github/actions/setup-java@v6
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `java-version` | Java version to install | No | `'17'` |
| `distribution` | Java distribution (temurin, corretto, zulu, etc.) | No | `'temurin'` |
| `cache` | Build tool to cache (`maven`, `gradle`, or empty) | No | `'maven'` |
| `maven-settings` | Path to custom Maven settings.xml | No | `''` |

## Outputs

| Output | Description |
|--------|-------------|
| `java-version` | Installed Java version |
| `distribution` | Java distribution used |
| `cache-hit` | `'true'` if build cache was restored |

## Features

1. **JDK Installation**: Installs specified Java version and distribution
2. **Build Tool Caching**: Caches Maven or Gradle dependencies
3. **Custom Maven Settings**: Supports custom `settings.xml` for private repositories
4. **Maven Verification**: Verifies Maven installation when caching Maven
5. **Step Summary**: Displays environment info in GitHub Actions summary

## Supported Distributions

| Distribution | Description |
|--------------|-------------|
| `temurin` | Eclipse Temurin (default, recommended) |
| `corretto` | Amazon Corretto |
| `zulu` | Azul Zulu |
| `liberica` | BellSoft Liberica |
| `microsoft` | Microsoft Build of OpenJDK |
| `oracle` | Oracle JDK |
| `dragonwell` | Alibaba Dragonwell |
| `sapmachine` | SAP Machine |

## Examples

### Basic Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4
      - uses: Keyfactor/actions/.github/actions/setup-java@v6
      - run: mvn package
```

### Specific Java Version

```yaml
- uses: Keyfactor/actions/.github/actions/setup-java@v6
  with:
    java-version: '11'
```

### Java 21 with Corretto

```yaml
- uses: Keyfactor/actions/.github/actions/setup-java@v6
  with:
    java-version: '21'
    distribution: 'corretto'
```

### Gradle Project

```yaml
- uses: Keyfactor/actions/.github/actions/setup-java@v6
  with:
    cache: 'gradle'

- run: ./gradlew build
```

### Custom Maven Settings

```yaml
- uses: Keyfactor/actions/.github/actions/setup-java@v6
  with:
    maven-settings: '.github/maven-settings.xml'
```

Example `.github/maven-settings.xml`:
```xml
<settings>
  <servers>
    <server>
      <id>github</id>
      <username>${env.GITHUB_ACTOR}</username>
      <password>${env.GITHUB_TOKEN}</password>
    </server>
  </servers>
</settings>
```

### No Caching

```yaml
- uses: Keyfactor/actions/.github/actions/setup-java@v6
  with:
    cache: ''
```

### Complete Maven Build Workflow

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4

      - uses: Keyfactor/actions/.github/actions/setup-java@v6
        with:
          java-version: '17'
          maven-settings: '.github/maven-settings.xml'

      - name: Build
        run: mvn -B package --file pom.xml

      - name: Test
        run: mvn -B test

      - name: Upload JAR
        uses: actions/upload-artifact@v4
        with:
          name: app-jar
          path: target/*.jar
```

### Multi-Version Matrix

```yaml
jobs:
  build:
    strategy:
      matrix:
        java: ['11', '17', '21']
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4

      - uses: Keyfactor/actions/.github/actions/setup-java@v6
        with:
          java-version: ${{ matrix.java }}

      - run: mvn -B verify
```

### Check Cache Hit

```yaml
- uses: Keyfactor/actions/.github/actions/setup-java@v6
  id: setup

- name: Report cache status
  run: |
    if [ "${{ steps.setup.outputs.cache-hit }}" == "true" ]; then
      echo "Maven dependencies restored from cache"
    else
      echo "Maven dependencies downloaded fresh"
    fi
```

### Spring Boot Application

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: keyfactor/checkout@v4

      - uses: Keyfactor/actions/.github/actions/setup-java@v6
        with:
          java-version: '17'

      - name: Build with Maven
        run: mvn -B spring-boot:build-image
```

## Maven Settings Location

When `maven-settings` is provided, the file is copied to `~/.m2/settings.xml`.

The directory `~/.m2` is created if it doesn't exist.

## Step Summary Output

The action appends environment information to `$GITHUB_STEP_SUMMARY`:

```markdown
### Java Environment
- **Java Version:** openjdk version "17.0.9" 2023-10-17
- **Distribution:** temurin
- **Cache Hit:** true
```

## Cache Configuration

### Maven Cache
- **Path**: `~/.m2/repository`
- **Key**: Based on `pom.xml` and `**/pom.xml` files

### Gradle Cache
- **Path**: `~/.gradle/caches`
- **Key**: Based on `*.gradle*` and `gradle-wrapper.properties`

## Requirements

- Ubuntu, Windows, or macOS runner
- `pom.xml` or `build.gradle` for caching

## Related Actions

- [detect-language](../detect-language/) - Detect repository language
- [setup-dotnet](../setup-dotnet/) - Setup .NET environment
- [setup-go](../setup-go/) - Setup Go environment
