# Proyecto_Graficos

Asly Rodriguez Hidalgo- Shader PS1.

Para este trabajo he desarrollado un shader con un script en Unity 6 con URP con el objetivo de recrear los gráficos de la PlayStation 1, centrandome principalmente en el flat shading, que es el concepto que hemos trabajado en clase. 

Al empezar el proyecto, lo primero fue entender como es la estructura de un shader en Unity, ya que hasta ahora hemos trabajado con HTML, WebGL y JavaScript. Esto me obligó a investigar como funcionan los vertex y fragment shaders en URP, ya que se ve que puede ser diferente en built in. Para ello fui a esta página https://docs.unity3d.com/es/530/Manual/ShadersOverview.html.

Desde el principio tenía claro por donde empezar para conseguir el efecto PS1. El punto clave fue el flat shading, que en el shader se consigue usando nointerpolation. De esta forma, la iluminación se calcula por cara y no por píxel, evitando la interpolación entre vértices y consiguiendo ese efecto de polígonos planos.
Primero al crear la escena probe con diferenetes assets unos mas low poly y otro menos, finalmente me quede con unos que se notaran mas los triamgulos. Para la iluminacion quise implemtar el Phong visto en clase para controlar mejor la iluminacion y que se haga mas facil de controlar y que quede visualmente mejor. No era estrictamente necesario usar el Phong ya que en La PS1 normal no se usaba. 

Al conseguir ya el efecto de los planos decidí aplicar el mismo efecto sobre las texturas de los assets. Una vez que se veia el efecto, decidi exagerar mas el efecto de plano, asi que en alugnos modelos cambi las normales en vez de imortar las normales las calcule y les baje a 0 el smooth angle para que se ve mucho mas brusco.
Para reforzar aún más el efecto PS1 vi que se veia bastante pixelado asi que lo añadi. También implementé dithering usando una matriz de Bayer para los colores y un efecto jitter en los vertices (vertex snapping) que simula el efecto de "lag".  

<img width="823" height="480" alt="image" src="https://github.com/user-attachments/assets/8b3ea2fa-442b-431d-a24f-1e02058acb95" />

Todos los parámetros importantes del shader (iluminacion, tamaño de pixel, profundidad de color, dithering, jitter, etc...) están visibles en el inspector de Unity, lo que permite modificar los valores y adaptalos segun la escena y sea mas personalizable. 

<img width="367" height="435" alt="Variables" src="https://github.com/user-attachments/assets/35b1cb26-8110-48ff-808b-5c3272d8b538" />

El mayor problema que tuve al realizar el trabajo fue la iluminacion de la escena, es decir como se comportaban por ejemplo las point lights con el entorno. Por ejemplo una pared que tenia el material con el shader implementado no reflejaba la luz como lo puede hacer un material base de unity que si lo hace. 
Para realizar este trabajo utilice como herramientas la pagina oficial de unity, foros de reedit e inteligencia artificial para solucionar errores. 


Escena sin aplicar ningun shader: 

<img width="1136" height="500" alt="Sin nada" src="https://github.com/user-attachments/assets/60450a01-8bd9-4b00-8d9f-fe893eb0511c" />

Escena con el shader PS1: 

<img width="1152" height="528" alt="Efecto PS1" src="https://github.com/user-attachments/assets/74923205-a16d-45d0-9bb5-b0b5946f2b81" />

<img width="818" height="464" alt="image" src="https://github.com/user-attachments/assets/6a5b170c-c0dd-49ca-8f2c-860403f6989f" />


