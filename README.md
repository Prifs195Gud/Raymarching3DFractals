[LT/EN]

![Pvz nuotrauka](https://github.com/Prifs195Gud/Raymarching3DFractals/blob/main/Mandelbulb.JPG?raw=true)

# Trimačių Fraktalų Atvaizdavimas Spindulio Žygio Metodu

Programa turi du rėžimus: apžvalginis ir darbo. Paleidus paprastai bus apžvalginis rėžimas. Numetus ant .exe konfigūracijos failą bus darbo.

## Reikalaujama įranga
- Programavimo aplinka:	Microsoft Visual Studio 2019
- CUDA SDK ir GPU kuri palaiko BENT compute_52 (5.2) t.y. geriau arba lygus su Quadro M6000 , GeForce 900, GTX-970, GTX-980, GTX Titan X. [Nvidia GPU list](https://developer.nvidia.com/cuda-gpus)
- Nvidia runtime versija lygi arba geriau negu: v511.65

## Valdymas
Apžvalginiame rėžime valdymas:
- W/A/S/D - kameros pozicijos keitimas.
- Q/E - kameros į apačia ir į viršų judėjimas.
- Kairysis shift - laikydami jį greičiau judėsite.
- Rodyklių klavišai - kameros žiūrėjimo kampo keitimas.
- 0/1/2/3...9 - scenos keitimas
- H - gijos skaičiavimų parodymo rėžimas
- L - šėšialiavimo rėžimas
- O - aplinkos okliuzijos rėžimas
- P - pauzė
- T - nuotraukos padarymas

&nbsp;

# Rendering 3d Fractals With The Ray Marching Method

This program has two modes: explore and work modes. If it is run normally it will be in the explore mode. If a config file is dropped on the .exe it will be run in work mode.

## Run requirements
- Integrated development environment: Microsoft Visual Studio 2019
- CUDA SDK and GPU which supports at least compute_52 (5.2) i.e. better or equal with Quadro M6000 , GeForce 900, GTX-970, GTX-980, GTX Titan X. [Nvidia GPU list](https://developer.nvidia.com/cuda-gpus)
- Nvidia runtime version better or equal: v511.65

## Controls
Explore mode controls:
- W/A/S/D - change camera position.
- Q/E - change camera up and down position. 
- Left shift - when holding it you will move faster.
- Arrow keys - change camera rotation
- 0/1/2/3...9 - change scene
- H - thread workload heatmap.
- L - lighting mode.
- O - ambient occlusion mode.
- P - pause.
- T - take a screenshot.
