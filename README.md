# BASED Agent Framework

A spec-oriented agent framework for bootstrapping agent-driven software projects.

Agent definitions live in `agents/` in this repository. The install script deploys them into `.opencode/agents/` in the target project so new projects can follow:

```text
task -> spec -> implementation
```

## Install

Run this from the target repository:

```bash
curl -fsSL https://raw.githubusercontent.com/wwnbb/based_agents/master/install.sh | bash
```

Framework details live in [`BASED_AGENT.md`](./BASED_AGENT.md).
