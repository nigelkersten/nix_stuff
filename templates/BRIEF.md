# Project: [name]

> Briefs follow the structure below. Delete sections that don't apply.
> The point of the template is to force you to think about each axis,
> not to fill in every box.

## What this is

One paragraph. What's the tool, who's it for, what does it replace or
enable. Avoid feature lists at this stage — describe the *outcome*, not
the implementation.

## Scope for this session

What you want built in this run. Be explicit about what's *not* in scope
yet. Future-session work belongs in the "Roadmap" section below, not here.

## Inputs and outputs

What does the tool take in? What does it produce? Where do outputs land?
This is the most important section to get right — most agent failures
trace back to fuzziness here.

If there are multiple input variables, list them and note which are
required vs optional. Brief tools that touch real-world data (CVs, URLs,
files) should specify formats explicitly.

## Acceptance criteria

How do I know it's done? Write criteria you'd use to demo the tool to
someone else. Each line should be testable — either a command that
should succeed, an artefact that should exist, or an observable
behaviour.

Examples:
- `<command>` produces `<output>` in under `<time>`
- All N sections of the output are populated, none empty
- Tests pass with mocked external services
- README explains setup, usage, and where secrets live

## Constraints and conventions

Cross-reference `~/.claude/CLAUDE.md` rather than restating its rules.
List only project-specific deviations or additions:
- Which language/framework if not the default
- Which models if it uses LLMs
- Which external services and how to authenticate to them
- Any explicit non-goals (e.g., "no web framework yet", "no auth yet")

## Implementation notes

Optional. Use sparingly. Notes here should be either:
- Things the agent genuinely wouldn't infer (e.g., "use the Anthropic
  web search tool, not custom scraping")
- Architectural hints that future sessions depend on (e.g., "structure
  so a web layer can wrap this without modification")

If you find yourself prescribing module names, function signatures, or
file structure here, stop. That's the "specify everything in the middle"
trap — either let the agent design freely or specify the contract very
tightly. Don't sit between.

## Roadmap (optional)

Future sessions you anticipate but aren't building now. One line each.
Helps the agent shape current decisions for future extensibility without
building anything speculative.

## What I want you to do

The closing instruction. Some standard variants:

- **Autonomous:** "Run autonomously. Make architectural decisions as
  needed; document non-obvious choices in code comments. Don't ask for
  clarification on small details. Flag genuinely ambiguous architectural
  choices in TODO comments for me to review later."

- **Stepwise:** "Propose a plan first. I'll review and approve before
  you start coding."

- **Spec-and-stop:** "Produce only the architecture and interfaces. No
  implementation. I'll review and request implementation in a follow-up."

Pick one and commit to it.
