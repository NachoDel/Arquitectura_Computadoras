import serial
import time

# Operaciones disponibles en la ALU
OPERATIONS = {
    '1': {'name': 'ADD', 'opcode': 0x20, 'symbol': '+'},
    '2': {'name': 'SUB', 'opcode': 0x22, 'symbol': '-'},
    '3': {'name': 'AND', 'opcode': 0x24, 'symbol': '&'},
    '4': {'name': 'OR', 'opcode': 0x25, 'symbol': '|'},
    '5': {'name': 'XOR', 'opcode': 0x26, 'symbol': '^'},
    '6': {'name': 'SRA', 'opcode': 0x03, 'symbol': '>>'},
    '7': {'name': 'SRL', 'opcode': 0x02, 'symbol': '>>>'},
    '8': {'name': 'NOR', 'opcode': 0x27, 'symbol': 'NOR'},
}

def print_menu():
    """Muestra el menú de operaciones disponibles"""
    print("\n" + "="*50)
    print("ALU SERIAL - Operaciones Disponibles")
    print("="*50)
    for key, op in OPERATIONS.items():
        print(f"{key}. {op['name']:6s} ({op['symbol']})")
    print("0. Salir")
    print("="*50)

def get_operand(name):
    """Solicita un operando al usuario"""
    while True:
        try:
            value = input(f"Ingrese {name} (0-255 o hex 0x00-0xFF): ").strip()
            if value.lower().startswith('0x'):
                num = int(value, 16)
            else:
                num = int(value)
            
            if 0 <= num <= 255:
                return num
            else:
                print("Error: El valor debe estar entre 0 y 255")
        except ValueError:
            print("Error: Ingrese un número válido")

def send_and_receive(ser, a, b, opcode):
    """Envía los operandos y opcode, y recibe la respuesta"""
    # Limpiar buffers y enviar
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    ser.write(bytes([a, b, opcode]))
    ser.flush()
    
    time.sleep(0.01)
    
    # Lectura
    resp = bytearray()
    start = time.time()
    deadline = start + 2.0
    last_rx = start
    idle_timeout = 0.06
    
    while time.time() < deadline:
        n_avail = ser.in_waiting
        if n_avail:
            chunk = ser.read(n_avail)
        else:
            chunk = ser.read(1)
        
        now = time.time()
        if chunk:
            resp.extend(chunk)
            last_rx = now
            if len(resp) >= 2:
                break
        else:
            if resp and (now - last_rx) > idle_timeout:
                break
            time.sleep(0.005)
    
    return resp

def display_result(a, b, op_info, resp):
    """Muestra los resultados de la operación"""
    print("\n" + "-"*50)
    print(f"Operación: {a} (0x{a:02X}) {op_info['symbol']} {b} (0x{b:02X})")
    print("-"*50)
    
    res = resp[0] if len(resp) >= 1 else None
    flags = resp[1] if len(resp) >= 2 else None
    
    if res is not None:
        print(f"Resultado: {res} (0x{res:02X}) [binario: {res:08b}]")
    else:
        print("Resultado: No recibido")
    
    if flags is not None:
        carry = (flags >> 1) & 1
        zero = flags & 1
        print(f"Flags: 0x{flags:02X}")
        print(f"  - Carry/Borrow: {carry}")
        print(f"  - Zero:  {zero}")
        if carry and op_info['name'] == 'SUB':
            # Si la operacion era una resta y el carry está activo, indica borrow por lo que debemos mostrar el resultado como negativo
            print()
            print("Nota: Resultado negativo (underflow en resta)")
            res = (~res & 0xFF) + 0x01  # complemento a dos
            print(f"  - Resultado correcto: -{res} (0x{res:02X}) [binario: {res:08b}]") 
    else:
        print("Flags: No recibidas")
    
    print("-"*50)

def main():
    """Función principal del programa"""
    try:
        # Configuración del puerto serial
        PORT = 'COM8'
        BAUDRATE = 9600
        
        print(f"\nConectando a {PORT} a {BAUDRATE} baud...")
        ser = serial.Serial(PORT, BAUDRATE, timeout=0.05)
        time.sleep(0.05)
        print("Conexión establecida ✓")
        
        while True:
            print_menu()
            choice = input("\nSeleccione una operación: ").strip()
            
            if choice == '0':
                print("\n¡Hasta luego!")
                break
            
            if choice not in OPERATIONS:
                print("\nOpción inválida. Intente nuevamente.")
                continue
            
            op_info = OPERATIONS[choice]
            
            # Obtener operandos
            print(f"\n--- Operación: {op_info['name']} ---")
            a = get_operand("operando A")
            b = get_operand("operando B")
            
            # Enviar y recibir
            print("\nEnviando datos...")
            resp = send_and_receive(ser, a, b, op_info['opcode'])
            
            # Mostrar resultados
            display_result(a, b, op_info, resp)
            
            # Preguntar si continuar
            continuar = input("\n¿Realizar otra operación? (s/n): ").strip().lower()
            if continuar != 's':
                print("\n¡Hasta luego!")
                break
        
        ser.close()
        print("Puerto serial cerrado.")
        
    except serial.SerialException as e:
        print(f"\nError al abrir el puerto serial: {e}")
    except KeyboardInterrupt:
        print("\n\nPrograma interrumpido por el usuario.")
    except Exception as e:
        print(f"\nError inesperado: {e}")

if __name__ == "__main__":
    main()