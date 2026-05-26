# Architecture Analysis & Review Prompt

## Objective
Conduct a comprehensive architecture analysis and review of this Flutter mobile application repository. Evaluate the current architecture against best practices, identify strengths and weaknesses, and provide actionable recommendations for improvement.

## Scope of Analysis

### 1. Architecture Patterns & Design
- **Overall Architecture Pattern**: Evaluate the offline-first, feature-first architecture with Riverpod DI
- **Layer Separation**: Assess the separation between presentation, state management, persistence, and services
- **Dependency Flow**: Analyze dependency directions and identify any circular dependencies or violations of clean architecture principles
- **State Management**: Review Riverpod provider usage, state composition, and reactivity patterns
- **Data Flow**: Trace data flow from UI → Services → Database → Cloud and back

### 2. Code Organization & Structure
- **Directory Structure**: Evaluate the `lib/core/`, `lib/features/`, `lib/services/`, `lib/shared/` organization
- **Module Boundaries**: Assess feature isolation and cross-cutting concerns
- **File Organization**: Review naming conventions, file sizes, and logical grouping
- **Code Reusability**: Identify opportunities for better abstraction and shared components

### 3. Data Layer Architecture
- **Local Persistence**: Review Drift database schema, DAOs, and query patterns
- **Cloud Sync Strategy**: Evaluate the bidirectional sync architecture with Supabase
- **Data Consistency**: Assess conflict resolution, dirty tracking, and sync status management
- **Migration Strategy**: Review database migration patterns and versioning

### 4. Service Layer Design
- **Service Boundaries**: Evaluate service isolation (AI, Market, Sync, Privacy, Analytics)
- **Integration Patterns**: Review external API integration approaches (Tradera, Supabase)
- **Background Processing**: Assess Workmanager integration and background sync architecture
- **Isolate Usage**: Review AI inference isolate pattern and resource management

### 5. Cross-Cutting Concerns
- **Error Handling**: Evaluate error handling strategy across layers
- **Logging & Observability**: Review analytics and Sentry integration patterns
- **Configuration Management**: Assess compile-time and runtime configuration approaches
- **Feature Flags**: Review feature flag implementation and usage

### 6. Scalability & Performance
- **Resource Management**: Evaluate memory usage, file I/O patterns, and resource cleanup
- **Concurrency**: Review async patterns, isolate usage, and serial task queue implementation
- **Caching Strategy**: Assess market data caching and photo storage patterns
- **Database Performance**: Review query optimization and indexing strategy

### 7. Security & Privacy
- **Authentication Flow**: Evaluate Supabase auth integration and guest mode support
- **Data Privacy**: Review privacy controls, data export, and account deletion flows
- **Sensitive Data Handling**: Assess credential management and secure storage
- **API Security**: Review edge function security and proxy patterns

### 8. Testing Architecture
- **Test Coverage**: Evaluate unit, widget, and golden test coverage
- **Test Organization**: Review test structure and naming conventions
- **Testability**: Assess how architecture supports testing (DI, mocking, isolation)

### 9. Backend Architecture (Supabase)
- **Edge Functions**: Review Tradera proxy and account deletion function design
- **Database Schema**: Evaluate Supabase schema and migration strategy
- **API Design**: Assess edge function API contracts and error handling

### 10. Technical Debt & Code Quality
- **Code Smells**: Identify anti-patterns, god objects, and overly complex modules
- **Duplication**: Find repeated code that could be abstracted
- **Complexity**: Identify areas with high cyclomatic complexity
- **Documentation**: Assess inline documentation and architectural documentation quality

## Analysis Approach

### Phase 1: High-Level Architecture Review
1. Read and analyze existing architecture documentation (`.planning/codebase/ARCHITECTURE.md`, `STACK.md`, `STRUCTURE.md`)
2. Review entry points (`lib/main.dart`, background sync, edge functions)
3. Map out the dependency graph and layer interactions
4. Identify the core architectural patterns in use

### Phase 2: Deep Dive by Layer
1. **Presentation Layer**: Review `lib/features/**` and `lib/shared/widgets/**`
2. **State Management**: Analyze `lib/core/app/providers.dart` and provider usage patterns
3. **Persistence Layer**: Examine `lib/core/database/**` (tables, DAOs, migrations)
4. **Service Layer**: Review `lib/services/**` (AI, Market, Sync, Privacy)
5. **Backend**: Analyze `supabase/functions/**` and `supabase/migrations/**`

### Phase 3: Cross-Cutting Analysis
1. Trace critical user flows (e.g., scan → persist → AI → market sync → cloud sync)
2. Analyze error handling patterns across the codebase
3. Review configuration and feature flag usage
4. Assess testing strategy and coverage

### Phase 4: Quality & Maintainability
1. Identify code smells and anti-patterns
2. Evaluate code complexity and maintainability metrics
3. Review documentation quality and completeness
4. Assess adherence to Flutter/Dart best practices

## Deliverables

### 1. Executive Summary
- Overall architecture health score (1-10)
- Top 5 strengths
- Top 5 concerns
- Critical issues requiring immediate attention

### 2. Detailed Findings by Category
For each analysis area (1-10 above), provide:
- **Current State**: What exists today
- **Strengths**: What's working well
- **Weaknesses**: What needs improvement
- **Risks**: Potential issues or technical debt
- **Recommendations**: Specific, actionable improvements

### 3. Architecture Diagrams
- High-level system architecture diagram
- Data flow diagrams for critical paths
- Dependency graph showing layer relationships
- Sync architecture diagram (local ↔ cloud)

### 4. Code Quality Metrics
- Complexity hotspots (files/functions with high complexity)
- Duplication analysis
- Test coverage gaps
- Dependency coupling metrics

### 5. Prioritized Recommendations
Categorize recommendations by:
- **Critical** (security, data loss, crashes)
- **High** (performance, scalability, major tech debt)
- **Medium** (code quality, maintainability)
- **Low** (nice-to-haves, optimizations)

### 6. Refactoring Roadmap
- Quick wins (low effort, high impact)
- Medium-term improvements (1-3 months)
- Long-term architectural evolution (3-6 months)

## Key Questions to Answer

1. **Architecture Fitness**: Does the current architecture support the product requirements effectively?
2. **Scalability**: Can the architecture handle growth in users, data, and features?
3. **Maintainability**: How easy is it to understand, modify, and extend the codebase?
4. **Testability**: Does the architecture facilitate comprehensive testing?
5. **Performance**: Are there architectural bottlenecks or inefficiencies?
6. **Security**: Are there architectural security vulnerabilities?
7. **Offline-First**: Is the offline-first pattern implemented consistently and correctly?
8. **Cloud Sync**: Is the sync architecture robust and conflict-resistant?
9. **Technical Debt**: What technical debt exists and what's the payoff strategy?
10. **Best Practices**: Does the codebase follow Flutter/Dart/Supabase best practices?

## Context Files to Review

### Core Architecture
- `lib/main.dart` - App bootstrap and DI
- `lib/core/app/providers.dart` - Provider definitions
- `lib/core/database/app_database.dart` - Database schema
- `lib/core/navigation/app_nav_shell.dart` - Navigation shell

### Critical Services
- `lib/services/sync/sync_scheduler.dart` - Market sync orchestration
- `lib/services/sync/cloud/cloud_sync_coordinator.dart` - Cloud sync coordination
- `lib/services/ai/inference/inference_isolate_service.dart` - AI inference
- `lib/services/market/market_bridge.dart` - Market data integration

### Key Features
- `lib/features/scanner/scanner_screen.dart` - Scanner feature
- `lib/features/analyzer/item_detail_screen.dart` - Item analysis
- `lib/features/auth/auth_gate.dart` - Authentication flow

### Backend
- `supabase/functions/tradera-proxy/index.ts` - Tradera proxy
- `supabase/functions/account-delete/index.ts` - Account deletion
- `supabase/migrations/**` - Database migrations

### Configuration & Documentation
- `.planning/codebase/ARCHITECTURE.md` - Current architecture docs
- `.planning/codebase/STACK.md` - Technology stack
- `.planning/codebase/STRUCTURE.md` - Codebase structure
- `.planning/codebase/CONCERNS.md` - Known concerns
- `pubspec.yaml` - Dependencies

## Output Format

Provide the analysis as a structured markdown document with:
- Clear headings and subheadings
- Bullet points for findings
- Code examples where relevant
- Diagrams (mermaid syntax) for architecture visualization
- Severity indicators (🔴 Critical, 🟡 High, 🟢 Medium, ⚪ Low)
- Actionable recommendations with effort estimates

## Success Criteria

A successful architecture review will:
1. Provide a clear, honest assessment of the current state
2. Identify both strengths and weaknesses objectively
3. Offer specific, actionable recommendations
4. Prioritize issues by impact and effort
5. Include concrete examples from the codebase
6. Provide a roadmap for architectural improvements
7. Balance idealism with pragmatism (acknowledge constraints)
8. Be useful for both immediate fixes and long-term planning
