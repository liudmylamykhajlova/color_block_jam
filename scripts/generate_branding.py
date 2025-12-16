#!/usr/bin/env python3
"""
Generate branding assets for Color Block Jam app.

Usage:
    pip install Pillow
    python scripts/generate_branding.py
"""

import os
import sys
from pathlib import Path

# Fix encoding for Windows console
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("Installing Pillow...")
    os.system("pip install Pillow")
    from PIL import Image, ImageDraw, ImageFont

# Colors from the game
GRADIENT_TOP = (102, 126, 234)      # #667eea
GRADIENT_BOTTOM = (118, 75, 162)    # #764ba2
BLOCK_RED = (255, 68, 68)           # #FF4444
BLOCK_GREEN = (68, 255, 68)         # #44FF44
BLOCK_BLUE = (68, 68, 255)          # #4444FF
BLOCK_YELLOW = (255, 255, 68)       # #FFFF44
WHITE = (255, 255, 255)
DARK_BG = (26, 26, 46)              # #1a1a2e

# Project paths
PROJECT_ROOT = Path(__file__).parent.parent
BRANDING_DIR = PROJECT_ROOT / "assets" / "branding"


def create_gradient(size, color_top, color_bottom):
    """Create a vertical gradient image."""
    img = Image.new('RGB', size)
    for y in range(size[1]):
        ratio = y / size[1]
        r = int(color_top[0] * (1 - ratio) + color_bottom[0] * ratio)
        g = int(color_top[1] * (1 - ratio) + color_bottom[1] * ratio)
        b = int(color_top[2] * (1 - ratio) + color_bottom[2] * ratio)
        for x in range(size[0]):
            img.putpixel((x, y), (r, g, b))
    return img


def draw_block(draw, x, y, size, color, outline_color=(0, 0, 0)):
    """Draw a single LEGO-style block."""
    # Main block
    draw.rectangle([x, y, x + size, y + size], fill=color, outline=outline_color, width=2)
    
    # LEGO stud (circle in center)
    stud_radius = size // 5
    cx, cy = x + size // 2, y + size // 2
    stud_color = tuple(min(255, c + 30) for c in color)
    draw.ellipse([cx - stud_radius, cy - stud_radius, cx + stud_radius, cy + stud_radius], 
                 fill=stud_color, outline=outline_color, width=1)


def draw_l_shape(draw, cx, cy, block_size, color, gap=2):
    """Draw an L-shaped block figure."""
    # L shape: 
    # XX
    # X
    # X
    positions = [
        (0, 0), (1, 0),  # top row
        (0, 1),          # middle
        (0, 2),          # bottom
    ]
    
    for dx, dy in positions:
        x = cx + dx * (block_size + gap)
        y = cy + dy * (block_size + gap)
        draw_block(draw, x, y, block_size, color)


def create_app_icon(size=1024):
    """Create the main app icon."""
    # Create gradient background
    img = create_gradient((size, size), GRADIENT_TOP, GRADIENT_BOTTOM)
    draw = ImageDraw.Draw(img)
    
    # Add rounded corners effect (simulate by drawing on alpha)
    # For simplicity, we'll use a circle mask
    
    # Calculate block sizes
    margin = size // 8
    block_size = size // 7
    gap = size // 50
    
    # Draw multiple colored blocks in a pattern
    # Create a mini puzzle scene
    
    # Red L-shape (top-left area)
    draw_l_shape(draw, margin, margin, block_size, BLOCK_RED, gap)
    
    # Blue horizontal blocks (middle-right)
    bx = size // 2 + margin // 2
    by = size // 2 - block_size // 2
    for i in range(3):
        draw_block(draw, bx + i * (block_size + gap), by, block_size, BLOCK_BLUE)
    
    # Yellow square (bottom-right)
    yx = size - margin - 2 * block_size - gap
    yy = size - margin - 2 * block_size - gap
    for dy in range(2):
        for dx in range(2):
            draw_block(draw, yx + dx * (block_size + gap), yy + dy * (block_size + gap), 
                      block_size, BLOCK_YELLOW)
    
    # Green T-shape (bottom-left)
    gx = margin
    gy = size - margin - 2 * block_size - gap
    # T shape: XXX
    #           X
    draw_block(draw, gx, gy, block_size, BLOCK_GREEN)
    draw_block(draw, gx + block_size + gap, gy, block_size, BLOCK_GREEN)
    draw_block(draw, gx + 2 * (block_size + gap), gy, block_size, BLOCK_GREEN)
    draw_block(draw, gx + block_size + gap, gy + block_size + gap, block_size, BLOCK_GREEN)
    
    return img


def create_app_icon_foreground(size=1024):
    """Create adaptive icon foreground (blocks only, transparent bg)."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Centered blocks composition
    margin = size // 4
    block_size = size // 8
    gap = size // 60
    
    # Center offset
    cx = size // 2 - block_size * 2
    cy = size // 2 - block_size * 2
    
    # Draw a colorful 2x2 arrangement representing the game
    colors = [BLOCK_RED, BLOCK_BLUE, BLOCK_GREEN, BLOCK_YELLOW]
    positions = [(0, 0), (1, 0), (0, 1), (1, 1)]
    
    for (dx, dy), color in zip(positions, colors):
        x = cx + dx * (block_size * 2 + gap)
        y = cy + dy * (block_size * 2 + gap)
        draw_block(draw, x, y, block_size * 2, color)
    
    return img


def create_splash_logo(size=400):
    """Create splash screen logo."""
    # Wider format for splash
    width = size * 2
    height = size
    
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw blocks arrangement
    block_size = height // 4
    gap = block_size // 10
    
    # Center the blocks
    start_x = (width - 4 * block_size - 3 * gap) // 2
    start_y = height // 2 - block_size // 2
    
    colors = [BLOCK_RED, BLOCK_GREEN, BLOCK_BLUE, BLOCK_YELLOW]
    for i, color in enumerate(colors):
        x = start_x + i * (block_size + gap)
        draw_block(draw, x, start_y, block_size, color)
    
    return img


def create_splash_icon(size=288):
    """Create Android 12 splash icon."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Simple 2x2 blocks
    block_size = size // 3
    gap = block_size // 10
    
    cx = (size - 2 * block_size - gap) // 2
    cy = (size - 2 * block_size - gap) // 2
    
    colors = [BLOCK_RED, BLOCK_BLUE, BLOCK_GREEN, BLOCK_YELLOW]
    positions = [(0, 0), (1, 0), (0, 1), (1, 1)]
    
    for (dx, dy), color in zip(positions, colors):
        x = cx + dx * (block_size + gap)
        y = cy + dy * (block_size + gap)
        draw_block(draw, x, y, block_size, color)
    
    return img


def main():
    """Generate all branding assets."""
    print("🎨 Generating branding assets...")
    
    # Create branding directory
    BRANDING_DIR.mkdir(parents=True, exist_ok=True)
    
    # Generate app icon (1024x1024)
    print("  📱 Creating app icon...")
    icon = create_app_icon(1024)
    icon.save(BRANDING_DIR / "app_icon.png", "PNG")
    print(f"     ✅ Saved: {BRANDING_DIR / 'app_icon.png'}")
    
    # Generate adaptive icon foreground
    print("  📱 Creating adaptive icon foreground...")
    foreground = create_app_icon_foreground(1024)
    foreground.save(BRANDING_DIR / "app_icon_foreground.png", "PNG")
    print(f"     ✅ Saved: {BRANDING_DIR / 'app_icon_foreground.png'}")
    
    # Generate splash logo
    print("  💦 Creating splash logo...")
    splash = create_splash_logo(400)
    splash.save(BRANDING_DIR / "splash_logo.png", "PNG")
    print(f"     ✅ Saved: {BRANDING_DIR / 'splash_logo.png'}")
    
    # Generate splash icon (Android 12)
    print("  💦 Creating splash icon (Android 12)...")
    splash_icon = create_splash_icon(288)
    splash_icon.save(BRANDING_DIR / "splash_icon.png", "PNG")
    print(f"     ✅ Saved: {BRANDING_DIR / 'splash_icon.png'}")
    
    print("\n✨ All branding assets generated!")
    print("\nNext steps:")
    print("  1. Run: flutter pub get")
    print("  2. Run: dart run flutter_launcher_icons")
    print("  3. Run: dart run flutter_native_splash:create")


if __name__ == "__main__":
    main()

