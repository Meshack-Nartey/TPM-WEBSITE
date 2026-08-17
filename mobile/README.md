# TPM Mobile

Flutter app for Transformation Project Ministries, built from the design board
in Claude Design (`TPM Canvas.dc.html` → `TPM App.dc.html`).

All 29 screens from the board are implemented. **They run on mock data** — the
[Spring Boot API](../api) is being written in parallel, and swapping
`lib/data/mock_data.dart` for an API client is the next step.

```bash
cd mobile
flutter pub get
flutter run
```

## Two surfaces, one brand

The board's central idea, and the thing to preserve when adding screens:

- **Member and public** — light, blue-white-gold. Everything a member sees.
- **Leader and administrator portal** — gold on black. Work mode.

They are two `ThemeData` builders in `lib/theme/tpm_theme.dart`, not one theme
with a brightness flag, because they are different products wearing one brand.
Crossing between them is deliberate and announced: the portal entry under
**More** is styled in the portal's own palette so the change of surface is
visible before you commit to it.

Playfair Display carries headings and figures; Montserrat carries body text and
the gold uppercase eyebrow that opens most sections.

## Layout

```
lib/
  app/          session (who is signed in), navigation types
  data/         mock_data.dart — the design board's copy, verbatim
  models/       plain data classes
  screens/
    auth/       splash, welcome, sign in, register, biometric
    member/     13 screens — home through more
    leader/     dashboard, weekly report, registry, register member, member detail
    admin/      overview, approvals, access, manage lists, compose
    system/     data states
  theme/        colour, type, elevation tokens
  widgets/      shared components, charts, the two navigation shells
assets/         photography, book covers and giving marks from the website
```

## Things that are load-bearing

**The weekly report works offline.** Branch leaders fill it in on the way home
from a service, often on a bar of GPRS. Submitting offline saves to the device
and queues; reconnecting drains the queue. The banner always names which of the
four states you are in, because a silently-queued report is worse than none.
The API's `reports` table is unique on (branch, meeting, date) so a report that
syncs twice cannot double-count attendance.

**Give is honest.** In-app payment does not exist yet, so the screen says so and
hands off to the existing web giving page rather than dressing up a dead end.

**Members do not own their record.** Profile offers "Request to update", not
"Edit"; that request is what appears on the admin approvals screen.

**Leaders see one branch.** The dashboard says so on screen — cheaper than
having someone wonder why the numbers look small.

## Assets

Photography, the seven book covers and the MTN MoMo / Telecel Cash / Stanbic
marks all come from `frontend/assets` — the same images the website uses, just
renamed to kebab-case and downscaled to 1200px. Nothing here is stock imagery.

Names, figures and sermon titles in `mock_data.dart` are invented placeholders.

## Tests

```bash
flutter test
```

38 tests. The useful one is `test/screens_render_test.dart`, which pumps every
board screen at 390×844 and asserts `takeException()` is null. A RenderFlex
overflow throws during layout in debug, so this is a real check that each
screen lays out rather than a claim that it does — it found 11 overflows the
first time it ran. Three behaviour tests cover the report's offline cycle,
clearing an approval, and registry search.

## Prototype affordance

Sign-in has a **"Prototype · sign in as"** role picker. It stands in for the
role the API will return on the real token, so the leader and admin screens
stay reachable with no backend. Delete it when auth is wired up — it is in
`lib/screens/auth/sign_in_screen.dart`.
