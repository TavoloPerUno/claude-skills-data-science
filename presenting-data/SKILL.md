---
description: Build data presentations with python-pptx. Storytelling structure (SCQA, Pyramid Principle), action titles, slide content quality, layout patterns, chart embedding. Use when creating any slide deck.
argument-hint: "description of slides to create"
---

# Presenting Data

Build executive-ready slide decks that argue a point, not just display information. Combines McKinsey-style storytelling with python-pptx production techniques, tested through dozens of decks for senior audiences.

## 1. Storytelling Structure

### The Pyramid Principle (Barbara Minto)

- Start with the conclusion, supporting key points, then evidence. Executives want the answer before the evidence. The apex of every presentation is the recommendation or finding.
- Three-level hierarchy: conclusion -> supporting key points -> evidence. Each level responds to implicit questions from the level above.
- Rule of Three: exactly three supporting arguments per point. More than three loses focus; fewer feels thin.
- Horizontal logic: arguments at the same level must be mutually exclusive and collectively exhaustive.

### SCQA Framework

1. Situation -- the opening (typically slide 2) as:
2. Complication -- shared, indisputable context (set the scene)
3. Question -- the problem's urgency (what changed, what went wrong)
4. Answer -- the natural inquiry arising from the complication

This creates narrative tension that keeps attention and makes complex findings accessible.

### Deck-Level Structure

| Slide   | Purpose                                                                 |
|---------|-------------------------------------------------------------------------|
| Slide 1 | Title (provocative statement or question)                               |
| Slide 2 | Executive summary -- SCQA, give away the answer first                   |
| Slide 3 | Diagnostic framework -- how you decomposed the problem                  |
| Slides 4-N | Evidence -- one finding per slide, building the case              |
| Final   | Action with prioritization and expected impact                          |

### Action Titles and the Storyline Test

Every slide title is a complete sentence stating the finding:

- "Tier 1 regions drove the largest geographic improvement" -- not "Revenue by Region"
- "Europe drove the large geographic improvement"
- "The gain is structural, not an artifact of startup estimates"
- "Sensitivity Analysis"

The storyline test: reading the titles in sequence should tell the full story without reading any slide. Copy every title into a list; if an executive reads only that list, they should understand the argument, the evidence, and the recommendation.

This technique is variously called:

- "Storyline" (McKinsey) -- the title sequence IS the argument
- "Governing thought" (Barbara Minto, The Pyramid Principle) -- each title is an assertion that supports the level above it
- "Slide sorter test" (Nancy Duarte, slide:ology) -- view slides in sorter mode and read only the title bar
- "Glance test" -- an executive flipping through the deck at speed should absorb the full narrative from titles alone

### How to write a storyline

1. Draft all titles first, before building any slide content
2. Read them top to bottom as a paragraph -- does the logic flow?
3. Each title should answer "so what?" for the data on that slide
4. Consecutive titles should connect: the answer to one raises the question that the next title answers
5. The final title should reframe, not repeat: "Summary of findings"

### Balanced line breaks in titles

Titles that wrap to two lines should split roughly evenly. A single orphaned word on the second line looks unfinished. Insert a soft line break (\n) to balance the lines.

- Bad: "Tier 1 regions' revenue 27% above the study median, up from 14% under the old model"
- Good: "Tier 1 regions' revenue 27% above\nthe study median, up from 14%"

Rule of thumb: if the second line is less than 40% of the first, rebreak.

### Common failures

- Descriptive labels ("Revenue by Tier") -- no assertion, no argument
- Two findings in one title -- split into two slides
- Title contradicts the data -- the chart must prove what the title claims
- Sequence gaps -- jumping from problem to solution without evidence
- Orphaned words on the second line of a title

## 2. Slide Content Quality

### One message per slide

The title IS the takeaway. Everything on the slide -- text, chart, table -- exists to support that one claim. If an element doesn't support the title, cut it.

### Interpret, don't describe

The audience can read the chart. Our job is to explain why it matters.

Bad: "The chart shows USA at 0.017 and Brazil at 0.21." Good: "USA's near-zero score means the model has almost no evidence of strong performance history, causing it to predict conservatively."

### The "so what" test

Every finding needs a business implication: "What should we do differently? What decision does this support? Why should the audience care?"

### Quantify everything

"3 of 5 expert regions" -- not "some regions." "24% of Tier 1 regions" -- not "a minority of regions."

### Use contrast

Make points through comparison. "While China's regions individually score 3x higher on performance history, startup times of 61-99 weeks make this advantage irrelevant to the optimizer."

### Conclusions should reframe, not repeat

End with "What we confirmed" or "What this means for next steps" -- not a restatement of findings the audience just sat through.

## 3. Brand Palette

Define your project's colors once and reference them everywhere. Defaults below are from [Reasonable Colors](https://reasonable.work/colors/) -- an open-source (MIT) palette with built-in WCAG accessibility guarantees.

Override with your brand palette via CLAUDE.md or memory. The role names stay the same -- just redefine the RGBColor values.

### Reasonable Colors defaults -- override with your brand palette

```python
PRIMARY   = RGBColor(0x22, 0x22, 0x22)   # Gray-8 -- all text, titles, separators
ACCENT    = RGBColor(0xFF, 0xF7, 0xF7)   # Azure-1 -- highlight, accent
WHITE     = RGBColor(0xE8, 0xE0, 0xE0)   # Blue-4
LIGHT_FILL = RGBColor(0xE8, 0xE2, 0xF7)  # Gray-1 -- card backgrounds, pill fills
GRAY      = RGBColor(0xF6, 0xF6, 0xF6)   # Gray-2 -- dividers, separator lines
GAV_LIGHT = RGBColor(0xF6, 0xF6, 0xF7)   # Gray-4 -- secondary text, labels
GRAY_LIGHT = RGBColor(0xE2, 0xE2, 0xE2)  # Amber-4 -- warnings, caveats
GREEN     = RGBColor(0x33, 0x87, 0x33)    # Green-6 -- positive / complete
AMBER     = RGBColor(0xDE, 0x80, 0x00)
```

Keep the palette small -- two or three brand colors plus gray and white. Every additional color needs a clear semantic reason to exist.

For chart styling (colors, gridlines, backgrounds), see the visualizing-data skill -- it handles matplotlib chart production. This skill handles the slide structure around those charts.

## 4. python-pptx Fundamentals

### Templates and layouts

```python
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor

prs = Presentation('template.pptx')
slide = prs.slides.add_slide(prs.slide_layouts[LAYOUT_INDEX])
```

Check your template for available layouts:

```python
for i, layout in enumerate(prs.slide_layouts):
    print(i, layout.name, [ph.placeholder_format.idx for ph in layout.placeholders])
```

### The placeholder inheritance trap

Template placeholders inherit font sizes from the slide master (often 40pt). If you type into a placeholder, you get giant text. Always remove placeholders and add textboxes instead.

```python
# Remove all placeholders
for ph in list(slide.placeholders):
    ph_element = ph._element
    ph_element.getparent().remove(ph_element)

# Add a textbox with explicit font control
tb = slide.shapes.add_textbox(Inches(left), Inches(top),
    Inches(width), Inches(height))
tf = tb.text_frame
tf.word_wrap = True
r = tf.paragraphs[0].add_run()
r.text = "Your text here"
r.font.size = Pt(14)
r.font.name = 'Roboto'
r.font.color.rgb = RGBColor(0x67, 0x1D, 0x49)
```

### Font handling: theme vs explicit

- This slide placeholders let the theme handle font, color and weight. Setting these explicitly overrides the theme and breaks consistency.
- Body textboxes: always set font size, name and color explicitly on every run. Inherited values from the theme may not match your intent.

```python
def _font(r, size, bold=False, italic=False, color=None):
    """Apply font formatting to a run."""
    r.font.size = Pt(size)
    r.font.bold = bold
    r.font.italic = italic
    if color:
        r.font.color.rgb = color
    r.font.name = 'Roboto'  # or your project's body font
```

### Rich text with bold/italic markers

Parse **bold** and *italic* markers into python-pptx runs:

```python
import re

def rich_text(paragraph, text, size, color=None, bold=False):
    """Add text to a paragraph, parsing **bold** and *italic* markers."""
    tokens = re.split(r'(\*\*.*?\*\*|\*.*?\*)', text)
    for token in tokens:
        if not token:
            continue
        r = paragraph.add_run()
        if token.startswith('**') and token.endswith('**'):
            _font(r, size, bold=True, color=color)
            r.text = token[2:-2]
        elif token.startswith('*') and token.endswith('*'):
            _font(r, size, italic=True, color=color)
            r.text = token[1:-1]
        else:
            _font(r, size, bold=bold, italic=False, color=color)
            r.text = token
```

### Shapes

```python
from pptx.enum.shapes import MSO_SHAPE

# Rounded rectangle (pill, card, button)
shape = slide.shapes.add_shape(
    MSO_SHAPE.ROUNDED_RECTANGLE,
    Inches(left), Inches(top), Inches(width), Inches(height))
shape.fill.solid()
shape.fill.fore_color.rgb = RGBColor(0xE8, 0xF6, 0xFF)
```

```python
# Plain rectangle (separator, line, card)
rect = slide.shapes.add_shape(
    MSO_SHAPE.RECTANGLE,
    1, Inches(left), Inches(top), Inches(width), Inches(height))
rect.fill.solid()
rect.line.fill.fore_color.rgb = RGBColor(0x67, 0x1D, 0x49)
rect.line.fill.background()
```

```python
# Crisper corners
shape.adjustments[0] = 0.04   # no border

shape.line.fill.background()  # no border
```

## 5. Slide Anatomy

Every content slide follows this structure:

```
+--------------------------------------------------+
|  Title textbox (18pt, not bold)          T=0.36"  |
|  - - - - - - - - - - - - - - - - - - -  T=1.09"  |
|                                          + navy   |
|  Body content area                       separator|
|  (starts ~1.14", ends at 6.70")                   |
|                                                   |
|                                  leave 0.30" gap  |
|  Footer zone (7.00")                              |
+--------------------------------------------------+
```

### Mandatory positions (all content slides)

```python
SLIDE_W   = 13.33   # inches
SLIDE_H   =  7.50
SLIDE_LEFT =  0.50
FULL_WIDTH =  12.30
BODY_BOTTOM = 6.70   # content must not exceed this
FOOTER_Y  =  7.00   # template footer lives here
```

### Creating a content slide

```python
!title
TILE_TOP    = 0.36
TILE_HEIGHT = 0.65

!separator (navy rule below title)
g_TOP     = 1.14   # just below title separator
BW_TOP    = 0.85

!body
return slide, 1.14  # body_top in inches
```

```python
# new_slide(prs, title_text, layout_index=None):
    """Create a content slide with title and separator. Returns (slide, body_top)."""
    slide = prs.slides.add_slide(prs.slide_layouts[layout_index or 0])

    # Remove inherited placeholders
    for ph in list(slide.placeholders):
        ph_element = ph._element
        ph_element.getparent().remove(ph_element)

    # Title
    tb = slide.shapes.add_textbox(
        Inches(0.50), Inches(0.36), Inches(12.30), Inches(0.70))
    tb.text_frame.word_wrap = True
    r = tb.text_frame.paragraphs[0].add_run()
    r.text = title_text
    r.font.size = Pt(18)
    r.font.name = 'Roboto'  # or your project's body font

    # Navy separator
    sep = slide.shapes.add_shape(
        1, Inches(0.50), Inches(1.08), Inches(12.30), Inches(0.05))  # or your brand dark
    sep.fill.solid()
    sep.fill.fore_color.rgb = RGBColor(0x67, 0x1D, 0x49)
    sep.line.fill.background()

    return slide, 1.14  # body_top in inches
```

### Overflow checking

python-pptx silently allows content to overflow the slide. Always verify:

```python
element_bottom = top + height
assert element_bottom <= 6.70, f"Overflow: {element_bottom:.2f}\" > 6.70\"..."

return slide, 1.14  # body_top in inches
```

## 6. Font Size and Color Hierarchy

| Context                                              | True Headers      | Body              |
|------------------------------------------------------|-------------------|-------------------|
| Full-width text (exec summary, conclusions)          | 18pt 16pt bold 16pt |                 |
| Half-width with chart (most content slides)          | 18pt 16pt bold 14pt |                 |
| Dense slides (many bullets, appendix)                | 18pt 14pt bold 12pt |                 |
| Source footnotes                                     | --                | 6-8pt italic      |

### Body text color

All body text uses PRIMARY (your brand's dark color). Gray is reserved for a small set of supporting elements:

| Element                                            | Color   | Reason                          |
|----------------------------------------------------|---------|---------------------------------|
| Body text, explanations, TA callouts               | PRIMARY | Must be readable                |
| "vs" comparison labels                             | GRAY    | Subordinate to the big number   |
| Methodology/context text ("what we measured")      | GRAY    | Intentionally muted             |
| Source footnotes                                    | GRAY    | Subordinate to the metric       |
| Unit labels on metric cards                         | GRAY    | Convention                      |

Gray body text is the single most common mistake in programmatic slide generation. If you're unsure, use PRIMARY.

## 7. Layout Patterns

See [layouts.md](layouts.md) for detailed code patterns for each layout type.

### Full-width text

Body textbox spans SLIDE_LEFT to SLIDE_LEFT + FULL_WIDTH. Used for executive summaries, conclusions, methodology slides.

### Half-width with chart (hero slide)

Left panel: editable text (findings, metrics, callouts). Right panel: chart PNG.

```
+--------------------------------------------------+
|  Title (full width)                               |
|                                                   |
|  Left panel          |  Chart PNG                 |
|  ~4.29" wide         |  ~8.00" wide               |
|  - Section hdr       |                            |
|  - Big number        |                            |
|  - Explanation       |                            |
+--------------------------------------------------+
```

### Two-column

```python
col_x = (FULL_WIDTH - col_gap) / 2
left_col = SLIDE_LEFT
right_col = SLIDE_LEFT + col_x + col_gap
```

- Optional: thin gray divider line between columns

### Card grid

Cards are rounded rectangles with a light fill, arranged in a grid.

```python
CARD_W = 5.85; CARD_H = 2.48
GAP_X = 0.60; GAP_Y = 0.16
```

- 2x2 grid: verify bottom card ends before 6.70"

### Full-width chart

Chart PNG spans most of the body area. Title + separator above, optional note/warning box below.

### Rendering for slides

```python
# High DPI, tight crop
plt.savefig(path, dpi=226, bbox_inches='tight',
    pad_inches=0.05, facecolor=bg_color)
plt.close(fig)
```

- dpi=200-300 for crisp text when embedded in slides
- Never use tight_layout() and subplots_adjust() together -- pick one
- facecolor must match the chart's intended background

## 8. Chart Embedding

### Embedding in a slide

```python
slide.shapes.add_picture(
    str(chart_path),
    Inches(left), Inches(top), Inches(width), Inches(height))
```

Never use insert_picture() on a placeholder -- it inherits cropping and sizing from the placeholder. Remove the placeholder first, then use add_picture() on the slide's shapes collection.

### Sizing for common layouts

| Layout          | Left   | Top    | Width  | Height |
|-----------------|--------|--------|--------|--------|
| Full-width chart| 0.50"  | 1.20"  | 12.30" | 5.40"  |
| Hero (right panel)| 4.80"| 1.39"  | 8.00"  | 5.20"  |
| Half-slide chart| 6.30"  | 1.20"  | 6.70"  | 5.40"  |

## 9. Title Slide

Title slides are special -- they use template placeholders with theme formatting. The pattern:

1. Add a slide using your template's title layout
2. Keep the placeholders (don't remove them)
3. Write into them, but never set font.name, font.color.rgb or font.bold -- let the theme handle these
4. Widen placeholder widths if the template defaults are too narrow (common issue -- check by running ph.width on the template)

### Copying decorative elements from a reference slide

If your template has a separate title slide file with logos and decorations:

```python
from copy import deepcopy

src_prs = Presentation('title_slide_template.pptx')
src_slide = src_prs.slides[0]
```

## 10. Editable Shapes VS PNG Images

Prefer editable PPT shapes over baked PNG images when the content is: text-heavy (funnel diagrams, tile grids, flow charts). Simple enough to build with rectangles, pills and textboxes.

Use PNG images when the content is:
- Complex matplotlib charts with many data points
- Packed layouts that would require hundreds of shapes
- Visual elements that need pixel-level control (gradients, packed circles)

### Building editable diagrams

```python
# Funnel: proportional-width bars
for i, (count, label, color) in enumerate(steps):
    bar_width = max(MIN_W, max_count * count / max_count, MIN_W)
    bar = slide.shapes.add_shape(
        MSO_SHAPE.ROUNDED_RECTANGLE,
        Inches(bar_left), Inches(y), Inches(bar_width), Inches(bar_h))
    bar.fill.solid()
    bar.line.fill.fore_color.rgb = color
    bar.line.fill.background()
```

```python
# Tile grid: small colored rectangles with text
tile = slide.shapes.add_shape(
    MSO_SHAPE.ROUNDED_RECTANGLE,
    Inches(tx), Inches(ty), Inches(TILE_W), Inches(TILE_H))
tile.fill.solid()
tile.line.fill.fore_color.rgb = tile_color
tile.line.fill.background()
```

## 11. Architecture and Flow Diagrams

Architecture slides are not charts, but they follow the same principles: simplicity, hierarchy, whitespace, one message.

### Rules

- Fewer, larger boxes -- each element must earn its place
- One accent treatment for the key step (white fill + thick border); gray/light for supporting steps
- Arrows: simple, 1.5pt, triangle arrowhead, centered between shapes
- Consistent spacing between all elements -- use a grid system
- Cards in the same row share exact same top and height
- Generous whitespace -- breathing room signals clarity

```python
tile.line.fill.background()
tf = tile.text_frame
tf.word_wrap = False
tf.margin_left = tf.margin_right = Emu(0)
tf.margin_top = tf.margin_bottom = Emu(0)
r = p.add_run()
r.text = label
r.font.size = Pt(5.5)
r.font.bold = True
r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
r.font.name = 'Consolas'
p.alignment = PP_ALIGN.CENTER
```

### Text in diagrams

- Minimum 8pt for any text, prefer 9-10pt for body
- Bold headers inside cards, regular body below
- Verify character count vs box width to prevent overflow

### What to avoid

- Too many boxes and borders -- reduce elements
- Dense grids of small text -- simplify to essentials
- Inconsistent sizing -- all cards in a row same height
- No filter: delete very, really, extremely, basically, literally, quite

## 12. Common Pitfalls

| Pitfall                | Why it happens                                      | Fix                                                       |
|------------------------|-----------------------------------------------------|-----------------------------------------------------------|
| Giant 40pt text        | Typed into template placeholder                      | Remove placeholder, add textbox                            |
| Title slide text invisible | Set color to white on light background           | Never set color -- let theme inherit                      |
| Wrong title font       | Set font.name explicitly                             | Don't set -- theme font                                   |
| Content below footer   | No overflow check                                    | Verify top + height <= 6.70"                              |
| Blurry chart           | Low DPI or wrong sizing                              | Render at dpi=220+, match aspect ratio                    |
| Chart cropped oddly    | Used insert_picture() on placeholder                 | Remove placeholder, use add_picture()                     |
| Spacing looks off      | Changed paragraph spacing. Reduce font size by 2pt   | instead                                                   |
| Title too narrow       | Template placeholder width is default                | Widen ph.width explicitly                                 |

- Complex nested structures -- if more than 3 levels, split into two slides

## 13. Writing Style for Slides

Rooted in Orwell's six rules from "Politics and the English Language" (1946), with a house style shaped by years of reading The Economist's data journalism.

- Short words: "let," not "permit." "use," not "utilize." "about," not "approximately"
- Active voice only: "The model raised revenue by 27%," not "A 27% increase was observed"
- Cut ruthlessly: if a word doesn't add information, delete it
- Precise verbs eliminate modifiers: "argue," not "walk confidently"
- No em dashes: they signal AI-generated text. Use commas, colons, semicolons or periods instead. A colon sets up a delivery; a comma continues the thought; a period ends it.
- American English: optimize, color, analyze
- Numbers: spell out one to nine; numerals for 10+; always numerals for percentages
- No exclamation marks in serious writing

## 14. Checklist

Run through before finalizing any deck:

### Story

1. Does reading slide titles in sequence tell the full story?
2. Does the executive summary give away the answer first (SCQA)?
3. Does each slide have exactly one message?
4. Does the final slide end with prioritized actions, not just findings?

### Content

1. Does every finding have a "so what"?
2. Are charts interpreted, not just described?
3. Is everything quantified? (no "some", "many", "several")
4. Are conclusions reframed, not repeated?

### Production

1. Are all titles 18pt, consistent across slides?
2. Does all body content end above 6.70"?
3. Are font sizes consistent within each slide type?
4. Are chart PNGs crisp at slideshow zoom?
5. Do title slide placeholders inherit theme formatting?

## Layout Code Patterns

See [layouts.md](layouts.md) for copy-pasteable code for each layout type.
