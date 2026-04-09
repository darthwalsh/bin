"""Tests for withings_fmt helpers."""

import arrow

from withings_fmt import (
  CHART_WIDTH,
  _hsv_to_rgb,
  fmt_date,
  fmt_sleep_axis,
  fmt_sleep_bar,
  fmt_time,
  score_to_ansi_color,
)


# _hsv_to_rgb
def test_hsv_red():
  assert _hsv_to_rgb(0, 1.0, 1.0) == (255, 0, 0)


def test_hsv_green():
  assert _hsv_to_rgb(120, 1.0, 1.0) == (0, 255, 0)


def test_hsv_white():
  assert _hsv_to_rgb(0, 0.0, 1.0) == (255, 255, 255)


def test_hsv_black():
  assert _hsv_to_rgb(0, 0.0, 0.0) == (0, 0, 0)


# score_to_ansi_color
def test_score_0_is_red():
  assert score_to_ansi_color(0) == "\033[38;2;255;0;0m"


def test_score_100_is_green():
  assert score_to_ansi_color(100) == "\033[38;2;0;255;0m"


def test_score_50_is_yellow():
  # hue=60 => pure yellow (255,255,0)
  assert score_to_ansi_color(50) == "\033[38;2;255;255;0m"


def test_score_clamps_below_0():
  assert score_to_ansi_color(-10) == score_to_ansi_color(0)


def test_score_clamps_above_100():
  assert score_to_ansi_color(110) == score_to_ansi_color(100)


# fmt_date
def test_fmt_date_single_digit_day():
  assert fmt_date(arrow.Arrow(2026, 4, 9)) == "Thu Apr  9"


def test_fmt_date_double_digit_day():
  assert fmt_date(arrow.Arrow(2026, 3, 14)) == "Sat Mar 14"


# fmt_time
def test_fmt_time_pm():
  assert fmt_time(arrow.Arrow(2026, 4, 9, 22, 2)) == "10:02"


def test_fmt_time_am():
  assert fmt_time(arrow.Arrow(2026, 4, 10, 5, 59)) == "05:59"


def test_fmt_time_midnight():
  assert fmt_time(arrow.Arrow(2026, 4, 9, 0, 0)) == "12:00"


# fmt_sleep_bar
def test_fmt_sleep_bar_width():
  bar = fmt_sleep_bar(arrow.Arrow(2026, 4, 9, 22, 0), arrow.Arrow(2026, 4, 10, 6, 0))
  assert len(bar) == CHART_WIDTH


def test_fmt_sleep_bar_position():
  # 10 PM start (1 hour after chart start at 9 PM) → 4 leading spaces; 6 AM end (9 hours after midnight = 33h, 12h after chart start) → 48 chars in
  bar = fmt_sleep_bar(arrow.Arrow(2026, 4, 9, 22, 0), arrow.Arrow(2026, 4, 10, 6, 0))
  assert bar[:4] == "    "   # 1 hour of leading space
  assert "*" in bar


# fmt_sleep_axis
def test_fmt_sleep_axis_starts_with_9():
  assert fmt_sleep_axis().lstrip().startswith("9")


def test_fmt_sleep_axis_contains_12():
  assert "12" in fmt_sleep_axis()
