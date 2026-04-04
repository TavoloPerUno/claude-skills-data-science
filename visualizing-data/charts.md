# Chart Type Code Patterns

Detailed matplotlib code for each chart type. All examples use the palette variables defined in SKILL.md section 4:

```python
# Reasonable Colors defaults (MIT license) - override with your brand palette
_BG = '#e8f2ff'; _PRIMARY = '#222222'; _WHITE = '#FFFFFF'
_ACCENT = '#006dca'; _SECONDARY = '#c6e0ff'
_MUTED = '#6f6f6f'; _MUTED_L = '#8b8b8b'
_POSITIVE = '#008217'; _NEGATIVE = '#e0002b'; _HL_YELLOW = '#fff9e5'
```

Override with your brand palette via CLAUDE.md or memory as needed.

## 1. Vertical Grouped Bar Chart

Best for: comparing two series (eg before/after) across categories.

```python
x = np.arange(len(categories))
w = 0.35

bars_a = ax.bar(x - w/2, vals_a, w, color=secondary_colors, linewidth=0, zorder=3)
bars_b = ax.bar(x + w/2, vals_b, w, color=highlight_colors, linewidth=0, zorder=3)

# Value labels - position inside tall bars, outside short bars
for i, (ba, bb, va, vb) in enumerate(zip(bars_a, bars_b, vals_a, vals_b)):
    is_focus = (i == 0)
    fs = 9.0 if is_focus else 7.0
    fw = 'bold' if is_focus else 'normal'

    bx = ba.get_x() + ba.get_width() / 2
    small = abs(va) / y_range < 0.12
    if small:
        y = va + (1.5 if va >= 0 else -1.5)
        va_align = 'bottom' if va >= 0 else 'top'
        color = _MUTED_L
    else:
        y = va / 2
        va_align = 'center'
        color = _WHITE
    ax.text(bx, y, f'{va:+.0f}%', ha='center', va=va_align,
            fontsize=fs, color=color, fontweight=fw)

# X-axis: highlight focus category
xlabels = ax.set_xticklabels(categories, fontsize=9, color=_MUTED_L)
xlabels[0].set_fontweight('bold')
xlabels[0].set_color(_ACCENT)
ax.tick_params(axis='x', length=0, pad=6)
```

## 2. Dumbbell Chart

Best for: showing old vs new for multiple groups with sub-categories (eg several tiers within each product line).

```python
for t_idx, tier in enumerate(tiers):
    ypos = tier_centers[t_idx]

    # Connecting line
    ax.plot([old_val, new_val], [ypos, ypos], '-',
            color=line_color, lw=1.5, alpha=alpha)

    # Old value (hollow circle)
    ax.plot(old_val, ypos, 'o', color='w', markeredgecolor=color,
            markersize=7, markeredgewidth=1.5, zorder=5)

    # New value (filled circle)
    ax.plot(new_val, ypos, 'o', color=color, markersize=8, zorder=5)

    # Label focus row with value + sample size
    if is_focus:
        ax.text(new_val + pad, ypos, f'{new_val:+.0f}%\nn={n:,}',
                color=color, fontsize=8, fontweight='bold', linespacing=1.3)
```

### Group separators

For multi-group dumbbells (eg several departments, each with sub-rows):

```python
# Gray band behind alternating groups
for i, group in enumerate(groups):
    if i % 2 == 0:
        y_top = group_top[i]
        y_bot = group_bottom[i]
        ax.axhspan(y_bot, y_top, color=_MUTED, alpha=0.06, zorder=0)

    # Group label (bold, left side)
    ax.text(-0.02, group_center[i], group,
            transform=ax.get_yaxis_transform(),
            fontsize=9, color=_PRIMARY, fontweight='bold',
            ha='right', va='center')
```

## 3. Stacked Multi-Panel Chart

Best for: showing the same metric under different methodological choices (eg six combinations of aggregation method and baseline).

```python
fig = plt.figure(figsize=(22, 10), facecolor=_BG)

# Layout: rows x columns
SUBTITLE_H = 0.025
ROW_GAP = 0.008
COL_GAP = 0.015

for ri, row_data in enumerate(rows):
    block_top = 1.0 - TOP_MARGIN - ri * (SUBTITLE_H + panel_h + ROW_GAP)

    # Row subtitle
    fig.text(LEFT_MARGIN, block_top, row_data['subtitle'],
             ha='left', va='top', fontsize=10.5, color=_PRIMARY)

    for ci, col_data in enumerate(columns):
        ax_l = LEFT_MARGIN + ci * (panel_w + COL_GAP)
        ax_b = block_top - SUBTITLE_H - panel_h
        ax = fig.add_axes([ax_l, ax_b, panel_w, panel_h])

        # Same bar chart code as vertical grouped bar
        # ...

        # Shared x-axis: only bottom row shows category labels
        if ri == len(rows) - 1:
            ax.set_xticklabels(categories)
        else:
            ax.set_xticklabels([])
```

## 4. Scatter Plot

Best for: showing relationships between two variables across entities (eg countries, regions, departments).

```python
# Size by volume, color by group
for group, color in group_colors.items():
    mask = df['group'] == group
    ax.scatter(
        df[mask]['x'], df[mask]['y'],
        s=df[mask]['volume'] * scale,
        color=color, alpha=0.7,
        edgecolors='white', linewidth=0.5, zorder=3)

    # Label large entities directly (no legend)
    for _, row in df[mask].iterrows():
        if row['volume'] > threshold:
            ax.annotate(row['name'], (row['x'], row['y']),
                        fontsize=7, color=_MUTED, ha='center', va='bottom')

# Median reference lines
ax.axvline(df['x'].median(), color='#AAAAAA', ls='--', lw=0.8, zorder=1)
ax.axhline(df['y'].median(), color='#AAAAAA', ls='--', lw=0.8, zorder=1)

# Quadrant labels (optional)
ax.text(0.02, 0.98, 'High Y, low X',
        transform=ax.transAxes, fontsize=7.5, color=_POSITIVE,
        va='top', ha='left', fontstyle='italic', alpha=0.7)
```

### Overlap avoidance

For dense scatter plots, use adjustText to avoid label collisions:

```python
from adjustText import adjust_text
texts = []
for _, row in df.iterrows():
    t = ax.text(row['x'], row['y'], row['label'],
                fontsize=6.5, color=_PRIMARY, ha='center', va='center')
    texts.append(t)
adjust_text(texts, ax=ax,
            arrowprops=dict(arrowstyle='-', color='#AAAAAA', lw=0.4),
            force_text=(0.3, 0.3), expand=(1.3, 1.5))
```

## 5. Packed Circle / Bubble Chart

Best for: showing proportions across many categories where the size differences are dramatic. Labels go directly on the circles.

```python
import circlify

# Sort ascending (circlify expects this)
df_sorted = df.sort_values('value').reset_index(drop=True)
circles = circlify.circlify(df_sorted['value'].tolist(), show_enclosure=False)

# Color gradient: darker = larger
FILLS = ['#light', ..., '#dark']  # 8-10 stops from light to dark
r_min = min(c.r for c in circles)
r_max = max(c.r for c in circles)

for circle, (_, row) in zip(circles, df_sorted.iterrows()):
    # Map radius to fill darkness
    ri = int((circle.r - r_min) / max(r_max - r_min, 1e-9) * (len(FILLS) - 1))
    fill = FILLS[len(FILLS) - 1 - ri]  # larger = darker

    patch = plt.Circle((circle.x, circle.y), circle.r,
                        facecolor=fill, edgecolor='white', linewidth=0.8)
    ax.add_patch(patch)

    # Label inside circle - size proportional to radius
    if circle.r > 0.06:
        fs = max(7, min(16, int(circle.r * 90)))
        ax.text(circle.x, circle.y + circle.r * 0.15,
                row['label'], fontsize=fs, color='white', ha='center')
        ax.text(circle.x, circle.y - circle.r * 0.25,
                f'{row["value"]:.1f}%', fontsize=fs + 1, color='white',
                ha='center', fontweight='bold')

ax.set_xlim(-1.2, 1.2)
ax.set_ylim(-1.2, 1.2)
ax.set_aspect('equal')
ax.axis('off')
```

## 6. Horizontal Grouped Bar Chart

Best for: comparing two series across a small number of categories (5-7) where labels are long.

```python
y = np.arange(len(categories))
h = 0.35

ax.barh(y + h/2, vals_a, h, color=_SECONDARY, linewidth=0, zorder=3)
ax.barh(y - h/2, vals_b, h, color=_ACCENT, linewidth=0, zorder=3)
ax.invert_yaxis()  # top category first

# Labels with yellow highlight
_HL = dict(boxstyle='round,pad=0.12', facecolor=_HL_YELLOW,
           edgecolor='none', alpha=0.85)
for i in range(len(categories)):
    ax.text(vals_b[i] + 0.8, y[i] - h/2,
            f'{vals_b[i]:+.0f}% n={ns[i]:,}',
            fontsize=11, color=_ACCENT, fontweight='bold', bbox=_HL)

# Category labels
ax.set_yticks(y)
ax.set_yticklabels(categories, fontsize=10, color=_PRIMARY)
ax.tick_params(axis='y', length=0, pad=8)
```

## 7. Line Chart with Bootstrap CI

Best for: showing a metric that scales with a continuous variable (eg savings that grow with study length), with uncertainty bands.

```python
# Central estimate + confidence interval
ax.fill_between(x, y_lo, y_hi, color=_ACCENT, alpha=0.12)
ax.plot(x, y_central, color=_ACCENT, lw=3)

# Annotate key point with arrow
ax.annotate(
    f'{val:.1f} weeks\n({lo:.1f}-{hi:.1f})',
    (x_pt, y_pt),
    textcoords='offset points', xytext=(15, 15),
    fontsize=10, color=_ACCENT, fontweight='bold', linespacing=1.3,
    arrowprops=dict(arrowstyle='->', color=_ACCENT, lw=1.5),
    bbox=dict(boxstyle='round,pad=0.15', facecolor=_HL_YELLOW,
              edgecolor='none', alpha=0.85))

# X-axis
ax.set_xlabel('Study duration (months)', fontsize=9, color=_MUTED, labelpad=8)
ax.set_ylabel('Weeks saved', fontsize=9, color=_MUTED, labelpad=8)
```

## 8. Timeline / Area Gap Chart

Best for: showing the gap between two cumulative curves (eg old vs new revenue trajectories).

```python
# Shaded area between curves
ax.fill_between(months, old_curve, new_curve, alpha=0.15, color=_ACCENT)
ax.plot(months, old_curve, color=_SECONDARY, lw=2, label='Baseline')
ax.plot(months, new_curve, color=_ACCENT, lw=2, label='Updated')

# Direct-label at end of each line (no legend)
ax.text(months[-1] + 0.3, old_curve[-1], 'Baseline',
        fontsize=9, color=_SECONDARY, va='center')
ax.text(months[-1] + 0.3, new_curve[-1], 'Updated',
        fontsize=9, color=_ACCENT, va='center', fontweight='bold')

# Annotate the gap at a key timepoint
mid = (old_curve[idx] + new_curve[idx]) / 2
ax.annotate(f'{gap:.1f}%\nfaster', xy=(months[idx], mid),
            fontsize=9, color=_ACCENT, fontweight='bold', ha='center')
```

## 9. Stacked Bar with Inline Numbers

Best for: composition / part-of-whole comparisons across categories.

```python
bottom = np.zeros(len(categories))
for segment, color in zip(segments, segment_colors):
    vals = df[segment].values
    bars = ax.bar(x, vals, bottom=bottom, color=color, linewidth=0, zorder=3)

    # Numbers ON the bars (white text, centered)
    for i, (bar, v) in enumerate(zip(bars, vals)):
        if v > min_label_threshold:  # skip tiny segments
            ax.text(bar.get_x() + bar.get_width() / 2,
                    bottom[i] + v / 2,
                    f'{v:.0f}', ha='center', va='center',
                    fontsize=8, color='white', fontweight='bold')
    bottom += vals
```

## Common Patterns

### Size legend for scatter/bubble charts

```python
for ns, label in [(200, '200'), (50, '50'), (10, '10')]:
    sz = ((ns / max_n) ** 0.5 * max_marker_size + min_size)
    ax.scatter([], [], s=sz, color=_MUTED, alpha=0.6,
               edgecolors='white', linewidth=0.5, label=f'{label} regions')
ax.legend(loc='lower right', title='Volume', title_fontsize=7,
          fontsize=6.5, frameon=False, labelcolor=_MUTED,
          labelspacing=1.2, handletextpad=0.5)
```

### Colorbar (for continuous color mapping)

```python
cbar = fig.colorbar(scatter_obj, ax=ax, shrink=0.4, pad=0.02, aspect=15)
cbar.set_label('Metric name', fontsize=7, color=_MUTED)
cbar.ax.tick_params(labelsize=6, colors=_MUTED)
cbar.outline.set_visible(False)
```

## 10. Sparklines / Mini Charts (for embedding in slides)

Small, self-contained charts designed to sit inside PPT card elements or table cells. No axes, no labels beyond the essentials. The background color matches the card fill so the chart blends in.

Key principles:
- Tiny figure size: 2.5-3" wide, 0.8-1.0" tall
- Match the container color: `facecolor=card_fill_color` (not transparent, which can render oddly in PPT)
- No spines, no ticks, no gridlines: the chart is decoration, not a standalone visualization
- Minimal labels: one or two value callouts, no axis text
- High DPI: 250+ so text stays crisp when embedded small

### Mini horizontal bars (before/after comparison)

```python
fig, ax = plt.subplots(figsize=(2.8, 0.85), facecolor=card_fill)
ax.set_facecolor(card_fill)
ax.barh([0.35, -0.35], [old_val, new_val], height=0.55,
        color=[_SECONDARY, _ACCENT], linewidth=0)
ax.text(old_val + 0.8, 0.35, f'+{old_val:.0f}%', fontsize=8,
        color=_SECONDARY, fontweight='bold', va='center', bbox=_HL)
ax.text(new_val + 0.8, -0.35, f'+{new_val:.0f}%', fontsize=8,
        color=_ACCENT, fontweight='bold', va='center', bbox=_HL)
for s in ax.spines.values(): s.set_visible(False)
ax.set_xticks([]); ax.set_yticks([])
plt.savefig(path, dpi=250, bbox_inches='tight', pad_inches=0.02,
            facecolor=card_fill)
```

### Mini dumbbell (sensitivity across variants)

```python
fig, ax = plt.subplots(figsize=(2.8, 1.0), facecolor=card_fill)
ax.set_facecolor(card_fill)
for i, (lbl, ov, nv) in enumerate(zip(labels, old_vals, new_vals)):
    y_pos = len(labels) / 2 - i  # spread vertically
    ax.plot([ov, nv], [y_pos, y_pos], '-', color=_PRIMARY, lw=2, alpha=0.25)
    ax.plot(ov, y_pos, 'o', color='white', markeredgecolor=_SECONDARY,
            markersize=8, markeredgewidth=1.0)
    ax.plot(nv, y_pos, 'o', color=_ACCENT, markersize=8)
    ax.text(nv + 0.8, y_pos, f'+{nv:.0f}%', fontsize=7, color=_ACCENT,
            fontweight='bold', va='center', bbox=_HL)
for s in ax.spines.values(): s.set_visible(False)
ax.set_xticks([]); ax.set_yticks([])
```

### Mini line chart (scaling metric)

```python
fig, ax = plt.subplots(figsize=(2.8, 0.85), facecolor=card_fill)
ax.set_facecolor(card_fill)
ax.fill_between(x, 0, y, color=_ACCENT, alpha=0.10)
ax.plot(x, y, color=_ACCENT, lw=2.5)

# One or two annotated dots
ax.plot(x_key, y_key, 'o', color=_ACCENT, markersize=7)
ax.text(x_key + offset, y_key, f'{y_key:.1f}', fontsize=7,
        color=_ACCENT, fontweight='bold', bbox=_HL)
for s in ax.spines.values(): s.set_visible(False)
ax.set_xticks([]); ax.set_yticks([])
```

### Red-yellow-green diverging colormap

```python
from matplotlib.colors import LinearSegmentedColormap
cmap = LinearSegmentedColormap.from_list('ryg',
    ['#D73027', '#FC8D59', '#FEE08B', '#D9EF8B', '#91CF60', '#1A9850'])
```
