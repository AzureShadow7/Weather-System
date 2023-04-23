using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialChange : MonoBehaviour
{
    // Start is called before the first frame update

    [Header("Ground Materials")]
    public Material gradualSnowMat;
    public Material gradualRainMat;
    public Material walkableSnowMat;

    public MeshRenderer groundmeshRenderer;

    void Start()
    {
        groundmeshRenderer = GetComponent<MeshRenderer>();

        Material currentMaterial1 = groundmeshRenderer.material;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void snowfall()
    {
        groundmeshRenderer.material = gradualSnowMat;
    }

    public void snowedGround()
    {
        groundmeshRenderer.material = walkableSnowMat;
    }

    public void rainfall()
    {
        groundmeshRenderer.material = gradualRainMat;
    }
}
