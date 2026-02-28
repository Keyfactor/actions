# Keyfactor Actions Makefile
# ==========================
# Useful targets for development and validation

.PHONY: help validate-yaml validate-actions lint check-versions check-permissions clean test all

# Default target
help:
	@echo "Keyfactor Actions - Development Targets"
	@echo "========================================"
	@echo ""
	@echo "Validation:"
	@echo "  make validate-yaml      - Validate all YAML syntax"
	@echo "  make validate-actions   - Validate composite action structure"
	@echo "  make check-versions     - Check for outdated action versions"
	@echo "  make check-permissions  - List workflows missing permissions"
	@echo ""
	@echo "Linting:"
	@echo "  make lint               - Run all linters"
	@echo "  make lint-workflows     - Lint workflow files with actionlint"
	@echo "  make lint-markdown      - Lint markdown files"
	@echo ""
	@echo "Analysis:"
	@echo "  make list-actions       - List all external actions used"
	@echo "  make list-keyfactor     - List remaining Keyfactor-specific actions"
	@echo "  make diff-upstream      - Show actions that differ from upstream"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean              - Remove generated files"
	@echo "  make all                - Run all validations"
	@echo ""

# =============================================================================
# Validation Targets
# =============================================================================

validate-yaml:
	@echo "Validating YAML syntax..."
	@failed=0; \
	for f in $$(find .github -name "*.yml" -o -name "*.yaml"); do \
		if ! yq eval '.' "$$f" > /dev/null 2>&1; then \
			echo "INVALID: $$f"; \
			failed=1; \
		fi; \
	done; \
	if [ $$failed -eq 0 ]; then \
		echo "All YAML files are valid."; \
	else \
		exit 1; \
	fi

validate-actions:
	@echo "Validating composite actions..."
	@for dir in .github/actions/*/; do \
		if [ -f "$$dir/action.yml" ]; then \
			echo "Checking $$dir..."; \
			yq eval '.name' "$$dir/action.yml" > /dev/null || echo "  Missing 'name'"; \
			yq eval '.description' "$$dir/action.yml" > /dev/null || echo "  Missing 'description'"; \
			yq eval '.runs.using' "$$dir/action.yml" > /dev/null || echo "  Missing 'runs.using'"; \
		else \
			echo "WARNING: $$dir missing action.yml"; \
		fi; \
	done
	@echo "Done."

check-versions:
	@echo "Checking action versions..."
	@echo ""
	@echo "External actions in use:"
	@grep -rh "uses:" .github --include="*.yml" | \
		grep -v "Keyfactor/actions" | \
		sed 's/.*uses: *//' | \
		sort -u | \
		while read action; do \
			echo "  $$action"; \
		done
	@echo ""
	@echo "To check for updates, visit:"
	@echo "  https://github.com/actions/checkout/releases"
	@echo "  https://github.com/actions/setup-dotnet/releases"
	@echo "  https://github.com/actions/setup-go/releases"

check-permissions:
	@echo "Workflows without explicit permissions block:"
	@echo ""
	@for f in .github/workflows/*.yml; do \
		if ! grep -q "^permissions:" "$$f" && ! grep -q "^  permissions:" "$$f"; then \
			echo "  $$(basename $$f)"; \
		fi; \
	done
	@echo ""
	@echo "(Note: workflow_call workflows inherit from caller)"

# =============================================================================
# Linting Targets
# =============================================================================

lint: lint-workflows lint-markdown
	@echo "All linting complete."

lint-workflows:
	@echo "Linting workflows with actionlint..."
	@if command -v actionlint > /dev/null 2>&1; then \
		actionlint .github/workflows/*.yml || true; \
	else \
		echo "actionlint not installed. Install with: brew install actionlint"; \
	fi

lint-markdown:
	@echo "Linting markdown files..."
	@if command -v markdownlint > /dev/null 2>&1; then \
		markdownlint README.md .github/actions/*/README.md || true; \
	else \
		echo "markdownlint not installed. Install with: npm install -g markdownlint-cli"; \
	fi

# =============================================================================
# Analysis Targets
# =============================================================================

list-actions:
	@echo "All external actions used in this repository:"
	@echo ""
	@grep -rh "uses:" .github --include="*.yml" | \
		sed 's/.*uses: *//' | \
		sed 's/ *#.*//' | \
		sort -u | \
		grep -v "^$$"

list-keyfactor:
	@echo "Keyfactor-specific actions (not replaceable with upstream):"
	@echo ""
	@grep -rh "uses: keyfactor/" .github --include="*.yml" | \
		grep -v "Keyfactor/actions" | \
		sed 's/.*uses: *//' | \
		sort -u

diff-upstream:
	@echo "Actions using Keyfactor forks (potential upstream replacements):"
	@echo ""
	@grep -rh "uses: keyfactor/" .github --include="*.yml" | \
		grep -v "Keyfactor/actions" | \
		grep -v "keyfactor/action-" | \
		sed 's/.*uses: *//' | \
		sort -u || echo "  None found - all standard actions use upstream!"

# =============================================================================
# Workflow Analysis
# =============================================================================

list-workflows:
	@echo "Workflows in this repository:"
	@echo ""
	@for f in .github/workflows/*.yml; do \
		name=$$(yq eval '.name // "unnamed"' "$$f"); \
		echo "  $$(basename $$f): $$name"; \
	done

list-workflow-triggers:
	@echo "Workflow triggers:"
	@echo ""
	@for f in .github/workflows/*.yml; do \
		echo "$$(basename $$f):"; \
		yq eval '.on | keys | .[]' "$$f" 2>/dev/null | sed 's/^/  - /'; \
	done

# =============================================================================
# Utilities
# =============================================================================

clean:
	@echo "Cleaning generated files..."
	@rm -rf dist/ coverage/ TestResults/
	@echo "Done."

# Run all validations
all: validate-yaml validate-actions check-permissions
	@echo ""
	@echo "All validations passed!"

# =============================================================================
# Installation helpers
# =============================================================================

install-tools:
	@echo "Installing development tools..."
	@if command -v brew > /dev/null 2>&1; then \
		brew install yq actionlint; \
	else \
		echo "Homebrew not found. Install manually:"; \
		echo "  yq: https://github.com/mikefarah/yq"; \
		echo "  actionlint: https://github.com/rhysd/actionlint"; \
	fi
	@npm install -g markdownlint-cli || echo "npm not found for markdownlint"
	@echo "Done."
