from kivymd.app import MDApp
from kivymd.uix.textfield import MDTextField

from datetime import datetime

class MyApp(MDApp):
    def build(self):
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

        return self.TxtF_Fecha

    def on_text_validate(self, instance, text):
        try:
            datetime.strptime(text, "%Y-%m-%d")  # Intentar convertir la fecha
            self.TxtF_Fecha.error = False  # No hay error, se muestra el mensaje de ayuda
        except ValueError:
            self.TxtF_Fecha.error = True  # Error, se muestra el mensaje de error

MyApp().run()