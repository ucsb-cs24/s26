# Quarter Sync Workflow

How to set up this course website for a new quarter.

## Scripts

| Script | Purpose |
|--------|---------|
| `sync_holidays.rb` | Creates/renames holiday placeholder files in `_lectures/` |
| `sync_dates.rb` | Shifts all `assigned`/`due` dates in `_lab/`, `_pa/`, `_lp/` |

---

## Steps for a new quarter

### 1. Update `_config.yml`

Change these fields:

```yaml
start_date: YYYY-MM-DD        # First Monday of instruction
dates_based_on: YYYY-MM-DD   # Set to the previous quarter's start_date
                               # (sync_dates.rb uses this to compute the offset)
holidays:
  - date: "YYYY-MM-DD"
    desc: "Holiday Name"
  # add one entry per holiday that falls on a lecture day
```

Also update: `url`, `baseurl`, `qtr`, `quarter`, `name`, `title`, `lect_repo`, `class_org`, `lecture_times`, `lecture_location`, `cal_dates`, `tas`, `ulas`, etc.

### 2. Sync holiday lecture files

```bash
ruby sync_holidays.rb --dry-run   # preview
ruby sync_holidays.rb             # apply
```

This reads `start_date`, `lecture_days`, and `holidays` from `_config.yml` and:
- Creates `_lectures/lect{N}a.md` (or `b`, `c`, …) for each holiday, where N is the
  count of actual lectures *before* the holiday in the schedule
- Hardcodes the `lecture_date` field (required because the date-computation include
  skips holidays and can never return a holiday date via sequence number)
- Reports any stale holiday files from the previous quarter so you can delete them

### 3. Shift assignment dates

```bash
ruby sync_dates.rb --dry-run   # preview
ruby sync_dates.rb             # apply
```

This computes `offset = start_date − dates_based_on` and adds that many days to
every `assigned` and `due` field in `_lab/*.md`, `_pa/*.md`, and `_lp/*.md`.
After applying, it updates `dates_based_on` in `_config.yml` to equal `start_date`,
so re-running the script is safe (offset becomes zero, nothing changes).

> **Note:** The offset between back-to-back quarters is usually a multiple of 7 days,
> preserving day-of-week alignment. Verify the shifted dates still fall on sensible
> days (e.g., labs due on Fridays) before publishing.

### 4. Check the lecture count

The number of lecture slots varies by quarter depending on when holidays fall:

```
lecture slots = (num_weeks + extra_exam_week) × lectures_per_week − holidays_on_lecture_days
```

For example, S26 (10 weeks, MW, 1 holiday) → **19 slots**; W26 (10 weeks, MW, 2 holidays) → **18 slots**.

If the slot count changed from the previous quarter:
- **More slots than lecture files:** add a new lecture file for the extra slot
  (e.g., if a "Quiz" or "Final Review" now gets its own day)
- **Fewer slots than lecture files:** merge or remove a lecture file

The lecture files use `sequence: N` (auto-computes the date) — just keep the
sequence numbers contiguous starting at 1. Holiday placeholder files use
`lecture_date: YYYY-MM-DD` instead of a sequence number.

### 5. Update content

- `lect18.md` / `lect19.md` — update quiz/final-review exam logistics (date, location, seating chart links)
- `_config.yml` `cal_dates` — update important dates (drop deadline, instruction end, final exam, quarter end)
- Any assignment files that reference quarter-specific dates, repos, or Gradescope links

### 6. Test locally

```bash
./jekyll.sh   # starts Jekyll at http://localhost:4000/<baseurl>
```

Check:
- Lecture table shows correct dates and no gaps
- Holiday rows appear in the right place
- Assignment assigned/due dates look reasonable
- All internal links resolve

---

## How lecture date computation works

Regular lecture files (`lect01.md` … `lect19.md`) use:
```yaml
sequence: N
```
The `_includes/compute_lecture_date.liquid` include walks the calendar from
`start_date`, counts Mon/Wed slots, skips holidays, and returns the Nth date.

Holiday placeholder files (`lect16a.md`, etc.) use:
```yaml
lecture_date: 2026-05-25
```
They cannot use `sequence` because the include skips holidays and would never
return the holiday date itself.

---

## Example: W26 → S26

| Field | W26 | S26 |
|-------|-----|-----|
| `start_date` | 2026-01-05 | 2026-03-30 |
| `holidays` | MLK Day (1/19), Presidents Day (2/16) | Memorial Day (5/25) |
| Lecture slots | 18 | 19 |
| Date offset | — | +84 days (12 weeks) |
