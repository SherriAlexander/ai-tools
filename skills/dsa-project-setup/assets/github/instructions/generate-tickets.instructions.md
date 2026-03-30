---
applyTo: "**"
---

# Jira Ticket Generation Instructions

These instructions govern how to generate and create Jira tickets from Figma designs using the Atlassian and Figma MCP servers.

---

## Workflow

When asked to generate tickets from a Figma design:

1. **Analyze the Figma frame** — Use `get_design_context` with the file key and node ID extracted from the Figma URL. Identify all components, containers, and page-level elements present.
2. **Identify the ticket scope** — Determine which components warrant individual tickets. Each distinct, reusable component gets its own Feature ticket. Layout containers (e.g. Full Bleed Container, Content Well) get their own tickets. Page templates get a separate Page Template ticket.
3. **Draft all tickets** — Write every ticket following the template below before creating any in Jira.
4. **Review with the user** — Present the draft tickets for review and approval.
5. **Create in Jira** — Use `createJiraIssue` for each approved ticket.

---

## Figma URL Parsing

Extract `fileKey` and `nodeId` from Figma URLs:

- `https://www.figma.com/design/{fileKey}/{fileName}?node-id={nodeId}`
- Convert `-` to `:` in `nodeId` (e.g. `1-6` → `1:6`)
- To deep-link a component in a ticket: `https://www.figma.com/design/{fileKey}/?node-id={nodeId}`

---

## Jira Project Defaults

Unless told otherwise:
- **Cloud ID**: `{{CLOUD_ID}}`
- **Target project**: `{{JIRA_PROJECT_KEY}}`
- **Reference project**: `{{JIRA_REFERENCE_PROJECT}}` (use as a canonical ticket example when available)
- **Issue type**: `{{JIRA_ISSUE_TYPE}}` for components and page templates
- **Issue type**: `Epic` for feature groupings (no description needed — name only)

To look up the target project key before creating tickets: use `getVisibleJiraProjects` and confirm with the user.

---

## Ticket Template — Feature (Component)

All content goes in the **`description` field** as markdown. There are no custom Jira fields — the section headings are the structure.

Use this exact template for component/container tickets:

```markdown
# Overview

[1–2 sentences in user story format: "As a [user], this component [does what] so that [why]." Do NOT include requirements here. Keep it concise and generic.]

# Image

[Reference the Figma frame: "See Figma design: [Component Name](https://www.figma.com/design/{fileKey}/?node-id={nodeId})"]

[If annotating behavior, describe annotations as numbered callouts referencing specific elements.]

# Functional Requirements

1. [First requirement — one verifiable behavior per item]
2. [Second requirement]
   1. [Sub-requirement or edge case]
   2. [Another sub-requirement]
3. [Continue for all interactions, states, and behaviors. Include happy path and error/empty states.]

**QA NOTE:** [Include inline QA callout notes in bold where there are known edge cases, CMS limitations, or testing gotchas — e.g. SXA styling limitations, default values that don't auto-apply, etc.]

## Data Sources

[Describe the data source pattern — local Data folder, shared folder, or auto-created on add.]

### Main Component

| **Section** | **Display Name** | **Machine Name** | **Field Type** | **Required** | **Default Value** | **Mapping** |
| --- | --- | --- | --- | --- | --- | --- |
| _Styling_ | [Field Name] | [machineName] | [Droplink / Checkbox / Single-Line Text / Multi-Line Text / Image / Rich Text / General Link / Date] | [true/false] | [value or NULL] | [link to related ticket if applicable] |

### Sub-Component

[Add table if the component has sub-components with their own fields. Omit section if not applicable.]

| **Section** | **Display Name** | **Machine Name** | **Field Type** | **Required** | **Default Value** | **Mapping** |
| --- | --- | --- | --- | --- | --- | --- |

# Authoring Considerations

1. See the Pages & Components Matrix for page-level availability and placeholder settings.
2. The component exists within the `[Rendering group name]` rendering group.
3. [Any "gotcha" CMS behaviors — edge cases that are easy for authors to misuse or for QA to miss. This section is critical for QA coverage.]

## Rendering Variants

[If the component has multiple visual variants, document them here. If only one variant exists, omit this section.]

This component includes multiple layout variants. The rendering outlined in this ticket represents the _Default_ variant.

**Variant options:**

1. Default
2. [link to variant ticket]

# Responsive Design Considerations

## Large Viewport

[Describe layout at large screen widths — column counts, image scaling, component visibility.]

## Medium Viewport

[Describe changes at medium breakpoint — stacking behavior, reflow, image scaling.]

## Small Viewport

[Describe mobile layout — stacking, truncation, touch targets, any hidden elements.]

# Search and Analytics Considerations

[Describe which fields should be indexed for internal search (Coveo, Sitecore Search, etc.), faceting, and analytics tracking. If not applicable, write: N/A]

# Third-Party Integrations

[Document any integrations inline for small ones (YouTube, Open Graph). For large integrations (Salesforce, etc.), link to the relevant Confluence documentation. If not applicable, write: N/A]

# Assumptions

[State assumptions made when writing the ticket — context only, NOT requirements. Example: "Article page template will be completed before this component." If none, write: N/A]

# Accessibility Guidelines

General accessibility implementation techniques and testing requirements are available in the [role-based accessibility checklists](https://velirs.atlassian.net/wiki/spaces/ACCESSIBILITY/pages/1583055554/Checklists+role-based).

[Add any component-specific accessibility notes — ARIA roles, keyboard navigation requirements, color contrast concerns. If none beyond the checklist, write: N/A]

# Other Notes and Considerations

[Contextual developer notes, external reference links, design inspiration, or anything that doesn't fit above. If none, write: N/A]
```

---

## Ticket Template — Page Template / Layout Details

Use for page-level tickets (e.g. "Homepage Data Template and Layout Details").

```markdown
# Overview

[1–2 sentences describing the page type and its purpose.]

# Image

[Link to the Page-Level Specification (PLS) or annotated wireframe in Figma or Confluence.]

# Data Template Details

| **Section** | **Display Name** | **Machine Name** | **Field Type** | **Required** | **Default Value** | **Mapping** |
| --- | --- | --- | --- | --- | --- | --- |

**Insert Options:** [Pages and folders available under this page node in the content tree.]

**Standard Field Values:** [Any fields pre-populated with standard values across all instances.]

# Page Layout & Placeholder Settings

[Define static components (not removable by author) vs. allowable components per placeholder/container. Reference branch templates for default page state.]

# SEO Considerations

[Meta tag populations, schema markup requirements, author-facing SEO fields (page title, URL path, heading structure). Reference the Schema and Open Graph definition document if applicable.]

# Assumptions

N/A

# Other Notes and Considerations

N/A
```

---

## Quality Rules

These rules are non-negotiable. AI-generated tickets must comply:

| Rule | Detail |
|---|---|
| **Summaries are generic** | Use component names, not placement descriptions. `Hero` not `Top Home Page Hero`. |
| **Overview = user story only** | 1–2 sentences, who/what/why. Zero requirements. |
| **Functional Requirements = ordered numbered lists** | Not prose. Not bullets. Dev and QA use them as checklists — every item must be independently verifiable. |
| **Assumptions ≠ Requirements** | Never put requirements in the Assumptions section. Assumptions are context only. |
| **Responsive = Large / Medium / Small** | Never say phone/tablet/desktop. Always use the three named viewport tiers. |
| **Authoring Considerations are critical for QA** | Surface every CMS edge case, gotcha, and "gotcha" behavior that QA needs to test. Do not skip or minimize this section. |
| **Inline QA NOTEs for known issues** | Bold `**QA NOTE:**` inline in Functional Requirements where there are known edge cases (e.g. SXA limitations, default values that don't auto-apply). |
| **Field definition tables are complete** | Every CMS field gets a row. Machine names use camelCase. Field type is specific (Droplink, Checkbox, Single-Line Text, etc.). |

---

## Figma Reference Guidelines

When writing tickets, reference Figma designs precisely:

- **Always include a Figma deep link** in the `# Image` section pointing to the specific frame/component node
- **Reference component names** exactly as they appear in Figma
- **Reference design tokens by name** when specifying visual behavior (e.g. color hex + token name, font name + weight)
- **Reference node IDs** in the link so designers and developers can navigate directly to the frame

Example image section:
```
# Image

See Figma design: [Hero Banner](https://www.figma.com/design/{fileKey}/?node-id=1:70)
```

---

## Ticket Scope Guidance

| Component type | Ticket approach |
|---|---|
| Standalone UI component (e.g. Card, Hero, Nav) | One `{{JIRA_ISSUE_TYPE}}` ticket per component |
| Layout container (e.g. Full Bleed Container, Content Well) | One `{{JIRA_ISSUE_TYPE}}` ticket per container type |
| Component variant (e.g. Card — Horizontal variant) | Separate ticket, linked to the base component ticket |
| Page template (e.g. Article Detail Page) | Page Template ticket (uses the page template format) |
| Shared configuration (e.g. Color Scheme parameter, Spacing enum) | One ticket shared across all components that use it |
| Epic | Name-only, no description. Groups related tickets. |

---

## Sprint Readiness Checklist

Before submitting a batch of tickets to Jira, confirm:

- [ ] All components from the Figma frame have a corresponding ticket
- [ ] Every ticket has a Figma deep link in the `# Image` section
- [ ] Functional Requirements are numbered lists, not prose
- [ ] Data Sources tables are complete with all fields
- [ ] Responsive Design section covers all three viewports
- [ ] No requirements buried in Assumptions
- [ ] Authoring Considerations cover all CMS edge cases
- [ ] Summaries are generic component names

---

## Example: Prompt Pattern

When a user provides a Figma URL, respond with:

1. A summary of components identified in the frame
2. Proposed ticket list (summary names only) for the user to confirm scope
3. After confirmation — full ticket drafts for review
4. After review — create in Jira using `createJiraIssue`

**Never create tickets in Jira without first presenting drafts for review.**
