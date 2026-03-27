# Queue

Use this file to pin repository-specific priorities for the autonomous cycle when no steering task exists.

If `steering/active/` or `steering/inbox/` contains task files, those take precedence over this fallback queue.

Default priorities:

- choose one narrow, high-value improvement at a time
- prefer changes with a matching verification command
- avoid broad exploratory rewrites without a concrete payoff
