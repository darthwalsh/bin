"""Display formatting helpers for withings.py — no withings_api dependency."""

ANSI_RESET = "\033[0m"
ANSI_BG_RED = "\033[41m"
ANSI_BOLD = "\033[1m"


def score_to_ansi_color(score: int) -> str:
  """Map 0-100 score to an ANSI 24-bit color: 0=red (hue 0), 100=green (hue 120)."""
  clamped = max(0, min(100, score))
  hue = clamped * 1.2  # 0 -> 0 (red), 100 -> 120 (green)
  r, g, b = _hsv_to_rgb(hue, 1.0, 1.0)
  return f"\033[38;2;{r};{g};{b}m"


def _hsv_to_rgb(h: float, s: float, v: float) -> tuple[int, int, int]:
  """Convert HSV (h in [0,360), s/v in [0,1]) to RGB tuple of ints [0,255]."""
  if s == 0:
    c = round(v * 255)
    return c, c, c
  h = h % 360 / 60
  i = int(h)
  f = h - i
  p = v * (1 - s)
  q = v * (1 - s * f)
  t = v * (1 - s * (1 - f))
  sectors = [
    (v, t, p),
    (q, v, p),
    (p, v, t),
    (p, q, v),
    (t, p, v),
    (v, p, q),
  ]
  r, g, b = sectors[i]
  return round(r * 255), round(g * 255), round(b * 255)


# Sleep bar: 9 PM (hour 21) to 11 AM (hour 35, i.e. 11 on the next day).
# 4 chars per hour → 14 hours × 4 = 56 chars wide.
CHART_START_HOUR = 21  # 9 PM
CHART_END_HOUR = 35    # 11 AM next day (35 = 24 + 11)
CHARS_PER_HOUR = 4
CHART_WIDTH = (CHART_END_HOUR - CHART_START_HOUR) * CHARS_PER_HOUR  # 56


def _to_chart_hour(dt) -> float:
  """Convert an arrow datetime to a fractional hour on the chart axis.

  Hours before midnight are taken as-is (e.g. 22.5 → 22.5).
  Hours after midnight are shifted +24 so they sort after midnight
  (e.g. 6.25 → 30.25), keeping everything on one linear axis.
  """
  h = dt.hour + dt.minute / 60
  if h < CHART_START_HOUR - 24:
    # extremely early morning already past midnight — shouldn't happen
    h += 24
  elif h < 12:
    # AM hours (0–11) are after midnight, add 24 to place them right of midnight
    h += 24
  return h


def fmt_sleep_bar(startdate, enddate) -> str:
  """Return a fixed-width ASCII bar showing when sleep occurred on the chart axis."""
  start_h = _to_chart_hour(startdate)
  end_h = _to_chart_hour(enddate)

  start_pos = round((start_h - CHART_START_HOUR) * CHARS_PER_HOUR)
  end_pos = round((end_h - CHART_START_HOUR) * CHARS_PER_HOUR)

  # Clamp to chart bounds
  start_pos = max(0, min(CHART_WIDTH, start_pos))
  end_pos = max(0, min(CHART_WIDTH, end_pos))

  bar_len = max(1, end_pos - start_pos)
  return " " * start_pos + "*" * bar_len + " " * (CHART_WIDTH - start_pos - bar_len)


def fmt_sleep_axis() -> str:
  """Return the hour-label axis line, e.g. ' 9  10  11  12   1   2 ...'"""
  labels = []
  for absolute_hour in range(CHART_START_HOUR, CHART_END_HOUR + 1):
    h12 = absolute_hour % 24 % 12 or 12
    labels.append(f"{h12:>3} ")
  # Each tick is CHARS_PER_HOUR (4) chars wide; drop the trailing space of the last label
  return "".join(labels).rstrip()


def fmt_time(dt) -> str:
  """Format an arrow datetime as 12-hour HH:MM without AM/PM, e.g. '01:15'."""
  return dt.format("hh:mm")


def fmt_date(dt) -> str:
  """Format arrow date as 'Thu Apr  9' (day right-padded to 2 chars)."""
  # arrow doesn't support %-d (no-pad day) on all platforms; build manually
  return dt.format("ddd MMM") + f" {dt.day:2d}"
