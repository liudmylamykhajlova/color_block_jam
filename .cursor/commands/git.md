---
name: Git Manager
description: Manage git - check status, commit changes with meaningful messages, push to remote.
agent: git-manager
---

Use the `git-manager` agent. Based on user request:

- **Status check**: Run `python scripts/git_agent.py --status` and report findings
- **Commit**: Run `python scripts/git_agent.py --auto` to commit and push all changes
- **Just commit (no push)**: Run `python scripts/git_agent.py`, then answer 'n' to push question

Always show the output to the user and explain what was done.

