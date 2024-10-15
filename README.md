Comenzar a Desarrollar Nuestro modelo de simulación en NetLogo

1. Propósito
El objetivo del modelo es simular el crecimiento del maíz bajo diferentes condiciones ambientales (temperatura, precipitación, nutrientes del suelo, luz solar) y observar cómo estas variables afectan el rendimiento final de la parcela. La simulación será una herramienta útil para agricultores que deseen optimizar el rendimiento del cultivo.


2. Entidades, variables de estado y escalas
Entidades:
Plantas de maíz: Son los agentes principales del modelo.
Suelo: Representa la parcela donde crecen las plantas y proporciona nutrientes y agua.
Clima: Simula las condiciones ambientales (temperatura, precipitación, luz solar).
Variables de Estado:
Plantas de maíz:
Altura: Se mide en centímetros (cm).
Estado de salud: Puede ser "Sano", "Enfermo", o "Muerto".
Etapa de crecimiento: Las etapas son "Semilla", "Plántula", y "Maduro".
Suelo:
Humedad: Proporción de agua en el suelo (%).
Nivel de nutrientes: Proporción de nutrientes en el suelo (%).
Espacio entre hileras: Distancia entre las plantas (cm).
Clima:
Temperatura: En grados Celsius (°C).
Precipitación: En milímetros de agua (mm).
Horas de luz solar: Número de horas por día.
Escalas:
Unidad de tiempo: Un "tick" representa un día.
Área de simulación: Una parcela de cultivo representada en metros cuadrados.

3. Descripción general de los procesos y programación
La simulación sigue una secuencia diaria donde el crecimiento del maíz depende de los factores ambientales.
Condiciones ambientales: Cada día, se actualizan las condiciones climáticas (temperatura, precipitación, luz solar).
Cálculo de GDD (Grados-Día de Crecimiento):
Fórmula: 


La temperatura mínima es de 50°F (10°C) y la máxima es de 86°F (30°C). Si los valores están fuera de estos límites, el crecimiento se detiene o la planta muere.
Estado de las plantas: Cada día se evalúan:
Disponibilidad de agua y nutrientes.
GDD y temperaturas.
Si las condiciones no son favorables, la salud de la planta se deteriora.
Etapa de crecimiento: Las plantas pasan por varias etapas (Semilla, Plántula, Maduro) a medida que crecen. Las condiciones climáticas y del suelo determinan si avanzan o retroceden en estas etapas.
Interacciones: Las plantas interactúan con el entorno. Si la parcela tiene suficiente agua y nutrientes, crecen más rápidamente.
4. Conceptos de diseño
Principios básicos:
El crecimiento del maíz es impulsado por la luz solar, agua, temperatura, y nutrientes en el suelo. Las plantas responden a la disponibilidad de estos recursos.
Emergencia:
El rendimiento total de la parcela es el resultado de la suma del crecimiento individual de cada planta, en función de su entorno.
Objetivos:
Cada planta intenta alcanzar su tamaño máximo y reproducirse, dependiendo de las condiciones ambientales.
Detección:
Las plantas "detectan" los niveles de agua, nutrientes y las condiciones climáticas, y ajustan su tasa de crecimiento en consecuencia.
Aleatoriedad:
Las condiciones climáticas pueden variar de un día a otro, introduciendo variaciones aleatorias en la temperatura y precipitación.
Interacción:
Las plantas interactúan principalmente con el clima y el suelo. También compiten por recursos si están plantadas muy cerca unas de otras.
Colectivos:
El rendimiento total de la parcela se calcula sumando la altura, el estado de salud y el rendimiento de grano de todas las plantas.
Observación:
Las variables observables incluyen la altura de las plantas, el estado de salud, la disponibilidad de agua, nutrientes y las condiciones climáticas diarias.


5. Inicialización
Al inicio de la simulación:
Todas las plantas son plántulas pequeñas.
El suelo tiene un nivel estándar de humedad y nutrientes.
La temperatura y la precipitación pueden ser configuradas por el usuario o generarse aleatoriamente con base en datos históricos.
La distancia entre las plantas se puede ajustar antes de iniciar la simulación.

6. Datos de entrada
Los usuarios pueden introducir:
Condiciones iniciales del suelo (humedad y nutrientes).
Datos climáticos (temperatura diaria y precipitación).
Número de plantas por parcela (densidad de siembra).

7. Submodelos
Crecimiento de plantas:
Calcula la altura diaria de las plantas usando la fórmula de GDD y el acceso a recursos (agua, nutrientes, luz).
Salud de las plantas:
Evalúa el estado de salud de las plantas basándose en la disponibilidad de nutrientes, agua y condiciones climáticas. Si las condiciones están fuera de los parámetros ideales, las plantas pueden enfermar o morir.
Ciclo climático:
Genera las condiciones climáticas diarias, como temperatura, precipitación y horas de luz solar. Las temperaturas pueden tener variabilidad diaria, y las precipitaciones pueden seguir un patrón estacional o ser aleatorias.

Siguiente paso: Implementación en NetLogo
Configurar el terreno:
Usar la función patches de NetLogo para crear una representación del terreno.
Asignar atributos a los parches para la humedad y nutrientes del suelo.
Crear los agentes:
Usar turtles para representar las plantas de maíz.
Definir sus variables (altura, estado de salud, etapa de crecimiento).
Condiciones climáticas:
Generar variaciones diarias de temperatura, precipitación y luz solar.
Implementar la fórmula de GDD para calcular el crecimiento.
Control de estado de salud:
Usar condicionales para que las plantas se deterioren o crezcan dependiendo de la disponibilidad de agua, nutrientes y las condiciones climáticas.
Visualización y gráficos:
Mostrar la evolución del crecimiento en gráficos de NetLogo que representen la altura de las plantas, el estado de salud y la humedad del suelo.

