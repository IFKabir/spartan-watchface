import os
from PIL import Image, ImageDraw, ImageFont

font_path = "node_modules/dseg/fonts/DSEG14-Classic/DSEG14Classic-Light.ttf"

def generate_font(name, filename_prefix, size, chars):
    font = ImageFont.truetype(font_path, size)
    
    char_info = {}
    max_height = 0
    total_width = 0

    for c in chars:
        bbox = font.getbbox(c)
        if bbox:
            left, top, right, bottom = bbox
            width = right - left
            height = bottom - top
        else:
            width = 0
            height = 0
            
        advance = int(font.getlength(c))
        char_info[c] = {
            'bbox': bbox,
            'width': width,
            'height': height,
            'advance': advance
        }
        total_width += width + 2
        if height > max_height:
            max_height = height

    img_width = total_width + 10
    img_height = max_height + 4
    img = Image.new("RGBA", (img_width, img_height), (0,0,0,0))
    draw = ImageDraw.Draw(img)

    fnt_content = []
    fnt_content.append(f'info face="{name}" size={size} bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1 outline=0')
    fnt_content.append(f'common lineHeight={max_height} base={max_height} scaleW={img_width} scaleH={img_height} pages=1 packed=0 alphaChnl=0 redChnl=0 greenChnl=0 blueChnl=0')
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
            c_left, c_top, c_right, c_bottom = c_bbox
            c_w = c_right - c_left
            c_h = c_bottom - c_top
            
            cropped = char_img.crop(c_bbox)
            
            y_offset = int((img_height - c_h) / 2)
            x_offset = 0
            
            img.paste(cropped, (x_current, y_offset))
            
            advance = info['advance'] + 2 # slight spacing
            
            fnt_content.append(f'char id={ord(c)} x={x_current} y={y_offset} width={c_w} height={c_h} xoffset={x_offset} yoffset={y_offset} xadvance={advance} page=0 chnl=15')
            x_current += c_w + 2
        else:
            fnt_content.append(f'char id={ord(c)} x=0 y=0 width=0 height=0 xoffset=0 yoffset=0 xadvance={info["advance"]+2} page=0 chnl=15')

    img.save(f"resources/fonts/{filename_prefix}_0.png")
    with open(f"resources/fonts/{filename_prefix}.fnt", "w") as f:
        f.write("\n".join(fnt_content) + "\n")
    print(f"Generated {name}")

# Generate Date Number Font (Larger)
generate_font("DateNumberFont", "date_number", 40, "0123456789 ")

# Generate Date Text Font (Smaller)
generate_font("DateTextFont", "date_text", 30, "ABCDEFGHIJKLMNOPQRSTUVWXYZ ")
