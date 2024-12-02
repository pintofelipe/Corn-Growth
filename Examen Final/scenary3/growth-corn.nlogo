globals [
  max-plant-height         ; Altura máxima de las plantas de maíz
  min-nutrient-level       ; Nivel mínimo de nutrientes para el crecimiento
  ideal-temperature        ; Temperatura ideal para el crecimiento
  ideal-precipitation      ; Precipitación ideal en mm
  row-spacing              ; Espacio entre hileras en cm
  plant-spacing            ; Espacio entre plantas en una hilera en cm




  ; Nuevas variables
  average-height           ; Altura promedio del cultivo
  health-percentage        ; Porcentaje de plantas saludables
  growth-efficiency        ; Eficiencia de crecimiento según condiciones
  seedling-threshold       ; Umbral de altura para la etapa de plántula
  mature-threshold         ; Umbral de altura para la etapa madura
]

breed [plants plant]       ; Definir entidad de la planta

plants-own [
  height                   ; Altura de la planta
  health                   ; Estado de salud: sana, estresada, enferma
  growth-stage             ; Etapa de crecimiento: semilla, plántula, madura
]

to setup
  clear-all

  ; Configurar parámetros iniciales
  set max-plant-height 300
  set min-nutrient-level 6.0  ; pH ideal para el crecimiento
  set ideal-temperature 25
  set ideal-precipitation 50
  set row-spacing 10         ; Espacio entre hileras en dm
  set plant-spacing 10       ; Espacio entre plantas en dm
  set seedling-threshold 10
  set mature-threshold 150

  ; Ajuste de la vista de la "hectárea"
  resize-world -25 25 -25 25 ; Ajusta el tamaño de la vista
  setup-terreno
  setup-plantas
  reset-ticks
end

to setup-terreno
  ask patches [
    set pcolor brown
    set moisture-level moisture-level   ; 50   %
    set nutrient-level nutrient-level   ; 6.0 ; ph ideal
    set temperature temperature         ; 25     ; °C
  ]
end



to setup-plantas
  let row-start -20  ; Posición inicial en el eje y para la primera fila
  let plant-height-initial 5  ; Altura inicial de cada planta

  while [row-start <= 20] [
    let col-start -20  ; Posición inicial en el eje x para la primera planta en la fila

    while [col-start <= 20] [
      create-plants 1 [
        setxy col-start row-start
        set shape "plant"
        set color green
        set height plant-height-initial
        set health "healthy"
        set growth-stage "seed"
      ]
      set col-start col-start + plant-spacing / 10 ; Espacio entre plantas
    ]
    set row-start row-start + row-spacing / 10    ; Espacio entre hileras
  ]
end

to go
  if ticks >= 100 [ stop ] ; Finaliza la simulación después de 100 días

  ask plants [

    let height-total 0
    ; Variables climáticas
    let temp-current-min max list 10 (random-float 20 + 10)
    let temp-current-max min list 30 (random-float 20 + 10)
    let GDD max list 0 ((temp-current-min + temp-current-max) / 2 - 10) ; °C

      ; Revisar si la planta puede crecer
    if (GDD > 0) and (health = "healthy") and (nutrient-level >= min-nutrient-level) OR (moisture-level >= 50) [
      ; Incrementar la altura según el GDD y actualizar el estado de crecimiento

      ; Evaluar factores que afectan el crecimiento solo si los deslizadores cumplen con los valores requeridos
      ; TEMPERATURE
      if (temperature != 0) [ ; Verifica que el deslizador de temperatura tenga un valor válido
        ifelse (temperature >= 20 and temperature <= 30) [
          ; Buen crecimiento
          set height-total 0 ; Peso positivo para condiciones óptimas
        ] [
          ifelse (temperature < 20) [
            ; Reducción de crecimiento
            set height-total (height-total - 2) ; Peso negativo
            if (ticks = 90)[
            ]
             ;user-message "Reducir crecimiento"
          ] [
            ; Estrés y enfermedades
          ; user-message "Estrés y enfermedades"
            set height-total (height-total - 3) ; Peso más negativo
            set health "stressed" ; Marca la planta como estresada
          ]
        ]
      ]


      ; LIGHT-HOURS
      if (light-hours != 0) [ ; Verifica que el deslizador de horas de luz tenga un valor válido
        if (light-hours <= 4) [
          ; Provoca crecimiento lento o muerte
           ;user-message "crecimiento lento o muerte"
          set height-total height-total - 2 ; Penalización significativa
          set health "stressed" ; Marca la planta como estresada
        ]
      ]



     ; ALTITUDE
      if (altitude != 0) [ ; Verifica que el deslizador de altitud tenga un valor válido
        ifelse (altitude >= 1000 and altitude <= 2000) [
          ; Crecimiento óptimo
           ;user-message "good"
          ;set height-total 0 ; Peso positivo
        ][
          ifelse (altitude >= 0 and altitude < 1000) [
            ; Crecimiento bueno pero más lento
            set height-total height-total + 2 ; Peso moderado
           ;user-message "crecimiento bueno pero más lento"
          ] [
            ifelse (altitude > 2000 and altitude <= 3000)[
              ; Crecimiento lento con riesgos
              set height-total height-total - 3 ; Penalización moderada
              set health "stressed" ; Marca la planta como estresada
              ;user-message "crecimiento lento con riesgos"
            ] [
              ; Altitud extrema, no germina
              ;user-message "El maíz no crece a esta altitud extrema."
            ]
          ]
        ]
      ]


      ; Calcular la nueva altura considerando height-total





      ifelse (height-total != 0) [
        ;print("hay cambios en la altura aplicando el caso 3 temperatura ")
          ; user-message "hay cambios"
        set height min list ((height + GDD * 0.7) + height-total) max-plant-height
      ] [
       ;print("Todo esta ready")
          ; user-message "good"
         set height min list (height + GDD * 0.7) max-plant-height ; Ajuste del coeficiente de crecimiento
      ]

      ;print(height)
      ; Cambiar las etapas de crecimiento y color según la altura
      if height > 10 [
        set growth-stage "seedling"
        set color lime
      ]

      if height > 150 [
        set growth-stage "mature"
        set color yellow
      ]

      ; Si la planta alcanza su altura máxima, detiene su crecimiento
      if height >= max-plant-height [
        set health "mature"
        set color brown
      ]
    ]



   ; if GDD <= 0 or health != "healthy" [
       ; el GDD no es suficiente, la planta podría enfermar
     ;  set health "sick"
     ; set color blue
    ;]

     ; Cambiar color según estado
    if health = "healthy" [ set color green ]
    if health = "stressed" [ set color red ]
    if health = "sick" [ set color blue ]

  ]



  ; Actualizar plots y avanzar en el tiempo
  actualizar-plots

  tick
  tick-advance 1
  wait 0.1
end



to actualizar-plots
  ; Gráfica de altura promedio
  set-current-plot "Average Plant Height"
  set-current-plot-pen "Height"
  ifelse any? plants [
    plot mean [height] of plants
  ] [
    plot 0
  ]
  ; Gráfica de salud de plantas
  set-current-plot "Plant Health Status"

  set-current-plot-pen "Healthy"
  plot count plants with [health = "healthy"]

  set-current-plot-pen "Stressed"
  plot count plants with [health = "stressed"]

  set-current-plot-pen "Sick"
  plot count plants with [health = "sick"]


  ; Gráfica de etapas de crecimiento
  set-current-plot "Plant Growth Stage"
  set-current-plot-pen "Seed"
  plot count plants with [growth-stage = "seed"]
  set-current-plot-pen "Seedling"
  plot count plants with [growth-stage = "seedling"]
  set-current-plot-pen "Mature"
  plot count plants with [growth-stage = "mature"]
end
@#$#@#$#@
GRAPHICS-WINDOW
829
10
1500
682
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks
30.0

BUTTON
128
57
191
90
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
45
57
108
90
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
21
221
304
403
Average Plant Height
days
Hight cm
0.0
100.0
0.0
300.0
false
false
"" ""
PENS
"Height" 1.0 0 -8862290 true "" "plot mean [height] of plants"

PLOT
31
427
592
632
Plant Growth Stage
days
number-of-plant
0.0
100.0
0.0
1800.0
false
true
"" ""
PENS
"Seed" 1.0 0 -14439633 true "" "plot count plants with [growth-stage = \"seed\"]"
"Seedling" 1.0 0 -15390905 true "" "plot count plants with [growth-stage = \"seedling\"]"
"Mature" 1.0 0 -1184463 true "" "plot count plants with [growth-stage = \"mature\"]"

PLOT
320
220
607
404
Plant Health Status
days
number-of-plants
0.0
100.0
0.0
1800.0
false
true
"" ""
PENS
"Healthy" 1.0 0 -15040220 true "" "plot count plants with [health = \"healthy\"]"
"Sick" 1.0 0 -8431303 true "" "plot count plants with [health = \"sick\"]"
"Stressed" 1.0 0 -7500403 true "" " plot count plants with [health = \"stressed\"]"

MONITOR
477
137
544
182
plants
count plants
3
1
11

SLIDER
32
170
204
203
moisture-level
moisture-level
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
31
128
203
161
nutrient-level
nutrient-level
0
10
6.0
0.1
1
ph
HORIZONTAL

SLIDER
233
67
405
100
temperature
temperature
10
50
29.0
1
1
°C
HORIZONTAL

CHOOSER
450
65
588
110
visualization
visualization
"scenaryOne" "scenaryTwo" "scenaryThree"
2

SLIDER
229
168
401
201
altitude
altitude
0
3000
1262.0
1
1
metros
HORIZONTAL

SLIDER
232
120
404
153
light-hours
light-hours
0
24
3.0
1
1
horas
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model simulates the growth of corn plants in a virtual environment, taking into account factors such as temperature, soil moisture, and available nutrients. The goal is to understand how these variables affect plant health and growth over time. The model allows you to observe the impact of different environmental conditions on plant growth and visualize how these variables change over time.

## HOW IT WORKS

The model uses agents that represent corn plants and patches that simulate the terrain. Plants follow the following rules: Growth: Plants grow based on accumulated degree days (GDD), which depend on temperature. If conditions are ideal, plants increase in height; otherwise, they can become sick.
Health: Each plant can be in one of three health states: healthy, sick, or mature. A plant's health is determined by its ability to grow under current environmental conditions.
Nutrients and moisture: Patches of land have nutrient and moisture levels that decrease over time, affecting plant growth.

## HOW TO USE IT

To use the model, follow these steps in the interface tab: Setup button: Start the simulation and set up the initial environment with plants and soil. Go button: Starts the simulation cycle, where plants will grow and soil conditions will be updated. Sliders: Adjust parameters such as minimum nutrient level, temperature, moisture-level, and other environmental factors. This will influence the growth behavior of the plants. Graphs: Observe graphs showing average plant height, health status, and growth stages over time.

## THINGS TO NOTICE

While running the model, observe the following: How soil conditions affect plant growth. Are there any noticeable trends in plant height and health?
The relationship between GDD and plant health. Do plants grow more when conditions are ideal?
Changes in plant coloration depending on their health status and growth stage.

## THINGS TO TRY

Experiment with the following settings: Change the maximum height of the plants and see how it affects overall growth.
Adjust the minimum nutrient level and see if the plants can stay healthy.
Try different temperature and precipitation values ​​to see how they influence plant health and growth.
Observe how moisture distribution in the soil affects plant growth.

## EXTENDING THE MODEL

To make the model more complicated and detailed, consider adding or changing the following in the code: Incorporate pests or diseases that can affect plant health and growth.
Simulate different corn species with different growth requirements and characteristics.
Add fertilization effects that influence soil nutrient levels and therefore plant growth.
Include a crop rotation cycle that affects soil quality over time.

## NETLOGO FEATURES

The model uses several interesting NetLogo features, such as: Race: Different races (plants) are used to represent plants, making it easy to manage their specific properties.
Own patches: Each patch of the terrain has individual properties (moisture level, nutrients), allowing to simulate a varied environment.
Dynamic graphs: Graphs are updated in real time to show the progress of plant growth and health.

## RELATED MODELS
Related models in the NetLogo library that may be of interest: Plant Growth: A model that shows how environmental conditions affect plant growth.
Ecosystem: A model that simulates the interaction between different species in an ecosystem.
Agriculture: Models that focus on agriculture and the impact of different practices on crop growth.

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
