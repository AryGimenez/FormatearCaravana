import csv

# Importar la clase datetime para trabajar con fechas y horas
from datetime import datetime



# [|A0000000858000047085263|06122023|174306|C204416|]

def process_csv(pInput_csv_path, pOutput_txt_path, pGuia, pfecha, pHora):
    """
    Método para procesar el archivo CSV y convertirlo del formato entregado por el lector Tru-Test 
    al formato deseado para el archivo TXT aceptado por SNIG.

    Parámetros:
    input_csv_path (str): Ruta al archivo CSV de entrada.
    output_txt_path (str): Ruta al archivo TXT de salida.
    guia (str): Código de la guía a incluir en el archivo TXT.
    fecha (str): Fecha a incluir en el formato 'DDMMYYYY'.
    hora (str): Hora a incluir en el formato 'HHMMSS'.
    new_date (str, opcional): Fecha en formato 'YYYY-MM-DD'. Si no se proporciona, se usará la fecha actual.
    new_time (str, opcional): Hora en formato 'HH:MM:SS'. Si no se proporciona, se usará la hora actual.
    """

    
    def format_time(time_str): 
        """Se utiliza para retirar los : de la hora optenida del archivo CSV"""
        return time_str.replace(':', '')
    
    def parse_time_to_seconds(time_str):
        """Convierte una hora en formato 'HH:MM:SS' a segundos desde medianoche."""
        t = datetime.strptime(time_str, '%H:%M:%S')
        return t.hour * 3600 + t.minute * 60 + t.second
    
    def seconds_to_time_str(seconds):
        """Convierte segundos desde medianoche a una cadena de hora en formato 'HHMMSS'."""
        t = timedelta(seconds=seconds)
        return (datetime.min + t).strftime('%H%M%S')  
    
     
    

    xIs_primero = True  # Variable para verificar si es la primera línea del CSV sin contar el titulo
    
    # Leer el archivo CSV
    with open(input_csv_path, newline='') as csvfile:
        reader = csv.reader(csvfile) # Crear un objeto lector de CSV``
        next(reader)  # Saltar la primera línea (cabecera)
        
        with open(output_txt_path, 'w') as txtfile: # Crear un archivo TXT para escribir

            for row in reader: # Recorrer cada fila del archivo CSV
                # Asignar valores de las columnas a variables
                
                xCaravana = row[0]
                xHora = format_time(row[3]) # Entrega la hora sin los 


                # Datos que no uso porque lo paso por parametro
                # fecha = row[2]
                # guia = row[4]

                # Verificar si es la primera línea
                if xIs_primero:
                    xHora = pHora
                    xIs_primero = False
                else:


                # Imprimir valores para verificar
                print(f"[|A0000000{caravana}|{fecha}|{hora}|{guia}|]")


# Uso de la función
input_csv_path = 'Tru-Test_2024-07-02_Session_1719919389.csv'  # Ruta relativa al archivo CSV
output_txt_path = 'output.txt'  # Ruta relativa donde quieres guardar el archivo TXT
guia = 'C204416'  # Código de la guía
fecha = '06122023'  # Fecha en formato 'DDMMYYYY'
hora = '174306'  # Hora en formato 'HHMMSS'
new_date = '03072024'  # Fecha deseada
new_time = '11:23:09'  # Hora deseada

process_csv(input_csv_path, output_txt_path, guia, fecha, hora, new_date, new_time)