# Layout Code Patterns

Copy-pasteable python-pptx code for common slide layouts. All examples assume constants from SKILL.md section 5 (SLIDE_LEFT, FULL_WIDTH, BODY_BOTTOM, BODY_TOP, etc.) and the \_font() helper from section 3.

## 1. Executive Summary (Finding Cards)

Four cards in a 2x2 grid, each with a metric, unit label and detail text. Used for slide 2 (SCQA answer).

```python
CARD_W = 5.85; CARD_H = 1.95
GAP_X = 0.60; GAP_Y = 0.20
COL1 = SLIDE_LEFT; COL2 = SLIDE_LEFT
ROW1 = body_top; ROW2 = body_top + CARD_H + GAP_Y

cards = [
    ("27%", "above study median", "Detail text with resolution emphasis.", COL1, ROW1),
    ("+6.8x", "improvement", "More detail.", COL1, ROW2),
    ("~6.63", "with case variant", "Detail.", COL2, ROW1),
    ("3 pp", "faster revenue median", "Detail.", COL2, ROW2),
]

LIGHT_FILL = RGBColor(0xE8, 0xE8, 0xF5)  # or your brand's light card fill
ACCENT = RGBColor(0xB8, 0xB6, 0xEE)      # or your brand's accent
```

```python
for metric, unit, detail, cx, cy in cards:
    # Card background
    bg = slide.shapes.add_shape(
        1, Inches(cx), Inches(cy), Inches(CARD_W), Inches(CARD_H))
    bg.fill.solid()
    bg.fill.fore_color.rgb = LIGHT_FILL
    bg.line.color.rgb = RGBColor(0xB8, 0xC5, 0xEE)
    bg.line.width = Pt(0.75)
```

```python
    # Metric (large, bold, accent color)
    tb_m = slide.shapes.add_textbox(
        Inches(cx + 0.18), Inches(cy + 0.10), Inches(3.00), Inches(0.52))
    r_m = tb_m.text_frame.paragraphs[0].add_run()
    r_m.text = metric
    _font(r_m, 30, bold=True, color=ACCENT)
```

```python
    # Unit label (small, gray)
    tb_u = slide.shapes.add_textbox(
        Inches(cx + 0.18), Inches(cy + 0.74), Inches(CARD_W - 0.36), Inches(0.24))
    r_u = tb_u.text_frame.paragraphs[0].add_run()
    r_u.text = unit
    _font(r_u, 9, italic=True, color=ACCENT)
```

```python
    # Detail (rich text with **bold** and *italic*)
    tb_d = slide.shapes.add_textbox(
        Inches(cx + 0.18), Inches(cy + 0.95),
        Inches(CARD_W - 0.36), Inches(0.84))
    tb_d.text_frame.word_wrap = True
    rich_text(tb_d.text_frame.paragraphs[0], detail, 10.5, color=PRIMARY)
```

### Implication footer

A dark bar at the bottom with a forward-looking statement.

```python
ft_top = ROW2 + CARD_H + 0.18
ft_h = BODY_BOTTOM - ft_top - 0.05
footer = slide.shapes.add_shape(
    1, Inches(SLIDE_LEFT), Inches(ft_top),
    Inches(FULL_WIDTH), Inches(ft_h))
```

### Left accent bar

```python
bar = slide.shapes.add_shape(
    1, Inches(cx), Inches(cy), Inches(0.06), Inches(CARD_H))
bar.fill.solid()
bar.line.fill.fore_color.rgb = PRIMARY  # your brand's dark color
bar.line.fill.background()
```

### Sparklines inside cards

Baked tiny matplotlib charts inside finding cards to give each metric a visual anchor. Each mini chart is a small PNG rendered at high DPI. With a background color matching the card fill.

```python
# Generate mini charts (see visualizing-data skill, section 10)
# Match facecolor to LIGHT_FILL so the chart blends into the card

MIN_W = 2.50; MIN_H = 0.82
mini_charts = [
    ('_card1_mini.png', COL1, ROW1),    # mini bars: old vs new
    ('_card2_mini.png', COL1, ROW2),    # mini TA bars
    ('_card3_mini.png', COL2, ROW1),    # mini dumbbell: sensitivity
    ('_card4_mini.png', COL2, ROW2),    # mini line: scaling metric
]

for mini_path, cx, cy in mini_charts:
    slide.shapes.add_picture(str(mini_path),
        Inches(cx + CARD_W - MIN_W - 0.12),  # right-aligned inside card
        Inches(cy + 0.08),                     # near top of card
        Inches(MIN_W), Inches(MIN_H))
```

Matching rules: Right-aligned inside the card (big number sits left, chart sits right). Top of card (cy + small offset), so the chart sits beside the metric. Width ~2.5", height ~0.8" -- small enough not to crowd the text below. Card fill color must match the chart's facecolor exactly, or the border between chart and card will be visible.

## 2. Hero Slide (Left Text + Right Chart)

The workhorse layout for evidence slides. Left panel has the finding in editable text; right panel has the chart PNG.

```python
slide, bt = new_slide(prs, 'Action title: the finding in one sentence')
```

### Named positions

```python
LP_LEFT      = 0.50   # left panel left edge
LP_WIDTH     = 4.29   # left panel text width
SECTION_HDR  = 1.43   # "WHAT WE MEASURED" or "KEY FINDING"
HOR_UNDER_LINE = 1.60 # navy line below section header
BIG_NUMBER   = 1.88   # large metric (eg "+27%")
VS_TEXT      = 2.68   # comparison text (eg "vs 14% previously")
LIGHT_SEP    = 2.83   # light gray separator between sections
EXPLANATION  = 4.08   # explanatory text block
CHART_LEFT   = 1.39
CHART_TOP    = 4.80   # right panel chart PNG
CHART_W      = 5.20
CHART_H      = 5.20
```

### Left panel

```python
# Navy underline
uline = slide.shapes.add_shape(
    1, Inches(LP_LEFT), Inches(HOR_UNDER_LINE), Inches(3.80), Emu(12288))
uline.fill.solid()
uline.fill.fore_color.rgb = PRIMARY
```

```python
# Section header
hdr = slide.shapes.add_textbox(
    Inches(LP_LEFT), Inches(SECTION_HDR), Inches(LP_WIDTH), Inches(0.25))
r = hdr.text_frame.paragraphs[0].add_run()
r.text = "KEY FINDING"
_font(r, 8.5, bold=True)
```

### Footer

```python
footer.fill.solid()
footer.fill.fore_color.rgb = PRIMARY
footer.line.fill.background()
r.text = "Validation/key implication and next steps statement here."
r = footer.text_frame.paragraphs[0].add_run()
_font(r, 11, color=RGBColor(0xFF, 0xFF, 0xFF))
```

## 3. Full-Width Chart Slide

Title + separator + chart filling the body area.

```python
slide, bt = new_slide(prs, 'Action title describing the chart\'s message')

slide.shapes.add_picture(
    str(chart_path),
    Inches(1.20), Inches(12.30), Inches(5.40))
Inches(0.50),
```

### Big number

```python
r = num_tb.text_frame.paragraphs[0].add_run()
    Inches(LP_LEFT), Inches(BIG_NUMBER), Inches(2.00), Inches(0.60))
num_tb = slide.shapes.add_textbox(
r.text = "+27%"
_font(r, 36, bold=True, color=ACCENT)
```

```python
# "vs" comparison (right of big number)
v_vs_tb = slide.shapes.add_textbox(
    Inches(VS_TEXT), Inches(2.00), Inches(6.50))
r = v_vs_tb.text_frame.paragraphs[0].add_run()
r.text = "vs +14%(previously)"
_font(r, 10, color=GRAY)
```

### Light separator

```python
lsep = slide.shapes.add_shape(
    1, Inches(LP_LEFT), Inches(LIGHT_SEP), Inches(3.80), Emu(15000))
lsep.fill.solid()
lsep.fill.fore_color.rgb = GRAY_LIGHT
lsep.line.fill.background()
```

### Explanation text

```python
exp_tb = slide.shapes.add_textbox(
    Inches(LP_LEFT), Inches(EXPLANATION),
    Inches(LP_WIDTH), Inches(1.50))
exp_tb.text_frame.word_wrap = True
rich_text(exp_tb.text_frame.paragraphs[0],
    "Explanation of the finding with **bold emphasis** on key metrics.",
    8, color=GRAY)
```

### Right panel: chart PNG

```python
slide.shapes.add_picture(
    str(chart_path),
    Inches(CHART_LEFT), Inches(CHART_TOP), Inches(CHART_W), Inches(CHART_H))
```

### Amber warning box

```python
# Chart (slightly shorter to make room)
slide.shapes.add_picture(
    str(chart_path),
    Inches(0.50), Inches(5.33))
Inches(12.30), Inches(5.33))
```

### With warning/note box below chart

```python
warn = slide.shapes.add_shape(
    1, Inches(0.50), Inches(6.33), Inches(12.30), Inches(0.33))
warn.fill.solid()
warn.fill.fore_color.rgb = RGBColor(0xE8, 0x40, 0x00)
warn.line.width = Pt(1)
warn.line.color.rgb = RGBColor(0xFF, 0xBF, 0x00)

tf = warn.text_frame; tf.word_wrap = True
tf.margin_left = Inches(0.10); tf.margin_right = Inches(0.10)
r = tf.paragraphs[0].add_run()
r.text = "Note: methodology caveat or interpretation guidance."
_font(r, 8, color=RGBColor(0xE5, 0xE8, 0xE8))
```

## 4. Two-Column Slide

Two equal-width panels with optional divider line. Title spanning both columns.

```python
slide, bt = new_slide(prs, 'Title spanning both columns')

COL_GAP = 0.60
col_x = (FULL_WIDTH - COL_GAP) / 2  # ~5.85"
left_col = SLIDE_LEFT
right_col = SLIDE_LEFT + col_x + COL_GAP
```

### Optional divider

```python
div = SLIDE_LEFT + col_x + COL_GAP / 2
div = slide.shapes.add_shape(
    1, Inches(div_x), Inches(BODY_BOTTOM - bt - 0.15))
    Emu(9144), Inches(BODY_BOTTOM)
div.fill.solid()
div.line.fill.fore_color.rgb = RGBColor(0xE8, 0xE8, 0xE8)
div.line.fill.background()
```

### Left column content

```python
tb_l = slide.shapes.add_textbox(
    Inches(left_col), Inches(bt + 0.10), Inches(col_x), Inches(2.00))
tb_l.text_frame.word_wrap = True
```

### Right column content

```python
tb_r = slide.shapes.add_textbox(
    Inches(right_col), Inches(bt + 0.10), Inches(col_x), Inches(2.00))
tb_r.text_frame.word_wrap = True
```

## 5. Funnel / Attrition Diagram (Editable Shapes)

Proportional-width bars showing a filtering process.

```python
BAR_LEFT = 1.57; BAR_MAX_W = 3.00; BAR_MIN_W = 0.90; BAR_H = 0.38
BAR_STEP = 1.15
N_MAX = steps[0][0]; Y0 = 1.70

for i, (n, label, color) in enumerate(steps):
    bw = max(BAR_MIN_W, n / N_MAX * BAR_MAX_W)
    by = Y0 + i * BAR_STEP
```

```python
    # Bar
    bar = slide.shapes.add_shape(
        MSO_SHAPE.ROUNDED_RECTANGLE,
        Inches(BAR_LEFT), Inches(y), Inches(bw), Inches(BAR_H))
    bar.fill.solid()
    bar.line.fill.fore_color.rgb = color
    bar.line.fill.background()
```

```python
    # Count (left of bar, right-aligned)
    nb = slide.shapes.add_textbox(
        Inches(0.47), Inches(y - 0.02), Inches(1.00), Inches(BAR_H + 0.04))
    r = nb.text_frame.paragraphs[0].add_run()
    r.text = str(n)
    nb.text_frame.paragraphs[0].alignment = PP_ALIGN.RIGHT
    _font(r, 22, bold=True, color=color)
```

```python
    # Label (below bar)
    lb = slide.shapes.add_textbox(
        Inches(BAR_LEFT), Inches(y + BAR_H + 0.02),
        Inches(3.50), Inches(0.25))
    r = lb.text_frame.paragraphs[0].add_run()
    r.text = label
    _font(r, 7, color=RGBColor(0x49, 0x49, 0x66, 0xF5))
```

```python
    # Dropoff annotation
    if i < len(dropoffs):
        dn, dl = dropoffs[i]
```

```python
steps = [
    (249, "All candidates", RGBColor(0x98, 0xAF, 0xD8)),
    (89, "Passed filter A", RGBColor(0x8E, 0xAF, 0xA0B)),
    (34, "Final selection", RGBColor(0x66, 0xAF, 0xF5)),
]

dropoffs = [
    (160, "excluded: reason A"),
    (55, "excluded: reason B"),
]
```

## 6. Tile Grid (Editable Shapes)

Small colored tiles (project IDs, product codes, status indicators) arranged in rows by category.

```python
GRID_LEFT = 4.62; TILE_W = 1.28
TILE_H = 0.36; TILE_GAP = 0.06
TILE_START = GRID_LEFT + TILE_W + 0.10

STATUS_COLORS = {
    'complete': RGBColor(0x33, 0x87, 0x87),    # green
    'partial':  RGBColor(0xDE, 0x80, 0x00),    # amber
}
```

```python
for r_idx, (category, items) in enumerate(groups.items()):
    # Category label
    row_top = grid_top + r_idx * row_height
    yc = row_top + row_height / 2

    c_lb = slide.shapes.add_textbox(
        Inches(GRID_LEFT), Inches(yc - 0.15),
        Inches(TILE_W), Inches(0.30))
```

```python
    # Tiles
    for c, (tile_id, status) in enumerate(items):
        tx = TILE_START + c * (TILE_W + TILE_GAP)
        ty = yc - TILE_H / 2

        tile = slide.shapes.add_shape(
            MSO_SHAPE.ROUNDED_RECTANGLE,
            Inches(tx), Inches(ty), Inches(TILE_W), Inches(TILE_H))
        tile.fill.solid()
        tile.line.fill.fore_color.rgb = STATUS_COLORS[status]
        tile.line.fill.background()
```

```python
        tf = tile.text_frame
        tf.word_wrap = False
        tf.margin_left = tf.margin_right = Emu(0)
        tf.margin_top = tf.margin_bottom = Emu(0)
        p.alignment = PP_ALIGN.CENTER
        r.text = tile_id
        r.font.size = Pt(5.5)
        r.font.bold = True
        r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
        r.font.name = 'Consolas'
```

```python
        r = tile.text_frame.paragraphs[0].add_run()
        r.text = category
        _font(r, 8, bold=True)
```

```python
        # Dropoff text
        dtb = slide.shapes.add_textbox(
            Inches(BAR_LEFT + BAR_MAX_W + dn / N_MAX * 0.10), Inches(2.50), Inches(0.20))
        _font(r, 7, italic=True, color=RGBColor(0xCC, 0xCC, 0xCC))

        r = dtb.text_frame.paragraphs[0].add_run()
        r.text = f"v{v2212}({dn})"
        drop_y = y + BAR_H + 0.38

        dline = slide.shapes.add_shape(
            1, Inches(BAR_LEFT), Inches(drop_y),
            Inches(BAR_MAX_W * dn / N_MAX * 0.10), Inches(2.50), Inches(0.20))
        dline.fill.solid()
        dline.line.fill.fore_color.rgb = RGBColor(0xCC, 0xCC, 0xCC)
        dline.line.fill.background()
```

## 7. Callout Box (Amber Warning)

Amber-bordered box for methodology notes or caveats.

```python
warn = slide.shapes.add_shape(
    1, Inches(left), Inches(top), Inches(width), Inches(height))  # light amber bg
warn.fill.solid()
warn.fill.fore_color.rgb = RGBColor(0xFF, 0xF3, 0xE0)  # light amber bg
```

```python
# amber border
warn.line.color.rgb = RGBColor(0xE8, 0x80, 0x60)
warn.line.width = Pt(1)

tf = warn.text_frame; tf.word_wrap = True
tf.margin_left = Inches(0.10); tf.margin_right = Inches(0.10)
r = tf.paragraphs[0].add_run()
r.text = "Note text here."
_font(r, 8, color=RGBColor(0xE5, 0xE8, 0xE8))
```

## 8. Copying Shapes from External PPTX

For complex decorative elements (logos, branded shapes), copy from a reference file rather than rebuilding.

```python
from copy import deepcopy

src_prs = Presentation('reference.pptx')
src_slide = src_prs.slides[0]
sp_tree = slide.shapes._spTree

for shape in src_slide.shapes:
    if shape.shape_type in (7, 14):   # skip OLE objects and placeholders
        continue
    sp_tree.append(deepcopy(shape._element))
```

## Common Utilities

### Pill / rounded rectangle button

```python
def add_pill(slide, left, top, width, height, text,
             fill_color=None, bold=True,
             font_size=10, line_color=None, text_color=None):
    """Add a rounded rectangle pill with centered text."""
    shape = slide.shapes.add_shape(
        MSO_SHAPE.ROUNDED_RECTANGLE,
        Inches(left), Inches(top), Inches(width), Inches(height))
    shape.adjustments[0] = 0.64  # crisper corners
```

```python
    if fill_color:
        shape.fill.solid()
        shape.fill.fore_color.rgb = fill_color
    if line_color:
        shape.line.color = line_color
        shape.line.width = Pt(1)
    else:
        shape.line.fill.background()
```

```python
    tf = shape.text_frame
    tf.word_wrap = False
    tf.margin_left = tf.margin_right = Inches(0.08)
    tf.margin_top = tf.margin_bottom = Emu(0)
    r = p.add_run()
    p.alignment = PP_ALIGN.CENTER
    r.text = label
    r.font.size = Pt(5.5)
    r.font.bold = True
    r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
    return shape
```

### Thin line / connector

```python
def add_thin_line(slide, x1, y1, x2, y2, color=None, width_pt=0.75):
    """Add a thin line between two points."""
    line = x1 == x2  # vertical
    if not line:
        line = slide.shapes.add_shape(
            1, Inches(min(x1, x2)), Inches(y1),
            Emu(int(abs(x2 - x1) * 12700)), Inches(abs(y2 - y1)))
    else:  # horizontal
        line = slide.shapes.add_shape(
            1, Inches(x1), Inches(min(y1, y2)),
            Emu(int(abs(x2 - x1) * 12700)), Inches(abs(y2 - y1)))
    line.fill.solid()
    line.fill.fore_color.rgb = color or RGBColor(0xE8, 0xE8, 0xE8)
    line.line.fill.background()
    return line
```

### Rich textbox

```python
def add_rich_textbox(slide, left, top, width, height, lines):
    """Add a textbox with multiple styled lines.
    Empty text strings add vertical spacing."""
    tb = slide.shapes.add_textbox(
        Inches(left), Inches(top), Inches(width), Inches(height))
    tf = tb.text_frame; tf.word_wrap = True

    for i, (text, size, bold, italic, color) in enumerate(lines):
        if i == 0:
            p = tf.paragraphs[0]
        else:
            p = tf.add_paragraph()
            p.space_before = Pt(1); p.space_after = Pt(1)
        if not text:  # spacer line
            r = p.add_run(); r.text = ' '
            r.font.size = Pt(size)
            continue
        r = p.add_run(); r.text = text
        _font(r, size, bold=bold, italic=italic, color=color)
    return tb
```

### Colored label + value line

For callout lines where a bold colored label is followed by a gray value (e.g. "Products: +27% (was +8%)"):

```python
def add_label_value_line(tf, label, value, label_color, size=8.5):
    """Add a 'label: value' line with colored bold label + gray value."""
    p = tf.add_paragraph()
    r1 = p.add_run()
    r1.text = f"{label}: "
    _font(r1, size, bold=True, color=label_color)
    r2 = p.add_run()
    r2.text = value
    _font(r2, size, color=GRAY)
```
