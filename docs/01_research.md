# DaysTracker - Competitive & UX Research

## 1. Problem and Context

DaysTracker solves a practical but underserved problem: people who move between countries and cities need a reliable record of where they have been and for how long, without turning that task into a spreadsheet habit or a compliance project.

The strongest market gap is between two established product types:

- Travel and journaling apps that are memorable, visual, and emotionally engaging, but weak at structured day counting.
- Residency and Schengen tools that are precise and useful, but often heavy, technical, or anxiety-inducing.

DaysTracker should sit between those categories with a clearer point of view:

- It is primarily a personal tracker for time spent in countries and cities.
- It can borrow warmth, recall, and narrative lightness from diary products, but that should live in tone and UX treatment rather than in product positioning.
- It includes light Schengen 90/180 awareness as a secondary helper, not as the app's identity.
- It is not legal advice, not a tax engine, not a trip planner, and not a social travel network.

What this means for product and UX decisions:

- The core job is not "write about my trip." The core job is "show me where I was and how many days I spent there."
- Emotional value still matters, because a purely utilitarian tracker is easier to abandon once the urgent need passes.
- The app should feel calm and trustworthy, especially around permissions, automation, and Schengen messaging.
- Offline-first, local-only behavior is not just a technical choice; it is part of the product promise and differentiator.

## 2. Competitor Landscape (high level)

### Travel / journey tracking apps

These products are strong at recall, storytelling, and map-based memory, but weak at precise country and city day counting.

- **Polarsteps**
  - Does route capture, map storytelling, and trip recap exceptionally well.
  - Feels polished and motivating, but is oriented toward sharing, stories, stats, and travel memorabilia rather than accurate day accounting.
  - Relevant pattern for DaysTracker: visual route recall and automatic history-building are powerful.
  - Pattern to avoid: social and storytelling layers that distract from fast day answers.
- **Day One**
  - Strong at private journaling, warm writing flows, and trustworthy privacy framing.
  - Weak at geographic aggregation and structured country/city analysis.
  - Relevant pattern for DaysTracker: premium private feel, gentle onboarding, and respectful copy.
  - Pattern to avoid: note-first interaction that makes location tracking feel secondary.
- **FindPenguins**
  - Combines trip tracking, maps, travel logs, and community/social discovery.
  - Makes journeys feel alive and connected, but is not built around day counts, country thresholds, or precise personal accounting.
  - Relevant pattern for DaysTracker: chronological route visualization can make history more legible and rewarding.
  - Pattern to avoid: community and public-sharing expectations.
- **Journey**
  - Focuses on personal journaling with a calm, reflective tone.
  - Supports the habit of recording life, but not the structured problem of country/city presence and rolling counts.
  - Relevant pattern for DaysTracker: softness in tone and non-threatening atmosphere.
  - Pattern to avoid: making freeform journaling the main interaction model.

What this bucket means for DaysTracker:

- Borrow visual memory and calm tone.
- Do not borrow social identity, story-first structure, or note-heavy capture.
- Maps and journey views should support recall and orientation, not publishing.

### Residency / day-count trackers

These products are strong at rules, thresholds, and precision, but often drift toward audit tooling, legal framing, or power-user complexity.

- **TrackingDays**
  - Tracks days and nights, supports Schengen and other residency rules, and is built around practical counting.
  - Its strength is clarity and trust for people who need numbers.
  - Its weakness is that the experience feels more like a tracking utility than a product with emotional retention.
  - Relevant pattern for DaysTracker: clear period-based counts and confidence in the math.
  - Pattern to avoid: reducing the whole product to a ledger.
- **Days Monitor**
  - Offers global day tracking, automatic background logging, alerts, and rule coverage across several regions.
  - Useful for serious compliance needs, but the breadth of rules, notifications, and reference content pulls it toward a compliance dashboard.
  - Relevant pattern for DaysTracker: automatic tracking and customizable limits are valuable ideas.
  - Pattern to avoid: visa- and tax-first tone that makes the product feel stressful.
- **Domicile365**
  - Is comprehensive and professionalized, with advisor-sharing and multi-jurisdiction rule support.
  - Strong for audit confidence and specialist workflows, but feels built for reporting and compliance management rather than everyday personal use.
  - Relevant pattern for DaysTracker: trust comes from precision and clear records.
  - Pattern to avoid: professional-service features and audit framing in the core product.
- **Nomad Tracker (PH)**
  - Combines automatic tracking, country rules, Schengen, tax-related thresholds, exports, and history reconstruction from existing data.
  - Shows how compelling "start from your real history" can be, especially when users do not want to enter everything manually.
  - Its weakness is scope creep into a power-user tool.
  - Relevant pattern for DaysTracker: photo-based history reconstruction is a strong wedge into user value.
  - Pattern to avoid: packing too many advanced rule systems into the MVP.
- **Country Days Tracker**
  - Overlaps closely with the DaysTracker value proposition through automatic counting, custom ranges, imports, privacy framing, and country-based reporting.
  - Its strength is obvious usefulness.
  - Its weakness is that it becomes feature-dense quickly, which risks a functional but less inviting feel.
  - Relevant pattern for DaysTracker: day views by country and city, plus import-from-photos, are highly relevant.
  - Pattern to avoid: letting every edge-case control surface into the mainstream UX.

What this bucket means for DaysTracker:

- Borrow counting clarity, trusted summaries, and history reconstruction.
- Keep the surface area lighter than compliance apps.
- Let precision exist behind a calm front door.

### Schengen 90/180 calculators

These products solve one narrow problem well: "How many days do I have left?" They are useful, but they rarely build a broader product relationship.

- **Schengen Simple**
  - Stands out for clear allowance explanations and forward-looking simulation.
  - Its strength is that it makes a complicated rule feel understandable.
  - Its weakness is narrowness: outside Schengen planning, the product has little broader travel history value.
  - Relevant pattern for DaysTracker: show days used, days remaining, and a simple explanation of why the number is what it is.
- **Entorii**
  - Offers both web and app experiences, along with dashboards, simulation, alerts, and reports.
  - Useful for planning and forecasting, but starts to feel more like a specialized compliance planner than a personal travel tracker.
  - Relevant pattern for DaysTracker: simulation is a meaningful future enhancement.
  - Pattern to avoid: letting planning tools dominate the product too early.
- **Schengen Diary**
  - Is simple and practical: it records trips, shows whether planned dates are valid, and explains invalid periods.
  - Its strength is simplicity.
  - Its weakness is that it is locked to one rule and one region.
  - Relevant pattern for DaysTracker: concise validation and explanation are helpful.
  - Pattern to avoid: red/green logic that feels punitive or alarmist.
- **ninety180.com**
  - Is valuable because it answers one question quickly with very little friction.
  - Demonstrates the importance of immediate, trustworthy output.
  - Its weakness is that it is a calculator, not a retained product.
  - Relevant pattern for DaysTracker: fast input and instant math should shape the Schengen summary experience.

What this bucket means for DaysTracker:

- Borrow directness, simplicity, and explanation.
- Keep Schengen integrated into the broader tracker experience.
- Avoid becoming a single-purpose calculator.

## 3. Key UX Patterns to Borrow or Avoid

### Patterns to borrow

- **Fast structured capture**
  - Logging should feel lighter than using a spreadsheet.
  - Users should be able to create or confirm visits in a few clear steps.
- **Map-backed recall**
  - A map is valuable when it helps users reconstruct where they have been, not when it becomes decorative.
- **History reconstruction from existing data**
  - Photo metadata import is one of the highest-leverage onboarding moves because it turns an empty app into a useful one quickly.
- **Simple numeric summaries**
  - Schengen and country-day counts should be shown as plain-language answers before any supporting detail.
- **Trust-building privacy language**
  - Private-journal products show that tone matters.
  - The app should explain permissions and data handling in normal language, not policy language.
- **Progressive disclosure**
  - Mainstream users should see only the information needed to complete the current task; advanced details can appear later, inside drill-downs or secondary views.
- **Review-before-save automation**
  - Confidence-based suggestions are better than silent automation in a domain where false positives damage trust.

### Patterns to avoid

- **Fear dashboards**
  - Heavy warning colors, legal phrasing, and "you are violating" language create anxiety and change the character of the product.
- **Social travel framing**
  - Feeds, followers, public trip books, and story-centric layouts do not support the core job.
- **Power-user-first settings**
  - Provider-specific configuration and rule-management surfaces should never sit on the critical path for ordinary users.
- **Rule explosion in MVP**
  - A growing matrix of country-specific tax and visa logic would dilute the product and raise maintenance cost.
- **Persona-branching onboarding**
  - The shared job is strong enough that one universal onboarding flow is better than trying to guess who the user is.
- **Empty-state dead ends**
  - A blank screen with no quick path to real data makes retention harder in a utility app.

## 4. Hypotheses and Questions

### Assumptions that look strong

- **Privacy-first, local-only storage is a real differentiator**
  - It is not just a feature checkbox; it aligns tightly with the audience's distrust of cloud tracking.
- **Hybrid framing is the right call**
  - "Personal tracker" is stronger positioning than "travel diary," while diary warmth still improves retention and tone.
- **Photo Import should be the recommended onboarding path**
  - It shortens time-to-value better than asking users to build their history from zero.
- **Equal weighting across nomads, expats, and frequent travellers is sensible**
  - Their context differs, but the underlying job is similar enough that the product does not need three separate identities.
- **Schengen belongs as a secondary layer**
  - It is valuable enough to matter, but too narrow and too anxiety-prone to define the whole product.

### Assumptions to challenge

- **Background tracking should not be the hero feature**
  - Automatic tracking is useful, but it introduces privacy, battery, and false-positive concerns.
  - It should feel optional and supportive, not like the app's central promise.
- **Residency awareness should not turn into explicit compliance language in MVP**
  - The product becomes heavier and more legally loaded as soon as it presents itself as a residency tool.
  - In MVP, country/city day counts and Schengen are enough.
- **Technical service setup should not surface in the core UX**
  - If advanced location or geocoding configuration is required, it should be secondary and generic in wording.
  - Provider-specific implementation details belong in technical documentation, not in the product brief.
- **My Journey should not be a permanent top-level destination in MVP**
  - It is meaningful only once the user has enough history.
  - Hiding the entry point until at least three visited cities is a good product discipline.

### Open questions

- What period should be the default landing view in `Statistics`: `365 days`, `183 days`, or the last-used filter?
- How much inline editing should photo-import suggestions allow before the review step becomes too heavy?
- How should the app show pending or unresolved background pings when geocoding is unavailable offline?
- How much platform parity should users expect from `Import from Photos` if source access differs between devices?

## 5. UX Opportunities

- **Use onboarding to establish trust before asking for data**
  - Lead with the promise: private, local-only, and useful without complexity.
- **Make Photo Import the fastest route to a meaningful timeline**
  - A user should feel "this app already knows enough to help me" within the first session.
- **Turn counts into fast answers, not reports**
  - The best `Statistics` experience is closer to "How many days in Spain this year?" than to a compliance spreadsheet.
- **Give the map a clear job**
  - It should help users see coverage, tap countries and cities for totals, and unlock `My Journey` only when the history is rich enough to justify it.
- **Treat Schengen as calm math**
  - Show `used`, `remaining`, `window`, and `earliest return date if over limit`, but keep the language supportive and non-legalistic.
- **Use confidence labels to reduce automation anxiety**
  - "Confirmed" versus "Possible" is a strong, understandable model for both photo import and low-confidence tracking events.
- **Design empty states with light emotional value**
  - The app does not need to become a diary, but it should still feel human and motivating when history is sparse.
- **Make data control a retention feature**
  - Import, export, clear data, and permission status are not just settings; they reinforce the core trust promise.
- **Keep advanced scope clearly staged**
  - Alerts, simulations, and broader rule engines can become future upgrades once the personal tracker loop is stable.
- **Differentiate through restraint**
  - The market already has products that are more social, more legalistic, and more feature-dense.
  - DaysTracker should win by being calmer, clearer, and easier to keep using.
