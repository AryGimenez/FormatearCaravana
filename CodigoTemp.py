import csv
from datetime import datetime, timedelta

def process_csv(input_csv_path, output_txt_path, guia, fecha, new_time=None):
    """
    Método para procesar el archivo CSV y convertirlo del formato entregado por el lector Tru-Test
    al formato deseado para el archivo TXT aceptado por SNIG.

    Parámetros:
    input_csv_path (str): Ruta al archivo CSV de entrada.
    output_txt_path (str): Ruta al archivo TXT de salida.
    guia (str): Código de la guía a incluir en el archivo TXT.
    fecha (str): Fecha a incluir en el formato 'DDMMYYYY'.
    new_time (str, opcional): Hora inicial en formato 'HHMMSS'. Si no se proporciona, se usará la hora del CSV.
    """

    def format_time(time_str):
        """Elimina los dos puntos de la hora para el formato deseado."""
        return time_str.replace(':', '')

    def parse_time_to_seconds(time_str):
        """Convierte una hora en formato 'HH:MM:SS' a segundos desde medianoche."""
        t = datetime.strptime(time_str, '%H:%M:%S')
        return t.hour * 3600 + t.minute * 60 + t.second

    def seconds_to_time_str(seconds):
        """Convierte segundos desde medianoche a una cadena de hora en formato 'HHMMSS'."""
        t = timedelta(seconds=seconds)
        return (datetime.min + t).strftime('%H%M%S')

    with open(input_csv_path, newline='') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # Saltar la primera línea (cabecera)
        
        rows = list(reader)  # Leer todas las filas y convertirlas a una lista
        times = [parse_time_to_seconds(row[3]) for row in rows]

        with open(output_txt_path, 'w') as txtfile:
            previous_time = None
            if new_time:
                previous_time = parse_time_to_seconds(new_time)
            else:
                previous_time = times[0]
            
            for i, row in enumerate(rows):
                caravana = row[0]
                if i == 0 and new_time:
                    current_time = parse_time_to_seconds(new_time)
                else:
                    current_time = previous_time + (times[i] - times[i - 1])
                formatted_time = seconds_to_time_str(current_time)

                formatted_line = f"[|A{caravana}|{fecha}|{formatted_time}|{guia}|]"
                txtfile.write(formatted_line + '\n')
                previous_time = current_time

# Uso de la función
input_csv_path = 'Tru-Test_2024-07-02_Session_1719919389.csv'  # Ruta relativa al archivo CSV
output_txt_path = 'output.txt'  # Ruta relativa donde quieres guardar el archivo TXT
guia = 'C204416'  # Código de la guía
fecha = '06122023'  # Fecha en formato 'DDMMYYYY'
new_time = '131000'  # Hora inicial en formato 'HHMMSS', puede ser None

process_csv(input_csv_path, output_txt_path, guia, fecha, new_time)
