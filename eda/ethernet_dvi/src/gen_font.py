from PIL import Image, ImageDraw, ImageFont
import numpy as np
import os

def create_digit_image():
    # パラメータ設定
    digit_size = 64  # 各文字のサイズ（64x64ピクセル）
    num_chars = 11  # 0から9までの10個の数字とコロン
    width = digit_size * num_chars
    height = digit_size
    
    # 透過背景の画像を作成（RGBAモードを使用）
    image = Image.new('RGBA', (width, height), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # フォントの設定（システムにインストールされているフォントを使用）
    # フォントサイズは文字が64x64のセル内に適切に収まるように調整
    font_size = 80
    try:
        # Windowsの場合
        font = ImageFont.truetype("arial.ttf", font_size)
    except IOError:
        try:
            # Macの場合
            font = ImageFont.truetype("Arial.ttf", font_size)
        except IOError:
            try:
                # Linuxの場合
                font = ImageFont.truetype("DejaVuSans.ttf", font_size)
            except IOError:
                # どのフォントも見つからない場合はデフォルトフォントを使用
                font = ImageFont.load_default()
                print("指定したフォントが見つかりませんでした。デフォルトフォントを使用します。")
    
    # 各数字とコロンをその位置に描画
    for i in range(11):
        if i < 10:
            char = str(i)  # 0-9の数字
        else:
            char = ":"  # コロン
            
        # 文字の描画位置を計算（中央揃え）
        text_width = draw.textlength(char, font=font)
        x = i * digit_size + (digit_size - text_width) / 2
        y = (digit_size - font_size) / 2 - 6  # フォントサイズを考慮して垂直位置を調整
        
        # 黒い文字で描画
        draw.text((x, y), char, fill='black', font=font)
    
    # 画像を保存
    image.save('digits_0_to_9.png')
    print("透過背景の画像が正常に生成されました: digits_0_to_9.png")
    
    return 'digits_0_to_9.png'

if __name__ == "__main__":
    create_digit_image()