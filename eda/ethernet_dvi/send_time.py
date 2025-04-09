import socket
import time
import datetime
import struct

def decimal_to_bcd_swapped(decimal):
    """
    10進数を2桁のBCDに変換し、4bitずつ入れ替える
    例: 23 -> 通常のBCD: 0x23 -> 入れ替え後: 0x32
    """
    tens = decimal // 10
    units = decimal % 10
    # 1の位を上位4bit、10の位を下位4bitに配置
    return (units << 4) | tens

def create_special_format(hour_bcd, minute_bcd, second_bcd):
    """
    時間(最下位バイト)、分、秒(最上位バイト)の順に並べ、
    時間と分、分と秒の間にそれぞれ4bitの値0xAを挿入する
    """
    # 最終的なフォーマット: [秒][A][分][A][時間]
    # それぞれの間に0xAを挿入する
    
    # 秒の上位4bitと下位4bit
    second_high = (second_bcd & 0xF0) >> 4
    second_low = second_bcd & 0x0F
    
    # 分の上位4bitと下位4bit
    minute_high = (minute_bcd & 0xF0) >> 4
    minute_low = minute_bcd & 0x0F
    
    # 時間の上位4bitと下位4bit
    hour_high = (hour_bcd & 0xF0) >> 4
    hour_low = hour_bcd & 0x0F
    
    # 32bitに詰める (ビッグエンディアン形式)
    # [秒の上位4bit][秒の下位4bit][0xA][分の上位4bit][分の下位4bit][0xA][時間の上位4bit][時間の下位4bit]
    byte1 = (second_high << 4) | second_low
    byte2 = (0xA << 4) | minute_high
    byte3 = (minute_low << 4) | 0xA
    byte4 = (hour_high << 4) | hour_low
    
    return byte1, byte2, byte3, byte4

def main():
    # UDP送信先の設定
    UDP_IP = "192.168.10.2"
    UDP_PORT = 10000
    
    # UDPソケットの作成
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    try:
        # 現在の時刻を取得
        now = datetime.datetime.now()
        hour = now.hour
        minute = now.minute
        second = now.second
        
        print(f"現在時刻: {hour:02d}:{minute:02d}:{second:02d}")
        
        # 時、分、秒をBCDに変換し、4bitずつ入れ替え
        bcd_hour = decimal_to_bcd_swapped(hour)
        bcd_minute = decimal_to_bcd_swapped(minute)
        bcd_second = decimal_to_bcd_swapped(second)
        
        print(f"BCD変換後 (桁入替): 時=0x{bcd_hour:02X}, 分=0x{bcd_minute:02X}, 秒=0x{bcd_second:02X}")
        
        # 特殊フォーマットに変換
        byte1, byte2, byte3, byte4 = create_special_format(bcd_hour, bcd_minute, bcd_second)
        
        # ビッグエンディアンでパック（秒が最上位バイト、時間が最下位バイト）
        data = struct.pack(">BBBB", byte1, byte2, byte3, byte4)
        
        # フォーマット確認用
        format_hex = f"{byte1:02X} {byte2:02X} {byte3:02X} {byte4:02X}"
        print(f"フォーマット後 (HEX): {format_hex}")
        print(f"フォーマット: [秒][0xA][分][0xA][時間]")
        
        # UDP送信
        sock.sendto(data, (UDP_IP, UDP_PORT))
        print(f"データを {UDP_IP}:{UDP_PORT} に送信しました")
        
    finally:
        sock.close()

if __name__ == "__main__":
    main()