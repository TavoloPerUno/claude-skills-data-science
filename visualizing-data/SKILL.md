---
name: visualizing-data
description: Create Economist-style data visualizations with matplotlib. Argumentative titles, limited palettes, direct labels, slideshow-ready sizing. Use when building any chart, plot or figure.
argument-hint: "[chart type or description]"
---

# Visualizing Data

Build publication-quality charts that argue, not decorate. Every principle here comes from The Economist's visual style, Sarah Leo's "Mistakes, we've drawn a few" (2019), and Elizabeth Rees's color philosophy -- tested and refined through dozens of slides for executive audiences.

## 1. Philosophy

These five rules govern every chart decision:

1. **Clarity over cleverness.** Every chart communicates one clear message. If it needs explaining, redesign it.
2. **The title is the argument.** Active. Interpretive: "Rich countries are growing faster than expected" -- not "GDP by Country." The headline is the thesis; the chart is the evidence.
3. **One chart, one message.** If you're showing two things, split into two charts. Use small multiples, not overlaid complexity.
4. **Start with the data, not the chart type.** What message must the reader take away? That dictates the format.
5. **The 5-second test.** A naive reader's first takeaway should match your intended message. If it doesn't, simplify.

### When not to chart

Sometimes the best chart is no chart. Skip the visualization when:
- The data is better as a clean table or a single number in large type
- There isn't enough data to justify a chart (two bars? just write the numbers)
- The shape of the data isn't visually interesting
- You'd have to squeeze too much in -- simplify the question first

Don't squeeze -- simplify. Pull out only what shows the message clearest. Redesign for the format, don't just shrink the original.

## 2. Choosing the Right Chart

| Message type | Chart | Notes |
|---|---|---|
| Comparison across categories | Bar (vertical or horizontal) | Sorted by value for rankings |
| Trend over time | Line | Direct-label series at end of line |
| Old vs new across groups | Dumbbell | Hollow = old, filled = new |
| Composition / part-of-whole | Stacked bar with inline numbers | Never pie charts |
| Relationship between variables | Scatter | Size by volume, color by group |
| Two-category comparison | Thermometer | Saves space, easy to see difference |
| Same metric, many scenarios | Small multiples | Shared axes, one per panel |
| Huge data ranges | Bubble | Label values -- eye can't compare circle sizes |
| Geography matters | Map | Only when location is the insight |
| Proportions | Bar | Pie charts almost always wrong |

Dual y-axes: **never**. Two scales imply a relationship that changes if you rescale either axis. Use small multiples or index both series instead.

## 3. Setup

```python
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
import matplotlib.patches as mp
import numpy as np
from pathlib import Path

matplotlib.use('Agg')

# Load Roboto
for ttf in (Path.home() / '.fonts').glob('Roboto*.ttf'):
    fm.fontManager.addfont(str(ttf))
plt.rcParams['font.family'] = 'Roboto'
```

## 4. Color

### Default palette (Reasonable Colors)

Defaults from [Reasonable Colors](https://reasonable.work/colors/) -- an open-source (MIT) palette with built-in accessibility guarantees. Any two shades 3 apart within a hue guarantee WCAG AA body text contrast (4.5:1).

Override with your brand palette via CLAUDE.md or memory. The role names stay the same -- just redefine the hex values.

```python
_BG        = '#e8f2ff'   # Azure-1 - light blue chart background
_PRIMARY   = '#222222'   # Gray-6 - titles, labels, body text
_WHITE     = '#FFFFFF'   # gridlines, zero line
_ACCENT    = '#006dca'   # Blue-4 - highlight / focus series
_SECONDARY = '#c6e0ff'   # Azure-2 - comparison / baseline series
_MUTED     = '#6f6f6f'   # Gray-4 - source text, axis labels
_MUTED_L   = '#8b8b8b'   # Gray-3 - muted bar labels, tick labels
_POSITIVE  = '#008217'   # Green-4 - positive change
_NEGATIVE  = '#e0002b'   # Red-4 - negative change
_HL_YELLOW = '#fff9e5'   # Yellow-1 - label highlight background
```

### Gray-out tones

Derived from the palette for muting non-focus series:

```python
# Focus series highlighted, rest muted
highlight_colors = [_ACCENT] + ['#b8b8b8'] * 4   # Blue-4 focus, Gray-3 muted
secondary_colors = [_SECONDARY] + ['#e2e2e2'] * 4  # Azure-2 focus, Gray-2 muted
```

### Label colors for slideshow readability

Labels must be dark enough to read when projected. Reasonable Colors' Gray shades guarantee contrast:

```python
color_highlight    = _ACCENT     # Blue-4 - focus series labels
color_primary_tl   = '#3e3e3e'   # Gray-5 - primary non-focus (darkest)
color_secondary    = '#6f6f6f'   # Gray-4 - secondary non-focus
color_baseline     = '#8b8b8b'   # Gray-3 - baseline series
# Never use lighter than Gray-3 for labels that must read in slideshow
```

### Rules

- **Limited palette.** Navy (primary) + one accent (blue). Maximum 6 colors in any single chart. Beyond that, readers struggle to distinguish.
- **Gray-out technique.** Highlight 1-2 series in a strong color; gray everything else. The eye goes to color first.
- **Color carries meaning, not decoration.** If two things share a color, the reader assumes they're related. Red means bad -- don't fight convention.
- Vary opacity within a palette to distinguish related categories without implying they're unrelated.
- **Exception:** well-known categories with strong color associations (eg political parties) get their recognized colors.
- Charts must work in black and white and be accessible for color-blind readers.

## 5. Chart Anatomy

Every chart follows this visual hierarchy -- a clear reading order that guides the eye from argument to evidence:

1. **Subtitle** (top-left) -- metric, units, scope
2. **Inline legend** (top-right) -- colored squares + labels (not a legend box)
3. **Chart area** -- light blue background, white gridlines
4. **Annotations** -- callouts at point of interest
5. **Source** (bottom-left) -- italic, small, gray

### Skeleton code

```python
fig = plt.figure(figsize=(w, h), facecolor=_BG)

# 1. Subtitle
fig.text(0.06, 0.95, 'Median x above baseline, by group',
         fontsize=9.5, color=_PRIMARY, va='top', ha='left')

# 2. Inline legend (colored squares + labels, top-right)
sq_x = 0.86; sq_w = 0.018; sq_h = 0.018
fig.patches.append(mp.FancyBboxPatch(
    (sq_x, 0.948), sq_w, sq_h, boxstyle="square,pad=0",
    facecolor=_ACCENT, edgecolor='none', transform=fig.transFigure))
fig.text(sq_x + 0.018, 0.953, 'Series A',
         fontsize=8.5, color=_MUTED, va='center')
# Add more squares for additional series at sq_x - 0.12 offsets

# 3. Axes
ax = fig.add_axes([0.06, 0.10, 0.90, 0.78])
ax.grid(axis='y', color=_WHITE, lw=1.0, zorder=1)
ax.set_facecolor(_BG)
ax.axhline(0, color=_WHITE, lw=1.0, zorder=2)
ax.set_axisbelow(True)
for s in ax.spines.values():
    s.set_visible(False)

# 5. Source
ax.text(0.0, -0.06, 'Source: dataset description.',
        transform=ax.transAxes, fontsize=6, color=_MUTED, style='italic')

# Save
plt.savefig(path, dpi=220, bbox_inches='tight', pad_inches=0.05,
            facecolor=_BG)
plt.close('all')
```

## 6. Labels and Slideshow Readability

Charts render at high DPI but shrink into PPT slides. Labels that look fine at 100% zoom become unreadable in slideshow mode. Compensate:

### Yellow highlight boxes

Put a subtle highlight behind every value label so it reads against any background:

```python
_HL_BOX = dict(boxstyle='round,pad=0.15', facecolor=_HL_YELLOW,
               edgecolor='none', alpha=0.85)
ax.text(x, y, f'{val:+.0f}%', fontsize=12, fontweight='bold',
        color=_ACCENT, bbox=_HL_BOX)
```

### Font sizes -- bigger than you think

| Element | Size |
|---|---|
| Focus / highlight value labels | 12pt bold |
| Secondary value labels | 10pt bold |
| X-axis category labels | 10-11pt |
| Y-axis tick labels | 8pt |
| Subtitle | 9.5-10pt |
| Source footnote | 6pt italic |

All value labels bold -- not just the focus series.

### Label colors -- darker than you think

Use the slideshow-tested label colors from section 4 (`color_highlight`, `color_primary_tl`, `color_secondary`, `color_baseline`). The key rule: never use `_MUTED_L` for labels that need to be read when projected.

### Inside vs outside bars

- **Tall bars:** white text inside, centered vertically, no highlight box
- **Short bars** (< ~12% of y-range): colored text outside with highlight box, nudged above/below the bar top

### Direct labels, not legends

Label series directly on the chart (at end of line, next to bar). Use legends only when direct labeling is physically impractical.

Annotate the "so what" at the point of interest -- the spike, the crossover, the outlier. Don't annotate every data point; annotate only the insight.

## 7. Change Boxes (Big Mac Style)

A column of small boxes showing before-and-after differences, positioned alongside the main chart:

```python
_pp_box = dict(boxstyle='round,pad=0.4', facecolor=_HL_YELLOW,
               edgecolor='none', alpha=0.85)
clr = _POSITIVE if diff > 0 else _NEGATIVE if diff < 0 else _MUTED
ax.text(BOX_CX, y[i], f'{diff:+d}', ha='center', va='center',
        fontsize=10, color=clr, fontweight='bold', bbox=_pp_box)

# Header
ax.text(BOX_CX, -0.7, 'Change\n(pp)', ha='center', va='center',
        fontsize=7.5, color=_PRIMARY, fontweight='bold', linespacing=1.2)
```

For dumbbell charts, use category-colored tinted fills:

```python
# Tinted background matching group color
GROUP_FILLS = {'Group A': '#E8EEFF', 'Group B': '#E4F2E0', 'Group C': '#FFF0D0'}
rect = mp.FancyBboxPatch(
    (BOX_L, ypos - BOX_H / 2), BOX_W, BOX_H,
    boxstyle='square,pad=0', facecolor=GROUP_FILLS[group],
    edgecolor=_COLORS[group], linewidth=0.6, alpha=alpha)
```

## 8. Confidence Intervals

Show uncertainty for any estimate or projection:

```python
ax.fill_between(x, y_lo, y_hi, color=_ACCENT, alpha=0.12)
ax.plot(x, y_mid, color=_ACCENT, lw=3)
```

Annotate key points with value and a range:

```python
ax.annotate(f'{val:.1f} weeks\n({lo:.1f}-{hi:.1f})',
            (x_pt, y_pt), textcoords='offset points', xytext=(15, 15),
            fontsize=10, color=_ACCENT, fontweight='bold', linespacing=1.3,
            arrowprops=dict(arrowstyle='->', color=_ACCENT, lw=1.5),
            bbox=_HL_BOX)
```

## 9. Scales and Axes

- **Bar charts:** y-axis starts at zero. Always. A bar from 50 to 52 looks like a 100% increase if the axis starts at 49.
- **Line charts** can truncate the y-axis (readers follow slope), but label the break clearly.
- **Log scales** for data spanning orders of magnitude -- label clearly.
- **Inverted y-axis** (eg "fewer is better") needs prominent annotation so readers don't misread direction.
- **Bubble/area charts:** scale by area (use sqrt of value for radius). A circle with 2x radius has 4x area.

## 10. Data Integrity

- Cite sources on every chart
- Don't cherry-pick time ranges to make a point
- Correlation does not equal causation -- chart design should not imply it
- Show uncertainty for estimates; don't present point estimates as certainties

## 11. Writing Style for Chart Text

Rooted in Orwell's six rules from "Politics and the English Language" (1946), with a house style shaped by years of reading The Economist's data journalism.

### Orwell's rules

1. Never use a cliche metaphor or figure of speech.
2. Never use a long word where a short one will do.
3. If it is possible to cut a word, cut it.
4. Never use the passive where you can use the active.
5. Never use jargon if an everyday English equivalent exists.
6. Break any rule sooner than say anything barbarous.

### In practice

- **Short words:** "get" not "permit", "use" not "utilize", "about" not "approximately", "show" not "demonstrate", "buy" not "purchase", "begin" not "commence", "enough" not "sufficient", "to" not "in order to"
- **Active voice:** "Revenue grew 12%" not "A 12% increase in revenue was observed"
- **No filler:** delete very, really, extremely, basically, literally, quite, totally, virtually
- **No em dashes:** they signal AI-generated text. Use commas, colons, semicolons or periods instead
- **Precise verbs eliminate modifiers:** "strut" not "walk confidently"
- **American English:** optimize, color, analyze, center, defense
- **Numbers:** spell out one to nine; numerals for 10+; always numerals for percentages, money, ages, measurements
- **Round numbers in headlines:** "about 4m" not "3,712,483"
- **Plain-language labels** -- no jargon or raw variable names on axes
- **No exclamation marks** in serious writing
- **Test against casual speech:** if you wouldn't say a word in conversation, replace it

## 12. Annotation Columns and Companion Elements

When a chart has a companion column (change boxes, CIs, ranks) beside the main plot area:

- **Hug the data.** Position the column relative to `data_max`, not as a fixed figure fraction. Wasted space between the last data point and the annotation column weakens the visual connection.
- **Use data coordinates for row-aligned elements.** When boxes must align vertically with chart rows, use `ax.text(x, y[i])` in data space, not `fig.text()` in figure fractions. Figure fractions drift when axes change.
- **Column headers align with chart headers.** A "Gain (pp)" header should sit at the same y-level as the chart subtitle, not float above the plot.
- **Grid lines stop where the data stops.** Grid lines past the data range create dead space. Derive the last tick from `data_max`, not a fixed ceiling.
- **Dynamic axis limits.** `last_tick = int(data_max // 5) * 5` then `xlim = last_tick + small_margin` keeps the chart tight.

```python
# Tight companion column positioning
data_max = max(values)
last_tick = int(data_max // 5) * 5             # eg 21.2 -> 20
BOX_X = data_max + 2.5                         # boxes just past data
XLIM = BOX_X + 2.5                             # minimal margin
ax.set_xticks(range(0, last_tick + 1, 5))      # no grid past data
ax.set_xlim(-margin, XLIM)

# Boxes in data coords (aligned with rows automatically)
ax.text(BOX_X, y[i], f'{diff:+.0f}', ha='center', va='center', ...)
```

## 13. Production and Polish

- **Consistency signals rigor.** Fonts, colors, spacing -- the same across every chart in a deck.
- **Generous whitespace.** Fewer elements, each earning its place.
- **Size proportional to informational density.** A simple line chart doesn't need a 22" wide figure.
- **Default chart styles signal laziness.** Always customize fonts, colors and spacing -- never ship matplotlib/Excel defaults.
- **Every chart needs a clear reading order.** Eye enters at title, moves to annotation, then data.
- **Connecting lines need visual weight.** On light backgrounds, muted colors disappear. Use darker colors with controlled alpha (eg `color=_PRIMARY, alpha=0.3`) instead of inherently light colors.
- **Uniform grid line thickness.** Mixing widths creates visual noise. Pick one weight (eg `lw=1.2`) and use it for all grid lines.

## 14. Common Mistakes (Sarah Leo, The Economist, 2019)

Three categories, from fixable to fundamental:

### Misleading -- charts that distort the data

- **Truncated y-axis on bar charts.** Bars encode magnitude by area. A bar from 50 to 52 looks like a 100% increase if the axis starts at 49. Line charts can truncate because readers follow the slope.
- **Dual y-axes.** Two scales on the same chart imply a relationship that may not exist. The apparent correlation changes if you rescale either axis. Use small multiples or index both series instead.
- **Inverted y-axis without clear labeling.** Flipping the axis (eg "fewer is better") without prominent annotation misleads readers into thinking up = good.
- **Area/bubble charts not scaled by area.** A circle with 2x radius has 4x area. Always scale by area (sqrt of value for radius), never by radius.

### Confusing -- charts that are hard to read

- **Too many colors or series.** More than 5-6 series becomes unreadable. Use the gray-out technique: highlight 1-2 series, gray the rest.
- **Unnecessary 3D effects.** Adds no information, distorts proportions. Never.
- **Pie charts for more than 2-3 categories.** Humans are bad at comparing angles. Use bars instead.
- **Overloaded annotations.** Too many labels compete for attention. Annotate only the insight, not every data point.
- **Rainbow color palettes.** Hard to read, not colorblind-safe. Use sequential or diverging palettes with 2-3 hues.

### Ugly -- charts that just don't look right

- **Gridlines that compete with data.** Gridlines should be barely visible (white on light blue, or light gray). Data should be the darkest element.
- **Default chart styles.** Excel/matplotlib defaults signal laziness. Always customize fonts, colors, spacing.
- **Poor font choices.** Use a clean sans-serif (Roboto, Helvetica). Stick to one font family per chart.
- **Cluttered legends.** Place labels directly on the data when possible. Use legends only when direct labeling is impractical.

## 15. Checklist

Run through before finalizing any chart:

1. Does the y-axis start at zero? (mandatory for bar charts)
2. Are there dual y-axes? (remove -- use small multiples)
3. Is the color palette limited? (max 6 colors, highlight focus series)
4. Are gridlines subtle? (white on light blue, lighter than data)
5. Is the title an insight, not a description?
6. Are labels direct? (on the chart, not in a separate legend)
7. Is the chart type appropriate for the message?
8. Does the 5-second test pass?
9. No 3D, no gradients, no decorative elements?
10. Are font sizes large enough for slideshow mode?
11. Are all value labels bold with highlight boxes?
12. Is there a source footnote?

## Chart Type Code Patterns

See [charts.md](charts.md) for detailed matplotlib code for each chart type.
