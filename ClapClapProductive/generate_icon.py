#!/usr/bin/env python3
"""
Generate app icon with clapping hands emoji for ClapClapProductive
"""

from PIL import Image, ImageDraw, ImageFont
import os
import json

# Icon sizes needed for macOS
ICON_SIZES = [
    16, 32, 64, 128, 256, 512, 1024
]

def create_icon(size, emoji="👏"):
    """Create an icon with the clapping hands emoji"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)

    # Draw background circle with gradient effect
    # Use a nice blue gradient
    for i in range(size):
        alpha = int(255 * (1 - i / size))
        color = (66, 133, 244, alpha)
        draw.ellipse([i, i, size-i, size-i], fill=color)

    # Draw solid background
    margin = int(size * 0.05)
    bg_color = (66, 133, 244, 255)  # Nice blue color
    draw.ellipse([margin, margin, size-margin, size-margin], fill=bg_color)

    # Try to draw emoji (this might not work on all systems)
    # If emoji rendering fails, we'll create a simple text-based icon
    try:
        # Try to use system font with emoji support
        font_size = int(size * 0.6)
        # Try different font paths for macOS
        font_paths = [
            "/System/Library/Fonts/Apple Color Emoji.ttc",
            "/Library/Fonts/Arial Unicode.ttf",
        ]

        font = None
        for font_path in font_paths:
            if os.path.exists(font_path):
                try:
                    font = ImageFont.truetype(font_path, font_size)
                    break
                except:
                    continue

        if font is None:
            font = ImageFont.load_default()

        # Get text bounding box
        bbox = draw.textbbox((0, 0), emoji, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]

        # Center the emoji
        x = (size - text_width) // 2 - bbox[0]
        y = (size - text_height) // 2 - bbox[1]

        draw.text((x, y), emoji, font=font, embedded_color=True)
    except Exception as e:
        print(f"Could not render emoji: {e}")
        # Fallback: draw "CLAP" text
        try:
            font_size = int(size * 0.2)
            font = ImageFont.load_default()
            text = "CLAP"
            bbox = draw.textbbox((0, 0), text, font=font)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
            x = (size - text_width) // 2
            y = (size - text_height) // 2
            draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
        except:
            pass

    return img

def main():
    # Create output directory
    output_dir = "ClapClapProductive/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(output_dir, exist_ok=True)

    # Generate icons for all sizes
    images_data = []

    for size in ICON_SIZES:
        # 1x version
        img = create_icon(size)
        filename = f"icon_{size}x{size}.png"
        img.save(os.path.join(output_dir, filename))
        print(f"Generated {filename}")

        images_data.append({
            "size": f"{size}x{size}",
            "idiom": "mac",
            "filename": filename,
            "scale": "1x"
        })

        # 2x version (except for 1024)
        if size < 1024:
            img_2x = create_icon(size * 2)
            filename_2x = f"icon_{size}x{size}@2x.png"
            img_2x.save(os.path.join(output_dir, filename_2x))
            print(f"Generated {filename_2x}")

            images_data.append({
                "size": f"{size}x{size}",
                "idiom": "mac",
                "filename": filename_2x,
                "scale": "2x"
            })

    # Create Contents.json
    contents = {
        "images": images_data,
        "info": {
            "version": 1,
            "author": "xcode"
        }
    }

    with open(os.path.join(output_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

    print("\n✅ App icons generated successfully!")
    print(f"📁 Location: {output_dir}")

if __name__ == "__main__":
    main()
