from kivymd.app import MDApp
from kivymd.uix.screen import Screen
from kivymd.uix.datatables import MDDataTable
from kivy.uix.button import Button
from kivy.uix.boxlayout import BoxLayout
from kivymd.uix.textfield import MDTextField
from datetime import datetime
from datetime import time
import csv


class DemoApp(MDApp):
    mCaravanas = []
    mFechLectura = datetime.now()
    mUltimaHora = time(12, 30, 0)

    def build(self):
        screen = Screen()

        data = self.load_data_from_csv("/home/ary/Descargas/datos.csv")

        data_table = MDDataTable(
            pos_hint={"center_x": 0.5, "top": 0.98},
            size_hint=(0.98, 0.6),
            check=True,
            rows_num=10,
            column_data=[("Caravana", 40), ("Fecha", 20), ("Hora", 20), ("Gia", 20)],
            row_data=data,
        )

        data_table.bind(on_row_press=self.on_row_press)
        data_table.bind(on_check_press=self.on_check_press)
        screen.add_widget(data_table)

        button_layout = BoxLayout(
            orientation="vertical", size_hint=(1, 0.32), padding=(20, 20, 20, 10)
        )






        # Agregar Caravana -----------------

        add_layout = BoxLayout(orientation="horizontal")

        btn_add = Button(text="Agregar Caravana")
        btn_add.bind(on_release=self.btn_add_release)

        TxtF_Caravana = MDTextField(
            input_filter="int",  # Permite solo números enteros
            hint_text="Ingrese un número",
            helper_text="Solo se permiten números",
            helper_text_mode="on_error",
            icon_right="numeric",
        )

        add_layout.add_widget(btn_add)
        add_layout.add_widget(TxtF_Caravana)

        button_layout.add_widget(add_layout) # Agrega los Widget para Agregar Caravana 




        # Modificar Fecha -----------------

        modFecha_layout = BoxLayout(orientation="horizontal")

        btn_modFecha = Button(text="Modificar Fecha")
        btn_modFecha.bind(on_release=self.btn_modFecha_release)

        fecha_actual = datetime.now().strftime("%Y-%m-%d")  # Formato: AAAA-MM-DD

        self.TxtF_Fecha = MDTextField(
            text=fecha_actual,  # Asignar la fecha actual al campo
            hint_text="Ingrese una fecha",
            helper_text="Formato: AAAA-MM-DD",
            helper_text_mode="persistent",
            icon_right="calendar",
            required=True,  # Requerir que se ingrese un valor
        )

        self.TxtF_Fecha.bind(text=self.on_text_validate)  # Vincular evento de validación
        modFecha_layout.add_widget(btn_modFecha)
        modFecha_layout.add_widget(self.TxtF_Fecha)      
   
        button_layout.add_widget(modFecha_layout) # Agrega los Widget para Modificar Fecha





        # Modificar Hora -----------------

        modHor_layout = BoxLayout(orientation="horizontal")

        btn_modHora = Button(text="Modificar Hora")
        # btn_modHora.bind(on_release=self.btn_modHora_release)

        Hora_actual = datetime.now().strftime("%Y-%m-%d")  # Formato: AAAA-MM-DD

        self.TxtF_Hora = MDTextField(
            text=Hora_actual,  # Asignar la Hora actual al campo
            hint_text="Ingrese una Hora",
            helper_text="Formato: AAAA-MM-DD",
            helper_text_mode="persistent",
            icon_right="calendar",
            required=True,  # Requerir que se ingrese un valor
        )

        self.TxtF_Hora.bind(text=self.on_text_validate)  # Vincular evento de validación
        modHor_layout.add_widget(btn_modHora)
        modHor_layout.add_widget(self.TxtF_Hora)      
   
        button_layout.add_widget(modHor_layout) # Agrega los Widget para Modificar Hora





        
        # Boton Eliminar Caravana --------------------------------

        btn_remove = Button(text="Eliminar Caravana")

        button_layout.add_widget(btn_remove)
        

        screen.add_widget(button_layout) # Agrega todo los Widget juntos en un Loyout

        return screen

    def load_data_from_csv(self, filename):
        data = []

        with open(filename, "r") as file:
            reader = csv.reader(file)
            next(reader)  # Saltar la primera fila si contiene encabezados

            for row in reader:
                mFechLectura = datetime.strptime(row[2], "%Y-%m-%d")
                mUltimaHora = datetime.strptime(row[3], "%H:%M:%S").time()
                data2 = [row[0], row[2], mUltimaHora, row[4]]

                data.append(data2)

        return data

    def on_text_validate(self, instance, text):
        try:
            datetime.strptime(text, "%Y-%m-%d")  # Intentar convertir la fecha
            self.TxtF_Fecha.error = False  # No hay error, se muestra el mensaje de ayuda
        except ValueError:
            self.TxtF_Fecha.error = True  # Error, se muestra el mensaje de error


    def on_row_press(self, instance_table, instance_row):
        print(instance_table, instance_row)

    def on_check_press(self, instance_table, current_row):
        print(instance_table, current_row)

    def btn_add_release(self, instance):
        print("Botón 1 presionado")

    # Modifica fecha de la lectura
    def btn_modFecha_release(self, instance):
        print("Botón 1 presionado")


    # Modifica Hora de la lectura
    def btn_modHora_release(self, instance):
        print("Botón 1 presionado")

    

DemoApp().run()
