using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayMarching : MonoBehaviour
{
    float length(Vector2 p)
    {
        return Mathf.Sqrt((p.x * p.x) + (p.y * p.y));
    }

    float SignedDistFunctionToCirle(Vector2 p, Vector2 centre, float radius)
    {
        return length(centre - p) - radius;
    }

    //float SignedDistFunctionToBox(Vector2 p, Vector2 centre, Vector2 size)
    //{
    //    Vector2 offset = Mathf.Abs(p - centre) - size; 
    //}
}
