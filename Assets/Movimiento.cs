using UnityEngine;

public class Movimiento : MonoBehaviour
{
    [Header("Movimiento circular")]
    public float radio = 2f;
    public float velocidadRotacion = 1f;

    [Header("Oscilación vertical")]
    public float amplitud = 0.5f;
    public float velocidadOscilacion = 2f;

    private Vector3 centro;
    private float angulo;

    void Start()
    {
        // Guardamos el punto central del círculo
        centro = transform.position;
    }

    void Update()
    {
        // Aumentamos el ángulo con el tiempo
        angulo += velocidadRotacion * Time.deltaTime;

        // Movimiento circular en XZ
        float x = Mathf.Cos(angulo) * radio;
        float z = Mathf.Sin(angulo) * radio;

        // Oscilación vertical en Y
        float y = Mathf.Sin(Time.time * velocidadOscilacion) * amplitud;

        // Aplicamos la posición
        transform.position = centro + new Vector3(x, y, z);
    }
}
