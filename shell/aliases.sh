# =============================================================================
# General
# =============================================================================

alias cls='clear'

# =============================================================================
# Workspace Navigation
# =============================================================================

alias per='cd "$PERSONAL"'
alias wrk='cd "$WORK"'
alias demo='cd "$DEMO"'

# =============================================================================
# OpenText OCP
# =============================================================================

alias vsf='cd "$OCP/ot2-vscode-foundation"'
alias app='cd "$OCP/mfe/admin-console-app"'
alias mfe='cd "$OCP/mfe/alm-microfrontend"'
alias e2e='cd "$OCP/ot2-vscode-e2e"'
alias ocli='cd "$OCP/ot2-cli"'
alias osbp='cd "$OCP/solution-builder"'
alias onpm='cd "$OCP/npm-components"'

# =============================================================================
# OCP Workspace
# =============================================================================

alias ows='cd "$OCP/ocp-workspace/alm-project-meta-data"'
alias vows='code "$OCP/ocp-workspace/alm-project-meta-data"'

# =============================================================================
# Demo Projects
# =============================================================================

alias oai='cd "$DEMO/opentext_ai"'
alias dsbp='cd "$DEMO/solution-builder-poc"'
alias dash='cd "$DEMO/otx/ocp-security-advocate"'
alias adt='cd "$DEMO/adt/adt-templates-26.01.001"'

# =============================================================================
# Personal
# =============================================================================

alias dlt='cd "$PERSONAL/delete_later"'

# =============================================================================
# Git
# =============================================================================

alias gtag='git tag | xargs git tag -d; git fetch origin --tags'

# =============================================================================
# Utilities
# =============================================================================

alias gclone='python "$PERSONAL/utility_scripts_python/gclone.py"'
alias devx='cd "$WORK/devx/sign-up-services"'
