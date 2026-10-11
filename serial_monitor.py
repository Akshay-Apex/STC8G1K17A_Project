import serial
import threading
import time
import sys

# --- CONFIGURATION ---
SERIAL_PORT = 'COM3'     # Change to your actual port (e.g., '/dev/ttyUSB0' on Linux)
BAUD_RATE = 115200       # Match this to your STC chip's baud rate
# ---------------------

def read_from_mcu(ser):
    """
    Background thread that continuously monitors incoming data from the STC chip
    and calculates the exact time interval between arrivals.
    """
    last_arrival_time = None
    print("\n[LISTENER] Monitoring incoming bytes... (Press Ctrl+C to exit)\n")
    
    while True:
        try:
            # Read exactly 1 byte. This blocks until data actually arrives.
            data = ser.read(1)
            
            if data:
                # Capture the highest-precision system timestamp immediately upon byte arrival
                current_time = time.perf_counter()
                
                if last_arrival_time is not None:
                    # Calculate elapsed time in seconds, then convert to milliseconds
                    elapsed_ms = (current_time - last_arrival_time) * 1000
                    print(f"[RECV] Byte 0x{data.hex().upper()} arrived. Interval since last: {elapsed_ms:.4f} ms")
                else:
                    print(f"[RECV] First byte 0x{data.hex().upper()} received. Timing started...")
                
                last_arrival_time = current_time
                
        except serial.SerialException as e:
            print(f"\n[ERROR] Serial read error: {e}")
            break

def main():
    try:
        # Open the serial port with a clean buffer
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=None) # No timeout = permanent block until data arrives
        ser.reset_input_buffer()
        ser.reset_output_buffer()
    except Exception as e:
        print(f"[FATAL] Could not open serial port {SERIAL_PORT}: {e}")
        sys.exit(1)

    # Start the high-precision reading function in a separate background thread
    # This prevents the terminal input prompt from freezing the time measurements
    listener_thread = threading.Thread(target=read_from_mcu, args=(ser,), daemon=True)
    listener_thread.start()

    # Main thread handles sending data back to the STC chip
    print("-----------------------------------------------------------------")
    print(" Instructions:")
    print(" 1. The script will automatically print the time intervals below.")
    print(" 2. Type your new software variable/constant and press Enter to send.")
    print("-----------------------------------------------------------------")
    
    while True:
        try:
            # Wait for user to type something in the PC terminal
            user_input = input("")
            if user_input.strip():
                # Append a newline (\n) so your STC C-code knows the string has ended
                payload = user_input.strip() + "\n"
                ser.write(payload.encode('utf-8'))
                print(f" -> [SENT] Sent '{user_input.strip()}' back to STC chip.")
        except (KeyboardInterrupt, SystemExit):
            print("\nExiting script...")
            ser.close()
            break

if __name__ == "__main__":
    main()
