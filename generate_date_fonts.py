import os
from PIL import Image, ImageDraw, ImageFont

font_path = "node_modules/dseg/fonts/DSEG14-Classic/DSEG14Classic-Light.ttf"

def generate_font(name, filename_prefix, size, chars, font_path, stretch_h_ratio=1.0):
    font = ImageFont.truetype(font_path, size)
    
    char_info = {}
    
    min_left = 999
    min_top = 999
    max_right = 0
    max_bottom = 0
    
    for c in chars:
        char_img = Image.new("RGBA", (size*2, size*2), (0,0,0,0))
        char_draw = ImageDraw.Draw(char_img)
        char_draw.text((10, 10), c, font=font, fill=(255,255,255,255))
        c_bbox = char_img.getbbox()
        if c_bbox:
            if c_bbox[0] < min_left: min_left = c_bbox[0]
            if c_bbox[1] < min_top: min_top = c_bbox[1]
            if c_bbox[2] > max_right: max_right = c_bbox[2]
            if c_bbox[3] > max_bottom: max_bottom = c_bbox[3]
            
        advance = int(font.getlength(c))
        char_info[c] = {'advance': advance}

    min_left = max(0, min_left - 2)
    min_top = max(0, min_top - 2)
    max_right = min(size*2, max_right + 2)
    max_bottom = min(size*2, max_bottom + 2)
    
    global_bbox = (min_left, min_top, max_right, max_bottom)
    global_width = max_right - min_left
    global_height = max_bottom - min_top
    
    if global_height <= 0: global_height = size

    # Apply height stretch ratio
    stretch_global_h = int(global_height * stretch_h_ratio)

    total_width = (global_width + 2) * len(chars)

    img_width = total_width + 10
    img_height = stretch_global_h + 4
    img = Image.new("RGBA", (img_width, img_height), (0,0,0,0))
    draw = ImageDraw.Draw(img)

    fnt_content = []
    fnt_content.append(f'info face="{name}" size={size} bold=0 italic=0 charset="" unicode=1 stretchH={int(100/stretch_h_ratio)} smooth=1 aa=1 padding=0,0,0,0 spacing=1,1 outline=0')
    fnt_content.append(f'common lineHeight={stretch_global_h} base={stretch_global_h} scaleW={img_width} scaleH={img_height} pages=1 packed=0 alphaChnl=0 redChnl=0 greenChnl=0 blueChnl=0')
    fnt_content.append(f'page id=0 file="{filename_prefix}_0.png"')
    fnt_content.append(f'chars count={len(chars)}')

    x_current = 1
    for c in chars:
        info = char_info[c]
        char_img = Image.new("RGBA", (size*2, size*2), (0,0,0,0))
        char_draw = ImageDraw.Draw(char_img)
        char_draw.text((10, 10), c, font=font, fill=(255,255,255,255))
        c_bbox = char_img.getbbox()
        
        if c_bbox:
            # Use character's actual width, but global height for baseline
            char_left = max(0, c_bbox[0] - 2)
            char_right = min(size*2, c_bbox[2] + 2)
            
            crop_box = (char_left, min_top, char_right, max_bottom)
            cropped = char_img.crop(crop_box)
            
            c_w = char_right - char_left
            
            stretch_w = c_w
            if stretch_h_ratio != 1.0 and c_w > 0 and stretch_global_h > 0:
                cropped = cropped.resize((c_w, stretch_global_h), Image.Resampling.LANCZOS)
            
            y_offset = 2
            x_offset = 2 
            
            img.paste(cropped, (x_current, y_offset))
            
            advance = stretch_w + 6 # Proportional advance with wider gap
            
            fnt_content.append(f'char id={ord(c)} x={x_current} y={y_offset} width={stretch_w} height={stretch_global_h} xoffset={x_offset} yoffset={y_offset} xadvance={advance} page=0 chnl=15')
            x_current += stretch_w + 2
        else:
            fnt_content.append(f'char id={ord(c)} x=0 y=0 width=0 height=0 xoffset=0 yoffset=0 xadvance={info["advance"]+2} page=0 chnl=15')

    img.save(f"resources/fonts/{filename_prefix}_0.png")
    with open(f"resources/fonts/{filename_prefix}.fnt", "w") as f:
        f.write("\n".join(fnt_content) + "\n")
    print(f"Generated {name}")

bold_font_path = "node_modules/dseg/fonts/DSEG14-Classic/DSEG14Classic-Regular.ttf"
light_font_path = "Rajdhani-Light.ttf"

# Generate Date Number Font (Larger and Regular, stretched vertically to be slightly shorter)
generate_font("DateNumberFont", "date_number", 40, "0123456789 ", bold_font_path, stretch_h_ratio=0.85)

# Generate Date Text Font (Smaller and Light, no stretch)
generate_font("DateTextFont", "date_text", 24, "ABCDEFGHIJKLMNOPQRSTUVWXYZ ", light_font_path)
