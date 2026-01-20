Criteria for evaluating and deciding whether to install a plugin or extension for any application. By not just installing every plugin I am curious in, the goal is to be intentional about adding dependencies to workflows and to avoid unnecessary bloat, performance issues, or security risks.
## Evaluation Criteria
#ai-slop
Before installing a new plugin, consider the following aspects:

- **Core Problem:** Does this plugin solve a significant, recurring problem or just a minor annoyance?
- **Performance:** What is the potential performance impact? Does it slow down application startup or core operations? Check reviews and community feedback for performance-related complaints.
- **Maintenance & Activity:** Is the plugin actively maintained? Compare repos with [[repo-stats.ps1]]
    - An abandoned plugin can become a security risk or break with future application updates.
    - Check the date of the last commit or release.
    - Are issues and pull requests being addressed?
- **Security & Privacy:**
    - If the permissions system isn't just "Run in a process as you", what permissions does the plugin require? Does it need access to your data or the ability to send information over the network?
    - Is the plugin open source? Reviewed by the community?
- **Configuration & Fit:**
    - How much configuration is required?
    - Does it integrate well with your existing workflow, or does it force you to change it in awkward ways?
    - Is the functionality already available through existing tools or native features?
- **Alternatives:** Have you looked for alternatives? Is there a simpler or more lightweight option available? Could a simple script or a different workflow achieve the same result?
