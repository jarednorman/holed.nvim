#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates the "holed" palette: a neutral gradient from #000000 to #ffffff
# plus a set of accent colours spaced geometrically around the OKLCH hue wheel.
# Prints each colour as a swatch using 24-bit terminal colour sequences.

# ---------------------------------------------------------------------------
# Tunables
# ---------------------------------------------------------------------------
NEUTRAL_STEPS = 8           # number of greys, including #000000 and #ffffff
NEUTRAL_FLOOR_Y = 0.01      # linear luminance of the first grey above black (1 = white)
NEUTRAL_TINT_HUE = 300.0    # OKLCH hue of the tint applied to the greys
NEUTRAL_TINT_CHROMA = 0.008 # peak tint chroma; fades to 0 at both endpoints

ACCENT_COUNT = 11           # accents spaced evenly around the hue wheel
ACCENT_START_HUE = 15.0     # OKLCH hue of the first accent, in degrees
ACCENT_LIGHTNESS = 0.76     # mean OKLCH L of the accents (0..1)
ACCENT_LIGHTNESS_SWING = 0.08 # L follows a cosine: +swing at PEAK_HUE, -swing opposite
ACCENT_LIGHTNESS_PEAK_HUE = 95.0 # hue where the accents are lightest (yellow)
ACCENT_CHROMA = 0.09        # OKLCH C shared by every accent

# ---------------------------------------------------------------------------
# Colour maths (sRGB <-> OKLab <-> OKLCH)
# ---------------------------------------------------------------------------
module Color
  module_function

  def srgb_to_linear(c)
    c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4
  end

  def linear_to_srgb(c)
    c <= 0.0031308 ? 12.92 * c : 1.055 * (c**(1 / 2.4)) - 0.055
  end

  def cbrt(x)
    x.negative? ? -((-x)**(1.0 / 3)) : x**(1.0 / 3)
  end

  # Returns [L, a, b] for an sRGB triple in 0..1.
  def rgb_to_oklab(r, g, b)
    r, g, b = [r, g, b].map { |c| srgb_to_linear(c) }
    l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
    m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
    s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
    [
      0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
      1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
      0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
    ]
  end

  # Returns an sRGB triple in 0..1, possibly outside that range.
  def oklab_to_rgb(lab_l, a, b)
    l = (lab_l + 0.3963377774 * a + 0.2158037573 * b)**3
    m = (lab_l - 0.1055613458 * a - 0.0638541728 * b)**3
    s = (lab_l - 0.0894841775 * a - 1.2914855480 * b)**3
    [
      4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
      -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
      -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    ].map { |c| linear_to_srgb(c) }
  end

  def oklch_to_rgb(l, c, h)
    rad = h * Math::PI / 180
    oklab_to_rgb(l, c * Math.cos(rad), c * Math.sin(rad))
  end

  def in_gamut?(rgb)
    rgb.all? { |c| c >= -1e-6 && c <= 1 + 1e-6 }
  end

  # Converts OKLCH to an in-gamut sRGB triple, reducing chroma if required so
  # that lightness and hue are preserved exactly.
  def oklch_to_srgb(l, c, h)
    rgb = oklch_to_rgb(l, c, h)
    unless in_gamut?(rgb)
      lo, hi = 0.0, c
      20.times do
        mid = (lo + hi) / 2
        if in_gamut?(oklch_to_rgb(l, mid, h)) then lo = mid else hi = mid end
      end
      rgb = oklch_to_rgb(l, lo, h)
    end
    rgb.map { |v| v.clamp(0.0, 1.0) }
  end

  def to_hex(rgb)
    format('#%02x%02x%02x', *rgb.map { |c| (c * 255).round })
  end

  def to_bytes(rgb)
    rgb.map { |c| (c * 255).round }
  end
end

# ---------------------------------------------------------------------------
# Palette generation
# ---------------------------------------------------------------------------
Swatch = Struct.new(:name, :rgb) do
  def hex = Color.to_hex(rgb)
end

# Black, then greys whose linear luminance grows geometrically from
# NEUTRAL_FLOOR_Y up to 1.0 (white). OKLab lightness is the cube root of
# luminance, so this is an even OKLCH ramp with a floor, slightly denser near black.
def neutral_lightness(i)
  return 0.0 if i.zero?
  steps = NEUTRAL_STEPS - 2
  ratio = (1 / NEUTRAL_FLOOR_Y)**(1.0 / steps)
  y = NEUTRAL_FLOOR_Y * ratio**(i - 1)
  l, = Color.rgb_to_oklab(*[y].cycle.first(3).map { |v| Color.linear_to_srgb(v) })
  l
end

def neutral_gradient
  Array.new(NEUTRAL_STEPS) do |i|
    l = neutral_lightness(i)
    chroma = NEUTRAL_TINT_CHROMA * Math.sin(Math::PI * l)
    rgb = Color.oklch_to_srgb(l, chroma, NEUTRAL_TINT_HUE)
    name = case i
           when 0 then 'black'
           when NEUTRAL_STEPS - 1 then 'white'
           else format('gray%d', i)
           end
    Swatch.new(format('%-6s L%.2f', name, l), rgb)
  end
end

# Approximate OKLCH hue angles of familiar colour names, for labelling.
HUE_NAMES = {
  'red' => 25.0, 'orange' => 55.0, 'yellow' => 85.0, 'lime' => 115.0,
  'green' => 145.0, 'teal' => 180.0, 'cyan' => 210.0, 'blue' => 245.0,
  'violet' => 275.0, 'purple' => 310.0, 'magenta' => 340.0
}.freeze

def hue_name(hue)
  name, = HUE_NAMES.min_by do |_, h|
    d = (hue - h).abs % 360
    [d, 360 - d].min
  end
  name
end

def accent_lightness(hue)
  rad = (hue - ACCENT_LIGHTNESS_PEAK_HUE) * Math::PI / 180
  ACCENT_LIGHTNESS + ACCENT_LIGHTNESS_SWING * Math.cos(rad)
end

def accents
  step = 360.0 / ACCENT_COUNT
  Array.new(ACCENT_COUNT) do |i|
    hue = (ACCENT_START_HUE + i * step) % 360
    l = accent_lightness(hue)
    rgb = Color.oklch_to_srgb(l, ACCENT_CHROMA, hue)
    Swatch.new(format('%-8s %3d° L%.2f', hue_name(hue), hue.round, l), rgb)
  end
end

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
def render(swatch)
  r, g, b = Color.to_bytes(swatch.rgb)
  l, = Color.rgb_to_oklab(*swatch.rgb)
  fg = l > 0.6 ? '0;0;0' : '255;255;255'
  "\e[48;2;#{r};#{g};#{b}m\e[38;2;#{fg}m #{swatch.hex} \e[0m #{swatch.name}"
end

if __FILE__ == $PROGRAM_NAME
  puts 'Neutral gradient'
  neutral_gradient.each { |s| puts render(s) }
  puts
  puts "Accents (L=#{ACCENT_LIGHTNESS}±#{ACCENT_LIGHTNESS_SWING} C=#{ACCENT_CHROMA})"
  accents.each { |s| puts render(s) }
end
