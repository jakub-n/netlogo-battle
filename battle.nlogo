;;__includes["a.nls" "b.nls"]

breed [redarmy redsoldier]
breed [bluearmy bluesoldier]

globals [
  stepLength 
  armyMargin
  ]

turtles-own[
  is-fighting
  ]

to setup
  clear-all
  setGlobals
  set-default-shape turtles "default"
  ;;set-default-shape turtles "person"
  setArmy
  ask turtles [ set size turtle-icon-size]
  ;;set death-prob 30 ;; in %
  drawChessboard
  reset-ticks
end

to go
  tick
  ask turtles [checkneighour]
  ask turtles with[is-fighting = false][
    move
    ]

  ask turtles with [is-fighting = true][ 
      fight
    ]
  if done? [
    stop
  ]
end

to setGlobals
  set stepLength 1
  set armyMargin 1
end

to setArmy  
  create-redarmy army-population [
    set color red
    
     if red_position = "random" [
       
        setxy (random (max-pxcor) - max-pxcor) (random (max-pycor * 2) - max-pycor)
        set heading 90
     ]
    
    if red_position = "corner" [
      let position_x min-pxcor + armyMargin
      let position_y max-pycor - armyMargin
      
      setxy position_x position_y
       
       while[count turtles-here > 1][
         set position_y position_y - person-radius
         
         if position_y <= 0 [
          set position_y max-pycor - armyMargin
          set position_x position_x + person-radius 
          ]
         
         setxy position_x position_y
         ]
      
       set heading 150         
      ]
    
    if red_position = "side" [
      let position_x min-pxcor
      let position_y max-pycor / 2
      
      setxy position_x position_y
       
       while[count turtles-here > 1][
         set position_y position_y - person-radius
         
         if position_y <= min-pycor / 2 [
          set position_y max-pycor / 2
          set position_x position_x + person-radius
           ]
         
         setxy position_x position_y
         ]
       set heading 90         
    ]

    set is-fighting false
    ]
  
  create-bluearmy army-population [
    set color blue
    
      if red_position = "random" [
       
        setxy (random (max-pxcor)) (random (max-pycor * 2) - max-pycor)
        set heading 270
     ]
    
    if blue_position = "corner" [
      let position_x max-pxcor - armyMargin
      let position_y min-pycor + armyMargin
      
      setxy position_x position_y
       
       while[count turtles-here > 1][
         set position_y position_y + person-radius
         
         if position_y >= 0 [
          set position_y min-pycor + armyMargin
          set position_x position_x - person-radius
           ]
         
         setxy position_x position_y
         ]
       set heading 300      
      ]
    
    if blue_position = "side" [
      let position_x max-pxcor
      let position_y max-pycor / 2
      
      setxy position_x position_y
       
       while[count turtles-here > 1][
         set position_y position_y - person-radius
         
         if position_y <= min-pycor / 2 [
          set position_y max-pycor / 2
          set position_x position_x - person-radius 
           ]
         
         setxy position_x position_y
         ]
        set heading 270          
    ]
     
    set is-fighting false
    ]
end

to move
  let originalXPosition xcor
  let originalYPosition ycor
  let originalDirection heading
  let originalPatch patch-here
  let positionFound? false
  
  let borderId getBorderIndex
  ifelse borderId != 0 
  [
    if borderId = 1 [set heading 180]
    if borderId = 2 [set heading 270]
    if borderId = 3 [set heading 0]
    if borderId = 4 [set heading 90]
    fd 1
    set originalDirection heading
    set positionFound? validateCurrentPosition
    ]
  [
    set positionFound? standardMove
    ]
  
   if not positionFound? [
    set xcor originalXPosition
    set ycor originalYPosition
    set heading originalDirection
    ;;show (word "Turtle " who " could not find proper position.")
  ]
  
end  

to-report getBorderIndex
  let borderWidth 0.1
  let topBorder max-pycor - borderWidth
  let bottomBorder min-pycor + borderWidth
  let rightBorder max-pxcor - borderWidth
  let leftBorder min-pxcor + borderWidth
  ;;show (word "top left bottom right borders: " topBorder rightBorder bottomBorder leftBorder)
  if [pycor] of patch-here >= topBorder
  [
    report 1
    ]
  
   if [pxcor] of patch-here >= rightBorder 
  [
    report 2
    ]
  
   if [pycor] of patch-here <= bottomBorder
  [
    report 3
    ]
  
   if [pxcor] of patch-here <= leftBorder
  [
    report 4
    ]  
  report 0  
end  
    
  
to-report standardMove
let counter 0
  let positionFound? false
  while [counter < 3 and not positionFound? ] [
    setNewPosition
    let positionValid? validateCurrentPosition
    if positionValid? [
      set positionFound? true
    ]
    set counter counter + 1
  ] 
  report positionFound?
end



to setNewPosition
  let turningStrategyIndex selectTurningStrategy
  
  ;; TODO delete
  ;;show word "setNewPosition turningStrategyIndex " turningStrategyIndex
  
  if turningStrategyIndex = 1 [setPositionByVisibleEnemy]
  if turningStrategyIndex = 2 [setPositionByFootprints]
  if turningStrategyIndex = 3 [setPositionRandomly]
end

to-report selectTurningStrategy
  let weightList (list (enemy-vision-weight * enemyVisionAvailable?) (getGroupingWeight * groupingAvailable?) random-weight)
  let randomNumber random (sum weightList)
  let selectedTurningStrategyIndex 0
  
  ;; TODO delete
  ;;show (word "sum weightList: " (sum weightList) " random number " randomNumber)
  
  let counter 1
  while [selectedTurningStrategyIndex = 0] [
    if (counter > 3) [
      show (word "turning selection cycle counter overrun; random number: " randomNumber " list: " weightList)
    ]
    let weightSum sum (sublist weightList 0 counter)
    ;;show (word "in while " counter " sum " weightSum " random number " randomNumber " sublist " (sublist weightList 0 counter))
    if randomNumber < weightSum [
      set selectedTurningStrategyIndex counter
      ;;show word "set selectedTurningStrategyIndex " counter
    ]
    set counter (counter + 1)
  ]
  report selectedTurningStrategyIndex
end

to-report getGroupingWeight
 ifelse breed = redarmy 
 [
   report grouping_weight_red
   ] 
 [
   report grouping_weight_blue
   ]
end

;; it returns true if there is no solder in radius "person-radius"
to-report validateCurrentPosition
  report not any? other turtles in-radius person-radius 
  
end

;; it returns boolean encoded as int (0~false 1~true)
to-report enemyVisionAvailable?
  report ifelse-value any? visibleEnemies [1] [0]
end

;; return true if position was set; false otherwise
to setPositionByVisibleEnemy
    let nearestEnemy min-one-of visibleEnemies [distance myself]
    face nearestEnemy
    applyHeadingDeviation
    forward stepLength
end

;; it returns boolean encoded as int (0~false 1~true)
to-report groupingAvailable?
  report ifelse-value any? neighbourFootprintedPatches [1] [0]
end

to setPositionByFootprints
  let relevantFellows neighbourFootprintedPatches
  
  let headingSum 0
  let headingCount count relevantFellows
  ask relevantFellows [
    set headingSum (sumAngle headingSum heading)
  ]
  let averageHeading headingSum / headingCount
  let newHeading (sumAngle ((1 - grouping-factor) * heading) (grouping-factor * averageHeading))
  set heading newHeading
  forward stepLength
end

to-report sumAngle [a b] 
  let extA a + 360
  let extB b + 360
  let aPlusB extA + extB - 720
  report aPlusB
end

to setPositionRandomly 
  rt random getTurningHalfRange
  lt random getTurningHalfRange 
  forward stepLength
end

to-report getTurningHalfRange
 let range 0
 ifelse breed = redarmy 
 [
   set range turning_range_red
   ] 
 [
   set range turning_range_blue
   ]
 report range / 2
end

to faceAgeragePointOf [turtleSet]
  let sumX 0
  let sumY 0
  ask turtleSet [
    set sumX (sumX + xcor)
    set sumY (sumY + ycor)
  ]
  let x (sumX / count turtleSet)
  let y (sumY / count turtleSet)
  faceXY x y
end

to applyHeadingDeviation
  rt random 40
  lt random 40
end

to checkneighour
  if any? enemiesInFightingRadius [
    if not is-fighting [
       set color color + 3
       set is-fighting true
    ] 
  ]
  
    
  if not any? enemiesInFightingRadius [
     if is-fighting [    
       set color color - 3
       set is-fighting false
     ]  
  ]
  
end

to fight
  if any? enemiesInFightingRadius [
    ask one-of enemiesInFightingRadius [
      if random 100 < death-prob [
        die
        ;;show word [color] of myself "won"
      ]
    ]
  ]

end

to-report done?
  if not any? turtles with [breed = redarmy] [
    report true
  ]
  if not any? turtles with [breed = bluearmy] [
    report true
  ]
  report false
end

to-report neighbourFootprintedPatches
  let relevantFellows other turtles in-cone (stepLength + 3) 180 with [breed = [breed] of myself]
  report relevantFellows
end

to-report visibleEnemies 
   report turtles in-radius view-radius with [breed != [breed] of myself]
end

to-report enemiesInFightingRadius
   report turtles in-radius fight-radius with [breed != [breed] of myself]
end

to drawChessboard 
    ask patches [
      fillWithOriginalColor
    ]
end

to fillWithOriginalColor
      let lightShade? ((pxcor + pycor) mod 2) = 0
      ifelse lightShade? [
        set pcolor background_color + 0.5
      ] [
        set pcolor background_color
      ]
end
@#$#@#$#@
GRAPHICS-WINDOW
422
11
965
575
20
20
13.0
1
10
1
1
1
0
0
0
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
6
10
70
43
Setup
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

BUTTON
78
10
141
43
Go
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
148
10
211
43
step
go
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
11
296
206
446
fighters counts
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"redarmy" 1.0 0 -2674135 true "" "plot count turtles with [breed = redarmy]"
"bluearmy" 1.0 0 -13345367 true "" "plot count turtles with [breed = bluearmy]"

SLIDER
994
40
1196
73
army-population
army-population
20
100
70
10
1
NIL
HORIZONTAL

SLIDER
994
80
1196
113
fight-radius
fight-radius
1.0
3
1.4
0.2
1
NIL
HORIZONTAL

SLIDER
994
120
1195
153
death-prob
death-prob
0
100
5
1
1
%
HORIZONTAL

MONITOR
11
240
68
285
reds
count turtles with [breed = redarmy]
17
1
11

MONITOR
69
240
126
285
blues
count turtles with [breed = bluearmy]
17
1
11

MONITOR
130
240
206
285
currently fighting
count turtles with [is-fighting = true]
17
1
11

PLOT
207
296
407
446
currently fighting
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles with [is-fighting = true]"

CHOOSER
9
72
101
117
red_position
red_position
"corner" "side" "random"
0

CHOOSER
217
72
309
117
blue_position
blue_position
"corner" "side" "random"
0

INPUTBOX
997
384
1095
444
background_color
51
1
0
Color

SLIDER
1101
384
1200
417
turtle-icon-size
turtle-icon-size
1
3
1
1
1
NIL
HORIZONTAL

TEXTBOX
998
359
1148
377
Visual settings
11
0.0
0

TEXTBOX
996
23
1146
41
Global settings
11
0.0
1

TEXTBOX
15
53
165
71
Red army settings
11
0.0
1

SLIDER
995
160
1195
193
person-radius
person-radius
0
1
1
0.1
1
NIL
HORIZONTAL

SLIDER
994
199
1195
232
view-radius
view-radius
0
20
20
1
1
NIL
HORIZONTAL

SLIDER
994
239
1196
272
enemy-vision-weight
enemy-vision-weight
0
100
55
1
1
%
HORIZONTAL

SLIDER
996
276
1197
309
random-weight
random-weight
1
100
55
1
1
%
HORIZONTAL

TEXTBOX
221
52
371
70
Blue army settings
11
0.0
1

TEXTBOX
13
219
163
237
Statistics
11
0.0
1

SLIDER
996
314
1198
347
grouping-factor
grouping-factor
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
9
124
151
157
turning_range_red
turning_range_red
0
360
120
10
1
NIL
HORIZONTAL

SLIDER
218
124
376
157
turning_range_blue
turning_range_blue
0
360
240
10
1
NIL
HORIZONTAL

SLIDER
9
163
165
196
grouping_weight_red
grouping_weight_red
0
100
0
1
1
%
HORIZONTAL

SLIDER
219
162
377
195
grouping_weight_blue
grouping_weight_blue
0
100
0
1
1
%
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

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
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [breed = redarmy]</metric>
    <metric>count turtles with [breed = bluearmy]</metric>
    <enumeratedValueSet variable="random-weight">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red_position">
      <value value="&quot;corner&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;side&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grouping_weight_blue">
      <value value="0"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="turning_range_red">
      <value value="120"/>
      <value value="240"/>
      <value value="360"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-prob">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="person-radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="view-radius">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grouping_weight_red">
      <value value="0"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="turning_range_blue">
      <value value="120"/>
      <value value="240"/>
      <value value="360"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="background_color">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enemy-vision-weight">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="army-population">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grouping-factor">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="turtle-icon-size">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fight-radius">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue_position">
      <value value="&quot;corner&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;side&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
